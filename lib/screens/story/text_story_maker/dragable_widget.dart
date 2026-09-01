import 'package:foap/helper/imports/common_import.dart';

enum DraggableWidgetType { text, image }

class DraggableWidget extends StatefulWidget {
  final Widget child;
  final DraggableWidgetType type;

  const DraggableWidget({super.key, required this.child, required this.type});

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  var position = Offset(Get.width / 2, Get.height / 2);
  var scale = 1.0;
  var rotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(widget.type == DraggableWidgetType.text){

        }
      },
      child: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable(
              feedback: widget.child,
              childWhenDragging: Opacity(
                opacity: .3,
                child: widget.child,
              ),
              onDragEnd: (details) => position = details.offset,
              child: widget.child,
            ),
          )
        ],
      ),
    );
  }
}
