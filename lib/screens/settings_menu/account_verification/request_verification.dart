import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:image_picker/image_picker.dart';
import '../../../components/actionSheets/action_sheet1.dart';
import '../../../controllers/request_verification_controller.dart';
import '../../../model/generic_item.dart';
import '../../../universal_components/rounded_input_field.dart';

class RequestVerification extends StatefulWidget {
  const RequestVerification({Key? key}) : super(key: key);

  @override
  State<RequestVerification> createState() => _RequestVerificationState();
}

class _RequestVerificationState extends State<RequestVerification> {
  final RequestVerificationController _requestVerificationController =
      RequestVerificationController();
  final UserProfileManager _userProfileManager = Get.find();

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SizedBox(
        height: Get.height,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            backNavigationBarWithIcon(
                context: context,
                title: LocalizationString.requestVerification,
                icon: ThemeIcon.book,
                iconBtnClicked: () {
                  if (_requestVerificationController
                      .verificationRequests.isNotEmpty) {
                    Get.to(() => RequestVerificationList(
                        requests: _requestVerificationController
                            .verificationRequests));
                  }
                }),

            divider(context: context).tP8,
            const SizedBox(
              height: 20,
            ),
            _userProfileManager.user.value!.isVerified
                ? alreadyVerifiedView()
                : requestVerification(),
          ],
        ),
      ),
    );
  }

  Widget alreadyVerifiedView() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Heading4Text(LocalizationString.verified.toUpperCase(),
                  weight: TextWeight.bold),
              const SizedBox(
                width: 5,
              ),
              Image.asset(
                'assets/verified.png',
                height: 30,
                width: 30,
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            LocalizationString.youAreVerifiedNow,
            style: TextStyle(fontSize: FontSizes.b2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BodyMediumText(
                LocalizationString.profileIsVerifiedOn,
                textAlign: TextAlign.center,
              ),
              BodyMediumText(
                _requestVerificationController.verifiedOn,
                weight: TextWeight.bold,
                color: AppColorConstants.themeColor,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(
            height: 300,
          ),
        ],
      ),
    );
  }

  Widget requestVerification() {
    return Stack(
      fit: StackFit.loose,
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Heading3Text(
                LocalizationString.applyVerification,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 10,
              ),
              BodyLargeText(
                LocalizationString.verifiedAccountSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyLargeText(LocalizationString.messageToReviewer,
                          weight: TextWeight.semiBold),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() => InputField(
                            controller:
                                _requestVerificationController.messageTf.value,
                            backgroundColor: AppColorConstants.cardColor,
                            cornerRadius: 10,
                            maxLines: 5,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  BodyLargeText(LocalizationString.documentType,
                      weight: TextWeight.semiBold),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => DropDownField(
                        controller:
                            _requestVerificationController.documentType.value,
                        backgroundColor: AppColorConstants.cardColor,
                        onTap: () {
                          chooseDocumentType();
                        },
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: Get.width - 32,
                    height: 40,
                    child: AppThemeButton(
                        text: LocalizationString.chooseImage,
                        onPress: () {
                          chooseImage();
                        }),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BodySmallText(LocalizationString.uploadFrontAndBack,
                      weight: TextWeight.medium),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ).hP16,
              SizedBox(
                height: 80,
                child: Obx(() => ListView.separated(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          _requestVerificationController.selectedImages.length,
                      itemBuilder: (ctx, index) {
                        return SizedBox(
                          height: 80,
                          width: 80,
                          child: Stack(
                            children: [
                              Image.file(
                                _requestVerificationController
                                    .selectedImages[index],
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ).overlay(Colors.black38),
                              Positioned(
                                  right: 5,
                                  top: 5,
                                  child: Container(
                                    color: AppColorConstants.themeColor,
                                    child:
                                        const ThemeIconWidget(ThemeIcon.delete)
                                            .p4,
                                  ).circular.ripple(() {
                                    _requestVerificationController
                                        .deleteDocument(
                                            _requestVerificationController
                                                .selectedImages[index]);
                                  }))
                            ],
                          ).round(10),
                        );
                      },
                      separatorBuilder: (ctx, index) {
                        return const SizedBox(
                          width: 20,
                        );
                      },
                    )),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
        Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SizedBox(
              width: Get.width - 32,
              height: 40,
              child: AppThemeButton(
                  text: LocalizationString.submit,
                  onPress: () {
                    submitRequest();
                  }),
            ))
      ],
    );
  }

  submitRequest() {
    _requestVerificationController.submitRequest(context);
  }

  chooseImage() {
    if (_requestVerificationController.selectedImages.length == 2) {
      AppUtil.showToast(
          message: LocalizationString.youCanUploadMaximumTwoImages,
          isSuccess: false);
      return;
    }
    picker.pickImage(source: ImageSource.gallery).then((pickedFile) {
      if (pickedFile != null) {
        _requestVerificationController.addDocument(File(pickedFile.path));
      } else {}
    });
  }

  chooseDocumentType() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ActionSheet1(
              items: [
                GenericItem(
                  id: '1',
                  title: LocalizationString.drivingLicense,
                  subTitle: '',
                  // isSelected: selectedItem?.id == '1',
                ),
                GenericItem(
                  id: '2',
                  title: LocalizationString.passport,
                  subTitle: '',
                  // isSelected: selectedItem?.id == '1',
                ),
                GenericItem(
                  id: '3',
                  title: LocalizationString.panCard,
                  subTitle: '',
                  // isSelected: selectedItem?.id == '1',
                ),
                GenericItem(
                  id: '4',
                  title: LocalizationString.other,
                  subTitle: '',
                  // isSelected: selectedItem?.id == '1',
                ),
              ],
              itemCallBack: (item) {
                if (item.id == '1') {
                  _requestVerificationController.setSelectedDocumentType(
                      LocalizationString.drivingLicense);
                } else if (item.id == '2') {
                  _requestVerificationController
                      .setSelectedDocumentType(LocalizationString.passport);
                } else if (item.id == '3') {
                  _requestVerificationController
                      .setSelectedDocumentType(LocalizationString.panCard);
                } else if (item.id == '4') {
                  _requestVerificationController
                      .setSelectedDocumentType(LocalizationString.other);
                }
              },
            ));
  }
}
