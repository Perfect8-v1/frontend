// lib/models/order_models.dart

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}

class Order {
  final int orderId;
  final String orderNumber;
  final int customerId;
  final String customerName;
  final String customerEmail;
  final OrderStatus status;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String currency;
  final Address shippingAddress;
  final Address billingAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String? trackingNumber;
  final String? trackingUrl;
  final String? notes;
  final DateTime createdDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;

  Order({
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    this.customerName = '',
    this.customerEmail = '',
    required this.status,
    this.items = const [],
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.currency = 'SEK',
    required this.shippingAddress,
    required this.billingAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    this.trackingNumber,
    this.trackingUrl,
    this.notes,
    required this.createdDate,
    this.shippedDate,
    this.deliveredDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Backend returns orderItems (not items)
    final itemsList = json['orderItems'] ?? json['items'] ?? [];
    final parsedItems = (itemsList as List<dynamic>)
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();

    // Backend returns flat shipping fields, not an object
    final shippingAddr = Address(
      firstName: json['shippingFirstName'] ?? '',
      lastName: json['shippingLastName'] ?? '',
      street: json['shippingAddressLine1'] ?? '',
      postalCode: json['shippingPostalCode'] ?? '',
      city: json['shippingCity'] ?? '',
      country: json['shippingCountry'] ?? 'Sverige',
      phone: json['shippingPhone'],
    );

    // Billing = shipping for v1.0
    final billingAddr = Address(
      firstName: json['shippingFirstName'] ?? '',
      lastName: json['shippingLastName'] ?? '',
      street: json['shippingAddressLine1'] ?? '',
      postalCode: json['shippingPostalCode'] ?? '',
      city: json['shippingCity'] ?? '',
      country: json['shippingCountry'] ?? 'Sverige',
      phone: json['shippingPhone'],
    );

    return Order(
      orderId: json['orderId'] ?? 0,
      orderNumber: json['orderNumber'] ?? '',
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      status: OrderStatus.fromString(json['status'] ?? 'PENDING'),
      items: parsedItems,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shippingAmount'] as num?)?.toDouble() ??
                (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      tax: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      total: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'SEK',
      shippingAddress: shippingAddr,
      billingAddress: billingAddr,
      paymentMethod: json['paymentMethod'] ?? 'INVOICE',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      trackingNumber: json['trackingNumber'],
      trackingUrl: json['trackingUrl'],
      notes: json['notes'] ?? json['customerNotes'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),
      shippedDate: json['shippedDate'] != null
          ? DateTime.parse(json['shippedDate'])
          : null,
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'])
          : null,
    );
  }
}

class OrderItem {
  final int orderItemId;
  final int productId;
  final String productName;
  final String? productSku;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    required this.orderItemId,
    required this.productId,
    required this.productName,
    this.productSku,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    orderItemId: json['orderItemId'] ?? 0,
    productId: json['productId'] ?? 0,
    productName: json['productName'] ?? '',
    productSku: json['productSku'] ?? json['sku'],
    quantity: json['quantity'] ?? 1,
    unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    subtotal: (json['subtotal'] as num?)?.toDouble() ??
              (json['totalPrice'] as num?)?.toDouble() ??
              (json['price'] as num?)?.toDouble() ?? 0.0,
  );
}

class Address {
  final String firstName;
  final String lastName;
  final String street;
  final String postalCode;
  final String city;
  final String country;
  final String? phone;

  Address({
    required this.firstName,
    required this.lastName,
    required this.street,
    required this.postalCode,
    required this.city,
    required this.country,
    this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    street: json['street'] ?? json['streetAddress'] ?? json['addressLine1'] ?? '',
    postalCode: json['postalCode'] ?? '',
    city: json['city'] ?? '',
    country: json['country'] ?? 'Sverige',
    phone: json['phone'] ?? json['phoneNumber'],
  );

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'street': street,
    'postalCode': postalCode,
    'city': city,
    'country': country,
    if (phone != null) 'phone': phone,
  };
}
