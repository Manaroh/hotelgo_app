import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/review_model.dart';
import 'auth_controller.dart';

/// Contrôleur responsable des avis clients.
///
/// Les avis sont stockés localement sous forme JSON dans SharedPreferences.
/// Chaque avis est lié à un hôtel et à un utilisateur.
class ReviewController {
  static const String _keyReviews = 'hotelReviews';

  final AuthController _authController = AuthController();

  /// Récupère tous les avis sauvegardés localement.
  ///
  /// Si aucune donnée n'existe encore, on retourne simplement une liste vide.
  Future<List<ReviewModel>> _getAllReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final rawReviews = prefs.getString(_keyReviews);

    if (rawReviews == null || rawReviews.isEmpty) {
      return [];
    }

    try {
      final decodedReviews = jsonDecode(rawReviews);

      if (decodedReviews is! List) {
        return [];
      }

      return decodedReviews.map<ReviewModel>((item) {
        return ReviewModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    } catch (_) {
      // Si les données stockées sont corrompues, on évite de bloquer l'application.
      return [];
    }
  }

  /// Sauvegarde tous les avis après conversion en JSON.
  Future<void> _saveAllReviews(List<ReviewModel> reviews) async {
    final prefs = await SharedPreferences.getInstance();

    final encodedReviews = jsonEncode(
      reviews.map((review) => review.toJson()).toList(),
    );

    await prefs.setString(_keyReviews, encodedReviews);
  }

  /// Récupère les avis d'un hôtel précis.
  ///
  /// Les avis les plus récents sont affichés en premier.
  Future<List<ReviewModel>> getReviewsByHotel(int hotelId) async {
    final reviews = await _getAllReviews();

    final hotelReviews = reviews.where((review) {
      return review.hotelId == hotelId;
    }).toList();

    hotelReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return hotelReviews;
  }

  /// Ajoute ou met à jour l'avis de l'utilisateur connecté.
  ///
  /// Un utilisateur ne garde qu'un seul avis par hôtel.
  /// Si l'utilisateur ajoute un nouvel avis sur le même hôtel,
  /// l'ancien est remplacé.
  Future<String?> addOrUpdateReview({
    required int hotelId,
    required double rating,
    required String comment,
  }) async {
    final user = await _authController.getCurrentUser();

    if (user == null) {
      return 'Vous devez être connecté pour ajouter un avis';
    }

    final cleanComment = comment.trim();

    if (cleanComment.isEmpty) {
      return 'Le commentaire est obligatoire';
    }

    if (cleanComment.length < 5) {
      return 'Le commentaire doit contenir au moins 5 caractères';
    }

    final reviews = await _getAllReviews();
    final cleanEmail = user.email.trim().toLowerCase();

    // On retire l'ancien avis du même utilisateur pour le même hôtel,
    // afin de le remplacer par le nouveau.
    reviews.removeWhere((review) {
      return review.hotelId == hotelId &&
          review.userEmail.trim().toLowerCase() == cleanEmail;
    });

    final newReview = ReviewModel(
      id: '${cleanEmail}_$hotelId',
      hotelId: hotelId,
      userEmail: cleanEmail,
      userName: user.fullName,
      rating: rating,
      comment: cleanComment,
      createdAt: DateTime.now().toIso8601String(),
    );

    reviews.add(newReview);

    await _saveAllReviews(reviews);

    return null;
  }

  /// Calcule la note moyenne affichée dans la page détails.
  ///
  /// Si aucun avis utilisateur n'existe, on garde la note de base de l'hôtel.
  double calculateAverageRating({
    required double hotelBaseRating,
    required List<ReviewModel> reviews,
  }) {
    if (reviews.isEmpty) {
      return hotelBaseRating;
    }

    final total = reviews.fold<double>(
      0,
      (sum, review) => sum + review.rating,
    );

    return total / reviews.length;
  }
}