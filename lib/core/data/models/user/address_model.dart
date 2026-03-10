class AddressModel<T> {
  
  final String? addrName;
  final String addressLine1;
  final String? addressLine2;
  final String? village;
  final String? taluka;
  final String city;
  final String state;
  final String? stateIso;
  final String postalCode;
  final double latitude;
  final double longitude;

  AddressModel({
    this.addrName,
    required this.addressLine1,
    this.addressLine2,
    this.village,
    this.taluka,
    required this.city,
    required this.state,
    this.stateIso,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addrName: json['addr_name'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      village: json['village'],
      taluka: json['taluka'],
      city: json['city'],
      state: json['state'],
      stateIso: json['state_iso'],
      postalCode: json['postal_code'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addr_name': addrName,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'village': village,
      'taluka': taluka,
      'city': city,
      'state': state,
      'state_iso': stateIso,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
