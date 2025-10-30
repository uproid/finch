import 'dart:convert';
import 'dart:io';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/src/tools/convertor/serializable/value_converter/json_value.dart';
import 'package:finch/finch_console.dart';

/// Manages WebSocket connections and events.
/// The [SocketManager] class handles WebSocket connections, manages client sessions,
/// and facilitates communication between the server and connected clients.
/// It also provides methods for sending messages to clients and users, handling connection events, and managing sessions.
class SocketManager {
  /// The server instance associated with this [SocketManager].
  FinchApp server;

  /// Optional [SocketEvent] object that contains event handlers for WebSocket connections.
  SocketEvent? event;

  /// A map of routes and corresponding [SocketEvent] handlers.
  Map<String, SocketEvent> routes = {};

  /// Manages WebSocket sessions.
  final SessionsManager session = SessionsManager();

  /// Constructs a [SocketManager] instance with the specified server and optional event handlers.
  ///
  /// The [server] parameter is required and represents the server instance.
  /// The [event] parameter is optional and allows setting up event handlers.
  /// The [routes] parameter is optional and allows setting up route-based event handling.
  SocketManager(
    this.server, {
    this.event,
    this.routes = const {},
  }) {
    server.socketManager = this;
  }

  /// Gets the count of connected clients.
  int get countClients => session.countClients;

  /// Gets the count of unique users with active connections.
  int get countUsers => session.countUsers;

  /// Adds new WebSocket events to the route map.
  ///
  /// The [events] parameter is a map where keys are route paths and values are [SocketEvent] handlers.
  void addEvents(Map<String, SocketEvent> events) {
    routes.addAll(events);
  }

  /// Handles an incoming WebSocket request and establishes a WebSocket connection.
  ///
  /// The [rq] parameter is the WebRequest that initiated the WebSocket upgrade.
  /// The optional [userId] parameter associates the WebSocket connection with a specific user.
  Future<Request> requestHandle(Request rq, {String? userId}) async {
    var socket = await WebSocketTransformer.upgrade(Context.rq.httpRequest);
    final id = rq.headers['sec-websocket-key']!.first;
    session.add(
      id,
      SocketClient(
        id: id,
        socket: socket,
        rq: rq,
        manager: this,
      ),
      userID: userId,
    );

    if (session.getClient(id) != null) {
      event?.onConnect?.call(session.getClient(id)!);
    }

    socket.listen(
      (data) {
        var res = <String, dynamic>{};
        try {
          Map json = FinchJson.jsonDecoder(data);
          res = Map<String, dynamic>.from(json);
        } catch (e) {
          Console.e(e);
          res = {'path': 'error', 'data': data};
        }

        if (routes.containsKey(res['path'] ?? '')) {
          routes[res['path']]?.onMessage!(session.getClient(id)!, res);
        } else if (event?.onMessage != null) {
          event?.onMessage!(session.getClient(id)!, res);
        }
      },
      onDone: () async {
        await event?.onDisconnect?.call(session.getClient(id)!);
        session.remove(id);
      },
      onError: (data) async {
        var res = <String, dynamic>{};
        try {
          res = jsonDecode(data);
        } catch (e) {
          res = {'path': 'error', 'data': data};
        }
        event?.onMessage!(session.getClient(id)!, res);
        event?.onError?.call(session.getClient(id)!, res);
        await event?.onDisconnect?.call(session.getClient(id)!);
        session.remove(id);
      },
      cancelOnError: true,
    );

    return rq;
  }

  /// Closes all WebSocket connections and clears the session data.
  Future close() async {
    for (var client in session.getAllClients().values) {
      client.socket.close();
    }

    session.clear();
  }

  /// Returns a list of all connected client IDs.
  List<String> getAllClientsKeys() {
    return session.getAllClients().keys.toList();
  }

  /// Sends data to all connected clients.
  ///
  /// The [data] parameter is the message to be sent.
  /// The optional [status] parameter represents the HTTP status code.
  /// The optional [path] parameter represents the message path or route.
  Future sendToAll(dynamic data, {int status = 200, String? path}) async {
    for (var client in session.getAllClients().values) {
      client.send(data, status: status, path: path);
    }
  }

  /// Sends data to a specific client by ID.
  ///
  /// The [id] parameter is the ID of the client to receive the message.
  /// The [data] parameter is the message to be sent.
  /// The optional [status] parameter represents the HTTP status code.
  /// The optional [path] parameter represents the message path or route.
  Future sendToClinet(
    String id,
    dynamic data, {
    int status = 200,
    String? path,
  }) async {
    if (session.existClient(id)) {
      session.getClient(id)!.send(data, status: status, path: path);
    }
  }

  /// Sends data to all clients associated with a specific user.
  ///
  /// The [id] parameter is the user ID.
  /// The [data] parameter is the message to be sent.
  /// The optional [status] parameter represents the HTTP status code.
  /// The optional [path] parameter represents the message path or route.
  Future sendToUser(
    String id,
    dynamic data, {
    int status = 200,
    String? path,
  }) async {
    session.getUserClientsSocket(id).forEach((clientSocket) {
      clientSocket.send(data, status: status, path: path);
    });
  }
}

/// Represents events related to WebSocket connections.
/// The [SocketEvent] class contains optional callbacks for handling WebSocket events
/// such as connection, disconnection, errors, and messages.
class SocketEvent {
  /// Callback function invoked when a client connects.
  Function(SocketClient socket)? onConnect;

