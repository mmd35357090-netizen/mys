import 'package:foap/api_handler/api_wrapper.dart';
import '../../screens/add_on/model/dating_package_model.dart';

class DatingPackageApi {
  static getPackages(
      {required Function(List<DatingPackageModel>) resultCallback}) async {
    await ApiWrapper()
        .getApi(url: NetworkConstantsUtil.datingPackages)
        .then((result) {
      if (result?.success == true) {
        var items = result!.data['datingPackage'];
        if (items is List) {
          resultCallback(
              items.map((e) => DatingPackageModel.fromJson(e)).toList());
        } else {
          resultCallback([]);
        }
      }
    });
  }

  static subscribe(
      {required int packageId,
      required Function(bool, String?) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.subscribeDatingPackage,
        param: {"dating_subscription_id": packageId.toString()}).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }
}
