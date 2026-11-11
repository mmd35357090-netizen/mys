import 'package:foap/util/biometric_helper.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/profile_controller.dart';

class ChangePaypalId extends StatefulWidget {
  const ChangePaypalId({super.key}) ;

  @override
  State<ChangePaypalId> createState() => _ChangePaypalIdState();
}

class _ChangePaypalIdState extends State<ChangePaypalId> {
  TextEditingController paypalId = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    paypalId.text = _userProfileManager.user.value!.paypalId ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          profileScreensNavigationBar(

              title: paymentDetailString.tr,
              rightBtnTitle: doneString.tr,
              completion: () async {
                if (!await BiometricHelper.confirmIfEnabled(
                    paymentDetailString.tr)) {
                  return;
                }
                profileController.updatePaypalId(
                    paypalId: paypalId.text, );
              }),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorConstants.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
                  width: 0.6),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyMediumText(paypalIdString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.semiBold),
                  Container(
                    color: Colors.transparent,
                    height: 50,
                    child: AppTextField(
                      controller: paypalId,
                      // showBorder: true,
                      hintText: 'paypalId@gmail.com',
                    ),
                  ),
                ],
              ).vP8,
            ],
          )).hp(DesignConstants.horizontalPadding),
        ],
      ),
    );
  }
}
