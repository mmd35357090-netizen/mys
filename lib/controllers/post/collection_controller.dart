import 'package:foap/helper/imports/common_import.dart';
import '../../api_handler/apis/collection_api.dart';
import '../../model/collection_model.dart';

class CollectionController extends GetxController {
  RxList<CollectionModel> collections = <CollectionModel>[].obs;
  RxBool isLoading = false.obs;

  loadCollections() {
    isLoading.value = true;
    CollectionApi.getCollections(resultCallback: (result) {
      collections.value = result;
      isLoading.value = false;
    });
  }

  createCollection(String name, {Function(bool)? completion}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      completion?.call(false);
      return;
    }
    CollectionApi.createCollection(
        name: trimmed,
        resultCallback: (success, message) {
          if (success) {
            loadCollections();
          } else {
            AppUtil.showToast(message: message ?? '', isSuccess: false);
          }
          completion?.call(success);
        });
  }

  deleteCollection(CollectionModel collection) {
    CollectionApi.deleteCollection(
        id: collection.id,
        resultCallback: (success) {
          if (success) {
            collections.removeWhere((e) => e.id == collection.id);
          }
        });
  }

  addPostToCollection(CollectionModel collection, int postId) {
    CollectionApi.addPost(
        collectionId: collection.id,
        postId: postId,
        resultCallback: (success, message) {
          AppUtil.showToast(
              message: success ? addedToCollectionString.tr : (message ?? ''),
              isSuccess: success);
          if (success) loadCollections();
        });
  }

  removePostFromCollection(CollectionModel collection, CollectionItemModel item) {
    CollectionApi.removePost(
        itemId: item.id,
        resultCallback: (success) {
          if (success) {
            collection.items.removeWhere((e) => e.id == item.id);
            collections.refresh();
          }
        });
  }
}
