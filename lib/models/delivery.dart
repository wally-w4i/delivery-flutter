class Delivery {
  final int id;
  final String date;
  final String status;
  final List<DeliveryDetail> details;

  Delivery({
    required this.id,
    required this.date,
    required this.status,
    required this.details,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      date: json['date'],
      status: json['status'],
      details: (json['details'] as List<dynamic>)
          .map((detail) => DeliveryDetail.fromJson(detail))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'status': status,
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}

class DeliveryDetail {
  final int? id;
  final int clientId;
  final String? status;

  DeliveryDetail({
    required this.id,
    required this.clientId,
    required this.status,
  });

  factory DeliveryDetail.fromJson(Map<String, dynamic> json) {
    return DeliveryDetail(
      id: json['id'],
      clientId: json['clientId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'clientId': clientId, 'status': status};
  }
}
