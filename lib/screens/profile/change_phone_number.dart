import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/profile_controller.dart';

class ChangePhoneNumber extends StatefulWidget {
  const ChangePhoneNumber({super.key});

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
    // the server keeps the dial code without "+" (e.g. 880), the picker shows "+880"
    final saved = (_userProfileManager.user.value!.countryCode ?? '')
        .replaceAll('+', '')
        .trim();
    countryCode = saved.isEmpty ? '+1' : '+$saved';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
                
                title: changePhoneNumberString.tr,
                rightBtnTitle: doneString.tr,
                completion: () {
                  profileController.updateMobile(
                      countryCode: countryCode,
                      phoneNumber: phoneNumber.text,
                      );
                }),
            const SizedBox(
              height: 20,
            ),
            Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorConstants.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
                  width: 0.6),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyMediumText(phoneNumberString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.semiBold),
                const SizedBox(
                  height: 8,
                ),
                addTextField(),
              ],
            )).hp(DesignConstants.horizontalPadding)
          ]),
        ));
  }

  addTextField() {
    return SizedBox(
      height: 50,
      child: AppMobileTextField(
        onChanged: (value) {},
        countryCodeText: countryCode,
        countryCodeValueChanged: (value) {
          countryCode = value;
          setState(() {});
        },
        controller: phoneNumber,
        hintText: '123456789',
      ),
    ).vP8;
  }
}
