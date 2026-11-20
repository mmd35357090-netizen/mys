import 'package:foap/api_handler/apis/users_api.dart';
import 'package:foap/util/app_util.dart';
import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:foap/screens/chat/chat_detail.dart';
import 'package:foap/screens/profile/other_user_profile.dart';

String _ageOf(UserModel p) {
  try {
    if (p.dob != null && p.dob != '') return p.dob!.calculateAge.toString();
  } catch (_) {}
  return '';
}

Widget _avatar(String? url, double size) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6))
      ],
    ),
    child: ClipOval(
      child: url != null && url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (c, u, e) =>
                  const Icon(Icons.person_rounded, size: 48, color: Colors.grey),
            )
          : Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.person_rounded,
                  size: 48, color: Colors.grey)),
    ),
  );
}

/// "It's a Match!" celebration shown when both people liked each other.
void showMatchDialog(UserModel other) {
  if (Get.context == null) return;
  final UserProfileManager manager = Get.find();
  final UserModel? me = manager.user.value;

  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B4DFF), Color(0xFFE5484D)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("It's a Match!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            Text(
              'You and ${other.userName} liked each other',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _avatar(me?.picture, 96),
                Transform.translate(
                    offset: const Offset(-10, 0),
                    child: _avatar(other.picture, 96)),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Break the ice',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _icebreakers
                  .map((m) => GestureDetector(
                        onTap: () {
                          Get.back();
                          _openChat(other, firstMessage: m);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: Text(m,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF7B4DFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26))),
                icon: const Icon(Icons.chat_bubble_rounded),
                label: const Text('Send a message',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                onPressed: () {
                  Get.back();
                  _openChat(other);
                },
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Keep swiping',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

const List<String> _icebreakers = [
  'Hey! Nice to match with you 👋',
  'What does a perfect weekend look like for you?',
  'Coffee or tea? ☕',
];

void _openChat(UserModel user, {String? firstMessage}) {
  if (!Get.isRegistered<ChatDetailController>()) return;
  final ChatDetailController chat = Get.find();
  Loader.show(status: loadingString.tr);
  chat.getChatRoomWithUser(
      userId: user.id,
      callback: (room) async {
        Loader.dismiss();
        Get.to(() => ChatDetail(chatRoom: room));
        if (firstMessage != null) {
          // give the chat screen a moment to open, then send the chosen opener
          await Future.delayed(const Duration(milliseconds: 600));
          try {
            await chat.sendTextMessage(
                messageText: firstMessage,
                mode: ChatMessageActionMode.none,
                room: room);
          } catch (_) {}
        }
      });
}

/// Full profile of a dating card: bio, job, height, location, interests.
void showDatingProfileDetail(
  UserModel p, {
  List<String>? photos,
  int? distanceKm,
  VoidCallback? onLike,
  VoidCallback? onSkip,
  VoidCallback? onMore,
}) {
  final String age = _ageOf(p);
  final List<String> facts = [];
  if (p.occupation != null && p.occupation!.isNotEmpty) {
    facts.add(p.occupation!);
  }
  if (p.city != null && p.city!.isNotEmpty) {
    facts.add(p.city!);
  }
  if (distanceKm != null) {
    facts.add('$distanceKm km away');
  }
  final List<String> slides = (photos != null && photos.isNotEmpty)
      ? photos
      : (p.picture != null ? [p.picture!] : <String>[]);
  if (p.height != null && p.height!.isNotEmpty && p.height != '121.0') {
    facts.add('${p.height} cm');
  }
  if (p.religion != null && p.religion!.isNotEmpty) {
    facts.add(p.religion!);
  }

  Get.bottomSheet(
    DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: AppColorConstants.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.zero,
          children: [
            Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
                child: SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: _PhotoSlider(urls: slides),
                ),
              ),
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 5,
                    width: 44,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(3)),
                  ),
                ),
              ),
              if (onMore != null)
                Positioned(
                  top: 18,
                  right: 14,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz_rounded,
                          color: Colors.white),
                      onPressed: onMore,
                    ),
                  ),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(
                        age.isEmpty ? p.userName : '${p.userName}, $age',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (p.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded,
                          color: Color(0xFF1D9BF0), size: 24),
                    ],
                    if (p.isOnline) ...[
                      const SizedBox(width: 8),
                      Container(
                          height: 10,
                          width: 10,
                          decoration: const BoxDecoration(
                              color: Color(0xFF2ECC71),
                              shape: BoxShape.circle)),
                    ],
                  ]),
                  if (p.isOnline ||
                      (p.chatLastTimeOnline != null &&
                          p.chatLastTimeOnline! > 0)) ...[
                    const SizedBox(height: 6),
                    Text(
                      p.isOnline ? 'Active now' : p.lastSeenAtTime,
                      style: TextStyle(
                          fontSize: 13,
                          color: p.isOnline
                              ? const Color(0xFF2ECC71)
                              : AppColorConstants.iconColor),
                    ),
                  ],
                  if (facts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: facts
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColorConstants.cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(f,
                                    style: const TextStyle(fontSize: 13.5)),
                              ))
                          .toList(),
                    ),
                  ],
                  if (p.bio != null && p.bio!.trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text('About',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(p.bio!,
                        style: const TextStyle(fontSize: 15, height: 1.4)),
                  ],
                  if (p.interests != null && p.interests!.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text('Interests',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: p.interests!
                          .map((i) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColorConstants.themeColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(i.name,
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        color: AppColorConstants.themeColor)),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (onLike != null || onSkip != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (onSkip != null)
                          _roundAction(Icons.close_rounded,
                              const Color(0xFF8A8F98), () {
                            Get.back();
                            onSkip();
                          }),
                        const SizedBox(width: 36),
                        if (onLike != null)
                          _roundAction(Icons.favorite_rounded,
                              const Color(0xFFE5484D), () {
                            Get.back();
                            onLike();
                          }),
                      ],
                    ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget _roundAction(IconData icon, Color color, VoidCallback onTap) {
  return Material(
    color: AppColorConstants.cardColor,
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.18),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
          height: 60, width: 60, child: Icon(icon, color: color, size: 30)),
    ),
  );
}

