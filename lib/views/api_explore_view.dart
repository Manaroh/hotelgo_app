import 'package:flutter/material.dart';

import '../models/api_place_model.dart';
import '../services/api_place_service.dart';
import '../utils/app_colors.dart';

/// Page dédiée à l'exploration des hôtels depuis une API REST externe.
///
/// Cette page récupère des hôtels par ville via ApiPlaceService.
/// Elle permet aussi de montrer que l'application sait consommer
/// des données externes et les afficher dans une interface Flutter.
class ApiExploreView extends StatefulWidget {
  const ApiExploreView({super.key});

  @override
  State<ApiExploreView> createState() => _ApiExploreViewState();
}

class _ApiExploreViewState extends State<ApiExploreView> {
  final ApiPlaceService _apiPlaceService = ApiPlaceService();
  final ScrollController _cityScrollController = ScrollController();

  /// Liste des villes disponibles dans l'interface API.
  final List<String> _cities = [
    'Tanger',
    'Casablanca',
    'Marrakech',
    'Rabat',
    'Agadir',
    'Fès',
  ];

  /// Images utilisées pour rendre les cartes API plus visuelles.
  ///
  /// Les résultats API ne contiennent pas toujours des images,
  /// donc j'associe des images par ville pour garder un affichage propre.
  final Map<String, List<String>> _cityImages = {
    'Tanger': [
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80',
    ],
    'Casablanca': [
      'https://images.unsplash.com/photo-1577147443647-81856d5151af?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80',
    ],
    'Marrakech': [
      'https://images.unsplash.com/photo-1597212618440-806262de4f6b?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=1200&q=80',
    ],
    'Rabat': [
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80',
    ],
    'Agadir': [
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=1200&q=80',
    ],
    'Fès': [
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1548013146-72479768bada?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=1200&q=80',
    ],
  };

  String _selectedCity = 'Tanger';
  bool _isLoading = false;
  List<ApiPlaceModel> _places = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Chargement automatique des hôtels de la ville sélectionnée par défaut.
    _loadPlaces();
  }

  @override
  void dispose() {
    _cityScrollController.dispose();
    super.dispose();
  }

  /// Charge les hôtels depuis l'API REST selon la ville sélectionnée.
  ///
  /// La méthode gère trois états :
  /// - chargement ;
  /// - résultats chargés ;
  /// - erreur éventuelle.
  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _places = [];
    });

    try {
      final results = await _apiPlaceService.searchHotelsByCity(_selectedCity);

      if (!mounted) return;

      setState(() {
        _places = results;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// Retourne l'image principale de la ville sélectionnée.
  String _currentCityImage() {
    final images = _cityImages[_selectedCity];

    if (images == null || images.isEmpty) {
      return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80';
    }

    return images.first;
  }

  /// Retourne une image pour une carte hôtel.
  ///
  /// Le modulo permet d'alterner les images si plusieurs hôtels sont affichés.
  String _imageForPlace(int index) {
    final images = _cityImages[_selectedCity];

    if (images == null || images.isEmpty) {
      return _currentCityImage();
    }

    return images[index % images.length];
  }

  /// Chip de sélection d'une ville.
  ///
  /// Quand l'utilisateur choisit une ville, on relance l'appel API.
  Widget _cityChip(String city) {
    final bool selected = _selectedCity == city;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: selected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.white,
        label: Text(city),
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        avatar: Icon(
          Icons.location_city_rounded,
          size: 18,
          color: selected ? AppColors.white : AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        onSelected: (_) {
          setState(() {
            _selectedCity = city;
          });

          _loadPlaces();
        },
      ),
    );
  }

  /// Carte d'en-tête qui explique le rôle de la page API REST.
  Widget _headerCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            child: Image.network(
              _currentCityImage(),
              width: double.infinity,
              height: 155,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 155,
                  color: AppColors.primary,
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    color: AppColors.white,
                    size: 60,
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.cloud_sync_rounded,
                  color: AppColors.white,
                  size: 42,
                ),
                SizedBox(height: 14),
                Text(
                  'Hôtels depuis une API REST externe',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cette page récupère des hôtels depuis une API REST externe et complète l’affichage lorsque les données publiques sont insuffisantes.',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Petit badge utilisé pour afficher le type, la ville ou les coordonnées.
  Widget _smallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Carte affichant un hôtel récupéré depuis l'API.
  Widget _placeCard(ApiPlaceModel place, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
            child: Stack(
              children: [
                Image.network(
                  _imageForPlace(index),
                  width: double.infinity,
                  height: 135,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 135,
                      color: AppColors.primary,
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        color: AppColors.white,
                        size: 42,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.public_rounded,
                          color: AppColors.white,
                          size: 15,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'API REST',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        place.displayName,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _smallBadge(place.category),
                          _smallBadge(place.type),
                          _smallBadge(place.city),
                          _smallBadge(
                            '${place.latitude.toStringAsFixed(3)}, ${place.longitude.toStringAsFixed(3)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Contenu principal selon l'état actuel :
  /// chargement, erreur, liste vide ou résultats API.
  Widget _bodyContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 54,
            ),
            const SizedBox(height: 14),
            const Text(
              'Impossible de charger les données API',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPlaces,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_places.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppColors.primary,
              size: 54,
            ),
            SizedBox(height: 14),
            Text(
              'Aucun résultat disponible',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: Column(
        key: ValueKey(_selectedCity),
        children: _places.asMap().entries.map((entry) {
          return _placeCard(entry.value, entry.key);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explorer API REST'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadPlaces,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _headerCard(),
              const SizedBox(height: 24),
              const Text(
                'Choisir une ville',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Scrollbar(
                controller: _cityScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                thickness: 4,
                radius: const Radius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SingleChildScrollView(
                    controller: _cityScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _cities.map((city) => _cityChip(city)).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text(
                    'Résultats API',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_places.length} hôtel(s)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _bodyContent(),
            ],
          ),
        ),
      ),
    );
  }
}