// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:foap/helper/imports/common_import.dart';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';
//
// import '../../util/shared_prefs.dart';
// import '../dashboard/loading.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key}) ;
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   late bool haveBiometricLogin = false;
//   var localAuth = LocalAuthentication();
//   RxInt bioMetricType = 0.obs;
//
//   @override
//   void initState() {
//     super.initState();
//     Get.offAll(() => const LoadingScreen());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//         backgroundColor: AppColorConstants.backgroundColor,
//         body: Stack(
//           children: [
//             CarouselSlider(
//               items: [
//                 for (String image in bgImages)
//                   Image.asset(
//                     image,
//                     fit: BoxFit.cover,
//                     height: double.infinity,
//                     width: double.infinity,
//                   )
//               ],
//               options: CarouselOptions(
//                 autoPlayInterval: const Duration(seconds: 1),
//                 autoPlay: true,
//                 enlargeCenterPage: false,
//                 enableInfiniteScroll: true,
//                 height: double.infinity,
//                 viewportFraction: 1,
//                 onPageChanged: (index, reason) {},
//               ),
//             ),
//             Container(
//               height: double.infinity,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topRight,
//                   end: Alignment.bottomLeft,
//                   stops: const [
//                     0.1,
//                     0.3,
//                     0.6,
//                     0.9,
//                   ],
//                   colors: [
//                     AppColorConstants.backgroundColor.withValues(alpha: 0.9),
//                     AppColorConstants.backgroundColor
//                         .lighten()
//                         .withValues(alpha: 0.9),
//                     AppColorConstants.backgroundColor
//                         .lighten()
//                         .withValues(alpha: 0.5),
//                     AppColorConstants.themeColor.withValues(alpha: 0.5),
//                   ],
//                 ),
//               ),
//             ),
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/spash_logo.png',
//                     height: 150,
//                     width: 150,
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   BodyLargeText(
//                     AppConfigConstants.appName,
//                       weight: TextWeight.medium
//                   ),
//                   Heading6Text(
//                     AppConfigConstants.appTagline.tr,
//                   ),
//                 ],
//               ).bp(200),
//             ),
//           ],
//         ));
//   }
// }
