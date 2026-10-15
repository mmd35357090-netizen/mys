import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';

class EventMemberTile extends StatelessWidget {
  final EventMemberModel member;
  final VoidCallback? viewCallback;

  const EventMemberTile({
    super.key,
    required this.member,
    this.viewCallback,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserAvatarView(
              user: member.user!,
              size: 40,
            ),
            SizedBox(
              width: Get.width - 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(member.user!.userName, weight: TextWeight.bold)
                      .bP4,
                  member.user!.country != null
                      ? BodyMediumText(
                    '${member.user!.city!}, ${member.user!.country!}',
                  )
                      : Container()
                ],
              ).hp(DesignConstants.horizontalPadding),
            ).ripple(() {
              if (viewCallback != null) {
                viewCallback!();
              }
            }),
            // const Spacer(),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}
