import 'package:foap/helper/imports/common_import.dart';

import '../../screens/add_on/controller/relationship/relationship_controller.dart';
import '../../screens/add_on/model/my_relations_model.dart';

class RelationshipCard extends StatelessWidget {
  final MyRelationsModel relationship;

  const RelationshipCard({Key? key, required this.relationship})
      : super(key: key);

  String getRelationFromId(int id) {
    final RelationshipController relationshipController =
        RelationshipController();

    List outputList = relationshipController.relationshipNames
        .where((o) => o.id == id)
        .toList();
    return outputList.isNotEmpty ? outputList[0].name : '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColorConstants.cardColor,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarView(
            url: relationship.user?.picture ?? '',
            size: 50,
            name: relationship.user?.userName,
          ),
          Heading6Text(
            relationship.user?.userName ?? '',
            weight: TextWeight.regular,
          ).setPadding(top: 15, bottom: 2),
          if (relationship.relationShipId != 0)
            BodyLargeText(getRelationFromId(relationship.relationShipId ?? 0),
                weight: TextWeight.medium),
          if (relationship.status != 4)
            BodyMediumText(
              requestPendingString.tr,
              weight: TextWeight.semiBold,
              color: AppColorConstants.themeColor,
            ),
        ],
      ).vP16,
    );
  }
}
