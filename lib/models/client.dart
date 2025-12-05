class Client {
  final int? id;
  final String description;
  final String address;
  final GpsPosition gpsPosition;

  Client({
    this.id,
    required this.description,
    required this.address,
    required this.gpsPosition,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      description: json['description'],
      address: json['address'],
      gpsPosition: GpsPosition.fromJson(json['gpsPosition']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'address': address,
      'gpsPosition': gpsPosition.toJson(),
    };
  }
}

class GpsPosition {
  final double latitude;
  final double longitude;

  GpsPosition({
    required this.latitude,
    required this.longitude,
  });

  factory GpsPosition.fromJson(Map<String, dynamic> json) {
    return GpsPosition(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}