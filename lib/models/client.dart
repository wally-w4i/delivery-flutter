class Client {
  final String description;
  final String address;
  final double? lat;
  final double? lng;

  Client({
    required this.description,
    required this.address,
    this.lat,
    this.lng,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      description: json['description'],
      address: json['address'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }
}
