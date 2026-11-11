import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/profile/set_profile_category_controller.dart';
import '../../../model/category_model.dart';
import 'find_random_user.dart';

class ChooseProfileCategory extends StatefulWidget {
  final bool isCalling;

  const ChooseProfileCategory({super.key, required this.isCalling})
      ;

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
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          backNavigationBar(
               title: strangerChatString.tr),
          const SizedBox(
            height: 20,
          ),
          Heading4Text(setProfileCategoryTypeString.tr,
              weight: TextWeight.bold),
          const SizedBox(
            height: 20,
          ),
          BodySmallText(weWillSearchUserInCategoryString.tr,
              textAlign: TextAlign.center,
              color: AppColorConstants.subHeadingTextColor,
              weight: TextWeight.medium,
             ).hp(DesignConstants.horizontalPadding),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: Obx(() => ListView.separated(
                  padding:  EdgeInsets.only(
                      top: 20, bottom: 100, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
                  itemCount: _setProfileCategoryController.categories.length,
                  itemBuilder: (ctx, index) {
                    CategoryModel category =
                        _setProfileCategoryController.categories[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColorConstants.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AppColorConstants.dividerColor
                                .withValues(alpha: 0.5),
                            width: 0.6),
                        boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BodyLargeText(
                            category.name,
                            weight: TextWeight.semiBold,
                          ),
                          ThemeIconWidget(ThemeIcon.nextArrow,
                              size: 14, color: AppColorConstants.themeColor)
                        ],
                      ),
                    ).ripple(() {
                      Get.to(() => FindRandomUser(
                            isCalling: widget.isCalling,
                            profileCategoryType: category.id,
                          ));
                    });
                  },
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(height: 12);
                  }))),
          AppThemeButton(
              text: skipString.tr,
              onPress: () {
                Get.to(() => FindRandomUser(isCalling: widget.isCalling));
              }).hp(DesignConstants.horizontalPadding),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
