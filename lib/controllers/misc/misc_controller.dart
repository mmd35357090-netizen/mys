import 'package:foap/model/data_wrapper.dart';
import 'package:get/get.dart';
import '../../api_handler/apis/misc_api.dart';
import '../../helper/enum.dart';
import '../../model/hash_tag.dart';
import 'package:foap/helper/list_extension.dart';
import '../../model/rating_model.dart';

class MiscController extends GetxController {
  RxList<Hashtag> hashTags = <Hashtag>[].obs;
  RxList<RatingModel> ratings = <RatingModel>[].obs;

  DataWrapper hashtagDataWrapper = DataWrapper();

  String _searchText = '';

  clear() {
    hashtagDataWrapper = DataWrapper();
    _searchText = '';
    hashTags.clear();
  }

  searchHashTags(String text) {
    clear();
    _searchText = text;
    loadHashTags();
  }

  loadHashTags() {
    if (hashtagDataWrapper.haveMoreData.value) {
      hashtagDataWrapper.isLoading.value = true;
      MiscApi.searchHashtag(
          hashtag: _searchText,
          page: hashtagDataWrapper.page,
          resultCallback: (result, metadata) {
            hashTags.addAll(result);
            hashTags.unique((e) => e.name);
            hashtagDataWrapper.processCompletedWithData(metadata);
            update();
          });
    }
  }

  addToPin(PinContentType type, int refId, Function(int) successHandler) {
    MiscApi.pinContent(type: type, refId: refId, successHandler: successHandler);
  }

  removeFromPin(PinContentType type, int refId) {
    MiscApi.removePinContent(type: type, refId: refId);
  }
}
