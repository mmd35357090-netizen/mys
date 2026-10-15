import 'package:flutter/material.dart';

class WKToggleSwitch1 extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color borderColor;
  final double borderWidth;
  final double width;
  final double height;
  final Duration animationDuration;
  final String? activeText;
  final String? inactiveText;
  final TextStyle? activeTextStyle;
  final TextStyle? inactiveTextStyle;
  final bool showShadow;
  final double shadowBlurRadius;
  final Color shadowColor;

  const WKToggleSwitch1({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0.0,
    this.width = 60.0,
    this.height = 30.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.activeText,
    this.inactiveText,
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.showShadow = false,
    this.shadowBlurRadius = 4.0,
    this.shadowColor = Colors.black26,
  });

  @override
  State<WKToggleSwitch1> createState() => _WKToggleSwitch1State();
}

class _WKToggleSwitch1State extends State<WKToggleSwitch1> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialValue;
  }

  void _toggleSwitch() {
    setState(() {
      _isActive = !_isActive;
      widget.onChanged(_isActive);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSwitch,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          color: _isActive ? widget.activeColor : widget.inactiveColor,
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          boxShadow: widget.showShadow
              ? [
            BoxShadow(
              color: widget.shadowColor,
              blurRadius: widget.shadowBlurRadius,
            ),
          ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: widget.animationDuration,
              alignment:
              _isActive ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: widget.height - 8,
                  height: widget.height - 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (widget.activeText != null && widget.inactiveText != null)
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!_isActive)
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          widget.inactiveText!,
                          style: widget.inactiveTextStyle ??
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    if (_isActive)
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Text(
                          widget.activeText!,
                          style: widget.activeTextStyle ??
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
