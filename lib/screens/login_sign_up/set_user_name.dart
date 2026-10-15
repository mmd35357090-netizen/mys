// import 'package:foap/helper/imports/common_import.dart';
// import 'package:foap/helper/imports/login_signup_imports.dart';
// import 'package:lottie/lottie.dart';
// import '../../controllers/profile/profile_controller.dart';
// import '../../util/form_validator.dart';
//
// class SetUserName extends StatefulWidget {
//   const SetUserName({super.key});
//
//   @override
//   State<SetUserName> createState() => _SetUserNameState();
// }
//
// class _SetUserNameState extends State<SetUserName> {
//   TextEditingController userName = TextEditingController();
//   final ProfileController profileController = Get.find();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       backgroundColor: AppColorConstants.backgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: Get.height * 0.1,
//             ),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: AppThemeBackButton(),
//             ),
//             SizedBox(
//               height: Get.height * 0.05,
//             ),
//             SizedBox(
//                 height: Get.height * 0.12,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Heading3Text(chooseUserNameString.tr, weight: TextWeight.bold)
//                         .rp(100),
//                     Positioned(
//                         right: 0,
//                         top: 0,
//                         bottom: 0,
//                         child: Lottie.asset(
//                           'assets/lottie/syahi.json',
//                         ))
//                   ],
//                 )),
//             SizedBox(
//               height: Get.height * 0.05,
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             BodyLargeText(setUserNameSubHeadingString.tr,
//                 textAlign: TextAlign.center, weight: TextWeight.medium),
//             const SizedBox(
//               height: 50,
//             ),
//             Stack(
//               children: [
//                 AppTextField(
//                   controller: userName,
//                   onChanged: (value) {
//                     if (value.length > 3) {
//                       profileController.verifyUsername(userName: value);
//                     }
//                   },
//                 ),
//                 Positioned(
//                   right: DesignConstants.horizontalPadding,
//                   bottom: 0,
//                   top: 0,
//                   child: Center(
//                     child:
//                         Obx(() => profileController.userNameCheckStatus.value == 1
//                             ? ThemeIconWidget(
//                                 ThemeIcon.checkMark,
//                                 color: AppColorConstants.themeColor,
//                               )
//                             : profileController.userNameCheckStatus.value == 0
//                                 ? ThemeIconWidget(
//                                     ThemeIcon.close,
//                                     color: AppColorConstants.red,
//                                   )
//                                 : Container()),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 50,
//             ),
//             AppThemeButton(
//                 text: nextString.tr,
//                 onPress: () {
//                   if (FormValidator().isTextEmpty(userName.text)) {
//                     AppUtil.showToast(
//                         message: pleaseEnterUserNameString.tr, isSuccess: false);
//                   } else if (profileController.userNameCheckStatus.value != 1) {
//                     AppUtil.showToast(
//                         message: pleaseEnterValidUserNameString.tr,
//                         isSuccess: false);
//                   } else {
//                     Get.to(() => SignUpScreen(
//                           userName: userName.text,
//                         ));
//                   }
//                 })
//           ],
//         ).hp(DesignConstants.horizontalPadding),
//       ),
//     );
//   }
// }
