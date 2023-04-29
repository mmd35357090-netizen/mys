import 'package:foap/components/segmented_control.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/universal_components/rounded_input_field.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../model/preference_model.dart';

class SetDatingPreference extends StatefulWidget {
  const SetDatingPreference({Key? key}) : super(key: key);

  @override
  State<SetDatingPreference> createState() => SetDatingPreferenceState();
}

class SetDatingPreferenceState extends State<SetDatingPreference> {
  int? selectedGender;

  SfRangeValues _valuesForAge = const SfRangeValues(16.0, 50.0);
  SfRangeValues _valuesForHeight = const SfRangeValues(165.0, 182.0);

  final DatingController datingController = DatingController();
  TextEditingController interestsController = TextEditingController();
  List<InterestModel> selectedInterests = [];

  List<String> colors = DatingProfileConstants.colors;
  int selectedColor = 1;

  List<String> religions = DatingProfileConstants.religions;
  TextEditingController religionController = TextEditingController();

  List<String> maritalStatus = DatingProfileConstants.maritalStatus;
  int? selectedMaritalStatus;

  TextEditingController languageController = TextEditingController();
  List<LanguageModel> selectedLanguages = [];

  int smoke = 0;

  TextEditingController drinkHabitController = TextEditingController();
  List<String> drinkHabitList = DatingProfileConstants.drinkHabits;

