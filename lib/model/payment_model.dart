import 'package:intl/intl.dart';
import '../helper/enum.dart';
import '../helper/enum_linking.dart';
import '../util/app_util.dart';

class TransactionModel {
  int id = 0;
  double? amount;
  int? coins;

  int status = 0;
  String createDate = '';
  PaymentType paymentType = PaymentType.package;
  TransactionType transactionType = TransactionType.credit;
  PaymentMode paymentMode = PaymentMode.inAppPurchase;
  TransactionMedium transactionMedium = TransactionMedium.money;

  TransactionModel();

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int _toInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? (double.tryParse(v.toString())?.toInt() ?? fallback);
  }

  // Tolerant parsing: a whole-number amount (e.g. 2 instead of 2.0), a numeric
  // string, or a missing field must never make the whole list disappear.
  factory TransactionModel.fromJson(dynamic json) {
    TransactionModel model = TransactionModel();
    model.id = _toInt(json['id']);
    model.amount = _toDouble(json['amount']);
    model.coins = json['coin'] == null ? null : _toInt(json['coin']);

    model.status = _toInt(json['status'], 10);
    model.paymentType = paymentTypeFromId(_toInt(json['payment_type']));
    model.transactionType =
        transactionTypeFromId(_toInt(json['transaction_type']));
    model.paymentMode = paymentModeFromId(_toInt(json['payment_mode']));
    model.transactionMedium =
        transactionMediumTypeFromId(_toInt(json['type'], 1));

    DateTime createDate =
        AppUtil.convertToDateTime(_toInt(json['created_at']));
    String dateString = DateFormat('MMM dd, yyyy').format(createDate);
    model.createDate = dateString;

    return model;
  }
}
