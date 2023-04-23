import 'package:foap/screens/settings_menu/support_requests_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../helper/common_import.dart';
import 'help_support_contorller.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  HelpSupportController helpSupportContorller = Get.find();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final messageController = TextEditingController();

  String _name = '';
  String _email = '';
  String _phone = '';
  String _message = '';

  void _submitForm() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            backNavigationBarWithIcon(context: context, title: LocalizationString.help,icon:ThemeIcon.card,iconBtnClicked: (){
              Get.to(()=> const SupportRequestsScreen());
            }),
            divider(context: context).tP8,
            SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    InputField(
                      controller: nameController,
                      showBorder: true,
                      showDivider: false,
                      textStyle: Theme.of(context).textTheme.titleSmall,
                      hintText: LocalizationString.name,
                      cornerRadius: 5,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    InputField(
                      controller: emailController,
                      showBorder: true,
                      showDivider: false,
                      textStyle: Theme.of(context).textTheme.titleSmall,
                      hintText: LocalizationString.email,
                      cornerRadius: 5,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    InputField(
                      controller: phoneController,
                      showBorder: true,
                      showDivider: false,
                      textStyle: Theme.of(context).textTheme.titleSmall,
                      hintText: LocalizationString.phoneNumber,
                      cornerRadius: 5,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    InputField(
                      controller: messageController,
                      maxLines: 12,
                      showBorder: true,
                      showDivider: false,
                      textStyle: Theme.of(context).textTheme.titleSmall,
                      hintText: LocalizationString.message,
                      cornerRadius: 5,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    _submitBtn(),
                  ],
                ).extended,
              ),
            ).p25
          ],
        ),
      ),
    );
  }

  Widget _submitBtn() {
    return FilledButtonType1(
      onPress: () {
        helpSupportContorller.submitSupportRequest(
            name: nameController.text,
            email: emailController.text,
            phone: phoneController.text,
            message: messageController.text);
      },
      text: LocalizationString.submit,
      enabledTextStyle: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(fontWeight: FontWeight.w900, color: Colors.white),
      isEnabled: true,
    );
  }
}
