import 'package:foap/helper/imports/common_import.dart';
import '../../../../../api_handler/apis/event_ticket_api.dart';
import '../../../model/event_model.dart';

/// Lets the organiser of an event see, add and edit its ticket types.
class ManageEventTickets extends StatefulWidget {
  final int eventId;
  final String eventName;

  const ManageEventTickets(
      {super.key, required this.eventId, required this.eventName});

  @override
  State<ManageEventTickets> createState() => _ManageEventTicketsState();
}

class _ManageEventTicketsState extends State<ManageEventTickets> {
  List<EventTicketType> _tickets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _loading = true);
    EventTicketApi.getTickets(
        eventId: widget.eventId,
        resultCallback: (result) {
          if (!mounted) return;
          setState(() {
            _tickets = result;
            _loading = false;
          });
        });
  }

  void _openForm({EventTicketType? ticket}) {
    final nameController = TextEditingController(text: ticket?.name ?? '');
    final priceController = TextEditingController(
        text: ticket == null ? '' : ticket.price.toString());
    final limitController = TextEditingController(
        text: ticket == null ? '' : ticket.limit.toString());

    Get.dialog(AlertDialog(
      backgroundColor: AppColorConstants.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Heading6Text(
          ticket == null ? addTicketsString.tr : editString.tr,
          weight: TextWeight.bold),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                maxLength: 60,
                decoration: InputDecoration(hintText: ticketTypeString.tr)),
            TextField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(hintText: priceString.tr)),
            TextField(
                controller: limitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: limitString.tr)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text(cancelString.tr)),
        TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim());
              final limit = int.tryParse(limitController.text.trim());
              if (name.isEmpty || price == null || price < 0 ||
                  limit == null || limit <= 0) {
                AppUtil.showToast(
                    message: pleaseEnterValidTicketString.tr,
                    isSuccess: false);
                return;
              }
              Get.back();
              EventTicketApi.saveTicket(
                  ticketId: ticket?.id,
                  eventId: widget.eventId,
                  name: name,
                  price: price,
                  limit: limit,
                  resultCallback: (success, message) {
                    if (success) {
                      _load();
                    } else {
                      AppUtil.showToast(
                          message: message ?? '', isSuccess: false);
                    }
                  });
            },
            child: Text(submitString.tr)),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: widget.eventName),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tickets.isEmpty
                    ? Center(
                        child: BodyLargeText(noTicketsYetString.tr,
                            color: AppColorConstants.subHeadingTextColor))
                    : ListView.separated(
                        padding: EdgeInsets.all(
                            DesignConstants.horizontalPadding),
                        itemCount: _tickets.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (ctx, index) => _tile(_tickets[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColorConstants.themeColor,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _tile(EventTicketType ticket) {
    final sold = ticket.limit - ticket.availableTicket;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(18),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.confirmation_number_rounded,
                color: AppColorConstants.themeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(ticket.name,
                    maxLines: 1, weight: TextWeight.semiBold),
                BodySmallText(
                    '${priceString.tr}: ${ticket.price}  ·  ${availableString.tr}: ${ticket.availableTicket}/${ticket.limit}  ·  $sold ${soldString.tr}'),
              ],
            ),
          ),
          Icon(Icons.edit_rounded, color: AppColorConstants.themeColor),
        ],
      ),
    ).ripple(() => _openForm(ticket: ticket));
  }
}
