class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime time;
  bool isSeen;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.time,
    this.isSeen = false, // ✅ NEVER NULL
  });
}
