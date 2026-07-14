class VisitModel {
  final int? id;
  final String storeName;
  final String storeAddress;
  final String storeType;
  final String storePhone;
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? photoPath;
  final int visitDate;
  final int checkInTime;
  final int? checkOutTime;
  final String status;
  final double orderValue;
  final String notes;
  final String productsShown;

  VisitModel({
    this.id,
    required this.storeName,
    required this.storeAddress,
    this.storeType = 'Retail',
    this.storePhone = '',
    required this.latitude,
    required this.longitude,
    this.accuracy = 0.0,
    this.photoPath,
    required this.visitDate,
    required this.checkInTime,
    this.checkOutTime,
    this.status = 'VISITED',
    this.orderValue = 0.0,
    this.notes = '',
    this.productsShown = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'storeType': storeType,
      'storePhone': storePhone,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'photoPath': photoPath,
      'visitDate': visitDate,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'orderValue': orderValue,
      'notes': notes,
      'productsShown': productsShown,
    };
  }

  factory VisitModel.fromMap(Map<String, dynamic> map) {
    return VisitModel(
      id: map['id'] as int?,
      storeName: map['storeName'] as String,
      storeAddress: map['storeAddress'] as String,
      storeType: map['storeType'] as String,
      storePhone: map['storePhone'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      accuracy: map['accuracy'] as double,
      photoPath: map['photoPath'] as String?,
      visitDate: map['visitDate'] as int,
      checkInTime: map['checkInTime'] as int,
      checkOutTime: map['checkOutTime'] as int?,
      status: map['status'] as String,
      orderValue: map['orderValue'] as double,
      notes: map['notes'] as String,
      productsShown: map['productsShown'] as String,
    );
  }
}
