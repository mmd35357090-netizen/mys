import 'dart:io';
import 'package:foap/controllers/profile/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:image_picker/image_picker.dart';

import 'add_name.dart';

class UploadProfilePicture extends StatefulWidget {
  final bool isSettingProfile;

  const UploadProfilePicture({Key? key, required this.isSettingProfile})
      : super(key: key);

  @override
  State<UploadProfilePicture> createState() => _UploadProfilePictureState();
}

class _UploadProfilePictureState extends State<UploadProfilePicture> {
  final UserProfileManager _userProfileManager = Get.find();
  final ProfileController _profileController = Get.find();

  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: uploadPhotoString.tr,
          ),
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: Get.width,
                  color: AppColorConstants.cardColor,
                  child:
                      Obx(() => _userProfileManager.user.value?.picture != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  _userProfileManager.user.value!.picture!,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: Get.width,
                            )
                          : Container()),
                ),
                Container(
                  height: double.infinity,
                  width: Get.width,
                  color: Colors.black26,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ThemeIconWidget(
                        ThemeIcon.edit,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Heading4Text(
                        editProfilePictureString,
                        weight: TextWeight.bold,
                        color: Colors.white,
                      )
                    ],
                  ),
                )
              ],
            ).ripple(() {
              openImagePickingPopup();
            }),
          ),
          const Spacer(),
          SizedBox(
              height: 50,
              width: Get.width - 50,
              child: AppThemeButton(
                  cornerRadius: 25,
                  text: nextString.tr,
                  onPress: () {
                    submit();
                  })),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  void openImagePickingPopup() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => Container(
              color: AppColorConstants.cardColor,
              child: Wrap(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 25),
                      child: Heading4Text(
                        addPhotoString.tr,
                        weight: TextWeight.bold,
                      )),
                  ListTile(
                      leading: const ThemeIconWidget(ThemeIcon.camera),
                      title: BodyLargeText(takePhotoString.tr),
                      onTap: () {
                        Get.back();
                        picker
                            .pickImage(source: ImageSource.camera)
                            .then((pickedFile) {
                          if (pickedFile != null) {
                            _profileController.editProfileImageAction(
                                pickedFile, false);
                          } else {}
                        });
                      }),
                  divider(),
                  ListTile(
                      leading: const ThemeIconWidget(ThemeIcon.gallery),
                      title: BodyLargeText(chooseFromGalleryString.tr),
                      onTap: () async {
                        Get.back();
                        picker
                            .pickImage(source: ImageSource.gallery)
                            .then((pickedFile) {
                          if (pickedFile != null) {
                            _profileController.editProfileImageAction(
                                pickedFile, false);
                          } else {}
                        });
                      }),
                  divider(),
                  ListTile(
                      leading: const ThemeIconWidget(ThemeIcon.close),
                      title: BodyLargeText(cancelString.tr),
                      onTap: () => Get.back()),
                ],
              ).p8,
            ).topRounded(20));
  }

  submit() {
    if (_userProfileManager.user.value!.picture == null) {
      AppUtil.showToast(message: pleaseUploadImageString, isSuccess: false);
    } else {
      Get.to(() => AddName(isSettingProfile: widget.isSettingProfile));
    }
  }
}
