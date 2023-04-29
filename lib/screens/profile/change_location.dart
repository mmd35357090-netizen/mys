import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class ChangeLocation extends StatefulWidget {
  const ChangeLocation({Key? key}) : super(key: key);

  @override
  State<ChangeLocation> createState() => _ChangeLocationState();
}

class _ChangeLocationState extends State<ChangeLocation> {
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController country = TextEditingController();
  TextEditingController city = TextEditingController();

  late UserModel model;

  final ProfileController profileController = Get.find();

  @override
  void initState() {
    model = _userProfileManager.user.value!;

    super.initState();

    country.text = model.country ?? '';
    city.text = model.city ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          profileScreensNavigationBar(
              context: context,
              title: LocalizationString.changeLocation,
              rightBtnTitle: LocalizationString.done,
              completion: () {
                updateLocation();
              }),
          divider(context: context).vP8,
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading6Text(LocalizationString.country,
                  weight: TextWeight.medium),
              Container(
                color: Colors.transparent,
                height: 50,
                child: InputField(
                  controller: country,
                  showDivider: true,
                  hintText: LocalizationString.country,
                ),
              ).vP8,
              const SizedBox(
                height: 20,
              ),
              Heading6Text(LocalizationString.city, weight: TextWeight.medium),
              Container(
                color: Colors.transparent,
                height: 50,
                child: InputField(
                  controller: city,
                  showDivider: true,
                  hintText: LocalizationString.city,
                ),
              ).vP8,
              const SizedBox(
                height: 20,
              ),
            ],
          ).hP16,
        ],
      ),
    );
  }

  updateLocation() {
    profileController.updateLocation(
        country: country.text, city: city.text, context: context);
  }
}
