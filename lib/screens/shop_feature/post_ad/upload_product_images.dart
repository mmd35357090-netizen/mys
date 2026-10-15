import 'package:foap/helper/imports/common_import.dart';
import 'package:image_picker/image_picker.dart';
import '../../../model/shop_model/ad_model.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import 'contact_detail.dart';

class UploadProductImages extends StatefulWidget {
  final AdModel? adModel;

  const UploadProductImages(this.adModel, {super.key}) ;

  @override
  State<UploadProductImages> createState() => _UploadProductImagesState();
}

class _UploadProductImagesState extends State<UploadProductImages> {
  final picker = ImagePicker();
  XFile? pickedImage;
  final ShopController shopController = Get.find();

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
          backNavigationBar(title: uploadPhotoString.tr),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [addImagesGridView()]),
                ).vP8,
                SizedBox(height: Get.height * 0.9),
                Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: AppThemeButton(
                      text: nextString.tr,
                      onPress: () {
                        // uploadAdImagesApi();
                        nextBtnClicked();
                      },
                    ))
              ],
            ).hP16,
          ),
        ],
      ),
    );
  }

  addImagesGridView() {
    final double itemWidth = (Get.width - 30) / 2;
    const double itemHeight = 160;

    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: itemWidth / itemHeight, //0.78,
        ),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: (widget.adModel!.images).length + 1,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
              onTap: () async {
                if (index == (widget.adModel!.images).length) {
                  openImagePickingPopup();
                } else {
                  // Get.to(() => EnlargeImageViewScreen(
                  //     (widget.adModel!.images ?? [])[index]));
                }
              },
              child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: index == (widget.adModel!.images).length
                          ? Center(
                              child: ThemeIconWidget(
                              ThemeIcon.plus,
                              size: 50,
                            ))
                          : Stack(
                              children: [
                                CachedNetworkImage(
                                    imageUrl: (widget.adModel!.images)[index],
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity),
                                Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      color: AppColorConstants.themeColor,
                                      child: ThemeIconWidget(
                                        ThemeIcon.delete,
                                        color: Colors.white,
                                      ).p8,
                                    ).round(10).ripple(() {
                                      widget.adModel!.images.removeAt(index);
                                      setState(() {});
                                    }))
                              ],
                            ))
                  .borderWithRadius(value: 1, radius: 10));
        });
  }

  void openImagePickingPopup() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              color: AppColorConstants.cardColor,
              child: Wrap(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 25),
                      child: BodyLargeText(
                        addPhotoString.tr,
                        color: AppColorConstants.mainTextColor,
                        weight: TextWeight.semiBold,
                      )),
                  ListTile(
                      leading: ThemeIconWidget(ThemeIcon.camera),
                      title: BodyLargeText(cameraString.tr),
                      onTap: () async {
                        Navigator.of(context).pop();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          uploadAdImagesApi();
                          setState(() {});
                        } else {
                        }
                      }),
                  ListTile(
                      leading: ThemeIconWidget(ThemeIcon.gallery),
                      title: BodyLargeText(galleryString.tr),
                      onTap: () async {
                        Navigator.of(context).pop();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);

                        if (pickedFile != null) {
                          pickedImage = pickedFile;
                          uploadAdImagesApi();
                        } else {
                        }
                      }),
                  ListTile(
                      leading: ThemeIconWidget(ThemeIcon.close),
                      title: BodyLargeText(cancelString.tr),
                      onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ));
  }

  nextBtnClicked() {
    if ((widget.adModel!.images).isEmpty) {
      AppUtil.showToast(message: pleaseUploadImageString.tr, isSuccess: false);
      return;
    }
    var imagesWithNames =
        widget.adModel?.images.map((e) => e.split('/').last).toList() ?? [];
    widget.adModel?.images = imagesWithNames;

    Get.to(() => ContactDetail(adModel: widget.adModel!));
  }

  void uploadAdImagesApi() {
    try {
      Loader.show();
      var futures = <Future>[];
      futures.add(shopController.uploadAdImage(
          pickedFile: pickedImage!,
          successCallback: (filePath) {
            setState(() {
              widget.adModel!.images.add(filePath);
            });
          }));
    } catch (error) {
      Loader.dismiss();
      AppUtil.showToast(message: errorMessageString.tr, isSuccess: false);
    }
  }
}
