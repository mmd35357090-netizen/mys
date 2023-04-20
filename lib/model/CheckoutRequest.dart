class CheckoutRequest {
  List<Items>? items;
  Payer? payer;

  CheckoutRequest({this.items, this.payer});

  CheckoutRequest.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    payer = json['payer'] != null ? new Payer.fromJson(json['payer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.payer != null) {
      data['payer'] = this.payer!.toJson();
    }
    return data;
  }
}

class Items {
  String? title;
  String? description;
  int? quantity;
  String? currencyId;
  int? unitPrice;

  Items(
      {this.title,
        this.description,
        this.quantity,
        this.currencyId,
        this.unitPrice});

  Items.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    quantity = json['quantity'];
    currencyId = json['currency_id'];
    unitPrice = json['unit_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['currency_id'] = this.currencyId;
    data['unit_price'] = this.unitPrice;
    return data;
  }
}

class Payer {
  String? email;

  Payer({this.email});

  Payer.fromJson(Map<String, dynamic> json) {
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    return data;
  }
}


// {
//         "items": [
//             {
//             "title": "Dummy Item",
//             "description": "Multicolor Item",
//             "quantity": 1,
//             "currency_id": "ARS",
//             "unit_price": 10.0
//             }
//         ],
//         "payer": {
//             "email": "payer@email.com"
//         }
//   }