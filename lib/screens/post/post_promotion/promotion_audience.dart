import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/post/promotion_controller.dart';
import '../../../model/audience_model.dart';
import 'audience/create_audience.dart';

class PromotionAudienceScreen extends StatelessWidget {
  PromotionAudienceScreen({super.key});
  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PromotionController>(
        init: _promotionController,
        builder: (ctx) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                defineAudience.tr,
                weight: FontWeight.bold,
              ).setPadding(top: 40, bottom: 30),
              // addNextOptionTile(
              //     specialRequirement.tr, subSpecialRequirement.tr),
              Expanded(
                child: ListView.builder(
                    itemCount: _promotionController.audiences.length + 2,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return index == 0
                          ? addCheckboxTile(null, automatic.tr, subAutomatic.tr)
                          : index == _promotionController.audiences.length + 1
                              ? addNextOptionTile(createOwn.tr, subCreateOwn.tr)
                                  .ripple(() {
                                  Get.to(() => CreateAudienceScreen());
                                })
                              : addCheckboxTile(
                                  _promotionController.audiences[index - 1],
                                  _promotionController
                                      .audiences[index - 1].name,
                                  _promotionController.order.audience?.id ==
                                          _promotionController
                                              .audiences[index - 1].id
                                      ? _promotionController
                                          .audienceSelectedInfo.value
                                      : '');
                    }),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                AppThemeButton(
                    text: nextString.tr,
                    onPress: () {
                      _promotionController.nextButtonEvent();
                    })
              ]).bP25
            ],
          ).hP16;
        });
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

  addCheckboxTile(AudienceModel? audience, String title, String subTitle) {
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
            ),
            subTitle == ''
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyMediumText(
                        subTitle,
                        weight: FontWeight.normal,
                        color: AppColorConstants.subHeadingTextColor,
                      ),
                      audience == null
                          ? const SizedBox()
                          : BodyMediumText(
                              'Edit',
                              weight: FontWeight.normal,
                              color: AppColorConstants.themeColor,
                            ).tP4.ripple(() {
                              // _promotionController.editAudienceSetup(audience);
                              Get.to(() =>
                                  CreateAudienceScreen(audience: audience));
                            })
                    ],
                  ).tP4
          ],
        )),
        ThemeIconWidget(
                _promotionController.order.audience?.id == audience?.id
                    ? ThemeIcon.selectedRadio
                    : ThemeIcon.unSelectedRadio,
                size: 25,
                color: _promotionController.order.audience?.id == audience?.id
                    ? AppColorConstants.themeColor
                    : AppColorConstants.mainTextColor)
            .lP4,
      ],
    ).vP16.ripple(() {
      _promotionController.selectAudience(audience);
    });
  }
}
