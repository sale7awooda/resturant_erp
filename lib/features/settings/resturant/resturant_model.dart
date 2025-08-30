class RestaurantDetail {
  final int? id;
  final String? name;
  final String? logo;
  final String? description;
  final String? location;
  final String? workingHours;
  final String? phone;
  final String? currency;
  final String? themeMode;
  final String? color;
  final String? language;
  RestaurantDetail({
    this.id,
    this.name,
    this.logo,
    this.description,
    this.location,
    this.workingHours,
    this.phone,
    this.currency,
    this.themeMode,
    this.color,
    this.language,
  });
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'logo': logo,
        'description': description,
        'location': location,
        'working_hours': workingHours,
        'phone': phone,
        'currency': currency,
        'theme_mode': themeMode,
        'color': color,
        'language': language
      };
  factory RestaurantDetail.fromMap(Map<String, dynamic> m) => RestaurantDetail(
        id: m['id'],
        name: m['name'],
        logo: m['logo'],
        description: m['description'],
        location: m['location'],
        workingHours: m['working_hours'],
        phone: m['phone'],
        currency: m['currency'],
        themeMode: m['theme_mode'],
        color: m['color'],
        language: m['language'],
      );
}
