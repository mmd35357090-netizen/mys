import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../components/user_card.dart';

class UsersList extends StatefulWidget {
  final List<UserModel> usersList;

  const UsersList({Key? key, required this.usersList}) : super(key: key);

  @override
  UsersListState createState() => UsersListState();
}

class UsersListState extends State<UsersList> {
  late List<UserModel> usersList = [];

  @override
  void initState() {
    usersList = widget.usersList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.arrow_back_ios,
                    color: AppColorConstants.iconColor)),
            Center(
                child: Heading5Text(
              friendsNearByString.tr,
              color: AppColorConstants.themeColor,

            )),
            Container()
          ])),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 25),
        itemCount: usersList.length,
        itemBuilder: (context, index) {
          return SelectableUserTile(model: usersList[index]);
        },
        separatorBuilder: (context, index) {
          return Container(
            height: 0.1,
            width: double.infinity,
            color: AppColorConstants.dividerColor,
          ).vP4;
        },
      ).hP16,
    );
  }
}
