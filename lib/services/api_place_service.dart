import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_place_model.dart';

/// Service responsable de la consommation de l'API REST externe.
///
/// Cette classe interroge Overpass API pour récupérer des hôtels
/// depuis les données OpenStreetMap.
///
/// Si l'API retourne peu de résultats ou rencontre un problème,
/// une liste de secours est utilisée pour garder un affichage propre.
class ApiPlaceService {
  /// Coordonnées centrales des villes utilisées dans la recherche API.
  ///
  /// La requête Overpass cherche les hôtels autour de ces coordonnées.
  final Map<String, Map<String, double>> _cityCenters = {
    'Tanger': {
      'lat': 35.7595,
      'lon': -5.8339,
    },
    'Casablanca': {
      'lat': 33.5731,
      'lon': -7.5898,
    },
    'Marrakech': {
      'lat': 31.6295,
      'lon': -7.9811,
    },
    'Rabat': {
      'lat': 34.0209,
      'lon': -6.8416,
    },
    'Agadir': {
      'lat': 30.4278,
      'lon': -9.5981,
    },
    'Fès': {
      'lat': 34.0181,
      'lon': -5.0078,
    },
  };

  /// Liste de secours utilisée si l'API externe ne donne pas assez de résultats.
  ///
  /// Cela évite d'afficher une page vide et garde l'application agréable
  /// même si l'API est lente, indisponible ou incomplète.
  final Map<String, List<ApiPlaceModel>> _fallbackHotels = {
    'Tanger': [
      ApiPlaceModel(
        name: 'Hilton Tangier City Center',
        displayName: 'Place du Maghreb Arabe, Tanger',
        type: 'hotel',
        category: 'tourism',
        latitude: 35.7723,
        longitude: -5.7873,
        city: 'Tanger',
      ),
      ApiPlaceModel(
        name: 'Barceló Tanger',
        displayName: 'Boulevard Mohamed VI, Tanger',
        type: 'hotel',
        category: 'tourism',
        latitude: 35.7806,
        longitude: -5.8137,
        city: 'Tanger',
      ),
      ApiPlaceModel(
        name: 'Royal Tulip City Center Tanger',
        displayName: 'Route de Malabata, Tanger',
        type: 'hotel',
        category: 'tourism',
        latitude: 35.7729,
        longitude: -5.7866,
        city: 'Tanger',
      ),
    ],
    'Casablanca': [
      ApiPlaceModel(
        name: 'Kenzi Tower Hotel',
        displayName: 'Twin Center, Boulevard Zerktouni, Casablanca',
        type: 'hotel',
        category: 'tourism',
        latitude: 33.5869,
        longitude: -7.6335,
        city: 'Casablanca',
      ),
      ApiPlaceModel(
        name: 'Hyatt Regency Casablanca',
        displayName: 'Place des Nations Unies, Casablanca',
        type: 'hotel',
        category: 'tourism',
        latitude: 33.5961,
        longitude: -7.6173,
        city: 'Casablanca',
      ),
      ApiPlaceModel(
        name: 'Mövenpick Hotel Casablanca',
        displayName: 'Avenue Hassan II, Casablanca',
        type: 'hotel',
        category: 'tourism',
        latitude: 33.5863,
        longitude: -7.6248,
        city: 'Casablanca',
      ),
    ],
    'Marrakech': [
      ApiPlaceModel(
        name: 'La Mamounia Marrakech',
        displayName: 'Avenue Bab Jdid, Marrakech',
        type: 'hotel',
        category: 'tourism',
        latitude: 31.6215,
        longitude: -7.9977,
        city: 'Marrakech',
      ),
      ApiPlaceModel(
        name: 'Mövenpick Mansour Eddahbi',
        displayName: 'Avenue Mohammed VI, Marrakech',
        type: 'hotel',
        category: 'tourism',
        latitude: 31.6246,
        longitude: -8.0109,
        city: 'Marrakech',
      ),
      ApiPlaceModel(
        name: 'Kenzi Rose Garden',
        displayName: 'Avenue Président Kennedy, Marrakech',
        type: 'hotel',
        category: 'tourism',
        latitude: 31.6269,
        longitude: -8.0064,
        city: 'Marrakech',
      ),
    ],
    'Rabat': [
      ApiPlaceModel(
        name: 'Sofitel Rabat Jardin des Roses',
        displayName: 'Avenue Imam Malik, Rabat',
        type: 'hotel',
        category: 'tourism',
        latitude: 33.9917,
        longitude: -6.8367,
        city: 'Rabat',
      ),
      ApiPlaceModel(
        name: 'ONOMO Hotel Rabat Terminus',
        displayName: 'Avenue Mohammed V, Rabat',
        type: 'hotel',
        category: 'tourism',
        latitude: 34.0181,
        longitude: -6.8343,
        city: 'Rabat',
      ),
      ApiPlaceModel(
        name: 'ibis Rabat Agdal',
        displayName: 'Avenue Haj Ahmed Charkaoui, Rabat',
        type: 'hotel',
        category: 'tourism',
        latitude: 34.0006,
        longitude: -6.8527,
        city: 'Rabat',
      ),
    ],
    'Agadir': [
      ApiPlaceModel(
        name: 'Sofitel Agadir Royal Bay Resort',
        displayName: 'Baie des Palmiers, Agadir',
        type: 'hotel',
        category: 'tourism',
        latitude: 30.3956,
        longitude: -9.5963,
        city: 'Agadir',
      ),
      ApiPlaceModel(
        name: 'Tildi Hotel & Spa',
        displayName: 'Rue Hubert Giraud, Agadir',
        type: 'hotel',
        category: 'tourism',
        latitude: 30.4259,
        longitude: -9.6083,
        city: 'Agadir',
      ),
      ApiPlaceModel(
        name: 'Hyatt Place Taghazout Bay',
        displayName: 'Taghazout Bay, Agadir',
        type: 'hotel',
        category: 'tourism',
        latitude: 30.5451,
        longitude: -9.7076,
        city: 'Agadir',
      ),
    ],
    'Fès': [
      ApiPlaceModel(
        name: 'Palais Faraj Suites & Spa',
        displayName: 'Bab Ziat, Fès',
        type: 'hotel',
        category: 'tourism',
        latitude: 34.0611,
        longitude: -4.9817,
        city: 'Fès',
      ),
      ApiPlaceModel(
        name: 'Hotel Sahrai',
        displayName: 'Bab Lghoul, Fès',
        type: 'hotel',
        category: 'tourism',
        latitude: 34.0372,
        longitude: -5.0028,
        city: 'Fès',
      ),
      ApiPlaceModel(
        name: 'Fes Marriott Hotel Jnan Palace',
        displayName: 'Avenue Ahmed Chaouki, Fès',
        type: 'hotel',
        category: 'tourism',
        latitude: 34.0229,
        longitude: -5.0075,
        city: 'Fès',
      ),
    ],
  };

