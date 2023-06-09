import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_demo_app/services/sendbird_service.dart';
import 'package:sendbird_demo_app/widgets/chat_page/message_bubble.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChatMessageRow extends StatefulWidget {
  final ChatMessage message;
  final bool currentUser;
  final Map<BaseMessage, List<Member>> tempReadMembers;
  final ChatMedia? chatMedia;
  const ChatMessageRow(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.tempReadMembers,
      this.chatMedia});

  @override
  State<ChatMessageRow> createState() => _ChatMessageRowState();
}

class _ChatMessageRowState extends State<ChatMessageRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            widget.message.user.id != SendBirdService().user.userId
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
        children:
            widget.currentUser ? _buildChat().reversed.toList() : _buildChat(),
      ),
    );
  }

  List<Widget> _buildChat() {
    return [
      buildCircleAvatar(message: widget.message),
      const SizedBox(
        width: 10,
      ),
      widget.chatMedia != null
          ? MessageBubble(
              message: widget.message,
              media: widget.chatMedia,
            )
          : MessageBubble(message: widget.message),
      _buildMessageCreateTime(context, widget.message)
    ];
  }

  Widget buildCircleAvatar({required ChatMessage message}) {
    return message.user.id != SendBirdService().user.userId
        ? message.user.profileImage!.isEmpty
            ? CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0XFFBDBDBD),
                child: Text(
                  (message.user.getFullName().isEmpty
                          ? message.user.id
                          : message.user.firstName.toString())
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ))
            : CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  message.user.profileImage!,
                ),
              )
        : const SizedBox();
  }

  Widget _buildMessageCreateTime(BuildContext context, ChatMessage message) {
    final currentUser = message.user.id == SendBirdService().user.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
      child: Row(
        crossAxisAlignment:
            currentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _buildReadIcon(message),
          Text(
            DateFormat.jm().format(message.createdAt),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.black.withAlpha(72)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadIcon(ChatMessage message) {
    Widget read = const SizedBox();
    widget.tempReadMembers.forEach((key, value) {
      if (key.message == message.text) {
        if (value.isNotEmpty) {
          read = const Icon(
            Icons.check,
            color: Color(0XFF259C72),
            size: 13,
          );
        } else {
          read = const SizedBox();
        }
      }
    });
    return read;
  }
}
