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

  Widget _card(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(IconData icon, String label, Widget value, VoidCallback onTap,
      {bool last = false}) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 36,
              width: 36,
              color: AppColorConstants.themeColor.withValues(alpha: 0.12),
              child: Icon(icon, size: 18, color: AppColorConstants.themeColor),
            ).round(11),
            const SizedBox(width: 12),
            Expanded(
              child: BodyLargeText(label, weight: TextWeight.semiBold),
            ),
            Flexible(child: value),
            const SizedBox(width: 8),
            ThemeIconWidget(
              ThemeIcon.nextArrow,
              color: AppColorConstants.subHeadingTextColor,
              size: 13,
            )
          ],
        ).setPadding(left: 14, right: 14, top: 14, bottom: 14).ripple(onTap),
        if (!last)
          Divider(
              height: 1,
              indent: 62,
              color: AppColorConstants.dividerColor.withValues(alpha: 0.6)),
      ],
    );
  }

  Widget _val(String text) {
    return BodyMediumText(text,
        maxLines: 1,
        textAlign: TextAlign.end,
        color: AppColorConstants.subHeadingTextColor);
  }

  Widget _sectionTitle(String t) {
    return BodySmallText(t.toUpperCase(),
            color: AppColorConstants.subHeadingTextColor,
            weight: TextWeight.bold)
        .setPadding(left: 6, bottom: 8, top: 22);
  }

  void _go(Widget page) {
    Get.to(() => page)!.then((value) {
      reloadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: editProfileString.tr),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addProfileView(),
                  _sectionTitle(accountString.tr),
                  Obx(() => _card([
                        _row(
                            Icons.alternate_email_rounded,
                            userNameString.tr,
                            _val(profileController.user.value?.userName ?? ''),
                            () => _go(const ChangeUserName())),
                        _row(
                            Icons.category_outlined,
                            categoryString.tr,
                            _val(profileController
                                    .user.value?.profileCategoryTypeName ??
                                ''),
                            () => _go(const SetProfileCategoryType(
                                  isFromSignup: false,
                                ))),
                        if (profileController.user.value?.accountCreatedWith ==
                            1)
                          _row(Icons.lock_outline_rounded, passwordString.tr,
                              _val('********'), () {
                            Get.to(() => const ChangePassword());
                          }),
                        _row(
                            Icons.phone_outlined,
                            phoneNumberString.tr,
                            _val(profileController.user.value?.phone ?? ''),
                            () => _go(const ChangePhoneNumber())),
                        _row(
                            Icons.account_balance_wallet_outlined,
                            paymentDetailString.tr,
                            _val(profileController.user.value?.paypalId ?? ''),
                            () => _go(const ChangePaypalId()),
                            last: true),
                      ])),
                  _sectionTitle(personalDetailsString.tr),
                  Obx(() => _card([
                        _row(
                            Icons.person_outline_rounded,
                            nameString.tr,
                            _val(profileController.user.value?.name ?? ''),
                            () => _go(const AddName(isSettingProfile: false))),
                        _row(
                            Icons.place_outlined,
                            locationString.tr,
                            _val(
                                '${profileController.user.value?.country ?? ''} ${profileController.user.value?.city ?? ''}'),
                            () => _go(const ChangeLocation())),
                        _row(
                            Icons.cake_outlined,
                            dateOfBirthString.tr,
                            _val(profileController.user.value?.dob ?? ''),
                            () => _go(
                                const SetDateOfBirth(isSettingProfile: false))),
                        _row(
                            Icons.wc_rounded,
                            genderString.tr,
                            _val(profileController.user.value?.genderType ==
                                    GenderType.male
                                ? maleString.tr
                                : profileController.user.value?.genderType ==
                                        GenderType.female
                                    ? femaleString.tr
                                    : otherString.tr),
                            () => _go(
                                const SetYourGender(isSettingProfile: false)),
                            last: true),
                      ])),
                  _sectionTitle(moreString.tr),
                  _card([
                    _row(
                        Icons.badge_outlined,
                        personalDetailsString.tr,
                        const SizedBox(),
                        () => _go(
                            const AddPersonalInfo(isSettingProfile: false))),
                    _row(
                        Icons.favorite_border_rounded,
                        interestsString.tr,
                        const SizedBox(),
                        () => _go(
                            const AddInterests(isSettingProfile: false))),
                    _row(
                        Icons.work_outline_rounded,
                        professionalDetailString.tr,
                        const SizedBox(),
                        () => _go(const AddProfessionalDetails(
                            isSettingProfile: false)),
                        last: true),
                  ]),
                  const SizedBox(height: 40),
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
          final user = profileController.user.value;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorConstants.themeColor,
                    AppColorConstants.themeColor.withValues(alpha: 0.72)
                  ]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: user == null
                ? const SizedBox(height: 120)
                : Column(children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: UserAvatarView(
                              user: user, size: 85, onTapHandler: () {}),
                        ),
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: AppColorConstants.cardColor,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2)),
                          child: Icon(Icons.camera_alt_rounded,
                              size: 15, color: AppColorConstants.themeColor),
                        ),
                      ],
                    ).ripple(() {
                      openImagePickingPopup();
                    }),
                    const SizedBox(height: 10),
                    BodySmallText(
                      editProfilePictureString.tr,
                      color: Colors.white70,
                    ).vP4.ripple(() {
                      openImagePickingPopup();
                    }),
                    Heading5Text(
                      user.userName,
                      color: Colors.white,
                      weight: TextWeight.bold,
                    ).setPadding(bottom: 2),
                    if (user.email != null)
                      BodyMediumText('${user.email}',
                          color: Colors.white, weight: TextWeight.regular),
                    if (user.country != null)
                      BodyMediumText('${user.country ?? ''}, ${user.city ?? ''}',
                              color: Colors.white70, weight: TextWeight.regular)
                          .vP4,
                  ]),
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
