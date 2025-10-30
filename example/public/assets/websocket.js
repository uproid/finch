var socketOutput = 0;
const videoElement = document.getElementById('serverVideo');

if (videoElement) {
    let sourceBuffer;

    const mediaSource = new MediaSource();
    videoElement.src = URL.createObjectURL(mediaSource);

    mediaSource.addEventListener('sourceopen', function () {
        sourceBuffer = mediaSource.addSourceBuffer('video/webm; codecs="opus,vp8"');
        sourceBuffer.addEventListener('updateend', function () {
            if (videoElement.paused) {
                videoElement.play();
            }
        });
    });
    const peerConnection = new RTCPeerConnection();
    let mediaRecorder;
    var socketEvents = {
        connected: function (data) {
            this.output({ data: 'Web Socket connected' });
            console.log('Web Socket connected');
        },

        close: function (e) {
            this.output({ data: 'Web Socket closed' });
            console.log('Web Socket closed');
        },

        output: function (data) {
            socketOutput++;
            if (document.getElementById('socket-output'))
                document.getElementById('socket-output').innerHTML = `${socketOutput}.  ${data.data}\n` + document.getElementById('socket-output').innerHTML;
        },

        clients: function (data) {
            if (document.getElementById('socket-output')) {
                document.getElementById('client-list').innerHTML = '';

                for (var i = 0; i < data.data.length; i++) {
                    var id = data.data[i];
                    var template = document.getElementById('btn-template-client').innerHTML;
                    document.getElementById('socket-output').innerHTML = `client ${i + 1}: ${id}\n` + document.getElementById('socket-output').innerHTML;
                    template = template.replace('{text}', `Client ${i + 1}`);
                    template = template.replace('{id}', id);
                    document.getElementById('client-list').innerHTML += template;
                }

                initClientList();
            }
        },

        streamServer: function (data) {
            const rawData = new Uint8Array(data.data);
            sourceBuffer?.appendBuffer(rawData);
        }
    }

    var socket = new WebSocket("/ws");
    socket.onmessage = function (e) {
        var data = JSON.parse(e.data);
        console.log(data);
        if (socketEvents[data.path]) {
            socketEvents[data.path](data);
        }
    };

    socket.onclose = function (e) {
        socketEvents.close(e);
    }


    document.getElementById('btn-socket-time')?.addEventListener('click', function () {
        socket.send(JSON.stringify({ path: 'time' }));
    });

    document.getElementById('btn-socket-fa')?.addEventListener('click', function () {
        socket.send(JSON.stringify({ path: 'fa' }));
    });

    document.getElementById('btn-socket-clients')?.addEventListener('click', function () {
        socket.send(JSON.stringify({ path: 'clients' }));
    });

    function initClientList() {
        document.querySelectorAll('.socket-client-send')?.forEach(function (element) {
            element.addEventListener('click', function () {
                var id = this.getAttribute('data-id');
                socket.send(JSON.stringify({ path: 'toclient', data: { id, message: `Hello! how are you?` } }));
            });
        });
    }

    document.getElementById('btn-stream')?.addEventListener('click', function () {
        socket.send(JSON.stringify({ path: 'clients' }));
    });

    document.getElementById('btn-stop-stream')?.addEventListener('click', function () {
        const vs = document.getElementById('videoStream');
        if (vs) {
            vs.classList.add('d-none');
            vs.classList.add('hidden');
        }
        mediaRecorder.stop();

        var localVideo = document.getElementById('localVideo');
        localVideo.pause(); // Pause the video
        localVideo.currentTime = 0;

        videoElement.pause();
        videoElement.currentTime = 0;
    });

    document.getElementById('btn-socket-stream')?.addEventListener('click', function () {
        const vs = document.getElementById('videoStream');
        if (vs) {
            vs.classList.remove('d-none');
            vs.classList.remove('hidden');
        }

        // دسترسی به دوربین و میکروفون
        navigator.mediaDevices.getUserMedia({ video: true, audio: true })
            .then((stream) => {
                document.getElementById('localVideo').srcObject = stream;
                stream.getTracks().forEach((track) => {
                    peerConnection.addTrack(track, stream);
                });

                // Send to server
                mediaRecorder = new MediaRecorder(stream, {
                    mimeType: `video/webm; codecs="opus,vp8"`,
                    videoBitsPerSecond: 100_000, // 2.5 Mbps for video will be OK
                    audioBitsPerSecond: 6_000    // 128 kbps for audio will be OK
                });

                mediaRecorder.ondataavailable = (event) => {
                    if (event.data.size > 0) {
                        event.data.arrayBuffer().then((data) => {
                            var toB64 = (buffer) => {
                                const byteArray = new Uint8Array(buffer);
                                var res = [];
                                byteArray.forEach((node) => res.push(node));
                                return res;
                            }
                            socket.send(JSON.stringify({
                                path: 'stream',
                                // JUST HERE SHOULD BE JSON event.data
                                blob: toB64(data)
                            }));
                        });
                    }
                };
                mediaRecorder.start(1000);
            })
            .catch((error) => console.error('Error accessing media devices:', error));
    });
}
