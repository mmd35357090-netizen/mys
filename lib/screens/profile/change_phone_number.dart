import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class ChangePhoneNumber extends StatefulWidget {
  const ChangePhoneNumber({Key? key}) : super(key: key);

  @override
  ChangePhoneNumberState createState() => ChangePhoneNumberState();
}

class ChangePhoneNumberState extends State<ChangePhoneNumber> {
  TextEditingController phoneNumber = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  String countryCode = "+1";

  @override
  void initState() {
    super.initState();
    phoneNumber.text = _userProfileManager.user.value!.phone ?? '';
    countryCode = _userProfileManager.user.value!.countryCode ?? '+1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(
              height: 55,
            ),
            profileScreensNavigationBar(
                context: context,
                title: LocalizationString.changePhoneNumber,
                rightBtnTitle: LocalizationString.done,
                completion: () {
                  profileController.updateMobile(
                      countryCode: countryCode,
                      phoneNumber: phoneNumber.text,
                      context: context);
                }),
            divider(context: context).vP8,
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(LocalizationString.phoneNumber,
                    weight: TextWeight.medium),
                const SizedBox(
                  height: 8,
                ),
                addTextField(),
              ],
            ).hP16
          ]),
        ));
  }

  addTextField() {
    return SizedBox(
      height: 50,
      child: InputMobileNumberField(
        onChanged: (value) {},
        phoneCodeText: countryCode,
        phoneCodeValueChanged: (value) {
          countryCode = value;
          setState(() {});
        },
        controller: phoneNumber,
        showDivider: true,
        hintText: '123456789',
      ),
    ).vP8;
  }
}
