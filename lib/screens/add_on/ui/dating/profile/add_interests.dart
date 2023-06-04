import 'package:foap/components/segmented_control.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';
import 'package:foap/universal_components/rounded_input_field.dart';
import 'package:get/get.dart';

import 'add_profesional_details.dart';

class AddInterests extends StatefulWidget {
  final bool isSettingProfile;

  const AddInterests({Key? key, required this.isSettingProfile})
      : super(key: key);

  @override
  State<AddInterests> createState() => AddInterestsState();
}

class AddInterestsState extends State<AddInterests> {
  final UserProfileManager _userProfileManager = Get.find();

  int smoke = 0;

  TextEditingController drinkHabitController = TextEditingController();
  List<String> drinkHabitList = DatingProfileConstants.drinkHabits;

  final DatingController datingController = DatingController();
  TextEditingController interestsController = TextEditingController();
  List<InterestModel> selectedInterests = [];

  TextEditingController languageController = TextEditingController();
  List<LanguageModel> selectedLanguages = [];

  @override
  void initState() {
    super.initState();
    datingController.getInterests();
    datingController.getLanguages();

    if (_userProfileManager.user.value!.smoke != null) {
      smoke = (_userProfileManager.user.value!.smoke!);
    }
    if (_userProfileManager.user.value!.drink != null) {
      int drink = int.parse(_userProfileManager.user.value!.drink!) - 1;
      drinkHabitController.text = drinkHabitList[drink];
    }

    if (_userProfileManager.user.value!.interests != null) {
      selectedInterests = _userProfileManager.user.value!.interests!;
      String result = selectedInterests.map((val) => val.name).join(', ');
      interestsController.text = result;
    }
    if (_userProfileManager.user.value!.languages != null) {
      selectedLanguages = _userProfileManager.user.value!.languages!;
      String result = selectedLanguages.map((val) => val.name).join(', ');
      languageController.text = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          backNavigationBar(
            title: addInterestsString.tr,
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Heading2Text(
                  addInterestsString.tr,
                ).setPadding(top: 20),
                Heading6Text(
                  addYourInterstsAndHabitsString.tr,
                ).setPadding(top: 20),
                addHeader(doYouSmokeString.tr).setPadding(top: 30, bottom: 8),
                SegmentedControl(
                    segments: [yesString.tr, noString.tr],
                    value: smoke - 1,
                    onValueChanged: (value) {
                      setState(() => smoke = value + 1);
                    }),
                addHeader(drinkingHabitString.tr)
                    .setPadding(top: 30, bottom: 8),
                DropdownBorderedField(
                  hintText: selectString.tr,
                  controller: drinkHabitController,
                  showBorder: true,
                  borderColor: AppColorConstants.borderColor,
                  cornerRadius: 10,
                  iconOnRightSide: true,
                  icon: ThemeIcon.downArrow,
                  iconColor: AppColorConstants.iconColor,
                  onTap: () {
                    openDrinkHabitListPopup();
                  },
                ),
                addHeader(interestsString.tr).setPadding(top: 30, bottom: 8),
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
                addHeader(languageString.tr).setPadding(top: 30, bottom: 8),
                DropdownBorderedField(
                  hintText: selectString.tr,
                  controller: languageController,
                  showBorder: true,
                  borderColor: AppColorConstants.borderColor,
                  cornerRadius: 10,
                  iconOnRightSide: true,
                  icon: ThemeIcon.downArrow,
                  iconColor: AppColorConstants.iconColor,
                  onTap: () {
                    openLanguagePopup();
                  },
                ),
                Center(
                  child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 50,
                      child: AppThemeButton(
                          cornerRadius: 25,
                          text: submitString.tr,
                          onPress: () {
                            submitDetail();
                          })),
                ).setPadding(top: 100),
              ],
            ).paddingAll(25),
          )),
        ]));
  }

  BodyLargeText addHeader(String header) {
    return BodyLargeText(
      header,
      weight: TextWeight.medium,
    );
  }

  void openDrinkHabitListPopup() {
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
                            itemCount: drinkHabitList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (_, int index) {
                              return ListTile(
                                  title: Text(drinkHabitList[index]),
                                  onTap: () {
                                    setState(() {
                                      drinkHabitController.text =
                                          drinkHabitList[index];
                                    });
                                  },
                                  trailing: ThemeIconWidget(
                                      drinkHabitList[index] ==
                                              drinkHabitController.text
                                          ? ThemeIcon.selectedCheckbox
                                          : ThemeIcon.emptyCheckbox,
                                      color: AppColorConstants.iconColor));
                            }).p16)
                    .topRounded(40));
          });
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
                              var anySelection = selectedInterests
                                  .where((element) => element.id == model.id);
                              bool isAdded = anySelection.isNotEmpty;

                              return ListTile(
                                  title: Text(model.name),
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

  void openLanguagePopup() {
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
                            itemCount: datingController.languages.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (_, int index) {
                              LanguageModel model =
                                  datingController.languages[index];
                              var anySelection = selectedLanguages
                                  .where((element) => element.id == model.id);
                              bool isAdded = anySelection.isNotEmpty;

                              return ListTile(
                                  title: Text(model.name ?? ''),
                                  onTap: () {
                                    isAdded
                                        ? selectedLanguages.remove(model)
                                        : selectedLanguages.add(model);

                                    String result = selectedLanguages
                                        .map((val) => val.name)
                                        .join(', ');
                                    languageController.text = result;
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

  submitDetail() {
    AddDatingDataModel dataModel = AddDatingDataModel();
    dataModel.smoke = smoke;
    _userProfileManager.user.value!.smoke = dataModel.smoke;

    if (drinkHabitController.text.isNotEmpty) {
      int drink = drinkHabitList.indexOf(drinkHabitController.text);
      dataModel.drink = drink + 1;
      _userProfileManager.user.value!.drink = dataModel.drink.toString();
    }
    if (selectedInterests.isNotEmpty) {
      dataModel.interests = selectedInterests;
      _userProfileManager.user.value!.interests = selectedInterests;
    }
    if (selectedLanguages.isNotEmpty) {
      dataModel.languages = selectedLanguages;
      _userProfileManager.user.value!.languages = selectedLanguages;
    }
    datingController.updateDatingProfile(dataModel, () {
      if (widget.isSettingProfile) {
        Get.to(() =>
            AddProfessionalDetails(isSettingProfile: widget.isSettingProfile));
      } else {
        Get.back();
      }
    });
  }
}
