import 'package:foap/helper/enum.dart';

int postTypeValueFrom(PostType postType) {
  switch (postType) {
    case PostType.basic:
      return 1;
    case PostType.competition:
      return 2;
    case PostType.club:
      return 3;
    case PostType.reel:
      return 4;
  }
}

int postContentTypeValueFrom(PostContentType contentType) {
  switch (contentType) {
    case PostContentType.text:
      return 1;
    case PostContentType.media:
      return 2;
    case PostContentType.location:
      return 3;
  }
}
