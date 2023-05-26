import 'package:foap/manager/location_manager.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/common_import.dart';

import 'add_name.dart';

class SetLocation extends StatefulWidget {
  final bool isFromSignup;

  const SetLocation({Key? key, required this.isFromSignup}) : super(key: key);

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
              rightBtnTitle: widget.isFromSignup ? skipString.tr : null,
              title: locationMainHeaderString.tr,
              completion: () {
                Get.to(() => AddName(isFromSignup: widget.isFromSignup));
              }),
          divider().tP8,
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  color: Theme.of(context).cardColor,
                  child: ThemeIconWidget(ThemeIcon.location,
                      size: 20, color: Theme.of(context).primaryColor),
                ).round(30).tP25,
                Heading3Text(
                  locationHeaderString.tr,
                ).setPadding(top: 40),
                Heading4Text(
                  locationSubHeaderString.tr,
                ).setPadding(top: 20),
                Center(
                  child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 50,
                      child: AppThemeButton(
                          cornerRadius: 25,
                          text: locationServiceString.tr,
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
        datingController.updateDatingProfile(dataModel, (msg) {
          if (widget.isFromSignup) {
            Get.to(() => AddName(isFromSignup: widget.isFromSignup));
          } else {
            Get.back();
          }
        });
      } catch (err) {}
    });
  }
}
