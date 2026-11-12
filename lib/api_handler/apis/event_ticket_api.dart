import 'package:foap/api_handler/api_wrapper.dart';
import '../../screens/add_on/model/event_model.dart';

class EventTicketApi {
  /// Loads every ticket type of an event (including sold out ones).
  static getTickets(
      {required int eventId,
      required Function(List<EventTicketType>) resultCallback}) async {
    var url = NetworkConstantsUtil.eventDetails
        .replaceAll('{{id}}', eventId.toString());

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['event']['eventTicket'];
        if (items is List) {
          resultCallback(items
              .map((e) => EventTicketType.fromJson(e as Map<String, dynamic>))
              .toList());
        } else {
          resultCallback([]);
        }
      }
    });
  }

  static saveTicket(
      {int? ticketId,
      required int eventId,
      required String name,
      required double price,
      required int limit,
      required Function(bool, String?) resultCallback}) async {
    final url = ticketId == null
        ? NetworkConstantsUtil.createEventTicket
        : NetworkConstantsUtil.updateEventTicket;

    final param = {
      if (ticketId != null) "id": ticketId.toString(),
      "event_id": eventId.toString(),
      "ticket_type": name,
      "price": price.toString(),
      "limit": limit.toString(),
    };

    await ApiWrapper().postApi(url: url, param: param).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }
}
