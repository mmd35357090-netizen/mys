// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:foap/apiHandler/api_wrapper.dart';
// import 'package:foap/screens/add_on/model/preference_model.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:foap/helper/imports/common_import.dart';
// import '../screens/add_on/controller/dating/dating_controller.dart';
// import 'package:foap/helper/imports/api_imports.dart';
// import '../util/constant_util.dart';
// import '../util/shared_prefs.dart';
// export 'package:foap/apiHandler/api_response_model.dart';
// import 'package:get/get.dart';
//
// class ApiController {
//   final JsonDecoder _decoder = const JsonDecoder();
//
//   // **************** Post ***************** //
//
//   // Future<ApiResponseModel> uploadPostMedia(String file) async {
//   //   var url =
//   //       NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.uploadPostImage;
//   //   var request = http.MultipartRequest('POST', Uri.parse(url));
//   //   String? authKey = await SharedPrefs().getAuthorizationKey();
//   //   request.headers.addAll({"Authorization": "Bearer ${authKey!}"});
//   //   request.files.add(await http.MultipartFile.fromPath('filenameFile', file));
//   //   var res = await request.send();
//   //   var responseData = await res.stream.toBytes();
//   //   var responseString = String.fromCharCodes(responseData);
//   //   final ApiResponseModel parsedResponse =
//   //       await getResponse(responseString, NetworkConstantsUtil.uploadPostImage);
//   //
//   //   return parsedResponse;
//   // }
//
//   // Future<ApiResponseModel> uploadFile(
//   //     {required String file, required UploadMediaType type}) async {
//   //   var url =
//   //       NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.uploadFileImage;
//   //   var request = http.MultipartRequest('POST', Uri.parse(url));
//   //   String? authKey = await SharedPrefs().getAuthorizationKey();
//   //   request.headers.addAll({"Authorization": "Bearer ${authKey!}"});
//   //   request.fields.addAll({'type': uploadMediaTypeId(type).toString()});
//   //   request.files.add(await http.MultipartFile.fromPath('mediaFile', file));
//   //   var res = await request.send();
//   //   var responseData = await res.stream.toBytes();
//   //   var responseString = String.fromCharCodes(responseData);
//   //   final ApiResponseModel parsedResponse =
//   //       await getResponse(responseString, NetworkConstantsUtil.uploadFileImage);
//   //
//   //   return parsedResponse;
//   // }
//
//   // Future<ApiResponseModel> findFriends(
//   //     {required int isExactMatch,
//   //     required String searchText,
//   //     SearchFrom? searchFrom,
//   //     int page = 1}) async {
//   //   String? authKey = await SharedPrefs().getAuthorizationKey();
//   //   var url = NetworkConstantsUtil.baseUrl + NetworkConstantsUtil.findFriends;
//   //
//   //   //searchFrom  ----- 1=username,2=email,3=phone
//   //
//   //   String searchFromValue = searchFrom == null
//   //       ? ''
//   //       : searchFrom == SearchFrom.username
//   //           ? '1'
//   //           : searchFrom == SearchFrom.email
//   //               ? '2'
//   //               : '3';
//   //   url =
//   //       '${url}searchText=$searchText&searchFrom=$searchFromValue&isExactMatch=$isExactMatch&page=$page';
//   //
//   //   return await http.get(Uri.parse(url), headers: {
//   //     "Authorization": "Bearer ${authKey!}"
//   //   }).then((http.Response response) async {
//   //     final ApiResponseModel parsedResponse = await getArrayResponse(
//   //         response.body, NetworkConstantsUtil.findFriends);
//   //     return parsedResponse;
//   //   });
//   // }
//
//
//
// }
