import 'package:get/get.dart';
import '../../apiHandler/apis/misc_api.dart';
import '../../model/hash_tag.dart';
import 'package:foap/helper/list_extension.dart';

class MiscController extends GetxController {
  RxList<Hashtag> hashTags = <Hashtag>[].obs;
  int hashtagsPage = 1;
  bool canLoadMoreHashtags = true;
  bool hashtagsIsLoading = false;
  String _searchText = '';

  clear() {
    hashtagsPage = 1;
    canLoadMoreHashtags = true;
    hashtagsIsLoading = false;
    _searchText = '';
    hashTags.clear();
  }

  searchHashTags(String text) {
    _searchText = text;
    loadHashTags();
  }

  loadHashTags() {
    if (canLoadMoreHashtags) {
      hashtagsIsLoading = true;
      MiscApi.searchHashtag(
          hashtag: _searchText,
          page: hashtagsPage,
          resultCallback: (result, metadata) {
            hashTags.addAll(result);
            hashTags.unique((e)=> e.name);

            hashtagsIsLoading = false;
            hashtagsPage += 1;
            canLoadMoreHashtags = result.length >= metadata.perPage;
            update();
          });
    }
  }
}
