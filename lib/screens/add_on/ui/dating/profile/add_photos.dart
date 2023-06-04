import 'package:foap/screens/add_on/ui/dating/profile/set_date_of_birth.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPhotos extends StatefulWidget {
  final bool isSettingProfile;

  const AddPhotos({Key? key, required this.isSettingProfile}) : super(key: key);

  @override
  State<AddPhotos> createState() => _AddPhotosState();
}

class _AddPhotosState extends State<AddPhotos> {
  final picker = ImagePicker();
  List<XFile> images = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Heading3Text(
              addPhotosString.tr,
            ).setPadding(top: 100),
            Heading5Text(
              profileWithGoodPhotosString.tr,
            ).setPadding(top: 20),
            GridView.builder(
                itemCount: 6,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                // You won't see infinite size error
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 20.0,
                    mainAxisExtent: 100),
                itemBuilder: (ctx, index) {
                  return addImagePickingView(index);
                }).setPadding(top: 50),
            Center(
              child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  child: AppThemeButton(
                      cornerRadius: 25,
                      text: nextString.tr,
                      onPress: () {
                        Get.to(() =>
                            SetDateOfBirth(isSettingProfile: widget.isSettingProfile));
                      })),
            ).setPadding(top: 110),
          ],
        ).hP25,
      ),
    );
  }

  addImagePickingView(int index) {
    return Container(
      height: 100,
      width: 100,
      color: Colors.white,
      child: images.asMap().containsKey(index)
          ? Image.file(File(images[index].path), fit: BoxFit.cover)
          : const Icon(
              Icons.add,
              size: 25,
            ),
    ).round(10).ripple(() {
      images.asMap().containsKey(index)
          ? openImageRemovePopup(index)
          : openImagePickingPopup();
    });
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
                        color: AppColorConstants.iconColor),
                    title: Text(takePhotoString.tr),
                    onTap: () {
                      Get.back();
                      picker
                          .pickImage(source: ImageSource.camera)
                          .then((pickedFile) {
                        if (pickedFile != null) {
                          setState(() {
                            images.add(pickedFile);
                          });
                        }
                      });
                    }),
                divider(),
                ListTile(
                    leading: Icon(Icons.wallpaper_outlined,
                        color: AppColorConstants.iconColor),
                    title: Text(chooseFromGalleryString.tr),
                    onTap: () async {
                      Get.back();
                      picker
                          .pickImage(source: ImageSource.gallery)
                          .then((pickedFile) {
                        if (pickedFile != null) {
                          setState(() {
                            images.add(pickedFile);
                          });
                        }
                      });
                    }),
                divider(),
                ListTile(
                    leading: Icon(Icons.close,
                        color: AppColorConstants.iconColor),
                    title: Text(cancelString.tr),
                    onTap: () => Get.back()),
              ],
            ));
  }

  void openImageRemovePopup(int index) {
    showModalBottomSheet(
        context: context,

        builder: (context) => Wrap(
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 25),
                    child: Text(removePhotoString.tr,
                        style: Theme.of(context).textTheme.bodyLarge)),
                ListTile(
                    leading: ThemeIconWidget(ThemeIcon.delete,
                        color: AppColorConstants.iconColor),
                    title: Text(removeString.tr),
                    onTap: () {
                      Get.back();
                      setState(() {
                        images.removeAt(index);
                      });
                    }),
                divider(),
                ListTile(
                    leading: ThemeIconWidget(ThemeIcon.close,
                        color: AppColorConstants.iconColor),
                    title: BodyLargeText(cancelString.tr),
                    onTap: () => Get.back()),
              ],
            ));
  }
}
