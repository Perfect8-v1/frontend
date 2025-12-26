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

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    orderId: json['orderId'] ?? 0,
    orderNumber: json['orderNumber'] ?? '',
    customerId: json['customerId'] ?? 0,
    status: OrderStatus.fromString(json['status'] ?? 'PENDING'),
    items: (json['items'] as List<dynamic>?)
        ?.map((e) => OrderItem.fromJson(e))
        .toList() ?? [],
    // Handle null values with safe casting
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    shipping: (json['shippingCost'] as num?)?.toDouble() ??
              (json['shipping'] as num?)?.toDouble() ?? 0.0,
    tax: (json['taxAmount'] as num?)?.toDouble() ??
         (json['tax'] as num?)?.toDouble() ?? 0.0,
    total: (json['totalAmount'] as num?)?.toDouble() ??
           (json['total'] as num?)?.toDouble() ?? 0.0,
    currency: json['currency'] ?? 'SEK',
    // Address can be string or object from backend
    shippingAddress: _parseAddress(json['shippingAddress']),
    billingAddress: _parseAddress(json['billingAddress'] ?? json['shippingAddress']),
    paymentMethod: json['paymentMethod'] ?? 'INVOICE',
    paymentStatus: json['paymentStatus'] ?? 'PENDING',
    trackingNumber: json['trackingNumber'],
    trackingUrl: json['trackingUrl'],
    notes: json['notes'],
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

/// Parse address from either string or object format
Address _parseAddress(dynamic addressData) {
  if (addressData == null) {
    return Address(
      firstName: '',
      lastName: '',
      street: '',
      postalCode: '',
      city: '',
      country: 'Sverige',
    );
  }

  // If it's a string (backend returns comma-separated format)
  if (addressData is String) {
    final parts = addressData.split(', ');
    return Address(
      firstName: '',
      lastName: '',
      street: parts.isNotEmpty ? parts[0] : '',
      city: parts.length > 1 ? parts[1] : '',
      country: parts.length > 2 ? parts[2] : 'Sverige',
      postalCode: parts.length > 3 ? parts[3] : '',
    );
  }

  // If it's an object
  return Address.fromJson(addressData as Map<String, dynamic>);
}

class OrderItem {
  final int orderItemId;
  final int productId;
  final String productName;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    required this.orderItemId,
    required this.productId,
    required this.productName,
    this.variantName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    orderItemId: json['orderItemId'] ?? 0,
    productId: json['productId'] ?? 0,
    productName: json['productName'] ?? '',
    variantName: json['variantName'],
    quantity: json['quantity'] ?? 1,
    unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    subtotal: (json['subtotal'] as num?)?.toDouble() ??
              (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
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
    street: json['street'] ?? json['streetAddress'] ?? '',
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

class CreateOrderRequest {
  final Address shippingAddress;
  final bool billingAddressSameAsShipping;
  final Address? billingAddress;
  final String paymentMethod;
  final String? notes;

  CreateOrderRequest({
    required this.shippingAddress,
    this.billingAddressSameAsShipping = true,
    this.billingAddress,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'shippingAddress': shippingAddress.toJson(),
    'billingAddress': {
      'sameAsShipping': billingAddressSameAsShipping,
      if (!billingAddressSameAsShipping && billingAddress != null)
        ...billingAddress!.toJson(),
    },
    'paymentMethod': paymentMethod,
    if (notes != null) 'notes': notes,
  };
}