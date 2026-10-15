// import 'package:flutter/material.dart';
//
// import '../../components/custom_texts.dart';
// import '../../model/business_model.dart';
//
// class TimeTable extends StatefulWidget {
//   final BusinessModel? business;
//
//   const TimeTable({super.key, required this.business}) ;
//
//   @override
//   _TimeTableState createState() => _TimeTableState();
// }
//
// class _TimeTableState extends State<TimeTable> {
//   bool timeTableExpanded = false;
//   BusinessModel? business;
//
//   @override
//   void initState() {
//     business = widget.business;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Heading6Text(
//           business!.todayTiming,
//           weight: TextWeight.bold,
//         ),
//         verticalSpacer(height: 25),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             BodyMediumText(
//               monday.tr,
//               color: TextColor.mainTextColor,
//             ),
//             BodySmallText(
//               business!.timingForDay(1),
//               weight: TextWeight.bold,
//             ),
//           ],
//         ).bP16,
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             BodyMediumText(
//               tuesday.tr,
//               color: TextColor.mainTextColor,
//             ),
//             BodySmallText(
//               business!.timingForDay(2),
//               weight: TextWeight.bold,
//             ),
//           ],
//         ).bP16,
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             BodyMediumText(
//               wednesday.tr,
//               color: TextColor.mainTextColor,
//             ),
//             BodySmallText(
//               business!.timingForDay(3),
//               weight: TextWeight.bold,
//             ),
//           ],
//         ).bP16,
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             BodyMediumText(
//               thursday.tr,
//               color: TextColor.mainTextColor,
//             ),
//             BodySmallText(
//               business!.timingForDay(4),
//               weight: TextWeight.bold,
//             ),
//           ],
//         ).bP16,
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             BodyMediumText(
//               friday.tr,
//               color: TextColor.mainTextColor,
//             ),
//             BodySmallText(
//               business!.timingForDay(5),
//               weight: TextWeight.bold,
//             ),
//           ],
//         ).bP16,
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             BodyMediumText(
//               saturday.tr,
//               color: TextColor.mainTextColor,
//             ),
//             BodySmallText(
//               business!.timingForDay(6),
//               weight: TextWeight.bold,
//             ),
//           ],
//         ).bP16,
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             BodyMediumText(
//               sunday.tr,
//               color: TextColor.mainTextColor,
//             ),
//             BodySmallText(
//               business!.timingForDay(7),
//               weight: TextWeight.bold,
//             ),
//           ],
//         ).bP16
//       ],
//     );
//   }
// }
