import 'package:foap/components/segmented_control.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';
import 'package:foap/universal_components/rounded_input_field.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'add_interests.dart';

class AddPersonalInfo extends StatefulWidget {
  final bool isSettingProfile;

  const AddPersonalInfo({Key? key, required this.isSettingProfile})
      : super(key: key);

  @override
  State<AddPersonalInfo> createState() => AddPersonalInfoState();
}

class AddPersonalInfoState extends State<AddPersonalInfo> {
  final DatingController datingController = DatingController();
  final UserProfileManager _userProfileManager = Get.find();

  List<String> colors = DatingProfileConstants.colors;
  int selectedColor = 0;

  double _valueForHeight = 176.0;

  List<String> religions = DatingProfileConstants.religions;
  TextEditingController religionController = TextEditingController();

  List<String> status = DatingProfileConstants.maritalStatus;
  int selectedStatus = 1;

  @override
  void initState() {
    super.initState();
    if (_userProfileManager.user.value!.color != null) {
      int index = colors.indexOf(_userProfileManager.user.value!.color!);
      selectedColor = index != -1 ? index : 0;
    }
    if (_userProfileManager.user.value!.height != null) {
      _valueForHeight = double.parse(_userProfileManager.user.value!.height!);
    }
    if (_userProfileManager.user.value!.religion != null) {
      religionController.text = _userProfileManager.user.value!.religion!;
    }
    if (_userProfileManager.user.value!.maritalStatus != null) {
      selectedStatus = _userProfileManager.user.value!.maritalStatus!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          divider().tP8,
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Heading2Text(
                    weNeedToKnowMoreString.tr,
                  ).setPadding(top: 20),
                  Heading6Text(
                    beAccurateString.tr,
                  ).setPadding(top: 20),
                  addHeader(colorString.tr).setPadding(top: 30, bottom: 8),
                  SegmentedControl(
                      segments: colors,
                      value: selectedColor,
                      onValueChanged: (value) {
                        setState(() => selectedColor = value);
                      }),
                  addHeader(heightString.tr).setPadding(top: 30),
                  Slider(
                    min: 121.0,
                    max: 243.0,
                    value: _valueForHeight,
                    inactiveColor: AppColorConstants.grayscale400,
                    activeColor: AppColorConstants.themeColor,
                    label: '${_valueForHeight.round()}',
                    divisions: 243,
                    onChanged: (dynamic value) {
                      setState(() {
                        _valueForHeight = value;
                      });
                    },
                  ),
                  addHeader(religionString.tr).setPadding(top: 15, bottom: 8),
                  DropdownBorderedField(
                    hintText: selectString.tr,
                    controller: religionController,
                    showBorder: true,
                    borderColor: AppColorConstants.borderColor,
                    cornerRadius: 10,
                    iconOnRightSide: true,
                    icon: ThemeIcon.downArrow,
                    iconColor: AppColorConstants.iconColor,
                    onTap: () {
                      openReligionPopup();
                    },
                  ),
                  addHeader(statusString.tr).setPadding(top: 30, bottom: 8),
                  SegmentedControl(
                      segments: status,
                      value: selectedStatus - 1,
                      onValueChanged: (value) {
                        setState(() => selectedStatus = value + 1);
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
                  ).setPadding(top: 100),
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
          ),
        ]));
  }

  BodyLargeText addHeader(String header) {
    return BodyLargeText(
      header,
      weight: TextWeight.medium,
    );
  }

  void openReligionPopup() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return FractionallySizedBox(
                heightFactor: 0.8,
                child: Container(
                        color: AppColorConstants.cardColor.darken(),
                        child: ListView.builder(
                            itemCount: religions.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (_, int index) {
                              return ListTile(
                                  title: BodyLargeText(religions[index]),
                                  onTap: () {
                                    setState(() {
                                      religionController.text =
                                          religions[index];
                                    });
                                  },
                                  trailing: ThemeIconWidget(
                                      religions[index] ==
                                              religionController.text
                                          ? ThemeIcon.selectedCheckbox
                                          : ThemeIcon.emptyCheckbox,
                                      color: AppColorConstants.iconColor));
                            }).p16)
                    .topRounded(40));
          });
        });
  }

  submitDetail() {
    AddDatingDataModel dataModel = AddDatingDataModel();

    if (selectedColor != null) {
      dataModel.selectedColor = colors[selectedColor!];
      _userProfileManager.user.value!.color = dataModel.selectedColor;
    }

    dataModel.height = _valueForHeight.toInt();
    _userProfileManager.user.value!.height = dataModel.height.toString();

    if (religionController.text.isNotEmpty) {
      dataModel.religion = religionController.text;
      _userProfileManager.user.value!.religion = religionController.text;
    }

    dataModel.status = selectedStatus;
    _userProfileManager.user.value!.maritalStatus = dataModel.status;

    datingController.updateDatingProfile(dataModel, () {
      if (widget.isSettingProfile) {
        Get.to(() => AddInterests(isSettingProfile: widget.isSettingProfile));
      } else {
        Get.back();
      }
    });
  }
}
