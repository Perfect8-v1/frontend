// lib/models/customer_models.dart

/// Customer model matching backend CustomerDTO
class Customer {
  final int? customerId;
  final int? userId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final bool active;
  final bool emailVerified;
  final List<Address> addresses;

  Customer({
    this.customerId,
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.active = true,
    this.emailVerified = false,
    this.addresses = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      userId: json['userId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      active: json['active'] ?? true,
      emailVerified: json['emailVerified'] ?? false,
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((a) => Address.fromJson(a))
              .toList() ??
          [],
    );
  }

  String get fullName {
    final parts = <String>[];
    if (firstName != null && firstName!.isNotEmpty) parts.add(firstName!);
    if (lastName != null && lastName!.isNotEmpty) parts.add(lastName!);
    return parts.join(' ');
  }

  /// Sammansatt username (firstName + lastName)
  String get username {
    final fn = firstName ?? '';
    final ln = lastName ?? '';
    return (fn + ln).replaceAll(' ', '').toLowerCase();
  }

  /// Get default shipping address if any
  Address? get defaultShippingAddress {
    return addresses.where((a) => a.defaultShipping).firstOrNull ??
        addresses.where((a) => a.isShippingAddress).firstOrNull;
  }
}

/// Address model matching backend AddressDTO
class Address {
  final int? addressId;
  final String? addressType; // BILLING, SHIPPING, BOTH
  final String? recipientName;
  final String? companyName;
  final String? streetAddress;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? stateCode;
  final String? postalCode;
  final String? country;
  final String? countryCode;
  final String? phoneNumber;
  final String? emailAddress;
  final String? deliveryInstructions;
  final bool defaultShipping;
  final bool defaultBilling;

  Address({
    this.addressId,
    this.addressType,
    this.recipientName,
    this.companyName,
    this.streetAddress,
    this.addressLine2,
    this.city,
    this.state,
    this.stateCode,
    this.postalCode,
    this.country,
    this.countryCode,
    this.phoneNumber,
    this.emailAddress,
    this.deliveryInstructions,
    this.defaultShipping = false,
    this.defaultBilling = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['addressId'],
      addressType: json['addressType'],
      recipientName: json['recipientName'],
      companyName: json['companyName'],
      streetAddress: json['streetAddress'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      stateCode: json['stateCode'],
      postalCode: json['postalCode'],
      country: json['country'],
      countryCode: json['countryCode'],
      phoneNumber: json['phoneNumber'],
      emailAddress: json['emailAddress'],
      deliveryInstructions: json['deliveryInstructions'],
      defaultShipping: json['defaultShipping'] ?? false,
      defaultBilling: json['defaultBilling'] ?? false,
    );
  }

  bool get isBillingAddress =>
      addressType == 'BILLING' || addressType == 'BOTH';

  bool get isShippingAddress =>
      addressType == 'SHIPPING' || addressType == 'BOTH';
}
