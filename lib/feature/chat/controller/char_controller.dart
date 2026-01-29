import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../model/chat_model.dart';

class ChatController extends GetxController {
  late IO.Socket socket;

  final RxList<Message> messages = <Message>[].obs;
  final RxBool isFriendTyping = false.obs;

  String myId = "user_1";
  // String myId = "user_2";
  String friendId = "user_2";

  @override
  void onInit() {
    super.onInit();
    connectSocket();
  }

  void connectSocket() {
    socket = IO.io(
      "http://127.0.0.1:3000",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionAttempts(9999)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .disableAutoConnect()
          .build(),
    );

    print("Connecting... myId: $myId | friendId: $friendId");

    socket.connect();

    socket.onConnect((_) {
      print('CONNECTED → id: ${socket.id}');
      print('Registering as $myId');
      socket.emit('register', myId);
      print('register sent');
    });

    socket.onDisconnect((reason) {
      print('DISCONNECTED | reason: $reason | myId: $myId');
    });

    socket.onReconnect((attempt) {
      print('RECONNECTED after $attempt');
      socket.emit('register', myId);
      print('Re-registered');
    });

    socket.on('receive_message', (data) {
      print('RECEIVED: $data');
      messages.add(
        Message(
          senderId: data['senderId'] ?? 'unknown',
          receiverId: data['receiverId'] ?? 'unknown',
          text: data['message'] ?? '',
          time: DateTime.now(),
          isSeen: true,
        ),
      );
      messages.refresh();
    });

    socket.on('typing', (data) {
      if (data['from'] == friendId) {
        isFriendTyping.value = true;
        Future.delayed(const Duration(seconds: 3), () {
          isFriendTyping.value = false;
        });
      }
    });

    socket.onError((err) {
      print('Socket ERROR: $err');
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final data = {'senderId': myId, 'receiverId': friendId, 'message': text};

    socket.emit('send_message', data);
    print('Sent: $data');

    messages.add(Message(senderId: myId, receiverId: friendId, text: text, time: DateTime.now(), isSeen: false));
    messages.refresh();
  }

  void emitTyping() {
    socket.emit('typing', {'from': myId, 'to': friendId});
  }

  void stopTyping() {
    socket.emit('stop_typing', {'to': friendId});
  }

  @override
  void onClose() {
    socket.disconnect();
    super.onClose();
  }
}
