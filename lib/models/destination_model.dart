class Destination {
  final String carPlate;
  final String driverId;
  final int capacity;
  int? likes;

  Destination(this.carPlate, this.driverId, this.capacity);

  Map<String, dynamic> toJson() {
    return {
      "carPlate": carPlate,
      "driverId": driverId,
      "capacity": capacity,
      "likes": likes
    };
  }
}
