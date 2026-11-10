import 'package:foap/screens/settings_menu/support_requests_screen.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'help_support_contorller.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  HelpSupportController helpSupportContorller = Get.find();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            backNavigationBarWithTrailingWidget(
              title: helpString.tr,
              widget: ThemeIconWidget(ThemeIcon.card).ripple(() {
                Get.to(() => const SupportRequestsScreen());
              }),
            ),
            SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColorConstants.themeColor,
                            AppColorConstants.themeColor
                                .withValues(alpha: 0.72),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.support_agent_rounded,
                              color: Colors.white, size: 34),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Need help? Send us a message and our team will reply as soon as possible.',
                              style: TextStyle(
                                  fontSize: 14,
                                  height: 1.35,
                                  color: Colors.white.withValues(alpha: 0.95)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppTextField(
                      controller: nameController,
                      hintText: nameString.tr,
                    ),
                    SizedBox(
                      height: Get.height * 0.025,
                    ),
                    AppTextField(
                      controller: emailController,
                      hintText: emailString.tr,
                    ),
                    SizedBox(
                      height: Get.height * 0.025,
                    ),
                    AppTextField(
                      controller: phoneController,
                      hintText: phoneNumberString.tr,
                    ),
                    SizedBox(
                      height: Get.height * 0.025,
                    ),
                    AppTextField(
                      controller: messageController,
                      maxLines: 5,
                      hintText: messageString.tr,
                    ),
                    SizedBox(
                      height: Get.height * 0.04,
                    ),
                    _submitBtn(),
                  ],
                ),
              ),
            ).p25
          ],
        ),
      ),
    );
  }

  Widget _submitBtn() {
    return AppThemeButton(
      onPress: () {
        helpSupportContorller.submitSupportRequest(
            name: nameController.text,
            email: emailController.text,
            phone: phoneController.text,
            message: messageController.text);

        nameController.text = '';
        emailController.text = '';
        phoneController.text = '';
        messageController.text = '';
      },
      text: submitString.tr,
    );
  }
}
