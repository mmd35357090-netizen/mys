import 'package:foap/helper/imports/common_import.dart';
import '../../../../controllers/post/promotion_controller.dart';
import '../../../../model/audience_model.dart';
import 'audience_interests.dart';
import 'audience_location.dart';
import 'audience_preference.dart';

class CreateAudienceScreen extends StatelessWidget {
  final AudienceModel? audience;

  CreateAudienceScreen({super.key, this.audience});
  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GetBuilder<PromotionController>(
          init: _promotionController,
          builder: (ctx) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                customNavigationBar(
                    title:
                        audience != null ? editAudience.tr : createAudience.tr,
                    action: () {
                      _promotionController.clearAudience();
                      Get.back();
                    }),
                // const EstimatedAudienceTile(),
                const SizedBox(
                  height: 40,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppTextField(
                        controller: _promotionController.audienceName,
                        hintText: audienceName.tr,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      addNextOptionTile(locationsString.tr,
                              _promotionController.selectedLocationNames.value)
                          .ripple(() {
                        Get.to(() => AudienceLocationScreen());
                      }),
                      divider(height: 1, color: AppColorConstants.dividerColor),
                      addNextOptionTile(interestsString.tr,
                              _promotionController.selectedNames.value)
                          .ripple(() {
                        _promotionController.getInterests();
                        Get.to(() => AudienceInterestsScreen());
                      }),
                      divider(height: 1, color: AppColorConstants.dividerColor),
                      addNextOptionTile(ageGender.tr,
                              _promotionController.getAgeAndGender())
                          .ripple(() {
                        Get.to(() => AudiencePreferenceScreen());
                      }),
                      divider(height: 1, color: AppColorConstants.dividerColor),
                    ]).hp(DesignConstants.horizontalPadding),
                const SizedBox(
                  height: 50,
                ),

                AppThemeButton(
                    text: doneString.tr,
                    onPress: () {
                      _promotionController.createAudienceApi(audience, () {
                        _promotionController.clearAudience();
                        Get.back();
                      });
                    }).hp(DesignConstants.horizontalPadding),
              ],
            );
          }),
    );
  }

  Widget addNextOptionTile(String title, String subTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Heading6Text(
              title,
              weight: FontWeight.normal,
              color: AppColorConstants.subHeadingTextColor,
            ),
            subTitle == ''
                ? const SizedBox()
                : BodyMediumText(
                    subTitle,
                    weight: FontWeight.normal,
                    color: AppColorConstants.subHeadingTextColor,
                  ).tP4
          ],
        )),
        ThemeIconWidget(ThemeIcon.nextArrow,
                size: 25, color: AppColorConstants.mainTextColor)
            .lP4,
      ],
    ).vP16;
  }
}
