import 'package:foap/controllers/job/job_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/job_model.dart';

class ApplyJob extends StatefulWidget {
  final JobModel job;

  const ApplyJob(this.job, {super.key}) ;

  @override
  State<ApplyJob> createState() => ApplyJobState();
}

class ApplyJobState extends State<ApplyJob> {
  final JobController jobController = Get.find();
  TextEditingController experience = TextEditingController();
  TextEditingController education = TextEditingController();
  TextEditingController coverLetter = TextEditingController();

  List<int> experienceList = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            backNavigationBar(title: enterProductDetailString.tr),
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Obx(() => AppDropdownField(
                                  label: experienceInYearsString.tr,
                                  value:
                                      jobController.experience.value.toString(),
                                  options: experienceList
                                      .map((e) => e.toString())
                                      .toList(),
                                  onChanged: (String value) {
                                    jobController
                                        .selectExperience(int.parse(value));
                                  },
                                )).bP16,
                            AppTextField(
                              label: educationString.tr,
                              hintText: 'MCA',
                              controller: education,
                            ).bP16,
                            AppTextField(
                              label: coverLetterString.tr,
                              hintText: enterHereString.tr,
                              controller: coverLetter,
                              maxLines: 100,
                            ).bP16,
                            AppThemeButton(
                              text: uploadResumeString.tr,
                              onPress: () {
                                jobController.openFilePicker();
                              },
                            ),
                            const SizedBox(height: 10),
                            Obx(
                              () => jobController.selectedResumeFileName.isEmpty
                                  ? Container()
                                  : BodyLargeText(
                                      jobController
                                          .selectedResumeFileName.value,
                                      color: AppColorConstants.themeColor,
                                    ),
                            ),
                            SizedBox(height: Get.height * 0.2),
                          ]),
                    ),
                    Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: AppThemeButton(
                          text: applyString.tr,
                          onPress: () {
                            submitBtnClicked();
                          },
                        ))
                  ],
                ),
              ).hp(DesignConstants.horizontalPadding),
            ),
          ],
        ),
      ),
    );
  }

  void submitBtnClicked() {
    if (education.text.isEmpty) {
      AppUtil.showToast(message: pleaseEnterEducationString, isSuccess: false);
    } else if (coverLetter.text.isEmpty) {
      AppUtil.showToast(
          message: pleaseEnterCoverLetterString, isSuccess: false);
    } else if (jobController.selectedResume == null) {
      AppUtil.showToast(message: pleaseSelectResumeString, isSuccess: false);
    } else {
      jobController.applyJob(
          jobId: widget.job.id.toString(),
          experience: jobController.experience.value.toString(),
          education: education.text,
          coverLetter: coverLetter.text);
    }
  }
}
