import 'package:geolocator/geolocator.dart';

/// Service responsable de la géolocalisation.
///
/// Il permet de récupérer la position actuelle de l'utilisateur,
/// de vérifier les permissions GPS et de calculer la distance
/// entre l'utilisateur et les hôtels.
class LocationService {
  static final LocationService instance = LocationService._internal();

  LocationService._internal();

  /// Coordonnées approximatives des hôtels locaux.
  ///
  /// Ces coordonnées sont utilisées pour afficher la distance
  /// entre l'utilisateur et chaque hôtel dans la page d'accueil.
  final Map<int, Map<String, double>> hotelCoordinates = {
    1: {'lat': 35.7595, 'lng': -5.8339},
    2: {'lat': 35.7806, 'lng': -5.8137},
    3: {'lat': 33.5869, 'lng': -7.6335},
    4: {'lat': 33.5883, 'lng': -7.6329},
    5: {'lat': 33.5988, 'lng': -7.6138},
    6: {'lat': 31.6246, 'lng': -8.0109},
    7: {'lat': 31.6295, 'lng': -8.0182},
    8: {'lat': 34.0181, 'lng': -6.8343},
    9: {'lat': 34.0006, 'lng': -6.8527},
    10: {'lat': 30.5451, 'lng': -9.7076},
    11: {'lat': 30.4259, 'lng': -9.6083},
    12: {'lat': 34.0611, 'lng': -4.9817},
  };

  /// Récupère la position actuelle de l'utilisateur.
  ///
  /// Avant de récupérer la position, on vérifie :
  /// - si la localisation est activée ;
  /// - si la permission est accordée ;
  /// - si la permission n'a pas été refusée définitivement.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Le service de localisation est désactivé');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permission de localisation refusée');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permission de localisation refusée définitivement. Activez-la depuis les paramètres.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Calcule la distance entre l'utilisateur et un hôtel.
  ///
  /// Geolocator retourne la distance en mètres.
  /// Je la convertis ensuite en kilomètres pour l'affichage.
  double? distanceToHotelInKm({
    required int hotelId,
    required double userLatitude,
    required double userLongitude,
  }) {
    final coordinates = hotelCoordinates[hotelId];

    if (coordinates == null) {
      return null;
    }

    final distanceInMeters = Geolocator.distanceBetween(
      userLatitude,
      userLongitude,
      coordinates['lat']!,
      coordinates['lng']!,
    );

    return distanceInMeters / 1000;
  }
}