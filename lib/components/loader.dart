import 'package:flutter_easyloading/flutter_easyloading.dart';

class Loader {
  static void show({String? status}) {
    EasyLoading.show(status: status);
  }

  static void dismiss() {
    EasyLoading.dismiss();
  }
}
