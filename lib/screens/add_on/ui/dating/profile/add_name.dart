import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';
import 'package:foap/screens/add_on/ui/dating/profile/set_date_of_birth.dart';
import 'package:foap/helper/imports/common_import.dart';

class AddName extends StatefulWidget {
  final bool isFromSignup;

  const AddName({Key? key, required this.isFromSignup}) : super(key: key);

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
    if (!widget.isFromSignup &&
        _userProfileManager.user.value!.name != null) {
      nameController.text = _userProfileManager.user.value!.name ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 50),
          profileScreensNavigationBar(
              
              rightBtnTitle:
                  widget.isFromSignup ? skipString.tr : null,
              title: nameMainHeaderString.tr,
              completion: () {
                Get.to(() => SetDateOfBirth(isFromSignup: widget.isFromSignup));
              }),
          divider().tP8,
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Heading2Text(
                  nameHeaderString.tr,
                ).setPadding(top: 100),
                Heading6Text(
                  nameSubHeaderString.tr,
                ).setPadding(top: 20),
                AppTextField(
                  hintText: 'e.g Alex',
                  controller: nameController,
                ).setPadding(top: 20),
                Center(
                  child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 50,
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
                                  (msg) {
                                if (widget.isFromSignup) {
                                  Get.to(() => SetDateOfBirth(
                                      isFromSignup: widget.isFromSignup));
                                } else {
                                  Get.back();
                                }
                                // if (msg != '' &&
                                //     !isLoginFirstTime) {
                                //   AppUtil.showToast(
                                //       
                                //       message: msg,
                                //       isSuccess: true);
                                // }
                              });
                            }
                          })),
                ).setPadding(top: 150),
              ]).hP25
        ],
      ),
    );
  }
}
