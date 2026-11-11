import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/highlights_imports.dart';
import 'package:image_picker/image_picker.dart';

class CreateHighlight extends StatefulWidget {

  const CreateHighlight({super.key});

  @override
  State<CreateHighlight> createState() => _CreateHighlightState();
}

class _CreateHighlightState extends State<CreateHighlight> {
  TextEditingController nameText = TextEditingController();
  final HighlightsController highlightsController = Get.find();

  final picker = ImagePicker();

  @override
  void initState() {
    highlightsController.updateCoverImagePath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 55,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ThemeIconWidget(
                ThemeIcon.close,
                color: AppColorConstants.themeColor,
                size: 20,
              ).ripple(() {
                Get.back();
              }),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColorConstants.themeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BodyLargeText(createString.tr,
                    weight: TextWeight.bold, color: Colors.white),
              ).ripple(() {
                if (nameText.text.isNotEmpty) {
                  highlightsController
                      .createHighlights(name: nameText.text);
                } else {
                  AppUtil.showToast(
                      message: pleaseEnterTitleString.tr, isSuccess: false);
                }
              }),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          addProfileView(),
          BodyLargeText(chooseCoverImageString.tr,
                  weight: TextWeight.bold, color: AppColorConstants.themeColor)
              .ripple(() {
            openImagePickingPopup();
          }),
          const SizedBox(
            height: 25,
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColorConstants.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColorConstants.dividerColor.withValues(alpha: 0.7)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextField(
              controller: nameText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: FontSizes.b3,
                  color: AppColorConstants.mainTextColor),
              maxLines: 5,
              onChanged: (text) {},
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 10, right: 10),
                  counterText: "",
                  labelStyle: TextStyle(
                      fontSize: FontSizes.b2,
                      color: AppColorConstants.themeColor),
                  hintStyle: TextStyle(
                      fontSize: FontSizes.h5,
                      color: AppColorConstants.themeColor),
                  hintText: enterHighlightNameString.tr),
            ),
          )
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }

  addProfileView() {
    return SizedBox(
      height: 110,
      child: Obx(() => Column(children: [
            Container(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AppColorConstants.cardColor,
                child: highlightsController.pickedImage.value != null
                    ? Image.file(
                        highlightsController.pickedImage.value!,
                        fit: BoxFit.cover,
                        height: 72,
                        width: 72,
                      ).circular
                    : highlightsController.model == null ||
                            highlightsController.model?.picture == null
                        ? CachedNetworkImage(
                            imageUrl: highlightsController
                                .selectedStoriesMedia.first.image!,
                            fit: BoxFit.cover,
                            height: 72,
                            width: 72,
                          ).circular
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(36.0),
                            child: CachedNetworkImage(
                              imageUrl:
                                  highlightsController.model!.picture!,
                              fit: BoxFit.cover,
                              height: 72.0,
                              width: 72.0,
                              placeholder: (context, url) =>
                                  AppUtil.addProgressIndicator(size: 100),
                              errorWidget: (context, url, error) => Icon(
                                Icons.error,
                                color: AppColorConstants.iconColor,
                              ),
                            )),
              ).p4,
            )
                .borderWithRadius(
                    value: 3, radius: 50, color: AppColorConstants.themeColor)
                .ripple(() {
              openImagePickingPopup();
            })
          ]).p8),
    );
  }

  void openImagePickingPopup() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 25),
                    child: BodyLargeText(
                      addPhotoString.tr,
                    )),
                ListTile(
                    leading: Icon(Icons.camera_alt_outlined,
                        color: AppColorConstants.mainTextColor),
                    title: BodyLargeText(
                      takePhotoString.tr,
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        highlightsController
                            .updateCoverImage(File(pickedFile.path));
                      } else {}
                    }),
                divider(),
                ListTile(
                    leading: Icon(Icons.wallpaper_outlined,
                        color: AppColorConstants.mainTextColor),
                    title: BodyLargeText(
                      chooseFromGalleryString.tr,
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        highlightsController
                            .updateCoverImage(File(pickedFile.path));
                      } else {}
                    }),
                divider(),
                ListTile(
                    leading: Icon(Icons.close, color: AppColorConstants.mainTextColor),
                    title: BodyLargeText(cancelString.tr),
                    onTap: () => Get.back()),
              ],
            ));
  }
}
