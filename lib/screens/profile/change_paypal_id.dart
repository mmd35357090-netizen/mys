import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class ChangePaypalId extends StatefulWidget {
  const ChangePaypalId({Key? key}) : super(key: key);

  @override
  State<ChangePaypalId> createState() => _ChangePaypalIdState();
}

class _ChangePaypalIdState extends State<ChangePaypalId> {
  TextEditingController paypalId = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    paypalId.text = _userProfileManager.user.value!.paypalId ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          profileScreensNavigationBar(
              context: context,
              title: LocalizationString.paymentDetail,
              rightBtnTitle: LocalizationString.done,
              completion: () {
                profileController.updatePaypalId(
                    paypalId: paypalId.text, context: context);
              }),

          divider(context: context).vP8,
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading6Text(LocalizationString.paypalId,
                      weight: TextWeight.medium),
                  Container(
                    color: Colors.transparent,
                    height: 50,
                    child: InputField(
                      controller: paypalId,
                      showDivider: true,
                      // showBorder: true,
                      hintText: 'paypalId@gmail.com',
                    ),
                  ),
                ],
              ).vP8,
            ],
          ).hP16,
        ],
      ),
    );
  }
}
