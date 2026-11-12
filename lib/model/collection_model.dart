class CollectionItemModel {
  int id = 0; // collection_user row id (needed to remove)
  int postId = 0;
  String thumbnail = '';
  bool isVideo = false;

  CollectionItemModel();

  factory CollectionItemModel.fromJson(dynamic json) {
    CollectionItemModel model = CollectionItemModel();
    model.id = json['id'] ?? 0;
    model.postId = json['post_id'] ?? 0;

    var post = json['post'];
    if (post != null && post['postGallary'] != null) {
      List gallery = post['postGallary'] as List;
      if (gallery.isNotEmpty) {
        var first = gallery.first;
        model.isVideo = first['media_type'] == 2;
        model.thumbnail = (first['videoThumbUrl'] ?? first['filenameUrl'] ?? '')
            .toString();
      }
    }
    return model;
  }
}

class CollectionModel {
  int id = 0;
  String name = '';
  String image = '';
  List<CollectionItemModel> items = [];

  CollectionModel();

  factory CollectionModel.fromJson(dynamic json) {
    CollectionModel model = CollectionModel();
    model.id = json['id'] ?? 0;
    model.name = (json['name'] ?? '').toString();
    model.image = (json['imageUrl'] ?? '').toString();
    var items = json['collectionUser'];
    if (items is List) {
      model.items = items.map((x) => CollectionItemModel.fromJson(x)).toList();
    }
    return model;
  }

  /// First available post thumbnail, used as the cover of the collection.
  String get coverImage {
    if (image.isNotEmpty) return image;
    for (final item in items) {
      if (item.thumbnail.isNotEmpty) return item.thumbnail;
    }
    return '';
  }
}
