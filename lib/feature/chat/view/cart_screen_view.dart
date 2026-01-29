import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/char_controller.dart'; // chat_controller.dart হলে নাম ঠিক করো

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final position = 0.0;
    if (animate) {
      _scrollController.animateTo(position, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _scrollController.jumpTo(position);
    }
  }

  @override
  void initState() {
    super.initState();
    // নতুন মেসেজ এলে অটো স্ক্রল
    controller.messages.listen((_) {
      Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
    });
    // প্রথমবার লোডে নিচে যাও
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animate: false));
  }

  @override
  void dispose() {
    textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Chat"),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Typing indicator
          Obx(() {
            if (!controller.isFriendTyping.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Friend is typing...",
                  style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ),
            );
          }),

          // Debug: total messages count (remove later)
          Obx(() => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Messages count: ${controller.messages.length}", style: const TextStyle(color: Colors.red)),
          )),

          // Messages List
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[controller.messages.length - 1 - index];
                  final isMe = msg.senderId == controller.myId;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF007AFF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatTime(msg.time),
                            style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Input field + send button
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -3)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: const Color(0xFFF1F1F1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      ),
                      onTap: () => controller.emitTyping(),
                      onChanged: (value) {
                        if (value.trim().isEmpty) controller.stopTyping();
                      },
                      onSubmitted: (value) {
                        final trimmed = value.trim();
                        if (trimmed.isNotEmpty) {
                          controller.sendMessage(trimmed);
                          textController.clear();
                          controller.stopTyping();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF007AFF),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 24),
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isNotEmpty) {
                          controller.sendMessage(text);
                          textController.clear();
                          controller.stopTyping();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}