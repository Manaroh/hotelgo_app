import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/reservation_controller.dart';
import '../models/reservation_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Page qui affiche l'historique des réservations de l'utilisateur connecté.
///
/// Cette page permet aussi de modifier ou supprimer une réservation.
/// Les données affichées viennent du ReservationController, donc elles sont
/// déjà filtrées par utilisateur connecté.
class ReservationsView extends StatefulWidget {
  const ReservationsView({super.key});

  @override
  State<ReservationsView> createState() => _ReservationsViewState();
}

class _ReservationsViewState extends State<ReservationsView> {
  final ReservationController _reservationController =
      ReservationController();

  List<ReservationModel> _reservations = [];
  bool _isLoading = true;

  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  /// Charge les réservations de l'utilisateur connecté.
  ///
  /// Le contrôleur récupère seulement les réservations liées au compte actuel.
  Future<void> _loadReservations() async {
    final reservations = await _reservationController.getAllReservations();

    if (!mounted) return;

    setState(() {
      _reservations = reservations;
      _isLoading = false;
    });
  }

  /// Supprime une réservation après confirmation.
  ///
  /// Avant de supprimer, j'affiche une boîte de dialogue pour éviter
  /// une suppression accidentelle.
  Future<void> _deleteReservation(ReservationModel reservation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la réservation'),
          content: Text(
            'Voulez-vous vraiment supprimer la réservation de ${reservation.hotelName} ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm != true || reservation.id == null) return;

    await _reservationController.deleteReservation(reservation.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Réservation supprimée'),
        backgroundColor: AppColors.success,
      ),
    );

    _loadReservations();
  }

  /// Convertit une date ISO en format plus lisible pour l'utilisateur.
  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);

    if (date == null) {
      return isoDate;
    }

    return _displayDateFormat.format(date);
  }

  /// Affichage utilisé lorsqu'il n'y a aucune réservation.
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune réservation',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Réservez un hôtel pour afficher votre historique ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.search_rounded),
              label: const Text('Explorer les hôtels'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carte qui affiche les informations d'une réservation.
  ///
  /// Elle contient aussi les actions Modifier et Supprimer.
  Widget _reservationCard(ReservationModel reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.hotelName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reservation.city,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _infoItem(
                  icon: Icons.login_rounded,
                  title: 'Arrivée',
                  value: _formatDate(reservation.checkInDate),
                ),
              ),
              Expanded(
                child: _infoItem(
                  icon: Icons.logout_rounded,
                  title: 'Départ',
                  value: _formatDate(reservation.checkOutDate),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _infoItem(
                  icon: Icons.groups_rounded,
                  title: 'Personnes',
                  value: '${reservation.guests}',
                ),
              ),
              Expanded(
                child: _infoItem(
                  icon: Icons.bed_rounded,
                  title: 'Chambre',
                  value: reservation.roomType,
                ),
              ),
            ],
          ),

          const Divider(height: 28),

          Row(
            children: [
              Text(
                '${reservation.nights} nuit(s)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${reservation.totalPrice.toStringAsFixed(0)} DH',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.booking,
                      arguments: reservation,
                    ).then((_) => _loadReservations());
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Modifier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteReservation(reservation),
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Supprimer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Petit bloc d'information utilisé dans une carte de réservation.
  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Calcule le montant total dépensé dans toutes les réservations.
  double _totalAmount() {
    return _reservations.fold(
      0,
      (sum, reservation) => sum + reservation.totalPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes réservations'),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _reservations.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _loadReservations,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.analytics_rounded,
                              color: AppColors.white,
                              size: 38,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Résumé',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_reservations.length} réservation(s) • ${_totalAmount().toStringAsFixed(0)} DH',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._reservations.map(_reservationCard),
                    ],
                  ),
                ),
    );
  }
}