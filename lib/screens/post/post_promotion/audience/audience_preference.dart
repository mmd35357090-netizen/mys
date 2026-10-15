import 'package:foap/helper/imports/common_import.dart';
import '../../../../controllers/post/promotion_controller.dart';

class AudiencePreferenceScreen extends StatelessWidget {
  AudiencePreferenceScreen({super.key});
  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GetBuilder<PromotionController>(
        init: _promotionController,
        builder: (ctx) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customNavigationBar(title: profilePreference.tr),
                AppDropdownField(
                  hintText: genderString.tr,
                  value: _promotionController.selectedGender.value,
                  icon: ThemeIcon.calendar,
                  options: _promotionController.genderType,
                  onChanged: (gender) =>
                      _promotionController.selectGender(gender),
                ).setPadding(top: 25, left: 16, right: 16),
                SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        trackHeight: 3.0,
                        valueIndicatorColor: Colors.transparent,
                        valueIndicatorTextStyle:
                            TextStyle(color: AppColorConstants.mainTextColor),
                        showValueIndicator: ShowValueIndicator.always),
                    child: RangeSlider(
                      values: _promotionController.ageRange.value,
                      min: 0.0,
                      max: 100.0,
                      activeColor: AppColorConstants.themeColor,
                      inactiveColor: AppColorConstants.subHeadingTextColor,
                      labels: RangeLabels(
                          '${_promotionController.ageRange.value.start.toInt()}',
                          '${_promotionController.ageRange.value.end.toInt()}'),
                      divisions: 100,
                      onChanged: (value) =>
                          _promotionController.selectAgeRange(value),
                    )).tp(20),
                BodyMediumText(
                        '${ageString.tr}: (${_promotionController.ageRange.value.start.toInt()} - ${_promotionController.ageRange.value.end.toInt()}) years')
                    .setPadding(top: 8, left: 18, right: 18),
              ]);
        }));
  }
}