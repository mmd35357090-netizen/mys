
class RegionalLocationModel {
  int id = 0;
  String fullName = '';
  String type = '';

  RegionalLocationModel();

  factory RegionalLocationModel.fromJson(dynamic json) {
    RegionalLocationModel model = RegionalLocationModel();
    model.id = json['id'];
    model.fullName = json['fullname'] ;
    model.type = json['type'] ;

    return model;
  }
}