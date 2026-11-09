import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/audience_model.dart';
import 'package:foap/model/post_model.dart';

/// Goal codes used by the server: 1 profile, 2 message, 4 website, 5 WhatsApp, 6 call, 7 only reach.
GoalType goalTypeFromCode(dynamic code) {
  switch (int.tryParse('$code') ?? 1) {
    case 2:
      return GoalType.message;
    case 4:
      return GoalType.website;
    case 5:
      return GoalType.whatsapp;
    case 6:
      return GoalType.call;
    case 7:
      return GoalType.reach;
    default:
      return GoalType.profile;
  }
}

int goalTypeCode(GoalType? type) {
  switch (type) {
    case GoalType.message:
      return 2;
    case GoalType.website:
      return 4;
    case GoalType.whatsapp:
      return 5;
    case GoalType.call:
      return 6;
    case GoalType.reach:
      return 7;
    default:
      return 1;
  }
}

class PostPromotionModel {
  int id = 0;
  int postId = 0;

  GoalType? type;
  String? url;
  String? urlText;

  PostPromotionModel();

  factory PostPromotionModel.fromJson(dynamic json) {
    PostPromotionModel model = PostPromotionModel();
    model.id = json['id'];
    model.postId = json['post_id'];

    model.type = goalTypeFromCode(json['type']);
    model.url = json['url'];
    model.urlText = json['url_text'];
    return model;
  }
}

class PostPromotionOrderRequest {
  PostModel? post;
  GoalType? goalType;

  String? url;
  String? urlText;
  int isAutomaticAudience = 1;
  AudienceModel? audience;
  double dailyBudget = 200;

  // Tax percentage. The server decides it (see PromotionController.loadPricing);
  // the server also recalculates the price, so this only has to match for display.
  double taxPercent = 18;

  // double? tax;

  // double? grandAmount;
  int duration = 2;

  List<Payment> payments = [];

  PostPromotionOrderRequest();

  Map<String, dynamic> toJson() => {
        "post_id": post?.id.toString(),
        "type": goalTypeCode(goalType).toString(),
        "url": url ?? '',
        "url_text": urlText ?? '',
        "is_audience_automatic": audience?.id == null ? 1 : 0,
        "audience_id": audience?.id == null ? '' : audience?.id.toString(),
        "amount": dailyBudget.toString(),
        "duration": duration.toString(),
        "total_amount": totalAmount,
        "tax": gst.toString(),
        "grand_amount": grandTotalAmount.toString(),
        "payments": payments.map((e) => e.toJson()).toList(),
      };

  double get gst {
    return double.parse((totalAmount * taxPercent / 100).toStringAsFixed(2));
  }

  double get totalAmount {
    return (dailyBudget.roundToDouble() * duration);
  }

  double get grandTotalAmount {
    return double.parse((totalAmount + gst).toStringAsFixed(2));
  }
}

class Payment {
  String? paymentMode;
  String? amount;
  String? transactionId;

  Payment();

  Map<String, dynamic> toJson() => {
        "payment_mode": paymentMode.toString(),
        "amount": amount.toString(),
        "transaction_id": transactionId.toString(),
      };
}
