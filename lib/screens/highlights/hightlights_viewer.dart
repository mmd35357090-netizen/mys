import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/highlights_imports.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

class HighlightViewer extends StatefulWidget {
  final HighlightsModel highlight;

  const HighlightViewer({Key? key, required this.highlight}) : super(key: key);

  @override
  State<HighlightViewer> createState() => _HighlightViewerState();
}

class _HighlightViewerState extends State<HighlightViewer> {
  final controller = StoryController();
  final HighlightsController highlightController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: storyWidget(),
    );
  }

  Widget storyWidget() {
    return Stack(
      children: [
        StoryView(
            storyItems: [
              for (HighlightMediaModel media
                  in widget.highlight.medias.reversed)
                media.story.isVideoPost() == true
                    ? StoryItem.pageImage(
                        key: Key(media.id.toString()),
                        url: media.story.video!,
                        controller: controller,
                      )
                    : StoryItem.pageImage(
                        key: Key(media.id.toString()),
                        url: media.story.image!,
                        controller: controller,
                      ),
            ],
            controller: controller,
            // pass controller here too
            repeat: true,
            // should the stories be slid forever
            onStoryShow: (s) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                highlightController.setCurrentStoryMedia(widget.highlight.medias
                    .where(
                        (element) => Key(element.id.toString()) == s.view.key)
                    .first);
              });
            },
            onComplete: () {
              Get.back();
            },
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Get.back();
              }
            }),
        Positioned(top: 70, left: 20, right: 0, child: userProfileView()),
      ],
    );
  }

  Widget userProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Obx(() => AvatarView(
                  url: highlightController
                      .storyMediaModel.value!.story.user!.picture,
                  size: 30,
                )).rP8,
            SizedBox(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyMediumText(
                        highlightController
                            .storyMediaModel.value!.story.user!.userName,
                        weight: TextWeight.medium,
                      ),
                      BodyMediumText(
                        highlightController.storyMediaModel.value!.createdAt,
                        weight: TextWeight.medium,
                        color: AppColorConstants.grayscale600,
                      )
                    ],
                  )),
            )
          ],
        ),
        // const Spacer(),
        SizedBox(
          height: 25,
          width: 40,
          child: ThemeIconWidget(
            ThemeIcon.more,
            color: AppColorConstants.iconColor,
            size: 20,
          ).ripple(() {
            openActionPopup();
          }),
        )
      ],
    );
  }

  void openActionPopup() {
    controller.pause();

    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                ListTile(
                    title: Center(child: Text(deleteFromHighlightString.tr)),
                    onTap: () async {
                      Get.back();
                      controller.play();

                      highlightController.deleteStoryFromHighlight();
                    }),
                divider(),
                ListTile(
                    title: Center(child: Text(cancelString.tr)),
                    onTap: () {
                      controller.play();
                      Get.back();
                    }),
              ],
            )).then((value) {
      controller.play();
    });
  }
}
