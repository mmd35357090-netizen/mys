// import 'dart:math';
// import 'package:foap/helper/imports/common_import.dart';
// import 'package:foap/screens/story/text_story_maker/dragable_widget.dart';
// import 'package:foap/screens/story/text_story_maker/story_text_font_selector.dart';
// import 'package:keyboard_attachable/keyboard_attachable.dart';
// import 'drawing_pad.dart';
//
// class TextStoryMakerController extends GetxController {
//   RxList<DraggableWidget> draggableWidgets = <DraggableWidget>[].obs;
//   RxList<Color> randomGradientColors = [
//     Color.fromRGBO(Random().nextInt(256), Random().nextInt(256),
//         Random().nextInt(256), 1.0),
//     Color.fromRGBO(Random().nextInt(256), Random().nextInt(256),
//         Random().nextInt(256), 1.0)
//   ].obs;
//
//   RxBool textEditorFocus = false.obs;
//   RxDouble textFontSize = (48.0).obs;
//
//   List<Color> textBGColors = [Colors.transparent, Colors.white, Colors.black];
//   List<Color> textColors = [
//     Colors.white,
//     Colors.black,
//     Colors.yellow,
//     Colors.pink,
//     Colors.purple,
//     Colors.brown,
//     Colors.blue,
//     Colors.blueGrey,
//     Colors.orange,
//     Colors.redAccent,
//     Colors.tealAccent,
//     Colors.green,
//     Colors.deepOrange,
//     Colors.amber,
//     Colors.indigo
//   ];
//
//   Rx<Color> textCurrentColor = Colors.black.obs;
//   Rx<Color> textCurrentBGColor = Colors.transparent.obs;
//   Rx<TextAlign> textCurrentAlignment = TextAlign.center.obs;
//
//   RxBool showTextColorPicker = false.obs;
//   RxBool showTextSizeSlider = false.obs;
//   RxBool showTextFontSelector = false.obs;
//   RxBool enableDrawing = false.obs;
//
//   Rx<TextStyle> currentFont = const TextStyle().obs;
//
//   clearTextStyleProperties() {
//     textEditorFocus.value = false;
//     textFontSize.value = (48.0);
//     currentFont.value = const TextStyle();
//     textCurrentColor.value = Colors.black;
//     textCurrentBGColor.value = Colors.transparent;
//     textCurrentAlignment.value = TextAlign.center;
//   }
//
//   textEditorFocusChanged(bool focus) {
//     textEditorFocus.value = focus;
//     showTextFontSelector.value = focus;
//     if (focus == false) {
//       showTextColorPicker.value = false;
//       showTextSizeSlider.value = false;
//       showTextFontSelector.value = false;
//     } else {
//       showTextSizeSlider.value = true;
//     }
//   }
//
//   textFontSizeChanged(double size) {
//     textFontSize.value = size;
//     textFontSize.refresh();
//   }
//
//   textBackgroundColorToggle() {
//     if (textCurrentBGColor.value == textBGColors[0]) {
//       textCurrentBGColor.value = textBGColors[1];
//     } else if (textCurrentBGColor.value == textBGColors[1]) {
//       textCurrentBGColor.value = textBGColors[2];
//     } else if (textCurrentBGColor.value == textBGColors[2]) {
//       textCurrentBGColor.value = textBGColors[0];
//     }
//   }
//
//   textAlignmentToggle() {
//     if (textCurrentAlignment.value == TextAlign.left) {
//       textCurrentAlignment.value = TextAlign.center;
//     } else if (textCurrentAlignment.value == TextAlign.center) {
//       textCurrentAlignment.value = TextAlign.right;
//     } else if (textCurrentAlignment.value == TextAlign.right) {
//       textCurrentAlignment.value = TextAlign.left;
//     }
//     textCurrentAlignment.refresh();
//   }
//
//   textColorPickerToggle() {
//     showTextColorPicker.value = !showTextColorPicker.value;
//     showTextSizeSlider.value = false;
//
//     showTextFontSelector.value = !showTextColorPicker.value;
//     showTextSizeSlider.value = !showTextColorPicker.value;
//   }
//
//   drawingPadToggle() {
//     enableDrawing.value = !enableDrawing.value;
//   }
//
//   textColorChanged(Color color) {
//     textCurrentColor.value = color;
//   }
//
//   textFontChanged(TextStyle style) {
//     currentFont.value = style;
//   }
//
//   shuffleBackgroundColors() {
//     randomGradientColors.value = [
//       Color.fromRGBO(Random().nextInt(256), Random().nextInt(256),
//           Random().nextInt(256), 1.0),
//       Color.fromRGBO(Random().nextInt(256), Random().nextInt(256),
//           Random().nextInt(256), 1.0)
//     ];
//     print(randomGradientColors);
//     randomGradientColors.refresh();
//     update();
//   }
// }
//
// class TextStoryMakerView extends StatefulWidget {
//   final Function(bool) textFieldFocusChanged;
//
//   const TextStoryMakerView({super.key, required this.textFieldFocusChanged});
//
//   @override
//   State<TextStoryMakerView> createState() => _TextStoryMakerViewState();
// }
//
// class _TextStoryMakerViewState extends State<TextStoryMakerView> {
//   final TextEditingController textController = TextEditingController();
//   final TextStoryMakerController textStoryMakerController = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColorConstants.backgroundColor,
//       resizeToAvoidBottomInset: true,
//       body: Column(
//         children: [
//           const SizedBox(
//             height: 25,
//           ),
//           Expanded(
//             child: FooterLayout(
//               footer:
//                   Obx(() => textStoryMakerController.showTextFontSelector.value
//                       ? StoryTextFontSelector()
//                       : Container(
//                           height: 20,
//                         )),
//               child: SingleChildScrollView(
//                 child: SizedBox(
//                   height: Get.height * 0.87,
//                   width: Get.width,
//                   child: Stack(
//                     children: [
//                       GestureDetector(
//                         behavior: HitTestBehavior.translucent,
//                         onTap: () {
//                           textStoryMakerController
//                               .textEditorFocusChanged(false);
//                           FocusScope.of(Get.context!).requestFocus(FocusNode());
//                         },
//                         child: Obx(() => Stack(
//                               children: [
//                                 SizedBox(
//                                     height: Get.height,
//                                     width: Get.width,
//                                     child: RandomGradientContainer()),
//                                 Obx(() => DrawingPad(
//                                       enableDrawing: textStoryMakerController
//                                           .enableDrawing.value,
//                                     )),
//                                 // DraggableWidget(
//                                 //   child: Container(
//                                 //     height: 100,
//                                 //     width: 100,
//                                 //     color: Colors.purple,
//                                 //   ),
//                                 // ),
//                                 for (DraggableWidget widget
//                                     in textStoryMakerController
//                                         .draggableWidgets)
//                                   widget,
//                                 textEditorView(),
//                               ],
//                             ).round(40)),
//                       ),
//                       Column(
//                         children: [
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Container(
//                                 height: 40,
//                                 width: 40,
//                                 color: AppColorConstants.backgroundColor,
//                                 child: Center(
//                                     child: ThemeIconWidget(
//                                   ThemeIcon.close,
//                                   size: 25,
//                                 )),
//                               ).circular.ripple(() {
//                                 Get.back();
//                               }),
//                               Obx(() =>
//                                   textStoryMakerController.textEditorFocus.value
//                                       ? textEditorTopTools()
//                                       : generalTopTools()),
//                               Container(
//                                 height: 40,
//                                 width: 40,
//                                 color: AppColorConstants.backgroundColor,
//                                 child: Center(
//                                     child: ThemeIconWidget(ThemeIcon.done,
//                                         size: 25)),
//                               ).circular.ripple(() {
//                                 Get.back();
//                               }),
//                             ],
//                           ).hp(DesignConstants.horizontalPadding),
//                         ],
//                       ),
//                       Obx(() =>
//                           textStoryMakerController.showTextSizeSlider.value
//                               ? textSizeSlider()
//                               : Container()),
//                       Obx(() =>
//                           textStoryMakerController.showTextColorPicker.value
//                               ? textColorPicker()
//                               : Container()),
//                       // Obx(() => textStoryMakerController.showTextFontSelector.value
//                       //     ? Positioned(
//                       //     left: 0,
//                       //     right: 0,
//                       //     bottom: 20,
//                       //     child: StoryTextFontSelector())
//                       //     : Container()),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget textColorPicker() {
//     return Positioned(
//       left: 0,
//       right: 0,
//       bottom: 20,
//       child: SizedBox(
//         height: 25,
//         child: ListView(
//           padding: EdgeInsets.only(
//               left: DesignConstants.horizontalPadding,
//               right: DesignConstants.horizontalPadding),
//           scrollDirection: Axis.horizontal,
//           children: [
//             for (Color color in textStoryMakerController.textColors)
//               Obx(() => Container(
//                     // height: 20,
//                     width: 20,
//                     color: color,
//                     child: textStoryMakerController.textCurrentColor.value ==
//                             color
//                         ? Center(child: ThemeIconWidget(ThemeIcon.checkMark))
//                         : null,
//                   )
//                       .borderWithRadius(
//                           value: 2, radius: 20, color: Colors.white)
//                       .rP8
//                       .ripple(() {
//                     textStoryMakerController.textColorChanged(color);
//                   }))
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget textSizeSlider() {
//     return Positioned(
//       bottom: 20,
//       left: 0,
//       right: 0,
//       child: Obx(
//         () => Slider(
//           value: textStoryMakerController.textFontSize.value,
//           min: 20.0,
//           max: 200.0,
//           onChanged: (value) {
//             print('onChanged');
//             textStoryMakerController.textFontSizeChanged(value);
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget textEditorView() {
//     return Obx(() => Focus(
//           child: Center(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: Get.width - 100,
//               ),
//               child: IntrinsicWidth(
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     TextField(
//                       controller: textController,
//                       keyboardType: TextInputType.multiline,
//                       textAlign:
//                           textStoryMakerController.textCurrentAlignment.value,
//                       maxLength: 500,
//                       style:
//                           textStoryMakerController.currentFont.value.copyWith(
//                         fontSize: textStoryMakerController.textFontSize.value,
//                         color: textStoryMakerController.textCurrentColor.value,
//                         background: Paint()
//                           ..strokeWidth = 20.0
//                           ..color =
//                               textStoryMakerController.textCurrentBGColor.value
//                           ..strokeCap = StrokeCap.round
//                           ..strokeJoin = StrokeJoin.round
//                           ..style = PaintingStyle.fill
//                           ..filterQuality = FilterQuality.high,
//                         shadows: <Shadow>[
//                           Shadow(
//                               offset: const Offset(1.0, 1.0),
//                               blurRadius: 2.0,
//                               color: textStoryMakerController
//                                           .textCurrentColor.value ==
//                                       Colors.black
//                                   ? Colors.white54
//                                   : Colors.black)
//                         ],
//                       ),
//                       onChanged: (value) {},
//                       maxLines: null,
//                       decoration: InputDecoration(
//                         floatingLabelBehavior: FloatingLabelBehavior.never,
//                         border: InputBorder.none,
//                         counterText: "",
//                         hintText: typeHereString.tr,
//                         hintStyle: TextStyle(
//                             fontSize: FontSizes.h1,
//                             color: AppColorConstants
//                                 .inputFieldPlaceholderTextColor
//                                 .withOpacity(0.2)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           onFocusChange: (hasFocus) {
//             if (hasFocus == false) {
//               //add draggable widget
//               addTextDraggableWidget();
//             }
//             widget.textFieldFocusChanged(hasFocus);
//             if (hasFocus) {
//               textStoryMakerController.textEditorFocusChanged(hasFocus);
//             }
//           },
//         ));
//   }
//
//   addTextDraggableWidget() {
//     if (textController.text.trim().isNotEmpty) {
//       var textWidget = Text(
//         textController.text,
//         textAlign: textStoryMakerController.textCurrentAlignment.value,
//         style: textStoryMakerController.currentFont.value.copyWith(
//           fontSize: textStoryMakerController.textFontSize.value,
//           color: textStoryMakerController.textCurrentColor.value,
//           background: Paint()
//             ..strokeWidth = 20.0
//             ..color = textStoryMakerController.textCurrentBGColor.value
//             ..strokeCap = StrokeCap.round
//             ..strokeJoin = StrokeJoin.round
//             ..style = PaintingStyle.fill
//             ..filterQuality = FilterQuality.high,
//         ),
//       );
//       textStoryMakerController.draggableWidgets.add(DraggableWidget(
//         type: DraggableWidgetType.text,
//         child: textWidget,
//       ));
//       textStoryMakerController.draggableWidgets.refresh();
//     }
//     textController.text = '';
//   }
//
//   Widget textEditorTopTools() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // ThemeIconWidget(
//         //   ThemeIcon.fontSize,
//         //   size: 25,
//         // ).ripple(() {
//         //   textStoryMakerController.textSizeSliderToggle();
//         // }),
//         // const SizedBox(
//         //   width: 15,
//         // ),
//         Obx(() => ThemeIconWidget(
//               textStoryMakerController.textCurrentAlignment.value ==
//                       TextAlign.left
//                   ? ThemeIcon.textLeftAlign
//                   : textStoryMakerController.textCurrentAlignment.value ==
//                           TextAlign.center
//                       ? ThemeIcon.textCenterAlign
//                       : ThemeIcon.textRightAlign,
//               size: 25,
//             ).ripple(() {
//               textStoryMakerController.textAlignmentToggle();
//             })),
//         const SizedBox(
//           width: 15,
//         ),
//         ThemeIconWidget(ThemeIcon.colorPicker, size: 25).ripple(() {
//           textStoryMakerController.textColorPickerToggle();
//         }),
//         const SizedBox(
//           width: 15,
//         ),
//         Obx(() => Container(
//                     color: textStoryMakerController.textCurrentBGColor.value,
//                     child: ThemeIconWidget(ThemeIcon.textBackground,
//                             size: 25,
//                             color: textStoryMakerController
//                                         .textCurrentBGColor.value ==
//                                     Colors.black
//                                 ? Colors.white
//                                 : AppColorConstants.iconColor)
//                         .p(2))
//                 .borderWithRadius(value: 2, radius: 5)
//                 .ripple(() {
//               textStoryMakerController.textBackgroundColorToggle();
//             })),
//       ],
//     );
//   }
//
//   Widget generalTopTools() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 30,
//           width: 30,
//           child: RandomGradientContainer(),
//         )
//             .borderWithRadius(value: 2, radius: 50, color: Colors.white)
//             .ripple(() {
//           textStoryMakerController.shuffleBackgroundColors();
//         }),
//         const SizedBox(
//           width: 15,
//         ),
//         Container(
//           height: 30,
//           width: 30,
//           color: textStoryMakerController.enableDrawing.value
//               ? Colors.white
//               : Colors.transparent,
//           child: Center(
//             child: ThemeIconWidget(ThemeIcon.drawing, size: 20).ripple(() {
//               textStoryMakerController.drawingPadToggle();
//             }),
//           ),
//         ).borderWithRadius(value: 2, radius: 20, color: Colors.white),
//       ],
//     );
//   }
// }
//
// class RandomGradientContainer extends StatelessWidget {
//   RandomGradientContainer({super.key});
//
//   final TextStoryMakerController textStoryMakerController = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<TextStoryMakerController>(
//         init: textStoryMakerController,
//         builder: (ctx) {
//           return Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: textStoryMakerController.randomGradientColors.value,
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//           );
//         });
//   }
// }
