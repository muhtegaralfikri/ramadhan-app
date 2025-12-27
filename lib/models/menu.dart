class MenuBuka {
  final String id;
  final String locationName;
  final String? address;
  final String? menu;
  final DateTime date;
  final String? contact;
  final int? capacity;
  final String? imageUrl;

  MenuBuka({
    required this.id,
    required this.locationName,
    this.address,
    this.menu,
    required this.date,
    this.contact,
    this.capacity,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_name': locationName,
      'address': address,
      'menu': menu,
      'date': date.toIso8601String(),
      'contact': contact,
      'capacity': capacity,
      'image_url': imageUrl,
    };
  }

  factory MenuBuka.fromJson(Map<String, dynamic> json) {
    return MenuBuka(
      id: json['id'],
      locationName: json['location_name'],
      address: json['address'],
      menu: json['menu'],
      date: DateTime.parse(json['date']),
      contact: json['contact'],
      capacity: json['capacity'],
      imageUrl: json['image_url'],
    );
  }
}
