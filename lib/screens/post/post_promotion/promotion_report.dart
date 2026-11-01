import 'package:foap/helper/imports/common_import.dart';
import '../../../api_handler/apis/promotion_api.dart';
import '../../../model/promotion_report_model.dart';
import 'promotion_ui.dart';

/// Results of one campaign: reach, actions, spend, daily chart, who saw it,
/// and the buttons to pause, resume or cancel it.
class PromotionReportScreen extends StatefulWidget {
  final int promotionId;

  const PromotionReportScreen({super.key, required this.promotionId});

  @override
  State<PromotionReportScreen> createState() => _PromotionReportScreenState();
}

class _PromotionReportScreenState extends State<PromotionReportScreen> {
  PromotionCampaign? _report;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    await PromotionApi.getReport(
        promotionId: widget.promotionId,
        reportCallback: (report) {
          if (!mounted) return;
          setState(() => _report = report);
        });
    if (mounted) setState(() => _loading = false);
  }

  void _togglePause(PromotionCampaign report) {
    final bool pause = report.status == PromotionStatus.active;
    Loader.show(status: loadingString.tr);
    PromotionApi.updateStatus(
        promotionId: report.id,
        status: pause ? PromotionStatus.paused : PromotionStatus.active,
        completionHandler: (success, message) {
          Loader.dismiss();
          if (message != null && message.isNotEmpty) {
            AppUtil.showToast(message: message, isSuccess: success);
          }
          if (success) _load();
        });
  }

  void _cancel(PromotionCampaign report) {
    AppUtil.showNewConfirmationAlert(
        title: boostCancelCampaign.tr,
        subTitle: boostCancelConfirm.tr,
        cancelHandler: () {
          Get.back();
        },
        okHandler: () {
          Get.back();
          Loader.show(status: loadingString.tr);
          PromotionApi.cancelPromotion(
              promotionId: report.id,
              completionHandler: (success, message) {
                Loader.dismiss();
                if (message != null && message.isNotEmpty) {
                  AppUtil.showToast(message: message, isSuccess: success);
                }
                if (success) _load();
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: boostCampaignReport.tr),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading && _report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final PromotionCampaign? report = _report;
    if (report == null) {
      return const SizedBox();
    }

    final String cur = report.currencySymbol;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _header(report),
          const SizedBox(height: 16),
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  promotionMetric(boostReachLabel.tr, '${report.reach}'),
                  promotionMetric(
                      boostImpressionsLabel.tr, '${report.impressions}'),
                  promotionMetric(boostResultsLabel.tr, '${report.results}'),
                ],
              ),
              const SizedBox(height: 4),
              BodyExtraSmallText(
                promotionGoalText(report.goalType),
                color: AppColorConstants.subHeadingTextColor,
              ),
            ],
          )),
          const SizedBox(height: 12),
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  promotionMetric(boostSpentLabel.tr,
                      promotionMoney(cur, report.spend)),
                  promotionMetric(boostRemainingLabel.tr,
                      promotionMoney(cur, report.remaining)),
                  promotionMetric(
                      boostCostPerResultLabel.tr,
                      report.costPerResult == null
                          ? '-'
                          : promotionMoney(cur, report.costPerResult!)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: report.spendProgress,
                  minHeight: 6,
                  backgroundColor: AppColorConstants.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColorConstants.themeColor),
                ),
              ),
            ],
          )),
          const SizedBox(height: 12),
          _card(Column(
            children: [
              _row(boostClicksLabel.tr, '${report.clicks}'),
              _row(boostCtrLabel.tr, '${report.ctr}%'),
              _row(boostProfileVisitsLabel.tr, '${report.profileVisits}'),
              _row(boostMessagesLabel.tr, '${report.messages}'),
              _row(boostWebsiteVisitsLabel.tr, '${report.websiteVisits}'),
              _row(boostNewFollowersLabel.tr, '${report.newFollowers}'),
              if (!report.trackingAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: BodyExtraSmallText(
                    boostTrackingMissing.tr,
                    color: AppColorConstants.subHeadingTextColor,
                  ),
                ),
            ],
          )),
          if (report.daily.isNotEmpty) ...[
            const SizedBox(height: 20),
            Heading6Text(boostDailyPerformance.tr,
                weight: TextWeight.semiBold),
            const SizedBox(height: 12),
            _card(_dailyChart(report.daily)),
          ],
          if (report.gender.values.any((v) => v > 0) ||
              report.age.values.any((v) => v > 0)) ...[
            const SizedBox(height: 20),
            Heading6Text(boostWhoSawIt.tr, weight: TextWeight.semiBold),
            const SizedBox(height: 12),
            if (report.gender.values.any((v) => v > 0))
              _card(_distribution(boostGenderLabel.tr, {
                maleString.tr: report.gender['male'] ?? 0,
                femaleString.tr: report.gender['female'] ?? 0,
                otherString.tr: report.gender['other'] ?? 0,
                boostUnknownLabel.tr: report.gender['unknown'] ?? 0,
              })),
            if (report.age.values.any((v) => v > 0)) ...[
              const SizedBox(height: 12),
              _card(_distribution(boostAgeLabel.tr, _orderedAge(report.age))),
            ],
          ],
          if (report.status == PromotionStatus.pending)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: BodySmallText(
                boostPendingNote.tr,
                color: AppColorConstants.subHeadingTextColor,
              ),
            ),
          if (report.status == PromotionStatus.active ||
              report.status == PromotionStatus.paused) ...[
            const SizedBox(height: 24),
            AppThemeButton(
              text: report.status == PromotionStatus.active
                  ? boostPauseCampaign.tr
                  : boostResumeCampaign.tr,
              onPress: () => _togglePause(report),
            ),
            if (report.status == PromotionStatus.active)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: BodyExtraSmallText(
                  boostPauseNote.tr,
                  color: AppColorConstants.subHeadingTextColor,
                ),
              ),
          ],
          if (report.canBeCancelled) ...[
            const SizedBox(height: 12),
            AppThemeBorderButton(
              text: boostCancelCampaign.tr,
              onPress: () => _cancel(report),
            ),
          ],
        ],
      ),
    );
  }

  Widget _header(PromotionCampaign report) {
    final String title =
        report.postTitle.isEmpty ? '#${report.id}' : report.postTitle;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Heading6Text(title, weight: TextWeight.semiBold, maxLines: 2),
        ),
        const SizedBox(width: 8),
        promotionStatusChip(report),
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColorConstants.borderColor),
      ),
      child: child,
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BodyMediumText(label, weight: TextWeight.medium),
          BodyMediumText(value),
        ],
      ),
    );
  }

  /// Bars for the reach of each day. Plain widgets, no chart package needed.
  Widget _dailyChart(List<PromotionDailyPoint> daily) {
    int maxReach = 1;
    for (final point in daily) {
      if (point.reach > maxReach) maxReach = point.reach;
    }
    const double chartHeight = 100;

    return SizedBox(
      height: chartHeight + 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: daily.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final PromotionDailyPoint point = daily[index];
          final double barHeight = point.reach == 0
              ? 2.0
              : (point.reach / maxReach * chartHeight)
                  .clamp(4.0, chartHeight)
                  .toDouble();
          // date is yyyy-mm-dd: show the day of the month
          final String day =
              point.date.length >= 10 ? point.date.substring(8, 10) : point.date;
          return SizedBox(
            width: 24,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BodyExtraSmallText('${point.reach}'),
                const SizedBox(height: 4),
                Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: AppColorConstants.themeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                BodyExtraSmallText(
                  day,
                  color: AppColorConstants.subHeadingTextColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, int> _orderedAge(Map<String, int> age) {
    const order = ['13-17', '18-24', '25-34', '35-44', '45-54', '55+', 'unknown'];
    final Map<String, int> result = {};
    for (final key in order) {
      if (age.containsKey(key)) {
        result[key == 'unknown' ? boostUnknownLabel.tr : key] = age[key]!;
      }
    }
    return result;
  }

  /// Rows with a label, a bar and a percentage.
  Widget _distribution(String title, Map<String, int> values) {
    int total = 0;
    values.forEach((key, value) => total += value);
    if (total == 0) total = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyMediumText(title, weight: TextWeight.semiBold),
        const SizedBox(height: 8),
        ...values.entries.map((entry) {
          final double share = entry.value / total;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: BodySmallText(entry.key),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: share,
                      minHeight: 8,
                      backgroundColor: AppColorConstants.borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColorConstants.themeColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: BodySmallText(
                    '${entry.value} (${(share * 100).round()}%)',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
