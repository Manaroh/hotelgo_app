import 'package:flutter/material.dart';

/// Palette principale de l'application HotelGo.
/// 
/// J'ai regroupé les couleurs ici pour garder un design cohérent
/// dans toutes les pages de l'application.
class AppColors {
  // Couleurs principales utilisées pour l'identité visuelle de l'application.
  static const Color primary = Color(0xFF0B3D91);
  static const Color secondary = Color(0xFF1E88E5);
  static const Color accent = Color(0xFFFFB300);

  // Couleurs générales de fond et de base.
  static const Color background = Color(0xFFF7F9FC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);

  // Couleurs utilisées pour les textes.
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Couleurs pour les messages de succès et d'erreur.
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  // Couleurs utilisées dans les cartes, bordures et conteneurs.
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
}