/// Report / Block / open full social profile.
void showDatingMoreSheet(UserModel p, {VoidCallback? onRemoved}) {
  Get.bottomSheet(
    SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColorConstants.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('View full profile'),
              onTap: () {
                Get.back();
                Get.to(() => OtherUserProfile(userId: p.id, user: p));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Color(0xFFE5484D)),
              title: const Text('Report'),
              onTap: () {
                Get.back();
                UsersApi.reportUser(
                    userId: p.id,
                    resultCallback: () {
                      AppUtil.showToast(
                          message: 'Thanks, we will review this profile',
                          isSuccess: true);
                    });
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: Color(0xFFE5484D)),
              title: const Text('Block'),
              onTap: () {
                Get.back();
                UsersApi.blockUser(
                    userId: p.id,
                    resultCallback: () {
                      AppUtil.showToast(
                          message: 'User blocked', isSuccess: true);
                      onRemoved?.call();
                    });
              },
            ),
          ],
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
  );
}

class _PhotoSlider extends StatefulWidget {
  const _PhotoSlider({required this.urls});
  final List<String> urls;

  @override
  State<_PhotoSlider> createState() => _PhotoSliderState();
}

class _PhotoSliderState extends State<_PhotoSlider> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.person_rounded, size: 80, color: Colors.grey));
    }
    return Stack(children: [
      PageView.builder(
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (c, i) => CachedNetworkImage(
          imageUrl: widget.urls[i],
          fit: BoxFit.cover,
          width: double.infinity,
          errorWidget: (c, u, e) => Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image_rounded,
                  size: 60, color: Colors.grey)),
        ),
      ),
      if (widget.urls.length > 1)
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                widget.urls.length,
                (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: i == _page ? 18 : 6,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: i == _page ? 0.95 : 0.55),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
          ),
        ),
    ]);
  }
}
