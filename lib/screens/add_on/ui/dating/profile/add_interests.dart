import 'package:foap/components/segmented_control.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';
import 'package:foap/universal_components/rounded_input_field.dart';
import 'package:get/get.dart';

import 'add_profesional_details.dart';


class AddInterests extends StatefulWidget {
  final bool isFromSignup;

  const AddInterests({Key? key, required this.isFromSignup}) : super(key: key);

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

    if (!widget.isFromSignup) {
      if (_userProfileManager.user.value!.smoke != null) {
        smoke = (_userProfileManager.user.value!.smoke ?? 1) - 1;
      }
      if (_userProfileManager.user.value!.drink != null) {
        int drink =
            int.parse(_userProfileManager.user.value!.drink ?? '1') - 1;
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
              title: LocalizationString.addInterestsHeader,
              completion: () {
                Get.to(() => AddProfessionalDetails(
                      isFromSignup: widget.isFromSignup,
                    ));
              }),
          divider(context: context).tP8,
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Heading2Text(
                  LocalizationString.addInterestsHeader,
                ).setPadding(top: 20),
                Heading6Text(
                  LocalizationString.addInterestsSubHeader,
                ).setPadding(top: 20),
                addHeader('Do you smoke?').setPadding(top: 30, bottom: 8),
                SegmentedControl(
                    segments: [LocalizationString.yes, LocalizationString.no],
                    value: smoke,
                    onValueChanged: (value) {
                      setState(() => smoke = value);
                    }),
                addHeader(LocalizationString.drinkingHabit)
                    .setPadding(top: 30, bottom: 8),
                DropdownBorderedField(
                  hintText: LocalizationString.select,
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
                addHeader(LocalizationString.interests)
                    .setPadding(top: 30, bottom: 8),
                DropdownBorderedField(
                  hintText: LocalizationString.select,
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
                addHeader(LocalizationString.language)
                    .setPadding(top: 30, bottom: 8),
                DropdownBorderedField(
                  hintText: LocalizationString.select,
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
                          text: LocalizationString.submit,
                          onPress: () {
                            AddDatingDataModel dataModel = AddDatingDataModel();
                            dataModel.smoke = smoke + 1;
                            _userProfileManager.user.value!.smoke =
                                dataModel.smoke;

                            if (drinkHabitController.text.isNotEmpty) {
                              int drink = drinkHabitList
                                  .indexOf(drinkHabitController.text);
                              dataModel.drink = drink + 1;
                              _userProfileManager.user.value!.drink =
                                  dataModel.drink.toString();
                            }
                            if (selectedInterests.isNotEmpty) {
                              dataModel.interests = selectedInterests;
                              _userProfileManager
                                  .user
                                  .value!
                                  .interests = selectedInterests;
                            }
                            if (selectedLanguages.isNotEmpty) {
                              dataModel.languages = selectedLanguages;
                              _userProfileManager
                                  .user
                                  .value!
                                  .languages = selectedLanguages;
                            }
                            datingController.updateDatingProfile(dataModel,
                                (msg) {
                              if (widget.isFromSignup) {
                                Get.to(() => AddProfessionalDetails(
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
                        color: Theme.of(context).cardColor.darken(0.07),
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
                                      color:
                                          Theme.of(context).iconTheme.color));
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
                        color: Theme.of(context).cardColor.darken(0.07),
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
                                      color:
                                          Theme.of(context).iconTheme.color));
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
                        color: Theme.of(context).cardColor.darken(),
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
                                      color:
                                          Theme.of(context).iconTheme.color));
                            }).p16)
                    .topRounded(40));
          });
        });
  }
}
