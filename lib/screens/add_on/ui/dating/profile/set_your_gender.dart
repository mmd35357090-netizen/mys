import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'add_personal_info.dart';

class SetYourGender extends StatefulWidget {
  final bool isFromSignup;

  const SetYourGender({Key? key, required this.isFromSignup}) : super(key: key);

  @override
  State<SetYourGender> createState() => _SetYourGenderState();
}

class _SetYourGenderState extends State<SetYourGender> {
  final DatingController datingController = DatingController();
  final UserProfileManager _userProfileManager = Get.find();

  List<String> genders = DatingProfileConstants.genders;
  int? selectedGender;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.isFromSignup &&
        _userProfileManager.user.value!.gender != null) {
      selectedGender =
          int.parse(_userProfileManager.user.value!.gender ?? '1') - 1;
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
              title: LocalizationString.genderMainHeader,
              completion: () {
                Get.to(
                    () => AddPersonalInfo(isFromSignup: widget.isFromSignup));
              }),
          divider(context: context).tP8,
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Heading2Text(
                  LocalizationString.genderMainHeader,
                ).setPadding(top: 20),
                Heading6Text(
                  LocalizationString.genderHeader,
                ).setPadding(top: 20),
                ListView.builder(
                  itemCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (_, int index) =>
                      addOption(index).setPadding(top: 15),
                ).setPadding(top: 35),
                Center(
                  child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 50,
                      child: AppThemeButton(
                          cornerRadius: 25,
                          text: LocalizationString.submit,
                          onPress: () {
                            if (selectedGender != null) {
                              AddDatingDataModel dataModel =
                                  AddDatingDataModel();
                              dataModel.gender = selectedGender! + 1;
                              _userProfileManager.user.value!.gender =
                                  dataModel.gender.toString();

                              datingController.updateDatingProfile(dataModel,
                                  (msg) {
                                if (widget.isFromSignup) {
                                  Get.to(() => AddPersonalInfo(
                                      isFromSignup: widget.isFromSignup));
                                } else {
                                  Get.back();
                                }
                              });
                            }
                          })),
                ).setPadding(top: 150),
              ],
            ).hP25,
          )),
        ]));
  }

  Widget addOption(int index) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Heading6Text(
            genders[index],
            color: AppColorConstants.grayscale900,
          ),
          ThemeIconWidget(
              selectedGender == index
                  ? ThemeIcon.circle
                  : ThemeIcon.circleOutline,
              color: AppColorConstants.iconColor)
        ],
      ).hP25.ripple(() {
        setState(() {
          selectedGender = index;
        });
      }),
    ).borderWithRadius(
        color: AppColorConstants.borderColor, radius: 15, value: 1);
  }
}
