import 'dart:ui';
import 'package:foap/helper/imports/common_import.dart';

class DrawingPad extends StatefulWidget {
  final bool enableDrawing;

  const DrawingPad({super.key, required this.enableDrawing});

  @override
  State<DrawingPad> createState() => _DrawingPadState();
}

class _DrawingPadState extends State<DrawingPad> {
  List<Offset?> points = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: Get.width,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (widget.enableDrawing) {
            setState(() {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              points.add(renderBox.globalToLocal(details.globalPosition));
            });
          }
        },
        onPanEnd: (details) {
          if (widget.enableDrawing) {
            points.add(null); // Add null to signify the end of a stroke
          }
        },
        child: CustomPaint(
          painter: MyPainter(points),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  List<Offset?> points;

  MyPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        // Draw points for touch up (end of stroke)
        canvas.drawPoints(PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
