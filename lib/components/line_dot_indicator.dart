import 'package:foap/helper/imports/common_import.dart';

class LineDotsIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Color color;
  final double dotSize;
  final double spacing;

  const LineDotsIndicator({super.key,
    required this.itemCount,
    required this.currentIndex,
    this.color = Colors.grey,
    this.dotSize = 10.0,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: dotSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(itemCount, (index) {
          // double _size = currentIndex == index ? dotSize * 2 : dotSize;
          return Container(
            width: dotSize,
            height: 5,
            color: currentIndex == index
                ? AppColorConstants.themeColor
                : AppColorConstants.subHeadingTextColor,
          ).circular.hp(2);
        }).toList(),
      ),
    );
  }
}
