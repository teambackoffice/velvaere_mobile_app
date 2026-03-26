import 'dart:convert';

GetQuotationModalClass getQuotationModalClassFromJson(String str) =>
    GetQuotationModalClass.fromJson(json.decode(str));

String getQuotationModalClassToJson(GetQuotationModalClass data) =>
    json.encode(data.toJson());

class GetQuotationModalClass {
  List<Message> message;

  GetQuotationModalClass({required this.message});

  factory GetQuotationModalClass.fromJson(Map<String, dynamic> json) =>
      GetQuotationModalClass(
        message: List<Message>.from(
          json["message"].map((x) => Message.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": List<dynamic>.from(message.map((x) => x.toJson())),
  };
}

class Message {
  Quotation quotation;

  Message({required this.quotation});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    quotation: Quotation.fromJson(json["quotation"] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => quotation.toJson();
}

class Quotation {
  String name;
  String status;
  String customerName;
  DateTime transactionDate;
  // ✅ Use (value as num).toDouble() to safely handle both int and double
  // values that the API may return for numeric fields.
  double grandTotal;

  Quotation({
    required this.name,
    required this.status,
    required this.customerName,
    required this.transactionDate,
    required this.grandTotal,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
    name: json["name"] ?? '',
    status: json["status"] ?? '',
    customerName: json["customer_name"] ?? '',
    transactionDate: json["transaction_date"] != null
        ? DateTime.parse(json["transaction_date"])
        : DateTime.now(),
    // KEY FIX: cast to `num` first, then call .toDouble()
    // This handles both int (e.g. 45200) and double (e.g. 45200.0)
    // values from the JSON without a type error.
    grandTotal: (json["grand_total"] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "status": status,
    "customer_name": customerName,
    "transaction_date":
        "${transactionDate.year.toString().padLeft(4, '0')}-"
        "${transactionDate.month.toString().padLeft(2, '0')}-"
        "${transactionDate.day.toString().padLeft(2, '0')}",
    "grand_total": grandTotal,
  };
}
