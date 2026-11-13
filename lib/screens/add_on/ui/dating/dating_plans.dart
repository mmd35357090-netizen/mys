import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/util/biometric_helper.dart';
import '../../../../api_handler/apis/dating_package_api.dart';
import '../../model/dating_package_model.dart';

/// Packages that raise the number of profiles a user can see per day.
/// They are bought with coins.
class DatingPlans extends StatefulWidget {
  const DatingPlans({super.key});

  @override
  State<DatingPlans> createState() => _DatingPlansState();
}

class _DatingPlansState extends State<DatingPlans> {
  final UserProfileManager _userProfileManager = Get.find();
  List<DatingPackageModel> _packages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    DatingPackageApi.getPackages(resultCallback: (result) {
      if (!mounted) return;
      setState(() {
        _packages = result.where((e) => !e.isDefault).toList();
        _loading = false;
      });
    });
  }

  void _buy(DatingPackageModel package) {
    AppUtil.showNewConfirmationAlert(
      title: package.name,
      subTitle:
          '${datingPlanBuyConfirmString.tr} ${package.coin} ${coinsString.tr}?',
      okHandler: () async {
        final ok = await BiometricHelper.confirmIfEnabled(package.name);
        if (!ok) return;
        DatingPackageApi.subscribe(
            packageId: package.id,
            resultCallback: (success, message) {
              if (success) {
                _userProfileManager.refreshProfile();
                AppUtil.showToast(
                    message: datingPlanActivatedString.tr, isSuccess: true);
              } else {
                AppUtil.showToast(
                    message: (message ?? '').isNotEmpty
                        ? message!
                        : pleaseTryAgainString.tr,
                    isSuccess: false);
              }
            });
      },
      cancelHandler: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: datingPlansString.tr),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _packages.isEmpty
                    ? Center(
                        child: BodyLargeText(noDatingPlansString.tr,
                            color: AppColorConstants.subHeadingTextColor))
                    : ListView.separated(
                        padding:
                            EdgeInsets.all(DesignConstants.horizontalPadding),
                        itemCount: _packages.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (ctx, index) => _tile(_packages[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _tile(DatingPackageModel package) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15)),
            child: Icon(Icons.workspace_premium_rounded,
                color: AppColorConstants.themeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(package.name,
                    maxLines: 1, weight: TextWeight.semiBold),
                BodySmallText(
                    '${package.numberOfProfiles} ${profilesPerDayString.tr}  ·  ${package.durationLabel}'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColorConstants.themeColor,
                AppColorConstants.themeColor.withValues(alpha: 0.78)
              ]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: BodyMediumText('${package.coin} ${coinsString.tr}',
                weight: TextWeight.bold, color: Colors.white),
          ).ripple(() => _buy(package)),
        ],
      ),
    );
  }
}
