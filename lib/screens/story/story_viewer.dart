import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:get/get.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:story_view/utils.dart';

import '../../universal_components/rounded_input_field.dart';
import '../profile/my_profile.dart';
import '../profile/other_user_profile.dart';
import '../settings_menu/settings_controller.dart';

class StoryViewer extends StatefulWidget {
  final StoryModel story;
  final VoidCallback storyDeleted;

  const StoryViewer({Key? key, required this.story, required this.storyDeleted})
      : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  final controller = StoryController();
  final AppStoryController storyController = AppStoryController();
  final SettingsController settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

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
              for (StoryMediaModel media in widget.story.media.reversed)
                media.isVideoPost() == true
                    ? StoryItem.pageVideo(
                        media.video!,
                        controller: controller,
                        duration: Duration(
                            seconds: int.parse(settingsController
                                .setting.value!.maximumVideoDurationAllowed!)),
                        key: Key(media.id.toString()),
                      )
                    : StoryItem.pageImage(
                        key: Key(media.id.toString()),
                        url: media.image!,
                        controller: controller,
                      ),
            ],
            controller: controller,
            // pass controller here too
            repeat: true,
            // should the stories be slid forever
            onStoryShow: (s) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                storyController.setCurrentStoryMedia(widget.story.media
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
            } // To disable vertical swipe gestures, ignore this parameter.
            // Preferrably for inline story view.
            ),
        Positioned(top: 70, left: 20, right: 0, child: userProfileView()),
        // Positioned(bottom: 0, left: 0, right: 0, child: replyView()),
      ],
    );
  }

  Widget replyWidget() {
    return FooterLayout(
      footer: KeyboardAttachable(
        // backgroundColor: Colors.blue,
        child: Container(
          height: 60,
          color: AppColorConstants.themeColor,
          child: Row(
            children: [
              Expanded(
                child: InputField(
                  hintText: LocalizationString.reply,
                ),
              ),
              ThemeIconWidget(
                ThemeIcon.send,
                color: AppColorConstants.iconColor,
              )
            ],
          ).hP25,
        ),
      ),
      child: storyWidget(),
    );
  }

  Widget userProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            AvatarView(
              url: widget.story.image,
              size: 30,
            ).rP8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BodyMediumText(
                  widget.story.userName,
    weight: TextWeight.medium,
    color: Colors.white

                ),
                Obx(() => storyController.storyMediaModel.value != null
                    ? BodyMediumText(
                        storyController.storyMediaModel.value!.createdAt,
                        color: AppColorConstants.grayscale100,

                      )
                    : Container())
              ],
            ),
          ],
        ),
        if (widget.story.media.first.userId ==
            _userProfileManager.user.value!.id)
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
    ).ripple(() {
      int userId = widget.story.media.first.userId;
      if (userId == _userProfileManager.user.value!.id) {
        Get.to(() => const MyProfile(showBack: true));
      } else {
        Get.to(() => OtherUserProfile(
              userId: userId,
            ));
      }
    });
  }

  void openActionPopup() {
    controller.pause();

    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                ListTile(
                    title: Center(child: BodyLargeText(LocalizationString.deleteStory)),
                    onTap: () async {
                      Get.back();
                      controller.play();

                      storyController.deleteStory(() {
                        widget.storyDeleted();
                      });
                    }),
                divider(context: context),
                ListTile(
                    title: Center(child: BodyLargeText(LocalizationString.cancel)),
                    onTap: () {
                      controller.play();
                      Get.back();
                    }),
              ],
            )).then((value) {
      controller.play();
    });
  }

// Widget replyView() {
//   return Column(
//     children: [
//       Text(
//         widget.story.title,
//         style: TextStyle(fontSize: FontSizes.b2).bold,
//         textAlign: TextAlign.center,
//       ).hP16,
//       divider(height: 0.5, color: AppTheme.dividerColor).tP16,
//     ],
//   );
// }
}
