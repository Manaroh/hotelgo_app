import '../models/user_model.dart';
import '../services/storage_service.dart';

/// Contrôleur responsable de l'authentification locale.
///
/// Il fait le lien entre les vues Login/Register et le service de stockage.
/// Toute la logique liée aux comptes utilisateurs passe par cette classe.
class AuthController {
  final StorageService _storageService = StorageService();

  /// Normalise l'email pour éviter les problèmes liés aux majuscules,
  /// aux minuscules ou aux espaces ajoutés par erreur.
  ///
  /// Exemple : " Manar@Gmail.com " devient "manar@gmail.com".
  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Crée un nouveau compte utilisateur.
  ///
  /// Avant d'ajouter l'utilisateur, on vérifie si l'email existe déjà.
  /// Cela permet d'éviter la création de deux comptes avec la même adresse.
  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cleanEmail = _normalizeEmail(email);

    final exists = await _storageService.emailExists(cleanEmail);

    if (exists) {
      return 'Un compte existe déjà avec cet email';
    }

    final user = UserModel(
      fullName: fullName.trim(),
      email: cleanEmail,
      password: password,
    );

    await _storageService.addUser(user);

    // Après l'inscription, l'utilisateur n'est pas connecté automatiquement.
    // Il sera redirigé vers la page Login avec les champs déjà préparés.
    await _storageService.setLoggedIn(value: false);

    return null;
  }

  /// Connecte un utilisateur existant.
  ///
  /// On vérifie d'abord si l'email existe, puis on compare le mot de passe
  /// avec celui sauvegardé localement.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = _normalizeEmail(email);

    final user = await _storageService.findUserByEmail(cleanEmail);

    if (user == null) {
      return 'Aucun compte trouvé avec cet email';
    }

    if (user.password != password) {
      return 'Email ou mot de passe incorrect';
    }

    await _storageService.setLoggedIn(
      value: true,
      email: cleanEmail,
    );

    return null;
  }

  /// Vérifie si un utilisateur est actuellement connecté.
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  /// Récupère la liste des comptes déjà enregistrés.
  ///
  /// Cette méthode est utilisée dans l'écran de choix de compte.
  Future<List<UserModel>> getSavedUsers() async {
    return await _storageService.getUsers();
  }

  /// Récupère l'utilisateur connecté actuellement.
  ///
  /// Cette information est utilisée dans l'accueil, le profil,
  /// les réservations, les favoris et les avis.
  Future<UserModel?> getCurrentUser() async {
    return await _storageService.getCurrentUser();
  }

  /// Déconnecte l'utilisateur sans supprimer son compte.
  Future<void> logout() async {
    await _storageService.logout();
  }
}