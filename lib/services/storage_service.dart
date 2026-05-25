import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

/// Service responsable du stockage local simple.
///
/// Ce service utilise SharedPreferences pour sauvegarder :
/// - les comptes utilisateurs ;
/// - l'état de connexion ;
/// - l'email de l'utilisateur actuellement connecté.
class StorageService {
  static const String _keyUsers = 'users';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyCurrentUserEmail = 'currentUserEmail';

  /// Normalise l'email pour éviter les problèmes de comparaison.
  ///
  /// Exemple : " Manar@Gmail.com " devient "manar@gmail.com".
  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Récupère tous les utilisateurs sauvegardés localement.
  ///
  /// Les utilisateurs sont stockés sous forme JSON dans SharedPreferences.
  /// Si aucune donnée n'existe, on retourne une liste vide.
  Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUsers = prefs.getString(_keyUsers);

    if (rawUsers == null || rawUsers.isEmpty) {
      return [];
    }

    try {
      final decodedUsers = jsonDecode(rawUsers);

      if (decodedUsers is! List) {
        return [];
      }

      return decodedUsers.map<UserModel>((item) {
        return UserModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    } catch (_) {
      // Si les données JSON sont invalides, on évite de bloquer l'application.
      return [];
    }
  }

  /// Sauvegarde la liste complète des utilisateurs.
  ///
  /// À chaque création de compte, la liste est encodée en JSON
  /// puis enregistrée dans SharedPreferences.
  Future<void> saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();

    final encodedUsers = jsonEncode(
      users.map((user) => user.toJson()).toList(),
    );

    await prefs.setString(_keyUsers, encodedUsers);
  }

  /// Vérifie si un email existe déjà dans les comptes enregistrés.
  Future<bool> emailExists(String email) async {
    final users = await getUsers();
    final cleanEmail = _normalizeEmail(email);

    return users.any(
      (user) => _normalizeEmail(user.email) == cleanEmail,
    );
  }

  /// Ajoute un nouvel utilisateur dans le stockage local.
  ///
  /// L'email est normalisé avant l'enregistrement pour éviter les doublons
  /// liés aux majuscules ou aux espaces.
  Future<void> addUser(UserModel user) async {
    final users = await getUsers();

    users.add(
      UserModel(
        fullName: user.fullName.trim(),
        email: _normalizeEmail(user.email),
        password: user.password,
      ),
    );

    await saveUsers(users);
  }

  /// Recherche un utilisateur à partir de son email.
  ///
  /// Si aucun compte ne correspond, la méthode retourne null.
  Future<UserModel?> findUserByEmail(String email) async {
    final users = await getUsers();
    final cleanEmail = _normalizeEmail(email);

    try {
      return users.firstWhere(
        (user) => _normalizeEmail(user.email) == cleanEmail,
      );
    } catch (_) {
      return null;
    }
  }

  /// Met à jour l'état de connexion.
  ///
  /// Quand l'utilisateur se connecte, on sauvegarde aussi son email
  /// pour pouvoir récupérer ses données dans les autres pages.
  Future<void> setLoggedIn({
    required bool value,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, value);

    if (value && email != null) {
      await prefs.setString(_keyCurrentUserEmail, _normalizeEmail(email));
    }
  }

  /// Indique si un utilisateur est actuellement connecté.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Récupère l'utilisateur connecté.
  ///
  /// On utilise l'email sauvegardé pour retrouver le compte complet
  /// dans la liste des utilisateurs.
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final loggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final email = prefs.getString(_keyCurrentUserEmail);

    if (!loggedIn || email == null) {
      return null;
    }

    return findUserByEmail(email);
  }

  /// Déconnecte l'utilisateur courant.
  ///
  /// Les comptes restent sauvegardés pour pouvoir apparaître ensuite
  /// dans la page "Choisir un compte".
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, false);
  }

  /// Supprime toutes les données sauvegardées dans SharedPreferences.
  ///
  /// Cette méthode est surtout utile pendant les tests pour recommencer
  /// l'application comme une première installation.
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}