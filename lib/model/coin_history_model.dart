class CoinHistoryEntry {
  int id = 0;
  int coin = 0;
  bool isCredit = true;
  String category = 'earned'; // bought | earned | spent | refund
  String title = '';
  int createdAt = 0;

  CoinHistoryEntry();

  factory CoinHistoryEntry.fromJson(dynamic json) {
    final e = CoinHistoryEntry();
    e.id = _int(json['id']);
    e.coin = _int(json['coin']);
    e.isCredit = _int(json['transaction_type']) == 1;
    e.category = (json['category'] ?? 'earned').toString();
    e.title = (json['title'] ?? '').toString();
    e.createdAt = _int(json['created_at']);
    return e;
  }
}

class CoinSummary {
  int balance = 0;
  int bought = 0;
  int earned = 0;
  int spent = 0;
  int refunded = 0;

  CoinSummary();

  factory CoinSummary.fromJson(dynamic data) {
    final s = CoinSummary();
    s.balance = _int(data['balance']);
    final m = data['summary'];
    if (m is Map) {
      s.bought = _int(m['bought']);
      s.earned = _int(m['earned']);
      s.spent = _int(m['spent']);
      s.refunded = _int(m['refunded']);
    }
    return s;
  }
}

int _int(dynamic v) {
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}
