class SalesPerson {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String region;
  final bool isActive;

  SalesPerson({
    this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.region = '',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'region': region,
    'isActive': isActive ? 1 : 0,
  };

  factory SalesPerson.fromMap(Map<String, dynamic> map) => SalesPerson(
    id: map['id'] as int?,
    name: map['name'] as String,
    phone: map['phone'] as String,
    email: map['email'] as String,
    region: map['region'] as String,
    isActive: map['isActive'] == 1,
  );
}
