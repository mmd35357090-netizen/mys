import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/ui/dating/dating_extras.dart';
import 'package:foap/screens/add_on/ui/dating/dating_plans.dart';
import 'package:foap/util/app_util.dart';

class DatingCard extends StatefulWidget {
  const DatingCard({super.key}) ;

  @override
  State<DatingCard> createState() => DatingCardState();
}

class DatingCardState extends State<DatingCard> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: datingString.tr,
          ),
          const Expanded(child: CardsStackWidget()),
        ],
      ),
    );
  }
}

class CardsStackWidget extends StatefulWidget {
  const CardsStackWidget({super.key});

  @override
  State<CardsStackWidget> createState() => _CardsStackWidgetState();
}

class _CardsStackWidgetState extends State<CardsStackWidget>
    with SingleTickerProviderStateMixin {
  final DatingController datingController = DatingController();

  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    datingController.getDatingProfiles();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (datingController.datingUsers.isNotEmpty) {
            datingController.datingUsers.removeLast();
          }
        });
        _animationController.reset();
        swipeNotifier.value = Swipe.none;
        if (datingController.datingUsers.isEmpty) {
          datingController.loadStatus();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  UserModel? get _top => datingController.datingUsers.isEmpty
      ? null
      : datingController.datingUsers.last;

  void _doLike({bool superLike = false}) {
    final UserModel? p = _top;
    if (p == null || _animationController.isAnimating) return;
    if (superLike && datingController.superLikesLeft.value <= 0) {
      AppUtil.showToast(
          message: 'You have used all Super Likes for today',
          isSuccess: false);
      return;
    }
    datingController.likeProfile(p,
        superLike: superLike, onMatch: (u) => showMatchDialog(u));
    swipeNotifier.value = Swipe.right;
    _animationController.forward();
  }

  void _doSkip() {
    final UserModel? p = _top;
    if (p == null || _animationController.isAnimating) return;
    datingController.skipProfile(p);
    swipeNotifier.value = Swipe.left;
    _animationController.forward();
  }

  void _doRewind() {
    if (datingController.lastSkipped == null) {
      AppUtil.showToast(message: 'Nothing to rewind', isSuccess: false);
      return;
    }
    datingController.rewind();
  }

  void _doBoost() {
    if (datingController.boostActive.value) {
      AppUtil.showToast(message: 'Your boost is active', isSuccess: true);
      return;
    }
    if (!datingController.boostAvailable.value) {
      AppUtil.showToast(
          message: "You have already used today's free boost",
          isSuccess: false);
      return;
    }
    datingController.boost();
    AppUtil.showToast(
        message: 'Boost started: you are shown first for 30 minutes',
        isSuccess: true);
  }

  void _openDetail(UserModel p) {
    showDatingProfileDetail(p,
        photos: datingController.photos[p.id],
        distanceKm: datingController.distances[p.id],
        onLike: () => _doLike(),
        onSkip: () => _doSkip(),
        onMore: () => showDatingMoreSheet(p, onRemoved: () {
              Get.back();
              setState(() => datingController.datingUsers
                  .removeWhere((e) => e.id == p.id));
            }));
  }

  void _openMore(UserModel p) {
    showDatingMoreSheet(p, onRemoved: () {
      setState(() =>
          datingController.datingUsers.removeWhere((e) => e.id == p.id));
    });
  }

  Widget _statusBar() {
    return Obx(() {
      final bool paused = datingController.isPaused.value;
      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
          child: Row(children: [
            if (datingController.dailyLimit.value > 0)
              _chip(Icons.local_fire_department_rounded,
                  '${datingController.remaining.value} left today'),
            const SizedBox(width: 8),
            _chip(Icons.star_rounded,
                '${datingController.superLikesLeft.value}',
                color: const Color(0xFF1D9BF0)),
            if (datingController.boostActive.value) ...[
              const SizedBox(width: 8),
              _chip(Icons.bolt_rounded, 'Boost on',
                  color: const Color(0xFF8E44AD)),
            ],
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (v) {
                if (v == 'pause') {
                  datingController.setPaused(!paused);
                } else if (v == 'boost') {
                  _doBoost();
                } else if (v == 'plans') {
                  Get.to(() => const DatingPlans());
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'pause',
                    child: Text(paused
                        ? 'Show my profile again'
                        : 'Hide my profile (pause)')),
                const PopupMenuItem(value: 'boost', child: Text('Boost my profile')),
                const PopupMenuItem(
                    value: 'plans', child: Text('Get more profiles per day')),
              ],
            ),
          ]),
        ),
        if (paused)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.visibility_off_rounded,
                  size: 18, color: Color(0xFFB26A00)),
              const SizedBox(width: 8),
              const Expanded(
                  child: Text('Your profile is hidden from other people',
                      style:
                          TextStyle(fontSize: 13, color: Color(0xFF8A5300)))),
              TextButton(
                  onPressed: () => datingController.setPaused(false),
                  child: const Text('Show')),
            ]),
          ),
      ]);
    });
  }

  Widget _chip(IconData icon, String text, {Color? color}) {
    final Color c = color ?? const Color(0xFFE5484D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 4),
        Text(text,
            style:
                TextStyle(fontSize: 12.5, color: c, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _limitView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                  color: const Color(0xFFE5484D).withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.hourglass_bottom_rounded,
                  size: 44, color: Color(0xFFE5484D)),
            ),
            const SizedBox(height: 20),
            const Text("You've seen all of today's profiles",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Come back tomorrow, or get more profiles per day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.5, color: AppColorConstants.iconColor)),
            const SizedBox(height: 22),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorConstants.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24))),
                onPressed: () => Get.to(() => const DatingPlans()),
                child: const Text('Get more profiles',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _retryView() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded,
            size: 48, color: AppColorConstants.iconColor),
        const SizedBox(height: 12),
        const Text('Could not load profiles',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        OutlinedButton(
            onPressed: () => datingController.getDatingProfiles(),
            child: const Text('Try again')),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _statusBar(),
      Expanded(
        child: Obx(() => datingController.isLoading.value
            ? const CardsStackShimmerWidget()
            : datingController.loadFailed.value &&
                    datingController.datingUsers.isEmpty
                ? _retryView()
                : datingController.datingUsers.isEmpty
                    ? (datingController.limitReached.value
                        ? _limitView()
                        : emptyData(
                            title: noDatingProfilesFoundString.tr,
                            subTitle: datingExploreString.tr,
                          ))
                    : _stack()),
      ),
    ]);
  }

  Widget _stack() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 100,
          child: ValueListenableBuilder(
            valueListenable: swipeNotifier,
            builder: (context, swipe, _) => Stack(
              clipBehavior: Clip.none,
              children:
                  List.generate(datingController.datingUsers.length, (index) {
                final UserModel profile = datingController.datingUsers[index];
                if (index == datingController.datingUsers.length - 1) {
                  datingController.loadPhotos(profile.id);
                  return PositionedTransition(
                    rect: RelativeRectTween(
                      begin: RelativeRect.fromSize(
                          const Rect.fromLTWH(0, 0, 580, 340),
                          const Size(580, 340)),
                      end: RelativeRect.fromSize(
                          Rect.fromLTWH(
                              swipe != Swipe.none
                                  ? swipe == Swipe.left
                                      ? -300
                                      : 300
                                  : 0,
                              0,
                              580,
                              340),
                          const Size(580, 340)),
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    )),
                    child: RotationTransition(
                      turns: Tween<double>(
                              begin: 0,
                              end: swipe != Swipe.none
                                  ? swipe == Swipe.left
                                      ? -0.1 * 0.3
                                      : 0.1 * 0.3
                                  : 0.0)
                          .animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0, 0.4, curve: Curves.easeInOut),
                        ),
                      ),
                      child: DragWidget(
                        profile: profile,
                        index: index,
                        swipeNotifier: swipeNotifier,
                        isLastCard: true,
                        photos: datingController.photos[profile.id],
                        distanceKm: datingController.distances[profile.id],
                        onInfo: () => _openDetail(profile),
                        onMore: () => _openMore(profile),
                      ),
                    ),
                  );
                } else {
                  return DragWidget(
                    profile: profile,
                    index: index,
                    swipeNotifier: swipeNotifier,
                    distanceKm: datingController.distances[profile.id],
                  );
                }
              }),
            ),
          ).round(10),
        ),
        Positioned(
          left: 0,
          child: DragTarget<int>(
            builder: (context, accepted, rejected) {
              return IgnorePointer(
                child: Container(
                  height: 700,
                  width: 80.0,
                  color: Colors.transparent,
                ),
              );
            },
            onAcceptWithDetails: (details) {
              final int index = details.data;
              if (index < 0 || index >= datingController.datingUsers.length) {
                return;
              }
              setState(() {
                datingController.skipProfile(datingController.datingUsers[index]);
                datingController.datingUsers.removeAt(index);
              });
              if (datingController.datingUsers.isEmpty) {
                datingController.loadStatus();
              }
            },
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionButtonWidget(
                size: 46,
                onPressed: _doRewind,
                icon: const Icon(Icons.replay_rounded,
                    size: 22, color: Color(0xFFF5A623)),
              ),
              const SizedBox(width: 12),
              ActionButtonWidget(
                onPressed: _doSkip,
                icon: const Icon(Icons.close_rounded,
                    size: 30, color: Color(0xFF8A8F98)),
              ),
              const SizedBox(width: 12),
              ActionButtonWidget(
                size: 52,
                onPressed: () => _doLike(superLike: true),
                icon: const Icon(Icons.star_rounded,
                    size: 26, color: Color(0xFF1D9BF0)),
              ),
              const SizedBox(width: 12),
              ActionButtonWidget(
                onPressed: () => _doLike(),
                icon: const Icon(Icons.favorite_rounded,
                    size: 30, color: Color(0xFFE5484D)),
              ),
              const SizedBox(width: 12),
              ActionButtonWidget(
                size: 46,
                onPressed: _doBoost,
                icon: const Icon(Icons.bolt_rounded,
                    size: 24, color: Color(0xFF8E44AD)),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          child: DragTarget<int>(
            builder: (context, accepted, rejected) {
              return IgnorePointer(
                child: Container(
                  height: 700,
                  width: 80.0,
                  color: Colors.transparent,
                ),
              );
            },
            onAcceptWithDetails: (details) {
              final int index = details.data;
              if (index < 0 || index >= datingController.datingUsers.length) {
                return;
              }
              final UserModel p = datingController.datingUsers[index];
              setState(() {
                datingController.likeProfile(p,
                    onMatch: (u) => showMatchDialog(u));
                datingController.datingUsers.removeAt(index);
              });
              if (datingController.datingUsers.isEmpty) {
                datingController.loadStatus();
              }
            },
          ),
        ),
      ],
    );
  }
}

