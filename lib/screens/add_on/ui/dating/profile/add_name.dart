import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';
import 'package:foap/screens/add_on/ui/dating/profile/set_date_of_birth.dart';
import 'package:foap/helper/imports/common_import.dart';

class AddName extends StatefulWidget {
  final bool isSettingProfile;

  const AddName({Key? key, required this.isSettingProfile}) : super(key: key);

  @override
  State<AddName> createState() => _AddNameState();
}

class _AddNameState extends State<AddName> {
  final DatingController datingController = DatingController();
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nameController.text = _userProfileManager.user.value!.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: addNameString.tr,
          ),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Heading2Text(
                    whatsYourNameString.tr,
                  ).setPadding(top: 20),
                  Heading6Text(
                    cantChangeThisLaterString.tr,
                  ).setPadding(top: 20),
                  AppTextField(
                    hintText: 'e.g Alex',
                    controller: nameController,
                  ).setPadding(top: 20),
                  const Spacer(),
                  SizedBox(
                      height: 50,
                      width: Get.width - 50,
                      child: AppThemeButton(
                          cornerRadius: 25,
                          text: submitString.tr,
                          onPress: () {
                            if (nameController.text != '') {
                              AddDatingDataModel dataModel =
                                  AddDatingDataModel();
                              dataModel.name = nameController.text;
                              _userProfileManager.user.value!.name =
                                  dataModel.name;
                              datingController.updateDatingProfile(dataModel,
                                  () {
                                if (widget.isSettingProfile) {
                                  Get.to(() => SetDateOfBirth(
                                      isSettingProfile:
                                          widget.isSettingProfile));
                                } else {
                                  Get.back();
                                }
                              });
                            }
                          })),
                ]).hp(DesignConstants.horizontalPadding),
          ),
          const SizedBox(height: 20,)
        ],
      ),
    );
  }
}
