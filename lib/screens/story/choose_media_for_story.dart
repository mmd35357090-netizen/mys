import 'package:foap/helper/imports/story_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../components/custom_gallery_picker.dart';

class ChooseMediaForStory extends StatefulWidget {
  const ChooseMediaForStory({Key? key}) : super(key: key);

  @override
  State<ChooseMediaForStory> createState() => _ChooseMediaForStoryState();
}

class _ChooseMediaForStoryState extends State<ChooseMediaForStory> {
  final AppStoryController storyController = AppStoryController();

  @override
  void initState() {
    // storyController.loadGalleryData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 55,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ThemeIconWidget(
                ThemeIcon.close,
                color: AppColorConstants.iconColor,
                size: 27,
              ).ripple(() {
                Get.back();
              }),
              const Spacer(),
              // Image.asset(
              //   'assets/logo.png',
              //   width: 80,
              //   height: 25,
              // ),
              const Spacer(),
              Obx(() => Heading4Text(
                    postString.tr,
                    weight: storyController.mediaList.isNotEmpty
                        ? TextWeight.bold
                        : TextWeight.medium,
                  ).ripple(() {
                    if (storyController.mediaList.isNotEmpty) {
                      storyController.uploadAllMedia(
                           items: storyController.mediaList);
                    }
                    // Get.to(() => ChooseStoryViewers(
                    //       images: storyController.selectedItems,
                    //     ));
                  })),
            ],
          ).hp(20),
          const SizedBox(height: 20),
          Expanded(
              child: GetBuilder<AppStoryController>(
                  init: storyController,
                  builder: (ctx) {
                    return CustomGalleryPicker(
                        mediaSelectionCompletion: (medias) {
                      storyController.mediaSelected(medias);
                    }, mediaCapturedCompletion: (media) {
                      storyController
                          .uploadAllMedia( items: [media]);
                    });
                  }))
        ],
      ),
    );
  }
}
