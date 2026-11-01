import 'package:foap/helper/imports/common_import.dart';

import '../../../controllers/post/promotion_controller.dart';
import 'promotion_estimate_card.dart';

class PromotionBudgetScreen extends StatelessWidget {
  PromotionBudgetScreen({super.key});
  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PromotionController>(
        init: _promotionController,
        builder: (ctx) {
          final order = _promotionController.order;
          final String currency = _promotionController.currency;

          final double minBudget = _promotionController.minDailyBudget.toDouble();
          final double maxBudget = _promotionController.maxDailyBudget.toDouble();
          final double minDays = _promotionController.minDuration.toDouble();
          final double maxDays = _promotionController.maxDuration.toDouble();

          // keep the slider thumb inside its range even if the limits changed
          final double budgetValue =
              order.dailyBudget.clamp(minBudget, maxBudget).toDouble();
          final double daysValue =
              order.duration.toDouble().clamp(minDays, maxDays).toDouble();

          return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Heading4Text(
                  '$currency${order.totalAmount.toInt()} ${boostOverLabel.tr} ${order.duration} ${daysString.tr}',
                  weight: FontWeight.bold,
                ).setPadding(top: 30, bottom: 2),
                BodySmallText(
                  totalSpend.tr,
                  weight: FontWeight.normal,
                  color: AppColorConstants.subHeadingTextColor,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Heading5Text(
                            budget.tr,
                            weight: TextWeight.semiBold,
                          ).hp(14).vP8,
                          addSlider(
                              context,
                              Slider(
                                min: minBudget,
                                max: maxBudget,
                                value: budgetValue,
                                label: '$currency${budgetValue.toInt()}',
                                divisions: (maxBudget - minBudget).toInt(),
                                onChanged: (value) => _promotionController
                                    .setBudgetRange(value),
                              )).tp(12),
                          Heading5Text(
                            durationString.tr,
                            weight: TextWeight.semiBold,
                          ).hp(14).vP8,
                          addSlider(
                              context,
                              Slider(
                                min: minDays,
                                max: maxDays,
                                value: daysValue,
                                label: '${daysValue.toInt()} ${daysString.tr}',
                                divisions: (maxDays - minDays).toInt(),
                                onChanged: (value) => _promotionController
                                    .setBudgetDurationRange(value.toInt()),
                              )).tp(12),
                          PromotionEstimateCard().hP16.tP16,
                        ]).tP8,
                  ),
                ),
                AppThemeButton(
                    text: nextString.tr,
                    onPress: () {
                      _promotionController.nextButtonEvent();
                    }).bP25.hP16,
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
