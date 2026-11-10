import 'dart:io';
import 'package:flutter/services.dart';
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

  Widget _statusCard(
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required String dateLabel,
      required String date}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: DesignConstants.horizontalPadding),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 38),
          ),
          const SizedBox(height: 16),
          Heading4Text(title, weight: TextWeight.bold),
          const SizedBox(height: 8),
          BodyMediumText(subtitle,
              textAlign: TextAlign.center,
              color: AppColorConstants.subHeadingTextColor),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: BodySmallText('$dateLabel  $date',
                color: color, weight: TextWeight.semiBold),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      );

  Widget alreadyVerifiedView() {
    return _statusCard(
        icon: Icons.verified_rounded,
        color: AppColorConstants.green,
        title: verifiedString.tr,
        subtitle: youAreVerifiedNowString.tr,
        dateLabel: profileIsVerifiedOnString.tr,
        date: _requestVerificationController.verifiedOn);
  }

  Widget verificationPendingView() {
    return _statusCard(
        icon: Icons.hourglass_top_rounded,
        color: AppColorConstants.themeColor,
        title: verificationInUnderProcess.tr,
        subtitle: 'We are reviewing your documents. You will be notified once it is done.',
        dateLabel: requestSentOn.tr,
        date: _requestVerificationController.requestSentOn);
  }

  Widget _section(
      {required IconData icon,
      required String title,
      String? subtitle,
      required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                    color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon,
                    size: 18, color: AppColorConstants.themeColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: BodyLargeText(title, weight: TextWeight.semiBold)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            BodySmallText(subtitle,
                color: AppColorConstants.subHeadingTextColor),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, {IconData? icon}) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: 1));
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: AppColorConstants.subHeadingTextColor, fontSize: 14),
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 20, color: AppColorConstants.subHeadingTextColor),
      filled: true,
      fillColor: AppColorConstants.backgroundColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder:
          b(AppColorConstants.dividerColor.withValues(alpha: 0.6)),
      focusedBorder: b(AppColorConstants.themeColor),
      border: b(AppColorConstants.dividerColor),
    );
  }

  Widget requestVerification() {
    final c = _requestVerificationController;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorConstants.themeColor,
                  AppColorConstants.themeColor.withValues(alpha: 0.72)
                ],
              ),
              boxShadow: [
                BoxShadow(
                    color: AppColorConstants.themeColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.verified_user_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Heading5Text(applyVerificationString.tr,
                          color: Colors.white, weight: TextWeight.bold),
                      const SizedBox(height: 4),
                      BodySmallText(verifiedAccountSubtitleString.tr,
                          color: Colors.white.withValues(alpha: 0.9)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 1. document type
          _section(
            icon: Icons.badge_outlined,
            title: documentTypeString.tr,
            child: Obx(() => AppDropdownField(
                  value: c.documentType.value.text,
                  options: [
                    nidString.tr,
                    passportString.tr,
                    drivingLicenseString.tr,
                    birthCertificateString.tr,
                    otherString.tr
                  ],
                  onChanged: (String value) {
                    c.setSelectedDocumentType(value);
                  },
                )),
          ),

          // 2. number
          Obx(() {
            final isNid = c.documentType.value.text == nidString.tr;
            final label = isNid
                ? 'NID number'
                : '${c.documentType.value.text} number';
            return _section(
              icon: Icons.pin_outlined,
              title: label,
              subtitle: isNid
                  ? 'Enter the number exactly as printed on your card (10, 13 or 17 digits).'
                  : 'Enter the number exactly as printed on your document.',
              child: Obx(() => TextField(
                    controller: c.documentNumber.value,
                    keyboardType:
                        isNid ? TextInputType.number : TextInputType.text,
                    inputFormatters: isNid
                        ? [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(17)
                          ]
                        : [LengthLimitingTextInputFormatter(30)],
                    style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                        color: AppColorConstants.mainTextColor),
                    decoration: _fieldDecoration(
                        isNid ? 'e.g. 1234567890' : 'Document number',
                        icon: Icons.numbers_rounded),
                  )),
            );
          }),

          // 3. photos
          _section(
            icon: Icons.photo_camera_outlined,
            title: uploadFrontAndBackString.tr,
            subtitle: 'Clear, uncropped photos. The name must match your profile.',
            child: Obx(() => Row(
                  children: [
                    for (int i = 0; i < 2; i++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i == 0 ? 10 : 0),
                          child: _imageSlot(i),
                        ),
                      ),
                  ],
                )),
          ),

          // 4. message
          _section(
            icon: Icons.chat_bubble_outline_rounded,
            title: messageToReviewerString.tr,
            child: TextField(
              controller: c.messageTf.value,
              maxLines: 4,
              style: TextStyle(
                  fontSize: 15, color: AppColorConstants.mainTextColor),
              decoration: _fieldDecoration('Optional'),
            ),
          ),

          const SizedBox(height: 4),
          GestureDetector(
            onTap: submitRequest,
            child: Container(
              height: 52,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: [
                  AppColorConstants.themeColor,
                  AppColorConstants.themeColor.withValues(alpha: 0.78)
                ]),
                boxShadow: [
                  BoxShadow(
                      color:
                          AppColorConstants.themeColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5))
                ],
              ),
              child: BodyLargeText(submitString.tr,
                  color: Colors.white, weight: TextWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageSlot(int index) {
    final images = _requestVerificationController.selectedImages;
    final has = index < images.length;
    final label = index == 0 ? 'Front' : 'Back';
    return AspectRatio(
      aspectRatio: 1.5,
      child: GestureDetector(
        onTap: has ? null : chooseImage,
        child: Container(
          decoration: BoxDecoration(
            color: AppColorConstants.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColorConstants.themeColor.withValues(alpha: 0.4),
                width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: has
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(images[index], fit: BoxFit.cover),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: GestureDetector(
                        onTap: () => _requestVerificationController
                            .deleteDocument(images[index]),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: AppColorConstants.themeColor, size: 28),
                    const SizedBox(height: 4),
                    BodySmallText(label,
                        color: AppColorConstants.themeColor,
                        weight: TextWeight.semiBold),
                  ],
                ),
        ),
      ),
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
