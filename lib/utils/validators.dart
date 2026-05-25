/// Classe utilisée pour valider les champs des formulaires.
/// 
/// Elle est utilisée principalement dans les pages Login et Register.
/// Le but est d'éviter les saisies incorrectes avant de sauvegarder
/// ou vérifier les données utilisateur.
class Validators {
  /// Vérifie le nom complet de l'utilisateur.
  /// 
  /// Le nom doit être obligatoire, contenir au moins 3 caractères,
  /// et ne doit pas contenir de chiffres ou de symboles inutiles.
  static String? validateName(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Le nom est obligatoire';
    }

    if (text.length < 3) {
      return 'Le nom doit contenir au moins 3 caractères';
    }

    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$").hasMatch(text)) {
      return 'Le nom ne doit contenir que des lettres';
    }

    return null;
  }

  /// Vérifie le format de l'adresse email.
  /// 
  /// J'ai ajouté une expression régulière pour accepter un format classique
  /// comme : nom@gmail.com.
  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'L’email est obligatoire';
    }

    if (email.contains(' ')) {
      return 'L’email ne doit pas contenir d’espace';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Veuillez entrer un email valide, ex: nom@gmail.com';
    }

    return null;
  }

  /// Vérifie le mot de passe.
  /// 
  /// Pour ce mini-projet, j'ai gardé une règle simple :
  /// le mot de passe doit contenir au moins 6 caractères.
  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }

    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    return null;
  }

  /// Vérifie que la confirmation correspond au mot de passe saisi.
  static String? validateConfirmPassword(String? value, String password) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'La confirmation est obligatoire';
    }

    if (confirmPassword != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }
}