import '../helper/user_profile_manager.dart';
import 'package:get/get.dart';

class FeatureModel {
  String? featureKey;
  bool isActive;

  FeatureModel({
    required this.featureKey,
    required this.isActive,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) => FeatureModel(
        featureKey: json["feature_key"],
        isActive: json["is_active"] == 1,
      );
}

class SettingModel {
  String? siteName;
  String? email;
  String? phone;
  String? inAppPurchaseId;
  int? isUploadImage;
  int? isUploadVideo;
  int? uploadMaxFile;
  String? facebook;
  String? youtube;
  String? twitter;
  String? linkedin;
  String? pinterest;
  String? instagram;
  String? siteUrl;
  int watchVideoRewardCoins;
  String? latestVersion;
  String? maximumVideoDurationAllowed;
  String? freeLiveTvDurationToView;
  String? latestAppDownloadLink;
  String? disclaimerUrl;
  String? privacyPolicyUrl;
  String? termsOfServiceUrl;
  String? giphyApiKey;

  String? agoraApiKey;
  String? interstitialAdUnitIdForAndroid;
  String? interstitialAdUnitIdForiOS;
  String? rewardInterstitlAdUnitIdForAndroid;
  String? rewardInterstitialAdUnitIdForiOS;
  String? bannerAdUnitIdForAndroid;
  String? bannerAdUnitIdForiOS;
  String? fbInterstitialAdUnitIdForAndroid;
  String? fbInterstitialAdUnitIdForiOS;
  String? fbRewardInterstitialAdUnitIdForAndroid;
  String? fbRewardInterstitialAdUnitIdForiOS;
  String? networkToUse;
  String? stripePublishableKey;
  String? razorpayKey;
  String? imglyApiKey;

  int minWithdrawLimit;
  int minCoinsWithdrawLimit;
  double coinsValue;
  double serviceFee;

  String? pid;
  String? chatGPTKey;

  String? themeColor;
  String? bgColorForLightTheme;
  String? bgColorForDarkTheme;
  String? textColorForLightTheme;
  String? textColorForDarkTheme;
  String? font;
  List<FeatureModel> features = [];
  String? iosAppLink;
  String? androidAppLink;

  SettingModel(
      {required this.email,
      required this.phone,
      required this.facebook,
      required this.youtube,
      required this.twitter,
      required this.linkedin,
      required this.pinterest,
      required this.instagram,
      required this.watchVideoRewardCoins,
      required this.latestVersion,
      required this.minWithdrawLimit,
      required this.minCoinsWithdrawLimit,
      required this.coinsValue,
      this.pid,
      required this.siteName,
      required this.inAppPurchaseId,
      required this.isUploadImage,
      required this.isUploadVideo,
      required this.uploadMaxFile,
      required this.siteUrl,
      required this.maximumVideoDurationAllowed,
      required this.freeLiveTvDurationToView,
      required this.latestAppDownloadLink,
      required this.disclaimerUrl,
      required this.privacyPolicyUrl,
      required this.termsOfServiceUrl,
      required this.giphyApiKey,
      required this.agoraApiKey,
// required this.googleMapApiKey,
      required this.interstitialAdUnitIdForAndroid,
      required this.interstitialAdUnitIdForiOS,
      required this.rewardInterstitlAdUnitIdForAndroid,
      required this.rewardInterstitialAdUnitIdForiOS,
      required this.bannerAdUnitIdForAndroid,
      required this.bannerAdUnitIdForiOS,
      required this.fbInterstitialAdUnitIdForAndroid,
      required this.fbInterstitialAdUnitIdForiOS,
      required this.fbRewardInterstitialAdUnitIdForAndroid,
      required this.fbRewardInterstitialAdUnitIdForiOS,
      required this.networkToUse,
      required this.serviceFee,
      required this.stripePublishableKey,
      required this.razorpayKey,
      required this.imglyApiKey,
      required this.chatGPTKey,
      required this.font,
      required this.themeColor,
      required this.bgColorForLightTheme,
      required this.bgColorForDarkTheme,
      required this.textColorForLightTheme,
      required this.textColorForDarkTheme,
      required this.features,
      this.iosAppLink,
      this.androidAppLink});

