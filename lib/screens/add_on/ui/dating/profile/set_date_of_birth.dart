import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/ui/dating/profile/set_your_gender.dart';
import 'package:foap/universal_components/rounded_input_field.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../../model/preference_model.dart';

class SetDateOfBirth extends StatefulWidget {
  final bool isFromSignup;

  const SetDateOfBirth({Key? key, required this.isFromSignup})
      : super(key: key);

  @override
  State<SetDateOfBirth> createState() => _SetDateOfBirthState();
}

class _SetDateOfBirthState extends State<SetDateOfBirth> {
  final DatingController datingController = DatingController();
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController day = TextEditingController();
  TextEditingController month = TextEditingController();
  TextEditingController year = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!widget.isFromSignup &&
        _userProfileManager.user.value!.dob != null) {
      String dob = _userProfileManager.user.value!.dob ?? '';
      var arr = dob.split('-');
      if (arr.length == 3) {
        year.text = arr[0];
        month.text = arr[1];
        day.text = arr[2];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          const SizedBox(height: 50),
          profileScreensNavigationBar(
              context: context,
              rightBtnTitle:
                  widget.isFromSignup ? LocalizationString.skip : null,
              title: LocalizationString.birthdayMainHeader,
              completion: () {
                Get.to(() => SetYourGender(isFromSignup: widget.isFromSignup));
              }),
          divider(context: context).tP8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Heading2Text(
                LocalizationString.birthdayHeader,
              ).setPadding(top: 20),
              Heading6Text(
                LocalizationString.birthdaySubHeader,
              ).setPadding(top: 10),
              Row(
                children: [
                  addTextField(LocalizationString.day, 'dd', day),
                  const SizedBox(width: 10),
                  addTextField(LocalizationString.month, 'MM', month),
                  const SizedBox(width: 10),
                  addTextField(LocalizationString.year, 'YYYY', year),
                ],
              ).setPadding(top: 50),
              Center(
                child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 50,
                    child: AppThemeButton(
                        cornerRadius: 25,
                        text: LocalizationString.submit,
                        onPress: () {
                          if (year.text != '' &&
                              month.text != '' &&
                              day.text != '') {
                            AddDatingDataModel dataModel = AddDatingDataModel();
                            dataModel.dob =
                                "${year.text}-${month.text}-${day.text}";
                            _userProfileManager.user.value!.dob =
                                dataModel.dob;
                            datingController.updateDatingProfile(dataModel,
                                (msg) {
                              if (widget.isFromSignup) {
                                Get.to(() => SetYourGender(
                                    isFromSignup: widget.isFromSignup));
                              } else {
                                Get.back();
                              }
                              // if (msg != '' &&
                              //     !isLoginFirstTime) {
                              //   AppUtil.showToast(
                              //       context: context,
                              //       message: msg,
                              //       isSuccess: true);
                              // }
                            });
                          }
                        })),
              ).setPadding(top: 150),
            ],
          ).hP25,
        ]));
  }

  Widget addTextField(
      String header, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyMediumText(
          header,
        ),
        SizedBox(
          width: 60,
          child: InputField(
            hintText: hint,
            controller: controller,
            showBorder: true,
            borderColor: Theme.of(context).disabledColor,
            cornerRadius: 10,
          ),
        ).tP8,
      ],
    );
  }
}
