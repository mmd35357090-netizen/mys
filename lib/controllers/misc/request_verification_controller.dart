import 'package:foap/api_handler/apis/profile_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/verification_request_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../api_handler/apis/misc_api.dart';

class RequestVerificationController extends GetxController {
  RxList<VerificationRequest> verificationRequests =
      <VerificationRequest>[].obs;

  Rx<TextEditingController> messageTf = TextEditingController().obs;
  Rx<TextEditingController> documentType =
      TextEditingController(text: nidString.tr).obs;

  Rx<TextEditingController> documentNumber = TextEditingController().obs;

  RxList<File> selectedImages = <File>[].obs;

  bool get isVerificationInProcess {
    return verificationRequests
        .where((request) => request.isProcessing == true)
        .toList()
        .isNotEmpty;
  }

  bool get isApproved {
    return verificationRequests
        .where((request) => request.isApproved == true)
        .toList()
        .isNotEmpty;
  }

  static const int maxFailedAttempts = 3;

  // requests the admin rejected
  int get failedAttempts =>
      verificationRequests.where((request) => request.isRejected).length;

  int get attemptsLeft => (maxFailedAttempts - failedAttempts).clamp(0, 3).toInt();

  // 3 rejected requests: the account can not apply again
  bool get isBlocked => failedAttempts >= maxFailedAttempts && !isApproved;

  String get lastAdminMessage {
    final rejected = verificationRequests
        .where((request) => request.isRejected)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return rejected.isEmpty ? '' : (rejected.first.adminMessage ?? '');
  }

  String get verifiedOn {
    final approved =
        verificationRequests.where((request) => request.isApproved).toList();
    if (approved.isEmpty) return '';
    int verifiedOn = approved.first.updatedAt ?? approved.first.createdAt;

    return DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(verifiedOn * 1000));
  }

  String get requestSentOn {
    int verifiedOn = verificationRequests
        .where((request) => request.isProcessing == true)
        .toList()
        .first
        .createdAt;

    return DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(verifiedOn * 1000));
  }

  clear() {
    documentType.value.text = nidString.tr;
    messageTf.value.text = '';
    documentNumber.value.text = '';
    selectedImages.clear();
  }

  getVerificationRequests() {
    ProfileApi.getVerificationRequestHistory(resultCallback: (result) {
      verificationRequests.value = result;
      verificationRequests.refresh();
      update();
    });
  }

  setSelectedDocumentType(String document) {
    documentType.value.text = document;
    documentType.refresh();
  }

  addDocument(File file) {
    selectedImages.add(file);
  }

  deleteDocument(File file) {
    selectedImages.remove(file);
  }

  submitRequest(BuildContext context) async {
    if (documentType.value.text.isEmpty) {
      AppUtil.showToast(
          message: pleaseSelectDocumentTypeString.tr, isSuccess: false);
      return;
    }
    final number = documentNumber.value.text.trim();
    final isNid = documentType.value.text == nidString.tr;
    final isOther = documentType.value.text == otherString.tr;
    if (!isOther && number.isEmpty) {
      AppUtil.showToast(
          message: 'Please enter your document number', isSuccess: false);
      return;
    }
    if (isNid && !RegExp(r'^(\d{10}|\d{13}|\d{17})$').hasMatch(number)) {
      AppUtil.showToast(
          message: 'NID number must be 10, 13 or 17 digits', isSuccess: false);
      return;
    }
    if (number.isNotEmpty && number.length < 4) {
      AppUtil.showToast(
          message: 'Document number is too short', isSuccess: false);
      return;
    }
    if (selectedImages.isEmpty) {
      AppUtil.showToast(message: pleaseUploadProofString.tr, isSuccess: false);
      return;
    }

    List<Map<String, String>> idProofImages = [];

    Loader.show(status: loadingString.tr);
    for (File file in selectedImages) {
      await MiscApi.uploadFile(file.path,
          mediaType: GalleryMediaType.photo, type: UploadMediaType.verification,
          resultCallback: (fileName, filePath) {
        Map<String, String> proof = {
          'filename': fileName,
          'media_type': '1',
          'title': '',
        };
        idProofImages.add(proof);
      });
    }

    ProfileApi.sendProfileVerificationRequest(
        userMessage: messageTf.value.text,
        documentType: documentType.value.text,
        documentNumber: number,
        images: idProofImages,
        resultCallback: () {
          Loader.dismiss();

          // show "pending" at once (do not wait for the list to reload) and stay on this
          // screen: the user sees that the request is in review and can not send it twice
          verificationRequests.insert(
              0,
              VerificationRequest(
                  id: 0,
                  status: 1,
                  userMessage: '',
                  adminMessage: '',
                  createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  updatedAt: null));
          verificationRequests.refresh();
          update();

          getVerificationRequests();

          AppUtil.showToast(
              message: verificationRequestSentString.tr, isSuccess: true);

          clear();
        });
  }

  cancelRequest(int id) {
    ProfileApi.cancelProfileVerificationRequest(
        id: id,
        userMessage: '',
        resultCallback: () {
          verificationRequests.removeWhere((request) => request.id == id);
          update();
          getVerificationRequests();
          update();
        });
  }
}
