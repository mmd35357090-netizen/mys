import 'dart:io';
import 'package:foap/controllers/misc/request_verification_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/settings_menu/creator_tools/account_verification/verification_request_list.dart';
import 'package:image_picker/image_picker.dart';

class RequestVerification extends StatefulWidget {
  const RequestVerification({super.key});

  @override
  State<RequestVerification> createState() => _RequestVerificationState();
}

class _RequestVerificationState extends State<RequestVerification> {
  final UserProfileManager _userProfileManager = Get.find();
  final RequestVerificationController _requestVerificationController =
      RequestVerificationController();
  final picker = ImagePicker();

  @override
  void initState() {
    _requestVerificationController.getVerificationRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Obx(() => Column(
                children: [
                  backNavigationBarWithTrailingWidget(
                    title: requestVerificationString.tr,
                    widget: ThemeIconWidget(ThemeIcon.bookMark).ripple(() {
                      if (_requestVerificationController
                          .verificationRequests.isNotEmpty) {
                        Get.to(() => const RequestVerificationList());
                      }
                    }),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // divider(context: context).tP8,
                          const SizedBox(
                            height: 20,
                          ),
                          _requestVerificationController.isApproved ||
                                  _userProfileManager
                                      .user.value!.isVerified
                              ? alreadyVerifiedView()
                              : _requestVerificationController
                                      .isVerificationInProcess
                                  ? verificationPendingView()
                                  : requestVerification(),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }

  Widget alreadyVerifiedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Heading4Text(verifiedString.tr.toUpperCase(),
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
          youAreVerifiedNowString.tr,
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
              profileIsVerifiedOnString.tr,
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
    );
  }

  Widget verificationPendingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Heading4Text(
          verificationInUnderProcess.tr,
          // style: TextStyle(fontSize: FontSizes.b2),
          // textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BodyMediumText(
              requestSentOn.tr,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              width: 5,
            ),
            BodyMediumText(
              _requestVerificationController.requestSentOn,
              weight: TextWeight.semiBold,
              color: AppColorConstants.themeColor,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(
          height: 300,
        ),
      ],
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
                applyVerificationString.tr,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 10,
              ),
              BodyLargeText(
                verifiedAccountSubtitleString.tr,
                textAlign: TextAlign.center,
              ).hP25,
              const SizedBox(
                height: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyLargeText(messageToReviewerString.tr,
                          weight: TextWeight.semiBold),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() => AppTextField(
                            controller: _requestVerificationController
                                .messageTf.value,
                            maxLines: 5,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  BodyLargeText(documentTypeString.tr,
                      weight: TextWeight.semiBold),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => AppDropdownField(
                        value: _requestVerificationController
                            .documentType.value.text,
                        options: [
                          drivingLicenseString.tr,
                          passportString.tr,
                          panCardString.tr,
                          otherString.tr
                        ],
                        onChanged: (String value) {
                          if (value == drivingLicenseString.tr) {
                            _requestVerificationController
                                .setSelectedDocumentType(
                                    drivingLicenseString.tr);
                          } else if (value == passportString.tr) {
                            _requestVerificationController
                                .setSelectedDocumentType(
                                    passportString.tr);
                          } else if (value == panCardString.tr) {
                            _requestVerificationController
                                .setSelectedDocumentType(panCardString.tr);
                          } else if (value == otherString.tr) {
                            _requestVerificationController
                                .setSelectedDocumentType(otherString.tr);
                          }
                        },
                        // controller:
                        // _requestVerificationController.documentType.value,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  AppThemeButton(
                      text: chooseImageString.tr,
                      onPress: () {
                        chooseImage();
                      }),
                  const SizedBox(
                    height: 15,
                  ),
                  BodySmallText(uploadFrontAndBackString.tr,
                      weight: TextWeight.medium),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 80,
                    child: Obx(() => ListView.separated(
                          padding: EdgeInsets.only(
                              left: DesignConstants.horizontalPadding,
                              right: DesignConstants.horizontalPadding),
                          scrollDirection: Axis.horizontal,
                          itemCount: _requestVerificationController
                              .selectedImages.length,
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
                                        color:
                                            AppColorConstants.themeColor,
                                        child: ThemeIconWidget(
                                                ThemeIcon.delete)
                                            .p4,
                                      ).circular.ripple(() {
                                        _requestVerificationController
                                            .deleteDocument(
                                                _requestVerificationController
                                                        .selectedImages[
                                                    index]);
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
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  AppThemeButton(
                      text: submitString.tr,
                      onPress: () {
                        submitRequest();
                      })
                ],
              ).hp(DesignConstants.horizontalPadding),
            ],
          ),
        ),
      ],
    );
  }

  submitRequest() {
    _requestVerificationController.submitRequest(context);
  }

  chooseImage() {
    if (_requestVerificationController.selectedImages.length == 2) {
      AppUtil.showToast(
          message: youCanUploadMaximumTwoImagesString.tr,
          isSuccess: false);
      return;
    }
    picker.pickImage(source: ImageSource.gallery).then((pickedFile) {
      if (pickedFile != null) {
        _requestVerificationController.addDocument(File(pickedFile.path));
      } else {}
    });
  }
}
