import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/relationship/relationship_controller.dart';
import 'package:get/get.dart';

class AcceptRejectInvitation extends StatefulWidget {
  const AcceptRejectInvitation({Key? key}) : super(key: key);

  @override
  State<AcceptRejectInvitation> createState() => _AcceptRejectInvitationState();
}

class _AcceptRejectInvitationState extends State<AcceptRejectInvitation> {
  final RelationshipController _relationshipController =
      RelationshipController();

  @override
  void initState() {
    super.initState();
    _relationshipController.getMyInvitations();
  }

  String getRelationFromId(int id) {
    List outputList = _relationshipController.relationshipNames
        .where((o) => o.id == id)
        .toList();
    return outputList.isNotEmpty ? outputList[0].name : '';
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
          backNavigationBar(
              context: context, title: LocalizationString.invites),
          divider(context: context).vP16,
          Expanded(
            child: GetBuilder<RelationshipController>(
                init: _relationshipController,
                builder: (ctx) {
                  return _relationshipController.myInvitations.isNotEmpty
                      ? ListView.separated(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          itemCount:
                              _relationshipController.myInvitations.length,
                          itemBuilder: (context, index) {
                            return getRow(index);
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 20,
                            );
                          })
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.height * 0.5,
                          child: emptyUser(
                              title: LocalizationString.noInvitationRequest,
                              subTitle: ''),
                        );
                }),
          )
        ],
      ),
    );
  }

  Widget getRow(int i) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              AvatarView(
                url: _relationshipController
                        .myInvitations[i].createdByObj?.picture ??
                    '',
                // size: 60,
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _relationshipController
                            .myInvitations[i].createdByObj?.userName ??
                        '',
                    style: TextStyle(
                        fontSize: FontSizes.h6,
                        fontWeight: TextWeight.semiBold,
                        color: AppColorConstants.grayscale100),
                  ),
                  Text(
                    "${LocalizationString.claimsToBe} ${_relationshipController.myInvitations[i].relationShip?.name}",
                    style: TextStyle(
                        fontSize: FontSizes.h6,
                        fontWeight: TextWeight.regular,
                        color: AppColorConstants.grayscale100),
                  )
                ],
              )
            ],
          ).setPadding(bottom: 10),
          Row(children: [
            Expanded(
                flex: 1, // you can play with this value, by default it is 1
                child: AppThemeBorderButton(
                    text: LocalizationString.approve,
                    height: 40,
                    textStyle: TextStyle(
                        fontSize: FontSizes.b2,
                        fontWeight: TextWeight.medium,
                        color: AppColorConstants.themeColor),
                    onPress: () {
                      _relationshipController.acceptRejectInvitation(
                          _relationshipController.myInvitations[i].id ?? 0, 4,
                          () {
                        _relationshipController.getMyInvitations();
                      });
                    })),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1, // you can play with this value, by default it is 1
              child: AppThemeButton(
                  height: 40,

                  text: LocalizationString.reject,
                  onPress: () {
                    _relationshipController.acceptRejectInvitation(
                        _relationshipController.myInvitations[i].id ?? 0, 3,
                        () {
                      _relationshipController.getMyInvitations();
                    });
                  }),
            ),
          ])
        ],
      ).p16,
    ).round(20);
  }
}
