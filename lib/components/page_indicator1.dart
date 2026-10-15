import 'package:flutter/material.dart';

class WKIndicator1 extends StatelessWidget {
  final int dotsCount;
  final int position;
  final Color dotColor;
  final Color activeDotColor;
  final double dotSpacing;
  final double dotWidth;
  final double dotHeight;
  final double? activeDotWidth;
  final Duration animationDuration;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final BoxShape shape;

  const WKIndicator1({
    super.key,
    required this.dotsCount,
    required this.position,
    required this.dotColor,
    required this.activeDotColor,
    this.dotSpacing = 8.0,
    this.dotWidth = 20.0,
    this.dotHeight = 4.0,
    this.activeDotWidth,
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius = 2.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotsCount, (index) {
        return AnimatedContainer(
          duration: animationDuration,
          width: index == position ? activeDotWidth ?? dotWidth : dotWidth,
          height: dotHeight,
          margin: EdgeInsets.symmetric(horizontal: dotSpacing / 2),
          decoration: BoxDecoration(
            color: index == position ? activeDotColor : dotColor,
            shape: shape,
            borderRadius: shape == BoxShape.rectangle
                ? BorderRadius.circular(borderRadius)
                : null,
            border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: borderWidth,
            ),
          ),
        );
      }),
    );
  }
}
