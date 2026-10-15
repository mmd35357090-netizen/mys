import 'package:foap/api_handler/apis/chat_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:overlay_support/overlay_support.dart';
import '../manager/db_manager_realm.dart';
import '../model/chat_message_model.dart';
import '../model/chat_room_model.dart';
import '../screens/chat/chat_detail.dart';

showNewMessageBanner(ChatMessageModel message, int roomId) async {
  ChatRoomModel? room = await getIt<RealmDBManager>().getRoomById(roomId);
  if (room == null) {
    ChatApi.getChatRoomDetail(roomId, resultCallback: (result) {
      showNotification(message, result);
    });
  } else {
    showNotification(message, room);
  }
}

showNotification(ChatMessageModel message, ChatRoomModel room) {
  showOverlayNotification((context) {
    return Material(
      child: Container(
        color: Colors.transparent,
        child: Container(
          color: AppColorConstants.cardColor,
          child: ListTile(
            leading: AvatarView(
              size: 35,
              url: room.isGroupChat == true
                  ? room.image
                  : room.memberById(message.senderId).userDetail.picture,
              name: room.isGroupChat == true
                  ? room.name
                  : room.memberById(message.senderId).userDetail.userName,
            ),
            title: BodyLargeText(
              room.isGroupChat == true
                  ? '(${room.name}) ${room.memberById(message.senderId).userDetail.userName}'
                  : room.memberById(message.senderId).userDetail.userName,
              weight: TextWeight.semiBold,
              // color: AppColorConstants.themeColor,
            ),
            subtitle: BodyMediumText(
              message.shortInfoForNotification,
            ),
          )
              .setPadding(
                  top: 60,
                  left: DesignConstants.horizontalPadding,
                  right: DesignConstants.horizontalPadding)
              .ripple(() {
            OverlaySupportEntry.of(context)!.dismiss();

            Get.to(() => ChatDetail(
                  chatRoom: room,
                ));
          }),
        ).bottomRounded(15),
      ),
    );
  }, duration: const Duration(milliseconds: 4000));
}
