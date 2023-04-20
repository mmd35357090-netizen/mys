import 'dart:math';
import 'package:currency_picker/currency_picker.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:foap/helper/imports/common_import.dart';

class InputField extends StatefulWidget {
  final String? label;
  final bool? showLabelInNewLine;
  final String? hintText;
  final String? defaultText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ThemeIcon? icon;
  final int? maxLines;
  final bool? showDivider;
  final Color? iconColor;
  final bool? isDisabled;
  final bool? startedEditing;
  final bool? isError;
  final bool? iconOnRightSide;
  final Color? backgroundColor;
  final bool? showBorder;
  final Color? borderColor;
  final double? cornerRadius;

  final Color? cursorColor;
  final TextStyle? textStyle;

  const InputField({
    Key? key,
    this.label,
    this.showLabelInNewLine = true,
    this.hintText,
    this.defaultText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.icon,
    this.maxLines,
    this.showDivider = false,
    this.iconColor,
    this.isDisabled,
    this.startedEditing = false,
    this.isError = false,
    this.iconOnRightSide = false,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor,
    this.cornerRadius = 0,
    this.cursorColor,
    this.textStyle,
  }) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late String? label;
  late bool? showLabelInNewLine;

  late String? hintText;
  late String? defaultText;
  late TextEditingController? controller;
  late ValueChanged<String>? onChanged;
  late ValueChanged<String>? onSubmitted;
  late ThemeIcon? icon;
  late int? maxLines;
  late bool? showDivider;
  late Color? iconColor;
  late bool isDisabled;
  late bool? startedEditing;
  late bool? isError;
  late bool? iconOnRightSide;
  late Color? backgroundColor;
  late bool? showBorder;
  late Color? borderColor;
  late double? cornerRadius;

  late Color cursorColor;

  @override
  void initState() {
    label = widget.label;
    showLabelInNewLine = widget.showLabelInNewLine;
    hintText = widget.hintText;
    defaultText = widget.defaultText;
    controller = widget.controller;
    onChanged = widget.onChanged;
    onSubmitted = widget.onSubmitted;
    icon = widget.icon;
    maxLines = widget.maxLines;
    showDivider = widget.showDivider;
    iconColor = widget.iconColor;
    isDisabled = widget.isDisabled ?? false;
    startedEditing = widget.startedEditing;
    isError = widget.isError;
    iconOnRightSide = widget.iconOnRightSide;
    backgroundColor = widget.backgroundColor;
    showBorder = widget.showBorder;
    borderColor = widget.borderColor;
    cornerRadius = widget.cornerRadius;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cursorColor = widget.cursorColor ?? AppColorConstants.iconColor;

    return Container(
      decoration: BoxDecoration(
        color: isError == false
            ? backgroundColor
            : (showDivider == false && showBorder == false)
                ? AppColorConstants.red
                : backgroundColor,
        borderRadius: BorderRadius.circular(cornerRadius ?? 0),
        border: showBorder == true
            ? Border.all(
                width: 0.5,
                color: isError == true
                    ? AppColorConstants.red
                    : borderColor ?? AppColorConstants.dividerColor)
            : null,
      ),
      // margin: EdgeInsets.symmetric(vertical: 5),
      // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: maxLines != null
          ? (min(maxLines!, 10) * 20) + 45
          : label != null
              ? 70
              : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (label != null && showLabelInNewLine == true)
              ? BodyMediumText(label!, weight: TextWeight.medium).bP4
              : Container(),
          Row(
            children: [
              (label != null && showLabelInNewLine == false)
                  ? BodyMediumText(label!, weight: TextWeight.medium).bP4
                  : Container(),
              iconOnRightSide == false ? iconView() : Container(),
              Expanded(
                child: Focus(
                  child: TextField(
                    controller: controller,
                    keyboardType: hintText == hintText
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                    textAlign: TextAlign.left,
                    style: widget.textStyle ??
                        TextStyle(
                            fontSize: FontSizes.h6,
                            color: AppColorConstants.grayscale900),
                    onChanged: widget.onChanged,
                    maxLines: maxLines,
                    decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.only(left: 10, right: 10),
                        counterText: "",
                        // labelText: hintText,
                        labelStyle: TextStyle(
                            fontSize: FontSizes.b2,
                            color: AppColorConstants.grayscale700),
                        hintStyle: TextStyle(
                            fontSize: FontSizes.h6,
                            color: AppColorConstants.grayscale500),
                        hintText: hintText),
                  ),
                  onFocusChange: (hasFocus) {
                    startedEditing = hasFocus;
                    setState(() {});
                  },
                ),
              ),
              iconOnRightSide == true ? iconView() : Container(),
            ],
          ),
          line()
        ],
      ),
    );
  }

  Widget line() {
    return showDivider == true
        ? Container(
            height: 0.5,
            color: startedEditing == true
                ? AppColorConstants.themeColor
                : isError == true
                    ? AppColorConstants.red
                    : AppColorConstants.dividerColor)
        : Container();
  }

  Widget iconView() {
    return icon != null
        ? ThemeIconWidget(icon!,
                color: iconColor ?? AppColorConstants.themeColor, size: 20)
            .rP16
        : Container();
  }
}

