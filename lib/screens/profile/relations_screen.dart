import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/relation_controller.dart';
import '../../model/relation_model.dart';
import 'other_user_profile.dart';

RelationController _ensureRelationController() {
  if (Get.isRegistered<RelationController>()) {
    return Get.find<RelationController>();
  }
  return Get.put(RelationController());
}

/// Bottom sheet: choose which relation to propose to [userId].
void showInviteRelationSheet(int userId) {
  final RelationController controller = _ensureRelationController();
  controller.loadRelationTypes();

  Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        color: AppColorConstants.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Heading6Text(addRelationString.tr, weight: TextWeight.bold),
            const SizedBox(height: 8),
            Flexible(
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.relationTypes.length,
                    itemBuilder: (ctx, index) {
                      final type = controller.relationTypes[index];
                      return ListTile(
                        leading: Icon(Icons.favorite_border_rounded,
                            color: AppColorConstants.themeColor),
                        title: BodyLargeText(type.name),
                        onTap: () {
                          Get.back();
                          controller.invite(type, userId);
                        },
                      );
                    },
                  )),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ).topRounded(28),
      isScrollControlled: true);
}

class RelationsScreen extends StatefulWidget {
  const RelationsScreen({super.key});

  @override
  State<RelationsScreen> createState() => _RelationsScreenState();
}

class _RelationsScreenState extends State<RelationsScreen> {
  late final RelationController _controller = _ensureRelationController();
  int _tab = 0; // 0 = my relations, 1 = invitations

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: relationsString.tr),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: DesignConstants.horizontalPadding, vertical: 12),
            child: Row(children: [
              Expanded(child: _tabButton(0, myRelationsString.tr)),
              const SizedBox(width: 10),
              Expanded(child: _tabButton(1, invitationsString.tr)),
            ]),
          ),
          Expanded(
            child: Obx(() {
              final list =
                  _tab == 0 ? _controller.myRelations : _controller.invitations;
              if (_controller.isLoading.value && list.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.isEmpty) {
                return Center(
                    child: BodyLargeText(noRelationsString.tr,
                        color: AppColorConstants.subHeadingTextColor));
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(
                    horizontal: DesignConstants.horizontalPadding,
                    vertical: 8),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) => _tile(list[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(int index, String title) {
    final selected = _tab == index;
    return Container(
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? AppColorConstants.themeColor
            : AppColorConstants.themeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: BodyMediumText(title,
          weight: TextWeight.semiBold,
          color: selected ? Colors.white : AppColorConstants.themeColor),
    ).ripple(() => setState(() => _tab = index));
  }

  Widget _tile(RelationInvitationModel item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(18),
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
      child: Row(
        children: [
          AvatarView(
              url: item.otherUserPicture,
              name: item.otherUserName.isEmpty ? null : item.otherUserName,
              size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(item.otherUserName,
                    maxLines: 1, weight: TextWeight.semiBold),
                BodySmallText(item.isIncoming
                    ? '${item.relationName} · ${invitedYouString.tr}'
                    : '${item.relationName}${item.isPending ? ' · ${pendingString.tr}' : ''}'),
              ],
            ),
          ),
          if (item.isIncoming) ...[
            Icon(Icons.check_circle_rounded, color: AppColorConstants.themeColor)
                .ripple(() => _controller.reply(item, true)),
            const SizedBox(width: 10),
            Icon(Icons.cancel_rounded, color: AppColorConstants.red)
                .ripple(() => _controller.reply(item, false)),
          ] else
            Icon(Icons.close_rounded, color: AppColorConstants.red)
                .ripple(() => AppUtil.showNewConfirmationAlert(
                      title: removeRelationString.tr,
                      subTitle: areYouSureRemoveRelationString.tr,
                      okHandler: () => _controller.cancel(item),
                      cancelHandler: () {},
                    )),
        ],
      ),
    ).ripple(() {
      if (item.otherUserId > 0) {
        Get.to(() => OtherUserProfile(userId: item.otherUserId));
      }
    });
  }
}
