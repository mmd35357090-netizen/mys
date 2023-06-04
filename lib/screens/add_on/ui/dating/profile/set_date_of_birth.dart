import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/ui/dating/profile/set_your_gender.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../../model/preference_model.dart';

class SetDateOfBirth extends StatefulWidget {
  final bool isSettingProfile;

  const SetDateOfBirth({Key? key, required this.isSettingProfile})
      : super(key: key);

  @override
  State<SetDateOfBirth> createState() => _SetDateOfBirthState();
}

class _SetDateOfBirthState extends State<SetDateOfBirth> {
  final DatingController datingController = DatingController();
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController dateOfBirth = TextEditingController();

  DateTime? dob;

  @override
  void initState() {
    super.initState();

    if (_userProfileManager.user.value!.dob != null) {
      String dateOfBirthString = _userProfileManager.user.value!.dob ?? '';
      var arr = dateOfBirthString.split('-');
      if (arr.length == 3) {
        dateOfBirth.text = dateOfBirthString;
        dob = DateTime.parse(dateOfBirthString);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          backNavigationBar(
            title: dateOfBirthString.tr,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Heading2Text(
                  whenIsYourBdayString.tr,
                ).setPadding(top: 20),
                Heading6Text(
                  beAccurateString.tr,
                ).setPadding(top: 10),
                addTextField(dateOfBirthString.tr, '05/25/1990', dateOfBirth)
                    .setPadding(top: 50),
                const Spacer(),
                SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 50,
                    child: AppThemeButton(
                        cornerRadius: 25,
                        text: submitString.tr,
                        onPress: () {
                          if (dateOfBirth.text != '') {
                            AddDatingDataModel dataModel = AddDatingDataModel();
                            dataModel.dob =
                                "${dob!.year}-${dob!.month}-${dob!.day}";
                            _userProfileManager.user.value!.dob = dataModel.dob;
                            datingController.updateDatingProfile(dataModel, () {
                              if (widget.isSettingProfile) {
                                Get.to(() => SetYourGender(
                                    isSettingProfile: widget.isSettingProfile));
                              } else {
                                Get.back();
                              }
                            });
                          }
                        })),
              ],
            ).hp(DesignConstants.horizontalPadding),
          ),
          const SizedBox(height: 20,)
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
        AppDateTimeTextField(
          hintText: hint,
          controller: controller,
          onChanged: (value) {
            dob = value;
          },
        ).tP8,
      ],
    );
  }
}
