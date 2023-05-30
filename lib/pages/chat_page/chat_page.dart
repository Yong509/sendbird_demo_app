import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_demo_app/services/sendbird_service.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChatPage extends StatefulWidget {
  final GroupChannel groupChannel;
  const ChatPage({super.key, required this.groupChannel});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with ChannelEventHandler {
  List<BaseMessage> _messages = [];
  @override
  void initState() {
    super.initState();
    widget.groupChannel.markAsRead();
    getMessages(widget.groupChannel);
    SendbirdSdk().addChannelEventHandler(widget.groupChannel.channelUrl, this);
  }

  @override
  void dispose() {
    SendbirdSdk().removeChannelEventHandler(widget.groupChannel.channelUrl);
    super.dispose();
  }

  @override
  onMessageReceived(channel, message) {
    widget.groupChannel.markAsRead();
    setState(() {
      _messages.add(message);
    });
  }

  Future<void> getMessages(GroupChannel channel) async {
    try {
      List<BaseMessage> messages = await channel.getMessagesByTimestamp(
          DateTime.now().millisecondsSinceEpoch * 1000, MessageListParams());
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      print('group_channel_view.dart: getMessages: ERROR: $e');
    }
  }

  @override
  void onReadReceiptUpdated(GroupChannel channel) {
    super.onReadReceiptUpdated(channel);
    final readMembers = widget.groupChannel.getReadMembers(_messages.last);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.groupChannel.name.toString(),
            ),
            Text(
              [
                for (final member in widget.groupChannel.members)
                  member.nickname
              ].join(","),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    ChatUser user = dashChatUserWidget(SendbirdSdk().currentUser!);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
      child: DashChat(
        key: Key(widget.groupChannel.channelUrl),
        currentUser: user,
        onSend: (ChatMessage message) {
          widget.groupChannel.markAsRead();
          var sentMessage =
              widget.groupChannel.sendUserMessageWithText(message.text);
          setState(() {
            _messages.add(sentMessage);
          });
        },
        messages: dashChatMessage(_messages),
        inputOptions: InputOptions(
          leading: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
          sendOnEnter: true,
          inputDecoration: const InputDecoration(
              hintText: "Enter messages",
              border: OutlineInputBorder(borderSide: BorderSide())),
        ),
        messageOptions: MessageOptions(
          showCurrentUserAvatar: true,
          showOtherUsersAvatar: true,
          messageDecorationBuilder: (message, previousMessage, nextMessage) {
            return BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              color: message.user.id == SendBirdService().user.userId
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200], // example
            );
          },
        ),
      ),
    );
  }

  List<ChatMessage> dashChatMessage(List<BaseMessage> messages) {
    List<ChatMessage> result = [];
    for (var message in messages) {
      Sender user = message.sender!;
      result.add(
        ChatMessage(
          createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
          text: message.message,
          user: dashChatUserWidget(user),
        ),
      );
    }
    return result;
  }

  ChatUser dashChatUserWidget(User user) {
    return ChatUser(
      id: user.userId,
      profileImage: user.profileUrl,
      firstName: user.nickname,
    );
  }
}
