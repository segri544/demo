class User {
  final String? id;
  final String name;
  final String lastName;
  final String email;
  final String position;
  final String? address;
  final String? vehiclePlate;

  const User(
      {this.id,
      this.address,
      this.vehiclePlate,
      required this.name,
      required this.lastName,
      required this.email,
      required this.position});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "lastName": lastName,
      "email": email,
      "position": position,
      "address": address,
      "vehiclePlate": vehiclePlate
    };
  }
}
