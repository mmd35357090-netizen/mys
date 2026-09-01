import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../helper/enum_linking.dart';
import '../main.dart';
import '../screens/login_sign_up/login_screen.dart';
import '../util/shared_prefs.dart';
import 'network_constant.dart';
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
    model.message = json['message'];

    if (json['status'] == 401) {
      // go to login
      if (isAnyPageInStack) {
        Get.offAll(() => const LoginScreen());
      }
    }
    if (model.success != true &&
        model.data != null &&
        model.message?.isEmpty == true) {
      var errors = model.data['errors'];
      if (errors != null) {
        var messages = model.data['errors']['message'];
        if (messages != null) {
          model.message = (messages as List).first;
        } else {
          if (model.data['errors'] is Map) {
            List errors = (model.data['errors'] as Map).values.first;
            model.message = errors.first;
          }
        }
      }
    }

    return model;
  }
}

class ApiWrapper {
  final JsonDecoder _decoder = const JsonDecoder();

  Future<ApiResponse?> getApiWithoutToken({required String url}) async {
    String urlString = '${NetworkConstantsUtil.baseUrl}$url';

    final connectivityResult = await (Connectivity().checkConnectivity());

    if (!connectivityResult.contains(ConnectivityResult.none)) {
      return http
          .get(Uri.parse(urlString))
          .then((http.Response response) async {
        dynamic data = _decoder.convert(response.body);
        EasyLoading.dismiss();
        SharedPrefs()
            .setApiResponse(url: urlString, response: response.body);

        return ApiResponse.fromJson(data);
      });
    } else {
      EasyLoading.dismiss();
      String? cachedResponse =
      await SharedPrefs().getCachedApiResponse(url: urlString);

      if (cachedResponse != null) {
        dynamic data = _decoder.convert(cachedResponse);
        return ApiResponse.fromJson(data);
      }
    }
    return null;
  }

  Future<ApiResponse?> getApi({required String url}) async {
    String? authKey = await SharedPrefs().getAuthorizationKey();
    String urlString = '${NetworkConstantsUtil.baseUrl}$url';

    final connectivityResult = await (Connectivity().checkConnectivity());

    print(authKey);
    print(urlString);

    if (!connectivityResult.contains(ConnectivityResult.none)) {
      return http.get(Uri.parse(urlString), headers: {
        "Authorization": "Bearer ${authKey!}"
      }).then((http.Response response) async {
        dynamic data = _decoder.convert(response.body);
        EasyLoading.dismiss();
        SharedPrefs()
            .setApiResponse(url: urlString, response: response.body);

        return ApiResponse.fromJson(data);
      });
    } else {
      EasyLoading.dismiss();
      String? cachedResponse =
      await SharedPrefs().getCachedApiResponse(url: urlString);

      if (cachedResponse != null) {
        dynamic data = _decoder.convert(cachedResponse);
        return ApiResponse.fromJson(data);
      }
    }
    return null;
  }

  Future<ApiResponse?> postApi(
      {required String url, required dynamic param}) async {
    String? authKey = await SharedPrefs().getAuthorizationKey();

    String urlString = '${NetworkConstantsUtil.baseUrl}$url';
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return null;
    }
    print('authKey $authKey');
    print('urlString $urlString');
    print('param $param');

