class Menu {
  final int id;
  final String name;
  final int price;
  final String? description;
  final String? image;

  Menu({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.image,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'], // ✅ disesuaikan
      price: (json['price'] is int) // ✅ disesuaikan
          ? json['price']
          : int.tryParse(json['price'].toString().split('.')[0]) ?? 0,
      description: json['description'], // ✅ tambahan opsional
      image: json['image'], // ✅ tambahan opsional
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image': image,
    };
  }
}