import 'package:flutter/material.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/theme/theme_icon.dart';

import '../components/custom_texts.dart';
import '../util/app_config_constants.dart';

class PasswordField extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final Color? backgroundColor;
  final String? label;
  final bool? showDivider;
  final bool? iconOnRightSide;
  final ThemeIcon? icon;
  final Color? iconColor;
  final bool? showRevealPasswordIcon;
  final bool? showLabelInNewLine;
  final bool? showBorder;
  final Color? borderColor;
  final bool? isError;
  final bool? startedEditing;
  final double? cornerRadius;

  final Color? cursorColor;
  final TextStyle? textStyle;

  const PasswordField({
    Key? key,
    required this.onChanged,
    this.controller,
    this.label,
    this.hintText,
    this.showDivider = false,
    this.backgroundColor,
    this.iconOnRightSide,
    this.iconColor,
    this.icon,
    this.showLabelInNewLine = true,
    this.showRevealPasswordIcon = false,
    this.showBorder = false,
    this.borderColor,
    this.isError = false,
    this.startedEditing = false,
    this.cornerRadius = 0,
    this.cursorColor,
    this.textStyle,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool showPassword = false;
  late String? label;
  late String? hintText;
  late bool? showDivider;
  late Color? backgroundColor;
  late bool? iconOnRightSide;
  late ThemeIcon? icon;
  late Color? iconColor;
  late bool? showRevealPasswordIcon;
  late bool? showLabelInNewLine;
  late bool? showBorder;
  late Color? borderColor;
  late bool? isError;
  late bool? startedEditing;
  late double? cornerRadius;
  late ValueChanged<String> onChanged;
  late TextEditingController? controller;

  late Color? cursorColor;

  @override
  void initState() {
    onChanged = widget.onChanged;
    controller = widget.controller;
    hintText = widget.hintText;
    label = widget.label;
    showDivider = widget.showDivider;
    backgroundColor = widget.backgroundColor;
    iconColor = widget.iconColor;
    icon = widget.icon;
    iconOnRightSide = widget.iconOnRightSide;
    showRevealPasswordIcon = widget.showRevealPasswordIcon;
    showLabelInNewLine = widget.showLabelInNewLine;
    showBorder = widget.showBorder;
    borderColor = widget.borderColor;
    isError = widget.isError;
    startedEditing = widget.startedEditing;
    cornerRadius = widget.cornerRadius;

    cursorColor = widget.cursorColor;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      height: label != null ? 70 : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (label != null && showLabelInNewLine == true)
              ? BodyMediumText(label!, weight: TextWeight.medium).bP4
              : Container(),
          Expanded(
            child: Row(
              children: [
                (label != null && showLabelInNewLine == false)
                    ? BodyMediumText(label!, weight: TextWeight.medium).bP4
                    : Container(),
                iconView(),
                Expanded(
                    child: Focus(
                  child: TextField(
                          style: TextStyle(
                              fontSize: FontSizes.h6,
                              color: AppColorConstants.grayscale900),
                          controller: controller,
                          onChanged: onChanged,
                          cursorColor: AppColorConstants.themeColor,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(left: 10, right: 10),
                            // labelText: hintText,
                            hintText: hintText,
                            labelStyle: TextStyle(fontSize: FontSizes.b2),
                            hintStyle: TextStyle(
                                fontSize: FontSizes.h6,
                                color: AppColorConstants.grayscale500),
                            border: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ))
                      .setPadding(
                          left: backgroundColor != null ? 16 : 0,
                          right: backgroundColor != null ? 16 : 0),
                  onFocusChange: (hasFocus) {
                    startedEditing = hasFocus;
                    setState(() {});
                  },
                )),
                revealPasswordIcon()
              ],
            ),
          ),
          line()
        ],
      ),
    );
  }

  Widget revealPasswordIcon() {
    return showRevealPasswordIcon == true
        ? Row(
            children: [
              ThemeIconWidget(
                showPassword == false ? ThemeIcon.showPwd : ThemeIcon.hidePwd,
                color: AppColorConstants.iconColor,
                size: 20,
              ).ripple(() {
                setState(() {
                  showPassword = !showPassword;
                });
              }),
              const SizedBox(
                width: 16,
              )
            ],
          )
        : Container();
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
        ? ThemeIconWidget(
            icon!,
            color: iconColor ?? AppColorConstants.themeColor,
            size: 20,
          ).rP16
        : Container();
  }
}
