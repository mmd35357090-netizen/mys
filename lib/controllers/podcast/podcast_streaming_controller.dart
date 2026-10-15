import 'dart:ui';

import 'package:foap/api_handler/apis/podcast_api.dart';
import 'package:foap/components/loader.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/screens/add_on/model/podcast_banner_model.dart';
import 'package:foap/screens/add_on/model/podcast_model.dart';
import 'package:get/get.dart';

import '../../helper/localization_strings.dart';

class PodcastStreamingController extends GetxController {
  RxList<PodcastBannerModel> banners = <PodcastBannerModel>[].obs;
  RxList<PodcastCategoryModel> categories = <PodcastCategoryModel>[].obs;

  RxList<HostModel> hosts = <HostModel>[].obs;
  RxList<PodcastModel> podcasts = <PodcastModel>[].obs;
  RxList<PodcastEpisodeModel> podcastEpisodes = <PodcastEpisodeModel>[].obs;

  Rx<PodcastModel?> podcastDetail = Rx<PodcastModel?>(null);
  Rx<HostModel?> hostDetail = Rx<HostModel?>(null);

  int hostsPage = 1;
  bool canLoadMoreHosts = true;
  RxBool isLoadingHosts = false.obs;
  RxInt totalHostsFound = 0.obs;

  int podcastsPage = 1;
  bool canLoadMorePodcasts = true;
  RxBool isLoadingPodcasts = false.obs;
  RxInt totalPodcastFound = 0.obs;

  int podcastEpisodePage = 1;
  bool canLoadMorePodcastEpisode = true;
  RxBool isLoadingPodcastEpisodes = false.obs;

  PodcastSearchModel podcastSearchModel = PodcastSearchModel();
  HostSearchModel hostSearchModel = HostSearchModel();

  clearCategories() {
    update();
  }

  clearBanners() {
    banners.clear();
    update();
  }

  clearPodcastEpisodes() {
    podcastEpisodes.clear();
    podcastEpisodePage = 1;
    canLoadMorePodcastEpisode = true;
  }

  clearPodcastSearch() {
    podcastSearchModel = PodcastSearchModel();
  }

  clearHostSearch() {
    hostSearchModel = HostSearchModel();
  }

  clearPodcasts() {
    podcasts.clear();
    podcastsPage = 1;
    canLoadMorePodcasts = true;
    totalPodcastFound.value = 0;
  }

  clearHosts() {
    hosts.clear();
    hostsPage = 1;
    canLoadMoreHosts = true;
    totalHostsFound.value = 0;

    update();
  }

  setPodcastHostId(int? id) {
    clearPodcasts();
    podcastSearchModel.hostId = id;
    getPodcasts(callback: () {});
  }

  setPodcastCategoryId(int? id) {
    clearPodcasts();
    podcastSearchModel.categoryId = id;
    getPodcasts(callback: () {});
  }

  setPodcastName(String? name) {
    clearPodcasts();
    podcastSearchModel.name = name;
    getPodcasts(callback: () {});
  }

  setHostName(String? name) {
    clearHosts();
    hostSearchModel.name = name;
    getHosts(callback: () {});
  }

  getPodcastCategories() {
    PodcastApi.getPodcastCategories(resultCallback: (result) {
      categories.value = result;
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

  getHosts({required VoidCallback callback}) {
    if (canLoadMoreHosts) {
      PodcastApi.getHostsList(
          page: hostsPage,
          searchModel: hostSearchModel,
          resultCallback: (result, metadata) {
            hosts.value = result;
            hosts.unique((e) => e.id);
            canLoadMoreHosts = result.length >= metadata.perPage;
            totalHostsFound.value = metadata.totalCount;

            if (canLoadMoreHosts) {
              hostsPage += 1;
            }

            update();
            callback();
          });
    } else {
      callback();
    }
  }

  getPodcasts({required VoidCallback callback}) {
    if (canLoadMorePodcasts) {
      PodcastApi.getPodcasts(
          page: podcastsPage,
          searchModel: podcastSearchModel,
          resultCallback: (result, metadata) {
            podcasts.value = result;

            podcasts.unique((e) => e.id);
            canLoadMorePodcasts = result.length >= metadata.perPage;
            totalPodcastFound.value = metadata.totalCount;

            if (canLoadMorePodcasts) {
              podcastsPage += 1;
            }

            callback();
            update();
          });
    } else {
      callback();
    }
  }

  getPodcastEpisode(
      {int? podcastId, String? name, required VoidCallback callback}) async {
    if (canLoadMorePodcastEpisode) {
      PodcastApi.getPodcastEpisode(
          page: podcastEpisodePage,
          podcastId: podcastId,
          name: name,
          resultCallback: (result, metadata) {
            podcastEpisodes.value = result;
            podcastEpisodes.unique((e) => e.id);
            canLoadMorePodcastEpisode = result.length >= metadata.perPage;
            if (canLoadMorePodcastEpisode) {
              podcastEpisodePage += 1;
            }

            callback();
            update();
          });
    } else {
      callback();
    }
  }

  getPodcastById(int id, Function(PodcastModel) completionCallBack) {
    Loader.show(status: loadingString.tr);

    PodcastApi.getPodcastById(
        id: id,
        resultCallback: (result) {
          Loader.dismiss();
          podcastDetail.value = result;
          update();
          completionCallBack(result);
        });
  }

  getHostById(int hostId, Function(HostModel) completionCallBack) {
    Loader.show(status: loadingString.tr);

    PodcastApi.getPodcastHostById(
        hostId: hostId,
        resultCallback: (result) {
          Loader.dismiss();

          hostDetail.value = result;
          update();
          completionCallBack(result);
        });
  }
}
