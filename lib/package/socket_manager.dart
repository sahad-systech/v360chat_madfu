import 'dart:developer';
import 'package:madfu_demo/package/local_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Callback function type for handling received messages
typedef OnMessageReceived = void Function(
    {required String content,
    List<String>? filePaths,
    required dynamic response,
    required String senderType,
    required String createdAt});

/// It's a singleton that manages the socket connection lifecycle and message events
class SocketManager { 
  /// Singleton instance
  static final SocketManager _instance = SocketManager._internal();
  /// The socket.io client instance
  late io.Socket _socket;
  /// Callback for handling incoming messages
  OnMessageReceived? onMessageReceived;

  factory SocketManager() => _instance;

  /// Private constructor to prevent instantiation
  SocketManager._internal();

  /// Establishes WebSocket connection to the chat server
  void connect({
    required String baseUrl,
    OnMessageReceived? onMessage,
    void Function()? onConnected,
  }) {
    // List<int> messageIdList = [];
    onMessageReceived = onMessage;
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

    _socket.onError((handler){
      log(handler.toString());
    });

    _socket.onConnect((_) async {
      final String? customerId = await View360ChatPrefs.getCustomerId();
      if (customerId != null) {
        socket.emit("joinRoom", "customer-$customerId");
      }
      log('view360 socket connected.');
      if (onConnected != null) {
        onConnected(); // ✅ Invoke the callback here
      }
    });

    _socket.onDisconnect((_) => log('Disconnected from chat socket'));

    _socket.off('message received');
    _socket.on('message received', (data) async{
      log(data.toString());
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
    });
  }

  /// Getter for the socket instance
  io.Socket get socket => _socket;

  /// Disconnects from the socket and clears all listeners
  void disconnect() {
    _socket.clearListeners();
    _socket.disconnect();
  }



}

