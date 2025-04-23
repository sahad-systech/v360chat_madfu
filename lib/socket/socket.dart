// import 'dart:developer';

// import 'package:socket_io_client/socket_io_client.dart' as io;

// import '../screens/chat/chat_screen.dart';

// // class SocketManager {
// //   static final SocketManager _instance = SocketManager._internal();
// //   late io.Socket _socket;

// //   factory SocketManager() {
// //     return _instance;
// //   }

// //   SocketManager._internal();

// //   void connect({
// //     required BuildContext context,
// //     required String listId,
// //   }) async {
// //     _socket = io.io(
// //         'https://webchat.systech.ae',
// //         io.OptionBuilder()
// //             .setTransports(['websocket']) // for Flutter or Dart VM
// //             .setPath('/widgetsocket.io/')
// //             .enableAutoConnect() // disable auto-connection
// //             .build());
// //     socket.connect();
// //     socket.onConnect((_) {
// //       log('Connected to Chat: socket');
// //       log("Chat: uri ${socket.io.uri.toString()}");
// //       log("Chat: checking connection ${socket.connected.toString()}");
// //       // socket.emit('setup', {'id': userId});
// //       // socket.emit('join chat', listId);
// //     });

// //     socket.onDisconnect((_) => log('Disconnected from chat socket'));
// //     socket.off('message received');
// //     _socket.on('message received', (data) {
// //       log('message received is working in socket');
// //       ChatScreenController.chatKey?.currentState
// //           ?.reciveMessage(data["message"]["content"].toString());
// //     });
// //   }

// //   io.Socket get socket => _socket;

// //   void disconnect() {
// //     _socket.disconnect();
// //   }
// // }
// class SocketManager {
//   static final SocketManager _instance = SocketManager._internal();
//   late io.Socket _socket;

//   factory SocketManager() => _instance;

//   SocketManager._internal();

//   void connect() {
//     _socket = io.io(
//       'https://webchat.systech.ae',
//       io.OptionBuilder()
//           .setTransports(['websocket'])
//           .setPath('/widgetsocket.io')
//           .enableAutoConnect()
//           .build(),
//     );

//     if (_socket.connected) return;

//     _socket.connect();

//     _socket.onConnect((data) {
//       final socketId = _socket.id;
//       log('socketId: $socketId');
//       log("Chat: uri ${_socket.io.uri}");
//       log("Chat: checking connection ${_socket.connected}");
//     });

//     _socket.onDisconnect((_) => log('Disconnected from chat socket'));

//     _socket.off('message received'); // Remove previous listener

//     _socket.on('message received', (data) {
//       log('message received is working in socket file ${data["file_path"]}');
//       if (ChatScreenController.chatKey?.currentState != null) {
//         ChatScreenController.chatKey?.currentState?.reciveMessage(
//             data["content"].toString(),
//             (data["file_path"] as List<dynamic>).cast<String>());
//       }
//     });
//   }

//   io.Socket get socket => _socket;

//   void disconnect() {
//     _socket.clearListeners();
//     _socket.disconnect();
//   }
// }
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef OnMessageReceived = void Function(
    String content, List<String> filePaths, dynamic data);

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  late io.Socket _socket;
  OnMessageReceived? onMessageReceived;

  factory SocketManager() => _instance;

  SocketManager._internal();

  void connect({
    String baseUrl = 'https://webchat.systech.ae',
    String socketPath = '/widgetsocket.io',
    OnMessageReceived? onMessage,
  }) {
    onMessageReceived = onMessage;

    // ✅ Initialize the socket first
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath(socketPath)
          .enableAutoConnect()
          .build(),
    );

    // ✅ Now it's safe to check connection
    if (_socket.connected) return;

    _socket.connect();

    _socket.onConnect((_) {
      final socketId = _socket.id;
      log('Socket connected. ID: $socketId');
    });

    _socket.onDisconnect((_) => log('Disconnected from chat socket'));

    _socket.off('message received');

    _socket.on('message received', (data) {
      final content = data["content"].toString();
      final filePaths = (data["file_path"] as List<dynamic>).cast<String>();
      onMessageReceived?.call(content, filePaths, data);
    });
  }

  io.Socket get socket => _socket;

  void disconnect() {
    _socket.clearListeners();
    _socket.disconnect();
  }
}