    return http.post(Uri.parse(urlString),
        body: jsonEncode(param),
        headers: {
          "Authorization": "Bearer ${authKey!}",
          'Content-Type': 'application/json'
        }).then((http.Response response) async {
      dynamic data = _decoder.convert(response.body);
      print(data);
      return ApiResponse.fromJson(data);
    });
  }

  Future<ApiResponse?> putApi(
      {required String url, required dynamic param}) async {
    String? authKey = await SharedPrefs().getAuthorizationKey();
    EasyLoading.show(status: loadingString.tr);

    return http.put(Uri.parse('${NetworkConstantsUtil.baseUrl}$url'),
        body: jsonEncode(param),
        headers: {
          "Authorization": "Bearer ${authKey!}",
          'Content-Type': 'application/json'
        }).then((http.Response response) async {
      dynamic data = _decoder.convert(response.body);
      // print(data);
      EasyLoading.dismiss();

      return ApiResponse.fromJson(data);
    });
  }

  Future<ApiResponse?> deleteApi({required String url}) async {
    String? authKey = await SharedPrefs().getAuthorizationKey();
    EasyLoading.show(status: loadingString.tr);

    // print('${NetworkConstantsUtil.baseUrl}$url');
    return http.delete(Uri.parse('${NetworkConstantsUtil.baseUrl}$url'),
        headers: {
          "Authorization": "Bearer $authKey",
          'Content-Type': 'application/json'
        }).then((http.Response response) async {
      dynamic data = _decoder.convert(response.body);
      // print(data);
      EasyLoading.dismiss();

      return ApiResponse.fromJson(data);
    });
  }

  Future<ApiResponse?> postApiWithoutToken(
      {required String url, required dynamic param}) async {
    // EasyLoading.show(status: loadingString.tr);

    print('urlString ${'${NetworkConstantsUtil.baseUrl}$url'}');
    print('param $param');

    return http
        .post(Uri.parse('${NetworkConstantsUtil.baseUrl}$url'),
        body: param)
        .then((http.Response response) async {
      dynamic data = _decoder.convert(response.body);
      print(data);
      return ApiResponse.fromJson(data);
    });
  }

  Future<ApiResponse?> multipartImageUpload(
      {required String url, required Uint8List imageFileData}) async {
    EasyLoading.show(status: loadingString.tr);

    print('url ${'${NetworkConstantsUtil.baseUrl}$url'}');
    String? authKey = await SharedPrefs().getAuthorizationKey();
    var postUri = Uri.parse('${NetworkConstantsUtil.baseUrl}$url');
    var request = http.MultipartRequest("POST", postUri);
    request.headers.addAll({"Authorization": "Bearer ${authKey!}"});

    request.files.add(http.MultipartFile.fromBytes(
        'imageFile', imageFileData,
        filename: '${DateTime.now().toIso8601String()}.jpg',
        contentType: MediaType('image', 'jpg')));

    return request.send().then((response) async {
      final respStr = await response.stream.bytesToString();
      EasyLoading.dismiss();

      dynamic data = _decoder.convert(respStr);

      print('data = $data');
      return ApiResponse.fromJson(data);
    });
  }

  Future<ApiResponse?> uploadFile(
      {required String file,
        required UploadMediaType type,
        required GalleryMediaType mediaType,
        required String url}) async {
    EasyLoading.show(status: loadingString.tr);
    String? authKey = await SharedPrefs().getAuthorizationKey();

    print('${NetworkConstantsUtil.baseUrl}$url');
    print("Bearer ${authKey!}");
    print(uploadMediaTypeId(type).toString());

    var request = http.MultipartRequest(
        'POST', Uri.parse('${NetworkConstantsUtil.baseUrl}$url'));
    request.headers.addAll({"Authorization": "Bearer ${authKey!}"});
    request.fields.addAll({'type': uploadMediaTypeId(type).toString()});
    if (mediaType == GalleryMediaType.video) {
      request.files.add(await http.MultipartFile.fromPath(
          'mediaFile', file,
          contentType: MediaType('video', 'mp4')));
    } else if (mediaType == GalleryMediaType.audio) {
      request.files.add(await http.MultipartFile.fromPath(
          'mediaFile', file,
          contentType: MediaType('audio', 'mp3')));
    } else {
      request.files
          .add(await http.MultipartFile.fromPath('mediaFile', file));
    }
    var res = await request.send();
    var responseData = await res.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    dynamic data = _decoder.convert(responseString);
    print('data $data');
    EasyLoading.dismiss();

    return ApiResponse.fromJson(data);
  }
}
