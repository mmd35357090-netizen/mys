import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/post/promotion_controller.dart';

/// Phone number (with the country code) for the WhatsApp and Call goals, and the text of the button.
class GoalPhone extends StatelessWidget {
  final GoalType type;

  GoalPhone({super.key, required this.type});

  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    final bool isWhatsApp = type == GoalType.whatsapp;
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GetBuilder<PromotionController>(
          init: _promotionController,
          builder: (ctx) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                customNavigationBar(title: isWhatsApp ? 'WhatsApp' : 'Phone call'),
                const SizedBox(height: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Heading6Text(
                      isWhatsApp
                          ? 'WhatsApp number'
                          : 'Phone number',
                      weight: TextWeight.semiBold),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _promotionController.phoneNumber,
                    hintText: '8801712345678',
                    onChanged: (_) => _promotionController.update(),
                  ),
                  BodyExtraSmallText(
                          'Write the number with the country code, without + or spaces. Example: 8801712345678',
                          weight: TextWeight.semiBold,
                          color: AppColorConstants.subHeadingTextColor)
                      .tP4,
                  const SizedBox(height: 20),
                  Heading6Text('Button text (optional)',
                      weight: TextWeight.semiBold),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _promotionController.phoneButtonText,
                    hintText: isWhatsApp ? 'WhatsApp us' : 'Call now',
                    maxLength: 30,
                  ),
                  BodyExtraSmallText(
                          isWhatsApp
                              ? 'People who tap the button open WhatsApp with a chat to this number.'
                              : 'People who tap the button open their phone with this number ready to call.',
                          weight: TextWeight.semiBold,
                          color: AppColorConstants.subHeadingTextColor)
                      .tP4,
                ]).hP16,
                Expanded(child: Container()),
                AppThemeButton(
                    text: doneString.tr,
                    onPress: () {
                      if (_promotionController.confirmPhoneGoal(type)) {
                        Get.back();
                      } else {
                        AppUtil.showToast(
                            message:
                                'Please enter a valid phone number with the country code',
                            isSuccess: false);
                      }
                    }).hP16.bP25,
              ],
            );
          }),
    );
  }
}
