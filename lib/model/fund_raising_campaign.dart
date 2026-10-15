import 'package:foap/model/post_promotion_model.dart';
import 'package:foap/model/user_model.dart';

import '../util/app_util.dart';
import 'category_model.dart';

class FundRaisingCampaign {
  int id;
  String title;
  String description;
  String coverImage;
  DateTime startDate;
  DateTime endDate;
  DateTime createdDate;
  double targetValue;
  double raisedValue;
  List<String> allImages;
  UserModel? createdBy;
  UserModel? createdFor;
  CategoryModel? category;

  bool isFavourite;
  bool isDonor;
  int totalDonors;
  List<UserModel> donors = [];

  FundRaisingCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.createdDate,
    required this.targetValue,
    required this.raisedValue,
    required this.allImages,
    required this.createdBy,
    required this.createdFor,
    required this.isFavourite,
    required this.isDonor,
    required this.totalDonors,
    required this.donors,
    required this.category,
  });

  factory FundRaisingCampaign.fromJson(dynamic json) {
    FundRaisingCampaign model = FundRaisingCampaign(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        coverImage: json['coverImageUrl'],
        startDate: AppUtil.convertToDateTime(json['start_date']),
        endDate: AppUtil.convertToDateTime(json['end_date']),
        createdDate: AppUtil.convertToDateTime(json['created_at']),
        targetValue: double.parse(json['target_value'].toString()),
        raisedValue: json['raised_value'] == null
            ? 0.0
            : double.parse(json['raised_value'].toString()),
        allImages: json['campaginAllImage'] != null
            ? (json['campaginAllImage'] as List)
                .map((e) => e['campaginImage'] as String)
                .toList()
            : [],
        createdBy: json['compaigner'] == null
            ? null
            : UserModel.fromJson(json['compaigner']),
        createdFor: json['compaigner_for'] == null
            ? null
            : UserModel.fromJson(json['compaigner_for']),
        category: json['categoryDetails'] == null
            ? null
            : CategoryModel.fromJson(json['categoryDetails']),
        isFavourite: json['is_favorite'] == 1,
        isDonor: json['is_donor'] == 1,
        totalDonors: json['total_donors'] ?? 0,
        donors: json['donorsDetails'] is List
            ? (json['donorsDetails'] as List)
                .map((e) => UserModel.fromJson(e))
                .toList()
            : []);

    return model;
  }

  bool get amIDonor {
    return isDonor;
  }
}

class FundRaisingCampaignSearchModel {
  int? categoryId;
  String? title;
  int? campaignerId;
  int? campaignForId;

  FundRaisingCampaignSearchModel();
}

class FundraisingDonationRequest {
  int? campaignId;
  double? totalAmount;
  String? itemName;

  List<Payment> payments;

  FundraisingDonationRequest({
    this.campaignId,
    this.totalAmount,
    required this.payments,
  });

  Map<String, dynamic> toJson() => {
        "id": campaignId.toString(),
        "payments": payments.map((e) => e.toJson()).toList(),
        "amount": totalAmount.toString(),
      };
}
