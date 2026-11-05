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
  int redeemable = 0; // earned coins that can be turned into dollars
  int locked = 0; // bought / bonus coins: can be spent, not redeemed
  double perCoinValue = 0; // USD for one coin
  int minRedeem = 0;

  CoinSummary();

  factory CoinSummary.fromJson(dynamic data) {
    final s = CoinSummary();
    s.balance = _int(data['balance']);
    s.redeemable = _int(data['redeemable']);
    s.locked = _int(data['locked']);
    s.perCoinValue = double.tryParse('${data['per_coin_value'] ?? 0}') ?? 0;
    s.minRedeem = _int(data['min_coin_redeem']);
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
