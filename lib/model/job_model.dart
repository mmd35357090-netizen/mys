import 'package:foap/model/user_model.dart';
import 'category_model.dart';

class JobModel {
  int id;
  String title;
  String description;
  String skills;
  int minExperience;
  int maxExperience;
  double minSalary;
  double maxSalary;
  String education;

  String country;
  String state;
  String city;

  UserModel? postedBy;
  CategoryModel? category;
  bool isApplied;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.postedBy,
    required this.category,
    required this.education,
    required this.minExperience,
    required this.minSalary,
    required this.maxExperience,
    required this.maxSalary,
    required this.isApplied,
    required this.skills,
    required this.country,
    required this.state,
    required this.city,
  });

  factory JobModel.fromJson(dynamic json) {
    JobModel model = JobModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      skills: json['skill'],
      education: json['education'],
      minExperience: json['experience_min'],
      maxExperience: json['experience_max'],
      minSalary: double.parse(json['salary_min'].toString()),
      maxSalary: double.parse(json['salary_max'].toString()),
      isApplied: json['applied_status'] == 1,
      country: json['country_name'].toString(),
      state: json['state_name'].toString(),
      city: json['city_name'].toString(),
      postedBy: json['organization'] == null
          ? null
          : UserModel.fromJson(json['organization']),
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category']),
    );

    return model;
  }
}

class JobSearchModel {
  int? categoryId;
  String? title;

  JobSearchModel();
}
