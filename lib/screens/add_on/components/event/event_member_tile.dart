import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';

class EventMemberTile extends StatelessWidget {
  final EventMemberModel member;
  final VoidCallback? viewCallback;

  const EventMemberTile({
    Key? key,
    required this.member,
    this.viewCallback,
  }) : super(key: key);

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
              width: MediaQuery.of(context).size.width - 200,
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
              ).hP16,
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
