// To parse this JSON data, do
//
//     final getCustomerModalClass = getCustomerModalClassFromJson(jsonString);

import 'dart:convert';

GetCustomerModalClass getCustomerModalClassFromJson(String str) =>
    GetCustomerModalClass.fromJson(json.decode(str));

String getCustomerModalClassToJson(GetCustomerModalClass data) =>
    json.encode(data.toJson());

class GetCustomerModalClass {
  List<CustomerMessage> message;

  GetCustomerModalClass({required this.message});

  factory GetCustomerModalClass.fromJson(Map<String, dynamic> json) =>
      GetCustomerModalClass(
        message: List<CustomerMessage>.from(
          json["message"].map((x) => CustomerMessage.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": List<dynamic>.from(message.map((x) => x.toJson())),
  };
}

class CustomerMessage {
  String name;
  String customerName;
  String customerType;
  String? customerGroup;
  String? territory;
  String? mobileNo;
  String? emailId;
  String? defaultCurrency;
  DateTime creation;
  DateTime modified;
  String owner;

  CustomerMessage({
    required this.name,
    required this.customerName,
    required this.customerType,
    required this.customerGroup,
    required this.territory,
    required this.mobileNo,
    required this.emailId,
    required this.defaultCurrency,
    required this.creation,
    required this.modified,
    required this.owner,
  });

  factory CustomerMessage.fromJson(Map<String, dynamic> json) =>
      CustomerMessage(
        name: json["name"],
        customerName: json["customer_name"],
        customerType: json["customer_type"],
        customerGroup: json["customer_group"],
        territory: json["territory"],
        mobileNo: json["mobile_no"],
        emailId: json["email_id"],
        defaultCurrency: json["default_currency"],
        creation: DateTime.parse(json["creation"]),
        modified: DateTime.parse(json["modified"]),
        owner: json["owner"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "customer_name": customerName,
    "customer_type": customerType,
    "customer_group": customerGroup,
    "territory": territory,
    "mobile_no": mobileNo,
    "email_id": emailId,
    "default_currency": defaultCurrency,
    "creation": creation.toIso8601String(),
    "modified": modified.toIso8601String(),
    "owner": owner,
  };
}
