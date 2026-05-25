import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Carte utilisée pour afficher les graphiques dans la page Profil.
///
/// Elle reçoit un titre, une icône et un widget enfant.
/// Le widget enfant peut être un graphique en barres, un graphique circulaire
/// ou un message indiquant qu'il n'y a pas encore de données.
class StatChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const StatChartCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Les couleurs sont adaptées selon le thème actuel.
    final cardColor = isDark ? const Color(0xFF1E293B) : AppColors.white;
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte : icône + titre du graphique.
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Contenu du graphique envoyé depuis ProfileView.
          child,
        ],
      ),
    );
  }
}