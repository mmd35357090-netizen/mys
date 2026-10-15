import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/club_imports.dart';
import '../reuseable_widgets/club_listing.dart';

class SearchClubsListing extends StatefulWidget {
  const SearchClubsListing({super.key}) ;

  @override
  SearchClubsListingState createState() => SearchClubsListingState();
}

class SearchClubsListingState extends State<SearchClubsListing> {
  final ClubsController _clubsController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Row(
            children: [
              ThemeIconWidget(
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
                      _clubsController.setSearchText(value);
                    },
                    onSearchStarted: () {
                      //controller.startSearch();
                    },
                    onSearchCompleted: (searchTerm) {}),
              ),
            ],
          ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 25),
          divider().tP8,
          Expanded(
            child: ClubListing(),
          ),
        ],
      ),
    );
  }
}
