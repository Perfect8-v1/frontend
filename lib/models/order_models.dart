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
    orderId: json['orderId'],
    orderNumber: json['orderNumber'],
    customerId: json['customerId'],
    status: OrderStatus.fromString(json['status']),
    items: (json['items'] as List<dynamic>?)
        ?.map((e) => OrderItem.fromJson(e))
        .toList() ?? [],
    subtotal: (json['subtotal'] as num).toDouble(),
    shipping: (json['shipping'] as num).toDouble(),
    tax: (json['tax'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
    currency: json['currency'] ?? 'SEK',
    shippingAddress: Address.fromJson(json['shippingAddress']),
    billingAddress: Address.fromJson(json['billingAddress']),
    paymentMethod: json['paymentMethod'],
    paymentStatus: json['paymentStatus'],
    trackingNumber: json['trackingNumber'],
    trackingUrl: json['trackingUrl'],
    notes: json['notes'],
    createdDate: DateTime.parse(json['createdDate']),
    shippedDate: json['shippedDate'] != null 
        ? DateTime.parse(json['shippedDate']) 
        : null,
    deliveredDate: json['deliveredDate'] != null 
        ? DateTime.parse(json['deliveredDate']) 
        : null,
  );
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
    orderItemId: json['orderItemId'],
    productId: json['productId'],
    productName: json['productName'],
    variantName: json['variantName'],
    quantity: json['quantity'],
    unitPrice: (json['unitPrice'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
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
    firstName: json['firstName'],
    lastName: json['lastName'],
    street: json['street'],
    postalCode: json['postalCode'],
    city: json['city'],
    country: json['country'],
    phone: json['phone'],
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