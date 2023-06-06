import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_demo_app/services/sendbird_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ChatMedia? media;
  const MessageBubble({super.key, required this.message, this.media});

  @override
  Widget build(BuildContext context) {
    final currentUser = message.user.id == SendBirdService().user.userId;
    final columnKey = GlobalKey();
    return Flexible(
      child: Column(
        key: columnKey,
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
            margin: media != null
                ? Uri.parse(media!.url).isAbsolute
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(vertical: 10)
                : const EdgeInsets.symmetric(vertical: 10),
            padding: media != null
                ? Uri.parse(media!.url).isAbsolute
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(vertical: 10, horizontal: 12)
                : const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: currentUser
                  ? const Color(0XFF1AC5B9)
                  : const Color(0XFFEEEEEE),
              borderRadius: BorderRadius.circular(30),
            ),
            child: media != null
                ? Uri.parse(media!.url).isAbsolute
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          onTap: () => showImageViewer(
                              context, Image.network(media!.url).image,
                              swipeDismissible: true, useSafeArea: true),
                          child: CachedNetworkImage(
                            imageUrl: media!.url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) {
                              return Text("Cannot load $url");
                            },
                          ),
                        ),
                      )
                    : const Text("invalid url")
                : InkWell(
                    onTap: Uri.parse(message.text).isAbsolute
                        ? () => launchUrl(Uri.parse(message.text))
                        : null,
                    child: SelectableText(
                      message.text,
                      showCursor: true,
                      scrollPhysics: const ClampingScrollPhysics(),
                      textAlign: currentUser ? TextAlign.end : TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: currentUser ? Colors.white : Colors.black,
                          decoration: Uri.parse(message.text).isAbsolute
                              ? TextDecoration.underline
                              : null),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
