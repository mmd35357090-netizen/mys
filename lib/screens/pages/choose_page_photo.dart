// import 'package:foap/helper/imports/common_import.dart';
// import 'package:get/get.dart';
//
// class ChoosePageCoverPhoto extends StatefulWidget {
//   const ChoosePageCoverPhoto({Key? key}) : super(key: key);
//
//   @override
//   ChoosePageCoverPhotoState createState() => ChoosePageCoverPhotoState();
// }
//
// class ChoosePageCoverPhotoState extends State<ChoosePageCoverPhoto> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorConstants.backgroundColor,
//       // appBar: CustomNavigationBar(
//       //   child: appBar(),
//       // ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(
//             height: 50,
//           ),
//           backNavigationBar(
//
//             title: addClubCoverPhoto,
//           ),
//           divider().tP8,
//           const SizedBox(
//             height: 20,
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Heading4Text(
//                 'Add Cover Photo',
//                   weight: TextWeight.semiBold
//               ),
//               const Heading6Text(
//                 'Give people an idea of what your group is about with a photo',
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               const Heading4Text(
//                 'Cover photo',
//               ),
//             ],
//           ).hP16,
//           SizedBox(
//             height: 200,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 CachedNetworkImage(
//                   imageUrl: 'Assets.dummyProfilePictureUrl',
//                   fit: BoxFit.cover,
//                 ).round(5),
//                 Positioned(
//                     bottom: 10,
//                     right: 10,
//                     child: Container(
//                       color: ColorConstants.cardColor,
//                       child: Row(
//                         children: [
//                           ThemeIconWidget(
//                             ThemeIcon.edit,
//                             size: 20,
//                             color: ColorConstants.iconColor,
//                           ),
//                           BodyLargeText(
//                             edit,
//                           )
//                         ],
//                       ).setPadding(left: 8, right: 8, top: 4, bottom: 4),
//                     ).round(5).ripple(() {}))
//               ],
//             ),
//           ).p16,
//           SizedBox(
//             height: 50,
//             child: ListView.separated(
//                 padding: const EdgeInsets.only(left: 16),
//                 scrollDirection: Axis.horizontal,
//                 itemCount: 10,
//                 itemBuilder: (BuildContext ctx, int index) {
//                   return CachedNetworkImage(
//                     imageUrl: 'Assets.dummyProfilePictureUrl',
//                     height: 50,
//                     width: 50,
//                     fit: BoxFit.cover,
//                   ).round(5);
//                 },
//                 separatorBuilder: (BuildContext ctx, int index) {
//                   return const SizedBox(
//                     width: 10,
//                   );
//                 }),
//           ),
//           const Spacer(),
//           AppThemeButton(
//               text: next,
//               onPress: () {
//                 Get.to(() => const ClubDescription());
//                 // NavigationService.instance.navigateToRoute(
//                 //     MaterialPageRoute(builder: (ctx) => GroupDescription()));
//               }).hP16,
//           const SizedBox(
//             height: 50,
//           )
//         ],
//       ),
//     );
//   }
// }