  /// Callback function invoked when a client disconnects.
  Function(SocketClient socket)? onDisconnect;

  /// Callback function invoked when an error occurs.
  Function(SocketClient socket, Map<String, dynamic> data)? onError;

  /// Callback function invoked when a message is received.
  Function(SocketClient socket, Map<String, dynamic> data)? onMessage;

  /// Constructs a [SocketEvent] instance with optional event handlers.
  ///
  /// The [onConnect], [onDisconnect], [onError], and [onMessage] parameters
  /// are optional callbacks for handling respective WebSocket events.
  SocketEvent({
    this.onConnect,
    this.onDisconnect,
    this.onError,
    this.onMessage,
  });
}

/// Represents a WebSocket client.
/// The [SocketClient] class encapsulates a WebSocket connection and provides
/// methods for sending data and closing the connection.
class SocketClient {
  /// The [SocketManager] instance managing this client.
  SocketManager manager;

  /// The unique identifier of this client.
  String id;

  /// The WebSocket connection associated with this client.
  WebSocket socket;

  /// The [Request] that initiated the WebSocket connection.
  Request rq;

  /// Constructs a [SocketClient] instance with the specified parameters.
  ///
  /// The [id], [socket], [rq], and [manager] parameters are required.
  SocketClient({
    required this.id,
    required this.socket,
    required this.rq,
    required this.manager,
  });

  /// Sends data to the client via the WebSocket connection.
  ///
  /// The [data] parameter is the message to be sent.
  /// The optional [status] parameter represents the HTTP status code.
  /// The optional [path] parameter represents the message path or route.
  Future send(dynamic data, {int status = 200, String? path}) async {
    var res = <String, dynamic>{};
    res['path'] = path ?? '';
    res['status'] = status;
    res['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    res['language'] = rq.getLanguage();
    res['client'] = id;
    res['data'] = data;
    socket.add(FinchJson.jsonEncoder(res));
  }

  /// Closes the WebSocket connection and removes the client from the session.
  Future close() async {
    socket.close();
    manager.session.remove(id);
  }
}

/// Manages WebSocket client sessions.
/// The [SessionsManager] class maintains a map of connected clients and their associated
/// user IDs, allowing for efficient client management and communication.
class SessionsManager {
  /// A map of client IDs to their respective [SocketClient] instances.
  final Map<String, SocketClient> _clients = {};

  /// A map of user IDs to lists of connected client IDs.
  final Map<String, List<String>> _users = {};

  /// Checks if a client with the specified ID exists.
  ///
  /// The [id] parameter is the unique identifier of the client.
  bool existClient(String id) {
    return _clients.containsKey(id);
  }

  /// Checks if a user with the given ID has active sessions.
  bool existUser(String userId) {
    return _users.containsKey(userId);
  }

  /// Adds a client to the session with an optional user ID association.
  ///
  /// The [clinetID] is the unique ID of the client. The [socket] is the [SocketClient] instance
  /// to add. Optionally, a [userID] can be provided to associate the client with a user.
  void add(String clinetID, SocketClient socket, {String? userID}) {
    _clients[clinetID] = socket;
    if (userID != null) {
      if (!_users.containsKey(userID)) {
        _users[userID] = [];
      }
      if (!_users[userID]!.contains(clinetID)) {
        _users[userID]!.add(clinetID);
      }
    }
  }

  /// Retrieves a list of client IDs associated with a specific user ID.
  ///
  /// The [userID] parameter is the ID of the user. Returns a list of client IDs associated with the user.
  List<String> getUserClientsID(String userID) {
    return _users[userID] ?? [];
  }

  /// Retrieves a list of [SocketClient] instances associated with a specific user ID.
  ///
  /// The [userID] parameter is the ID of the user. Returns a list of [SocketClient] instances associated
  /// with the user.
  List<SocketClient> getUserClientsSocket(String userID) {
    var allID = _users[userID] ?? [];
    var res = <SocketClient>[];
    for (var id in allID) {
      if (_clients.containsKey(id)) {
        res.add(_clients[id]!);
      }
    }

    return res;
  }

  /// Retrieves a [SocketClient] instance by its ID.
  ///
  /// The [id] parameter is the unique ID of the client. Returns the [SocketClient] instance associated
  /// with the ID, or `null` if no such client exists.
  SocketClient? getClient(String id) {
    return _clients[id];
  }

  /// Retrieves a map of all clients with their IDs as keys.
  ///
  /// Returns a map where the keys are client IDs and the values are [SocketClient] instances.
  Map<String, SocketClient> getAllClients() {
    return _clients;
  }

  /// Removes a client from the session by its ID.
  ///
  /// The [id] parameter is the unique ID of the client to remove. Also removes the client from the user
  /// associations if applicable.
  void remove(String id) {
    _clients.remove(id);
    _users.removeWhere((userId, userClinets) {
      userClinets.remove(id);
      return userClinets.isEmpty;
    });
  }

  /// Clears all clients and user associations from the session.
  void clear() {
    _clients.clear();
    _users.clear();
  }

  /// Returns the number of unique users with active sessions.
  int get countUsers => _users.length;

  /// Returns the total number of active WebSocket clients.
  int get countClients {
    return _clients.length;
  }

  /// Returns the number of clients associated with a specific user ID.
  ///
  /// The [userID] parameter is the ID of the user. Returns the count of client sessions associated
  /// with the user.
  int getCountUserClients(String userID) {
    return _users[userID]?.length ?? 0;
  }
}
