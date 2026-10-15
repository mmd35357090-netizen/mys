import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

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

    info.ip = await IPAddressFetcher.getIPAddress() ?? '';
    info.model = modelName;
    info.osVersion = osVersion;
    info.deviceType = Platform.isAndroid ? '1' : '2';
  }
}

class IPAddressFetcher {
  static Future<String?> getIPAddress() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
    return null;
  }
}