  /// Recherche les hôtels d'une ville via Overpass API.
  ///
  /// La requête cible les objets OpenStreetMap qui possèdent le tag :
  /// tourism=hotel.
  ///
  /// Si l'API ne répond pas correctement, on utilise les données de secours.
  Future<List<ApiPlaceModel>> searchHotelsByCity(String city) async {
    final center = _cityCenters[city];

    if (center == null) {
      return _fallbackHotels[city] ?? [];
    }

    final double lat = center['lat']!;
    final double lon = center['lon']!;

    final query = '''
[out:json][timeout:25];
(
  node["tourism"="hotel"](around:18000,$lat,$lon);
  way["tourism"="hotel"](around:18000,$lat,$lon);
  relation["tourism"="hotel"](around:18000,$lat,$lon);
);
out center tags 25;
''';

    final uri = Uri.parse('https://overpass-api.de/api/interpreter');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'HotelGoFlutterMiniProject/1.0',
        },
        body: {
          'data': query,
        },
      );

      if (response.statusCode != 200) {
        return _fallbackHotels[city] ?? [];
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> elements = data['elements'] ?? [];

      final apiResults = elements
          .map(
            (item) => ApiPlaceModel.fromOverpassJson(
              item as Map<String, dynamic>,
              city,
            ),
          )
          .where((place) {
            final name = place.name.trim().toLowerCase();

            // On retire les résultats vides ou trop génériques.
            if (name.isEmpty) return false;
            if (name == 'hôtel sans nom') return false;
            if (name == 'hotel ${city.toLowerCase()}') return false;
            if (name == 'hôtel ${city.toLowerCase()}') return false;

            return true;
          })
          .toList();

      final Map<String, ApiPlaceModel> uniquePlaces = {};

      // Suppression des doublons en utilisant le nom de l'hôtel.
      for (final place in apiResults) {
        uniquePlaces[place.name.toLowerCase()] = place;
      }

      final cleanResults = uniquePlaces.values.take(8).toList();
      final fallback = _fallbackHotels[city] ?? [];

      // Si l'API donne moins de 3 résultats propres, on complète
      // avec des hôtels de secours pour garder une page bien remplie.
      if (cleanResults.length < 3) {
        final combined = [...cleanResults];

        for (final fallbackHotel in fallback) {
          final alreadyExists = combined.any(
            (hotel) =>
                hotel.name.toLowerCase() ==
                fallbackHotel.name.toLowerCase(),
          );

          if (!alreadyExists) {
            combined.add(fallbackHotel);
          }
        }

        return combined.take(8).toList();
      }

      return cleanResults;
    } catch (_) {
      // En cas d'erreur réseau ou API, l'application reste utilisable.
      return _fallbackHotels[city] ?? [];
    }
  }
}