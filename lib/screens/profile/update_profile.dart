import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/profile_imports.dart';
import 'package:foap/screens/add_on/ui/dating/profile/add_interests.dart';
import 'package:foap/screens/login_sign_up/set_profile_category_type.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  UpdateProfileState createState() => UpdateProfileState();
}

class UpdateProfileState extends State<UpdateProfile> {
  bool isLoading = true;
  final picker = ImagePicker();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    reloadData();
  }

  reloadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.setUser(_userProfileManager.user.value!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: ''),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addProfileView(),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      BodyLargeText(
                        userNameString.tr,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController.user.value!.userName,
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const ChangeUserName())!.then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(
                        categoryString.tr,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController
                                  .user.value!.profileCategoryTypeName,
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const SetProfileCategoryType(
                              isFromSignup: false,
                            ))!
                        .then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  if (profileController.user.value!.accountCreatedWith == 1)
                    Column(
                      children: [
                        Row(
                          children: [
                            BodyLargeText(
                              passwordString.tr,
                              weight: TextWeight.medium,
                            ),
                            const Spacer(),
                            const BodyMediumText(
                              '********',
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ThemeIconWidget(
                              ThemeIcon.edit,
                              color: AppColorConstants.iconColor,
                              size: 15,
                            )
                          ],
                        ).ripple(() {
                          Get.to(() => const ChangePassword());
                        }),
                        divider().vP16
                      ],
                    ),
                  Row(
                    children: [
                      BodyLargeText(
                        phoneNumberString.tr,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController.user.value!.phone ?? '',
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const ChangePhoneNumber())!.then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(paymentDetailString.tr,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController.user.value!.paypalId ?? '',
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const ChangePaypalId())!.then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(locationString.tr,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => BodyMediumText(
                            '${profileController.user.value?.country ?? ''} ${profileController.user.value?.city ?? ''}',
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const ChangeLocation())!.then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(nameString.tr, weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => BodyMediumText(
                            profileController.user.value?.name ?? '',
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const AddName(isSettingProfile: false))!
                        .then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(dateOfBirthString.tr,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => BodyMediumText(
                            profileController.user.value?.dob ?? '',
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const SetDateOfBirth(isSettingProfile: false))!
                        .then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(genderString.tr, weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => BodyMediumText(
                            profileController.user.value?.genderType ==
                                    GenderType.male
                                ? maleString.tr
                                : profileController.user.value?.genderType ==
                                        GenderType.female
                                    ? femaleString.tr
                                    : otherString.tr,
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const SetYourGender(isSettingProfile: false))!
                        .then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(personalDetailsString.tr,
                          weight: TextWeight.medium),
                      const Spacer(),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() =>
                            const AddPersonalInfo(isSettingProfile: false))!
                        .then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(interestsString.tr,
                          weight: TextWeight.medium),
                      const Spacer(),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const AddInterests(
                              isSettingProfile: false,
                            ))!
                        .then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(professionalDetailString.tr,
                          weight: TextWeight.medium),
                      const Spacer(),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      )
                    ],
                  ).ripple(() {
                    Get.to(() => const AddProfessionalDetails(
                            isSettingProfile: false))!
                        .then((value) {
                      reloadData();
                    });
                  }),
                  divider().vP16,
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
          ),
        ],
      ),
    );
  }

  addProfileView() {
    return GetBuilder<ProfileController>(
        init: profileController,
        builder: (ctx) {
          return SizedBox(
            height: 225,
            child: profileController.user.value != null
                ? SizedBox(
                    width: Get.width,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          UserAvatarView(
                                  user: profileController.user.value!,
                                  size: 85,
                                  onTapHandler: () {})
                              .ripple(() {
                            openImagePickingPopup();
                          }),
                          const SizedBox(
                            height: 10,
                          ),
                          BodySmallText(
                            editProfilePictureString.tr,
                          ).vP4.ripple(() {
                            openImagePickingPopup();
                          }),
                          Heading6Text(
                            profileController.user.value!.userName,
                            weight: TextWeight.bold,
                          ).setPadding(bottom: 4),
                          profileController.user.value?.email != null
                              ? BodyMediumText(
                                  '${profileController.user.value!.email}',
                                  color: AppColorConstants.mainTextColor,
                                  weight: TextWeight.regular,
                                )
                              : Container(),
                          profileController.user.value?.country != null
                              ? BodyMediumText(
                                  '${profileController.user.value?.country ?? ''},${profileController.user.value?.city ?? ''}',
                                  color: AppColorConstants.mainTextColor,
                                  weight: TextWeight.regular,
                                ).vP4
                              : Container(),
                        ]).p8,
                  )
                : Container(),
          );
        });
  }

  void openImagePickingPopup() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
              color: AppColorConstants.backgroundColor,
              child: Wrap(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 25),
                      child: Heading5Text(
                        addPhotoString.tr,
                        weight: TextWeight.bold,
                      )),
                  ListTile(
                      leading: Icon(Icons.camera_alt_outlined,
                          color: AppColorConstants.iconColor),
                      title: BodyLargeText(takePhotoString.tr),
                      onTap: () {
                        Get.back();
                        picker
                            .pickImage(source: ImageSource.camera)
                            .then((pickedFile) {
                          if (pickedFile != null) {
                            profileController
                                .editProfileImageAction(pickedFile);
                          } else {}
                        });
                      }),
                  divider(),
                  ListTile(
                      leading: Icon(Icons.wallpaper_outlined,
                          color: AppColorConstants.iconColor),
                      title: BodyLargeText(chooseFromGalleryString.tr),
                      onTap: () async {
                        Get.back();
                        picker
                            .pickImage(source: ImageSource.gallery)
                            .then((pickedFile) {
                          if (pickedFile != null) {
                            profileController
                                .editProfileImageAction(pickedFile);
                          } else {}
                        });
                      }),
                  divider(),
                  ListTile(
                      leading:
                          Icon(Icons.close, color: AppColorConstants.iconColor),
                      title: BodyLargeText(cancelString.tr),
                      onTap: () => Get.back()),
                ],
              ),
            ).topRounded(20));
  }
}
