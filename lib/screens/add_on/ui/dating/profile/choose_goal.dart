import 'package:foap/screens/add_on/ui/dating/profile/what_you_hope.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/common_import.dart';

class ChooseGoal extends StatefulWidget {
  final bool isSettingProfile;

  const ChooseGoal({Key? key, required this.isSettingProfile}) : super(key: key);

  @override
  State<ChooseGoal> createState() => _ChooseGoalState();
}

class _ChooseGoalState extends State<ChooseGoal> {
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 100,
          ),
          const Heading3Text(
            'Choose a mode to get started',
          ),
          const SizedBox(
            height: 20,
          ),
          const Heading3Text(
            'DateFinder for making all kinds of connections! You will be able to switch modes once you are all setup',
          ),
          const SizedBox(
            height: 50,
          ),
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 80,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Heading4Text(
                            dateString.tr,
                          ),
                          const Heading5Text(
                            'Find what spark in and empowered community',
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.circle_outlined),
                  ],
                ).hP25,
              ).round(10),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 80,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BFF',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                          Text('Make new friends at every stage of life',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.black)),
                        ],
                      ),
                    ),
                    const Icon(Icons.circle_outlined),
                  ],
                ).hP25,
              ).round(10),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 80,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bizz',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                          Text('Move your career forward the modern way',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.black)),
                        ],
                      ),
                    ),
                    const Icon(Icons.circle_outlined),
                  ],
                ).hP25,
              ).round(10),
            ],
          ),
          const SizedBox(
            height: 150,
          ),
          Center(
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                child: AppThemeButton(
                    backgroundColor: Colors.white,
                    cornerRadius: 25,
                    text: nextString.tr,
                    onPress: () {
                      Get.to(
                          () => WhatYouHope(isSettingProfile: widget.isSettingProfile));
                    })),
          ),
        ],
      ).hP25.addGradientBackground(),
    );
  }
}
