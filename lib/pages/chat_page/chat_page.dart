import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_demo_app/services/sendbird_service.dart';
import 'package:sendbird_demo_app/widgets/chat_page/chat_message_row.dart';
import 'package:sendbird_demo_app/widgets/chat_page/date_seperator.dart';
import 'package:sendbird_demo_app/widgets/chat_page/message_bubble.dart';
import 'package:sendbird_demo_app/widgets/chat_page/upload_picture_bottom_sheet.dart';
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
  List<Member> readMembers = [];
  Map<BaseMessage, List<Member>> tempReadMembers = {};
  late ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    widget.groupChannel.markAsRead();
    scrollController = ScrollController();
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
        for (final message in _messages) {
          tempReadMembers[message] = [];
        }
        tempReadMembers.forEach((key, value) {
          final read = channel.getReadMembers(key);

          if (read.isNotEmpty) {
            tempReadMembers[key] = read;
          }
        });
      });
    } catch (e) {
      print('group_channel_view.dart: getMessages: ERROR: $e');
    }
  }

  @override
  void onReadReceiptUpdated(GroupChannel channel) {
    super.onReadReceiptUpdated(channel);
    getMessages(channel);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeIn,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.chevron_left,
              color: Color(0XFF1AC5B9),
              size: 35,
            )),
        title: Row(
          children: [
            widget.groupChannel.name!.isNotEmpty
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0XFFBDBDBD),
                    child: Text(
                      (widget.groupChannel.name!.isEmpty
                              ? ''
                              : widget.groupChannel.name.toString())
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  )
                : CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        NetworkImage(widget.groupChannel.coverUrl.toString()),
                  ),
            const SizedBox(
              width: 20,
            ),
            Text(
              widget.groupChannel.name.toString(),
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color(0XFF1AC5B9),
              size: 30,
            ),
          )
        ],
      ),
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    ChatUser user = dashChatUserWidget(SendbirdSdk().currentUser!);
    return SingleChildScrollView(
      physics: const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
      child: Container(
        height: MediaQuery.of(context).size.height * (85 / 100),
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 14),
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
          messages: dashChatMessage(_messages.reversed.toList()),
          inputOptions: InputOptions(
            leading: [
              Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: IconButton(
                  onPressed: () async {
                    final image =
                        await UploadPictureBottomSheet(context: context)
                            .showUploadBottomSheet();
                    if (image != null) {
                      widget.groupChannel.sendFileMessage(
                        FileMessageParams.withFile(image),
                        onCompleted: (message, error) {
                          setState(() {
                            _messages.add(message);
                          });
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeIn,
                            ),
                          );
                        },
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.add_box_sharp,
                    color: Color(0XFF1AC5B9),
                    size: 36,
                  ),
                ),
              )
            ],
            sendOnEnter: true,
            inputDecoration: const InputDecoration(
              hintText: "Enter messages",
              filled: true,
              fillColor: Color(0XFFEEEEEE),
              contentPadding: EdgeInsets.only(left: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          messageListOptions: MessageListOptions(
            scrollPhysics: const BouncingScrollPhysics(),
            separatorFrequency: SeparatorFrequency.days,
            scrollController: scrollController,
            dateSeparatorBuilder: (date) => DateSeperator(date: date),
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
            messageRowBuilder: (message, previousMessage, nextMessage,
                isAfterDateSeparator, isBeforeDateSeparator) {
              final currentUser =
                  message.user.id == SendBirdService().user.userId;
              if (message.medias != null) {
                for (final media in message.medias!) {
                  return ChatMessageRow(
                      chatMedia: media,
                      message: message,
                      currentUser: currentUser,
                      tempReadMembers: tempReadMembers);
                }
              }
              return ChatMessageRow(
                message: message,
                currentUser: currentUser,
                tempReadMembers: tempReadMembers,
              );
            },
          ),
        ),
      ),
    );
  }

  List<ChatMessage> dashChatMessage(List<BaseMessage> messages) {
    List<ChatMessage> result = [];
    final instance = SendbirdSdk().getInternal();
    final ekey = instance.sessionManager.getEKey();
    for (var message in messages) {
      Sender user = message.sender!;

      result.add(
        ChatMessage(
          createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
          text: message.message,
          medias: message.toJson()['url'] != null
              ? [
                  ChatMedia(
                    url: "${message.toJson()['url']}?auth=$ekey",
                    fileName: "${message.toJson()['url']}?auth=$ekey",
                    type: MediaType.image,
                  )
                ]
              : null,
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
