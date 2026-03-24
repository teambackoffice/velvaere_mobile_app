// To parse this JSON data, do
//
//     final getLeadModalClass = getLeadModalClassFromJson(jsonString);

import 'dart:convert';

GetLeadModalClass getLeadModalClassFromJson(String str) =>
    GetLeadModalClass.fromJson(json.decode(str));

String getLeadModalClassToJson(GetLeadModalClass data) =>
    json.encode(data.toJson());

class GetLeadModalClass {
  List<Message> message;

  GetLeadModalClass({required this.message});

  factory GetLeadModalClass.fromJson(Map<String, dynamic> json) =>
      GetLeadModalClass(
        message: List<Message>.from(
          json["message"].map((x) => Message.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": List<dynamic>.from(message.map((x) => x.toJson())),
  };
}

class Message {
  String name;
  String leadName;
  String mobileNo;
  String emailId;
  String source;
  String status;
  DateTime creation;
  DateTime modified;
  String leadOwner;

  Message({
    required this.name,
    required this.leadName,
    required this.mobileNo,
    required this.emailId,
    required this.source,
    required this.status,
    required this.creation,
    required this.modified,
    required this.leadOwner,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    name: json["name"],
    leadName: json["lead_name"],
    mobileNo: json["mobile_no"],
    emailId: json["email_id"],
    source: json["source"],
    status: json["status"],
    creation: DateTime.parse(json["creation"]),
    modified: DateTime.parse(json["modified"]),
    leadOwner: json["lead_owner"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lead_name": leadName,
    "mobile_no": mobileNo,
    "email_id": emailId,
    "source": source,
    "status": status,
    "creation": creation.toIso8601String(),
    "modified": modified.toIso8601String(),
    "lead_owner": leadOwner,
  };
}
