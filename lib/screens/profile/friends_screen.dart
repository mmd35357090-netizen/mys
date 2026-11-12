import 'package:foap/helper/imports/common_import.dart';
import '../../api_handler/apis/friends_api.dart';
import '../../api_handler/apis/misc_api.dart';
import '../../api_handler/apis/users_api.dart';
import '../../components/sm_tab_bar.dart';
import '../../components/user_card.dart';
import '../../model/api_meta_data.dart';

/// Friends hub: requests I received, requests I sent, mutual friends and
/// suggestions. Built on top of the follow system (a friend is somebody who
/// follows me and whom I follow).
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  // null until the count is known
  int? _requestCount;
  int? _sentCount;
  int? _friendCount;

  @override
  void initState() {
    super.initState();
    // load the totals up-front so every tab title shows its number
    MiscApi.getFollowRequests(
        page: 1,
        resultCallback: (_, meta) => _setCount(requests: meta.totalCount));
    FriendsApi.getSentRequests(
        page: 1,
        resultCallback: (_, meta) => _setCount(sent: meta.totalCount));
    FriendsApi.getFriends(
        page: 1,
        resultCallback: (_, meta) => _setCount(friends: meta.totalCount));
  }

  void _setCount({int? requests, int? sent, int? friends}) {
    if (!mounted) return;
    setState(() {
      if (requests != null) _requestCount = requests;
      if (sent != null) _sentCount = sent;
      if (friends != null) _friendCount = friends;
    });
  }

  String _label(String title, int? count) =>
      count == null ? title : '$title ($count)';

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _label(requestsString.tr, _requestCount),
      _label(sentRequestsString.tr, _sentCount),
      _label(friendsString.tr, _friendCount),
      suggestionsString.tr,
    ];

    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: DefaultTabController(
        length: tabs.length,
        child: Column(
          children: [
            backNavigationBar(title: friendsString.tr),
            SMTabBar(tabs: tabs, canScroll: true),
            Expanded(
              child: TabBarView(
                children: [
                  _UserListTab(
                    onTotal: (n) => _setCount(requests: n),
                    onRemoved: () => _setCount(
                        requests: ((_requestCount ?? 1) - 1).clamp(0, 1 << 30).toInt()),
                    emptyText: noRequestsString.tr,
                    loader: (page, done) {
                      MiscApi.getFollowRequests(
                          page: page,
                          resultCallback: (result, meta) => done(
                              result.map((e) => e.sender).toList(), meta));
                    },
                    tileBuilder: (user, remove, refresh) =>
                        FollowRequestSenderUserTile(
                      profile: user,
                      acceptCallback: () {
                        remove();
                        MiscApi.acceptFollowRequest(
                            userId: user.id,
                            completionHandler: () {
                              Get.find<UserProfileManager>().refreshProfile();
                            });
                      },
                      declineCallback: () {
                        remove();
                        MiscApi.declineFollowRequest(userId: user.id);
                      },
                    ),
                  ),
                  _UserListTab(
                    onTotal: (n) => _setCount(sent: n),
                    onRemoved: () => _setCount(
                        sent: ((_sentCount ?? 1) - 1).clamp(0, 1 << 30).toInt()),
                    emptyText: noSentRequestsString.tr,
                    loader: (page, done) =>
                        FriendsApi.getSentRequests(
                            page: page, resultCallback: done),
                    tileBuilder: (user, remove, refresh) =>
                        _SentRequestTile(
                      user: user,
                      cancelCallback: () {
                        remove();
                        FriendsApi.cancelSentRequest(
                            userId: user.id, resultCallback: (_) {});
                      },
                    ),
                  ),
                  _UserListTab(
                    onTotal: (n) => _setCount(friends: n),
                    emptyText: noFriendsString.tr,
                    loader: (page, done) =>
                        FriendsApi.getFriends(
                            page: page, resultCallback: done),
                    tileBuilder: (user, remove, refresh) =>
                        UserTile(profile: user),
                  ),
                  _UserListTab(
                    emptyText: noSuggestionsString.tr,
                    loader: (page, done) {
                      UsersApi.getSuggestedUsers(
                          page: page,
                          resultCallback: (result) => done(
                              result,
                              APIMetaData(
                                  totalCount: result.length,
                                  pageCount: 1,
                                  currentPage: 1,
                                  perPage: result.length)));
                    },
                    tileBuilder: (user, remove, refresh) => UserTile(
                      profile: user,
                      followCallback: () {
                        user.followingStatus = user.isPrivateProfile
                            ? FollowingStatus.requested
                            : FollowingStatus.following;
                        refresh();
                        UsersApi.followUnfollowUser(
                            isFollowing: true, user: user);
                      },
                      unFollowCallback: () {
                        user.followingStatus = FollowingStatus.notFollowing;
                        refresh();
                        UsersApi.followUnfollowUser(
                            isFollowing: false, user: user);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentRequestTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback cancelCallback;

  const _SentRequestTile({required this.user, required this.cancelCallback});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: UserTile(profile: user)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColorConstants.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: BodySmallText(cancelString.tr,
              weight: TextWeight.semiBold, color: AppColorConstants.red),
        ).ripple(cancelCallback),
      ],
    );
  }
}

typedef _Loader = void Function(
    int page, void Function(List<UserModel>, APIMetaData) done);

/// A pull-to-refresh, infinite scrolling list of users.
class _UserListTab extends StatefulWidget {
  final _Loader loader;
  final Widget Function(
          UserModel user, VoidCallback removeSelf, VoidCallback refresh)
      tileBuilder;
  final String emptyText;
  final void Function(int total)? onTotal;
  final VoidCallback? onRemoved;

  const _UserListTab(
      {required this.loader,
      required this.tileBuilder,
      required this.emptyText,
      this.onTotal,
      this.onRemoved});

  @override
  State<_UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<_UserListTab>
    with AutomaticKeepAliveClientMixin {
  final List<UserModel> _users = [];
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  bool _firstLoadDone = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _load();
      }
    });
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _users.clear();
    _page = 1;
    _hasMore = true;
    _firstLoadDone = false;
    _loading = false;
    _load();
  }

  void _load() {
    if (_loading || !_hasMore) return;
    _loading = true;
    widget.loader(_page, (result, meta) {
      if (!mounted) return;
      setState(() {
        for (final user in result) {
          if (_users.indexWhere((e) => e.id == user.id) < 0) {
            _users.add(user);
          }
        }
        _hasMore = meta.currentPage < meta.pageCount;
        widget.onTotal?.call(meta.totalCount);
        _page += 1;
        _loading = false;
        _firstLoadDone = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_firstLoadDone) {
      return const ShimmerUsers().hp(DesignConstants.horizontalPadding);
    }

    if (_users.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(children: [
          const SizedBox(height: 120),
          Center(
              child: BodyLargeText(widget.emptyText,
                  color: AppColorConstants.subHeadingTextColor)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.only(
            top: 16,
            bottom: 60,
            left: DesignConstants.horizontalPadding,
            right: DesignConstants.horizontalPadding),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return widget.tileBuilder(user, () {
            setState(() => _users.removeWhere((e) => e.id == user.id));
            widget.onRemoved?.call();
          }, () => setState(() {}));
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
      ),
    );
  }
}
