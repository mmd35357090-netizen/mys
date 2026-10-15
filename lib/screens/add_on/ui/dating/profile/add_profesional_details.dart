import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../../model/preference_model.dart';
import '../dating_dashboard.dart';

class AddProfessionalDetails extends StatefulWidget {
  final bool isSettingProfile;

  const AddProfessionalDetails({super.key, required this.isSettingProfile})
      ;

  @override
  State<AddProfessionalDetails> createState() => AddProfessionalDetailsState();
}

class AddProfessionalDetailsState extends State<AddProfessionalDetails> {
  TextEditingController qualificationController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController experienceMonthController = TextEditingController();
  TextEditingController experienceYearController = TextEditingController();
  final DatingController datingController = DatingController();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();

    if (_userProfileManager.user.value!.qualification != null) {
      qualificationController.text =
          _userProfileManager.user.value!.qualification!;
    }
    if (_userProfileManager.user.value!.occupation != null) {
      occupationController.text = _userProfileManager.user.value!.occupation!;
    }
    if (_userProfileManager.user.value!.experienceMonth != null) {
      experienceMonthController.text =
          _userProfileManager.user.value!.experienceMonth!.toString();
    }
    if (_userProfileManager.user.value!.experienceYear != null) {
      experienceYearController.text =
          _userProfileManager.user.value!.experienceYear!.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          backNavigationBar(
            title: professionalDetailString.tr,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Heading3Text(
                    addProfessionalDetailString.tr,
                  ).vP25,
                  AppTextField(
                    label: qualificationString.tr,
                    hintText: 'Master in computer',
                    controller: qualificationController,
                  ).bP25,
                  AppTextField(
                    hintText: 'Entrepreneur',
                    label: occupationString.tr,
                    controller: occupationController,
                  ).bP25,
                  BodySmallText(
                    workExperienceString.tr,
                  ).bP8,
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: AppTextField(
                            hintText: yearString.tr,
                            controller: experienceYearController,
                          ).rp(4),
                        ),
                        Flexible(
                          child: AppTextField(
                            hintText: monthString.tr,
                            controller: experienceMonthController,
                          ).lp(4),
                        ),
                      ]),
                  // const Spacer(),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                      height: 50,
                      width: Get.width - 50,
                      child: AppThemeButton(
                          cornerRadius: 25,
                          text: submitString.tr,
                          onPress: () {
                            AddDatingDataModel dataModel = AddDatingDataModel();
                            if (qualificationController.text.isNotEmpty) {
                              dataModel.qualification =
                                  qualificationController.text;
                              _userProfileManager.user.value!.qualification =
                                  dataModel.qualification;
                            }
                            if (occupationController.text.isNotEmpty) {
                              dataModel.occupation = occupationController.text;
                              _userProfileManager.user.value!.occupation =
                                  dataModel.occupation;
                            }
                            if (experienceMonthController.text.isNotEmpty) {
                              dataModel.experienceMonth =
                                  experienceMonthController.text;
                              _userProfileManager.user.value!.experienceMonth =
                                  int.parse(dataModel.experienceMonth ?? '0');
                            }
                            if (experienceYearController.text.isNotEmpty) {
                              dataModel.experienceYear =
                                  experienceYearController.text;
                              _userProfileManager.user.value!.experienceYear =
                                  int.parse(dataModel.experienceYear ?? '0');
                            }

                            if (qualificationController.text.isNotEmpty ||
                                occupationController.text.isNotEmpty ||
                                experienceMonthController.text.isNotEmpty ||
                                experienceYearController.text.isNotEmpty) {
                              datingController.updateDatingProfile(dataModel,
                                  () {
                                if (widget.isSettingProfile) {
                                  Get.close(7);
                                  Get.to(() => const DatingDashboard());
                                } else {
                                  Get.back();
                                }
                              });
                            }
                          })),
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ]));
  }

  BodyLargeText addHeader(String header) {
    return BodyLargeText(
      header,
      weight: TextWeight.medium,
    );
  }
}
