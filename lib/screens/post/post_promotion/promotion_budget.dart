import 'package:foap/helper/imports/common_import.dart';

import '../../../controllers/post/promotion_controller.dart';

class PromotionBudgetScreen extends StatelessWidget {
  PromotionBudgetScreen({super.key});
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
                  '\$${_promotionController.order.dailyBudget.toInt() * _promotionController.order.duration.toInt()} over ${_promotionController.order.duration.toInt()} days',
                  weight: FontWeight.bold,
                ).setPadding(top: 30, bottom: 2),
                BodySmallText(
                  totalSpend.tr,
                  weight: FontWeight.normal,
                  color: AppColorConstants.subHeadingTextColor,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Heading5Text(
                    budget.tr,
                    weight: TextWeight.semiBold,
                  ).hp(14).vP8,
                  addSlider(
                      context,
                      Slider(
                        min: 1.0,
                        max: 1000.0,
                        value: _promotionController.order.dailyBudget,
                        label:
                            '\$ ${_promotionController.order.dailyBudget} daily',
                        divisions: 100,
                        onChanged: (value) =>
                            _promotionController.setBudgetRange(value),
                      )).tp(12),
                  Heading5Text(
                    durationString.tr,
                    weight: TextWeight.semiBold,
                  ).hp(14).vP8,
                  addSlider(
                      context,
                      Slider(
                        min: 2.0,
                        max: 30.0,
                        value: _promotionController.order.duration.toDouble(),
                        label: '${_promotionController.order.duration} days',
                        divisions: 100,
                        onChanged: (value) => _promotionController
                            .setBudgetDurationRange(value.toInt()),
                      )).tp(12),
                ]).tP8,
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppThemeButton(
                            text: nextString.tr,
                            onPress: () {
                              _promotionController.nextButtonEvent();
                            })
                      ]).bP25.hP16,
                ),
              ]);
        });
  }

  Widget addSlider(BuildContext context, Widget view) {
    return SliderTheme(
        data: SliderTheme.of(context).copyWith(
            trackHeight: 3.0,
            valueIndicatorColor: Colors.transparent,
            valueIndicatorTextStyle:
                TextStyle(color: AppColorConstants.mainTextColor),
            activeTrackColor: AppColorConstants.themeColor,
            inactiveTrackColor: AppColorConstants.subHeadingTextColor,
            thumbColor: AppColorConstants.themeColor,
            showValueIndicator: ShowValueIndicator.always),
        child: view);
  }
}
