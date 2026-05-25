/// Modèle qui représente un avis client sur un hôtel.
///
/// Chaque avis est lié à un hôtel et à un utilisateur.
/// Il contient une note, un commentaire et une date de création.
class ReviewModel {
  final String id;
  final int hotelId;
  final String userEmail;
  final String userName;
  final double rating;
  final String comment;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.hotelId,
    required this.userEmail,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Convertit un avis en Map.
  ///
  /// Cette méthode permet de sauvegarder les avis localement,
  /// par exemple dans SharedPreferences sous forme JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelId': hotelId,
      'userEmail': userEmail,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  /// Reconstruit un avis à partir d'une Map.
  ///
  /// Le cast de rating en double permet d'éviter les problèmes
  /// lorsque la valeur est lue comme int ou double.
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      hotelId: json['hotelId'] ?? 0,
      userEmail: json['userEmail'] ?? '',
      userName: json['userName'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}