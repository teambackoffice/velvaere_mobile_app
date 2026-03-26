// To parse this JSON data, do
//
//     final getItemsModalClass = getItemsModalClassFromJson(jsonString);

import 'dart:convert';

GetItemsModalClass getItemsModalClassFromJson(String str) =>
    GetItemsModalClass.fromJson(json.decode(str));

String getItemsModalClassToJson(GetItemsModalClass data) =>
    json.encode(data.toJson());

class GetItemsModalClass {
  List<Message> message;

  GetItemsModalClass({required this.message});

  factory GetItemsModalClass.fromJson(Map<String, dynamic> json) =>
      GetItemsModalClass(
        message: List<Message>.from(
          json["message"].map((x) => Message.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": List<dynamic>.from(message.map((x) => x.toJson())),
  };
}

class Message {
  String itemCode;
  String itemName;
  String itemGroup;
  String description;
  String uom;
  dynamic image;
  String priceList;
  double priceListRate;
  String currency;

  Message({
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    required this.description,
    required this.uom,
    required this.image,
    required this.priceList,
    required this.priceListRate,
    required this.currency,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    itemCode: json["item_code"],
    itemName: json["item_name"],
    itemGroup: json["item_group"],
    description: json["description"],
    uom: json["uom"],
    image: json["image"],
    priceList: json["price_list"],
    priceListRate: json["price_list_rate"],
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "item_code": itemCode,
    "item_name": itemName,
    "item_group": itemGroup,
    "description": description,
    "uom": uom,
    "image": image,
    "price_list": priceList,
    "price_list_rate": priceListRate,
    "currency": currency,
  };
}
