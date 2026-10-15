import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../../model/preference_model.dart';
import 'add_personal_info.dart';

class SetDateOfBirth extends StatefulWidget {
  final bool isSettingProfile;

  const SetDateOfBirth({super.key, required this.isSettingProfile})
      ;

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

    if ((_userProfileManager.user.value!.dob ?? '').isNotEmpty) {
      String dateOfBirthString = _userProfileManager.user.value!.dob ?? '';
      dateOfBirth.text = dateOfBirthString;
      dob = dateOfBirthString.toDateInFormat('yyyy-MM-dd');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
                Heading3Text(
                  whenIsYourBdayString.tr,
                ).setPadding(top: 20),
                BodyMediumText(
                  beAccurateString.tr,
                ).setPadding(top: 10, bottom: 50),
                AppDateTimeTextField(
                  label: dateOfBirthString.tr,
                  hintText: '05/25/1990',
                  controller: dateOfBirth,
                  onChanged: (value) {
                    dob = value;
                  },
                ),
                const Spacer(),
                SizedBox(
                    height: 50,
                    width: Get.width - 50,
                    child: AppThemeButton(
                        cornerRadius: 25,
                        text: submitString.tr,
                        onPress: () {
                          if (dateOfBirth.text != '') {
                            AddDatingDataModel dataModel = AddDatingDataModel();
                            dataModel.dob = dob!.formatTo('yyyy-MM-dd');
                            _userProfileManager.user.value!.dob = dataModel.dob;
                            datingController.updateDatingProfile(dataModel, () {
                              if (widget.isSettingProfile) {
                                Get.to(() => AddPersonalInfo(
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
          const SizedBox(
            height: 20,
          )
        ]));
  }
}
