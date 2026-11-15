import 'package:intl/intl.dart';

class VerificationRequest {
  int id = 0;
  String userMessage = '';
  String? adminMessage = '';
  String? documentType;
  String? documentNumber;

  int status = 0;
  int createdAt = 0;
  int? updatedAt;

  VerificationRequest({
    required this.id,
    required this.status,
    required this.userMessage,
    required this.adminMessage,
    required this.createdAt,
    required this.updatedAt,
    this.documentType,
    this.documentNumber,
  });

  factory VerificationRequest.fromJson(Map<String, dynamic> json) =>
      VerificationRequest(
        // tolerant parsing: a null / text value from the server must never break the whole list
        id: int.tryParse('${json["id"]}') ?? 0,
        status: int.tryParse('${json["status"]}') ?? 0,
        userMessage: json["user_message"]?.toString() ?? '',
        adminMessage: json["admin_message"]?.toString(),
        createdAt: int.tryParse('${json["created_at"]}') ?? 0,
        updatedAt: int.tryParse('${json["updated_at"]}'),
        documentType: json["document_type"]?.toString(),
        documentNumber: json["document_number"]?.toString(),
      );

  String get sentOn {
    return DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(createdAt * 1000));
  }

  bool get isProcessing {
    return status == 1;
  }

  bool get isCancelled {
    return status == 2;
  }

  bool get isRejected {
    return status == 3;
  }

  bool get isApproved {
    return status == 10;
  }
}
