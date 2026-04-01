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
        message: json["message"] == null
            ? []
            : List<Message>.from(
                json["message"].map((x) => Message.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "message": List<dynamic>.from(message.map((x) => x.toJson())),
  };
}

class Message {
  Quotation quotation;
  List<Item> items;
  List<Tax> taxes;
  List<PaymentSchedule> paymentSchedule;

  Message({
    required this.quotation,
    required this.items,
    required this.taxes,
    required this.paymentSchedule,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    quotation: Quotation.fromJson(json["quotation"] ?? {}),
    items: json["items"] == null
        ? []
        : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    taxes: json["taxes"] == null
        ? []
        : List<Tax>.from(json["taxes"].map((x) => Tax.fromJson(x))),
    paymentSchedule: json["payment_schedule"] == null
        ? []
        : List<PaymentSchedule>.from(
            json["payment_schedule"].map((x) => PaymentSchedule.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "quotation": quotation.toJson(),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "taxes": List<dynamic>.from(taxes.map((x) => x.toJson())),
    "payment_schedule": List<dynamic>.from(
      paymentSchedule.map((x) => x.toJson()),
    ),
  };
}

class Quotation {
  String name;
  String status;
  String? amendedFrom;
  String quotationTo;
  String partyName;
  String customerName;
  String? contactPerson;
  String? contactDisplay;
  String? contactMobile;
  String? contactEmail;
  String? customerAddress;
  String? addressDisplay;
  String? shippingAddressName;
  String? shippingAddress;
  DateTime transactionDate;
  DateTime? validTill;
  DateTime? creation;
  DateTime? modified;
  String owner;
  String currency;
  String sellingPriceList;
  String priceListCurrency;
  double plcConversionRate;
  double conversionRate;
  double totalQty;
  double baseTotal;
  double baseNetTotal;
  double netTotal;
  double total;
  double baseGrandTotal;
  double grandTotal;
  double roundingAdjustment;
  double roundedTotal;
  String inWords;
  double totalTaxesAndCharges;
  double discountAmount;
  double additionalDiscountPercentage;
  String? paymentTermsTemplate;
  String? tcName;
  String? terms;
  String orderType;
  String company;
  String? campaign;
  String? source;

  Quotation({
    required this.name,
    required this.status,
    this.amendedFrom,
    required this.quotationTo,
    required this.partyName,
    required this.customerName,
    this.contactPerson,
    this.contactDisplay,
    this.contactMobile,
    this.contactEmail,
    this.customerAddress,
    this.addressDisplay,
    this.shippingAddressName,
    this.shippingAddress,
    required this.transactionDate,
    this.validTill,
    this.creation,
    this.modified,
    required this.owner,
    required this.currency,
    required this.sellingPriceList,
    required this.priceListCurrency,
    required this.plcConversionRate,
    required this.conversionRate,
    required this.totalQty,
    required this.baseTotal,
    required this.baseNetTotal,
    required this.netTotal,
    required this.total,
    required this.baseGrandTotal,
    required this.grandTotal,
    required this.roundingAdjustment,
    required this.roundedTotal,
    required this.inWords,
    required this.totalTaxesAndCharges,
    required this.discountAmount,
    required this.additionalDiscountPercentage,
    this.paymentTermsTemplate,
    this.tcName,
    this.terms,
    required this.orderType,
    required this.company,
    this.campaign,
    this.source,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
    name: json["name"] ?? '',
    status: json["status"] ?? '',
    amendedFrom: json["amended_from"],
    quotationTo: json["quotation_to"] ?? '',
    partyName: json["party_name"] ?? '',
    customerName: json["customer_name"] ?? '',
    contactPerson: json["contact_person"],
    contactDisplay: json["contact_display"],
    contactMobile: json["contact_mobile"],
    contactEmail: json["contact_email"],
    customerAddress: json["customer_address"],
    addressDisplay: json["address_display"],
    shippingAddressName: json["shipping_address_name"],
    shippingAddress: json["shipping_address"],
    transactionDate: json["transaction_date"] != null
        ? DateTime.parse(json["transaction_date"])
        : DateTime.now(),
    validTill: json["valid_till"] != null
        ? DateTime.parse(json["valid_till"])
        : null,
    creation: json["creation"] != null
        ? DateTime.parse(json["creation"])
        : null,
    modified: json["modified"] != null
        ? DateTime.parse(json["modified"])
        : null,
    owner: json["owner"] ?? '',
    currency: json["currency"] ?? '',
    sellingPriceList: json["selling_price_list"] ?? '',
    priceListCurrency: json["price_list_currency"] ?? '',
    plcConversionRate: (json["plc_conversion_rate"] as num?)?.toDouble() ?? 0.0,
    conversionRate: (json["conversion_rate"] as num?)?.toDouble() ?? 0.0,
    totalQty: (json["total_qty"] as num?)?.toDouble() ?? 0.0,
    baseTotal: (json["base_total"] as num?)?.toDouble() ?? 0.0,
    baseNetTotal: (json["base_net_total"] as num?)?.toDouble() ?? 0.0,
    netTotal: (json["net_total"] as num?)?.toDouble() ?? 0.0,
    total: (json["total"] as num?)?.toDouble() ?? 0.0,
    baseGrandTotal: (json["base_grand_total"] as num?)?.toDouble() ?? 0.0,
    grandTotal: (json["grand_total"] as num?)?.toDouble() ?? 0.0,
    roundingAdjustment:
        (json["rounding_adjustment"] as num?)?.toDouble() ?? 0.0,
    roundedTotal: (json["rounded_total"] as num?)?.toDouble() ?? 0.0,
    inWords: json["in_words"] ?? '',
    totalTaxesAndCharges:
        (json["total_taxes_and_charges"] as num?)?.toDouble() ?? 0.0,
    discountAmount: (json["discount_amount"] as num?)?.toDouble() ?? 0.0,
    additionalDiscountPercentage:
        (json["additional_discount_percentage"] as num?)?.toDouble() ?? 0.0,
    paymentTermsTemplate: json["payment_terms_template"],
    tcName: json["tc_name"],
    terms: json["terms"],
    orderType: json["order_type"] ?? '',
    company: json["company"] ?? '',
    campaign: json["campaign"],
    source: json["source"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "status": status,
    "amended_from": amendedFrom,
    "quotation_to": quotationTo,
    "party_name": partyName,
    "customer_name": customerName,
    "contact_person": contactPerson,
    "contact_display": contactDisplay,
    "contact_mobile": contactMobile,
    "contact_email": contactEmail,
    "customer_address": customerAddress,
    "address_display": addressDisplay,
    "shipping_address_name": shippingAddressName,
    "shipping_address": shippingAddress,
    "transaction_date":
        "${transactionDate.year.toString().padLeft(4, '0')}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}",
    "valid_till": validTill?.toIso8601String(),
    "creation": creation?.toIso8601String(),
    "modified": modified?.toIso8601String(),
    "owner": owner,
    "currency": currency,
    "selling_price_list": sellingPriceList,
    "price_list_currency": priceListCurrency,
    "plc_conversion_rate": plcConversionRate,
    "conversion_rate": conversionRate,
    "total_qty": totalQty,
    "base_total": baseTotal,
    "base_net_total": baseNetTotal,
    "net_total": netTotal,
    "total": total,
    "base_grand_total": baseGrandTotal,
    "grand_total": grandTotal,
    "rounding_adjustment": roundingAdjustment,
    "rounded_total": roundedTotal,
    "in_words": inWords,
    "total_taxes_and_charges": totalTaxesAndCharges,
    "discount_amount": discountAmount,
    "additional_discount_percentage": additionalDiscountPercentage,
    "payment_terms_template": paymentTermsTemplate,
    "tc_name": tcName,
    "terms": terms,
    "order_type": orderType,
    "company": company,
    "campaign": campaign,
    "source": source,
  };
}

class Item {
  String itemCode;
  String itemName;
  String description;
  double qty;
  String uom;
  double rate;
  double discountPercentage;
  double discountAmount;
  double priceListRate;
  double netRate;
  double netAmount;
  double amount;
  String warehouse;
  String itemGroup;

  Item({
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.qty,
    required this.uom,
    required this.rate,
    required this.discountPercentage,
    required this.discountAmount,
    required this.priceListRate,
    required this.netRate,
    required this.netAmount,
    required this.amount,
    required this.warehouse,
    required this.itemGroup,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemCode: json["item_code"] ?? '',
    itemName: json["item_name"] ?? '',
    description: json["description"] ?? '',
    qty: (json["qty"] as num?)?.toDouble() ?? 0.0,
    uom: json["uom"] ?? '',
    rate: (json["rate"] as num?)?.toDouble() ?? 0.0,
    discountPercentage:
        (json["discount_percentage"] as num?)?.toDouble() ?? 0.0,
    discountAmount: (json["discount_amount"] as num?)?.toDouble() ?? 0.0,
    priceListRate: (json["price_list_rate"] as num?)?.toDouble() ?? 0.0,
    netRate: (json["net_rate"] as num?)?.toDouble() ?? 0.0,
    netAmount: (json["net_amount"] as num?)?.toDouble() ?? 0.0,
    amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
    warehouse: json["warehouse"] ?? '',
    itemGroup: json["item_group"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "item_code": itemCode,
    "item_name": itemName,
    "description": description,
    "qty": qty,
    "uom": uom,
    "rate": rate,
    "discount_percentage": discountPercentage,
    "discount_amount": discountAmount,
    "price_list_rate": priceListRate,
    "net_rate": netRate,
    "net_amount": netAmount,
    "amount": amount,
    "warehouse": warehouse,
    "item_group": itemGroup,
  };
}

class Tax {
  Tax();

  factory Tax.fromJson(Map<String, dynamic> json) => Tax();

  Map<String, dynamic> toJson() => {};
}

class PaymentSchedule {
  String? paymentTerm;
  DateTime dueDate;
  double invoicePortion;
  double paymentAmount;

  PaymentSchedule({
    this.paymentTerm,
    required this.dueDate,
    required this.invoicePortion,
    required this.paymentAmount,
  });

  factory PaymentSchedule.fromJson(Map<String, dynamic> json) =>
      PaymentSchedule(
        paymentTerm: json["payment_term"],
        dueDate: json["due_date"] != null
            ? DateTime.parse(json["due_date"])
            : DateTime.now(),
        invoicePortion: (json["invoice_portion"] as num?)?.toDouble() ?? 0.0,
        paymentAmount: (json["payment_amount"] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
    "payment_term": paymentTerm,
    "due_date":
        "${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}",
    "invoice_portion": invoicePortion,
    "payment_amount": paymentAmount,
  };
}
