import 'package:foap/helper/imports/common_import.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/chat_and_call/chat_gpt_controller.dart';

class ChatGPT extends StatefulWidget {
  const ChatGPT({Key? key}) : super(key: key);

  @override
  State<ChatGPT> createState() => _ChatGPTState();
}

class _ChatGPTState extends State<ChatGPT> {
  TextEditingController textField = TextEditingController();
  final ChatGPTController _chatGPTController = ChatGPTController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          backNavigationBar(title: chatGPT.tr),
          Obx(() => Expanded(
                  child: ListView.separated(
                padding:  EdgeInsets.only(
                    top: 50, bottom: 50, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
                itemBuilder: (ctx, index) {
                  ChatGPTMessage message = _chatGPTController.messages[index];
                  return Row(
                    mainAxisAlignment: message.isSent
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (message.isSent) const Spacer(),
                      Container(
                        constraints: BoxConstraints(
                            minWidth: 50, maxWidth: Get.width - 100),
                        color: message.isSent
                            ? AppColorConstants.cardColor
                            : AppColorConstants.themeColor,
                        child: BodyLargeText(message.content)
                            .setPadding(left: 10, right: 10, top: 8, bottom: 8),
                      ).round(10),
                      if (!message.isSent) const Spacer(),
                    ],
                  );
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(
                    height: 20,
                  );
                },
                itemCount: _chatGPTController.messages.length,
              ))),
          Obx(() => _chatGPTController.messages.isNotEmpty
              ? _chatGPTController.messages.last.isSent
                  ? Lottie.asset('assets/lottie/typing.json').hp(DesignConstants.horizontalPadding)
                  : Container()
              : Container()),
          messageComposerView()
        ],
      ),
    );
  }

  Widget messageComposerView() {
    return Column(
      children: [
        Container(
          color: AppColorConstants.backgroundColor.darken(0.02),
          height: 70,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: textField,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: FontSizes.h5,
                                  color: AppColorConstants.grayscale900,
                                  fontWeight: TextWeight.medium),
                              maxLines: 50,
                              decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  labelStyle: TextStyle(
                                      fontSize: FontSizes.b2,
                                      color: AppColorConstants.themeColor,
                                      fontWeight: TextWeight.medium),
                                  hintStyle: TextStyle(
                                      fontSize: FontSizes.b2,
                                      color: AppColorConstants.themeColor,
                                      fontWeight: TextWeight.medium),
                                  hintText: pleaseEnterMessageString.tr),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Heading5Text(
                          sendString.tr,
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor,
                        ).ripple(() {
                          if (textField.text.isNotEmpty) {
                            _chatGPTController.sendMessage(textField.text);
                            textField.text = '';
                          }

                          //sendMessage();
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
        )
      ],
    );
  }
}
