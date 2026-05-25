import '../models/reservation_model.dart';
import '../services/database_service.dart';
import 'auth_controller.dart';

/// Contrôleur responsable des réservations.
///
/// Il applique aussi la logique multi-utilisateur : chaque réservation
/// est liée à l'email de l'utilisateur connecté.
class ReservationController {
  final DatabaseService _databaseService = DatabaseService.instance;
  final AuthController _authController = AuthController();

  /// Récupère l'email de l'utilisateur connecté.
  ///
  /// L'email est utilisé comme clé pour séparer les réservations
  /// de chaque utilisateur.
  Future<String?> _currentUserEmail() async {
    final user = await _authController.getCurrentUser();

    if (user == null) {
      return null;
    }

    return user.email.trim().toLowerCase();
  }

  /// Ajoute une nouvelle réservation dans SQLite.
  ///
  /// Avant l'insertion, on ajoute automatiquement l'email de l'utilisateur
  /// pour que la réservation soit bien associée au bon compte.
  Future<int> addReservation(ReservationModel reservation) async {
    final email = await _currentUserEmail();

    if (email == null) {
      return 0;
    }

    final reservationWithUser = reservation.copyWith(
      userEmail: email,
    );

    return await _databaseService.insertReservation(reservationWithUser);
  }

  /// Récupère uniquement les réservations de l'utilisateur connecté.
  Future<List<ReservationModel>> getAllReservations() async {
    final email = await _currentUserEmail();

    if (email == null) {
      return [];
    }

    return await _databaseService.getReservationsByUser(email);
  }

  /// Modifie une réservation existante.
  ///
  /// On garde toujours l'email de l'utilisateur connecté pour éviter
  /// de modifier les données d'un autre compte.
  Future<int> updateReservation(ReservationModel reservation) async {
    final email = await _currentUserEmail();

    if (email == null) {
      return 0;
    }

    final reservationWithUser = reservation.copyWith(
      userEmail: email,
    );

    return await _databaseService.updateReservation(reservationWithUser);
  }

  /// Supprime une réservation par son identifiant.
  ///
  /// La suppression se fait aussi avec l'email de l'utilisateur pour sécuriser
  /// la séparation des données entre comptes.
  Future<int> deleteReservation(int id) async {
    final email = await _currentUserEmail();

    if (email == null) {
      return 0;
    }

    return await _databaseService.deleteReservation(
      id: id,
      userEmail: email,
    );
  }
}