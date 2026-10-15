
class SenderDetail {
  String? name;
  String? username;
  String? email;
  String? image;
  int? id;

  int? isReported;
  String? picture;
  String? coverImageUrl;

  String? profileCategoryName;
  int? isLike;

  SenderDetail(
      {name,
        username,
        email,
        image,
        id,
        isReported,
        picture,
        coverImageUrl,
        profileCategoryName,
        isLike});

  SenderDetail.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    username = json['username'];
    email = json['email'];
    image = json['image'];
    id = json['id'];
    isReported = json['is_reported'];
    picture = json['picture'];
    coverImageUrl = json['coverImageUrl'];
    profileCategoryName = json['profileCategoryName'];
    isLike = json['is_like'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['username'] = username;
    data['email'] = email;
    data['image'] = image;
    data['id'] = id;
    data['is_reported'] = isReported;
    data['picture'] = picture;
    data['coverImageUrl'] = coverImageUrl;
    data['profileCategoryName'] = profileCategoryName;
    data['is_like'] = isLike;
    return data;
  }
}

class Links {
  Self? self;
  Self? first;
  Self? last;

  Links({self, first, last});

  Links.fromJson(Map<String, dynamic> json) {
    self = json['self'] != null ? Self.fromJson(json['self']) : null;
    first = json['first'] != null ? Self.fromJson(json['first']) : null;
    last = json['last'] != null ? Self.fromJson(json['last']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (self != null) {
      data['self'] = self!.toJson();
    }
    if (first != null) {
      data['first'] = first!.toJson();
    }
    if (last != null) {
      data['last'] = last!.toJson();
    }
    return data;
  }
}

class Self {
  String? href;

  Self({href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['href'] = href;
    return data;
  }
}

class Meta {
  int? totalCount;
  int? pageCount;
  int? currentPage;
  int? perPage;

  Meta({totalCount, pageCount, currentPage, perPage});

  Meta.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    pageCount = json['pageCount'];
    currentPage = json['currentPage'];
    perPage = json['perPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCount'] = totalCount;
    data['pageCount'] = pageCount;
    data['currentPage'] = currentPage;
    data['perPage'] = perPage;
    return data;
  }
}
