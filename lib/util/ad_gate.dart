import 'package:foap/helper/imports/common_import.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../screens/settings_menu/settings_controller.dart';
import 'ad_network_keys.dart';

/// One place that decides whether a full-screen Google ad may be shown.
/// Rules (kept strict on purpose, so the AdMob account stays safe):
///  - the admin's ad source must allow Google, and the place (reels / video) must be on
///  - never two full-screen ads closer than the admin's gap (60 s or more)
///  - an ad problem never breaks the app: every failure is silent
class AdGate {
  static DateTime? _lastShown;
  static bool _busy = false;
  static int _reelsSeen = 0;

  static bool _gapPassed(int gapSeconds) {
    if (_lastShown == null) return true;
    return DateTime.now().difference(_lastShown!).inSeconds >= gapSeconds;
  }

  static Future<void> _showInterstitial(int gapSeconds) async {
    if (_busy || !_gapPassed(gapSeconds)) return;
    final String unitId = AdmobKeys().interstitialAdUnitIdSafe;
    if (unitId.isEmpty) return;
    _busy = true;
    try {
      await InterstitialAd.load(
        adUnitId: unitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _busy = false;
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _busy = false;
              },
            );
            _lastShown = DateTime.now();
            ad.show();
          },
          onAdFailedToLoad: (error) {
            _busy = false;
          },
        ),
      );
    } catch (_) {
      _busy = false;
    }
  }

  /// Call every time the viewer moves to a new reel.
  static void onReelViewed() {
    try {
      final setting = Get.find<SettingsController>().setting.value;
      if (setting == null || !setting.googleAdsOn || !setting.adsReelsEnabled) {
        return;
      }
      _reelsSeen++;
      // a full-screen ad comes after every (N * 2) reels, the N-th pages being ad pages
      if (_reelsSeen >= setting.reelsAdEvery * 2) {
        _reelsSeen = 0;
        _showInterstitial(setting.interstitialGapSeconds);
      }
    } catch (_) {}
  }

  /// Call when the viewer closes a full-screen video.
  static void onVideoClosed() {
    try {
      final setting = Get.find<SettingsController>().setting.value;
      if (setting == null || !setting.googleAdsOn || !setting.adsVideoEnabled) {
        return;
      }
      _showInterstitial(setting.interstitialGapSeconds);
    } catch (_) {}
  }
}
