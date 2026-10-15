import 'package:flutter/cupertino.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;
import '../../../../components/sm_tab_bar.dart';
import '../../../../controllers/post/promotion_controller.dart';

class AudienceLocationScreen extends StatelessWidget {
  AudienceLocationScreen({super.key}) ;

  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GetBuilder<PromotionController>(
            init: _promotionController,
            builder: (ctx) {
              return SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      customNavigationBar(title: locationsString.tr),
                      // const EstimatedAudienceTile(),
                      DefaultTabController(
                        length: _promotionController.locationType.length,
                        child: Column(children: [
                          SMTabBar(
                              tabs: _promotionController.locationType,
                              canScroll: false),
                          SizedBox(
                              height: Get.height - 320,
                              child: TabBarView(
                                children: [
                                  regionalLocationView(),
                                  localLocationView(context)
                                ],
                              )),
                        ]),
                      ),
                    ]),
              );
            }));
  }

  Widget regionalLocationView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SFSearchBar(
        onSearchCompleted: (value) => {},
        onSearchChanged: (value) => _promotionController.searchLocations(value),
        showSearchIcon: true,
        // backgroundColor: AppColorConstants.subHeadingTextColor,
        radius: 15,
      ).p(DesignConstants.horizontalPadding),
      Expanded(
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BodyMediumText(addLocations.tr,
                  color: AppColorConstants.subHeadingTextColor)
              .hp(DesignConstants.horizontalPadding),
          _promotionController.selectedLocations.isNotEmpty
              ? Heading6Text(selectedRegion.tr, weight: TextWeight.semiBold)
                  .hp(DesignConstants.horizontalPadding)
                  .tP16
              : const SizedBox(),
          _promotionController.selectedLocations.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 5),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BodyLargeText(_promotionController
                                    .selectedLocations[index].fullName),
                                ThemeIconWidget(ThemeIcon.checkMarkWithCircle,
                                    color: AppColorConstants.themeColor)
                              ]),
                          BodyMediumText(
                              _promotionController
                                  .selectedLocations[index].type,
                              color: AppColorConstants.subHeadingTextColor)
                        ]).vp(10).ripple(() {
                      _promotionController.selectLocations(
                          _promotionController.selectedLocations[index]);
                    });
                  },
                  itemCount: _promotionController.selectedLocations.length,
                ).hp(DesignConstants.horizontalPadding)
              : const SizedBox(),
          _promotionController.regionalLocations.isNotEmpty
              ? Heading6Text(searchedRegions.tr, weight: TextWeight.semiBold)
                  .hp(DesignConstants.horizontalPadding)
                  .tP16
              : const SizedBox(),
          _promotionController.regionalLocations.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 5),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyLargeText(_promotionController
                              .regionalLocations[index].fullName),
                          BodyMediumText(
                              _promotionController
                                  .regionalLocations[index].type,
                              color: AppColorConstants.subHeadingTextColor)
                        ]).vp(10).ripple(() {
                      _promotionController.selectLocations(
                          _promotionController.regionalLocations[index]);
                    });
                  },
                  itemCount: _promotionController.regionalLocations.length,
                ).hp(DesignConstants.horizontalPadding)
              : const SizedBox(),
        ])),
      )
    ]);
  }

  Widget localLocationView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: 250,
            child: google_map.GoogleMap(
              initialCameraPosition: const google_map.CameraPosition(
                target: google_map.LatLng(20.5937, 78.9629),
                zoom: 0,
              ),
              mapToolbarEnabled: false,
              zoomControlsEnabled: true,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              onMapCreated: (google_map.GoogleMapController controller) {
                _promotionController.mapController = controller;
                _goToCurrentLocation();
              },
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Heading6Text(
              yourCurrentLocation.tr,
              weight: FontWeight.normal,
            ),
            CupertinoSwitch(
              value: _promotionController.isLocationEnabled.value,
              onChanged: (value) =>
                  _promotionController.setCurrentLocation(value, () {
                _goToCurrentLocation();
              }),
            ).lP4,
          ],
        ).hp(DesignConstants.horizontalPadding).vP8,
        divider(height: 1, color: AppColorConstants.dividerColor),
        Heading5Text(
          radius.tr,
          weight: TextWeight.semiBold,
        ).hp(DesignConstants.horizontalPadding).vP8,
        SliderTheme(
            data: SliderTheme.of(context).copyWith(
                trackHeight: 3.0,
                valueIndicatorColor: Colors.transparent,
                valueIndicatorTextStyle:
                    TextStyle(color: AppColorConstants.mainTextColor),
                showValueIndicator: ShowValueIndicator.always),
            child: Slider(
              min: 0.0,
              max: 100.0,
              value: _promotionController.radius.value,
              activeColor: AppColorConstants.themeColor,
              inactiveColor: AppColorConstants.subHeadingTextColor,
              label: '${_promotionController.radius.value.toInt()} km',
              divisions: 100,
              onChanged: (value) => _promotionController.setRadiusRange(value),
            )).tP8,
      ],
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (_promotionController.latitude.value != null) {
      final google_map.CameraPosition kLake = google_map.CameraPosition(
          target: google_map.LatLng(_promotionController.latitude.value ?? 0.0,
              _promotionController.longitude.value ?? 0.0),
          tilt: 59,
          zoom: 5);
      _promotionController.mapController
          .animateCamera(google_map.CameraUpdate.newCameraPosition(kLake));
    }
  }
}
