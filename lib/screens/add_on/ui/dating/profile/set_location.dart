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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 50),
          profileScreensNavigationBar(
              context: context,
              rightBtnTitle:
              widget.isFromSignup ? LocalizationString.skip : null,
              title: LocalizationString.locationMainHeader,
              completion: () {
                Get.to(() => AddName(isFromSignup: widget.isFromSignup));
              }),
          divider(context: context).tP8,
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
                  LocalizationString.locationHeader,
                ).setPadding(top: 40),
                Heading4Text(
                  LocalizationString.locationSubHeader,
                ).setPadding(top: 20),
                Center(
                  child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 50,
                      child: AppThemeButton(
                          cornerRadius: 25,
                          text: LocalizationString.locationService,
                          onPress: () {
                            LocationManager().getLocation((location) async {
                              try {
                                AddDatingDataModel dataModel =
                                AddDatingDataModel();
                                dataModel.latitude =
                                    location.latitude.toString();
                                dataModel.longitude =
                                    location.longitude.toString();
                                _userProfileManager.user.value!.latitude =
                                    location.latitude.toString();
                                _userProfileManager.user.value!.longitude =
                                    location.longitude.toString();
                                datingController.updateDatingProfile(dataModel,
                                        (msg) {
                                      if (widget.isFromSignup) {
                                        Get.to(() => AddName(
                                            isFromSignup: widget.isFromSignup));
                                      } else {
                                        Get.back();
                                      }
                                    });
                              } catch (err) {}
                            });
                          })),
                ).setPadding(top: 150),
              ]).hP25,
        ],
      ),
    );
  }
}
