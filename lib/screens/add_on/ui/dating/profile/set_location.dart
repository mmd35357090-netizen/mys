import 'package:foap/manager/location_manager.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/common_import.dart';

import 'add_name.dart';

class SetLocation extends StatefulWidget {
  final bool isSettingProfile;

  const SetLocation({Key? key, required this.isSettingProfile}) : super(key: key);

  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {
  final DatingController datingController = DatingController();
  final UserProfileManager _userProfileManager = Get.find();
  final LocationManager _locationManager = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 50),
          profileScreensNavigationBar(
              rightBtnTitle: widget.isSettingProfile ? skipString.tr : null,
              title: setLocationString.tr,
              completion: () {
                Get.to(() => AddName(isSettingProfile: widget.isSettingProfile));
              }),
          divider().tP8,
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  color: AppColorConstants.cardColor,
                  child: ThemeIconWidget(ThemeIcon.location,
                      size: 20, color: AppColorConstants.themeColor),
                ).round(30).tP25,
                Heading3Text(
                  setLocationServiceString.tr,
                ).setPadding(top: 40),
                Heading4Text(
                  weWillUseYourLoctaionString.tr,
                ).setPadding(top: 20),
                Center(
                  child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 50,
                      child: AppThemeButton(
                          cornerRadius: 25,
                          text: setLocationServiceStrng.tr,
                          onPress: () {
                            enableLocation();
                          })),
                ).setPadding(top: 150),
              ]).hP25,
        ],
      ),
    );
  }

  enableLocation() {
    _locationManager.getLocation(locationCallback: (locationData) {
      try {
        AddDatingDataModel dataModel = AddDatingDataModel();
        dataModel.latitude = locationData.latitude.toString();
        dataModel.longitude = locationData.longitude.toString();
        _userProfileManager.user.value!.latitude = locationData.latitude.toString();
        _userProfileManager.user.value!.longitude =
            locationData.longitude.toString();
        datingController.updateDatingProfile(dataModel, () {
          if (widget.isSettingProfile) {
            Get.to(() => AddName(isSettingProfile: widget.isSettingProfile));
          } else {
            Get.back();
          }
        });
      } catch (err) {}
    });
  }
}
