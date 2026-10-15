import 'package:foap/model/user_model.dart';

class AddPreferenceModel {
  int? gender;
  int? ageFrom;
  int? ageTo;
  int? heightFrom;
  int? heightTo;
  int? holisticFrom;
  int? holisticTo;
  int? passionateAbout;

  String? selectedColor;
  String? religion;
  int? status;

  int? smoke;
  int? drink;

  List<InterestModel>? interests;
  List<LanguageModel>? languages;

  AddPreferenceModel();

  factory AddPreferenceModel.fromJson(dynamic json) {
    AddPreferenceModel model = AddPreferenceModel();
    model.gender = json["gander"];
    model.ageFrom = json["age_from"];
    model.ageTo = json["age_to"];
    model.heightFrom = json["height_from"] == null
        ? null
        : json["height_from"] is String
            ? int.parse(json["height_from"])
            : json["height_from"];
    model.heightTo = json["height_to"] == null
        ? null
        : json["height_to"] is String
            ? int.parse(json["height_to"])
            : json["height_to"];

    model.passionateAbout = json["passionate"];
    model.holisticFrom = json["holistic_path_from"];
    model.holisticTo = json["holistic_path_to"];
    model.selectedColor = json["color"];
    model.religion = json["religion"];
    model.status = json["marital_status"];
    model.smoke = json["smoke_id"];
    model.drink = json["drinking_habit"] == null
        ? null
        : json["drinking_habit"] is String
            ? int.parse(json["drinking_habit"])
            : json["drinking_habit"];

    if (json['preferenceInterest'] != null &&
        json['preferenceInterest'].length > 0) {
      model.interests = List<InterestModel>.from(
          json['preferenceInterest'].map((x) => InterestModel.fromJson(x)));
    }

    if (json['preferenceLanguage'] != null &&
        json['preferenceLanguage'].length > 0) {
      model.languages = List<LanguageModel>.from(
          json['preferenceLanguage'].map((x) => LanguageModel.fromJson(x)));
    }
    return model;
  }
}

class AddDatingDataModel {
  String? latitude;
  String? longitude;
  String? name;
  String? dob;
  int? gender;
  int? passionateAbout;
  int? holisticPath;

  String? selectedColor;
  int? height;
  String? religion;
  int? status;
  int? smoke;
  int? drink;
  List<InterestModel>? interests;
  List<LanguageModel>? languages;
  String? qualification;
  String? occupation;
  String? experienceMonth;
  String? experienceYear;

  AddDatingDataModel();
}
