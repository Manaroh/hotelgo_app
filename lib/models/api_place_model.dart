/// Modèle utilisé pour représenter un hôtel récupéré depuis l'API REST.
///
/// Les données API ne viennent pas du même endroit que les hôtels locaux.
/// Ce modèle permet donc de convertir les résultats de l'API en objets
/// simples à afficher dans l'application.
class ApiPlaceModel {
  final String name;
  final String displayName;
  final String type;
  final String category;
  final double latitude;
  final double longitude;
  final String city;

  ApiPlaceModel({
    required this.name,
    required this.displayName,
    required this.type,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.city,
  });

  /// Convertit une valeur dynamique en double.
  ///
  /// Les coordonnées venant d'une API peuvent parfois être lues comme int,
  /// double ou String. Cette méthode sécurise la conversion.
  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  /// Crée un ApiPlaceModel à partir d'un objet JSON venant d'Overpass API.
  ///
  /// Overpass peut retourner des nodes avec lat/lon directement,
  /// ou des ways/relations avec les coordonnées dans center.
  factory ApiPlaceModel.fromOverpassJson(
    Map<String, dynamic> json,
    String city,
  ) {
    final rawTags = json['tags'];

    // Les tags contiennent les informations lisibles comme le nom,
    // l'adresse ou le type de lieu.
    final Map<String, dynamic> tags = rawTags is Map
        ? Map<String, dynamic>.from(rawTags)
        : <String, dynamic>{};

    final rawCenter = json['center'];

    // Les objets complexes de OpenStreetMap peuvent avoir leurs coordonnées
    // dans le champ center au lieu de lat/lon.
    final Map<String, dynamic> center = rawCenter is Map
        ? Map<String, dynamic>.from(rawCenter)
        : <String, dynamic>{};

    final String name = (tags['name'] ??
            tags['name:fr'] ??
            tags['name:en'] ??
            'Hôtel sans nom')
        .toString();

    final double lat = json['lat'] != null
        ? _toDouble(json['lat'])
        : _toDouble(center['lat']);

    final double lon = json['lon'] != null
        ? _toDouble(json['lon'])
        : _toDouble(center['lon']);

    final String street = (tags['addr:street'] ?? '').toString();
    final String district = (tags['addr:suburb'] ?? '').toString();
    final String phone =
        (tags['phone'] ?? tags['contact:phone'] ?? '').toString();

    String address = city;

    // On construit une adresse courte et lisible pour l'interface.
    if (street.isNotEmpty) {
      address = '$street, $city';
    } else if (district.isNotEmpty) {
      address = '$district, $city';
    }

    if (phone.isNotEmpty) {
      address = '$address • $phone';
    }

    return ApiPlaceModel(
      name: name,
      displayName: address,
      type: (tags['tourism'] ?? 'hotel').toString(),
      category: 'tourism',
      latitude: lat,
      longitude: lon,
      city: city,
    );
  }
}