class InputPriceField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? currencyText;
  final String? currencyFlag;
  final bool? disableCurrencySelection;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCurrencyValueChanged;

  const InputPriceField({
    Key? key,
    this.label,
    this.hintText,
    this.currencyText,
    this.currencyFlag,
    this.controller,
    this.onChanged,
    this.onCurrencyValueChanged,
    this.disableCurrencySelection,
  }) : super(key: key);

  @override
  State<InputPriceField> createState() => _InputPriceFieldState();
}

class _InputPriceFieldState extends State<InputPriceField> {
  late String? currencyText;
  late String? currencyFlag;

  @override
  void initState() {
    currencyText = widget.currencyText;
    currencyFlag = widget.currencyFlag;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColorConstants.backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label != null
              ? BodyMediumText(
                  widget.label!,
                  weight: TextWeight.medium,
                ).bP8
              : Container(),
          Row(
            children: [
              Row(
                children: [
                  BodyLargeText(widget.currencyText ?? "+1",
                          weight: TextWeight.bold)
                      .hP8
                      .ripple(() {
                    showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showCurrencyName: true,
                      showCurrencyCode: true,
                      onSelect: (Currency currency) {
                        setState(() {
                          currencyFlag = currency.flag;
                          currencyText = currency.symbol;
                          widget.onCurrencyValueChanged!(widget.currencyText!);
                        });
                      },
                    );
                  }),
                ],
              ),
              Container(
                width: 1,
                height: 20,
                color: AppColorConstants.dividerColor,
              ).hP16,
              Expanded(
                  child: TextField(
                style: TextStyle(fontSize: FontSizes.b3),
                controller: widget.controller,
                onChanged: widget.onChanged,
                keyboardType: TextInputType.number,
                cursorColor: AppColorConstants.iconColor,
                decoration: InputDecoration(
                  hintStyle: TextStyle(fontSize: FontSizes.b3),
                  hintText: widget.hintText,
                  border: InputBorder.none,
                ),
              ))
            ],
          )
        ],
      ),
    );
  }
}

class DropDownField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final bool? disable;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const DropDownField({
    Key? key,
    this.label,
    this.hintText,
    this.disable,
    this.controller,
    this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<DropDownField> createState() => _DropDownFieldState();
}

class _DropDownFieldState extends State<DropDownField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColorConstants.backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.label != null
              ? BodyMediumText(widget.label!, weight: TextWeight.medium).bP8
              : Container(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: AbsorbPointer(
                absorbing: true,
                child: TextField(
                  readOnly: true,
                  style: TextStyle(fontSize: FontSizes.b3),
                  controller: widget.controller,
                  keyboardType: TextInputType.number,
                  cursorColor: AppColorConstants.iconColor,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: FontSizes.b3),
                    hintText: widget.hintText,
                    border: InputBorder.none,
                  ),
                ),
              )),
              ThemeIconWidget(
                ThemeIcon.downArrow,
                color: AppColorConstants.iconColor,
                size: 25,
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
        ],
      ),
    ).ripple(() {
      widget.onTap!();
    });
  }
}

