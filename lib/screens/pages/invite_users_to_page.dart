// import 'package:foap/helper/imports/common_import.dart';
// import 'package:get/get.dart';
//
// class InviteUsersToPage extends StatefulWidget {
//   const InviteUsersToPage({Key? key}) : super(key: key);
//
//   @override
//   InviteUsersToPageState createState() => InviteUsersToPageState();
// }
//
// class InviteUsersToPageState extends State<InviteUsersToPage> {
//   final SelectUserForGroupChatController selectUserForGroupChatController =
//   Get.find();
//
//   @override
//   void initState() {
//     selectUserForGroupChatController.getFriends();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorConstants.backgroundColor,
//       body: Column(
//         children: [
//           const SizedBox(
//             height: 50,
//           ),
//           SizedBox(
//             height: 40,
//             child: Stack(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const ThemeIconWidget(
//                       ThemeIcon.close,
//                       size: 20,
//                     ).ripple(() {
//                       Navigator.of(context).pop();
//                     }),
//                     Heading5Text(
//                       create,
//                         weight: TextWeight.medium
//                     ).ripple(() {
//
//                     }),
//                   ],
//                 ),
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Heading5Text(
//                         invite,
//                           weight: TextWeight.medium
//                       ),
//                       Obx(() => selectUserForGroupChatController
//                           .selectedFriends.isNotEmpty
//                           ? Heading5Text(
//                         '${selectUserForGroupChatController.selectedFriends.length} ${friendsSelected}',
//                           weight: TextWeight.bold
//                       )
//                           : Container())
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ).hP16,
//           divider().tP8,
//           GetBuilder<SelectUserForGroupChatController>(
//             init: selectUserForGroupChatController,
//             builder: (ctx) {
//               List<UserModel> usersList =
//                   selectUserForGroupChatController.selectedFriends;
//               return usersList.isNotEmpty
//                   ? SizedBox(
//                   height: 100,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.only(
//                         top: 20, left: 16, right: 16, bottom: 10),
//                     itemCount: usersList.length,
//                     itemBuilder: (context, index) {
//                       return Stack(
//                         children: [
//                           Column(
//                             children: [
//                               UserAvatarView(
//                                 user: usersList[index],
//                                 size: 50,
//                               ).circular,
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               Heading6Text(
//                                 usersList[index].userName,
//
//                               )
//                             ],
//                           ),
//                           Positioned(
//                             top: 0,
//                             right: 0,
//                             child: Container(
//                                 height: 25,
//                                 width: 25,
//                                 color: ColorConstants.cardColor,
//                                 child: const ThemeIconWidget(
//                                   ThemeIcon.close,
//                                   size: 20,
//                                 )).circular.ripple(() {
//                               selectUserForGroupChatController
//                                   .selectFriend(usersList[index]);
//                             }),
//                           ),
//                         ],
//                       );
//                     },
//                     separatorBuilder: (context, index) {
//                       return const SizedBox(
//                         width: 15,
//                       );
//                     },
//                   ))
//                   : Container();
//             },
//           ),
//           SearchBar(
//               showSearchIcon: true,
//               iconColor: ColorConstants.themeColor,
//               onSearchChanged: (value) {
//                 selectUserForGroupChatController.searchTextChanged(value);
//               },
//               onSearchStarted: () {
//                 //controller.startSearch();
//               },
//               onSearchCompleted: (searchTerm) {})
//               .p16,
//           divider().tP16,
//           Expanded(
//             child: GetBuilder<SelectUserForGroupChatController>(
//                 init: selectUserForGroupChatController,
//                 builder: (ctx) {
//                   ScrollController scrollController = ScrollController();
//                   scrollController.addListener(() {
//                     if (scrollController.position.maxScrollExtent ==
//                         scrollController.position.pixels) {
//                       if (!selectUserForGroupChatController.isLoading) {
//                         selectUserForGroupChatController.getFriends();
//                       }
//                     }
//                   });
//
//                   List<UserModel> usersList =
//                       selectUserForGroupChatController.friends;
//                   return GridView.builder(
//                     gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 5,
//                         crossAxisSpacing: 5.0,
//                         mainAxisSpacing: 5.0,
//                         childAspectRatio: 0.8),
//                     padding: const EdgeInsets.only(top: 25, left: 8, right: 8),
//                     itemCount: usersList.length,
//                     itemBuilder: (context, index) {
//                       return SelectableUserCard(
//                         model: usersList[index],
//                         isSelected: selectUserForGroupChatController
//                             .selectedFriends
//                             .contains(usersList[index]),
//                         selectionHandler: () {
//                           selectUserForGroupChatController
//                               .selectFriend(usersList[index]);
//                         },
//                       );
//                     },
//                   );
//                 }),
//           ),
//         ],
//       ),
//     );
//   }
// }
