import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class LocationChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const LocationChatTile({super.key, required this.message})
      ;

  @override
  Widget build(BuildContext context) {
    return StaticMapWidget(
            latitude: message.mediaContent.location!.latitude,
            longitude: message.mediaContent.location!.longitude,
            apiKey: AppConfigConstants.googleMapApiKey)
        .round(10);
  }
}
