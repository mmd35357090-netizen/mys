import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/post/collection_controller.dart';
import '../../model/collection_model.dart';
import 'collection_detail.dart';

CollectionController _ensureCollectionController() {
  if (Get.isRegistered<CollectionController>()) {
    return Get.find<CollectionController>();
  }
  return Get.put(CollectionController());
}

void showCreateCollectionDialog({Function(bool)? completion}) {
  final CollectionController controller = _ensureCollectionController();
  final TextEditingController nameController = TextEditingController();
  Get.dialog(AlertDialog(
    backgroundColor: AppColorConstants.cardColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Heading6Text(newCollectionString.tr, weight: TextWeight.bold),
    content: TextField(
      controller: nameController,
      autofocus: true,
      maxLength: 100,
      decoration: InputDecoration(hintText: collectionNameString.tr),
    ),
    actions: [
      TextButton(onPressed: () => Get.back(), child: Text(cancelString.tr)),
      TextButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            Get.back();
            controller.createCollection(name, completion: completion);
          },
          child: Text(createString.tr)),
    ],
  ));
}

/// Bottom sheet that lets the user pick the collection a post is added to.
void showAddToCollectionSheet(int postId) {
  final CollectionController controller = _ensureCollectionController();
  controller.loadCollections();

  Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        color: AppColorConstants.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Heading6Text(addToCollectionString.tr, weight: TextWeight.bold),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.add_circle_rounded,
                  color: AppColorConstants.themeColor),
              title: BodyLargeText(newCollectionString.tr,
                  weight: TextWeight.semiBold),
              onTap: () {
                Get.back();
                showCreateCollectionDialog();
              },
            ),
            Flexible(
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.collections.length,
                    itemBuilder: (ctx, index) {
                      final collection = controller.collections[index];
                      return ListTile(
                        leading: Icon(Icons.folder_rounded,
                            color: AppColorConstants.themeColor),
                        title: BodyLargeText(collection.name),
                        trailing: BodySmallText('${collection.items.length}'),
                        onTap: () {
                          Get.back();
                          controller.addPostToCollection(collection, postId);
                        },
                      );
                    },
                  )),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ).topRounded(28),
      isScrollControlled: true);
}

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  late final CollectionController _controller = _ensureCollectionController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: collectionsString.tr),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value &&
                  _controller.collections.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.collections.isEmpty) {
                return Center(
                    child: BodyLargeText(noCollectionString.tr,
                        color: AppColorConstants.subHeadingTextColor));
              }
              return GridView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: DesignConstants.horizontalPadding,
                    vertical: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95),
                itemCount: _controller.collections.length,
                itemBuilder: (ctx, index) =>
                    _collectionTile(_controller.collections[index]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColorConstants.themeColor,
        onPressed: () => showCreateCollectionDialog(),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _collectionTile(CollectionModel collection) {
    final cover = collection.coverImage;
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
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: cover.isEmpty
                  ? Container(
                      color:
                          AppColorConstants.themeColor.withValues(alpha: 0.12),
                      child: Icon(Icons.folder_rounded,
                          size: 44, color: AppColorConstants.themeColor))
                  : CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(collection.name,
                    maxLines: 1, weight: TextWeight.semiBold),
                BodySmallText('${collection.items.length} ${postsString.tr}'),
              ],
            ),
          ),
        ],
      ).round(20),
    ).ripple(() {
      Get.to(() => CollectionDetail(collectionId: collection.id));
    });
  }
}
