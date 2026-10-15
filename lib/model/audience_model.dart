import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/regional_location_model.dart';

class AudienceModel {
  int id = 0;
  int userId = 0;
  String name = '';

  String gender = '1';
  int ageStartRange = 0;
  int ageEndRange = 0;

  int locationType = 0;
  int radius = 0;
  String latitude = '';
  String longitude = '';

  int countryId = 0;
  int stateId = 0;
  int cityId = 0;

  List<InterestModel> interests = [];
  List<RegionalLocationModel> regions = [];

  AudienceModel();

  factory AudienceModel.fromJson(dynamic json) {
    AudienceModel model = AudienceModel();
    model.id = json['id'] ?? 0;
    model.userId = json['user_id'] ?? 0;
    model.name = json['name'] ?? '';

    model.gender = json['gender'] == '1'
        ? maleString.tr
        : json['gender'] == '2'
            ? femaleString.tr
            : otherString.tr;
    model.ageStartRange = json['age_start_range'] ?? 0;
    model.ageEndRange = json['age_end_range'] ?? 0;

    model.locationType = json['location_type'] ?? 1;
    model.radius = json['radius'] ?? 0;
    model.latitude = json['latitude'] ?? '';
    model.longitude = json['longitude'] ?? '';

    model.countryId = json['country_id'] ?? 0;
    model.stateId = json['state_id'] ?? 0;
    model.cityId = json['city_id'] ?? 0;

    model.interests = List<InterestModel>.from(
        json['interestDetails'].map((x) => InterestModel.fromAudienceJson(x)));

    model.regions = List<RegionalLocationModel>.from(
        json['locationDetails'].map((x) => RegionalLocationModel.fromJson(x)));

    return model;
  }
}
