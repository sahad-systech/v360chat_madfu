import 'package:madfu_demo/package/local_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Callback function type for handling received messages
typedef OnMessageReceived = void Function(
    {required String content,
    List<String>? filePaths,
    required dynamic response,
    required String senderType,
    required String createdAt});

/// Callback for socket errors
typedef OnSocketError = void Function(dynamic error);

/// Callback for socket disconnection
typedef OnSocketDisconnected = void Function(dynamic reason);

/// It's a singleton that manages the socket connection lifecycle and message events
class SocketManager { 
  /// Singleton instance
  static final SocketManager _instance = SocketManager._internal();
  /// The socket.io client instance
  late io.Socket _socket;
  /// Callback for handling incoming messages
  OnMessageReceived? onMessageReceived;
  /// Callback for socket errors
  OnSocketError? onSocketError;
  /// Callback for socket disconnection
  OnSocketDisconnected? onSocketDisconnected;
  /// Reconnection attempt count
  int _reconnectAttempts = 0;
  /// Max reconnection attempts
  static const int _maxReconnectAttempts = 5;

  factory SocketManager() => _instance;

  /// Private constructor to prevent instantiation
  SocketManager._internal();

  /// Establishes WebSocket connection to the chat server
  void connect({
    required String baseUrl,
    OnMessageReceived? onMessage,
    void Function()? onConnected,
    OnSocketError? onError,
    OnSocketDisconnected? onDisconnected,
  }) {
    onMessageReceived = onMessage;
    onSocketError = onError;
    onSocketDisconnected = onDisconnected;
    _reconnectAttempts = 0;

    // ✅ Initialize the socket first
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/widgetsocket.io')
          .enableAutoConnect()
          .build(),
    );

    // ✅ Now it's safe to check connection
    if (_socket.connected) return;

    _socket.connect();

    // ✅ Handle socket errors
    _socket.onError((error) {
      onSocketError?.call(error);
    });

    // ✅ Handle socket connection
    _socket.onConnect((_) async {
      _reconnectAttempts = 0; // Reset attempts on successful connection
      
      final String? customerId = await View360ChatPrefs.getCustomerId();
      if (customerId != null) {
        socket.emit("joinRoom", "customer-$customerId");
      }
      if (onConnected != null) {
        onConnected();
      }
    });

    // ✅ Handle socket disconnection
    _socket.onDisconnect((reason) {
      onSocketDisconnected?.call(reason);
      
      // Attempt to reconnect
      _attemptReconnect(baseUrl, onMessage, onConnected, onError, onDisconnected);
    });

    _socket.off('message received');
    _socket.on('message received', (data) async {
      try {
        final String type = data["type"].toString();
        if (type == "assigned-agent") {
          await View360ChatPrefs.changeQueueStatus(false);
          await View360ChatPrefs.condentIdInQueue(data["chatId"].toString());
        }
        if (type == "end-message") {
          await View360ChatPrefs.removeCustomerId();
        }

        final content = data["content"].toString();
        final List<String>? filePaths = data["file_path"] == null
            ? null
            : (data["file_path"] as List<dynamic>).cast<String>();
        onMessageReceived?.call(
            content: content,
            filePaths: filePaths,
            response: data,
            senderType: data["senderType"].toString(),
            createdAt: data["createdAt"].toString());
      } catch (e) {
        onSocketError?.call(e);
      }
    });
  }

  /// Attempts to reconnect to the socket
  void _attemptReconnect(
    String baseUrl,
    OnMessageReceived? onMessage,
    void Function()? onConnected,
    OnSocketError? onError,
    OnSocketDisconnected? onDisconnected,
  ) {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delaySeconds = _reconnectAttempts * 2; // Exponential backoff
      
      Future.delayed(Duration(seconds: delaySeconds), () {
        if (!_socket.connected) {
          connect(
            baseUrl: baseUrl,
            onMessage: onMessage,
            onConnected: onConnected,
            onError: onError,
            onDisconnected: onDisconnected,
          );
        }
      });
    }
  }

  /// Getter for the socket instance
  io.Socket get socket => _socket;

  /// Disconnects from the socket and clears all listeners
  void disconnect() {
    _socket.clearListeners();
    _socket.disconnect();
  }



}

