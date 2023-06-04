import 'package:foap/helper/imports/common_import.dart';
import 'choose_whom_to_date.dart';

class WhatYouHope extends StatefulWidget {
  final bool isSettingProfile;

  const WhatYouHope({Key? key, required this.isSettingProfile})
      : super(key: key);

  @override
  State<WhatYouHope> createState() => _WhatYouHopeState();
}

class _WhatYouHopeState extends State<WhatYouHope> {
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
            'What are you hoping to find?',
          ),
          const SizedBox(
            height: 20,
          ),
          const Heading4Text(
            'Honesty helps you and everyone on Datefinder find what you\'re looking for',
          ),
          const SizedBox(
            height: 50,
          ),
          Column(
            children: [
              Container(
                height: 60,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('A relationship',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                    const Icon(Icons.circle_outlined),
                  ],
                ).hP25,
              ).round(10),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 60,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Something casual',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                    const Icon(Icons.circle_outlined),
                  ],
                ).hP25,
              ).round(10),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 60,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Not sure',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                    const Icon(Icons.circle_outlined),
                  ],
                ).hP25,
              ).round(10),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 60,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cant disclose',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                    const Icon(Icons.circle_outlined),
                  ],
                ).hP25,
              ).round(10)
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
                      Get.to(() => ChooseWhomToDate(
                          isSettingProfile: widget.isSettingProfile));
                    })),
          ),
        ],
      ).hP25.addGradientBackground(),
    );
  }
}
