import 'package:foap/helper/imports/common_import.dart';

class AvatarView extends StatelessWidget {
  final String? url;
  final String? name;

  final double? size;
  final Color? borderColor;

  const AvatarView(
      {super.key,
        required this.url,
        this.size = 60,
        this.borderColor,
        this.name});

  @override
  Widget build(BuildContext context) {
    String initials = '';

    if (name != null) {
      List<String> nameParts = name!.trim().split(' ');
      initials = '';
      for (var part in nameParts) {
        initials += part.substring(0, 1).toUpperCase();
        if (initials.length >= 2) {
          break;
        }
      }
    }

    return SizedBox(
      height: size ?? 60,
      width: size ?? 60,
      child: url != null && (url ?? '').isNotEmpty
          ? CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (context, url) => SizedBox(
            height: 20,
            width: 20,
            child: const CircularProgressIndicator().p16),
        errorWidget: (context, url, error) => const Icon(
          Icons.error,
        ),
      ).round(size ?? 60)
          : Container(
        color: AppColorConstants.backgroundColor,
        child: userNameInitialView(initials, size ?? 60),
      ),
    ).borderWithRadius(
        value: 2,
        radius: size ?? 60,
        color: borderColor ?? AppColorConstants.themeColor);
  }
}

class UserAvatarView extends StatelessWidget {
  final UserModel user;
  final double? size;
  final VoidCallback? onTapHandler;
  final bool hideLiveIndicator;
  final bool hideOnlineIndicator;
  final bool hideBorder;

  const UserAvatarView(
      {super.key,
        required this.user,
        this.size = 60,
        this.onTapHandler,
        this.hideLiveIndicator = false,
        this.hideOnlineIndicator = false,
        this.hideBorder = false});

  @override
  Widget build(BuildContext context) {
    final UserProfileManager userProfileManager = Get.find();

    return SizedBox(
      height: size ?? 60,
      width: size ?? 60,
      child: Stack(
        children: [
          user.liveCallDetail != null && hideLiveIndicator == false
              ? liveUserWidget(
            size: size ?? 60,
          ).ripple(() {
            if (onTapHandler != null) {
              onTapHandler!();
            }
          })
              : userPictureView(
            size: size ?? 60,
          ),
          (user.liveCallDetail == null || hideLiveIndicator == true) &&
              hideOnlineIndicator == false &&
              user.isShareOnlineStatus == true &&
              userProfileManager.user.value!.isShareOnlineStatus
              ? Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                height: 15,
                width: 15,
                color: user.isOnline == true
                    ? AppColorConstants.themeColor
                    : Colors.transparent,
              ).circular)
              : Container(),
          user.isVIPUser == true
              ? Positioned(
              right: 0,
              top: 0,
              child: Image.asset('assets/vip.png',
                  height: (size ?? 60) * 0.4,
                  width: (size ?? 60) * 0.4))
              : Container(),
        ],
      ),
    );
  }

  Widget userPictureView({
    required double size,
    double? radius,
  }) {
    return user.picture != null && user.picture != 'null'
        ? CachedNetworkImage(
      imageUrl: user.picture!,
      fit: BoxFit.cover,
      height: size,
      width: size,
      placeholder: (context, url) => SizedBox(
          height: 20,
          width: 20,
          child: const CircularProgressIndicator().p16),
      errorWidget: (context, url, error) => SizedBox(
          height: size,
          width: size,
          child: Icon(
            Icons.error,
            size: size / 2,
          )),
    ).borderWithRadius(
        value: hideBorder ? 0 : 1,
        radius: size,
        color: AppColorConstants.themeColor)
        : userNameInitialView(user.getInitials, size).borderWithRadius(
        value: hideBorder ? 0 : 1,
        radius: size,
        color: AppColorConstants.themeColor);
  }

  Widget liveUserWidget({
    required double size,
  }) {
    return Stack(
      children: [
        userPictureView(size: size, radius: 5),
        Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Container(
              height: 15,
              color: AppColorConstants.themeColor,
              child: Center(
                child: BodyExtraSmallText(
                  liveString.tr,
                  color: Colors.white,
                ),
              ),
            ).round(5))
      ],
    );
  }
}

class UserPlaneImageView extends StatelessWidget {
  final UserModel user;
  final double? size;

  const UserPlaneImageView({
    super.key,
    required this.user,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? 60,
      width: size ?? 60,
      child: userPictureView(
        size: size ?? 60,
      ),
    );
  }

  Widget userPictureView({
    required double size,
    double? radius,
  }) {
    return user.picture != null
        ? CachedNetworkImage(
      imageUrl: user.picture!,
      fit: BoxFit.cover,
      height: size,
      width: size,
      placeholder: (context, url) => SizedBox(
          height: 20,
          width: 20,
          child: const CircularProgressIndicator().p16),
      errorWidget: (context, url, error) => SizedBox(
          height: size,
          width: size,
          child: Icon(
            Icons.error,
            size: size / 2,
          )),
    ).round(20)
        : userNameInitialView(user.getInitials, size)
        .borderWithRadius(value: 1, radius: 20);
  }
}

Widget userNameInitialView(String initials, double size) {
  return SizedBox(
    height: double.infinity,
    width: double.infinity,
    child: Center(
      child: size < 40
          ? BodySmallText(
        initials,
        weight: TextWeight.medium,
      )
          : size < 60
          ? BodyMediumText(
        initials,
        weight: TextWeight.medium,
      )
          : size < 80
          ? BodyExtraLargeText(
        initials,
        weight: TextWeight.medium,
      )
          : Heading2Text(
        initials,
        weight: TextWeight.medium,
      ),
    ),
  );
}
