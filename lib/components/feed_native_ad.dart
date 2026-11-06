import 'package:foap/helper/imports/common_import.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../api_handler/apis/creator_pool_api.dart';
import '../util/ad_network_keys.dart';

/// One Google AdMob native ad for the home feed. The ad carries Google's own "Ad" label.
/// [hostPostId] is the post just above the ad: when the ad is really shown, the server is told
/// so the creator of that post can share in the ad revenue.
class FeedNativeAd extends StatefulWidget {
  final int hostPostId;

  const FeedNativeAd({super.key, required this.hostPostId});

  @override
  State<FeedNativeAd> createState() => _FeedNativeAdState();
}

class _FeedNativeAdState extends State<FeedNativeAd> {
  NativeAd? _ad;
  bool _loaded = false;
  static bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final String unitId = AdmobKeys().nativeAdUnitId;
      if (unitId.isEmpty) return;
      if (!_initialized) {
        _initialized = true;
        await MobileAds.instance.initialize();
      }
      final ad = NativeAd(
        adUnitId: unitId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (Ad ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            if (mounted) setState(() => _ad = null);
          },
          onAdImpression: (Ad ad) {
            CreatorPoolApi.reportAdImpression(postId: widget.hostPostId);
          },
        ),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (_) {
      // an ad problem must never break the feed
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null || !_loaded) {
      return const SizedBox.shrink();
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 320, maxHeight: 400),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: AdWidget(ad: _ad!),
    );
  }
}
