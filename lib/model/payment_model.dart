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

  factory TransactionModel.fromJson(dynamic json) {
    TransactionModel model = TransactionModel();
    model.id = json['id'];
    model.amount = json['amount'];
    model.coins = json['coin'];

    model.status = json['status'];
    model.paymentType = paymentTypeFromId(json['payment_type']);
    model.transactionType =
        transactionTypeFromId(json['transaction_type']);
    model.paymentMode = paymentModeFromId(json['payment_mode']);
    model.transactionMedium = transactionMediumTypeFromId(json['type']);

    DateTime createDate = AppUtil.convertToDateTime(json['created_at']);
    String dateString = DateFormat('MMM dd, yyyy').format(createDate);
    model.createDate = dateString;

    return model;
  }
}