class InputMobileNumberField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? phoneCodeText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? phoneCodeValueChanged;
  final bool? showDivider;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final bool? isError;
  final bool? showBorder;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? cornerRadius;

  const InputMobileNumberField({
    Key? key,
    this.label,
    this.hintText,
    this.showDivider,
    required this.phoneCodeText,
    this.controller,
    required this.onChanged,
    required this.phoneCodeValueChanged,
    this.cursorColor,
    this.textStyle,
    this.isError,
    this.showBorder,
    this.borderColor,
    this.cornerRadius,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<InputMobileNumberField> createState() => _InputMobileNumberFieldState();
}

class _InputMobileNumberFieldState extends State<InputMobileNumberField> {
  late Color? cursorColor;
  late TextStyle? textStyle;
  bool? startedEditing;
  late bool? isError;
  late String? phoneCodeText;
  late TextEditingController controller;
  late String? hintText;
  late bool? showBorder;
  late Color? backgroundColor;
  late bool? showDivider;
  late Color? borderColor;
  late double? cornerRadius;

  @override
  void initState() {
    isError = widget.isError;
    controller = widget.controller!;
    hintText = widget.hintText;
    showBorder = widget.showBorder;
    backgroundColor = widget.backgroundColor;
    showDivider = widget.showDivider;
    borderColor = widget.borderColor;
    cornerRadius = widget.cornerRadius;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cursorColor = widget.cursorColor ?? AppColorConstants.iconColor;
    // textStyle = widget.textStyle ?? TextStyle(fontSize: FontSizes.h5);
    return Container(
      // color:Colors.red,
      // margin: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isError == false
            ? backgroundColor
            : (showDivider == false && showBorder == false)
                ? AppColorConstants.red
                : backgroundColor,
        borderRadius: BorderRadius.circular(cornerRadius ?? 0),
        border: showBorder == true
            ? Border.all(
                width: 0.5,
                color: isError == true
                    ? AppColorConstants.red
                    : borderColor ?? AppColorConstants.dividerColor)
            : null,
      ),
      height: widget.label != null ? 72 : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.label != null
              ? BodyMediumText(widget.label!, weight: TextWeight.medium)
              : Container(),
          Row(children: [
            BodyLargeText(
              '${widget.phoneCodeText}',
            ).hP8.ripple(() {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                // optional. Shows phone code before the country name.
                onSelect: (Country country) {
                  setState(() {
                    phoneCodeText = '+${country.phoneCode}';
                    widget.phoneCodeValueChanged!(phoneCodeText!);
                  });
                },
              );
            }),
            Container(
              width: 0.5,
              height: 20,
              color: AppColorConstants.dividerColor,
            ).hP8,
            Expanded(
              child: SizedBox(
                  height: 46,
                  child: Focus(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: FontSizes.h6,
                          color: AppColorConstants.grayscale900),
                      onChanged: widget.onChanged,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.only(left: 10, right: 10),
                          counterText: "",
                          // labelText: hintText,
                          // labelStyle: TextStyle(fontSize: FontSizes.b2)!.copyWith(color: ColorConstants.themeColor),
                          hintStyle: TextStyle(
                              fontSize: FontSizes.h6,
                              color: AppColorConstants.grayscale600),
                          hintText: hintText),
                    ),
                    onFocusChange: (hasFocus) {
                      startedEditing = hasFocus;
                      setState(() {});
                    },
                  )),
            )
          ]),
          line()
        ],
      ),
    );
  }

  Widget line() {
    return widget.showDivider == true
        ? Container(
            height: 0.5,
            color: startedEditing == true
                ? AppColorConstants.themeColor
                : isError == true
                    ? AppColorConstants.red
                    : AppColorConstants.dividerColor)
        : Container();
  }
}

class InputDateField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? defaultText;
  final ValueChanged<TimeOfDay>? onChanged;

  const InputDateField({
    Key? key,
    this.label,
    this.hintText,
    this.defaultText,
    this.onChanged,
  }) : super(key: key);

  @override
  State<InputDateField> createState() => _InputDateFieldState();
}

class _InputDateFieldState extends State<InputDateField> {
  String? label;
  String? hintText;
  String? defaultText;
  TextEditingController controller = TextEditingController();
  ValueChanged<TimeOfDay>? onChanged;

  @override
  void initState() {
    hintText = widget.label;
    hintText = widget.hintText;
    defaultText = widget.defaultText;
    onChanged = widget.onChanged;

    controller.text = defaultText ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label != null
              ? BodyMediumText(widget.label!, weight: TextWeight.medium).bP8
              : Container(),
          Container(
            width: 80,
            height: 50,
            color: AppColorConstants.backgroundColor,
            child: TextField(
              style: TextStyle(fontSize: FontSizes.b3),
              textAlign: TextAlign.center,
              controller: controller,
              // onChanged: onChanged,
              cursorColor: AppColorConstants.iconColor,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: FontSizes.b3),
                border: InputBorder.none,
              ),
              readOnly: true,
              //set it true, so that user will not able to edit text
              onTap: () async {
                TimeOfDay initialTime = TimeOfDay.now();
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );

                if (pickedTime != null) {
                  //print(pickedTime.minute); //pickedDate output format => 2021-03-10 00:00:00.000
                  // String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  // print(formattedDate); //formatted date output using intl package =>  2021-03-16
                  //you can implement different kind of Date Format here according to your requirement
                  onChanged!(pickedTime);
                  setState(() {
                    controller.text = pickedTime
                        .format(context); //set output date to TextField value.
                  });
                } else {}
              },
            ).hP4,
          ).round(25),
        ],
      ),
    );
  }
}

