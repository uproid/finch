import 'package:finch/finch_app.dart';

/// Signaling backend for the WebRTC video meeting room example.
///
/// This does NOT relay any audio/video: media flows directly between browsers
/// (peer-to-peer, mesh topology) once connected, which keeps latency low and
/// avoids putting video traffic through the Dart server. The socket here only
/// exchanges small JSON messages (who joined, SDP offers/answers, ICE
/// candidates) so peers can find each other and negotiate a direct
/// connection.
class MeetingRoomManager {
  MeetingRoomManager._();
  static final MeetingRoomManager instance = MeetingRoomManager._();

  /// roomId -> { clientId -> displayName }
  final Map<String, Map<String, String>> _rooms = {};

  /// clientId -> roomId, used to clean up on disconnect/leave.
  final Map<String, String> _clientRoom = {};

  /// clientId -> {mic, cam}, so newly joined peers immediately see the
  /// correct mute/camera-off state of everyone already in the room.
  final Map<String, Map<String, bool>> _clientState = {};

  Map<String, SocketEvent> getRoutes() {
    return {
      'meeting:join': SocketEvent(onMessage: _onJoin),
      'meeting:leave': SocketEvent(onMessage: (socket, data) => _leave(socket)),
      'meeting:signal': SocketEvent(onMessage: _onSignal),
      'meeting:chat': SocketEvent(onMessage: _onChat),
      'meeting:state': SocketEvent(onMessage: _onState),
      'meeting:screen': SocketEvent(onMessage: _onScreen),
    };
  }

  /// Must be called from the global socket `onDisconnect` handler so a
  /// dropped connection (closed tab, lost network) still frees its room slot
  /// and notifies the remaining participants.
  void onDisconnect(SocketClient socket) => _leave(socket);

  void _onJoin(SocketClient socket, Map<String, dynamic> data) {
    final payload = Map<String, dynamic>.from(data['data'] ?? {});
    final room = (payload['room'] ?? '').toString().trim();
    var name = (payload['name'] ?? '').toString().trim();
    if (room.isEmpty) return;
    if (name.isEmpty) name = 'Guest';
    if (name.length > 40) name = name.substring(0, 40);

    // A client can only be in one room at a time.
    _leave(socket);

    final members = _rooms.putIfAbsent(room, () => {});
    final existingPeers = Map<String, String>.from(members);

    members[socket.id] = name;
    _clientRoom[socket.id] = room;
    _clientState[socket.id] = {'mic': true, 'cam': true};

    // Tell the joining client who is already here (with their current
    // mic/camera state, so tiles render correctly from the first frame).
    socket.send({
      'room': room,
      'you': {'id': socket.id, 'name': name},
      'peers': existingPeers.entries
          .map((e) => {
                'id': e.key,
                'name': e.value,
                'mic': _clientState[e.key]?['mic'] ?? true,
                'cam': _clientState[e.key]?['cam'] ?? true,
              })
          .toList(),
    }, path: 'meeting:joined');

    // Tell the existing participants a new peer arrived.
    for (final peerId in existingPeers.keys) {
      socket.manager.session.getClient(peerId)?.send(
        {'id': socket.id, 'name': name, 'mic': true, 'cam': true},
        path: 'meeting:peer-joined',
      );
    }
  }

  void _onState(SocketClient socket, Map<String, dynamic> data) {
    final room = _clientRoom[socket.id];
    if (room == null) return;

    final payload = Map<String, dynamic>.from(data['data'] ?? {});
    final mic = payload['mic'] != false;
    final cam = payload['cam'] != false;
    _clientState[socket.id] = {'mic': mic, 'cam': cam};

    for (final id in _rooms[room]?.keys ?? const <String>[]) {
      if (id == socket.id) continue;
      socket.manager.session.getClient(id)?.send(
        {'id': socket.id, 'mic': mic, 'cam': cam},
        path: 'meeting:state',
      );
    }
  }

  /// Screen-share start/stop is broadcast explicitly (rather than inferred
  /// from WebRTC track events) so the UI can reliably show/remove the
  /// dedicated "screen" tile — the actual video still travels peer-to-peer,
  /// this just tells everyone else in the room when to expect/drop it.
  void _onScreen(SocketClient socket, Map<String, dynamic> data) {
    final room = _clientRoom[socket.id];
    if (room == null) return;

    final payload = Map<String, dynamic>.from(data['data'] ?? {});
    final active = payload['active'] == true;

    for (final id in _rooms[room]?.keys ?? const <String>[]) {
      if (id == socket.id) continue;
      socket.manager.session.getClient(id)?.send(
        {'id': socket.id, 'active': active},
        path: 'meeting:screen',
      );
    }
  }

  void _onSignal(SocketClient socket, Map<String, dynamic> data) {
    final payload = Map<String, dynamic>.from(data['data'] ?? {});
    final to = (payload['to'] ?? '').toString();
    final signal = payload['signal'];
    if (to.isEmpty || signal == null) return;

    // Only relay within the same room, never blindly to any client id.
    final room = _clientRoom[socket.id];
    if (room == null || _rooms[room]?.containsKey(to) != true) return;

    socket.manager.session.getClient(to)?.send(
      {'from': socket.id, 'signal': signal},
      path: 'meeting:signal',
    );
  }

  void _onChat(SocketClient socket, Map<String, dynamic> data) {
    final room = _clientRoom[socket.id];
    if (room == null) return;

    final payload = Map<String, dynamic>.from(data['data'] ?? {});
    final message = (payload['message'] ?? '').toString().trim();
    if (message.isEmpty) return;

    final name = _rooms[room]?[socket.id] ?? 'Guest';
    for (final id in _rooms[room]?.keys ?? const <String>[]) {
      if (id == socket.id) continue;
      socket.manager.session.getClient(id)?.send(
        {'from': socket.id, 'name': name, 'message': message},
        path: 'meeting:chat',
      );
    }
  }

  void _leave(SocketClient socket) {
    _clientState.remove(socket.id);
    final room = _clientRoom.remove(socket.id);
    if (room == null) return;

    final members = _rooms[room];
    members?.remove(socket.id);

    if (members != null) {
      for (final id in members.keys) {
        socket.manager.session.getClient(id)?.send(
          {'id': socket.id},
          path: 'meeting:peer-left',
        );
      }
      if (members.isEmpty) _rooms.remove(room);
    }
  }
}