  @override
  void initState() {
    super.initState();
    datingController.getInterests();
    datingController.getLanguages();
    datingController.getUserPreference(() {
      if (datingController.preferenceModel?.gender != null) {
        selectedGender = (datingController.preferenceModel?.gender ?? 1) - 1;
      }

      double ageFrom = 16.0;
      if (datingController.preferenceModel?.ageFrom != null) {
        ageFrom = datingController.preferenceModel!.ageFrom!.toDouble();
      }

      double ageTo = 50.0;
      if (datingController.preferenceModel?.ageTo != null) {
        ageTo = datingController.preferenceModel!.ageTo!.toDouble();
      }
      _valuesForAge = SfRangeValues(ageFrom, ageTo);

      double heightFrom = 165.0;
      if (datingController.preferenceModel?.heightFrom != null) {
        heightFrom = datingController.preferenceModel!.heightFrom!.toDouble();
      }

      double heightTo = 182.0;
      if (datingController.preferenceModel?.heightTo != null) {
        heightTo = datingController.preferenceModel!.heightTo!.toDouble();
      }
      _valuesForHeight = SfRangeValues(heightFrom, heightTo);

      if (datingController.preferenceModel?.interests != null) {
        selectedInterests = datingController.preferenceModel!.interests!;
        String result = selectedInterests.map((val) => val.name).join(', ');
        interestsController.text = result;
      }

      if (datingController.preferenceModel?.selectedColor != null) {
        selectedColor =
            colors.indexOf(datingController.preferenceModel!.selectedColor!);
      }

      if (datingController.preferenceModel?.religion != null) {
        int index =
            religions.indexOf(datingController.preferenceModel!.religion!);
        religionController.text = religions[index];
      }

      if (datingController.preferenceModel?.status != null) {
        selectedMaritalStatus = datingController.preferenceModel!.status! - 1;
      }

      if (datingController.preferenceModel?.languages != null) {
        selectedLanguages = datingController.preferenceModel!.languages!;
        String result = selectedLanguages.map((val) => val.name).join(', ');
        languageController.text = result;
      }

      if (datingController.preferenceModel?.smoke != null) {
        smoke = (datingController.preferenceModel?.smoke ?? 1) - 1;
      }

      if (datingController.preferenceModel?.drink != null) {
        int drink = (datingController.preferenceModel?.drink ?? 1) - 1;
        drinkHabitController.text = drinkHabitList[drink];
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          backNavigationBar(
            context: context,
            title: LocalizationString.preferences,
          ),
          divider(context: context).tP8,
          GetBuilder<DatingController>(
              init: datingController,
              builder: (ctx) {
                return Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        addHeader(LocalizationString.gender)
                            .setPadding(bottom: 8),
                        SegmentedControl(
                            segments: [
                              LocalizationString.male,
                              LocalizationString.female,
                              LocalizationString.other
                            ],
                            value: selectedGender,
                            onValueChanged: (value) {
                              setState(() => selectedGender = value);
                            }),
                        addHeader(LocalizationString.age).setPadding(top: 30),
                        SfRangeSlider(
                          min: 16.0,
                          max: 100.0,
                          inactiveColor: AppColorConstants.cardColor,
                          activeColor: AppColorConstants.themeColor,
                          showLabels: true,
                          enableTooltip: true,
                          values: _valuesForAge,
                          onChanged: (dynamic values) {
                            setState(() {
                              _valuesForAge = values;
                            });
                          },
                          tooltipTextFormatterCallback:
                              (dynamic actualValue, String formattedText) {
                            return '${actualValue.round()}';
                          },
                          labelFormatterCallback:
                              (dynamic actualValue, String formattedText) {
                            return '${actualValue.round()}Y';
                          },
                        ),
                        addHeader(LocalizationString.height)
                            .setPadding(top: 30),
                        SfRangeSlider(
                          min: 121.0,
                          max: 243.0,
                          inactiveColor: AppColorConstants.cardColor,
                          activeColor: AppColorConstants.themeColor,
                          showLabels: true,
                          enableTooltip: true,
                          values: _valuesForHeight,
                          onChanged: (dynamic values) {
                            setState(() {
                              _valuesForHeight = values;
                            });
                          },
                          tooltipTextFormatterCallback:
                              (dynamic actualValue, String formattedText) {
                            return '${actualValue.round()}';
                          },
                          labelFormatterCallback:
                              (dynamic actualValue, String formattedText) {
                            return '${actualValue.round()} cm';
                          },
                        ),
                        addHeader(LocalizationString.interests)
                            .setPadding(top: 30, bottom: 8),
                        addInputField(
                            interestsController, () => openInterestsPopup()),
                        addHeader(LocalizationString.color)
                            .setPadding(top: 30, bottom: 8),
                        SegmentedControl(
                            segments: colors,
                            value: selectedColor,
                            onValueChanged: (value) {
                              setState(() => selectedColor = value);
                            }),
                        addHeader(LocalizationString.religion)
                            .setPadding(top: 30, bottom: 8),
                        addInputField(
                            religionController, () => openReligionPopup()),
                        addHeader(LocalizationString.status)
                            .setPadding(top: 30, bottom: 8),
                        SegmentedControl(
                            segments: maritalStatus,
                            value: selectedMaritalStatus,
                            onValueChanged: (value) {
                              setState(() => selectedMaritalStatus = value);
                            }),
                        addHeader(LocalizationString.language)
                            .setPadding(top: 30, bottom: 8),
                        addInputField(
                            languageController, () => openLanguagePopup()),
                        addHeader(LocalizationString.smokingHabit)
                            .setPadding(top: 30, bottom: 8),
                        SegmentedControl(
                            segments: [
                              LocalizationString.yes,
                              LocalizationString.no
                            ],
                            value: smoke,
                            onValueChanged: (value) {
                              setState(() => smoke = value);
                            }),
                        addHeader(LocalizationString.drinkingHabit)
                            .setPadding(top: 30, bottom: 8),
                        addInputField(drinkHabitController,
                            () => openDrinkHabitListPopup()),
                        Center(
                          child: SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width - 50,
                              child: AppThemeButton(
                                  cornerRadius: 25,
                                  text: LocalizationString.set,
                                  onPress: () {
                                    setPref();
                                  })),
                        ).setPadding(top: 30),
                      ]).paddingAll(20)),
                );
              }),
        ],
      ),
    );
  }

  Widget addHeader(String header) {
    return BodyLargeText(header, weight: TextWeight.medium);
  }

  addInputField(TextEditingController controller, VoidCallback? onTap) {
    return DropdownBorderedField(
      hintText: LocalizationString.select,
      controller: controller,
      showBorder: true,
      borderColor: AppColorConstants.disabledColor,
      cornerRadius: 10,
      iconOnRightSide: true,
      icon: ThemeIcon.downArrow,
      iconColor: AppColorConstants.disabledColor,
      onTap: () => onTap!(),
    );
  }

  void openInterestsPopup() {
    // showModalBottomSheet(
    //     backgroundColor: Colors.transparent,
    //     context: context,
    //     isScrollControlled: true,
    //     builder: (context) => const FractionallySizedBox(
    //         heightFactor: 0.42, child: ChatMediaSharingOptionPopup()));

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
                              title: BodyLargeText(model.name),
                              onTap: () {
                                int index = selectedInterests.indexWhere(
                                    (element) => element.id == model.id);
                                index != -1
                                    ? selectedInterests.removeAt(index)
                                    : selectedInterests.add(model);

                                String result = selectedInterests
                                    .map((val) => val.name)
                                    .join(', ');
                                interestsController.text = result;
                                setState(() {});
                              },
                              trailing: Icon(
                                  isAdded
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: AppColorConstants.iconColor));
                        }).p16,
                  ));
            },
          ).topRounded(40);
        });
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
                                  trailing: Icon(
                                      religions[index] ==
                                              religionController.text
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: AppColorConstants.iconColor));
                            }).p16))
                .topRounded(40);
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
                                  title: BodyLargeText(model.name ?? ''),
                                  onTap: () {
                                    int index = selectedLanguages.indexWhere(
                                        (element) => element.id == model.id);
                                    index != -1
                                        ? selectedLanguages.removeAt(index)
                                        : selectedLanguages.add(model);

                                    String result = selectedLanguages
                                        .map((val) => val.name)
                                        .join(', ');
                                    languageController.text = result;
                                    setState(() {});
                                  },
                                  trailing: Icon(
                                      isAdded
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: AppColorConstants.iconColor));
                            }).p16)
                    .topRounded(40));
          });
        });
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
                        color: AppColorConstants.cardColor.darken(),
                        child: ListView.builder(
                            itemCount: drinkHabitList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (_, int index) {
                              return ListTile(
                                  title: BodyLargeText(drinkHabitList[index]),
                                  onTap: () {
                                    setState(() {
                                      drinkHabitController.text =
                                          drinkHabitList[index];
                                    });
                                  },
                                  trailing: Icon(
                                      drinkHabitList[index] ==
                                              drinkHabitController.text
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: AppColorConstants.iconColor));
                            }).p16)
                    .topRounded(40));
          });
        });
  }

  setPref() {
    AddPreferenceModel preferences = AddPreferenceModel();
    if (selectedGender != null) {
      preferences.gender = selectedGender! + 1;
    }

    preferences.ageFrom = _valuesForAge.start.toInt();
    preferences.ageTo = _valuesForAge.end.toInt();

    preferences.heightFrom = _valuesForHeight.start.toInt();
    preferences.heightTo = _valuesForHeight.end.toInt();

    if (selectedInterests.isNotEmpty) {
      preferences.interests = selectedInterests;
    }

    preferences.selectedColor = colors[selectedColor];

    if (religionController.text.isNotEmpty) {
      preferences.religion = religionController.text;
    }

    if (selectedMaritalStatus != null) {
      preferences.status = selectedMaritalStatus! + 1;
    }

    if (selectedLanguages.isNotEmpty) {
      preferences.languages = selectedLanguages;
    }

    preferences.smoke = smoke + 1;

    if (drinkHabitController.text.isNotEmpty) {
      int drink = drinkHabitList.indexOf(drinkHabitController.text);
      preferences.drink = drink + 1;
    }
    datingController.setPreferencesApi(preferences);
  }
}
