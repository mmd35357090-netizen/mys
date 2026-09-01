import 'package:easy_audience_network/easy_audience_network.dart'
as fb_audience;

import 'package:foap/helper/imports/common_import.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../screens/settings_menu/settings_controller.dart';
import 'ad_network_keys.dart';

class AdNetworkHelper {}

//ignore: must_be_immutable
class RewardedInterstitialAds {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  SettingsController settingsController = Get.find();

  void show(VoidCallback onRewarded) {
    if (int.parse(settingsController.setting.value!.networkToUse!) == 1) {
      final rewardedAd = fb_audience.RewardedAd(
        FacebookAudienceNetworkKeys().rewardInterstitialAdUnitId,
        userId: 'some_user_id', // optional for server side verification
      );
      rewardedAd.listener = fb_audience.RewardedAdListener(
        onLoaded: () {
          rewardedAd.show();
        },
        onVideoComplete: () {
          rewardedAd.destroy();
          onRewarded();
        },
      );
      rewardedAd.load();
    } else {
      RewardedInterstitialAd.load(
          adUnitId: AdmobKeys().rewardInterstitialAdUnitId,
          request: const AdRequest(),
          rewardedInterstitialAdLoadCallback:
          RewardedInterstitialAdLoadCallback(
            onAdLoaded: (RewardedInterstitialAd ad) {
              // Keep a reference to the ad so you can show it later.
              _rewardedInterstitialAd = ad;
              _rewardedInterstitialAd?.show(onUserEarnedReward:
                  (AdWithoutView ad, RewardItem rewardItem) {
                // Reward the user for watching an ad.
                onRewarded();
              });
            },
            onAdFailedToLoad: (LoadAdError error) {
              // print('RewardedInterstitialAd failed to load: $error');
            },
          ));
    }
  }
}

//ignore: must_be_immutable
class InterstitialAds {
  InterstitialAd? _interstitialAd;
  SettingsController settingsController = Get.find();

  void show() {
    if (settingsController.setting.value!.networkToUse == '1') {
      final interstitialAd = fb_audience.InterstitialAd(
          FacebookAudienceNetworkKeys().interstitialAdUnitId);
      interstitialAd.listener = fb_audience.InterstitialAdListener(
        onLoaded: () {
          interstitialAd.show();
        },
        onDismissed: () {
          interstitialAd.destroy();
          print('Interstitial dismissed');
        },
      );
      interstitialAd.load();
    } else {
      InterstitialAd.load(
        adUnitId: AdmobKeys().interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialAd?.show();
            _interstitialAd = null;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {},
            );
          },
          onAdFailedToLoad: (err) {},
        ),
      );
    }
  }
}