  factory SettingModel.fromJson(Map<String, dynamic> json) => SettingModel(
      email: json["email"],
      phone: json["phone"],
      facebook: json["facebook"],
      youtube: json["youtube"],
      twitter: json["twitter"],
      linkedin: json["linkedin"],
      pinterest: json["pinterest"],
      instagram: json["instagram"],
      latestVersion: json["release_version"],
      watchVideoRewardCoins: json["each_view_coin"] ?? 0,
      minWithdrawLimit: json["min_widhdraw_price"] ?? 0,
      minCoinsWithdrawLimit: json["min_coin_redeem"] ?? 0,
      coinsValue: double.parse(json["per_coin_value"].toString()),
      pid: json["user_p_id"],
      siteName: json["site_name"],
      inAppPurchaseId: json["in_app_purchase_id"],
      isUploadImage: json["is_upload_image"],
      isUploadVideo: json["is_upload_video"],
      uploadMaxFile: json["upload_max_file"],
      siteUrl: json["site_url"],
      maximumVideoDurationAllowed: json["maximum_video_duration_allowed"],
      freeLiveTvDurationToView: json["free_live_tv_duration_to_view"],
      latestAppDownloadLink: json["latest_app_download_link"],
      disclaimerUrl: json["disclaimer_url"],
      privacyPolicyUrl: json["privacy_policy_url"],
      termsOfServiceUrl: json["terms_of_service_url"],
      giphyApiKey: json["giphy_api_key"],
      agoraApiKey: json["agora_api_key"],
// googleMapApiKey: json["google_map_api_key"],
      interstitialAdUnitIdForAndroid:
          json["interstitial_ad_unit_id_for_android"],
      interstitialAdUnitIdForiOS: json["interstitial_ad_unit_id_for_IOS"],
      rewardInterstitlAdUnitIdForAndroid:
          json["reward_Interstitl_ad_unit_id_for_android"],
      rewardInterstitialAdUnitIdForiOS:
          json["reward_interstitial_ad_unit_id_for_IOS"],
      bannerAdUnitIdForAndroid: json["banner_ad_unit_id_for_android"],
      bannerAdUnitIdForiOS: json["banner_ad_unit_id_for_IOS"],
      fbInterstitialAdUnitIdForAndroid:
          json["fb_interstitial_ad_unit_id_for_android"],
      fbInterstitialAdUnitIdForiOS: json["fb_interstitial_ad_unit_id_for_IOS"],
      fbRewardInterstitialAdUnitIdForAndroid:
          json["fb_reward_interstitial_ad_unit_id_for_android"],
      fbRewardInterstitialAdUnitIdForiOS:
          json["fb_reward_interstitial_ad_unit_id_for_IOS"],
      networkToUse: json["network_to_use"],
      serviceFee: json["serviceFee"] ?? 5,
      stripePublishableKey: json["stripe_publishable_key"],
      razorpayKey: json["razorpay_api_key"],
      themeColor: json["theme_color"] ?? '4169e1',
      bgColorForLightTheme: json["theme_light_background_color"] ?? 'FFFFFF',
      bgColorForDarkTheme: json["theme_dark_background_color"] ?? '000000',
      textColorForLightTheme: json["theme_light_text_color"] ?? '000000',
      textColorForDarkTheme: json["theme_dark_text_color"] ?? 'FFFFFF',
      font: json["theme_font"],
      chatGPTKey: json["chat_gpt_key"],
      imglyApiKey: json["imgly_key"],
      iosAppLink: json["iosAppLink"] ?? 'ios app link',
      androidAppLink: json["androidAppLink"] ?? 'android app ink',
      features: (json["featureList"] as List)
          .map((e) => FeatureModel.fromJson(e))
          .toList());

  bool getFeatureAvailabilityStatus(String featureName) {
    UserProfileManager userProfileManager = Get.find();

    if (userProfileManager.user.value == null) {
      return false;
    }

    List<FeatureModel> matchedFeatures =
        features.where((element) => element.featureKey == featureName).toList();

    if (matchedFeatures.isEmpty) {
      return false;
    }
    if (matchedFeatures.first.isActive == false) {
      return false;
    }
    List<FeatureModel> matchedFeaturesForUser = userProfileManager
        .user.value!.features
        .where((element) => element.featureKey == featureName)
        .toList();
    if (matchedFeaturesForUser.isEmpty) {
      return false;
    }

    return matchedFeaturesForUser.first.isActive;
  }

