import 'package:foap/helper/imports/common_import.dart';

class OTPFieldViewConstants {
  static double width = 50;
  static double height = 50;
  static double separatorWidth = 10;
  static int length = 4;
  static BoxDecoration decoration = BoxDecoration(
    border: Border.all(color: Colors.black),
    borderRadius: BorderRadius.circular(10),
  );
  static TextStyle textStyle =
      TextStyle(color: AppColorConstants.mainTextColor, fontSize: 25);
}

class PinTheme {
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final BoxDecoration? decoration;

  PinTheme({this.width, this.height, this.textStyle, this.decoration});
}

class OTPFieldView extends StatefulWidget {
  final PinTheme? defaultPinTheme;
  final PinTheme? currentFocusFieldTheme;
  final PinTheme? nextFieldTheme;
  final PinTheme? submittedPinTheme;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool? obscureText;
  final double? separatorWidth;
  final int? length;
  final TextInputType keyboardType;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? containerDecoration;

  const OTPFieldView({
    super.key,
    this.defaultPinTheme,
    this.currentFocusFieldTheme,
    this.nextFieldTheme,
    this.submittedPinTheme,
    required this.onSubmitted,
    this.onChanged,
    this.obscureText,
    this.separatorWidth,
    this.length,
    this.keyboardType = TextInputType.number,
    this.padding,
    this.margin,
    this.containerDecoration,
  });

  @override
  State<OTPFieldView> createState() => _OTPFieldViewState();
}

class _OTPFieldViewState extends State<OTPFieldView> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  int numberOfFields = OTPFieldViewConstants.length;

  @override
  void initState() {
    super.initState();
    numberOfFields = widget.length ?? OTPFieldViewConstants.length;
    controllers =
        List.generate(numberOfFields, (index) => TextEditingController());
    focusNodes = List.generate(numberOfFields, (index) => FocusNode());
    focusNodes.first.requestFocus();
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.containerDecoration,
      padding: widget.padding,
      margin: widget.margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          numberOfFields,
          (index) => Container(
            width: _getWidth(index),
            height: _getHeight(index),
            decoration: _getBoxDecoration(index),
            alignment: Alignment.center,
            child: Center(
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                textAlign: TextAlign.center,
                style: _getTextFieldStyle(index),
                obscureText: widget.obscureText ?? false,
                keyboardType: widget.keyboardType,
                maxLength: 1,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.isNotEmpty && index < numberOfFields - 1) {
                    focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    focusNodes[index - 1].requestFocus();
                  }
                  widget.onChanged?.call(value);
                  if (value.isNotEmpty && index == numberOfFields - 1) {
                    widget.onSubmitted.call(_getOTP());
                  }
                },
              ),
            ),
          ).rp(index < numberOfFields - 1
              ? widget.separatorWidth ??
                  OTPFieldViewConstants.separatorWidth
              : 0),
        ),
      ),
    );
  }

  int get focusTextFieldIndex {
    int index = focusNodes.indexWhere((element) => element.hasFocus);
    return index == -1 ? 0 : index;
  }

  TextStyle? _getTextFieldStyle(int index) {
    if (focusNodes[index].hasFocus || focusTextFieldIndex == index) {
      return widget.currentFocusFieldTheme?.textStyle ??
          widget.defaultPinTheme?.textStyle ??
          OTPFieldViewConstants.textStyle;
    } else if (index < (numberOfFields - 1) &&
        controllers[index].text.isNotEmpty) {
      return widget.submittedPinTheme?.textStyle ??
          widget.defaultPinTheme?.textStyle ??
          OTPFieldViewConstants.textStyle;
    } else if (index == focusTextFieldIndex + 1) {
      return widget.nextFieldTheme?.textStyle ??
          widget.defaultPinTheme?.textStyle ??
          OTPFieldViewConstants.textStyle;
    } else {
      return widget.defaultPinTheme?.textStyle ??
          OTPFieldViewConstants.textStyle;
    }
  }

  BoxDecoration? _getBoxDecoration(int index) {
    if (focusNodes[index].hasFocus || focusTextFieldIndex == index) {
      return widget.currentFocusFieldTheme?.decoration ??
          widget.defaultPinTheme?.decoration ??
          OTPFieldViewConstants.decoration;
    } else if (index < (numberOfFields - 1) &&
        controllers[index].text.isNotEmpty) {
      return widget.submittedPinTheme?.decoration ??
          widget.defaultPinTheme?.decoration ??
          OTPFieldViewConstants.decoration;
    } else if (index == focusTextFieldIndex + 1) {
      return widget.nextFieldTheme?.decoration ??
          widget.defaultPinTheme?.decoration ??
          OTPFieldViewConstants.decoration;
    } else {
      return widget.defaultPinTheme?.decoration ??
          OTPFieldViewConstants.decoration;
    }
  }

  double? _getHeight(int index) {
    if (focusNodes[index].hasFocus || focusTextFieldIndex == index) {
      return widget.currentFocusFieldTheme?.height ??
          widget.defaultPinTheme?.height ??
          OTPFieldViewConstants.height;
    } else if (index < (numberOfFields - 1) &&
        controllers[index].text.isNotEmpty) {
      return widget.submittedPinTheme?.height ??
          widget.defaultPinTheme?.height ??
          OTPFieldViewConstants.height;
    } else if (index == focusTextFieldIndex + 1) {
      return widget.submittedPinTheme?.height ??
          widget.defaultPinTheme?.height ??
          OTPFieldViewConstants.height;
    } else {
      return widget.defaultPinTheme?.height ??
          OTPFieldViewConstants.height;
    }
  }

  double? _getWidth(int index) {
    if (focusNodes[index].hasFocus || focusTextFieldIndex == index) {
      return widget.currentFocusFieldTheme?.width ??
          widget.defaultPinTheme?.width ??
          OTPFieldViewConstants.width;
    } else if (index < (numberOfFields - 1) &&
        controllers[index].text.isNotEmpty) {
      return widget.submittedPinTheme?.width ??
          widget.defaultPinTheme?.width ??
          OTPFieldViewConstants.width;
    } else if (index == focusTextFieldIndex + 1) {
      return widget.submittedPinTheme?.width ??
          widget.defaultPinTheme?.width ??
          OTPFieldViewConstants.width;
    } else {
      return widget.defaultPinTheme?.width ?? OTPFieldViewConstants.width;
    }
  }

  String _getOTP() {
    String otp = '';
    for (var controller in controllers) {
      otp += controller.text;
    }
    return otp;
  }
}
