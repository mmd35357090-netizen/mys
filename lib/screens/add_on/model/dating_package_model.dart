class DatingPackageModel {
  int id = 0;
  String name = '';
  int numberOfProfiles = 0;
  int duration = 0; // 1 week, 2 month, 3 three months, 4 six months, 5 year
  int coin = 0;
  bool isDefault = false;

  DatingPackageModel();

  factory DatingPackageModel.fromJson(dynamic json) {
    DatingPackageModel model = DatingPackageModel();
    model.id = json['id'] ?? 0;
    model.name = (json['name'] ?? '').toString();
    model.numberOfProfiles =
        int.tryParse((json['number_of_profiles'] ?? 0).toString()) ?? 0;
    model.duration = int.tryParse((json['duration'] ?? 0).toString()) ?? 0;
    model.coin = int.tryParse((json['coin'] ?? 0).toString()) ?? 0;
    model.isDefault = (json['is_default'] ?? 0).toString() == '1';
    return model;
  }

  String get durationLabel {
    switch (duration) {
      case 1:
        return '1 week';
      case 2:
        return '1 month';
      case 3:
        return '3 months';
      case 4:
        return '6 months';
      case 5:
        return '1 year';
    }
    return '';
  }
}
