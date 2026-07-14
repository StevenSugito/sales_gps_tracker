class DeliveryModel {
  final int? id;
  final int orderId;
  final int salesPersonId;
  final String deliveryNumber;
  final String courierName;
  final String trackingNumber;
  final String status;
  final int deliveryDate;
  final int? receivedDate;
  final String? receivedBy;
  final String? photoPath;
  final String? notes;

  DeliveryModel({
    this.id,
    required this.orderId,
    required this.salesPersonId,
    required this.deliveryNumber,
    this.courierName = '',
    this.trackingNumber = '',
    this.status = 'PREPARING',
    required this.deliveryDate,
    this.receivedDate,
    this.receivedBy,
    this.photoPath,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'orderId': orderId,
    'salesPersonId': salesPersonId,
    'deliveryNumber': deliveryNumber,
    'courierName': courierName,
    'trackingNumber': trackingNumber,
    'status': status,
    'deliveryDate': deliveryDate,
    'receivedDate': receivedDate,
    'receivedBy': receivedBy,
    'photoPath': photoPath,
    'notes': notes,
  };

  factory DeliveryModel.fromMap(Map<String, dynamic> map) => DeliveryModel(
    id: map['id'] as int?,
    orderId: map['orderId'] as int,
    salesPersonId: map['salesPersonId'] as int,
    deliveryNumber: map['deliveryNumber'] as String,
    courierName: map['courierName'] as String,
    trackingNumber: map['trackingNumber'] as String,
    status: map['status'] as String,
    deliveryDate: map['deliveryDate'] as int,
    receivedDate: map['receivedDate'] as int?,
    receivedBy: map['receivedBy'] as String?,
    photoPath: map['photoPath'] as String?,
    notes: map['notes'] as String?,
  );
}
