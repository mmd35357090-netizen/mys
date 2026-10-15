import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/audience_model.dart';
import 'package:foap/model/post_model.dart';

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

    model.type = json['type'] == 4
        ? GoalType.website
        : json['type'] == 2
            ? GoalType.message
            : GoalType.profile;
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

  // double? tax;

  // double? grandAmount;
  int duration = 2;

  List<Payment> payments = [];

  PostPromotionOrderRequest();

  Map<String, dynamic> toJson() => {
        "post_id": post?.id.toString(),
        "type": goalType == GoalType.website
            ? '4'
            : goalType == GoalType.message
                ? '2'
                : '1',
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
    return (dailyBudget * (duration)) * 0.18;
  }

  double get totalAmount {
    return (dailyBudget * (duration));
  }

  double get grandTotalAmount {
    return (dailyBudget * (duration)) + gst;
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
