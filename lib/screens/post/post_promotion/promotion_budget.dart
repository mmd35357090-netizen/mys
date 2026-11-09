import 'package:foap/helper/imports/common_import.dart';

import '../../../controllers/post/promotion_controller.dart';
import 'promotion_estimate_card.dart';
import 'promotion_ui.dart';

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
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColorConstants.themeColor,
                        AppColorConstants.themeColor.withValues(alpha: 0.72),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColorConstants.themeColor.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(children: [
                    BodySmallText(totalSpend.tr,
                        color: Colors.white.withValues(alpha: 0.85)),
                    const SizedBox(height: 6),
                    Heading2Text('$currency${order.totalAmount.toInt()}',
                        color: Colors.white, weight: TextWeight.bold),
                    const SizedBox(height: 4),
                    BodyMediumText(
                        '${boostOverLabel.tr} ${order.duration} ${daysString.tr}',
                        color: Colors.white.withValues(alpha: 0.9)),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          promotionCard(
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Column(children: [
                              _titleWithValue(
                                  budget.tr,
                                  '$currency${budgetValue.toInt()} / ${boostPerDayLabel.tr}',
                                  Icons.payments_rounded),
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
                                  )),
                            ]),
                          ),
                          promotionCard(
                            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Column(children: [
                              _titleWithValue(
                                  durationString.tr,
                                  '${daysValue.toInt()} ${daysString.tr}',
                                  Icons.event_rounded),
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
                                  )),
                            ]),
                          ),
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

  // Title on the left, the chosen value on the right, so the number is always visible.
  Widget _titleWithValue(String title, String value, IconData icon) {
    return Row(
      children: [
        promotionIconBubble(icon, AppColorConstants.themeColor, size: 38),
        const SizedBox(width: 12),
        Expanded(child: Heading6Text(title, weight: TextWeight.semiBold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorConstants.themeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: BodyMediumText(value,
              weight: TextWeight.semiBold,
              color: AppColorConstants.themeColor),
        ),
      ],
    );
  }

  Widget addSlider(BuildContext context, Widget view) {
    return SliderTheme(
        data: SliderTheme.of(context).copyWith(
            trackHeight: 5.0,
            valueIndicatorColor: Colors.transparent,
            valueIndicatorTextStyle:
                TextStyle(color: AppColorConstants.mainTextColor),
            activeTrackColor: AppColorConstants.themeColor,
            inactiveTrackColor: AppColorConstants.dividerColor,
            thumbColor: AppColorConstants.themeColor,
            showValueIndicator: ShowValueIndicator.always),
        child: view);
  }
}
