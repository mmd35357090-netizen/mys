import '../../helper/imports/common_import.dart';
import '../settings_menu/settings_controller.dart';

class PostOptionsPopup extends StatelessWidget {
  final SettingsController _settingsController = Get.find();
  final Function(PostOptionType) callbackHandler;

  PostOptionsPopup({super.key, required this.callbackHandler});

  @override
  Widget build(BuildContext context) {
    List<Widget> options = [];

    options.add(cameraButton());

    if (_settingsController.setting.value!.enableImagePost) {
      options.add(galleryButton());
    }
    if (_settingsController.setting.value!.enableVideoPost) {
      options.add(videoButton());
    }
    options.add(drawButton());
    options.add(audioButton());
    options.add(gifButton());
    options.add(pollButton());

    return SizedBox(
      height: 30,
      child: ListView.separated(
        padding: EdgeInsets.only(
            left: DesignConstants.horizontalPadding,
            right: DesignConstants.horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (ctx, index) {
          return options[index];
        },
        separatorBuilder: (ctx, index) {
          return const SizedBox(
            width: 8,
          );
        },
      ),
    );
  }

  Widget cameraButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.camera,
      name: cameraString.tr,
      onPress: () async {
        callbackHandler(PostOptionType.camera);
      },
    );
  }

  Widget galleryButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.gallery,
      name: galleryString,
      onPress: () async {
        callbackHandler(PostOptionType.gallery);
      },
    );
  }

  Widget videoButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.videoCamera,
      name: videoString.tr,
      onPress: () async {
        callbackHandler(PostOptionType.video);
      },
    );
  }

  Widget drawButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.drawing,
      name: drawingString.tr,
      imageUrl: 'assets/images/dashboard/draw_icon.svg',
      onPress: () {
        callbackHandler(PostOptionType.drawing);
      },
    );
  }

  Widget audioButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.mic,
      name: audioString.tr,
      onPress: () {
        callbackHandler(PostOptionType.audio);
      },
    );
  }

  Widget gifButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.gif,
      name: gifString.tr,
      onPress: () {
        callbackHandler(PostOptionType.gif);
      },
    );
  }

  Widget pollButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.poll,
      name: pollString.tr,
      onPress: () {
        callbackHandler(PostOptionType.poll);
      },
    );
  }
}

class ModalComponents extends StatelessWidget {
  final bool check;
  final String? imageUrl;
  final ThemeIcon icon;
  final String name;
  final VoidCallback? onPress;

  const ModalComponents(
      {super.key,
      required this.check,
      this.imageUrl,
      required this.icon,
      required this.name,
      this.onPress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ThemeIconWidget(icon),
        const SizedBox(
          width: 10,
        ),
        BodySmallText(
          name,
        ),
      ],
    ).hP8.borderWithRadius(value: 0.5, radius: 5).ripple(() {
      onPress!();
    });
  }
}
