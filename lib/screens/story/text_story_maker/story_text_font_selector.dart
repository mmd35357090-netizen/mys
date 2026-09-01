// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:foap/helper/imports/common_import.dart';
// import 'package:foap/helper/story_editor/src/presentation/widgets/animated_onTap_button.dart';
// import 'package:foap/screens/story/text_story_maker/text_story_maker_view.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class StoryTextFontSelector extends StatelessWidget {
//   final TextStoryMakerController textStoryMakerController = Get.find();
//
//   StoryTextFontSelector({super.key});
//
//   PageController pageController = PageController(viewportFraction: .125);
//   List<TextStyle> fonts = [
//     GoogleFonts.lato(),
//     GoogleFonts.roboto(),
//     GoogleFonts.sanchez(),
//     GoogleFonts.laBelleAurore()
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     var size = Get.size;
//     return Container(
//       height: size.width * 0.1,
//       width: size.width,
//       alignment: Alignment.center,
//       child: PageView.builder(
//         controller: pageController,
//         itemCount: fonts.length,
//         onPageChanged: (index) {
//           HapticFeedback.heavyImpact();
//           textStoryMakerController.textFontChanged(fonts[index]);
//           pageController.animateToPage(index,
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeIn);
//         },
//         physics: const BouncingScrollPhysics(),
//         allowImplicitScrolling: true,
//         pageSnapping: false,
//         itemBuilder: (context, index) {
//           return AnimatedOnTapButton(
//             onTap: () {
//               textStoryMakerController.textFontChanged(fonts[index]);
//               // editorNotifier.fontFamilyIndex = index;
//               pageController.jumpToPage(index);
//               pageController.animateToPage(index,
//                   duration: const Duration(milliseconds: 300),
//                   curve: Curves.easeIn);
//             },
//             child: Obx(() => Container(
//                   height: size.width * 0.1,
//                   width: size.width * 0.1,
//                   alignment: Alignment.center,
//                   margin: const EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                       color: fonts[index] ==
//                               textStoryMakerController.currentFont.value
//                           ? AppColorConstants.themeColor.withOpacity(0.5)
//                           : Colors.black.withOpacity(0.4),
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white)),
//                   child: Center(
//                     child: Text(
//                       'Aa',
//                       style: fonts[index]
//                           .copyWith(
//                               color: fonts[index] ==
//                                       textStoryMakerController.currentFont.value
//                                   ? Colors.red
//                                   : Colors.white,
//                               fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 )),
//           );
//         },
//       ),
//     );
//   }
// }
