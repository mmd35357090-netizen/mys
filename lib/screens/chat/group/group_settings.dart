import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../../components/actionSheets/action_sheet1.dart';
import '../../../model/generic_item.dart';

class GroupSettings extends StatefulWidget {
  const GroupSettings({super.key}) ;

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  final ChatRoomDetailController _chatRoomDetailController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
               title: groupSettingsString.tr),

          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColorConstants.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
                  width: 0.6),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5))
              ],
            ),
            height: 68,
            child: Column(
              // padding: const EdgeInsets.only(top: 10, bottom: 10),
              children: [
                Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                      child: Center(
                        child: ThemeIconWidget(
                          ThemeIcon.send,
                          size: 18,
                          color: AppColorConstants.themeColor,
                        ),
                      ),
                    ).round(12),
                    const SizedBox(
                      width: 15,
                    ),
                    BodyLargeText(
                      sendMessagesString.tr,
                      weight: TextWeight.semiBold,
                    ),
                    const Spacer(),
                    Obx(() => BodyMediumText(
                          _chatDetailController.chatRoom.value!.groupAccess == 1
                              ? onlyAdminsString.tr
                              : allParticipantsString.tr,
                          color: AppColorConstants.themeColor,
                          weight: TextWeight.semiBold,
                        )),
                    const SizedBox(width: 6),
                    ThemeIconWidget(
                      ThemeIcon.nextArrow,
                      size: 12,
                    )
                  ],
                ).ripple(() {
                  openActionSheetForSendMessage();
                }),
              ],
            ).p16,
          ).hP16,
        ],
      ),
    );
  }

  openActionSheetForSendMessage() {
    showModalBottomSheet(
        context: context,

        backgroundColor: Colors.transparent,
        builder: (context) => ActionSheet1(
              items: [
                GenericItem(
                  id: '1',
                  title: allParticipantsString.tr,
                  subTitle: allParticipantsString.tr,
                  // isSelected: selectedItem?.id == '1',
                ),
                GenericItem(
                  id: '2',
                  title: onlyAdminsString.tr,
                  subTitle: onlyAdminsString.tr,
                  // isSelected: selectedItem?.id == '1',
                ),
              ],
              itemCallBack: (item) {
                if (item.id == '1') {
                  _chatRoomDetailController.updateGroupAccess(2);
                } else if (item.id == '2') {
                  _chatRoomDetailController.updateGroupAccess(1);
                }
              },
            ));
  }
}
