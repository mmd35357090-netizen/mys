import 'package:foap/helper/imports/common_import.dart';
import 'package:intl/intl.dart';
import '../../../../api_handler/apis/friends_api.dart';
import '../../../../api_handler/apis/pickleball_api.dart';
import '../../model/pickleball_model.dart';

Widget _pAvatar(String url, String name, double size) {
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

BoxDecoration _pCard() => BoxDecoration(
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

void _toast(bool ok, String? message, String fallback) {
  AppUtil.showToast(
      message: (message ?? '').isNotEmpty ? message! : fallback,
      isSuccess: ok);
}

/// Bottom sheet that lets the user pick friends (mutual follows).
Future<List<UserModel>?> showFriendPicker(
    {required int maxSelect, Set<int> excludeIds = const {}}) {
  return Get.bottomSheet<List<UserModel>>(
    _FriendPicker(maxSelect: maxSelect, excludeIds: excludeIds),
    isScrollControlled: true,
    backgroundColor: AppColorConstants.backgroundColor,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  );
}

class _FriendPicker extends StatefulWidget {
  final int maxSelect;
  final Set<int> excludeIds;

  const _FriendPicker({required this.maxSelect, required this.excludeIds});

  @override
  State<_FriendPicker> createState() => _FriendPickerState();
}

class _FriendPickerState extends State<_FriendPicker> {
  List<UserModel> _friends = [];
  final List<UserModel> _selected = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    FriendsApi.getFriends(
        page: 1,
        resultCallback: (list, meta) {
          if (!mounted) return;
          setState(() {
            _friends =
                list.where((e) => !widget.excludeIds.contains(e.id)).toList();
            _loading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(children: [
        const SizedBox(height: 16),
        BodyLargeText(selectPlayersString.tr, weight: TextWeight.bold),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _friends.isEmpty
                  ? Center(
                      child: BodyMediumText(noFriendsToInviteString.tr,
                          color: AppColorConstants.subHeadingTextColor))
                  : ListView.builder(
                      itemCount: _friends.length,
                      itemBuilder: (ctx, i) {
                        final u = _friends[i];
                        final sel = _selected.any((e) => e.id == u.id);
                        return ListTile(
                          leading: _pAvatar(u.picture ?? '', u.userName, 40),
                          title: BodyMediumText(u.userName),
                          trailing: Icon(
                              sel
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: AppColorConstants.themeColor),
                          onTap: () {
                            setState(() {
                              if (sel) {
                                _selected.removeWhere((e) => e.id == u.id);
                              } else if (_selected.length <
                                  widget.maxSelect) {
                                _selected.add(u);
                              }
                            });
                          },
                        );
                      }),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppThemeButton(
              text: doneString.tr,
              onPress: () => Get.back(result: _selected)),
        ),
      ]),
    );
  }
}

/// Create a match: court, singles/doubles, points, time and players.
class CreatePickleballMatch extends StatefulWidget {
  const CreatePickleballMatch({super.key});

  @override
  State<CreatePickleballMatch> createState() => _CreatePickleballMatchState();
}

class _CreatePickleballMatchState extends State<CreatePickleballMatch> {
  final UserProfileManager _me = Get.find();
  PickleballCourtModel? _court;
  int _type = 1;
  int _points = 11;
  DateTime _when = DateTime.now().add(const Duration(hours: 2));
  List<UserModel> _teamA = []; // friends besides me
  List<UserModel> _teamB = [];
  bool _saving = false;

  int get _perTeam => _type == 2 ? 2 : 1;

  Future<void> _pickCourt() async {
    final court = await Get.bottomSheet<PickleballCourtModel>(
      const _CourtPicker(),
      isScrollControlled: true,
      backgroundColor: AppColorConstants.backgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    );
    if (court != null) setState(() => _court = court);
  }

  Future<void> _pickTime() async {
    final d = await showDatePicker(
        context: context,
        initialDate: _when,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (d == null || !mounted) return;
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (t == null) return;
    setState(() => _when = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _pickPlayers(bool teamA) async {
    final max = teamA ? _perTeam - 1 : _perTeam;
    if (max <= 0) return;
    final exclude = <int>{
      _me.user.value!.id,
      ...(teamA ? _teamB : _teamA).map((e) => e.id)
    };
    final result = await showFriendPicker(maxSelect: max, excludeIds: exclude);
    if (result == null) return;
    setState(() {
      if (teamA) {
        _teamA = result;
      } else {
        _teamB = result;
      }
    });
  }

  void _save() {
    if (_court == null) {
      AppUtil.showToast(message: selectCourtString.tr, isSuccess: false);
      return;
    }
    if (_teamB.length < _perTeam) {
      AppUtil.showToast(message: selectOpponentsString.tr, isSuccess: false);
      return;
    }
    final myId = _me.user.value!.id;
    final teams = [
      {
        'name': 'Team A',
        'player': [
          {'player_id': myId, 'is_send_invitation': 0},
          ..._teamA.map((e) => {'player_id': e.id, 'is_send_invitation': 1}),
        ]
      },
      {
        'name': 'Team B',
        'player': _teamB
            .map((e) => {'player_id': e.id, 'is_send_invitation': 1})
            .toList()
      },
    ];
    setState(() => _saving = true);
    PickleballApi.createMatch(
        courtId: _court!.id,
        matchType: _type,
        pointToWin: _points,
        startTime: _when.millisecondsSinceEpoch ~/ 1000,
        teams: teams,
        resultCallback: (ok, message) {
          if (!mounted) return;
          setState(() => _saving = false);
          _toast(ok, message, pleaseTryAgainString.tr);
          if (ok) Get.back(result: true);
        });
  }

  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: BodyMediumText(t, weight: TextWeight.semiBold));

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: sel
            ? AppColorConstants.themeColor
            : AppColorConstants.themeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: BodySmallText(label,
          weight: TextWeight.semiBold,
          color: sel ? Colors.white : AppColorConstants.themeColor),
    ).ripple(onTap);
  }

  Widget _row(IconData icon, String text, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _pCard(),
      child: Row(children: [
        Icon(icon, color: AppColorConstants.themeColor),
        const SizedBox(width: 10),
        Expanded(child: BodyMediumText(text, maxLines: 1)),
        const Icon(Icons.chevron_right_rounded),
      ]),
    ).ripple(onTap);
  }

  String _names(List<UserModel> l) => l.map((e) => e.userName).join(', ');

  @override
  Widget build(BuildContext context) {
    final myName = _me.user.value?.userName ?? '';
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(children: [
        backNavigationBar(title: createMatchString.tr),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(courtString.tr),
                  _row(Icons.stadium_outlined,
                      _court?.name ?? selectCourtString.tr, _pickCourt),
                  _label(matchTypeString.tr),
                  Row(children: [
                    _chip(singlesString.tr, _type == 1, () {
                      setState(() {
                        _type = 1;
                        _teamA = [];
                        _teamB = [];
                      });
                    }),
                    const SizedBox(width: 8),
                    _chip(doublesString.tr, _type == 2, () {
                      setState(() {
                        _type = 2;
                        _teamA = [];
                        _teamB = [];
                      });
                    }),
                  ]),
                  _label(pointsToWinString.tr),
                  Row(children: [
                    for (final p in [11, 15, 21]) ...[
                      _chip('$p', _points == p,
                          () => setState(() => _points = p)),
                      const SizedBox(width: 8),
                    ]
                  ]),
                  _label(dateTimeString.tr),
                  _row(Icons.schedule_rounded,
                      DateFormat('d MMM yyyy, h:mm a').format(_when), _pickTime),
                  _label('Team A'),
                  _row(
                      Icons.group_rounded,
                      _perTeam == 1
                          ? myName
                          : '$myName${_teamA.isEmpty ? '' : ', ${_names(_teamA)}'}',
                      () => _pickPlayers(true)),
                  _label('Team B'),
                  _row(
                      Icons.group_outlined,
                      _teamB.isEmpty ? selectOpponentsString.tr : _names(_teamB),
                      () => _pickPlayers(false)),
                  const SizedBox(height: 28),
                  AppThemeButton(
                      text: _saving ? loadingString.tr : createMatchString.tr,
                      onPress: _saving ? null : _save),
                ]),
          ),
        ),
      ]),
    );
  }
}

