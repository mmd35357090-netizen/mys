import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/api_handler/apis/deposit_api.dart';
import 'package:foap/model/deposit_model.dart';

/// "My deposits": every top-up request and what happened to it.
class DepositHistoryScreen extends StatefulWidget {
  const DepositHistoryScreen({super.key});

  @override
  State<DepositHistoryScreen> createState() => _DepositHistoryScreenState();
}

class _DepositHistoryScreenState extends State<DepositHistoryScreen> {
  final ScrollController _scroll = ScrollController();
  List<DepositRequestModel> _items = [];
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 &&
          !_loadingMore &&
          !_loading &&
          _hasMore) {
        _load(refresh: false);
      }
    });
    _load(refresh: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({required bool refresh}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      if (mounted) setState(() => _loading = true);
    } else {
      if (mounted) setState(() => _loadingMore = true);
    }
    await DepositApi.getRequests(
        page: _page,
        resultCallback: (items, meta) {
          if (!mounted) return;
          setState(() {
            _items = refresh ? items : [..._items, ...items];
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

  Color _statusColor(int status) {
    if (status == DepositStatus.approved) return Colors.green;
    if (status == DepositStatus.rejected) return Colors.red;
    return Colors.orange;
  }

  String _statusText(int status) {
    if (status == DepositStatus.approved) return depositApprovedStatus.tr;
    if (status == DepositStatus.rejected) return depositRejectedStatus.tr;
    return depositPendingStatus.tr;
  }

  String _date(int seconds) {
    if (seconds <= 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: myDepositsString.tr),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
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
                child: BodyLargeText(depositNoRequests.tr,
                    textAlign: TextAlign.center)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding, 16,
            DesignConstants.horizontalPadding, 40),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _tile(_items[index]);
        },
      ),
    );
  }

  Widget _tile(DepositRequestModel r) {
    final Color color = _statusColor(r.status);
    final bool approved = r.status == DepositStatus.approved;
    final double shown = approved && r.creditedUsd != null
        ? r.creditedUsd!
        : r.usdAmount;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: BodyLargeText(
                    '${r.methodTitle} - \$${shown.toStringAsFixed(2)}',
                    weight: TextWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BodySmallText(_statusText(r.status),
                    color: color, weight: TextWeight.medium),
              ),
            ],
          ),
          const SizedBox(height: 6),
          BodySmallText(
              '${r.currencySymbol}${r.localAmount.toStringAsFixed(2)}  -  ${r.trxId}',
              color: AppColorConstants.subHeadingTextColor),
          const SizedBox(height: 2),
          BodySmallText(_date(r.createdAt),
              color: AppColorConstants.subHeadingTextColor),
          if (r.status == DepositStatus.rejected && r.adminNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            BodyMediumText('${depositReason.tr}: ${r.adminNote}',
                color: AppColorConstants.red),
          ],
          if (approved &&
              r.creditedUsd != null &&
              (r.creditedUsd! - r.usdAmount).abs() > 0.009) ...[
            const SizedBox(height: 8),
            BodySmallText(
                '${depositCredited.tr}: \$${r.creditedUsd!.toStringAsFixed(2)}',
                color: AppColorConstants.green),
          ],
        ],
      ),
    );
  }
}
