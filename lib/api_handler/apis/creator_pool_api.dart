import '../../helper/imports/common_import.dart';
import '../api_wrapper.dart';

class CreatorPoolApi {
  /// Tells the server that a feed ad was shown next to this post (used for the creator revenue share).
  /// It must never disturb the app, so every error is ignored.
  static void reportAdImpression({required int postId}) {
    try {
      ApiWrapper()
          .postApi(
              url: NetworkConstantsUtil.creatorAdImpression,
              param: {'post_id': postId.toString()})
          .then((_) {})
          .catchError((_) {});
    } catch (_) {}
  }
}
