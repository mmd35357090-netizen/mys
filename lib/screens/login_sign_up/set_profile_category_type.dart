import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../controllers/profile/set_profile_category_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../model/category_model.dart';

class SetProfileCategoryType extends StatefulWidget {
  final bool isFromSignup;

  const SetProfileCategoryType({Key? key, required this.isFromSignup})
      : super(key: key);

  @override
  State<SetProfileCategoryType> createState() => _SetProfileCategoryTypeState();
}

class _SetProfileCategoryTypeState extends State<SetProfileCategoryType> {
  final SetProfileCategoryController _setProfileCategoryController =
      SetProfileCategoryController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setProfileCategoryController.getProfileTypeCategories();
      _setProfileCategoryController.setProfileCategoryType(
          _userProfileManager.user.value!.profileCategoryTypeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isFromSignup == true)
            const SizedBox(
              height: 70,
            ),
          if (widget.isFromSignup == false)
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                backNavigationBar(
                    context: context,
                    title: LocalizationString.setProfileCategoryType)
              ],
            ),
          if (widget.isFromSignup == true)
            Heading3Text(
              LocalizationString.setProfileCategoryType,
            ),
          const SizedBox(
            height: 20,
          ),
          BodySmallText(
            LocalizationString.setProfileCategoryTypeSubHeading,
            textAlign: TextAlign.center,
            weight: TextWeight.medium,
          ).hP16,
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: Obx(() => ListView.separated(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 100, left: 16, right: 16),
                  itemCount: _setProfileCategoryController.categories.length,
                  itemBuilder: (ctx, index) {
                    CategoryModel category =
                        _setProfileCategoryController.categories[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(category.name,
                            style: TextStyle(
                                fontSize: FontSizes.b2,
                                color: AppColorConstants.grayscale900,
                                fontWeight: TextWeight.semiBold)),
                        Obx(() => ThemeIconWidget(
                              _setProfileCategoryController
                                          .profileCategoryType.value ==
                                      category.id
                                  ? ThemeIcon.checkMarkWithCircle
                                  : ThemeIcon.circleOutline,
                              color: _setProfileCategoryController
                                          .profileCategoryType.value ==
                                      category.id
                                  ? AppColorConstants.themeColor
                                  : AppColorConstants.iconColor,
                            )),
                      ],
                    ).ripple(() {
                      _setProfileCategoryController
                          .setProfileCategoryType(category.id);
                    });
                  },
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(height: 20);
                  }))),
          AppThemeButton(
              text: LocalizationString.submit,
              onPress: () {
                profileController.updateProfileCategoryType(
                    profileCategoryType:
                        _setProfileCategoryController.profileCategoryType.value,
                    isSigningUp: true,
                    context: context);
              }).hP16,
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
