import 'package:flutter/material.dart';
import 'package:foap/helper/string_extension.dart';

class WKImage1 extends StatelessWidget {
  final String path;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;
  final AlignmentGeometry? alignment;
  final Function(dynamic, dynamic)? placeholder;
  final Function(dynamic, dynamic, dynamic)? errorWidget;

  const WKImage1(
      {super.key,
      required this.path,
      this.color,
      this.height,
      this.width,
      this.fit,
      this.placeholder,
      this.alignment,
      this.errorWidget});

  @override
  Widget build(BuildContext context) {
    return path.isNetworkPath
        ? Image.network(
            path,
            height: height ?? double.infinity,
            width: width ?? double.infinity,
            fit: fit ?? BoxFit.contain,
            alignment: alignment ?? Alignment.center,
          )
        : Image.asset(path,
            height: height ?? double.infinity,
            width: width ?? double.infinity,
            fit: fit ?? BoxFit.contain,
            alignment: alignment ?? Alignment.center,
            color: color);
  }
}
