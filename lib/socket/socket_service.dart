import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String userId) {
    socket = IO.io(
      'http://YOUR_IP:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      socket.emit('register', userId);
    });
  }

  void sendMessage(Map<String, dynamic> data) {
    socket.emit('send_message', data);
  }

  void onMessage(Function(dynamic) callback) {
    socket.on('receive_message', callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}
