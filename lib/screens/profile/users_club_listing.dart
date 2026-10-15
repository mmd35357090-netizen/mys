import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/clubs/clubs_controller.dart';
import '../reuseable_widgets/club_listing.dart';

class UsersClubs extends StatefulWidget {
  final UserModel user;

  const UsersClubs({super.key, required this.user});

  @override
  UsersClubsState createState() => UsersClubsState();
}

class UsersClubsState extends State<UsersClubs> {
  final ClubsController _clubsController = Get.find();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    loadData();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
        } else {
          _clubsController.getClubs();
        }
      }
    });

    super.initState();
  }

  loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clubsController.clear();
      _clubsController.setUserId(widget.user.id);
      _clubsController.getClubs();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clubsController.clear();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: '${widget.user.userName} ${clubsString.tr}',
          ),
          Expanded(child: ClubListing())
        ],
      ),
    );
  }
}
