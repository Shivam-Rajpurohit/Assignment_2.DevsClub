class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final int? baseExperience;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    this.baseExperience
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      imageUrl: json['sprites']?['front_default'] ?? '',
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      types: _parseTypes(json['types']),
      abilities: _parseAbilities(json['abilities']),
      baseExperience: json['base_experience'],
    );
  }

  static List<String> _parseTypes(dynamic typesData) {
    if (typesData == null) return [];
    return List<String>.from(
      typesData.map((type) => type['type']['name'].toString()),
    );
  }

  static List<String> _parseAbilities(dynamic abilitiesData) {
    if (abilitiesData == null) return [];
    return List<String>.from(
      abilitiesData.map((ability) => ability['ability']['name'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'height': height,
      'weight': weight,
      'types': types,
      'abilities': abilities,
    };
  }

  String get formattedId => '#${id.toString().padLeft(3, '0')}';
  String get capitalizedName => name[0].toUpperCase() + name.substring(1);
  String get formattedHeight => '${height / 10} m';
  String get formattedWeight => '${weight / 10} kg';
}