class _CourtPicker extends StatefulWidget {
  const _CourtPicker();

  @override
  State<_CourtPicker> createState() => _CourtPickerState();
}

class _CourtPickerState extends State<_CourtPicker> {
  final TextEditingController _search = TextEditingController();
  List<PickleballCourtModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() {
    setState(() => _loading = true);
    final q = _search.text.trim();
    PickleballApi.getCourts(
        page: 1,
        search: q,
        resultCallback: (list, meta) {
          if (!mounted || q != _search.text.trim()) return;
          setState(() {
            _items = list;
            _loading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(children: [
        const SizedBox(height: 16),
        BodyLargeText(selectCourtString.tr, weight: TextWeight.bold),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: searchCourtString.tr,
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppColorConstants.cardColor,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) => ListTile(
                    title: BodyMediumText(_items[i].name),
                    subtitle: BodySmallText(_items[i].address, maxLines: 1),
                    onTap: () => Get.back(result: _items[i]),
                  )),
        ),
      ]),
    );
  }
}

/// One match: teams, players and their invitation status.
class PickleballMatchDetail extends StatefulWidget {
  final int matchId;

  const PickleballMatchDetail({super.key, required this.matchId});

  @override
  State<PickleballMatchDetail> createState() => _PickleballMatchDetailState();
}

