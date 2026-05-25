import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/hotel_controller.dart';
import '../controllers/favorite_controller.dart';
import '../models/hotel_model.dart';
import '../models/user_model.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../widgets/hotel_card.dart';
import '../widgets/app_bottom_nav_bar.dart';

import 'hotel_details_view.dart';

/// Page principale de l'application après connexion.
///
/// Elle affiche les hôtels disponibles, la recherche, les filtres,
/// les favoris, la géolocalisation et l'accès à la page API REST.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthController _authController = AuthController();
  final HotelController _hotelController = HotelController();
  final FavoriteController _favoriteController = FavoriteController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _destinationScrollController = ScrollController();
  final LocationService _locationService = LocationService.instance;

  UserModel? _currentUser;
  List<HotelModel> _hotels = [];
  final Set<int> _favoriteHotelIds = {};

  int? _selectedStars;
  double? _selectedMaxPrice;
  String? _selectedCity;

  bool _showHotelList = true;
  int _listAnimationKey = 0;

  bool _isLocating = false;
  bool _sortedByDistance = false;
  double? _userLatitude;
  double? _userLongitude;
  final Map<int, double> _hotelDistancesKm = {};

  @override
  void initState() {
    super.initState();

    // Au chargement de l'accueil, on récupère l'utilisateur connecté,
    // la liste complète des hôtels et les favoris sauvegardés.
    _loadUser();
    _hotels = _hotelController.getAllHotels();
    _loadFavorites();
  }

  /// Charge l'utilisateur actuellement connecté.
  ///
  /// Son nom est utilisé pour personnaliser le message de bienvenue.
  Future<void> _loadUser() async {
    final user = await _authController.getCurrentUser();

    if (!mounted) return;

    setState(() {
      _currentUser = user;
    });
  }

  /// Charge les hôtels favoris de l'utilisateur connecté.
  ///
  /// Les IDs sont stockés dans un Set pour vérifier rapidement
  /// si un hôtel est favori ou non.
  Future<void> _loadFavorites() async {
    final favoriteIds = await _favoriteController.getFavoriteIds();

    if (!mounted) return;

    setState(() {
      _favoriteHotelIds
        ..clear()
        ..addAll(favoriteIds);
    });
  }

  /// Calcule la distance entre la position de l'utilisateur et chaque hôtel.
  ///
  /// Les résultats sont stockés dans _hotelDistancesKm pour pouvoir
  /// les afficher dans les badges et trier la liste.
  void _calculateDistances(List<HotelModel> hotels) {
    _hotelDistancesKm.clear();

    if (_userLatitude == null || _userLongitude == null) {
      return;
    }

    for (final hotel in hotels) {
      final distance = _locationService.distanceToHotelInKm(
        hotelId: hotel.id,
        userLatitude: _userLatitude!,
        userLongitude: _userLongitude!,
      );

      if (distance != null) {
        _hotelDistancesKm[hotel.id] = distance;
      }
    }
  }

  /// Trie les hôtels du plus proche au plus loin.
  ///
  /// Si un hôtel n'a pas de distance disponible, il est placé à la fin.
  void _sortBySavedDistance(List<HotelModel> hotels) {
    hotels.sort((a, b) {
      final distanceA = _hotelDistancesKm[a.id] ?? double.infinity;
      final distanceB = _hotelDistancesKm[b.id] ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });
  }

  /// Applique la recherche et les filtres sélectionnés.
  ///
  /// Cette méthode est utilisée quand l'utilisateur écrit dans la recherche,
  /// choisit une ville, sélectionne un nombre d'étoiles ou un prix maximum.
  Future<void> _applyFilters() async {
    setState(() {
      _showHotelList = false;
    });

    await Future.delayed(const Duration(milliseconds: 180));

    final results = _hotelController.searchAndFilterHotels(
      query: _searchController.text,
      stars: _selectedStars,
      maxPrice: _selectedMaxPrice,
      city: _selectedCity,
    );

    // Si la géolocalisation est active, on garde aussi le tri par distance
    // après chaque recherche ou changement de filtre.
    if (_userLatitude != null && _userLongitude != null) {
      _calculateDistances(results);
      _sortBySavedDistance(results);
    }

    if (!mounted) return;

    setState(() {
      _hotels = results;
      _listAnimationKey++;
      _showHotelList = true;
    });
  }

  /// Réinitialise tous les filtres.
  ///
  /// Cette méthode remet aussi la liste en mode normal, sans tri par distance.
  Future<void> _resetFilters() async {
    setState(() {
      _showHotelList = false;
    });

    await Future.delayed(const Duration(milliseconds: 180));

    if (!mounted) return;

    setState(() {
      _searchController.clear();
      _selectedStars = null;
      _selectedMaxPrice = null;
      _selectedCity = null;
      _sortedByDistance = false;
      _userLatitude = null;
      _userLongitude = null;
      _hotelDistancesKm.clear();
      _hotels = _hotelController.getAllHotels();
      _listAnimationKey++;
      _showHotelList = true;
    });
  }

  /// Récupère la position de l'utilisateur et trie les hôtels autour de lui.
  ///
  /// Cette méthode demande les permissions GPS si nécessaire,
  /// puis calcule les distances et trie les hôtels.
  Future<void> _sortHotelsAroundMe() async {
    setState(() {
      _isLocating = true;
      _showHotelList = false;
    });

    try {
      final position = await _locationService.getCurrentPosition();

      final filteredHotels = _hotelController.searchAndFilterHotels(
        query: _searchController.text,
        stars: _selectedStars,
        maxPrice: _selectedMaxPrice,
        city: _selectedCity,
      );

      _userLatitude = position.latitude;
      _userLongitude = position.longitude;

      _calculateDistances(filteredHotels);
      _sortBySavedDistance(filteredHotels);

      if (!mounted) return;

      setState(() {
        _hotels = filteredHotels;
        _sortedByDistance = true;
        _isLocating = false;
        _showHotelList = true;
        _listAnimationKey++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hôtels triés selon votre position'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLocating = false;
        _showHotelList = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Annule le tri par distance et revient à l'affichage filtré normal.
  void _clearDistanceSorting() {
    setState(() {
      _sortedByDistance = false;
      _userLatitude = null;
      _userLongitude = null;
      _hotelDistancesKm.clear();
      _listAnimationKey++;
    });

    _applyFilters();
  }

  /// Formate la distance pour l'affichage.
  ///
  /// Si la distance est inférieure à 1 km, elle est affichée en mètres.
  String _formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }

    return '${distance.toStringAsFixed(1)} km';
  }

  /// Ajoute ou retire un hôtel des favoris.
  ///
  /// Après la modification, on recharge les favoris pour mettre à jour
  /// l'interface immédiatement.
  Future<void> _toggleFavorite(int hotelId) async {
    await _favoriteController.toggleFavorite(hotelId);
    await _loadFavorites();

    if (!mounted) return;

    final isFavorite = _favoriteHotelIds.contains(hotelId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Hôtel ajouté aux favoris'
              : 'Hôtel retiré des favoris',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// Déconnecte l'utilisateur et retourne vers la page de choix de compte.
  Future<void> _logout() async {
    await _authController.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.accountPicker,
      (route) => false,
    );
  }

  /// Ouvre la page détails d'un hôtel avec une transition personnalisée.
  ///
  /// La transition combine fade, slide et scale pour donner un rendu
  /// plus fluide et professionnel.
  void _openHotelDetails(HotelModel hotel) {
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        settings: RouteSettings(
          name: AppRoutes.hotelDetails,
          arguments: hotel,
        ),
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const HotelDetailsView();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.12, 0.08),
            end: Offset.zero,
          ).animate(curvedAnimation);

          final scaleAnimation = Tween<double>(
            begin: 0.96,
            end: 1.0,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          );
        },
      ),
    )
        .then((_) {
      // Quand on revient de la page détails, on recharge les favoris
      // au cas où l'utilisateur les a modifiés.
      _loadFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _destinationScrollController.dispose();
    super.dispose();
  }

  /// Construit un chip de ville pour la section Destinations populaires.
  Widget _buildCityChip(String label, String? city) {
    final selected = _selectedCity == city;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) {
          setState(() {
            _selectedCity = city;
          });

          _applyFilters();
        },
        avatar: Icon(
          city == null ? Icons.public_rounded : Icons.location_city_rounded,
          size: 18,
          color: selected ? AppColors.white : AppColors.primary,
        ),
        label: Text(label),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.white,
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }

  /// Construit un chip de filtre rapide.
  ///
  /// Il est utilisé pour les étoiles et les filtres de prix.
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    required IconData icon,
  }) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? AppColors.white : AppColors.primary,
      ),
      label: Text(label),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.white,
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  /// Carte permettant d'activer ou d'annuler le tri par géolocalisation.
  Widget _locationFilterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _sortedByDistance ? AppColors.primary : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _sortedByDistance
                  ? 'Hôtels triés par distance'
                  : 'Trouvez les hôtels les plus proches de vous',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (_sortedByDistance)
            IconButton(
              onPressed: _clearDistanceSorting,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.error,
              ),
              tooltip: 'Annuler le tri',
            )
          else
            ElevatedButton(
              onPressed: _isLocating ? null : _sortHotelsAroundMe,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Autour'),
            ),
        ],
      ),
    );
  }

  /// Badge affichant la distance entre l'utilisateur et l'hôtel.
  Widget _distanceBadge(HotelModel hotel) {
    final distance = _hotelDistancesKm[hotel.id];

    if (distance == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.near_me_rounded,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(
              'À ${_formatDistance(distance)} de vous',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carte hôtel animée.
  ///
  /// Chaque carte apparaît avec un petit effet de montée et de zoom.
  Widget _animatedHotelCard({
    required HotelModel hotel,
    required int index,
  }) {
    final animationDuration = 380 + (index * 95);
    final safeDuration = animationDuration > 850 ? 850 : animationDuration;

    return TweenAnimationBuilder<double>(
      key: ValueKey(
        'hotel-${hotel.id}-${_selectedCity ?? 'all'}-${_selectedStars ?? 'all'}-${_selectedMaxPrice ?? 'all'}-${_searchController.text}-${_sortedByDistance ? 'distance' : 'normal'}',
      ),
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ),
      duration: Duration(milliseconds: safeDuration),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final safeOpacity = value.clamp(0.0, 1.0);

        return Opacity(
          opacity: safeOpacity,
          child: Transform.translate(
            offset: Offset(0, 45 * (1 - value)),
            child: Transform.scale(
              scale: 0.94 + (0.06 * value),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _distanceBadge(hotel),
          HotelCard(
            hotel: hotel,
            isFavorite: _favoriteHotelIds.contains(hotel.id),
            onFavoriteTap: () => _toggleFavorite(hotel.id),
            onTap: () {
              _openHotelDetails(hotel);
            },
          ),
        ],
      ),
    );
  }

  /// Section qui affiche la liste des hôtels avec animation.
  ///
  /// Elle gère aussi l'état de chargement et le cas où aucun hôtel
  /// ne correspond aux filtres.
  Widget _hotelListSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation);

        final scaleAnimation = Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
      child: !_showHotelList
          ? Container(
              key: const ValueKey('loading-hotels-animation'),
              height: 220,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _hotels.isEmpty
              ? Container(
                  key: ValueKey('empty-hotels-$_listAnimationKey'),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        color: AppColors.primary,
                        size: 60,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Aucun hôtel trouvé',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Essayez une autre ville ou modifiez les filtres.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  key: ValueKey('hotel-list-$_listAnimationKey'),
                  children: _hotels.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final hotel = entry.value;

                      return _animatedHotelCard(
                        hotel: hotel,
                        index: index,
                      );
                    },
                  ).toList(),
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = _currentUser?.fullName ?? 'Utilisateur';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('HotelGo'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Déconnexion',
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Bonjour, $userName',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              'Votre prochain séjour commence ici.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _applyFilters(),
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                  ),
                  hintText: 'Rechercher par ville ou hôtel...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 22),

            _locationFilterCard(),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.apiExplore);
                },
                icon: const Icon(Icons.cloud_sync_rounded),
                label: const Text('Explorer via API REST'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Destinations populaires',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Scrollbar(
              controller: _destinationScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              thickness: 4,
              radius: const Radius.circular(20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  controller: _destinationScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCityChip('Tous', null),
                      _buildCityChip('Tanger', 'Tanger'),
                      _buildCityChip('Casablanca', 'Casablanca'),
                      _buildCityChip('Marrakech', 'Marrakech'),
                      _buildCityChip('Rabat', 'Rabat'),
                      _buildCityChip('Agadir', 'Agadir'),
                      _buildCityChip('Fès', 'Fès'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Filtres rapides',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildFilterChip(
                  label: 'Tous',
                  selected: _selectedStars == null &&
                      _selectedMaxPrice == null &&
                      _selectedCity == null &&
                      !_sortedByDistance,
                  icon: Icons.apps_rounded,
                  onSelected: _resetFilters,
                ),
                _buildFilterChip(
                  label: '3 étoiles',
                  selected: _selectedStars == 3,
                  icon: Icons.star_rounded,
                  onSelected: () {
                    setState(() {
                      _selectedStars = 3;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: '4 étoiles',
                  selected: _selectedStars == 4,
                  icon: Icons.star_rounded,
                  onSelected: () {
                    setState(() {
                      _selectedStars = 4;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: '5 étoiles',
                  selected: _selectedStars == 5,
                  icon: Icons.star_rounded,
                  onSelected: () {
                    setState(() {
                      _selectedStars = 5;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: '≤ 600 DH',
                  selected: _selectedMaxPrice == 600,
                  icon: Icons.payments_rounded,
                  onSelected: () {
                    setState(() {
                      _selectedMaxPrice = 600;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: '≤ 1000 DH',
                  selected: _selectedMaxPrice == 1000,
                  icon: Icons.payments_rounded,
                  onSelected: () {
                    setState(() {
                      _selectedMaxPrice = 1000;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: '≤ 1500 DH',
                  selected: _selectedMaxPrice == 1500,
                  icon: Icons.payments_rounded,
                  onSelected: () {
                    setState(() {
                      _selectedMaxPrice = 1500;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),

            const SizedBox(height: 26),

            Row(
              children: [
                const Text(
                  'Hôtels disponibles',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_hotels.length} résultat(s)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _hotelListSection(),
          ],
        ),
      ),
    );
  }
}