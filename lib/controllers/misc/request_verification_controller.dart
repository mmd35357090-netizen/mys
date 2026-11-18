import 'package:foap/api_handler/apis/profile_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/verification_request_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';
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

  // false until the server answered once (so the form is never shown by mistake while loading)
  RxBool isLoaded = false.obs;
  RxBool isSubmitting = false.obs;

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

  Future<void> getVerificationRequests() {
    final done = Completer<void>();
    ProfileApi.getVerificationRequestHistory(resultCallback: (result) {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      verificationRequests.value = result;
      verificationRequests.refresh();
      isLoaded.value = true;
      update();
      if (!done.isCompleted) done.complete();
    }, onError: () {
      isLoaded.value = true;
      if (!done.isCompleted) done.complete();
    });
    return done.future;
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
    if (isSubmitting.value) return; // ignore a second tap
    if (isVerificationInProcess) return; // one request at a time
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

    isSubmitting.value = true;
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

    if (idProofImages.length != selectedImages.length) {
      // a picture did not upload: do not send half a request
      Loader.dismiss();
      isSubmitting.value = false;
      AppUtil.showToast(
          message: 'Could not upload the photo. Please try again.',
          isSuccess: false);
      return;
    }

    ProfileApi.sendProfileVerificationRequest(
        userMessage: messageTf.value.text,
        documentType: documentType.value.text,
        documentNumber: number,
        images: idProofImages,
        resultCallback: (ok, message) async {
          if (!ok) {
            // the server did NOT take the request: say why, and do not claim success
            Loader.dismiss();
            isSubmitting.value = false;
            AppUtil.showToast(
                message: message.isNotEmpty
                    ? message
                    : 'Could not send the request. Please try again.',
                isSuccess: false);
            await getVerificationRequests();
            return;
          }

          clear();
          await getVerificationRequests();
          if (!isVerificationInProcess) {
            // accepted, but the list does not show it as waiting yet: show "in review" anyway
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
          }
          update();
          Loader.dismiss();
          isSubmitting.value = false;

          AppUtil.showToast(
              message: verificationRequestSentString.tr, isSuccess: true);
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
