import '../helper/imports/common_import.dart';

class MediaCard extends StatelessWidget {
  final MediaModel model;

  const MediaCard({super.key, required this.model}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: model.image ?? '',
              fit: BoxFit.cover,
              // height: 110,
            ).round(14),
          ),
          BodySmallText(model.name ?? '', maxLines: 1, weight: TextWeight.semiBold)
              .setPadding(top: 12, bottom: 6),
          BodySmallText(
            model.showTime ?? '',
            weight: TextWeight.regular,
            color: AppColorConstants.themeColor,
          ),
        ],
      ).p(10),
    );
  }
}

class MediaModel {
  String? name;
  String? image;
  String? showTime;

  MediaModel(this.name, this.image, this.showTime);
}
