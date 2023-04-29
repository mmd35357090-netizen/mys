import 'package:foap/components/profile/relationship_card.dart';
import 'package:foap/controllers/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/relationship/relationship_controller.dart';
import 'package:foap/screens/add_on/ui/add_relationship/search_relation_profile.dart';
import 'package:foap/screens/profile/my_profile.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:get/get.dart';

class AddRelationship extends StatefulWidget {
  const AddRelationship({Key? key}) : super(key: key);

  @override
  State<AddRelationship> createState() => _AddRelationshipState();
}

class _AddRelationshipState extends State<AddRelationship> {
  final RelationshipController _relationshipController =
      RelationshipController();
  final ProfileController _profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  var isSwitched = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    _profileController.getMyProfile();
    _relationshipController.getRelationships();
    _relationshipController.getMyRelationships();
    _relationshipController.getMyInvitations();
  }

  @override
  void dispose() {
    _relationshipController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Obx(() => backNavigationBarWithIconBadge(
              context: context,
              icon: ThemeIcon.notification,
              title: LocalizationString.myFamily,
              badgeCount: _relationshipController.myInvitations.isNotEmpty
                  ? _relationshipController.myInvitations.length
                  : 0,
              iconBtnClicked: () {
                showSettingDialog();
              })),
          divider(context: context).tP8,
          Expanded(
            child: GetBuilder<RelationshipController>(
                init: _relationshipController,
                builder: (ctx) {
                  return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 5,
                      ),
                      padding: EdgeInsets.zero,
                      itemCount:
                          _relationshipController.relationships.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index !=
                            _relationshipController.relationships.length) {
                          return RelationshipCard(
                            relationship:
                                _relationshipController.relationships[index],
                          ).ripple(() {
                            if (_relationshipController
                                    .relationships[index].userId ==
                                _userProfileManager.user.value!.id) {
                              Get.to(() => const MyProfile(showBack: true))!
                                  .then((value) {
                                loadData();
                              });
                            } else {
                              Get.to(() => OtherUserProfile(
                                      userId: _relationshipController
                                          .relationships[index].userId!))!
                                  .then((value) {
                                loadData();
                              });
                            }
                          });
                        } else {
                          return Card(
                              color: AppColorConstants.cardColor,
                              margin: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const ThemeIconWidget(
                                    ThemeIcon.group,
                                    size: 40,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Heading4Text(
                                    LocalizationString.add,
                                  ),
                                ],
                              )).ripple(() {
                            openBottomSheet();
                          });
                        }
                      }).paddingAll(10);
                }),
          )
        ],
      ),
    );
  }

  openBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
              itemCount: _relationshipController.relationshipNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.account_box),
                  title: Text(
                      _relationshipController.relationshipNames[index].name ??
                          ''),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => SearchProfile(
                        relationId:
                            _relationshipController.relationshipNames[index].id,
                        actionPerformed: () {
                          _relationshipController.getMyRelationships();
                        }));
                  },
                );
              });
        });
  }

  showSettingDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
                height: 225,
                width: MediaQuery.of(context).size.width - 20,
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        child: Text(
                          'Choose who can view your Relationships',
                          style: TextStyle(
                              fontSize: FontSizes.h5,
                              color: AppColorConstants.grayscale100),
                        ),
                      ),
                      ListTile(
                        title: const Text('Nobody'),
                        leading: Radio<RelationsRevealSetting>(
                          value: RelationsRevealSetting.none,
                          groupValue: _profileController
                              .user.value?.relationsRevealSetting,
                          onChanged: (RelationsRevealSetting? value) {
                            _relationshipController.postRelationshipSettings(
                              0,
                            );
                            Get.back();
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(LocalizationString.followers),
                        leading: Radio<RelationsRevealSetting>(
                          value: RelationsRevealSetting.followers,
                          groupValue: _profileController
                              .user.value?.relationsRevealSetting,
                          onChanged: (RelationsRevealSetting? value) {
                            _relationshipController.postRelationshipSettings(
                              2,
                            );
                            Get.back();
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Everyone'),
                        leading: Radio<RelationsRevealSetting>(
                          value: RelationsRevealSetting.all,
                          groupValue: _profileController
                              .user.value?.relationsRevealSetting,
                          onChanged: (RelationsRevealSetting? value) {
                            _relationshipController.postRelationshipSettings(
                              1,
                            );
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ));
          }));
        });
  }
}
