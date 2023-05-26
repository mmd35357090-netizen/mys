import 'package:foap/apiHandler/api_wrapper.dart';

import '../../model/category_model.dart';
import '../../screens/add_on/model/podcast_banner_model.dart';
import '../../screens/add_on/model/podcast_model.dart';

class PodcastApi {
  static getPodcastBanners(
      {required Function(List<PodcastBannerModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.podcastBanners;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var podcastBanners = result!.data['podcast_banner'];
        var items = podcastBanners['items'];
          if (url == NetworkConstantsUtil.podcastBanners) {
            resultCallback(List<PodcastBannerModel>.from(
                items.map((x) => PodcastBannerModel.fromJson(x))));

        }
      }
    });
  }

  static getPodcastCategories(
      {required Function(List<PodcastCategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getPodcastCategories;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {}
      var items = result!.data['category'];

      resultCallback(List<PodcastCategoryModel>.from(
          items.map((x) => PodcastCategoryModel.fromJson(x))));
    });
  }

  static getPodcastList(
      {int? categoryId,
      String? name,
      required Function(List<PodcastModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getHosts;

    if (categoryId != null) {
      url = '$url&category_id=$categoryId';
    }
    if (name != null) {
      url = '$url&name=$name';
    }

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var podcasts = result!.data['podcast'];
        var items = podcasts['items'];
          resultCallback(List<PodcastModel>.from(
              items.map((x) => PodcastModel.fromJson(x))));

      }
    });
  }

  static getPodcastShows(
      {int? podcastId,
      String? name,
      required Function(List<PodcastShowModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getPodcastShows;

    if (podcastId != null) {
      url = '$url&podcast_channel_id=$podcastId';
    }
    if (name != null) {
      url = '$url&name=$name';
    }

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var podcasts = result!.data['podcast_show'];
        var items = podcasts['items'];
          resultCallback(List<PodcastShowModel>.from(
              items.map((x) => PodcastShowModel.fromJson(x))));
        }

    });
  }

  static getPodcastShowsEpisode(
      {int? podcastShowId,
      String? name,
      required Function(List<PodcastShowEpisodeModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getPodcastShowsEpisode;

    if (podcastShowId != null) {
      url = '$url&podcast_show_id=$podcastShowId';
    }
    if (name != null) {
      url = '$url&name=$name';
    }

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var showEpisodes = result!.data['podcastShowEpisode'];
        var items = showEpisodes['items'];
          if (url == NetworkConstantsUtil.getPodcastShowsEpisode) {
            resultCallback(List<PodcastShowEpisodeModel>.from(
                items.map((x) => PodcastShowEpisodeModel.fromJson(x))));

        }
      }
    });
  }

  static getPodcastShowById(
      {int? showId, required Function(PodcastShowModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getHostShowById;

    if (showId != null) {
      url = '$url&id=$showId';
    }
    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var showDetails = result!.data['podcastShowDetails'];
        resultCallback(PodcastShowModel.fromJson(showDetails));
      }
    });
  }

  static getPodcastHostById(
      {required int hostId,
      required Function(PodcastModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getPodcastHostDetail
        .replaceAll('{{host_id}}', hostId.toString());

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var showDetails = result!.data['podcastHostDetails'];
        resultCallback(PodcastModel.fromJson(showDetails));
      }
    });
  }
}
