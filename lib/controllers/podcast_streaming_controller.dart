import 'package:foap/apiHandler/apis/podcast_api.dart';
import 'package:foap/model/category_model.dart';
import 'package:foap/screens/add_on/model/podcast_banner_model.dart';
import 'package:foap/screens/add_on/model/podcast_model.dart';
import 'package:get/get.dart';

class PodcastStreamingController extends GetxController {
  RxList<PodcastBannerModel> banners = <PodcastBannerModel>[].obs;
  RxList<PodcastCategoryModel> categories = <PodcastCategoryModel>[].obs;
  RxList<PodcastModel> podcasts = <PodcastModel>[].obs;
  RxList<PodcastShowModel> podcastShows = <PodcastShowModel>[].obs;
  RxList<PodcastShowEpisodeModel> podcastShowEpisodes =
      <PodcastShowEpisodeModel>[].obs;

  Rx<PodcastShowModel?> showDetail = Rx<PodcastShowModel?>(null);
  Rx<PodcastModel?> hostDetail = Rx<PodcastModel?>(null);

  clearCategories() {
    categories.clear();
    update();
  }

  clearBanners() {
    banners.clear();
    update();
  }

  clearPodcast() {
    podcasts.clear();
    update();
  }

  getPodcastCategories() {
    PodcastApi.getPodcastCategories(resultCallback: (result) {
      categories.value =
          result.where((element) => element.podcasts.isNotEmpty).toList();
      categories.refresh();
      update();
    });
  }

  getPodcastBanners() {
    PodcastApi.getPodcastBanners(resultCallback: (result) {
      banners.value = result;
      update();
    });
  }

  getPodCastList({int? categoryId, String? name}) {
    PodcastApi.getPodcastList(
        categoryId: categoryId,
        name: name,
        resultCallback: (result) {
          podcasts.value = result;
          update();
        });
  }

  getPodcastShows({int? podcastId, String? name}) {
    PodcastApi.getPodcastShows(
        podcastId: podcastId,
        name: name,
        resultCallback: (result) {
          podcastShows.value = result;
          podcastShows.refresh();
          update();
        });
  }

  getPodcastShowsEpisode({int? podcastShowId, String? name}) async {
    PodcastApi.getPodcastShowsEpisode(
        podcastShowId: podcastShowId,
        name: name,
        resultCallback: (result) {
          podcastShowEpisodes.value = result;
          podcastShowEpisodes.refresh();
          update();
        });
  }

  getPodcastShowById(int showId, Function() completionCallBack) {
    PodcastApi.getPodcastShowById(
        showId: showId,
        resultCallback: (result) {
          showDetail.value = result;
          update();
          completionCallBack();
        });
  }

  getHostById(int hostId, Function() completionCallBack) {
    PodcastApi.getPodcastHostById(
        hostId: hostId,
        resultCallback: (result) {
          hostDetail.value = result;
          update();
          completionCallBack();
        });
  }
}
