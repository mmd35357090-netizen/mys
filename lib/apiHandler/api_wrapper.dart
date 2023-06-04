import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../helper/enum.dart';
import '../helper/localization_strings.dart';
import '../util/shared_prefs.dart';
import 'network_constant.dart';
export 'api_param_model.dart';
export 'api_response_model.dart';
export 'network_constant.dart';

class ApiResponse {
  bool? success;
  dynamic data;
  String? message;

  ApiResponse();

  factory ApiResponse.fromJson(dynamic json) {
    ApiResponse model = ApiResponse();
    model.success = json['status'] == 200;
    model.data = json['data'];

    if (model.success != true) {
      Map errors = model.data['errors'];
      List errorsArr = errors[errors.keys.first] ?? [];
      if (errorsArr.isNotEmpty) {
        String error = errorsArr.first ?? errorMessageString.tr;
        model.message = error;
      }
    }

    return model;
  }
}

class ApiWrapper {
  final JsonDecoder _decoder = const JsonDecoder();

  Future<ApiResponse?> getApi({required String url}) async {
    String? authKey = await SharedPrefs().getAuthorizationKey();
    String urlString = '${NetworkConstantsUtil.baseUrl}$url';

    return http.get(Uri.parse(urlString), headers: {
      "Authorization": "Bearer ${authKey!}"
    }).then((http.Response response) async {
      dynamic data = _decoder.convert(response.body);
      EasyLoading.dismiss();
      // log(data.toString());
      if (data['status'] == 401 && data['data'] == null) {
        //Get.offAll(() => LoginForExpiredToken());
      } else {
        return ApiResponse.fromJson(data);
      }
      return null;
    });
  }

  Future<ApiResponse?> postApi(
      {required String url, required dynamic param}) async {
    String? authKey = await SharedPrefs().getAuthorizationKey();
    // EasyLoading.show(status: loadingString.tr);

    String urlString = '${NetworkConstantsUtil.baseUrl}$url';

    print(urlString);
    print(param);

    return http.post(Uri.parse(urlString), body: jsonEncode(param), headers: {
      "Authorization": "Bearer ${authKey!}",
      'Content-Type': 'application/json'
    }).then((http.Response response) async {
      dynamic data = _decoder.convert(response.body);
      // EasyLoading.dismiss();
      if (data['status'] == 401 && data['data'] == null) {
        // Get.offAll(() => LoginForExpiredToken());
      } else {
        return ApiResponse.fromJson(data);
      }
      return null;
    });
  }

  Future<ApiResponse?> putApi(
      {required String url, required dynamic param}) async {
    String? authKey = await SharedPrefs().getAuthorizationKey();
    EasyLoading.show(status: loadingString.tr);

    // print(url);
    // print(param);
    // print("Bearer ${authKey!}");

    return http.put(Uri.parse('${NetworkConstantsUtil.baseUrl}$url'),
        body: jsonEncode(param),
        headers: {
          "Authorization": "Bearer ${authKey!}",
          'Content-Type': 'application/json'
        }).then((http.Response response) async {
      dynamic data = _decoder.convert(response.body);
      print(data);
      EasyLoading.dismiss();
      if (data['status'] == 401 && data['data'] == null) {
        // Get.offAll(() => LoginForExpiredToken());
      } else {
        return ApiResponse.fromJson(data);
      }
      return null;
    });
  }

  Future<ApiResponse?> deleteApi({required String url}) async {
    String? authKey = await SharedPrefs().getAuthorizationKey();
    EasyLoading.show(status: loadingString.tr);

    return http.delete(Uri.parse('${NetworkConstantsUtil.baseUrl}$url'),
        headers: {
          "Authorization": "Bearer $authKey",
          'Content-Type': 'application/json'
        }).then((http.Response response) async {
      dynamic data = _decoder.convert(response.body);
      print(data);
      EasyLoading.dismiss();
      if (data['status'] == 401 && data['data'] == null) {
        // Get.offAll(() => LoginForExpiredToken());
      } else {
        return ApiResponse.fromJson(data);
      }
      return null;
    });
  }

