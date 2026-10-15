import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../api_handler/apis/users_api.dart';
import '../../manager/location_manager.dart';
import '../../model/location.dart';

class CustomMarker {
  String id;
  String name;
  String? address;
  double latitude;
  double longitude;
  BitmapDescriptor? icon;

  CustomMarker({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.icon,
  });

  factory CustomMarker.fromJson(Map<String, dynamic> json) {
    return CustomMarker(
      id: json['place_id'],
      name: json['name'],
      address: json['vicinity'],
      latitude: json['geometry']['location']['lat'],
      longitude: json['geometry']['location']['lng'],
    );
  }
}

class MapScreenController extends GetxController {
  RxList<google_map.Marker> markers = <google_map.Marker>[].obs;

  // RxList<CustomMarker> userLocations = <CustomMarker>[].obs;

  Rx<LocationModel?> currentLocation = Rx<LocationModel?>(null);
  final LocationManager _locationManager = Get.find();
  BitmapDescriptor? userMarkerIcon;

  RxInt selectedSegment = 0.obs;
  final UserProfileManager _userProfileManager = Get.find();

  clear() {
    markers.clear();
  }

  changeSegment(int segment) {
    selectedSegment.value = segment;
    if (segment == 0) {
      queryFollowers();
    } else if (segment == 1) {
      queryFollowingUsers();
    }
  }

  getLocation(Function(LocationModel) locationHandler) {
    _locationManager.getLocation(locationCallback: (locationData) {
      currentLocation.value = locationData;
      locationHandler(locationData);
      // update();
      queryFollowers();
    });
  }

  queryFollowers() async {
    markers.clear();
    await UsersApi.getFollowerUsers(
        resultCallback: (result, metadata) {
          createMarkersWithUsers(result);
        },
        userId: _userProfileManager.user.value!.id);
  }

  queryFollowingUsers() async {
    markers.clear();

    await UsersApi.getFollowingUsers(resultCallback: (result, metadata) {
      createMarkersWithUsers(result);
    });
  }

  createMarkersWithUsers(List<UserModel> users) async {
    for (UserModel userModel in users) {
      if (userModel.latitude != null) {
        String? imgUrl = userModel.picture;
        Uint8List bytes;

        if (imgUrl != null) {
          bytes = (await NetworkAssetBundle(Uri.parse(imgUrl)).load(imgUrl))
              .buffer
              .asUint8List();
          convertImageFileToCustomBitmapDescriptor(bytes,
              title: userModel.userName,
              size: 170,
              borderSize: 20,
              addBorder: true,
              borderColor: Colors.white)
              .then((result) {
            getMarkers(userModel, result);
          });
        } else {
          if (userMarkerIcon == null) {
            final ByteData bytesData =
            (await rootBundle.load('assets/account_selected.png'));
            bytes = bytesData.buffer.asUint8List();

            google_map.BitmapDescriptor.fromAssetImage(
                const ImageConfiguration(size: Size(12, 12)),
                'assets/account_selected.png')
                .then((icon) {
              userMarkerIcon = icon;
              getMarkers(userModel, icon);
            });
          } else {
            getMarkers(userModel, userMarkerIcon!);
          }
        }
      }
    }
  }

  getMarkers(UserModel userModel, google_map.BitmapDescriptor icon) {
    print('getMarkers  add markers');

    markers.add(google_map.Marker(
      //add first marker
      markerId: google_map.MarkerId(userModel.id.toString()),
      position: google_map.LatLng(double.parse(userModel.latitude!),
          double.parse(userModel.longitude!)),
      icon: icon,
      onTap: () {
        Get.to(() => OtherUserProfile(
          userId: userModel.id,
          user: userModel,
        ));
      },
    ));

    markers.refresh();
    update();
  }

  static Future<google_map.BitmapDescriptor>
  convertImageFileToCustomBitmapDescriptor(Uint8List imageUint8List,
      {int size = 150,
        bool addBorder = false,
        Color borderColor = Colors.white,
        double borderSize = 10,
        String? title,
        Color titleColor = Colors.white,
        Color titleBackgroundColor = Colors.black}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color;
    final TextPainter textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );
    final double radius = size / 2;

//make canvas clip path to prevent image drawing over the circle
    final Path clipPath = Path();
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        const Radius.circular(100)));
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        const Radius.circular(100)));
    canvas.clipPath(clipPath);

//paintImage
    final ui.Codec codec = await ui.instantiateImageCodec(imageUint8List);

    final ui.FrameInfo imageFI = await codec.getNextFrame();
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: imageFI.image);

    if (addBorder) {
//draw Border
      paint.color = borderColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = borderSize;
      canvas.drawCircle(Offset(radius, radius), radius, paint);
    }

    if (title != null) {
      if (title.length > 9) {
        title = title.substring(0, 9);
      }
//draw Title background
      paint.color = titleBackgroundColor;
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
              const Radius.circular(100)),
          paint);

//draw Title
      textPainter.text = TextSpan(
          text: title,
          style: TextStyle(
            fontSize: radius / 2.5,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ));
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(radius - textPainter.width / 2,
              size * 9.5 / 10 - textPainter.height / 2));
    }

//convert canvas as PNG bytes
    final image = await pictureRecorder
        .endRecording()
        .toImage(size, (size * 1.1).toInt());

    final data = await image.toByteData(format: ui.ImageByteFormat.png);

//convert PNG bytes as BitmapDescriptor
    return google_map.BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
