// import 'package:foap/helper/imports/common_import.dart';
//
// class CreatePage extends StatefulWidget {
//   const CreatePage({Key? key}) : super(key: key);
//
//   @override
//   CreatePageState createState() => CreatePageState();
// }
//
// class CreatePageState extends State<CreatePage> {
//   GenericItem? selectedItem;
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
//           backNavigationBar(
//
//             title: createClub,
//           ),
//           divider().tP8,
//           Expanded(
//             child: Column(
//               children: [
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 const InputField(
//                   showBorder: true,
//                   cornerRadius: 5,
//                   hintText: 'Name  your group',
//                 ),
//                 divider().vP16,
//                 Stack(
//                   children: const [
//                     AbsorbPointer(
//                       child: InputField(
//                         showBorder: true,
//                         cornerRadius: 5,
//                         hintText: 'Choose privacy',
//                         // onPress: () {
//                         //   print('onPress');
//                         // },
//                       ),
//                     ),
//                     SizedBox(height: 40,width: double.infinity,)
//                   ],
//                 ).ripple((){
//                   showActionSheet();
//                 }),
//                 const Spacer(),
//                 divider().vP16,
//                 AppThemeButton(
//                     text: createGroup,
//                     onPress: () {
//                       //Get.to(() => const ChooseClubCoverPhoto());
//                       // NavigationService.instance.navigateToRoute(
//                       //     MaterialPageRoute(builder: (ctx) => ChooseCoverPhoto()));
//                     }).bP25
//               ],
//             ).hP16,
//           )
//         ],
//       ),
//     );
//   }
//
//   showActionSheet() {
//     showModalBottomSheet(
//
//         backgroundColor: Colors.transparent,
//         builder: (context) => ActionSheet(
//               items: [
//                 GenericItem(
//                     id: '1',
//                     title: public,
//                     subTitle:
//                         'Anyone can see who\'s in the group and what they post',
//                     isSelected: selectedItem?.id == '1',
//                     icon: ThemeIcon.public),
//                 GenericItem(
//                     id: '2',
//                     title: private,
//                     subTitle:
//                         'Only members can see who\'s in the group and what they post',
//                     isSelected: selectedItem?.id == '2',
//                     icon: ThemeIcon.lock),
//               ],
//               itemCallBack: (item) {
//                 setState(() {
//                   selectedItem = item;
//                 });
//               },
//             ));
//   }
// }
