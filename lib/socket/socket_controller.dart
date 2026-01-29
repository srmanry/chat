import 'package:get/get.dart';

import 'socket_service.dart';

class ChatController extends GetxController {
  final SocketService socketService = SocketService();
  final String myId = "user_1";
  final String friendId = "user_2";
  @override
  void onInit() {
    socketService.connect(myId);

    socketService.onMessage((data) {
      // UI update
    });

    super.onInit();
  }

  void sendMessage(String text) {
    socketService.sendMessage({
      'senderId': myId,
      'receiverId': friendId,
      'message': text,
    });
  }
}