class _PickleballMatchDetailState extends State<PickleballMatchDetail> {
  final UserProfileManager _me = Get.find();
  PickleballMatchModel? _match;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    PickleballApi.getMatch(
        id: widget.matchId,
        resultCallback: (m) {
          if (!mounted) return;
          setState(() => _match = m);
        });
  }

  int get _myId => _me.user.value?.id ?? 0;

  bool get _isOwner => _match != null && _match!.createdBy == _myId;

  void _after(bool ok, String? message) {
    if (!mounted) return;
    setState(() => _busy = false);
    _toast(ok, message, pleaseTryAgainString.tr);
    if (ok) _load();
  }

  void _reply(PickleballPlayerModel p, bool accept) {
    setState(() => _busy = true);
    PickleballApi.replyInvitation(
        teamPlayerId: p.teamPlayerId, accept: accept, resultCallback: _after);
  }

  void _remove(PickleballPlayerModel p) {
    AppUtil.showNewConfirmationAlert(
      title: removePlayerString.tr,
      subTitle: p.name,
      okHandler: () {
        setState(() => _busy = true);
        PickleballApi.removePlayer(
            teamPlayerId: p.teamPlayerId, resultCallback: _after);
      },
      cancelHandler: () {},
    );
  }

  Future<void> _add(PickleballTeamModel team) async {
    final exclude = <int>{
      for (final t in _match!.teams)
        for (final p in t.players) p.playerId
    };
    final picked = await showFriendPicker(maxSelect: 1, excludeIds: exclude);
    if (picked == null || picked.isEmpty) return;
    setState(() => _busy = true);
    PickleballApi.addPlayer(
        teamId: team.id, playerId: picked.first.id, resultCallback: _after);
  }

  Future<void> _declare() async {
    final m = _match!;
    if (m.teams.length < 2) return;
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text(declareResultString.tr),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
            controller: c1,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '${m.teams[0].name} score')),
        TextField(
            controller: c2,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '${m.teams[1].name} score')),
      ]),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelString.tr)),
        TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(doneString.tr)),
      ],
    ));
    final s1 = int.tryParse(c1.text.trim());
    final s2 = int.tryParse(c2.text.trim());
    c1.dispose();
    c2.dispose();
    if (ok != true) return;
    if (s1 == null || s2 == null || s1 == s2 || s1 < 0 || s2 < 0) {
      AppUtil.showToast(message: invalidScoreString.tr, isSuccess: false);
      return;
    }
    final scores = [s1, s2];
    final winner = s1 > s2 ? m.teams[0].id : m.teams[1].id;
    final teams = <Map<String, dynamic>>[];
    for (var i = 0; i < 2; i++) {
      final t = m.teams[i];
      teams.add({
        'team_id': t.id,
        'team_point': scores[i],
        'player': t.players
            .where((p) => p.status == 10)
            .map((p) => {'player_id': p.playerId, 'point_gain': scores[i]})
            .toList(),
      });
    }
    setState(() => _busy = true);
    PickleballApi.declareResult(
        matchId: m.id,
        winnerTeamId: winner,
        teams: teams,
        resultCallback: _after);
  }

  @override
  Widget build(BuildContext context) {
    final m = _match;
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(children: [
        backNavigationBar(title: matchDetailString.tr),
        Expanded(
          child: m == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: _pCard(),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BodyLargeText(m.court?.name ?? '',
                                    weight: TextWeight.semiBold),
                                BodySmallText(m.court?.address ?? ''),
                                const SizedBox(height: 6),
                                BodySmallText(
                                    '${m.startTime > 0 ? DateFormat('d MMM yyyy, h:mm a').format(DateTime.fromMillisecondsSinceEpoch(m.startTime * 1000)) : ''}'
                                    '  ·  ${m.matchType == 2 ? doublesString.tr : singlesString.tr}'
                                    '  ·  ${m.pointToWin} ${pointsToWinString.tr}',
                                    color: AppColorConstants.themeColor),
                              ]),
                        ),
                        for (final t in m.teams) _teamCard(m, t),
                        if (_isOwner && m.status == 1 && m.teams.length >= 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: AppThemeButton(
                                text: declareResultString.tr,
                                onPress: _busy ? null : _declare),
                          ),
                      ]),
                ),
        ),
      ]),
    );
  }

  Widget _teamCard(PickleballMatchModel m, PickleballTeamModel t) {
    final slots = m.matchType == 2 ? 2 : 1;
    final players = t.players;
    final canAdd = _isOwner && m.status == 1 && players.length < slots;
    final won = m.isCompleted && m.winnerTeamId == t.id;
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: _pCard(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: BodyLargeText(t.name, weight: TextWeight.semiBold)),
          if (won)
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B)),
        ]),
        for (final p in players) _playerRow(m, p),
        if (canAdd)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: [
              Icon(Icons.person_add_alt_1_rounded,
                  color: AppColorConstants.themeColor),
              const SizedBox(width: 8),
              BodyMediumText(addPlayerString.tr,
                  color: AppColorConstants.themeColor),
            ]).ripple(_busy ? () {} : () => _add(t)),
          ),
      ]),
    );
  }

  Widget _playerRow(PickleballMatchModel m, PickleballPlayerModel p) {
    final pending = p.status == 1;
    final mineAndPending = pending && p.playerId == _myId;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(children: [
        _pAvatar(p.image, p.name, 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyMediumText(p.name, maxLines: 1),
                if (pending)
                  BodySmallText(invitationPendingString.tr,
                      color: const Color(0xFFF59E0B)),
              ]),
        ),
        if (mineAndPending && !_busy) ...[
          Icon(Icons.check_circle_rounded, color: AppColorConstants.themeColor)
              .ripple(() => _reply(p, true)),
          const SizedBox(width: 10),
          Icon(Icons.cancel_rounded, color: AppColorConstants.red)
              .ripple(() => _reply(p, false)),
        ] else if (_isOwner &&
            m.status == 1 &&
            p.playerId != _myId &&
            !_busy)
          Icon(Icons.close_rounded, color: AppColorConstants.red)
              .ripple(() => _remove(p)),
      ]),
    );
  }
}

