import 'package:foap/components/thumbnail_view.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class StoryChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const StoryChatTile({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 250,
      child: Container(
        color: message.isMineMessage
            ? AppColorConstants.disabledColor
            : AppColorConstants.themeColor.withOpacity(0.2),
        child: SizedBox(
          height: 250,
          child: message.storyContent.media.first.image != null
              ? CachedNetworkImage(
                  imageUrl: message.storyContent.media.first.image!,
                  httpHeaders: const {'accept': 'image/*'},
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      AppUtil.addProgressIndicator(size: 100),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : FutureBuilder<ThumbnailResult>(
                  future: genThumbnail(message.storyContent.media.first.video!),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      final image = snapshot.data.userImage;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          image,
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.red,
                        child: Text(
                          "Error:\n${snapshot.error.toString()}",
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator().p16;
                    }
                  },
                ),
        ),
      ).round(15),
    );
  }
}
