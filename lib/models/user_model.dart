/// Modèle qui représente un utilisateur de l'application.
///
/// Ce modèle est utilisé pour sauvegarder et récupérer les informations
/// d'un compte utilisateur localement.
class UserModel {
  final String fullName;
  final String email;
  final String password;

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
  });

  /// Convertit l'objet UserModel en Map.
  ///
  /// Cette méthode est utile pour enregistrer les informations de l'utilisateur
  /// dans le stockage local sous forme de données simples.
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }

  /// Reconstruit un utilisateur à partir d'une Map.
  ///
  /// Les valeurs par défaut évitent les erreurs si une donnée est absente
  /// dans le stockage local.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}