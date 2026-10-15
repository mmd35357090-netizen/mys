// import 'package:foap/helper/imports/common_import.dart';
// import '../../controllers/misc/gift_controller.dart';
// import '../../model/post_gift_model.dart';
// import '../../screens/settings_menu/coin_packages_widget.dart';
//
// class PostGiftPageView extends StatefulWidget {
//   final Function(PostGiftModel) giftSelectedCompletion;
//
//   const PostGiftPageView(
//       {super.key, required this.giftSelectedCompletion});
//
//   @override
//   State<PostGiftPageView> createState() => _PostGiftPageViewState();
// }
//
// class _PostGiftPageViewState extends State<PostGiftPageView> {
//   final UserProfileManager _userProfileManager = Get.find();
//
//   int currentView = 0;
//   List<Widget> pages = [];
//
//   @override
//   void initState() {
//     pages = [
//       GiftsListing(
//         giftSelectedCompletion: widget.giftSelectedCompletion,
//       ),
//       coinPackages(),
//     ];
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColorConstants.themeColor.darken(0.48),
//       child: Column(
//         children: [
//           Container(
//             height: 60,
//             color: AppColorConstants.themeColor.darken(0.48),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     BodyLargeText(
//                       '${availableCoinsString.tr} : ',
//                       color: Colors.white,
//                     ),
//                     ThemeIconWidget(
//                       ThemeIcon.diamond,
//                       size: 20,
//                       color: AppColorConstants.themeColor,
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     BodyLargeText(
//                       _userProfileManager.user.value!.coins.toString(),
//                       color: Colors.white,
//                     )
//                   ],
//                 ),
//                 currentView == 0
//                     ? Container(
//                             color: AppColorConstants.themeColor,
//                             child: BodyLargeText(
//                               coinsString.tr,
//                               weight: TextWeight.semiBold,
//                             ).setPadding(
//                                 left: 10, right: 10, top: 5, bottom: 5))
//                         .round(20)
//                         .ripple(() {
//                         setState(() {
//                           currentView = 1;
//                         });
//                       })
//                     : ThemeIconWidget(
//                         ThemeIcon.close,
//                         size: 20,
//                       ).ripple(() {
//                         setState(() {
//                           currentView = 0;
//                         });
//                       }),
//               ],
//             ).p16,
//           ).topRounded(20),
//           Expanded(child: pages[currentView]),
//         ],
//       ),
//     );
//   }
//
//   Widget coinPackages() {
//     return const CoinPackagesWidget();
//   }
// }
//
// class GiftsListing extends StatefulWidget {
//   final Function(PostGiftModel) giftSelectedCompletion;
//
//   const GiftsListing({super.key, required this.giftSelectedCompletion});
//
//   @override
//   State<GiftsListing> createState() => _GiftsListingState();
// }
//
// class _GiftsListingState extends State<GiftsListing> {
//   final GiftController _postGiftController = Get.find();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _postGiftController.clear();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColorConstants.backgroundColor.darken(),
//       child: Obx(() {
//         return ListView.separated(
//             padding: EdgeInsets.only(
//                 left: DesignConstants.horizontalPadding,
//                 right: DesignConstants.horizontalPadding,
//                 top: 20,
//                 bottom: 50),
//             itemCount: _postGiftController.timelineGift.length,
//             itemBuilder: (context, index) {
//               PostGiftModel postGift =
//                   _postGiftController.timelineGift[index];
//               // return Container(child: Text(postGift.name.toString()));
//               return giftBox(postGift).ripple(() {
//                 widget.giftSelectedCompletion(postGift);
//               });
//             },
//             separatorBuilder: (context, index) {
//               return const SizedBox(
//                 height: 25,
//               );
//             });
//       }),
//     );
//   }
//
//   Widget giftBox(PostGiftModel gift) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         ThemeIconWidget(
//           ThemeIcon.diamond,
//           size: 25,
//           color: AppColorConstants.iconColor,
//         ),
//         const SizedBox(
//           width: 2,
//         ),
//         Heading6Text(
//           gift.coin.toString(),
//           weight: TextWeight.semiBold,
//         ),
//
//         const SizedBox(
//           width: 25,
//         ),
//         Expanded(
//           child: Row(
//             children: [
//               // const Spacer(),
//               Container(
//                 color: AppColorConstants.themeColor,
//                 child: Center(
//                   child: Heading6Text(
//                     gift.name.toString(),
//                     weight: TextWeight.semiBold,
//                     color: Colors.white,
//                   ).setPadding(top: 5, bottom: 5, left: 10, right: 10),
//                 ),
//               ).round(40),
//               const Spacer(),
//             ],
//           ),
//         ),
//         // const Spacer()
//       ],
//     ).round(10);
//   }
// }
