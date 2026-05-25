import 'package:shared_preferences/shared_preferences.dart';

import '../models/hotel_model.dart';
import 'auth_controller.dart';
import 'hotel_controller.dart';

/// Contrôleur responsable des hôtels favoris.
///
/// Les favoris sont sauvegardés localement avec SharedPreferences.
/// Chaque utilisateur a sa propre clé de stockage pour garder ses favoris séparés.
class FavoriteController {
  final HotelController _hotelController = HotelController();
  final AuthController _authController = AuthController();

  /// Crée une clé spécifique pour les favoris de l'utilisateur connecté.
  ///
  /// Exemple :
  /// favoriteHotelIds_manar@gmail.com
  Future<String> _favoritesKey() async {
    final user = await _authController.getCurrentUser();

    if (user == null) {
      return 'favoriteHotelIds_guest';
    }

    final email = user.email.trim().toLowerCase();

    return 'favoriteHotelIds_$email';
  }

  /// Récupère les identifiants des hôtels ajoutés aux favoris.
  Future<List<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _favoritesKey();

    final idsAsString = prefs.getStringList(key) ?? [];

    return idsAsString
        .map((id) => int.tryParse(id))
        .whereType<int>()
        .toList();
  }

  /// Vérifie si un hôtel est déjà dans les favoris.
  Future<bool> isFavorite(int hotelId) async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.contains(hotelId);
  }

  /// Ajoute ou retire un hôtel des favoris.
  ///
  /// Si l'hôtel existe déjà dans la liste, on le retire.
  /// Sinon, on l'ajoute.
  Future<void> toggleFavorite(int hotelId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _favoritesKey();

    final favoriteIds = await getFavoriteIds();

    if (favoriteIds.contains(hotelId)) {
      favoriteIds.remove(hotelId);
    } else {
      favoriteIds.add(hotelId);
    }

    await prefs.setStringList(
      key,
      favoriteIds.map((id) => id.toString()).toList(),
    );
  }

  /// Retourne les objets HotelModel correspondant aux hôtels favoris.
  ///
  /// On récupère d'abord les IDs, puis on filtre la liste complète des hôtels.
  Future<List<HotelModel>> getFavoriteHotels() async {
    final favoriteIds = await getFavoriteIds();
    final allHotels = _hotelController.getAllHotels();

    return allHotels.where((hotel) {
      return favoriteIds.contains(hotel.id);
    }).toList();
  }
}