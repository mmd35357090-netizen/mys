import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class StoryReplyChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const StoryReplyChatTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: message.messageContentType == MessageContentType.reactedOnStory
            ? 180
            : 220,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: message.isMineMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            message.messageContentType == MessageContentType.reactedOnStory
                ? BodySmallText(message.isMineMessage
                    ? youReactedToStory.tr
                    : '${message.userName} ${reactedToYourStory.toLowerCase()}')
                : BodySmallText(message.isMineMessage
                    ? youRepliedToStory.tr
                    : '${message.userName} ${repliedToYourStory.toLowerCase()}'),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: SizedBox(
                width: 120,
                child: message.messageContentType ==
                        MessageContentType.reactedOnStory
                    ? Stack(
                        children: [
                          Positioned(
                            left: message.isMineMessage ? 20 : 0,
                            top: 0,
                            bottom: 0,
                            right: message.isMineMessage ? 0 : 20,
                            child: Container(
                              color: message.isMineMessage
                                  ? AppColorConstants.disabledColor
                                  : AppColorConstants.themeColor
                                      .withOpacity(0.2),
                              child: SizedBox(
                                height: double.infinity,
                                child: CachedNetworkImage(
                                  imageUrl: message.repliedOnStory.media.first.image!,
                                  httpHeaders: const {'accept': 'image/*'},
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      AppUtil.addProgressIndicator(size: 100),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ).round(15),
                          ),
                          Positioned(
                            left: message.isMineMessage ? 0 : null,
                            right: message.isMineMessage ? null : 0,
                            bottom: 0,
                            child: Image.asset(
                              message.textMessage,
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: message.isMineMessage
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: message.isMineMessage
                                ? AppColorConstants.disabledColor
                                : AppColorConstants.themeColor.withOpacity(0.2),
                            child: SizedBox(
                              height: 150,
                              child: CachedNetworkImage(
                                imageUrl: message.repliedOnStory.media.first.image!,
                                httpHeaders: const {'accept': 'image/*'},
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    AppUtil.addProgressIndicator(size: 100),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ).round(15),
                          Expanded(
                            child: BodyLargeText(
                              message.textMessage,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ));
  }
}
