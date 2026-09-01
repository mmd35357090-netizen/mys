import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/verification_request_model.dart';

class VerificationRejectReason extends StatelessWidget {
  final VerificationRequest request;

  const VerificationRejectReason({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: replyString.tr),
          const SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: Heading6Text(
              request.adminMessage ?? '',
              weight: TextWeight.regular,
            ).hp(DesignConstants.horizontalPadding),
          )
        ],
      ),
    );
  }
}
