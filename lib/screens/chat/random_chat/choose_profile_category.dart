import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../../controllers/profile/set_profile_category_controller.dart';
import '../../../model/category_model.dart';
import 'find_random_user.dart';

class ChooseProfileCategory extends StatefulWidget {
  final bool isCalling;

  const ChooseProfileCategory({Key? key, required this.isCalling})
      : super(key: key);

  @override
  State<ChooseProfileCategory> createState() => _ChooseProfileCategoryState();
}

class _ChooseProfileCategoryState extends State<ChooseProfileCategory> {
  final SetProfileCategoryController _setProfileCategoryController =
      SetProfileCategoryController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setProfileCategoryController.getProfileTypeCategories();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          backNavigationBar(
               title: strangerChatString.tr),
          const SizedBox(
            height: 20,
          ),
          Heading5Text(setProfileCategoryTypeString.tr,
              ),
          const SizedBox(
            height: 20,
          ),
          BodySmallText(weWillSearchUserInCategoryString.tr,
              textAlign: TextAlign.center,
              weight: TextWeight.medium,
             ),
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
                        BodyLargeText(
                          category.name,
                        ),
                        const ThemeIconWidget(ThemeIcon.nextArrow)
                      ],
                    ).ripple(() {
                      Get.to(() => FindRandomUser(
                            isCalling: widget.isCalling,
                            profileCategoryType: category.id,
                          ));
                    });
                  },
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(height: 20);
                  }))),
          AppThemeButton(
              text: skipString.tr,
              onPress: () {
                Get.to(() => FindRandomUser(isCalling: widget.isCalling));
              }).hP16,
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
