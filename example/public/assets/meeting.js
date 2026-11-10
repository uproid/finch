/**
 * Video Meeting Room client.
 *
 * Topology: full mesh WebRTC. Every participant opens one RTCPeerConnection
 * directly to every other participant, so audio/video never touches the
 * Dart server — only tiny signaling messages (join/leave/offer/answer/ICE)
 * go over the existing Finch WebSocket at /ws. That keeps latency as low as
 * the network allows and avoids a media-relay bottleneck.
 *
 * Mesh scales by participant-squared upload bandwidth, so this is a great
 * fit for small rooms (a handful of people). Beyond ~6-8 participants an
 * SFU (selective forwarding unit) media server would be the next step.
 */
(function () {
  const joinScreen = document.getElementById('joinScreen');
  if (!joinScreen) return; // not on the meeting page

  const meetingScreen = document.getElementById('meetingScreen');
  const joinForm = document.getElementById('joinForm');
  const btnJoin = document.getElementById('btnJoin');
  const inputName = document.getElementById('inputName');
  const inputRoom = document.getElementById('inputRoom');
  const joinError = document.getElementById('joinError');
  const btnEnableMedia = document.getElementById('btnEnableMedia');
  const localPreviewVideo = document.getElementById('localPreviewVideo');
  const previewPlaceholder = document.getElementById('previewPlaceholder');

  const videoGrid = document.getElementById('videoGrid');
  const tileTemplate = document.getElementById('tile-template');
  const roomLabel = document.getElementById('roomLabel');
  const participantCount = document.getElementById('participantCount');
  const participantsList = document.getElementById('participantsList');
  const liveDot = document.getElementById('liveDot');
  const liveBadge = document.getElementById('liveBadge');

  const btnToggleMic = document.getElementById('btnToggleMic');
  const btnToggleCamera = document.getElementById('btnToggleCamera');
  const btnShareScreen = document.getElementById('btnShareScreen');
  const btnLeave = document.getElementById('btnLeave');
  const btnCopyLink = document.getElementById('btnCopyLink');
  const btnToggleChat = document.getElementById('btnToggleChat');
  const sidePanel = document.getElementById('sidePanel');

  const chatForm = document.getElementById('chatForm');
  const chatInput = document.getElementById('chatInput');
  const chatMessages = document.getElementById('chatMessages');

  const ICE_SERVERS = [
    { urls: 'stun:stun.l.google.com:19302' },
    { urls: 'stun:stun1.l.google.com:19302' },
  ];

  let ws = null;
  let localStream = null;
  let screenStream = null;
  let screenTrack = null;
  let myId = null;
  let myName = '';
  let myRoom = '';
  let pinnedId = null;
  const screenSuffix = videoGrid.dataset.screenSuffix || '(screen)';
  /** @type {Map<string, {pc: RTCPeerConnection, name: string}>} */
  const peers = new Map();
  const audioMeters = new Map(); // id -> {stop()}

  function connectSocket() {
    const proto = location.protocol === 'https:' ? 'wss://' : 'ws://';
    ws = new WebSocket(proto + location.host + '/ws');
    ws.onmessage = (e) => {
      let msg;
      try {
        msg = JSON.parse(e.data);
      } catch (err) {
        return;
      }
      const handler = handlers[msg.path];
      if (handler) handler(msg.data || {});
    };
  }

  function send(path, data) {
    if (!ws || ws.readyState !== WebSocket.OPEN) return;
    ws.send(JSON.stringify({ path, data }));
  }

  // ---------------- Pre-join camera preview ----------------

  async function enableLocalMedia() {
    if (localStream) return localStream;
    localStream = await navigator.mediaDevices.getUserMedia({
      video: { width: { ideal: 1280 }, height: { ideal: 720 } },
      audio: { echoCancellation: true, noiseSuppression: true, autoGainControl: true },
    });
    localPreviewVideo.srcObject = localStream;
    localPreviewVideo.classList.remove('hidden');
    previewPlaceholder.classList.add('hidden');
    playVideo(localPreviewVideo);
    return localStream;
  }

  btnEnableMedia?.addEventListener('click', () => {
    enableLocalMedia().catch((err) => showJoinError(err.message || String(err)));
  });

  // Browsers only honor the `autoplay` attribute reliably right after a user
  // gesture; a few messages later (join ack, remote track arriving) that
  // window has often closed and the element just sits paused. Call play()
  // explicitly, and if it's still rejected, the click-anywhere fallback
  // below (registered once) will retry it on the next real user gesture.
  function playVideo(video) {
    video.play().catch(() => {
      pendingPlays.add(video);
    });
  }

  const pendingPlays = new Set();
  document.addEventListener(
    'click',
    () => {
      pendingPlays.forEach((video) => {
        video.play().then(() => pendingPlays.delete(video)).catch(() => {});
      });
    },
    { capture: true }
  );

  function showJoinError(text) {
    joinError.textContent = text;
    joinError.classList.remove('hidden');
  }

  // ---------------- Join flow ----------------

  const params = new URLSearchParams(location.search);
  if (params.get('room')) inputRoom.value = params.get('room');

  joinForm?.addEventListener('submit', async (e) => {
    e.preventDefault();
    joinError.classList.add('hidden');

    const name = inputName.value.trim();
    const room = inputRoom.value.trim();
    if (!name || !room) {
      showJoinError(joinForm.dataset.roomRequired || 'Please enter your name and a room name');
      return;
    }

    try {
      await enableLocalMedia();
    } catch (err) {
      showJoinError(err.message || String(err));
      return;
    }

    myName = name;
    myRoom = room;
    setJoining(true);

    if (!ws || ws.readyState !== WebSocket.OPEN) {
      connectSocket();
      ws.addEventListener('open', () => send('meeting:join', { room, name }), { once: true });
    } else {
      send('meeting:join', { room, name });
    }
  });

  function setJoining(isJoining) {
    if (!btnJoin) return;
    btnJoin.disabled = isJoining;
    btnJoin.querySelector('span').textContent = isJoining
      ? joinForm.dataset.connectingLabel || 'Connecting...'
      : joinForm.dataset.joinLabel || 'Join meeting';
  }

  // ---------------- Signaling handlers ----------------

  const handlers = {
    'meeting:joined': (data) => {
      myId = data.you.id;
      setJoining(false);
      roomLabel.textContent = myRoom;
      joinScreen.classList.add('hidden');
      meetingScreen.classList.remove('hidden');
      liveDot?.classList.remove('hidden');
      liveBadge?.classList.remove('hidden');
      liveBadge?.classList.add('inline-flex');

      addLocalTile();
      (data.peers || []).forEach((p) => {
        createPeer(p.id, p.name, true);
        setRemoteState(p.id, p.mic, p.cam);
      });
      updateParticipantsList();
      updateWaitingHint();
    },

    'meeting:peer-joined': (data) => {
      createPeer(data.id, data.name, false);
      setRemoteState(data.id, data.mic, data.cam);
      updateParticipantsList();
      updateWaitingHint();
    },

    'meeting:peer-left': (data) => {
      removePeer(data.id);
      updateParticipantsList();
      updateWaitingHint();
    },

    'meeting:signal': (data) => handleSignal(data.from, data.signal),

    'meeting:state': (data) => setRemoteState(data.id, data.mic, data.cam),

    'meeting:screen': (data) => {
      if (!data.active) removeScreenTile(data.id);
    },

    'meeting:chat': (data) => appendChatMessage(data.name, data.message, false),
  };

  // Perfect negotiation: both sides can trigger renegotiation (e.g. either
  // peer may start a screen share later), so both need to react to
  // negotiationneeded and handle an incoming offer arriving while their own
  // offer is in flight. The peer that did NOT initiate the original
  // connection is "polite" and yields to the collision; the original
  // initiator ignores the colliding offer instead. See MDN's "Perfect
  // negotiation" pattern.
  //
  // Candidates can also arrive before the matching setRemoteDescription()
  // resolves (async handlers overlapping), so they're queued per-peer until
  // the remote description is actually in place.
  async function handleSignal(from, signal) {
    const entry = peers.get(from) || createPeer(from, 'Guest', false);
    const pc = entry.pc;

    if (signal.type === 'offer' || signal.type === 'answer') {
      if (signal.type === 'offer') {
        const offerCollision = entry.makingOffer || pc.signalingState !== 'stable';
        entry.ignoreOffer = !entry.polite && offerCollision;
        if (entry.ignoreOffer) return;

        if (offerCollision) {
          await Promise.all([
            pc.setLocalDescription({ type: 'rollback' }),
            pc.setRemoteDescription(new RTCSessionDescription(signal.sdp)),
          ]);
        } else {
          await pc.setRemoteDescription(new RTCSessionDescription(signal.sdp));
        }
        await pc.setLocalDescription();
        send('meeting:signal', { to: from, signal: { type: pc.localDescription.type, sdp: pc.localDescription } });
      } else {
        await pc.setRemoteDescription(new RTCSessionDescription(signal.sdp));
      }

      const queued = entry.pendingCandidates || [];
      entry.pendingCandidates = [];
      for (const candidate of queued) {
        try {
          await pc.addIceCandidate(new RTCIceCandidate(candidate));
        } catch (err) {
          console.warn('Failed to add queued ICE candidate', err);
        }
      }
    } else if (signal.type === 'candidate' && signal.candidate) {
      if (pc.remoteDescription) {
        try {
          await pc.addIceCandidate(new RTCIceCandidate(signal.candidate));
        } catch (err) {
          if (!entry.ignoreOffer) console.warn('Failed to add ICE candidate', err);
        }
      } else {
        entry.pendingCandidates = entry.pendingCandidates || [];
        entry.pendingCandidates.push(signal.candidate);
      }
    }
  }

  // ---------------- Peer connection lifecycle ----------------

  function createPeer(peerId, name, isInitiator) {
    if (peers.has(peerId)) return peers.get(peerId);

    const pc = new RTCPeerConnection({ iceServers: ICE_SERVERS });
    // The side that did NOT initiate the original connection defers to the
    // other on a renegotiation collision (see handleSignal / perfect
    // negotiation). cameraStreamId lets attachRemoteStream tell "this peer's
    // camera" apart from "this peer just started sharing their screen" —
    // both arrive via the same pc.ontrack, as separate MediaStreams.
    const entry = {
      pc,
      name,
      polite: !isInitiator,
      makingOffer: false,
      ignoreOffer: false,
      pendingCandidates: [],
      cameraStreamId: null,
      screenSender: null,
    };
    peers.set(peerId, entry);

    localStream?.getTracks().forEach((track) => pc.addTrack(track, localStream));
    // Late joiners while a screen share is already running get that track too.
    if (screenTrack && screenStream) {
      entry.screenSender = pc.addTrack(screenTrack, screenStream);
    }

    pc.onicecandidate = (e) => {
      if (e.candidate) {
        send('meeting:signal', { to: peerId, signal: { type: 'candidate', candidate: e.candidate } });
      }
    };

    pc.ontrack = (e) => attachRemoteStream(peerId, e.streams[0]);

    pc.onconnectionstatechange = () => updateTileStatus(peerId, pc.connectionState);

    pc.onnegotiationneeded = async () => {
      try {
        entry.makingOffer = true;
        await pc.setLocalDescription();
        send('meeting:signal', { to: peerId, signal: { type: pc.localDescription.type, sdp: pc.localDescription } });
      } catch (err) {
        console.error('negotiation failed', err);
      } finally {
        entry.makingOffer = false;
      }
    };

    addRemoteTile(peerId, name);
    return entry;
  }

  function removePeer(peerId) {
    const entry = peers.get(peerId);
    if (entry) {
      entry.pc.close();
      peers.delete(peerId);
    }
    stopAudioMeter(peerId);
    document.getElementById('tile-' + peerId)?.remove();
    if (pinnedId === peerId) applyPinnedId(null);
    removeScreenTile(peerId);
  }

  // ---------------- Tiles / UI ----------------

  function cloneTile(id, name) {
    const node = tileTemplate.content.cloneNode(true);
    const tile = node.querySelector('.tile');
    tile.id = 'tile-' + id;
    tile.querySelector('.tile-name').textContent = name;
    tile.querySelector('.tile-initial').textContent = (name || '?').trim().charAt(0).toUpperCase();
    tile.querySelector('.tile-pin-btn')?.addEventListener('click', () => togglePin(id));
    videoGrid.appendChild(node);
    return document.getElementById('tile-' + id);
  }

  function addLocalTile() {
    const tile = cloneTile('local', (myName || 'You') + ' (you)');
    const video = tile.querySelector('.tile-video');
    video.muted = true;
    attachStreamToTile('local', localStream);
    tile.querySelector('.tile-dot').classList.replace('bg-amber-400', 'bg-emerald-400');
  }

  function addRemoteTile(peerId, name) {
    cloneTile(peerId, name);
  }

  // ontrack fires once per track (audio, then video) with the same
  // MediaStream — reassigning srcObject each time would reset playback (and
  // pause it) — so only (re)attach when the stream actually changed. A
  // second, DIFFERENT stream on the same connection means that peer just
  // started sharing their screen: it gets its own dedicated tile rather
  // than replacing their camera.
  function attachRemoteStream(peerId, stream) {
    const entry = peers.get(peerId);
    if (!entry) return;

    if (!entry.cameraStreamId || stream.id === entry.cameraStreamId) {
      entry.cameraStreamId = entry.cameraStreamId || stream.id;
      attachStreamToTile(peerId, stream);
      return;
    }

    const screenId = peerId + '-screen';
    if (!document.getElementById('tile-' + screenId)) {
      cloneTile(screenId, entry.name + ' ' + screenSuffix);
    }
    attachStreamToTile(screenId, stream, { audioMeter: false });
    focusTile(screenId);
  }

  function attachStreamToTile(id, stream, opts) {
    const tile = document.getElementById('tile-' + id);
    if (!tile) return;
    const video = tile.querySelector('.tile-video');
    if (video.srcObject === stream) return;
    video.srcObject = stream;
    playVideo(video);
    if (!opts || opts.audioMeter !== false) startAudioMeter(id, stream);
  }

  function removeScreenTile(peerId) {
    const screenId = peerId + '-screen';
    stopAudioMeter(screenId);
    document.getElementById('tile-' + screenId)?.remove();
    if (pinnedId === screenId) applyPinnedId(null);
  }

  // ---------------- Pin / spotlight ----------------

  function applyPinnedId(id) {
    pinnedId = id;
    videoGrid.classList.toggle('pinned-mode', !!pinnedId);
    videoGrid.querySelectorAll('.tile').forEach((tile) => {
      const isPinned = !!pinnedId && tile.id === 'tile-' + pinnedId;
      tile.classList.toggle('is-pinned', isPinned);
      const btn = tile.querySelector('.tile-pin-btn');
      if (!btn) return;
      btn.classList.toggle('hidden', !isPinned);
      btn.classList.toggle('flex', isPinned);
      btn.title = isPinned ? btn.dataset.labelOff : btn.dataset.labelOn;
      btn.querySelector('i').className = isPinned ? 'fa-solid fa-compress text-[11px]' : 'fa-solid fa-expand text-[11px]';
    });
  }

  // Toggle: used by the user clicking a tile's pin button.
  function togglePin(id) {
    applyPinnedId(pinnedId === id ? null : id);
  }

  // Force-set: used when a screen share appears and should take focus
  // regardless of whatever was pinned before.
  function focusTile(id) {
    applyPinnedId(id);
  }

  function updateTileStatus(peerId, state) {
    const tile = document.getElementById('tile-' + peerId);
    if (!tile) return;
    const dot = tile.querySelector('.tile-dot');
    dot.classList.remove('bg-amber-400', 'bg-emerald-400', 'bg-rose-500');
    if (state === 'connected') dot.classList.add('bg-emerald-400');
    else if (state === 'failed' || state === 'disconnected' || state === 'closed') dot.classList.add('bg-rose-500');
    else dot.classList.add('bg-amber-400');
  }

  function setRemoteState(peerId, mic, cam) {
    const tile = document.getElementById('tile-' + peerId);
    if (!tile) return;
    tile.querySelector('.tile-mic-off').classList.toggle('hidden', mic !== false);
    const camOff = tile.querySelector('.tile-cam-off');
    const avatar = tile.querySelector('.tile-avatar');
    camOff.classList.toggle('hidden', cam !== false);
    avatar.classList.toggle('hidden', cam !== false);
    avatar.classList.toggle('flex', cam === false);
  }

  const waitingHint = document.getElementById('waitingHint');
  function updateWaitingHint() {
    waitingHint?.classList.toggle('hidden', peers.size > 0);
  }

  function updateParticipantsList() {
    const total = peers.size + 1;
    participantCount.textContent = String(total);

    const rows = [`<div class="flex items-center gap-2 rounded-lg px-2 py-1.5"><span class="h-2 w-2 rounded-full bg-emerald-400"></span><span class="truncate font-medium">${escapeHtml(myName)} (you)</span></div>`];
    peers.forEach((entry) => {
      rows.push(`<div class="flex items-center gap-2 rounded-lg px-2 py-1.5"><span class="h-2 w-2 rounded-full bg-emerald-400"></span><span class="truncate">${escapeHtml(entry.name)}</span></div>`);
    });
    participantsList.innerHTML = rows.join('');
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str ?? '';
    return div.innerHTML;
  }

  // ---------------- Speaking indicator (Web Audio analyser) ----------------

  function startAudioMeter(id, stream) {
    if (!stream || stream.getAudioTracks().length === 0) return;
    stopAudioMeter(id);

    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const source = ctx.createMediaStreamSource(stream);
    const analyser = ctx.createAnalyser();
    analyser.fftSize = 512;
    source.connect(analyser);
    const data = new Uint8Array(analyser.frequencyBinCount);

    let raf;
    const tick = () => {
      analyser.getByteFrequencyData(data);
      const avg = data.reduce((a, b) => a + b, 0) / data.length;
      const tile = document.getElementById('tile-' + id);
      if (tile) {
        const ring = tile.querySelector('.tile-ring');
        ring.classList.toggle('ring-4', avg > 18);
      }
      raf = requestAnimationFrame(tick);
    };
    tick();

    audioMeters.set(id, {
      stop() {
        cancelAnimationFrame(raf);
        source.disconnect();
        ctx.close();
      },
    });
  }

  function stopAudioMeter(id) {
    audioMeters.get(id)?.stop();
    audioMeters.delete(id);
  }

  // ---------------- Controls ----------------

  btnToggleMic?.addEventListener('click', () => {
    const track = localStream?.getAudioTracks()[0];
    if (!track) return;
    track.enabled = !track.enabled;
    btnToggleMic.dataset.active = String(track.enabled);
    btnToggleMic.title = track.enabled ? btnToggleMic.dataset.labelOn : btnToggleMic.dataset.labelOff;
    btnToggleMic.querySelector('i').className = track.enabled ? 'fa-solid fa-microphone' : 'fa-solid fa-microphone-slash';
    btnToggleMic.classList.toggle('bg-rose-600', !track.enabled);
    btnToggleMic.classList.toggle('text-white', !track.enabled);
    setRemoteState('local', track.enabled, localStream.getVideoTracks()[0]?.enabled);
    send('meeting:state', { mic: track.enabled, cam: localStream.getVideoTracks()[0]?.enabled !== false });
  });

  btnToggleCamera?.addEventListener('click', () => {
    const track = localStream?.getVideoTracks()[0];
    if (!track) return;
    track.enabled = !track.enabled;
    btnToggleCamera.dataset.active = String(track.enabled);
    btnToggleCamera.title = track.enabled ? btnToggleCamera.dataset.labelOn : btnToggleCamera.dataset.labelOff;
    btnToggleCamera.querySelector('i').className = track.enabled ? 'fa-solid fa-video' : 'fa-solid fa-video-slash';
    btnToggleCamera.classList.toggle('bg-rose-600', !track.enabled);
    btnToggleCamera.classList.toggle('text-white', !track.enabled);
    setRemoteState('local', localStream.getAudioTracks()[0]?.enabled !== false, track.enabled);
    send('meeting:state', { mic: localStream.getAudioTracks()[0]?.enabled !== false, cam: track.enabled });
  });

  // The screen share is added as an EXTRA track/transceiver (not a
  // replaceTrack swap of the camera), so everyone keeps seeing the
  // presenter's camera in its own tile while the screen gets a second,
  // dedicated tile — both visible at once, locally and for every peer.
  btnShareScreen?.addEventListener('click', async () => {
    if (screenTrack) {
      stopScreenShare();
      return;
    }
    try {
      screenStream = await navigator.mediaDevices.getDisplayMedia({ video: true });
      screenTrack = screenStream.getVideoTracks()[0];
      screenTrack.onended = () => stopScreenShare();

      peers.forEach((entry) => {
        entry.screenSender = entry.pc.addTrack(screenTrack, screenStream);
      });

      if (!document.getElementById('tile-local-screen')) {
        cloneTile('local-screen', (myName || 'You') + ' ' + screenSuffix);
      }
      attachStreamToTile('local-screen', screenStream, { audioMeter: false });
      focusTile('local-screen');
      send('meeting:screen', { active: true });

      btnShareScreen.dataset.active = 'true';
      btnShareScreen.title = btnShareScreen.dataset.labelOff;
      btnShareScreen.classList.add('bg-violet-600', 'text-white');
    } catch (err) {
      console.warn('Screen share cancelled/failed', err);
      screenStream = null;
    }
  });

  function stopScreenShare() {
    if (!screenTrack) return;

    peers.forEach((entry) => {
      if (entry.screenSender) {
        entry.pc.removeTrack(entry.screenSender);
        entry.screenSender = null;
      }
    });

    screenTrack.stop();
    screenTrack = null;
    screenStream = null;

    removeScreenTile('local');
    send('meeting:screen', { active: false });

    btnShareScreen.dataset.active = 'false';
    btnShareScreen.title = btnShareScreen.dataset.labelOn;
    btnShareScreen.classList.remove('bg-violet-600', 'text-white');
  }

  btnCopyLink?.addEventListener('click', async () => {
    const url = `${location.origin}${location.pathname}?room=${encodeURIComponent(myRoom || inputRoom.value.trim())}`;
    try {
      await navigator.clipboard.writeText(url);
      const original = btnCopyLink.innerHTML;
      btnCopyLink.innerHTML = '<i class="fa-solid fa-check"></i> ' + (btnCopyLink.dataset.copiedText || 'Link copied!');
      setTimeout(() => {
        btnCopyLink.innerHTML = original;
      }, 1800);
    } catch (err) {
      console.warn('Clipboard write failed', err);
    }
  });

  btnToggleChat?.addEventListener('click', () => {
    sidePanel.classList.toggle('hidden');
  });

  btnLeave?.addEventListener('click', () => leaveMeeting());

  function leaveMeeting() {
    send('meeting:leave', {});
    peers.forEach((_, id) => removePeer(id));
    stopScreenShare();
    stopAudioMeter('local');

    localStream?.getTracks().forEach((t) => t.stop());
    localStream = null;

    videoGrid.innerHTML = '';
    videoGrid.classList.remove('pinned-mode');
    pinnedId = null;
    participantsList.innerHTML = '';
    chatMessages.innerHTML = '';
    localPreviewVideo.classList.add('hidden');
    previewPlaceholder.classList.remove('hidden');
    liveDot?.classList.add('hidden');
    liveBadge?.classList.add('hidden');
    setJoining(false);
    updateWaitingHint();

    // Reset control buttons back to their default "on" state for the next join.
    [btnToggleMic, btnToggleCamera].forEach((btn) => {
      if (!btn) return;
      btn.dataset.active = 'true';
      btn.title = btn.dataset.labelOn;
      btn.classList.remove('bg-rose-600', 'text-white');
    });
    btnToggleMic.querySelector('i').className = 'fa-solid fa-microphone';
    btnToggleCamera.querySelector('i').className = 'fa-solid fa-video';

    meetingScreen.classList.add('hidden');
    joinScreen.classList.remove('hidden');
    myRoom = '';
  }

  window.addEventListener('beforeunload', () => {
    if (myRoom) send('meeting:leave', {});
  });

  // ---------------- Chat ----------------

  chatForm?.addEventListener('submit', (e) => {
    e.preventDefault();
    const message = chatInput.value.trim();
    if (!message) return;
    send('meeting:chat', { message });
    appendChatMessage(myName, message, true);
    chatInput.value = '';
  });

  function appendChatMessage(name, message, isMe) {
    const wrap = document.createElement('div');
    wrap.className = 'flex flex-col ' + (isMe ? 'items-end' : 'items-start');
    wrap.innerHTML = `
      <span class="text-[10px] font-medium text-zinc-400">${escapeHtml(name)}</span>
      <span class="max-w-[85%] rounded-xl px-3 py-1.5 ${isMe ? 'bg-teal-600 text-white' : 'bg-zinc-100 text-zinc-800'}">${escapeHtml(message)}</span>
    `;
    chatMessages.appendChild(wrap);
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }

  connectSocket();
})();
