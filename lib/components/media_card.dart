import '../helper/imports/common_import.dart';

class MediaCard extends StatelessWidget {
  final MediaModel model;

  const MediaCard({super.key, required this.model}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: model.image ?? '',
              fit: BoxFit.cover,
              // height: 110,
            ).round(12),
          ),
          BodySmallText(model.name ?? '', weight: TextWeight.regular)
              .setPadding(top: 12, bottom: 6),
          BodySmallText(
            model.showTime ?? '',
            weight: TextWeight.regular,
            color: AppColorConstants.themeColor,
          ),
        ],
      ).p(12),
    ).round(15);
  }
}

class MediaModel {
  String? name;
  String? image;
  String? showTime;

  MediaModel(this.name, this.image, this.showTime);
}
