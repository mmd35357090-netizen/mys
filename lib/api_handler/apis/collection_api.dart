import 'package:foap/api_handler/api_wrapper.dart';
import '../../model/collection_model.dart';

class CollectionApi {
  static getCollections(
      {required Function(List<CollectionModel>) resultCallback}) async {
    await ApiWrapper()
        .getApi(url: NetworkConstantsUtil.collections)
        .then((result) {
      if (result?.success == true) {
        var items = result!.data['collection'];
        if (items is List) {
          resultCallback(
              items.map((x) => CollectionModel.fromJson(x)).toList());
        } else {
          resultCallback([]);
        }
      }
    });
  }

  static createCollection(
      {required String name,
      required Function(bool, String?) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.collections,
        param: {"name": name}).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }

  static deleteCollection(
      {required int id, required Function(bool) resultCallback}) async {
    await ApiWrapper()
        .deleteApi(url: '${NetworkConstantsUtil.collections}/$id')
        .then((result) {
      resultCallback(result?.success == true);
    });
  }

  static addPost(
      {required int collectionId,
      required int postId,
      required Function(bool, String?) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.collectionAddPost,
        param: {
          "collection_id": collectionId.toString(),
          "post_id": postId.toString()
        }).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }

  static removePost(
      {required int itemId, required Function(bool) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.collectionRemovePost,
        param: {"id": itemId.toString()}).then((result) {
      resultCallback(result?.success == true);
    });
  }
}
