import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrôleur responsable de la photo de profil.
///
/// Il permet de sauvegarder, récupérer et supprimer une image de profil
/// pour chaque utilisateur séparément.
class ProfileImageController {
  static const String _keyPrefix = 'profileImagePath_';

  /// Nettoie l'email pour pouvoir l'utiliser dans une clé ou un nom de fichier.
  ///
  /// Les caractères spéciaux sont remplacés par des underscores.
  String _cleanEmail(String email) {
    return email.trim().toLowerCase().replaceAll(
          RegExp(r'[^a-zA-Z0-9]'),
          '_',
        );
  }

  /// Construit la clé SharedPreferences utilisée pour un utilisateur.
  String _keyForUser(String email) {
    return '$_keyPrefix${_cleanEmail(email)}';
  }

  /// Récupère le chemin de la photo de profil d'un utilisateur.
  ///
  /// On vérifie aussi si le fichier existe réellement dans le stockage local.
  Future<String?> getProfileImagePath(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_keyForUser(email));

    if (path == null || path.isEmpty) {
      return null;
    }

    final file = File(path);

    if (await file.exists()) {
      return path;
    }

    return null;
  }

  /// Sauvegarde une nouvelle photo de profil.
  ///
  /// L'image choisie est copiée dans le dossier interne de l'application.
  /// Si une ancienne photo existe, elle est supprimée pour éviter d'accumuler
  /// des fichiers inutiles.
  Future<String?> saveProfileImage({
    required String email,
    required String sourcePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final oldPath = prefs.getString(_keyForUser(email));

    if (oldPath != null && oldPath.isNotEmpty) {
      final oldFile = File(oldPath);

      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    }

    final appDirectory = await getApplicationDocumentsDirectory();
    final profileDirectory = Directory('${appDirectory.path}/profile_images');

    if (!await profileDirectory.exists()) {
      await profileDirectory.create(recursive: true);
    }

    final extension = sourcePath.contains('.')
        ? sourcePath.split('.').last
        : 'jpg';

    final fileName =
        'profile_${_cleanEmail(email)}_${DateTime.now().millisecondsSinceEpoch}.$extension';

    final savedImagePath = '${profileDirectory.path}/$fileName';

    final savedFile = await File(sourcePath).copy(savedImagePath);

    await prefs.setString(
      _keyForUser(email),
      savedFile.path,
    );

    return savedFile.path;
  }

  /// Supprime la photo de profil de l'utilisateur.
  ///
  /// On supprime à la fois le fichier local et la clé sauvegardée.
  Future<void> removeProfileImage(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForUser(email);
    final path = prefs.getString(key);

    if (path != null && path.isNotEmpty) {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    }

    await prefs.remove(key);
  }
}