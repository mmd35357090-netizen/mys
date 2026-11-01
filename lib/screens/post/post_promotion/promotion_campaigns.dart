import 'package:foap/helper/imports/common_import.dart';
import '../../../api_handler/apis/promotion_api.dart';
import '../../../components/sm_tab_bar.dart';
import '../../../model/promotion_report_model.dart';
import 'promotion_report.dart';
import 'promotion_ui.dart';

/// "My campaigns": every boost the user has bought, running or finished.
class PromotionCampaignsScreen extends StatelessWidget {
  const PromotionCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [boostActiveTab.tr, boostCompletedTab.tr];
    return DefaultTabController(
      length: tabs.length,
      child: AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBar(title: boostMyCampaigns.tr),
            SMTabBar(tabs: tabs, canScroll: false),
            const Expanded(
              child: TabBarView(
                children: [
                  _CampaignList(type: 'ACTIVE'),
                  _CampaignList(type: 'COMPLETED'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignList extends StatefulWidget {
  final String type;

  const _CampaignList({required this.type});

  @override
  State<_CampaignList> createState() => _CampaignListState();
}

class _CampaignListState extends State<_CampaignList> {
  final ScrollController _scrollController = ScrollController();
  List<PromotionCampaign> _items = [];
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        !_loading &&
        _hasMore) {
      _load(refresh: false);
    }
  }

  Future<void> _load({required bool refresh}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      if (mounted) setState(() => _loading = true);
    } else {
      if (mounted) setState(() => _loadingMore = true);
    }

    await PromotionApi.getCampaigns(
        type: widget.type,
        page: _page,
        campaignsCallback: (campaigns, meta) {
          if (!mounted) return;
          setState(() {
            _items = refresh ? campaigns : [..._items, ...campaigns];
            _hasMore = meta.currentPage < meta.pageCount;
            _page = meta.currentPage + 1;
          });
        });

    if (mounted) {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 80),
            Center(
              child: Heading6Text(
                boostNoCampaigns.tr,
                weight: TextWeight.semiBold,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: BodyMediumText(
                boostNoCampaignsHint.tr,
                color: AppColorConstants.subHeadingTextColor,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final PromotionCampaign campaign = _items[index];
          return _CampaignCard(
            campaign: campaign,
            onTap: () async {
              await Get.to(() => PromotionReportScreen(promotionId: campaign.id));
              // the user may have paused or cancelled it
              _load(refresh: true);
            },
          );
        },
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final PromotionCampaign campaign;
  final VoidCallback onTap;

  const _CampaignCard({required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String title =
        campaign.postTitle.isEmpty ? '#${campaign.id}' : campaign.postTitle;
    final String timeText = campaign.isRunning
        ? '${campaign.daysLeft} ${boostDaysLeft.tr}'
        : boostEnded.tr;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColorConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BodyLargeText(
                  title,
                  weight: TextWeight.semiBold,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              promotionStatusChip(campaign),
            ],
          ),
          const SizedBox(height: 4),
          BodySmallText(
            promotionGoalText(campaign.goalType),
            color: AppColorConstants.subHeadingTextColor,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: campaign.spendProgress,
              minHeight: 6,
              backgroundColor: AppColorConstants.borderColor,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColorConstants.themeColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              promotionMetric(boostReachLabel.tr, '${campaign.reach}'),
              promotionMetric(boostSpentLabel.tr,
                  promotionMoney(campaign.currencySymbol, campaign.spend)),
              promotionMetric(durationString.tr, timeText),
            ],
          ),
        ],
      ),
    ).ripple(onTap);
  }
}
