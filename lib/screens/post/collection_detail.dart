import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/post/collection_controller.dart';
import '../../model/collection_model.dart';
import 'single_post_detail.dart';

class CollectionDetail extends StatelessWidget {
  final int collectionId;

  const CollectionDetail({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    final CollectionController controller = Get.find();

    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Obx(() {
        final matches =
            controller.collections.where((e) => e.id == collectionId);
        if (matches.isEmpty) {
          return Column(children: [
            backNavigationBar(title: collectionsString.tr),
            const Expanded(child: SizedBox())
          ]);
        }
        final collection = matches.first;

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: backNavigationBar(title: collection.name)),
                Padding(
                  padding: EdgeInsets.only(
                      right: DesignConstants.horizontalPadding, top: 40),
                  child: Icon(Icons.delete_outline_rounded,
                          color: AppColorConstants.red)
                      .ripple(() {
                    AppUtil.showNewConfirmationAlert(
                      title: deleteCollectionString.tr,
                      subTitle: areYouSureDeleteCollectionString.tr,
                      okHandler: () {
                        controller.deleteCollection(collection);
                        Get.back();
                      },
                      cancelHandler: () {},
                    );
                  }),
                ),
              ],
            ),
            Expanded(
              child: collection.items.isEmpty
                  ? Center(
                      child: BodyLargeText(noCollectionPostsString.tr,
                          color: AppColorConstants.subHeadingTextColor))
                  : GridView.builder(
                      padding: EdgeInsets.all(DesignConstants.horizontalPadding),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6),
                      itemCount: collection.items.length,
                      itemBuilder: (ctx, index) =>
                          _tappable(controller, collection, collection.items[index]),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _itemTile(CollectionModel collection, CollectionItemModel item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        item.thumbnail.isEmpty
            ? Container(
                color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                child: Icon(Icons.image_rounded,
                    color: AppColorConstants.themeColor))
            : CachedNetworkImage(imageUrl: item.thumbnail, fit: BoxFit.cover),
        if (item.isVideo)
          const Positioned(
              right: 6,
              top: 6,
              child: Icon(Icons.play_circle_fill_rounded,
                  size: 20, color: Colors.white)),
      ],
    ).round(12);
  }

  Widget _tappable(CollectionController controller, CollectionModel collection,
      CollectionItemModel item) {
    return GestureDetector(
      onTap: () => Get.to(() => SinglePostDetail(postId: item.postId)),
      onLongPress: () {
        AppUtil.showNewConfirmationAlert(
          title: removeFromCollectionString.tr,
          subTitle: areYouSureRemoveFromCollectionString.tr,
          okHandler: () =>
              controller.removePostFromCollection(collection, item),
          cancelHandler: () {},
        );
      },
      child: _itemTile(collection, item),
    );
  }
}
