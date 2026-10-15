import 'package:foap/controllers/post/add_post_controller.dart';

import '../../helper/imports/common_import.dart';

class CreatePoll extends StatefulWidget {
  const CreatePoll({super.key});

  @override
  State<CreatePoll> createState() => _CreatePollState();
}

class _CreatePollState extends State<CreatePoll> {
  final AddPostController _addPostController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController pollName = TextEditingController();
  List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void submitPoll() {
    String question = pollName.text.trim();
    List<String> options = optionControllers
        .map((controller) => controller.text.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    if (question.isEmpty) {
      AppUtil.showToast(
          message: pollQuestionCanNotBeEmpty.tr, isSuccess: false);

      return;
    }

    if (options.length < 2) {
      AppUtil.showToast(
          message: atleastTwoOptionsAreRequiredString.tr,
          isSuccess: false);
      return;
    }

    Map<String, dynamic> pollData = {
      "question": question,
      "options": options,
    };

    _addPostController.createPoll(pollData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: createPollString.tr),
          const SizedBox(height: 20),
          form().hp(DesignConstants.horizontalPadding),

        ],
      ),
    );
  }

  Widget form() {
    return Column(
      children: [
        AppTextField(
          controller: pollName,
          hintText: askQuestionString.tr,
          label: questionString.tr,
        ),
        const SizedBox(height: 20),
        ...List.generate(optionControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: optionControllers[index],
                    hintText: "${optionString.tr} ${index + 1}",
                    label: "${optionString.tr} ${index + 1}",
                  ),
                ),
                if (optionControllers.length > 2)
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Container(
                        color: AppColorConstants.red,
                        child: ThemeIconWidget(
                          ThemeIcon.minus,
                          color: Colors.white,
                        ).p(12),
                      ).round(10).ripple(() {
                        setState(() {
                          optionControllers.removeAt(index);
                        });
                      })
                    ],
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        if (optionControllers.length < 4)
          AppThemeButton(
            text: addOptionString.tr,
            onPress: () {
              if (optionControllers.length < 4) {
                setState(() {
                  optionControllers.add(TextEditingController());
                });
              }
            },
          ),
        const SizedBox(height: 20),

        SizedBox(
          height: 50,
          child: Row(
            children: [
              ThemeIconWidget(ThemeIcon.message),
              const SizedBox(
                width: 10,
              ),
              BodyMediumText(allowCommentsString),
              const Spacer(),
              Obx(() => ThemeIconWidget(_addPostController
                  .enableComments.value
                  ? ThemeIcon.selectedCheckbox
                  : ThemeIcon.emptyCheckbox)
                  .ripple(() {
                _addPostController.toggleEnableComments();
              })),
            ],
          ),
        ),
        if (_userProfileManager
            .user.value!.subscriptionPlans.isNotEmpty)
          SizedBox(
            height: 50,
            child: Row(
              children: [
                ThemeIconWidget(ThemeIcon.diamond),
                const SizedBox(
                  width: 10,
                ),
                BodyMediumText(forSubscribersOnlyString),
                const Spacer(),
                Obx(() => ThemeIconWidget(_addPostController
                    .isPaidContent.value
                    ? ThemeIcon.selectedCheckbox
                    : ThemeIcon.emptyCheckbox)
                    .ripple(() {
                  _addPostController
                      .togglePaidContentMode();
                })),
              ],
            ),
          ),
        const SizedBox(height: 20),
        AppThemeButton(text: submitString.tr, onPress: submitPoll),
      ],
    );
  }

  @override
  void dispose() {
    pollName.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
