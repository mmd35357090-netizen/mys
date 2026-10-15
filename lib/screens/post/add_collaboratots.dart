import 'package:foap/controllers/post/add_post_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/post/select_users.dart';
import '../../components/user_card.dart';

class AddCollaborators extends StatefulWidget {
  const AddCollaborators({super.key});

  @override
  AddCollaboratorsState createState() => AddCollaboratorsState();
}

class AddCollaboratorsState extends State<AddCollaborators> {
  final AddPostController addPostController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: addCollaboratorString.tr),
          Expanded(
            child: Column(
              children: [
                Obx(() => Expanded(
                      child: SizedBox(
                        child: addPostController.collaborators.isNotEmpty
                            ? ListView.separated(
                                padding: const EdgeInsets.only(
                                    top: 20, bottom: 50),
                                itemCount:
                                    addPostController.collaborators.length,
                                itemBuilder: (context, index) {
                                  UserModel user = addPostController
                                      .collaborators[index];
                                  return UserTile(
                                    profile: user,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return divider(height: 1).vP16;
                                },
                              )
                            : emptyUser(
                                title: noCollaborationFound.tr,
                                subTitle: searchSomeUserToAddAsCollaborator.tr,
                              ),
                      ),
                    )),
                AppThemeButton(
                    text: addCollaboratorString.tr,
                    onPress: () {
                      selectUsers();
                    }),
                const SizedBox(
                  height: 10,
                ),
              ],
            ).hp(DesignConstants.horizontalPadding),
          ),
        ],
      ),
    );
  }

  void selectUsers() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: SelectUser(userSelected: (user) {
                addPostController.addCollaborator(user);
              }),
            ));
  }
}
