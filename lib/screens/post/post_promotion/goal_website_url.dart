import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/post/promotion_controller.dart';

class GoalWebsiteUrl extends StatelessWidget {
  GoalWebsiteUrl({super.key});

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
                customNavigationBar(title: website.tr),
                const SizedBox(
                  height: 20,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AppTextField(
                      controller: _promotionController.websiteUrl,
                      hintText: website.tr,
                      onChanged: (value) =>
                          _promotionController.validateUrl(value),
                      icon: _promotionController.isValidWebsite.value == true
                          ? ThemeIcon.checkMark
                          : _promotionController.isValidWebsite.value == false
                              ? ThemeIcon.close
                              : null),
                  BodyExtraSmallText('https://www.example.com',
                          weight: TextWeight.semiBold,
                          color: AppColorConstants.red)
                      .tP4,
                  Heading6Text(buttonAction.tr, weight: TextWeight.semiBold)
                      .tP16,
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _promotionController.websiteButtonText,
                    hintText: 'Write your own, e.g. Download app',
                    maxLength: 30,
                  ),
                  BodyExtraSmallText(
                          'Leave empty to use one of the buttons below',
                          weight: TextWeight.semiBold,
                          color: AppColorConstants.subHeadingTextColor)
                      .tP4,
                ]).hP16,
                Expanded(
                  child: ListView.builder(
                      itemCount: _promotionController.actionButtons.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      itemBuilder: (context, index) {
                        return addCheckboxTile(
                            _promotionController.actionButtons[index],
                            '',
                            index);
                      }),
                ),
                AppThemeButton(
                    text: doneString.tr,
                    onPress: () {
                      if (_promotionController.confirmWebsiteGoal()) {
                        Get.back();
                      } else {
                        AppUtil.showToast(
                            message: 'Please enter a valid website address, e.g. https://www.example.com',
                            isSuccess: false);
                      }
                    }).hP16.bP25,
              ],
            );
          }),
    );
  }

  addCheckboxTile(String title, String subTitle, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Heading6Text(
          title,
          weight: FontWeight.normal,
        ),
        ThemeIconWidget(
                _promotionController.actionSelected.value == index
                    ? ThemeIcon.selectedRadio
                    : ThemeIcon.unSelectedRadio,
                size: 25,
                color: _promotionController.actionSelected.value == index
                    ? AppColorConstants.themeColor
                    : AppColorConstants.mainTextColor)
            .lP4,
      ],
    ).vP16.ripple(() {
      _promotionController.websiteButtonText.text = '';
      _promotionController.selectAction(index);
    });
  }
}
