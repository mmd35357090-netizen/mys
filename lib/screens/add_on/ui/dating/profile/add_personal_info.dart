import 'package:foap/components/segmented_control.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';
import 'package:foap/universal_components/rounded_input_field.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'add_interests.dart';

class AddPersonalInfo extends StatefulWidget {
  final bool isSettingProfile;

  const AddPersonalInfo({super.key, required this.isSettingProfile});

  @override
  State<AddPersonalInfo> createState() => AddPersonalInfoState();
}

class AddPersonalInfoState extends State<AddPersonalInfo> {
  final DatingController datingController = DatingController();
  final UserProfileManager _userProfileManager = Get.find();
  List<InterestModel> selectedInterests = [];

  List<String> colors = DatingProfileConstants.colors;
  List<String> passionateAbout = DatingProfileConstants.passionateAbout;

  // int selectedColor = 0;
  int selectedPassionateAbout = 0;

  // double _valueForHeight = 176.0;
  int _valueForHolisticPath = 0;

  // List<String> religions = DatingProfileConstants.religions;

  // TextEditingController religionController = TextEditingController();
  TextEditingController interestsController = TextEditingController();

  List<String> status = DatingProfileConstants.genders;

  // int selectedStatus = 1;
  int selectedGender = 1;

  @override
  void initState() {
    super.initState();
    datingController.getInterests();
    // if (_userProfileManager.user.value!.color != null) {
    //   int index = colors.indexOf(_userProfileManager.user.value!.color!);
    //   selectedColor = index != -1 ? index : 0;
    // }
    if (_userProfileManager.user.value!.passionate != null) {
      selectedPassionateAbout =
          _userProfileManager.user.value!.passionate ?? 1;
    }

    // if (_userProfileManager.user.value!.height != null) {
    //   _valueForHeight =
    //       double.parse(_userProfileManager.user.value!.height!);
    // }
    if (_userProfileManager.user.value!.holisticPath != null) {
      _valueForHolisticPath =
          _userProfileManager.user.value!.holisticPath!;
    }
    // if (_userProfileManager.user.value!.religion != null) {
    //   religionController.text = _userProfileManager.user.value!.religion!;
    // }
    // if (_userProfileManager.user.value!.maritalStatus != null) {
    //   selectedStatus = _userProfileManager.user.value!.maritalStatus!;
    // }
    if (_userProfileManager.user.value!.gender != null) {
      selectedGender =
          int.parse(_userProfileManager.user.value!.gender ?? '1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          // const SizedBox(height: 50),
          backNavigationBar(
            // rightBtnTitle: widget.isSettingProfile ? skipString.tr : null,
            title: personalDetailsString.tr,
            // completion: () {
            //   Get.to(() =>
            //       AddInterests(isSettingProfile: widget.isSettingProfile));
            // }
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Heading3Text(
                    weNeedToKnowMoreString.tr,
                  ).setPadding(top: 20),
                  Heading6Text(
                    beAccurateString.tr,
                  ).setPadding(top: 20),
                  // addHeader(colorString.tr).setPadding(top: 30, bottom: 8),
                  // SegmentedControl(
                  //     segments: colors,
                  //     value: selectedColor,
                  //     onValueChanged: (value) {
                  //       setState(() => selectedColor = value);
                  //     }),
                  addHeader(whatAreYouMostPassionateAboutString.tr)
                      .setPadding(top: 30, bottom: 8),
                  SegmentedControl(
                      segments: passionateAbout,
                      value: selectedPassionateAbout - 1,
                      onValueChanged: (value) {
                        setState(
                            () => selectedPassionateAbout = value + 1);
                      }),
                  // addHeader(heightString.tr)
                  //     .setPadding(top: 30, bottom: 20),
                  // Slider(
                  //   min: 121.0,
                  //   max: 243.0,
                  //   value: _valueForHeight,
                  //   inactiveColor: AppColorConstants.subHeadingTextColor,
                  //   activeColor: AppColorConstants.themeColor,
                  //   label: '${_valueForHeight.round()}',
                  //   divisions: 243,
                  //   padding: EdgeInsets.zero,
                  //   onChanged: (dynamic value) {
                  //     setState(() {
                  //       _valueForHeight = value;
                  //     });
                  //   },
                  // ),
                  addHeader(howWouldYouDescribeHolisticPath.tr)
                      .setPadding(top: 30, bottom: 20),
                  Slider(
                    min: 0.0,
                    max: 100.0,
                    padding: EdgeInsets.zero,
                    value: _valueForHolisticPath.toDouble(),
                    inactiveColor: AppColorConstants.subHeadingTextColor,
                    activeColor: AppColorConstants.themeColor,
                    label: '${_valueForHolisticPath.round()}',
                    divisions: 100,
                    onChanged: (dynamic value) {
                      setState(() {
                        _valueForHolisticPath = (value as double).toInt();
                      });
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodySmallText(
                        beginnerString.tr,
                      ),
                      BodySmallText(
                        professionalString.tr,
                      )
                    ],
                  ),
                  // addHeader(religionString.tr)
                  //     .setPadding(top: 25, bottom: 8),
                  // DropdownBorderedField(
                  //   hintText: selectString.tr,
                  //   controller: religionController,
                  //   showBorder: true,
                  //   borderColor: AppColorConstants.borderColor,
                  //   cornerRadius: 10,
                  //   iconOnRightSide: true,
                  //   icon: ThemeIcon.downArrow,
                  //   iconColor: AppColorConstants.iconColor,
                  //   onTap: () {
                  //     openReligionPopup();
                  //   },
                  // ),
                  addHeader(whatInterestYouString.tr)
                      .setPadding(top: 25, bottom: 8),
                  DropdownBorderedField(
                    hintText: selectString.tr,
                    controller: interestsController,
                    showBorder: true,
                    borderColor: AppColorConstants.borderColor,
                    cornerRadius: 10,
                    iconOnRightSide: true,
                    icon: ThemeIcon.downArrow,
                    iconColor: AppColorConstants.iconColor,
                    onTap: () {
                      openInterestsPopup();
                    },
                  ),
                  addHeader(genderString.tr)
                      .setPadding(top: 30, bottom: 8),
                  SegmentedControl(
                      segments: status,
                      value: selectedGender - 1,
                      onValueChanged: (value) {
                        setState(() => selectedGender = value + 1);
                      }),
                  Center(
                    child: SizedBox(
                        height: 50,
                        width: Get.width - 50,
                        child: AppThemeButton(
                            cornerRadius: 25,
                            text: submitString.tr,
                            onPress: () {
                              submitDetail();
                            })),
                  ).setPadding(top: 50, bottom: 100),
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
          ),
        ]));
  }

  BodySmallText addHeader(String header) {
    return BodySmallText(
      header,
      // weight: TextWeight.medium,
    );
  }

  // void openReligionPopup() {
  //   showModalBottomSheet(
  //       backgroundColor: Colors.transparent,
  //       context: context,
  //       builder: (context) {
  //         return StatefulBuilder(
  //             builder: (BuildContext context, StateSetter setState) {
  //           return FractionallySizedBox(
  //               heightFactor: 0.8,
  //               child: Container(
  //                       color: AppColorConstants.cardColor.darken(),
  //                       child: ListView.builder(
  //                           itemCount: religions.length,
  //                           physics: const NeverScrollableScrollPhysics(),
  //                           shrinkWrap: true,
  //                           itemBuilder: (_, int index) {
  //                             return ListTile(
  //                                 title: BodyLargeText(religions[index]),
  //                                 onTap: () {
  //                                   setState(() {
  //                                     religionController.text =
  //                                         religions[index];
  //                                   });
  //                                 },
  //                                 trailing: ThemeIconWidget(
  //                                     religions[index] ==
  //                                             religionController.text
  //                                         ? ThemeIcon.selectedCheckbox
  //                                         : ThemeIcon.emptyCheckbox,
  //                                     color: AppColorConstants.iconColor));
  //                           }).p16)
  //                   .topRounded(40));
  //         });
  //       });
  // }

  submitDetail() {
    AddDatingDataModel dataModel = AddDatingDataModel();

    // dataModel.selectedColor = colors[selectedColor];
    // _userProfileManager.user.value!.color = dataModel.selectedColor;

    // dataModel.height = _valueForHeight.toInt();
    // _userProfileManager.user.value!.height = dataModel.height.toString();

    // if (religionController.text.isNotEmpty) {
    //   dataModel.religion = religionController.text;
    //   _userProfileManager.user.value!.religion = religionController.text;
    // }

    dataModel.gender = selectedGender;
    dataModel.passionateAbout = selectedPassionateAbout;
    dataModel.holisticPath = _valueForHolisticPath;

    _userProfileManager.user.value!.gender = dataModel.gender.toString();
    _userProfileManager.user.value!.passionate =
        dataModel.passionateAbout!;
    _userProfileManager.user.value!.holisticPath = dataModel.holisticPath!;

    datingController.updateDatingProfile(dataModel, () {
      if (widget.isSettingProfile) {
        Get.to(
            () => AddInterests(isSettingProfile: widget.isSettingProfile));
      } else {
        Get.back();
      }
    });
  }

  void openInterestsPopup() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return FractionallySizedBox(
                heightFactor: 0.8,
                child: Container(
                        color: AppColorConstants.cardColor.darken(0.07),
                        child: ListView.builder(
                            itemCount: datingController.interests.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (_, int index) {
                              InterestModel model =
                                  datingController.interests[index];
                              var anySelection = selectedInterests.where(
                                  (element) => element.id == model.id);
                              bool isAdded = anySelection.isNotEmpty;

                              return ListTile(
                                  title: BodyLargeText(model.name),
                                  onTap: () {
                                    isAdded
                                        ? selectedInterests.remove(model)
                                        : selectedInterests.add(model);

                                    String result = selectedInterests
                                        .map((val) => val.name)
                                        .join(', ');
                                    interestsController.text = result;
                                    setState(() {});
                                  },
                                  trailing: ThemeIconWidget(
                                      isAdded
                                          ? ThemeIcon.selectedCheckbox
                                          : ThemeIcon.emptyCheckbox,
                                      color: AppColorConstants.iconColor));
                            }).p16)
                    .topRounded(40));
          });
        });
  }
}
