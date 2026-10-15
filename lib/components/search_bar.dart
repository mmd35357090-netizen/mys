import 'package:foap/helper/imports/common_import.dart';

class SFSearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchStarted;
  final ValueChanged<String> onSearchCompleted;

  final Color? iconColor;
  final Color? backgroundColor;
  final double? radius;

  final bool? needBackButton;
  final bool? showSearchIcon;
  final TextStyle? textStyle;
  final double? shadowOpacity;
  final String? hintText;

  const SFSearchBar({
    super.key,
    required this.onSearchCompleted,
    this.onSearchStarted,
    this.onSearchChanged,
    this.iconColor,
    this.radius,
    this.backgroundColor,
    this.needBackButton,
    this.showSearchIcon,
    this.textStyle,
    this.shadowOpacity,
    this.hintText,
  }) ;

  @override
  State<SFSearchBar> createState() => _SFSearchBarState();
}

class _SFSearchBarState extends State<SFSearchBar> {
  late ValueChanged<String>? onSearchChanged;
  late VoidCallback? onSearchStarted;
  late ValueChanged<String> onSearchCompleted;
  TextEditingController controller = TextEditingController();
  late Color? iconColor;
  String? searchText;
  bool? needBackButton;
  bool? showSearchIcon;
  late TextStyle? textStyle;
  late Color? backgroundColor;
  late double? radius;
  late double? shadowOpacity;
  late String? hintText;

  @override
  void initState() {
    onSearchChanged = widget.onSearchChanged;
    onSearchStarted = widget.onSearchStarted;
    onSearchCompleted = widget.onSearchCompleted;
    iconColor = widget.iconColor;
    needBackButton = widget.needBackButton;
    showSearchIcon = widget.showSearchIcon;
    textStyle = widget.textStyle;
    backgroundColor = widget.backgroundColor;
    radius = widget.radius;
    shadowOpacity = widget.shadowOpacity;
    hintText = widget.hintText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            needBackButton == true
                ? IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: ThemeIconWidget(
                      ThemeIcon.backArrow,
                      color: AppColorConstants.themeColor,
                    ))
                : Container(),
            showSearchIcon == true
                ? ThemeIconWidget(
                    ThemeIcon.search,
                    color: iconColor,
                    size: 20,
                  ).lP16.ripple(() {
                    if (searchText != null && searchText!.length > 2) {
                      onSearchChanged!(searchText!);
                    }
                  })
                : Container(),
            Expanded(

              child: TextField(
                  autocorrect: false,
                  controller: controller,
                  onEditingComplete: () {
                    onSearchCompleted(controller.text);
                  },
                  onChanged: (value) {
                    searchText = value;
                    // controller.text = searchText!;
                    if (onSearchChanged != null) {
                      onSearchChanged!(value);
                    }
                    setState(() {});
                  },
                  onTap: () {
                    if (onSearchStarted != null) {
                      onSearchStarted!();
                    }
                  },
                  style: textStyle ??
                      TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.mainTextColor),
                  cursorColor: AppColorConstants.iconColor,
                  decoration: InputDecoration(
                    hintStyle: textStyle ??
                        TextStyle(
                            fontSize: FontSizes.b3,
                            color: AppColorConstants.mainTextColor),
                    hintText: hintText ?? searchAnythingString.tr,
                    border: InputBorder.none,
                  )).setPadding(bottom: 4, left: 8),
            ),
          ],
        ),
      ),
    ).backgroundCard(
        radius: radius ?? 20,
        fillColor: backgroundColor,
        shadowOpacity: shadowOpacity);
  }
}



class WKSearchBarType4 extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchStarted;
  final ValueChanged<String> onSearchCompleted;

  final Color? iconColor;
  final Color? backgroundColor;
  final double? cornerRadius;

  final bool? needBackButton;
  final bool? showSearchIcon;
  final TextStyle? textStyle;
  final double? shadowOpacity;

  final String? hintText;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? iconSize;
  final EdgeInsetsGeometry? iconPadding;
  final Color? borderColor;
  final double? borderWidth;

  const WKSearchBarType4({
    super.key,
    required this.onSearchCompleted,
    this.onSearchStarted,
    this.onSearchChanged,
    this.iconColor,
    this.cornerRadius,
    this.backgroundColor,
    this.needBackButton,
    this.showSearchIcon = true,
    this.textStyle,
    this.shadowOpacity = 0.4,
    this.hintText,
    this.padding,
    this.margin,
    this.height = 50.0,
    this.iconSize = 20.0,
    this.iconPadding,
    this.borderColor,
    this.borderWidth = 0.5,
  });

  @override
  State<WKSearchBarType4> createState() => _WKSearchBarType4State();
}

class _WKSearchBarType4State extends State<WKSearchBarType4> {
  late TextEditingController controller;
  String? searchText;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(widget.cornerRadius ?? 0),
        border: Border.all(
          color: widget.borderColor ?? AppColorConstants.themeColor,
          width: widget.borderWidth!,
        ),
        boxShadow: [
          if (widget.shadowOpacity != null && widget.shadowOpacity! > 0)
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.shadowOpacity!),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.needBackButton == true)
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: ThemeIconWidget(
                  ThemeIcon.backArrow,
                  color: widget.iconColor ?? AppColorConstants.themeColor,
                ),
              ),
            if (widget.showSearchIcon == true)
              Padding(
                  padding: widget.iconPadding ??
                      const EdgeInsets.only(left: 16),
                  child: ThemeIconWidget(
                    ThemeIcon.search,
                    color: widget.iconColor,
                    size: widget.iconSize,
                  )).ripple(() {
                if (searchText != null && searchText!.length > 2) {
                  widget.onSearchChanged!(searchText!);
                }
              }),
            Expanded(
              child: TextField(
                controller: controller,
                onEditingComplete: () {
                  widget.onSearchCompleted(controller.text);
                },
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    if (widget.onSearchChanged != null) {
                      widget.onSearchChanged!(value);
                    }
                  });
                },
                onTap: () {
                  if (widget.onSearchStarted != null) {
                    widget.onSearchStarted!();
                  }
                },
                style: widget.textStyle ??
                    TextStyle(
                        fontSize: 16,
                        color: AppColorConstants.mainTextColor),
                cursorColor: widget.textStyle?.color ??
                    AppColorConstants.themeColor,
                decoration: InputDecoration(
                  hintStyle: widget.textStyle ??
                      TextStyle(
                          fontSize: 16,
                          color: AppColorConstants.mainTextColor),
                  hintText: widget.hintText ?? searchString.tr,
                  border: InputBorder.none,
                ),
              ).setPadding(bottom: 4, left: 8),
            ),
          ],
        ),
      ),
    );
  }
}