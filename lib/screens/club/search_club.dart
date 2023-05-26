import 'package:get/get.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/club_imports.dart';
import '../../components/group_avatars/group_avatar2.dart';
import '../../components/search_bar.dart';

class SearchClubsListing extends StatefulWidget {
  const SearchClubsListing({Key? key}) : super(key: key);

  @override
  SearchClubsListingState createState() => SearchClubsListingState();
}

class SearchClubsListingState extends State<SearchClubsListing> {
  final SearchClubsController _searchClubsController = SearchClubsController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchClubsController.clear();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Row(
            children: [
              const ThemeIconWidget(
                ThemeIcon.backArrow,
                size: 25,
              ).ripple(() {
                Get.back();
              }),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: SFSearchBar(
                    hintText: searchString.tr,
                    showSearchIcon: true,
                    iconColor: AppColorConstants.themeColor,
                    onSearchChanged: (value) {
                      _searchClubsController.searchTextChanged(value);
                    },
                    onSearchStarted: () {
                      //controller.startSearch();
                    },
                    onSearchCompleted: (searchTerm) {}),
              ),
            ],
          ).setPadding(left: 16, right: 16, top: 25, bottom: 20),
          divider().tP8,
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate([
                  const SizedBox(
                    height: 40,
                  ),
                  Obx(() {
                    ScrollController scrollController = ScrollController();
                    scrollController.addListener(() {
                      if (scrollController.position.maxScrollExtent ==
                          scrollController.position.pixels) {
                        if (!_searchClubsController.isLoadingClubs.value) {
                          _searchClubsController.searchClubs(
                              name: _searchClubsController.searchText.value);
                        }
                      }
                    });

                    List<ClubModel> clubs = _searchClubsController.clubs;

                    return _searchClubsController.clubs.isEmpty
                        ? Container()
                        : Column(
                            children: [
                              SizedBox(
                                height: clubs.length * 350,
                                child: ListView.separated(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    itemCount: clubs.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext ctx, int index) {
                                      return ClubCard(
                                        club: clubs[index],
                                        joinBtnClicked: () {
                                          _searchClubsController
                                              .joinClub(clubs[index]);
                                        },
                                        leaveBtnClicked: () {
                                          _searchClubsController
                                              .leaveClub(clubs[index]);
                                        },
                                        previewBtnClicked: () {
                                          Get.to(() => ClubDetail(
                                                club: clubs[index],
                                                needRefreshCallback: () {
                                                  _searchClubsController
                                                      .searchClubs(
                                                          name:
                                                              _searchClubsController
                                                                  .searchText
                                                                  .value);
                                                },
                                                deleteCallback: (club) {
                                                  AppUtil.showToast(
                                                      message:
                                                          clubIsDeletedString.tr,
                                                      isSuccess: true);
                                                  _searchClubsController
                                                      .clubDeleted(club);
                                                },
                                              ));
                                        },
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext ctx, int index) {
                                      return const SizedBox(
                                        height: 25,
                                      );
                                    }),
                              ),
                            ],
                          ).bP16;
                  }),
                ]))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
