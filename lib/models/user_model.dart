/// >>>>>> Author: Berke Gürel <<<<<<<

// The User class representing a user object
class User {
  final String? id; // Unique identifier for the user (optional)
  final String name; // User's first name
  final String lastName; // User's last name
  final String email; // User's email address
  final String position; // User's position (e.g., job title)
  final String? address; // User's address (optional)
  final String? vehiclePlate; // User's vehicle plate number (optional)
  final List? likedDestinations; // List of liked destination IDs (optional)

  // Constructor to initialize the User object with the provided properties
  const User({
    this.id,
    this.address,
    this.vehiclePlate,
    required this.name,
    this.likedDestinations,
    required this.lastName,
    required this.email,
    required this.position,
  });

  // Method to convert the User object to a JSON format (a Map of key-value pairs)
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "lastName": lastName,
      "email": email,
      "position": position,
      "address": address,
      "vehiclePlate": vehiclePlate,
      "likedDestinations": likedDestinations,
    };
  }
}
