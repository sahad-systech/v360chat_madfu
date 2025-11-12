import 'dart:developer';
import 'package:madfu_demo/package/local_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
// import 'package:view360_chat/src/local/local_storage.dart';

typedef OnMessageReceived = void Function(
    {required String content,
    List<String>? filePaths,
    required dynamic response,
    required String senderType,
    required String createdAt});

class SocketManager { 
  static final SocketManager _instance = SocketManager._internal();
  late io.Socket _socket;
  OnMessageReceived? onMessageReceived;

  factory SocketManager() => _instance;

  SocketManager._internal();

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
    _socket.on('message received', (data) {
      log(data.toString());
      final String type = data["type"].toString();
      if (type == "assigned-agent") {
        View360ChatPrefs.changeQueueStatus(false);
        View360ChatPrefs.condentIdInQueue(data["chatId"].toString());
      }
      if (type == "end-message") {
        View360ChatPrefs.removeCustomerId();
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

  io.Socket get socket => _socket;

  void disconnect() {
    _socket.clearListeners();
    _socket.disconnect();
  }



}

