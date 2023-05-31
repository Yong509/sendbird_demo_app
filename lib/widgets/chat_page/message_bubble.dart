import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_demo_app/services/sendbird_service.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final currentUser = message.user.id == SendBirdService().user.userId;
    return Flexible(
      child: Column(
        crossAxisAlignment:
            currentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          currentUser
              ? const SizedBox()
              : Text(
                  message.user.getFullName(),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.black.withAlpha(95),
                      ),
                ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: currentUser
                  ? const Color(0XFF1AC5B9)
                  : const Color(0XFFEEEEEE),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              message.text,
              textAlign: currentUser ? TextAlign.end : TextAlign.start,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: currentUser ? Colors.white : Colors.black,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
