import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/controllers/home/home_controller.dart';
import 'package:foap/components/post_card/post_card.dart';
import '../screens/settings_menu/settings_controller.dart';
import 'feed_native_ad.dart';

/// Places ad pages between reels.
class ReelSlots {
  /// Returns one entry per page: the reel index, or null for an ad page.
  /// An ad page follows every [every] reels, never at the very end.
  static List<int?> layout(int reelCount, int every, bool adsOn) {
    final List<int?> out = [];
    for (int i = 0; i < reelCount; i++) {
      out.add(i);
      if (adsOn && every >= 3 && (i + 1) % every == 0 && i < reelCount - 1) {
        out.add(null);
      }
    }
    return out;
  }

  /// Page number of a given reel index.
  static int pageOfReel(int reelIndex, int every, bool adsOn) {
    if (!adsOn || every < 3) return reelIndex;
    return reelIndex + (reelIndex ~/ every);
  }

  /// True when ads may be shown in reels, by the admin switches.
  static bool adsOn() {
    try {
      final s = Get.find<SettingsController>().setting.value;
      return s != null && s.adsReelsEnabled && (s.googleAdsOn || s.ownAdsOn);
    } catch (_) {
      return false;
    }
  }

  static int every() {
    try {
      return Get.find<SettingsController>().setting.value?.reelsAdEvery ?? 4;
    } catch (_) {
      return 4;
    }
  }
}

/// One full page ad between reels: a user promotion (any type: text, photo, video) from this app,
/// or a Google AdMob native ad. The admin's "Ad source" decides which of them may appear.
class ReelAdPage extends StatelessWidget {
  final int adNumber; // 0, 1, 2 ... how many ad pages came before
  final int hostReelId; // the reel just before this ad: its creator shares the ad revenue

  const ReelAdPage({super.key, required this.adNumber, required this.hostReelId});

  @override
  Widget build(BuildContext context) {
    final setting = Get.find<SettingsController>().setting.value;
    final bool google = setting?.googleAdsOn ?? false;
    final bool own = setting?.ownAdsOn ?? false;

    List sponsored = [];
    try {
      sponsored = Get.find<HomeController>().sponsoredPosts.toList();
    } catch (_) {}
    final bool haveOwn = own && sponsored.isNotEmpty;

    // both on: take turns (own first); otherwise use what is on
    bool showOwn;
    if (haveOwn && google) {
      showOwn = adNumber % 2 == 0;
    } else {
      showOwn = haveOwn;
    }

    Widget content;
    if (showOwn) {
      final post = sponsored[(adNumber ~/ (google ? 2 : 1)) % sponsored.length];
      content = SingleChildScrollView(
        child: PostCard(
          model: post,
          removePostHandler: () {},
          blockUserHandler: () {},
        ),
      );
    } else if (google) {
      content = Center(
        child: FeedNativeAd(
            key: ValueKey('reel_native_$adNumber'), hostPostId: hostReelId),
      );
    } else {
      content = const SizedBox.shrink();
    }

    return Container(
      color: AppColorConstants.backgroundColor,
      width: Get.width,
      height: Get.height,
      child: SafeArea(
        child: Stack(
          children: [
            Center(child: content),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: Text('Swipe up to continue',
                    style: TextStyle(
                        color: AppColorConstants.iconColor.withValues(alpha: 0.6),
                        fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
