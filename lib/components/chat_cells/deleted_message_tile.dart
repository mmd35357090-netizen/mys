import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class DeletedMessageChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const DeletedMessageChatTile({super.key, required this.message})
      ;

  @override
  Widget build(BuildContext context) {
    return Text(
      thisMessageIsDeletedString.tr,
      style: TextStyle(fontSize: FontSizes.b2)
          .copyWith(decoration: TextDecoration.underline),
    );
  }
}
