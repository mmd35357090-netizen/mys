import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';

class ChatImageViewer extends StatefulWidget {
  final ChatMessageModel chatMessage;
  final VoidCallback? handler;

  const ChatImageViewer({super.key, required this.chatMessage, this.handler})
      ;

  @override
  EnlargeImageViewState createState() => EnlargeImageViewState();
}

class EnlargeImageViewState extends State<ChatImageViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ThemeIconWidget(
                  ThemeIcon.backArrow,
                  size: 20,
                  color: Colors.white,
                ).ripple(() {
                  Get.back();
                }),
              ],
            ).hp(DesignConstants.horizontalPadding),
            Expanded(
                child: MessageImage(
                    message: widget.chatMessage, fitMode: BoxFit.contain)),
          ],
        ));
  }
}
