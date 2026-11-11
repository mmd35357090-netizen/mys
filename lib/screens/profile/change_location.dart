import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/profile_controller.dart';

class ChangeLocation extends StatefulWidget {
  const ChangeLocation({super.key});

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
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          profileScreensNavigationBar(
              
              title: changeLocationString.tr,
              rightBtnTitle: doneString.tr,
              completion: () {
                updateLocation();
              }),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorConstants.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
                  width: 0.6),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyMediumText(countryString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.semiBold),
              Container(
                color: Colors.transparent,
                height: 50,
                child: AppTextField(
                  controller: country,
                  hintText: countryString.tr,
                ),
              ).vP8,
              const SizedBox(
                height: 20,
              ),
              BodyMediumText(cityString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.semiBold),
              Container(
                color: Colors.transparent,
                height: 50,
                child: AppTextField(
                  controller: city,
                  hintText: cityString.tr,
                ),
              ).vP8,
              const SizedBox(
                height: 20,
              ),
            ],
          )).hp(DesignConstants.horizontalPadding),
        ],
      ),
    );
  }

  updateLocation() {
    profileController.updateLocation(
        country: country.text, city: city.text);
  }
}
