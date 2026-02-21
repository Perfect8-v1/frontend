// lib/models/email_models.dart

/// Email request DTO matching backend API: POST /email/send
class EmailRequest {
  final String to;
  final String subject;
  final String template;
  final Map<String, dynamic> variables;

  EmailRequest({
    required this.to,
    required this.subject,
    required this.template,
    this.variables = const {},
  });

  Map<String, dynamic> toJson() => {
        'to': to,
        'subject': subject,
        'template': template,
        'variables': variables,
      };
}

/// Email log entry from GET /email/logs
class EmailLog {
  final int? id;
  final String? to;
  final String? subject;
  final String? template;
  final String? status;
  final DateTime? sentDate;

  EmailLog({
    this.id,
    this.to,
    this.subject,
    this.template,
    this.status,
    this.sentDate,
  });

  factory EmailLog.fromJson(Map<String, dynamic> json) => EmailLog(
        id: json['id'],
        to: json['to'],
        subject: json['subject'],
        template: json['template'],
        status: json['status'],
        sentDate: json['sentDate'] != null
            ? DateTime.parse(json['sentDate'])
            : null,
      );
}

/// Order email DTO matching backend OrderEmailDTO
class OrderEmailDTO {
  // Order details
  final int orderId;
  final String orderNumber;
  final DateTime orderDate;
  final String orderStatus;

  // Customer info
  final int customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;

  // Items
  final List<OrderItemDto> items;

  // Amounts
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double discountAmount;
  final double totalAmount;
  final String currency;

  // Addresses
  final AddressDto? billingAddress;
  final AddressDto? shippingAddress;

  // Payment
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;

  // Store info
  final String storeName;
  final String storeEmail;
  final String? storePhone;
  final String? storeAddress;
  final String? storeWebsite;

  // URLs
  final String? orderViewUrl;
  final String? trackingUrl;
  final String? invoiceUrl;
  final String? returnUrl;

  OrderEmailDTO({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.orderStatus,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    this.taxAmount = 0,
    this.shippingCost = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    this.currency = 'SEK',
    this.billingAddress,
    this.shippingAddress,
    required this.paymentMethod,
    this.paymentStatus = 'PENDING',
    this.transactionId,
    this.storeName = 'Perfect8',
    this.storeEmail = 'info@perfect8.se',
    this.storePhone,
    this.storeAddress,
    this.storeWebsite = 'https://p8.rantila.com',
    this.orderViewUrl,
    this.trackingUrl,
    this.invoiceUrl,
    this.returnUrl,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'orderNumber': orderNumber,
        'orderDate': orderDate.toIso8601String(),
        'orderStatus': orderStatus,
        'customerId': customerId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        if (customerPhone != null) 'customerPhone': customerPhone,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'taxAmount': taxAmount,
        'shippingCost': shippingCost,
        'discountAmount': discountAmount,
        'totalAmount': totalAmount,
        'currency': currency,
        if (billingAddress != null) 'billingAddress': billingAddress!.toJson(),
        if (shippingAddress != null)
          'shippingAddress': shippingAddress!.toJson(),
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        if (transactionId != null) 'transactionId': transactionId,
        'storeName': storeName,
        'storeEmail': storeEmail,
        if (storePhone != null) 'storePhone': storePhone,
        if (storeAddress != null) 'storeAddress': storeAddress,
        if (storeWebsite != null) 'storeWebsite': storeWebsite,
        if (orderViewUrl != null) 'orderViewUrl': orderViewUrl,
        if (trackingUrl != null) 'trackingUrl': trackingUrl,
        if (invoiceUrl != null) 'invoiceUrl': invoiceUrl,
        if (returnUrl != null) 'returnUrl': returnUrl,
      };
}

/// Order item for email DTO
class OrderItemDto {
  final int productId;
  final String productName;
  final String? productSku;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? variantInfo;

  OrderItemDto({
    required this.productId,
    required this.productName,
    this.productSku,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.variantInfo,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        if (productSku != null) 'productSku': productSku,
        if (productImage != null) 'productImage': productImage,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        if (variantInfo != null) 'variantInfo': variantInfo,
      };
}

/// Address for email DTO
class AddressDto {
  final String firstName;
  final String lastName;
  final String street;
  final String city;
  final String postalCode;
  final String country;
  final String? phone;

  AddressDto({
    required this.firstName,
    required this.lastName,
    required this.street,
    required this.city,
    required this.postalCode,
    this.country = 'Sverige',
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'street': street,
        'city': city,
        'postalCode': postalCode,
        'country': country,
        if (phone != null) 'phone': phone,
      };
}
