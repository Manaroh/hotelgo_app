import 'package:flutter/material.dart';

import '../controllers/favorite_controller.dart';
import '../models/hotel_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../widgets/hotel_card.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Page qui affiche les hôtels favoris de l'utilisateur connecté.
///
/// Les favoris sont récupérés depuis FavoriteController.
/// Chaque utilisateur possède sa propre liste de favoris.
class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final FavoriteController _favoriteController = FavoriteController();

  List<HotelModel> _favoriteHotels = [];
  List<int> _favoriteIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Chargement des favoris dès l'ouverture de la page.
    _loadFavorites();
  }

  /// Charge la liste des hôtels favoris.
  ///
  /// On récupère à la fois les objets HotelModel et leurs IDs.
  /// Les IDs servent surtout à afficher correctement l'état du bouton favori.
  Future<void> _loadFavorites() async {
    final hotels = await _favoriteController.getFavoriteHotels();
    final ids = await _favoriteController.getFavoriteIds();

    if (!mounted) return;

    setState(() {
      _favoriteHotels = hotels;
      _favoriteIds = ids;
      _isLoading = false;
    });
  }

  /// Retire un hôtel de la liste des favoris.
  ///
  /// Après la suppression, on recharge la liste pour mettre à jour l'interface.
  Future<void> _toggleFavorite(int hotelId) async {
    await _favoriteController.toggleFavorite(hotelId);
    await _loadFavorites();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hôtel retiré des favoris'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// Affichage utilisé lorsque l'utilisateur n'a encore aucun favori.
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppColors.primary,
                size: 52,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Aucun favori',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez des hôtels aux favoris pour les retrouver facilement ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes favoris'),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _favoriteHotels.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Carte de résumé en haut de la page.
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.white,
                              size: 38,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hôtels sauvegardés',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_favoriteHotels.length} hôtel(s) dans vos favoris',
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

                      // Affichage des hôtels favoris sous forme de cartes.
                      ..._favoriteHotels.map(
                        (hotel) => HotelCard(
                          hotel: hotel,
                          isFavorite: _favoriteIds.contains(hotel.id),
                          onFavoriteTap: () => _toggleFavorite(hotel.id),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.hotelDetails,
                              arguments: hotel,
                            ).then((_) => _loadFavorites());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}