class RoundedInputDateTimeField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? defaultText;
  final ValueChanged<DateTime>? onChanged;

  const RoundedInputDateTimeField({
    Key? key,
    this.label,
    this.hintText,
    this.defaultText,
    this.onChanged,
  }) : super(key: key);

  @override
  State<RoundedInputDateTimeField> createState() =>
      _RoundedInputDateTimeFieldState();
}

class _RoundedInputDateTimeFieldState extends State<RoundedInputDateTimeField> {
  String? label;
  String? hintText;
  String? defaultText;
  TextEditingController controller = TextEditingController();
  ValueChanged<DateTime>? onChanged;

  @override
  void initState() {
    label = widget.label;
    hintText = widget.hintText;
    defaultText = widget.defaultText;
    onChanged = widget.onChanged;

    controller.text = defaultText ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          widget.label != null
              ? BodyMediumText(widget.label!, weight: TextWeight.medium).bP8
              : Container(),
          Container(
            color: AppColorConstants.backgroundColor,
            child: Center(
              child: TextField(
                style: TextStyle(fontSize: FontSizes.b3),
                textAlign: TextAlign.left,
                controller: controller,
                // onChanged: onChanged,
                cursorColor: AppColorConstants.iconColor,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(fontSize: FontSizes.b3),
                  border: InputBorder.none,
                ),
                readOnly: true,
                //set it true, so that user will not able to edit text
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1960),
                      initialDate: DateTime.now(),
                      lastDate: DateTime(2100));
                  if (pickedDate != null) {
                    onChanged!(pickedDate);
                    setState(() {
                      String formattedDate =
                          DateFormat('dd-MMM-yyyy').format(pickedDate);
                      controller.text =
                          formattedDate; //set output date to TextField value.
                    });
                  } else {}
                },
              ).hP16,
            ),
          ).round(25),
        ],
      ),
    );
  }
}

class DropdownBorderedField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ThemeIcon? icon;
  final Color? iconColor;
  final bool? iconOnRightSide;
  final Color? backgroundColor;
  final bool? showBorder;
  final Color? borderColor;
  final double? cornerRadius;
  final VoidCallback? onTap;

  final TextStyle? textStyle;

  const DropdownBorderedField(
      {Key? key,
      this.hintText,
      this.controller,
      this.icon,
      this.iconColor,
      this.iconOnRightSide = false,
      this.backgroundColor,
      this.showBorder = false,
      this.borderColor,
      this.cornerRadius = 0,
      this.textStyle,
      this.onTap})
      : super(key: key);

  @override
  State<DropdownBorderedField> createState() => _DropdownBorderedState();
}

class _DropdownBorderedState extends State<DropdownBorderedField> {
  late String? hintText;
  late TextEditingController? controller;
  late ThemeIcon? icon;
  late Color? iconColor;
  late bool? iconOnRightSide;
  late Color? backgroundColor;
  late bool? showBorder;
  late Color? borderColor;
  late double? cornerRadius;

  @override
  void initState() {
    hintText = widget.hintText;
    controller = widget.controller;
    icon = widget.icon;
    iconColor = widget.iconColor;
    iconOnRightSide = widget.iconOnRightSide;
    backgroundColor = widget.backgroundColor;
    showBorder = widget.showBorder;
    borderColor = widget.borderColor;
    cornerRadius = widget.cornerRadius;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cornerRadius ?? 0),
        border: showBorder == true
            ? Border.all(
                width: 0.5,
                color: borderColor ?? AppColorConstants.dividerColor)
            : null,
      ),
      height: 60,
      child: Row(children: [
        Expanded(
          child: AbsorbPointer(
              absorbing: true,
              child: TextField(
                readOnly: true,
                controller: controller,
                keyboardType: hintText == hintText
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                textAlign: TextAlign.left,
                style: widget.textStyle ??
                    TextStyle(
                        fontSize: FontSizes.b3,
                        color: AppColorConstants.grayscale900),
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    counterText: "",
                    // labelText: hintText,
                    labelStyle: TextStyle(
                        fontSize: FontSizes.b2,
                        color: AppColorConstants.grayscale900),
                    hintStyle: widget.textStyle ??
                        TextStyle(
                            fontSize: FontSizes.b3,
                            color: AppColorConstants.grayscale900),
                    hintText: hintText),
              )),
        ),
        iconOnRightSide == true ? iconView() : Container(),
      ]),
    ).ripple(() {
      widget.onTap!();
    });
  }

  Widget iconView() {
    return icon != null
        ? ThemeIconWidget(icon!,
                color: iconColor ?? AppColorConstants.themeColor, size: 20)
            .rP16
        : Container();
  }
}