class DragWidget extends StatefulWidget {
  const DragWidget(
      {super.key,
      required this.profile,
      required this.index,
      required this.swipeNotifier,
      this.isLastCard = false,
      this.onInfo,
      this.onMore,
      this.photos,
      this.distanceKm});
  final List<String>? photos;
  final int? distanceKm;
  final VoidCallback? onInfo;
  final VoidCallback? onMore;
  final UserModel profile;
  final int index;
  final ValueNotifier<Swipe> swipeNotifier;
  final bool isLastCard;

  @override
  State<DragWidget> createState() => _DragWidgetState();
}

class _DragWidgetState extends State<DragWidget> {
  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);
  int _photoIndex = 0;

  List<String> get _photos => (widget.photos != null && widget.photos!.isNotEmpty)
      ? widget.photos!
      : (widget.profile.picture != null ? [widget.profile.picture!] : <String>[]);

  void _onTapCard(TapUpDetails d) {
    final double w = Get.width - 40;
    final double x = d.localPosition.dx;
    final int n = _photos.length;
    if (widget.isLastCard && n > 1 && x < w * 0.3) {
      setState(() => _photoIndex = (_photoIndex - 1).clamp(0, n - 1));
    } else if (widget.isLastCard && n > 1 && x > w * 0.7) {
      setState(() => _photoIndex = (_photoIndex + 1).clamp(0, n - 1));
    } else {
      widget.onInfo?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      // Data is the value this Draggable stores.
      data: widget.index,
      feedback: Material(
        color: Colors.transparent,
        child: ValueListenableBuilder(
          valueListenable: swipeNotifier,
          builder: (context, swipe, _) {
            return RotationTransition(
              turns: swipe != Swipe.none
                  ? swipe == Swipe.left
                      ? const AlwaysStoppedAnimation(-15 / 360)
                      : const AlwaysStoppedAnimation(15 / 360)
                  : const AlwaysStoppedAnimation(0),
              child: Stack(
                children: [
                  ProfileCard(profile: widget.profile),
                  swipe != Swipe.none
                      ? swipe == Swipe.right
                          ? Positioned(
                              top: 40,
                              left: 20,
                              child: Transform.rotate(
                                angle: 12,
                                child: TagWidget(
                                  text: likeString.tr.toLowerCase(),
                                  color: Colors.green[400]!,
                                ),
                              ),
                            )
                          : Positioned(
                              top: 50,
                              right: 24,
                              child: Transform.rotate(
                                angle: -12,
                                child: TagWidget(
                                  text: disLikeString.tr.toUpperCase(),
                                  color: Colors.red[400]!,
                                ),
                              ),
                            )
                      : const SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
      ),
      onDragUpdate: (DragUpdateDetails dragUpdateDetails) {
        // When Draggable widget is dragged right
        if (dragUpdateDetails.delta.dx > 0 &&
            dragUpdateDetails.globalPosition.dx >
                Get.width / 2) {
          swipeNotifier.value = Swipe.right;
        }
        // When Draggable widget is dragged left
        if (dragUpdateDetails.delta.dx < 0 &&
            dragUpdateDetails.globalPosition.dx <
                Get.width / 2) {
          swipeNotifier.value = Swipe.left;
        }
      },
      onDragEnd: (drag) {
        swipeNotifier.value = Swipe.none;
      },

      childWhenDragging: Container(
        color: Colors.transparent,
      ),

      child: ValueListenableBuilder(
          valueListenable: widget.swipeNotifier,
          builder: (BuildContext context, Swipe swipe, Widget? child) {
            return Stack(
              children: [
                GestureDetector(
                    onTapUp: _onTapCard,
                    child: ProfileCard(
                        profile: widget.profile,
                        imageUrl: _photos.isEmpty
                            ? null
                            : _photos[_photoIndex.clamp(0, _photos.length - 1)],
                        photoCount: _photos.length,
                        photoIndex: _photoIndex,
                        distanceKm: widget.distanceKm,
                        onInfo: widget.onInfo,
                        onMore: widget.onMore)),
                // heck if this is the last card and Swipe is not equal to Swipe.none
                swipe != Swipe.none && widget.isLastCard
                    ? swipe == Swipe.right
                        ? Positioned(
                            top: 40,
                            left: 20,
                            child: Transform.rotate(
                              angle: 12,
                              child: TagWidget(
                                text: likeString.tr.toUpperCase(),
                                color: Colors.green[400]!,
                              ),
                            ),
                          )
                        : Positioned(
                            top: 50,
                            right: 24,
                            child: Transform.rotate(
                              angle: -12,
                              child: TagWidget(
                                text: disLikeString.tr.toUpperCase(),
                                color: Colors.red[400]!,
                              ),
                            ),
                          )
                    : const SizedBox.shrink(),
              ],
            );
          }),
    ).setPadding(top: 15);
  }
}

class TagWidget extends StatelessWidget {
  const TagWidget({
    super.key,
    required this.text,
    required this.color,
  }) ;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: color,
            width: 3,
          ),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard(
      {super.key,
      required this.profile,
      this.onInfo,
      this.onMore,
      this.imageUrl,
      this.photoCount = 1,
      this.photoIndex = 0,
      this.distanceKm});
  final String? imageUrl;
  final int photoCount;
  final int photoIndex;
  final int? distanceKm;
  final UserModel profile;
  final VoidCallback? onInfo;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final String displayName = profile.name == null || profile.name!.isEmpty
        ? profile.userName
        : profile.name!;
    final String genderText = profile.genderType == GenderType.female
        ? femaleString.tr
        : profile.genderType == GenderType.other
            ? otherString.tr
            : maleString.tr;

    return SizedBox(
      height: Get.height - 270,
      width: Get.width - 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: (imageUrl ?? profile.picture) != null
                  ? CachedNetworkImage(
                      imageUrl: (imageUrl ?? profile.picture)!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                          color: AppColorConstants.cardColor,
                          child: const Center(
                              child: SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.4)))),
                      errorWidget: (context, url, error) => Container(
                          color: AppColorConstants.cardColor,
                          child: Center(
                              child: Icon(Icons.person_rounded,
                                  size: 72,
                                  color: AppColorConstants.iconColor))),
                    )
                  : Image.asset(
                      'assets/images/avatar_1.jpg',
                      fit: BoxFit.cover,
                    ),
            ),
            if (photoCount > 1)
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: Row(
                  children: List.generate(
                      photoCount,
                      (i) => Expanded(
                            child: Container(
                              height: 3.5,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                    alpha: i == photoIndex ? 0.95 : 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          )),
                ),
              ),
            if (onMore != null)
              Positioned(
                top: 20,
                right: 12,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onMore,
                    child: const SizedBox(
                        height: 36,
                        width: 36,
                        child: Icon(Icons.more_horiz_rounded,
                            color: Colors.white, size: 20)),
                  ),
                ),
              ),
            if (profile.isVerified)
              const Positioned(
                top: 28,
                left: 16,
                child: Icon(Icons.verified_rounded,
                    color: Color(0xFF1D9BF0), size: 26),
              ),
            // soft dark fade so the text is always readable
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xE6000000), Color(0x00000000)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: displayName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700)),
                        if (profile.dob != null && profile.dob != '')
                          TextSpan(
                              text: '  ${profile.dob!.calculateAge}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400)),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (profile.city != null && profile.city != '') ...[
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: Colors.white70),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(profile.city!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (distanceKm != null) ...[
                          const Icon(Icons.near_me_outlined,
                              size: 15, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text('$distanceKm km',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(width: 10),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(genderText,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).setPadding(left: 20, right: 20);
  }
}

class ActionButtonWidget extends StatelessWidget {
  const ActionButtonWidget(
      {super.key,
      required this.onPressed,
      required this.icon,
      this.size = 62});
  final double size;
  final VoidCallback onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColorConstants.cardColor,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          height: size,
          width: size,
          child: Center(child: icon),
        ),
      ),
    );
  }
}

enum Swipe { left, right, none }
