import 'package:foap/helper/imports/common_import.dart';


import '../../controllers/notification/notification_setting_controller.dart';
import '../../universal_components/menu_tiles.dart';


class AppNotificationSettings extends StatefulWidget {
  const AppNotificationSettings({super.key});

  @override
  State<AppNotificationSettings> createState() =>
      _AppNotificationSettingsState();
}

class _AppNotificationSettingsState extends State<AppNotificationSettings> {
  final NotificationSettingController settingController =
      NotificationSettingController();

  @override
  void initState() {
    super.initState();
    settingController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            backNavigationBar(title: notificationSettingsString.tr),
            const SizedBox(
              height: 20,
            ),
            GetBuilder<NotificationSettingController>(
                init: settingController,
                builder: (ctx) {
                  return Column(
                    children: [
                      _card(Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BodyLargeText(turnOffAllString.tr,
                              weight: TextWeight.bold),
                          settingController.turnOfAll.value == 1
                              ? ThemeIconWidget(
                                  ThemeIcon.selectedRadio,
                                  color: AppColorConstants.themeColor,
                                ).ripple(() {
                                  settingController.turnOfAll.value = 0;
                                })
                              : ThemeIconWidget(ThemeIcon.circleOutline,
                                      color: AppColorConstants.iconColor)
                                  .ripple(() {
                                  settingController.turnOfAll.value = 1;
                                  settingController
                                      .likesNotificationStatus.value = 0;
                                  settingController
                                      .commentNotificationStatus.value = 0;
                                })
                        ],
                      )).setPadding(
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding,
                          bottom: 8),
                      settingSegment(likesString.tr).vP8,
                      settingSegment(commentsString.tr).vP8,
                    ],
                  );
                })
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  Widget settingSegment(String title) {
    final bool isLikes = title == likesString.tr;
    final int status = isLikes
        ? settingController.likesNotificationStatus.value
        : settingController.commentNotificationStatus.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: BodySmallText(
            title.toUpperCase(),
            weight: TextWeight.bold,
            color: AppColorConstants.subHeadingTextColor,
          ),
        ),
        _card(Column(
          children: [
            settingOption(title, offString.tr, status == 0),
            settingOption(title, fromPeopleOrFollowString.tr, status == 2),
            settingOption(title, fromEveryoneString.tr, status == 1),
          ],
        )),
      ],
    ).hp(DesignConstants.horizontalPadding);
  }

  Widget settingOption(String sectionName, String title, bool isSelected) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BodyLargeText(title),
          isSelected
              ? ThemeIconWidget(ThemeIcon.selectedRadio,
                  color: AppColorConstants.themeColor)
              : ThemeIconWidget(ThemeIcon.circleOutline,
                  color: AppColorConstants.iconColor)
        ],
      ).vP8,
    ).ripple(() {
      settingController.updateNotificationSetting(
          section: sectionName, title: title);
    });
  }
}
