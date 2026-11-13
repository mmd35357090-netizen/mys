class PickleballCourtModel {
  int id = 0;
  String name = '';
  String address = '';
  String imageUrl = '';
  bool indoor = false;
  double distance = 0;

  factory PickleballCourtModel.fromJson(dynamic json) {
    final m = PickleballCourtModel._();
    m.id = json['id'] ?? 0;
    m.name = (json['name'] ?? '').toString();
    m.address = (json['address'] ?? '').toString();
    m.imageUrl = (json['imageUrl'] ?? '').toString();
    m.indoor = (json['type'] ?? 1).toString() == '2';
    m.distance = double.tryParse((json['distance'] ?? 0).toString()) ?? 0;
    return m;
  }

  PickleballCourtModel._();
}

class PickleballPlayerModel {
  int teamPlayerId = 0;
  int playerId = 0;
  int status = 0; // 1 pending, 2 rejected, 10 active
  String name = '';
  String image = '';
  int points = 0;

  PickleballPlayerModel._();

  factory PickleballPlayerModel.fromJson(dynamic json) {
    final m = PickleballPlayerModel._();
    m.teamPlayerId = json['id'] ?? 0;
    m.playerId = int.tryParse((json['player_id'] ?? 0).toString()) ?? 0;
    m.status = int.tryParse((json['status'] ?? 0).toString()) ?? 0;
    m.points = int.tryParse((json['point_gain'] ?? 0).toString()) ?? 0;
    final d = json['playerDetail'];
    if (d != null) {
      m.name = (d['name'] ?? d['username'] ?? '').toString();
      m.image = (d['picture'] ?? d['image'] ?? '').toString();
    }
    return m;
  }
}

class PickleballTeamModel {
  int id = 0;
  String name = '';
  int winnerStatus = 0; // 0 not declared, 1 won, 2 lost
  List<PickleballPlayerModel> players = [];

  PickleballTeamModel._();

  factory PickleballTeamModel.fromJson(dynamic json) {
    final m = PickleballTeamModel._();
    m.id = json['id'] ?? 0;
    m.name = (json['name'] ?? '').toString();
    m.winnerStatus = int.tryParse((json['winner_status'] ?? 0).toString()) ?? 0;
    final p = json['teamPlayer'];
    if (p is List) {
      m.players = p.map((e) => PickleballPlayerModel.fromJson(e)).toList();
    }
    return m;
  }
}

class PickleballMatchModel {
  int id = 0;
  int matchType = 1; // 1 singles, 2 doubles
  int pointToWin = 0;
  int startTime = 0;
  int status = 1; // 1 ongoing, 2 cancelled, 10 completed
  int winnerTeamId = 0;
  int createdBy = 0;
  PickleballCourtModel? court;
  List<PickleballTeamModel> teams = [];

  PickleballMatchModel._();

  bool get isCompleted => status == 10;

  factory PickleballMatchModel.fromJson(dynamic json) {
    final m = PickleballMatchModel._();
    m.id = json['id'] ?? 0;
    m.matchType = int.tryParse((json['match_type'] ?? 1).toString()) ?? 1;
    m.pointToWin = int.tryParse((json['point_to_win'] ?? 0).toString()) ?? 0;
    m.startTime = int.tryParse((json['start_time'] ?? 0).toString()) ?? 0;
    m.status = int.tryParse((json['status'] ?? 1).toString()) ?? 1;
    m.winnerTeamId =
        int.tryParse((json['winner_team_id'] ?? 0).toString()) ?? 0;
    m.createdBy = int.tryParse((json['created_by'] ?? 0).toString()) ?? 0;
    if (json['court'] != null) {
      m.court = PickleballCourtModel.fromJson(json['court']);
    }
    final t = json['matchTeam'];
    if (t is List) {
      m.teams = t.map((e) => PickleballTeamModel.fromJson(e)).toList();
    }
    return m;
  }
}

class PickleballTopPlayer {
  int id = 0;
  String name = '';
  String image = '';
  int points = 0;
  int wins = 0;
  int losses = 0;
  int matches = 0;

  PickleballTopPlayer._();

  factory PickleballTopPlayer.fromJson(dynamic json) {
    final m = PickleballTopPlayer._();
    m.id = json['id'] ?? 0;
    m.name = (json['name'] ?? json['username'] ?? '').toString();
    m.image = (json['picture'] ?? '').toString();
    final s = json['pickleballSummary'];
    if (s != null) {
      m.points = int.tryParse((s['totalPoint'] ?? 0).toString()) ?? 0;
      m.wins = int.tryParse((s['totalWin'] ?? 0).toString()) ?? 0;
      m.losses = int.tryParse((s['totalLoss'] ?? 0).toString()) ?? 0;
      m.matches = int.tryParse((s['totalMatch'] ?? 0).toString()) ?? 0;
    }
    return m;
  }
}
