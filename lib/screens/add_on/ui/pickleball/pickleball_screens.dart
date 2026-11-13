import 'package:foap/helper/imports/common_import.dart';
import 'package:intl/intl.dart';
import '../../../../api_handler/apis/pickleball_api.dart';
import '../../../../model/api_meta_data.dart';
import '../../model/pickleball_model.dart';
import 'pickleball_match_screens.dart';

BoxDecoration _cardDecoration() => BoxDecoration(
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
    );

Widget _avatar(String url, String name, double size) {
  final hasUrl = url.startsWith('http');
  return CircleAvatar(
    radius: size / 2,
    backgroundColor: AppColorConstants.themeColor.withValues(alpha: 0.12),
    backgroundImage: hasUrl ? NetworkImage(url) : null,
    child: hasUrl
        ? null
        : Text(name.isEmpty ? '?' : name[0].toUpperCase(),
            style: TextStyle(
                color: AppColorConstants.themeColor,
                fontWeight: FontWeight.bold)),
  );
}

/// Matches list: ongoing / completed, all matches or only mine.
class PickleballMatchesScreen extends StatefulWidget {
  const PickleballMatchesScreen({super.key});

  @override
  State<PickleballMatchesScreen> createState() =>
      _PickleballMatchesScreenState();
}

class _PickleballMatchesScreenState extends State<PickleballMatchesScreen> {
  final ScrollController _scroll = ScrollController();
  List<PickleballMatchModel> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  int _statusType = 1;
  bool _mineOnly = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) {
        _load();
      }
    });
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _items = [];
      _page = 1;
      _hasMore = true;
    });
    _load();
  }

  void _load() {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    final type = _statusType;
    final mine = _mineOnly;
    PickleballApi.getMatches(
        page: _page,
        statusType: type,
        mineOnly: mine,
        resultCallback: (list, meta) {
          if (!mounted || type != _statusType || mine != _mineOnly) return;
          setState(() {
            _items.addAll(list);
            _hasMore = meta.currentPage < meta.pageCount;
            _page += 1;
            _loading = false;
          });
        });
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? AppColorConstants.themeColor
            : AppColorConstants.themeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: BodySmallText(label,
          weight: TextWeight.semiBold,
          color: selected ? Colors.white : AppColorConstants.themeColor),
    ).ripple(onTap);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: pickleballString.tr),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(children: [
              _chip(ongoingString.tr, _statusType == 1, () {
                _statusType = 1;
                _reset();
              }),
              const SizedBox(width: 8),
              _chip(completedString.tr, _statusType == 2, () {
                _statusType = 2;
                _reset();
              }),
              const SizedBox(width: 8),
              _chip(myMatchesString.tr, _mineOnly, () {
                _mineOnly = !_mineOnly;
                _reset();
              }),
              const Spacer(),
              Icon(Icons.add_circle_outline_rounded,
                      color: AppColorConstants.themeColor)
                  .ripple(() async {
                final created = await Get.to(() => const CreatePickleballMatch());
                if (created == true) _reset();
              }),
              const SizedBox(width: 12),
              Icon(Icons.emoji_events_outlined,
                      color: AppColorConstants.themeColor)
                  .ripple(() => Get.to(() => const PickleballTopPlayersScreen())),
              const SizedBox(width: 12),
              Icon(Icons.stadium_outlined, color: AppColorConstants.themeColor)
                  .ripple(() => Get.to(() => const PickleballCourtsScreen())),
            ]),
          ),
          Expanded(
            child: _items.isEmpty && !_loading
                ? Center(
                    child: BodyLargeText(noMatchesString.tr,
                        color: AppColorConstants.subHeadingTextColor))
                : ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _items.length + (_loading ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      if (i >= _items.length) {
                        return const Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Center(child: CircularProgressIndicator()));
                      }
                      return _matchCard(_items[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _matchCard(PickleballMatchModel match) {
    final when = match.startTime > 0
        ? DateFormat('d MMM, h:mm a').format(
            DateTime.fromMillisecondsSinceEpoch(match.startTime * 1000))
        : '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: BodyLargeText(match.court?.name ?? '',
                    maxLines: 1, weight: TextWeight.semiBold)),
            BodySmallText(
                match.matchType == 2 ? doublesString.tr : singlesString.tr,
                color: AppColorConstants.themeColor),
          ]),
          if (when.isNotEmpty)
            BodySmallText('$when  ·  ${match.pointToWin} ${pointsToWinString.tr}'),
          const SizedBox(height: 10),
          for (final team in match.teams) _teamRow(match, team),
        ],
      ),
    ).ripple(() async {
      await Get.to(() => PickleballMatchDetail(matchId: match.id));
      _reset();
    });
  }

  Widget _teamRow(PickleballMatchModel match, PickleballTeamModel team) {
    final won = match.isCompleted && match.winnerTeamId == team.id;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(children: [
        for (final p in team.players.where((p) => p.status != 2).take(3))
          Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _avatar(p.image, p.name, 28)),
        const SizedBox(width: 6),
        Expanded(
            child: BodyMediumText(
                team.players.isEmpty
                    ? team.name
                    : team.players.map((e) => e.name).join(', '),
                maxLines: 1)),
        if (won)
          Icon(Icons.emoji_events_rounded,
              size: 20, color: const Color(0xFFF59E0B)),
      ]),
    );
  }
}

/// Courts list with search.
class PickleballCourtsScreen extends StatefulWidget {
  const PickleballCourtsScreen({super.key});

  @override
  State<PickleballCourtsScreen> createState() => _PickleballCourtsScreenState();
}

class _PickleballCourtsScreenState extends State<PickleballCourtsScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();
  List<PickleballCourtModel> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) {
        _load();
      }
    });
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _items = [];
      _page = 1;
      _hasMore = true;
    });
    _load();
  }

  void _load() {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    final q = _search.text.trim();
    PickleballApi.getCourts(
        page: _page,
        search: q,
        resultCallback: (list, meta) {
          if (!mounted || q != _search.text.trim()) return;
          setState(() {
            _items.addAll(list);
            _hasMore = meta.currentPage < meta.pageCount;
            _page += 1;
            _loading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: courtsString.tr),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _reset(),
              decoration: InputDecoration(
                hintText: searchCourtString.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColorConstants.cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _items.isEmpty && !_loading
                ? Center(
                    child: BodyLargeText(noCourtsString.tr,
                        color: AppColorConstants.subHeadingTextColor))
                : ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _items.length + (_loading ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      if (i >= _items.length) {
                        return const Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Center(child: CircularProgressIndicator()));
                      }
                      return _courtCard(_items[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _courtCard(PickleballCourtModel c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: c.imageUrl.startsWith('http')
              ? Image.network(c.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _courtIcon())
              : _courtIcon(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(c.name, maxLines: 1, weight: TextWeight.semiBold),
              BodySmallText(c.address, maxLines: 2),
              BodySmallText(
                  '${c.indoor ? indoorString.tr : outdoorString.tr}'
                  '${c.distance > 0 ? '  ·  ${c.distance.toStringAsFixed(1)} mi' : ''}',
                  color: AppColorConstants.themeColor),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _courtIcon() => Container(
        width: 64,
        height: 64,
        color: AppColorConstants.themeColor.withValues(alpha: 0.12),
        child: Icon(Icons.sports_tennis_rounded,
            color: AppColorConstants.themeColor),
      );
}
