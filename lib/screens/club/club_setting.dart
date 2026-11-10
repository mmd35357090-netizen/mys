import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../universal_components/menu_tiles.dart';

class ClubSettings extends StatefulWidget {
  final ClubModel club;
  final Function(ClubModel) deleteClubCallback;

  // final Function(ClubModel) updateClubCallback;
  const ClubSettings({
    super.key,
    required this.club,
    required this.deleteClubCallback,
    // required this.updateClubCallback
  }) ;

  @override
  State<ClubSettings> createState() => _ClubSettingsState();
}

class _ClubSettingsState extends State<ClubSettings> {
  final ClubsController _clubsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: clubSettingsString.tr),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                MenuSection(tiles: [
                  MenuRow(
                    icon: Icons.edit_outlined,
                    color: const Color(0xFF6366F1),
                    title: editClubInfoString.tr,
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppColorConstants.subHeadingTextColor),
                    onTap: () {
                      Get.to(() => CreateClub(
                            club: widget.club,
                          ));
                    },
                  ),
                  MenuRow(
                    icon: Icons.image_outlined,
                    color: const Color(0xFF0EA5E9),
                    title: editClubImageString.tr,
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppColorConstants.subHeadingTextColor),
                    onTap: () {
                      Get.to(() => ChooseClubCoverPhoto(
                            club: widget.club,
                          ));
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                MenuSection(tiles: [
                  MenuRow(
                    icon: Icons.delete_outline_rounded,
                    color: AppColorConstants.red,
                    title: deleteClubString.tr,
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppColorConstants.subHeadingTextColor),
                    onTap: () {
                      AppUtil.showNewConfirmationAlert(
                        title: deleteClubString.tr,
                        subTitle: areYouSureToDeleteClubString.tr,
                        okHandler: () {
                          _clubsController.deleteClub(
                              club: widget.club,
                              callback: () {
                                widget.deleteClubCallback(widget.club);
                              });
                        },
                        cancelHandler: () {
                          Get.back();
                        },
                      );
                    },
                  ),
                ]),
              ],
            ).hp(DesignConstants.horizontalPadding),
          )
        ],
      ),
    );
  }
}
