import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:foap/controllers/misc/map_screen_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import '../../helper/imports/common_import.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    as google_map;

// ignore: must_be_immutable
class MapsUsersScreen extends StatefulWidget {
  UserModel? currentUser;

  MapsUsersScreen({super.key, this.currentUser});

  @override
  State<MapsUsersScreen> createState() => _MapsUsersScreenState();
}

class _MapsUsersScreenState extends State<MapsUsersScreen> {
  late google_map.GoogleMapController mapController;
  final MapScreenController _mapScreenController = MapScreenController();

  // google_map.CameraPosition? kGooglePlex;
  BitmapDescriptor? customMarker;
  List<CustomMarker> locations = [];

  @override
  void initState() {
    _mapScreenController.getLocation((p0) => () {});
    super.initState();
  }

  @override
  void dispose() {
    locations.clear();
    _mapScreenController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Stack(
          children: [
            Obx(() {
              return _mapScreenController.currentLocation.value == null
                  ? const Center(child: CircularProgressIndicator())
                  : followersMapView();
            }),
            appBar(),
            Positioned(
              top: 100,
              left: DesignConstants.horizontalPadding,
              right: DesignConstants.horizontalPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: AppColorConstants.themeColor
                        .withValues(alpha: 0.7),
                    child: Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              color: _mapScreenController
                                          .selectedSegment.value ==
                                      0
                                  ? AppColorConstants.themeColor
                                  : Colors.transparent,
                              child: BodyLargeText(
                                followersString.tr,
                                weight: _mapScreenController
                                            .selectedSegment.value ==
                                        0
                                    ? TextWeight.bold
                                    : TextWeight.medium,
                                color: _mapScreenController
                                            .selectedSegment.value ==
                                        0
                                    ? Colors.white
                                    : AppColorConstants.mainTextColor,
                              ).p(10),
                            ).ripple(() {
                              _mapScreenController.changeSegment(0);
                            }),
                            const Heading6Text('|'),
                            Container(
                              color: _mapScreenController
                                          .selectedSegment.value ==
                                      1
                                  ? AppColorConstants.themeColor
                                  : Colors.transparent,
                              child: BodyLargeText(
                                followingString.tr,
                                color: _mapScreenController
                                            .selectedSegment.value ==
                                        1
                                    ? Colors.white
                                    : AppColorConstants.mainTextColor,
                                weight: _mapScreenController
                                            .selectedSegment.value ==
                                        1
                                    ? TextWeight.bold
                                    : TextWeight.medium,
                              ).p(10),
                            ).ripple(() {
                              _mapScreenController.changeSegment(1);
                            }),
                          ],
                        )),
                  ).round(50),
                ],
              ),
            )
          ],
        ));
  }

  Widget followersMapView() {
    return Obx(() => google_map.GoogleMap(
          mapType: google_map.MapType.terrain,
          markers: _mapScreenController.markers.toSet(),
          initialCameraPosition: google_map.CameraPosition(
            target: google_map.LatLng(
                _mapScreenController.currentLocation.value!.latitude,
                _mapScreenController.currentLocation.value!.longitude),
            zoom: 0,
          ),
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          onMapCreated: (google_map.GoogleMapController controller) {
            mapController = controller;
            _goToCurrentLocation();
          },
        ));
  }

  Future<void> _goToCurrentLocation() async {
    final google_map.CameraPosition kLake = google_map.CameraPosition(
        target: google_map.LatLng(
            _mapScreenController.currentLocation.value!.latitude,
            _mapScreenController.currentLocation.value!.longitude),
        tilt: 59,
        zoom: 5);
    final google_map.GoogleMapController controller = mapController;
    controller
        .animateCamera(google_map.CameraUpdate.newCameraPosition(kLake));
  }

  Widget appBar() {
    return Positioned(
      child: Container(
        height: 150.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black.withValues(alpha: 0.5),
                  Colors.grey.withValues(alpha: 0.0),
                ],
                stops: const [
                  0.0,
                  0.5,
                  1.0
                ])),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 20,
              color: Colors.white,
            ).ripple(() {
              Get.back();
            }),
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }
}
