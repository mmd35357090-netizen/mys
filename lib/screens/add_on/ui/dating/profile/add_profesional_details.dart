import 'package:foap/manager/socket_manager.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../../model/preference_model.dart';

class AddProfessionalDetails extends StatefulWidget {
  final bool isFromSignup;

  const AddProfessionalDetails({Key? key, required this.isFromSignup})
      : super(key: key);

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
    if (!widget.isFromSignup) {
      if (_userProfileManager.user.value!.qualification != null) {
        qualificationController.text =
            _userProfileManager.user.value!.qualification ?? '';
      }
      if (_userProfileManager.user.value!.occupation != null) {
        occupationController.text =
            _userProfileManager.user.value!.occupation ?? '';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          const SizedBox(height: 50),
          profileScreensNavigationBar(

              rightBtnTitle:
                  widget.isFromSignup ? skipString.tr : null,
              title: professionalString.tr,
              completion: () {
                Get.offAll(() => const DashboardScreen());
                getIt<SocketManager>().connect();
              }),
          divider().tP8,
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Heading2Text(
                  addProfessionalHeaderString.tr,
                ).setPadding(top: 20),
                addHeader(qualificationString.tr)
                    .setPadding(top: 30, bottom: 8),
                AppTextField(
                    hintText: 'Master in computer',
                    controller: qualificationController,
                    ),
                addHeader(occupationString.tr)
                    .setPadding(top: 30, bottom: 8),
                AppTextField(
                    hintText: 'Entrepreneur',
                    controller: occupationController,
                    ),
                addHeader(workExperienceString.tr)
                    .setPadding(top: 30, bottom: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: AppTextField(
                                hintText: '1900',
                                controller: experienceYearController,
                                )
                            .rp(4),
                      ),
                      Flexible(
                        child: AppTextField(
                                hintText: '10',
                                controller: experienceMonthController,
                                )
                            .lp(4),
                      ),
                    ]),
                Center(
                  child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 50,
                      child: AppThemeButton(
                          cornerRadius: 25,
                          text: submitString.tr,
                          onPress: () {
                            AddDatingDataModel dataModel = AddDatingDataModel();
                            if (qualificationController.text.isNotEmpty) {
                              dataModel.qualification =
                                  qualificationController.text;
                              _userProfileManager
                                  .user
                                  .value!
                                  .qualification = dataModel.qualification;
                            }
                            if (occupationController.text.isNotEmpty) {
                              dataModel.occupation = occupationController.text;
                              _userProfileManager
                                  .user
                                  .value!
                                  .occupation = dataModel.occupation;
                            }
                            if (experienceMonthController.text.isNotEmpty) {
                              dataModel.experienceMonth =
                                  experienceMonthController.text;
                              _userProfileManager
                                      .user
                                      .value!
                                      .experienceMonth =
                                  int.parse(dataModel.experienceMonth ?? '0');
                            }
                            if (experienceYearController.text.isNotEmpty) {
                              dataModel.experienceYear =
                                  experienceYearController.text;
                              _userProfileManager
                                      .user
                                      .value!
                                      .experienceYear =
                                  int.parse(dataModel.experienceYear ?? '0');
                            }

                            if (qualificationController.text.isNotEmpty ||
                                occupationController.text.isNotEmpty ||
                                experienceMonthController.text.isNotEmpty ||
                                experienceYearController.text.isNotEmpty) {
                              datingController.updateDatingProfile(dataModel,
                                  (msg) {
                                if (widget.isFromSignup) {
                                  Get.offAll(() => const DashboardScreen());
                                  getIt<SocketManager>().connect();
                                } else {
                                  Get.back();
                                }
                                // if (msg != '' && !isLoginFirstTime) {
                                //   AppUtil.showToast(
                                //
                                //       message: msg,
                                //       isSuccess: true);
                                // }
                              });
                            }
                          })),
                ).setPadding(top: 50),
              ],
            ).p(25),
          )),
        ]));
  }

  BodyLargeText addHeader(String header) {
    return BodyLargeText(
      header,
      weight: TextWeight.medium,
    );
  }
}