  Future<ApiResponse?> postApiWithoutToken(
      {required String url, required dynamic param}) async {
    // EasyLoading.show(status: loadingString.tr);

    return http
        .post(Uri.parse('${NetworkConstantsUtil.baseUrl}$url'), body: param)
        .then((http.Response response) async {
      dynamic data = _decoder.convert(response.body);

      // EasyLoading.dismiss();
      if (data['status'] == 401 && data['data'] == null) {
        // Get.offAll(() => LoginForExpiredToken());
      } else {
        return ApiResponse.fromJson(data);
      }
      return null;
    });
  }

  Future<ApiResponse?> multipartImageUpload(
      {required String url, required Uint8List imageFileData}) async {
    EasyLoading.show(status: loadingString.tr);

    String? authKey = await SharedPrefs().getAuthorizationKey();
    var postUri = Uri.parse('${NetworkConstantsUtil.baseUrl}$url');
    var request = http.MultipartRequest("POST", postUri);
    request.headers.addAll({"Authorization": "Bearer ${authKey!}"});

    request.files.add(http.MultipartFile.fromBytes('imageFile', imageFileData,
        filename: '${DateTime.now().toIso8601String()}.jpg',
        contentType: MediaType('image', 'jpg')));

    return request.send().then((response) async {
      final respStr = await response.stream.bytesToString();
      EasyLoading.dismiss();

      dynamic data = _decoder.convert(respStr);

      if (data['status'] == 401 && data['data'] == null) {
        // Get.offAll(() => LoginForExpiredToken());
      } else {
        return ApiResponse.fromJson(data);
      }
    });
  }

  Future<ApiResponse?> uploadFile(
      {required String file,
      required UploadMediaType type,
      required String url}) async {
    EasyLoading.show(status: loadingString.tr);

    var request = http.MultipartRequest(
        'POST', Uri.parse('${NetworkConstantsUtil.baseUrl}$url'));
    String? authKey = await SharedPrefs().getAuthorizationKey();
    request.headers.addAll({"Authorization": "Bearer ${authKey!}"});
    request.fields.addAll({'type': uploadMediaTypeId(type).toString()});
    request.files.add(await http.MultipartFile.fromPath('mediaFile', file));
    var res = await request.send();
    var responseData = await res.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    dynamic data = _decoder.convert(responseString);

    EasyLoading.dismiss();
    if (data['status'] == 401 && data['data'] == null) {
      // Get.offAll(() => LoginForExpiredToken());
    } else {
      print('data ${data}');
      return ApiResponse.fromJson(data);
    }
    return null;
  }

  Future<ApiResponse?> uploadPostFile(
      {required String file, required String url}) async {
    EasyLoading.show(status: loadingString.tr);

    var request = http.MultipartRequest(
        'POST', Uri.parse('${NetworkConstantsUtil.baseUrl}$url'));
    String? authKey = await SharedPrefs().getAuthorizationKey();
    request.headers.addAll({"Authorization": "Bearer ${authKey!}"});
    request.files.add(await http.MultipartFile.fromPath('filenameFile', file));
    var res = await request.send();
    var responseData = await res.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    dynamic data = _decoder.convert(responseString);

    EasyLoading.dismiss();
    if (data['status'] == 401 && data['data'] == null) {
      // Get.offAll(() => LoginForExpiredToken());
    } else {
      return ApiResponse.fromJson(data);
    }
    return null;
  }

  int uploadMediaTypeId(UploadMediaType type) {
    switch (type) {
      case UploadMediaType.post:
        return 1;
      case UploadMediaType.storyOrHighlights:
        return 3;
      case UploadMediaType.chat:
        return 5;
      case UploadMediaType.club:
        return 5;
      case UploadMediaType.verification:
        return 12;
    }
  }
}
