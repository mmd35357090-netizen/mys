import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_ip_address/get_ip_address.dart';

class DeviceInfo {
  String model = '';
  String osVersion = '';
  String ip = '';
  String deviceType = '';

  DeviceInfo();
}

class DeviceInfoManager {
  static DeviceInfo info = DeviceInfo();

  static collectDeviceInfo() async {
    var ipAddress = IpAddress(type: RequestType.json);
    dynamic data = await ipAddress.getIpAddress();
    String modelName = '';
    String osVersion = '';

    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      modelName = androidInfo.model;
    } else {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      modelName = iosInfo.name;
      osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
    }

    info.ip = data['ip'];
    info.model = modelName;
    info.osVersion = osVersion;
    info.deviceType = Platform.isAndroid ? '1' : '2';
  }
}
