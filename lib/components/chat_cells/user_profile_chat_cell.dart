import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class UserProfileChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const UserProfileChatTile({super.key, required this.message})
      ;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 65,
        width: double.infinity,
        child: Container(
                color: message.isMineMessage
                    ? AppColorConstants.disabledColor
                    : AppColorConstants.themeColor.withValues(alpha: 0.2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AvatarView(
                      url: message.profileContent.userPicture,
                      name: message.profileContent.userName,
                      size: 40,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Heading6Text(
                          message.profileContent.userName,
                          weight: TextWeight.medium,
                        ),
                        BodyMediumText(
                          message.profileContent.location,
                        ),
                      ],
                    ),
                    const Spacer(),
                    ThemeIconWidget(ThemeIcon.nextArrow),
                  ],
                ).hP8)
            .round(15));
  }

}