  bool get enableChatGPT {
    return getFeatureAvailabilityStatus('chat_gpt');
  }

  bool get enableImagePost {
    return getFeatureAvailabilityStatus('enable_photo_post');
  }

  bool get enableVideoPost {
    return getFeatureAvailabilityStatus('enable_video_post');
  }

  bool get enableStories {
    return getFeatureAvailabilityStatus('enable_story');
  }

  bool get enableHighlights {
    return getFeatureAvailabilityStatus('enable_story_highlights');
  }

  bool get enableChat {
    return getFeatureAvailabilityStatus('enable_chat');
  }

  bool get enableLocationSharingInChat {
    return getFeatureAvailabilityStatus('location_share');
  }

  bool get enablePhotoSharingInChat {
    return getFeatureAvailabilityStatus('photo_sharing');
  }

  bool get enableContactSharingInChat {
    return getFeatureAvailabilityStatus('contact_share');
  }

  bool get enableVideoSharingInChat {
    return getFeatureAvailabilityStatus('video_share');
  }

  bool get enableAudioSharingInChat {
    return getFeatureAvailabilityStatus('audio_share');
  }

  bool get enableFileSharingInChat {
    return getFeatureAvailabilityStatus('file_Share');
  }

  bool get enableGifSharingInChat {
    return getFeatureAvailabilityStatus('gif_share');
  }

  bool get enableDrawingSharingInChat {
    return getFeatureAvailabilityStatus('drawing_share');
  }

  bool get enableClubSharingInChat {
    return getFeatureAvailabilityStatus('club_share');
  }

  bool get enableProfileSharingInChat {
    return getFeatureAvailabilityStatus('user_profile_share');
  }

  bool get enableReplyInChat {
    return getFeatureAvailabilityStatus('reply');
  }

  bool get enableForwardingInChat {
    return getFeatureAvailabilityStatus('forward');
  }

  bool get enableStarMessage {
    return getFeatureAvailabilityStatus('star_message');
  }

  bool get enableAudioCalling {
    return getFeatureAvailabilityStatus('enable_audio_calling') && agoraApiKey!.isNotEmpty;
  }

  bool get enableVideoCalling {
    return getFeatureAvailabilityStatus('enable_video_calling') && agoraApiKey!.isNotEmpty;
  }

  bool get enableLive {
    return getFeatureAvailabilityStatus('enable_live') && agoraApiKey!.isNotEmpty;
  }

  bool get enableClubs {
    return getFeatureAvailabilityStatus('enable_clubs');
  }

  bool get enableCompetitions {
    return getFeatureAvailabilityStatus('enable_competitions');
  }

  bool get enableEvents {
    return getFeatureAvailabilityStatus('enable_events');
  }

  bool get enableStrangerChat {
    return getFeatureAvailabilityStatus('enable_staranger_chat');
  }

  bool get enableProfileVerification {
    return getFeatureAvailabilityStatus('enable_profile_verification');
  }

  bool get enableDarkLightModeSwitch {
    return getFeatureAvailabilityStatus('enable_dark_light_mode_switching');
  }

  bool get enableWatchTv {
    return getFeatureAvailabilityStatus('enable_watch_tv');
  }

  bool get enablePodcasts {
    return getFeatureAvailabilityStatus('enable_podcasts');
  }

  bool get enableGift {
    return getFeatureAvailabilityStatus('enable_gift_sending');
  }

  bool get enablePostPhotoVideoEdit {
    return getFeatureAvailabilityStatus('photo_video_editable');
  }

  bool get enablePolls {
    return getFeatureAvailabilityStatus('polls');
  }

  bool get enableFundRaising {
    return getFeatureAvailabilityStatus('enable_fund_raising');
  }

  bool get enableOffers {
    return getFeatureAvailabilityStatus('offer');
  }

  bool get enableJobs {
    return getFeatureAvailabilityStatus('job');
  }

  bool get enableShop {
    return getFeatureAvailabilityStatus('shop');
  }

  bool get enableLiveUserListing {
    return getFeatureAvailabilityStatus('live_user');
  }

  bool get enableReel {
    return getFeatureAvailabilityStatus('reel');
  }

  bool get enableDating {
    return getFeatureAvailabilityStatus('dating');
  }

  bool get canEditPhotoVideo {
    return enablePostPhotoVideoEdit;
  }
}
