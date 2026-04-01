// To parse this JSON data, do
//
//     final getCountModalClass = getCountModalClassFromJson(jsonString);

import 'dart:convert';

GetCountModalClass getCountModalClassFromJson(String str) =>
    GetCountModalClass.fromJson(json.decode(str));

String getCountModalClassToJson(GetCountModalClass data) =>
    json.encode(data.toJson());

class GetCountModalClass {
  Message message;

  GetCountModalClass({required this.message});

  factory GetCountModalClass.fromJson(Map<String, dynamic> json) =>
      GetCountModalClass(message: Message.fromJson(json["message"]));

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class Message {
  String status;
  String user;
  SystemCounts systemCounts;
  UserCounts userCounts;

  Message({
    required this.status,
    required this.user,
    required this.systemCounts,
    required this.userCounts,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    status: json["status"],
    user: json["user"],
    systemCounts: SystemCounts.fromJson(json["system_counts"]),
    userCounts: UserCounts.fromJson(json["user_counts"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "user": user,
    "system_counts": systemCounts.toJson(),
    "user_counts": userCounts.toJson(),
  };
}

class SystemCounts {
  int totalLeads;
  int totalQuotations;
  int totalCustomers;

  SystemCounts({
    required this.totalLeads,
    required this.totalQuotations,
    required this.totalCustomers,
  });

  factory SystemCounts.fromJson(Map<String, dynamic> json) => SystemCounts(
    totalLeads: json["total_leads"],
    totalQuotations: json["total_quotations"],
    totalCustomers: json["total_customers"],
  );

  Map<String, dynamic> toJson() => {
    "total_leads": totalLeads,
    "total_quotations": totalQuotations,
    "total_customers": totalCustomers,
  };
}

class UserCounts {
  int leadsCreated;
  int quotationsCreated;

  UserCounts({required this.leadsCreated, required this.quotationsCreated});

  factory UserCounts.fromJson(Map<String, dynamic> json) => UserCounts(
    leadsCreated: json["leads_created"],
    quotationsCreated: json["quotations_created"],
  );

  Map<String, dynamic> toJson() => {
    "leads_created": leadsCreated,
    "quotations_created": quotationsCreated,
  };
}