/// Leaderboard ranked by total points from completed matches.
class PickleballTopPlayersScreen extends StatefulWidget {
  const PickleballTopPlayersScreen({super.key});

  @override
  State<PickleballTopPlayersScreen> createState() =>
      _PickleballTopPlayersScreenState();
}

class _PickleballTopPlayersScreenState
    extends State<PickleballTopPlayersScreen> {
  final ScrollController _scroll = ScrollController();
  final List<PickleballTopPlayer> _items = [];
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
    super.dispose();
  }

  void _load() {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    PickleballApi.getTopPlayers(
        page: _page,
        resultCallback: (list, meta) {
          if (!mounted) return;
          setState(() {
            _items.addAll(list.where((e) => e.points > 0));
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
      body: Column(children: [
        backNavigationBar(title: topPlayersString.tr),
        Expanded(
          child: _items.isEmpty && !_loading
              ? Center(
                  child: BodyLargeText(noPlayersYetString.tr,
                      color: AppColorConstants.subHeadingTextColor))
              : ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _items.length + (_loading ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    if (i >= _items.length) {
                      return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()));
                    }
                    final p = _items[i];
                    final medal = i == 0
                        ? const Color(0xFFF59E0B)
                        : i == 1
                            ? const Color(0xFF9CA3AF)
                            : i == 2
                                ? const Color(0xFFB45309)
                                : null;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _pCard(),
                      child: Row(children: [
                        SizedBox(
                            width: 28,
                            child: medal != null
                                ? Icon(Icons.emoji_events_rounded,
                                    color: medal)
                                : BodyMediumText('${i + 1}')),
                        const SizedBox(width: 6),
                        _pAvatar(p.image, p.name, 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BodyMediumText(p.name,
                                    maxLines: 1, weight: TextWeight.semiBold),
                                BodySmallText(
                                    '${p.wins}W · ${p.losses}L · ${p.matches} ${matchesString.tr}'),
                              ]),
                        ),
                        BodyLargeText('${p.points}',
                            weight: TextWeight.bold,
                            color: AppColorConstants.themeColor),
                      ]),
                    );
                  }),
        ),
      ]),
    );
  }
}
