import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/reservation_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/profile_image_controller.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/stat_chart_card.dart';

/// Page Profil de l'utilisateur.
///
/// Cette page regroupe les informations personnelles, les statistiques,
/// le dark mode, la photo de profil et les raccourcis vers les réservations
/// et les favoris.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController _authController = AuthController();
  final ReservationController _reservationController = ReservationController();
  final FavoriteController _favoriteController = FavoriteController();

  final ProfileImageController _profileImageController =
      ProfileImageController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _profileImagePath;
  bool _isPickingImage = false;

  UserModel? _currentUser;
  List<ReservationModel> _reservations = [];
  int _favoriteCount = 0;
  bool _isLoading = true;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    // Chargement de toutes les données nécessaires dès l'ouverture du profil.
    _loadProfileData();
  }

  /// Charge les données du profil.
  ///
  /// On récupère l'utilisateur connecté, ses réservations, ses favoris
  /// et sa photo de profil sauvegardée localement.
  Future<void> _loadProfileData() async {
    final user = await _authController.getCurrentUser();
    final reservations = await _reservationController.getAllReservations();
    final favoriteIds = await _favoriteController.getFavoriteIds();

    final profileImagePath = user == null
        ? null
        : await _profileImageController.getProfileImagePath(user.email);

    if (!mounted) return;

    setState(() {
      _currentUser = user;
      _reservations = reservations;
      _favoriteCount = favoriteIds.length;
      _profileImagePath = profileImagePath;
      _isLoading = false;
    });
  }

  /// Calcule le total dépensé par l'utilisateur.
  double _totalSpent() {
    return _reservations.fold(
      0,
      (sum, reservation) => sum + reservation.totalPrice,
    );
  }

  /// Calcule le nombre total de nuits réservées.
  int _totalNights() {
    return _reservations.fold<int>(
      0,
      (sum, reservation) => sum + reservation.nights,
    );
  }

  /// Retourne la dernière réservation affichée dans le profil.
  ReservationModel? _lastReservation() {
    if (_reservations.isEmpty) {
      return null;
    }

    return _reservations.first;
  }

  /// Formate une date ISO en format lisible.
  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);

    if (date == null) {
      return isoDate;
    }

    return _dateFormat.format(date);
  }

  /// Déconnecte l'utilisateur et revient à la page Welcome.
  Future<void> _logout() async {
    await _authController.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.welcome,
      (route) => false,
    );
  }

  /// Génère les initiales de l'utilisateur à partir de son nom complet.
  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  /// Couleur des cartes selon le thème clair ou sombre.
  Color _cardColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E293B) : AppColors.white;
  }

  /// Couleur des bordures selon le thème actuel.
  Color _borderColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF334155) : AppColors.border;
  }

  /// Couleur principale du texte selon le thème.
  Color _primaryTextColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : AppColors.textPrimary;
  }

  /// Couleur secondaire du texte selon le thème.
  Color _secondaryTextColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;
  }

  /// Prépare les données du graphique "Réservations par ville".
  Map<String, int> _reservationsByCity() {
    final Map<String, int> data = {};

    for (final reservation in _reservations) {
      data[reservation.city] = (data[reservation.city] ?? 0) + 1;
    }

    return data;
  }

  /// Prépare les données du graphique "Dépenses par type de chambre".
  Map<String, double> _spentByRoomType() {
    final Map<String, double> data = {};

    for (final reservation in _reservations) {
      data[reservation.roomType] =
          (data[reservation.roomType] ?? 0) + reservation.totalPrice;
    }

    return data;
  }

  /// Affichage utilisé lorsqu'il n'y a pas encore assez de données
  /// pour construire un graphique.
  Widget _emptyChart(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.insert_chart_outlined_rounded,
            color: AppColors.primary,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryTextColor(),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Élément de légende utilisé sous les graphiques.
  Widget _legendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label : $value',
            style: TextStyle(
              color: _secondaryTextColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Graphique en barres : nombre de réservations par ville.
  Widget _reservationsByCityChart() {
    final data = _reservationsByCity();

    if (data.isEmpty) {
      return _emptyChart(
        'Aucune donnée disponible. Ajoutez des réservations pour afficher les statistiques par ville.',
      );
    }

    final entries = data.entries.toList();

    final maxValue = entries.fold<int>(
      0,
      (max, entry) => entry.value > max ? entry.value : max,
    );

    final textColor = _secondaryTextColor();

    return Column(
      children: [
        SizedBox(
          height: 230,
          child: BarChart(
            BarChartData(
              maxY: maxValue.toDouble() + 1,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: _borderColor(),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) {
                        return const SizedBox.shrink();
                      }

                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      if (index < 0 || index >= entries.length) {
                        return const SizedBox.shrink();
                      }

                      final city = entries[index].key;
                      final shortCity =
                          city.length > 7 ? '${city.substring(0, 7)}.' : city;

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          shortCity,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(entries.length, (index) {
                final entry = entries[index];

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: AppColors.primary,
                      width: 20,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          children: entries.map((entry) {
            return _legendItem(
              color: AppColors.primary,
              label: entry.key,
              value: '${entry.value}',
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Graphique circulaire : dépenses par type de chambre.
  Widget _spentByRoomTypeChart() {
    final data = _spentByRoomType();

    if (data.isEmpty) {
      return _emptyChart(
        'Aucune dépense enregistrée. Les dépenses par type de chambre apparaîtront après réservation.',
      );
    }

    final entries = data.entries.toList();

    final total = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.value,
    );

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      Colors.purple,
    ];

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 45,
              sections: List.generate(entries.length, (index) {
                final entry = entries[index];
                final percent = total == 0 ? 0 : (entry.value / total) * 100;

                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: entry.value,
                  title: '${percent.toStringAsFixed(0)}%',
                  radius: 58,
                  titleStyle: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          children: List.generate(entries.length, (index) {
            final entry = entries[index];

            return _legendItem(
              color: colors[index % colors.length],
              label: entry.key,
              value: '${entry.value.toStringAsFixed(0)} DH',
            );
          }),
        ),
      ],
    );
  }

  /// Graphique circulaire qui compare réservations et favoris.
  Widget _summaryPieChart() {
    final reservationsCount = _reservations.length;
    final favoritesCount = _favoriteCount;

    if (reservationsCount == 0 && favoritesCount == 0) {
      return _emptyChart(
        'Aucune donnée à comparer. Ajoutez des favoris ou des réservations.',
      );
    }

    final total = reservationsCount + favoritesCount;

    final sections = [
      PieChartSectionData(
        color: AppColors.primary,
        value: reservationsCount.toDouble(),
        title: '${((reservationsCount / total) * 100).toStringAsFixed(0)}%',
        radius: 55,
        titleStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      PieChartSectionData(
        color: AppColors.accent,
        value: favoritesCount.toDouble(),
        title: '${((favoritesCount / total) * 100).toStringAsFixed(0)}%',
        radius: 55,
        titleStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 42,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          children: [
            _legendItem(
              color: AppColors.primary,
              label: 'Réservations',
              value: '$reservationsCount',
            ),
            _legendItem(
              color: AppColors.accent,
              label: 'Favoris',
              value: '$favoritesCount',
            ),
          ],
        ),
      ],
    );
  }

  /// Carte statistique utilisée dans le tableau de bord.
  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor(),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _borderColor()),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
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
            const SizedBox(height: 12),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryTextColor(),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryTextColor(),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carte qui affiche la dernière réservation de l'utilisateur.
  Widget _lastReservationCard() {
    final lastReservation = _lastReservation();

    if (lastReservation == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor(),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _borderColor()),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune réservation pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryTextColor(),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Vos prochaines réservations apparaîtront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryTextColor(),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor(),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor()),
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
          Text(
            'Dernière réservation',
            style: TextStyle(
              color: _primaryTextColor(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
                      lastReservation.hotelName,
                      style: TextStyle(
                        color: _primaryTextColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(lastReservation.checkInDate)} → ${_formatDate(lastReservation.checkOutDate)}',
                      style: TextStyle(
                        color: _secondaryTextColor(),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            height: 28,
            color: _borderColor(),
          ),
          Row(
            children: [
              Text(
                '${lastReservation.nights} nuit(s)',
                style: TextStyle(
                  color: _secondaryTextColor(),
                ),
              ),
              const Spacer(),
              Text(
                '${lastReservation.totalPrice.toStringAsFixed(0)} DH',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Carte permettant d'activer ou désactiver le mode sombre.
  Widget _darkModeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor()),
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.dark_mode_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode sombre',
                  style: TextStyle(
                    color: _primaryTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Changer l’apparence de l’application',
                  style: TextStyle(
                    color: _secondaryTextColor(),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: ThemeController.instance.isDarkMode,
            activeColor: AppColors.primary,
            onChanged: (value) async {
              await ThemeController.instance.toggleTheme(value);

              if (!mounted) return;

              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  /// Choisit une image de profil depuis la galerie ou la caméra.
  Future<void> _pickProfileImage(ImageSource source) async {
    final user = _currentUser;

    if (user == null) {
      return;
    }

    Navigator.pop(context);

    setState(() {
      _isPickingImage = true;
    });

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 900,
      );

      if (pickedImage == null) {
        if (!mounted) return;

        setState(() {
          _isPickingImage = false;
        });

        return;
      }

      final savedPath = await _profileImageController.saveProfileImage(
        email: user.email,
        sourcePath: pickedImage.path,
      );

      if (!mounted) return;

      setState(() {
        _profileImagePath = savedPath;
        _isPickingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de charger l’image'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Supprime la photo de profil de l'utilisateur connecté.
  Future<void> _removeProfileImage() async {
    final user = _currentUser;

    if (user == null) {
      return;
    }

    Navigator.pop(context);

    await _profileImageController.removeProfileImage(user.email);

    if (!mounted) return;

    setState(() {
      _profileImagePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo de profil supprimée'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// Ouvre le menu contenant les options de photo de profil.
  void _openProfileImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'Photo de profil',
                  style: TextStyle(
                    color: _primaryTextColor(),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.white,
                    ),
                  ),
                  title: Text(
                    'Choisir depuis la galerie',
                    style: TextStyle(
                      color: _primaryTextColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _pickProfileImage(ImageSource.gallery),
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.white,
                    ),
                  ),
                  title: Text(
                    'Prendre une photo',
                    style: TextStyle(
                      color: _primaryTextColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _pickProfileImage(ImageSource.camera),
                ),

                if (_profileImagePath != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.error,
                      child: Icon(
                        Icons.delete_rounded,
                        color: AppColors.white,
                      ),
                    ),
                    title: const Text(
                      'Supprimer la photo',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: _removeProfileImage,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Avatar du profil.
  ///
  /// Si une image existe, elle est affichée.
  /// Sinon, on affiche les initiales de l'utilisateur.
  Widget _profileAvatar(String userName) {
    final hasImage = _profileImagePath != null &&
        _profileImagePath!.isNotEmpty &&
        File(_profileImagePath!).existsSync();

    return GestureDetector(
      onTap: _isPickingImage ? null : _openProfileImageOptions,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.white,
            backgroundImage:
                hasImage ? FileImage(File(_profileImagePath!)) : null,
            child: hasImage
                ? null
                : Text(
                    _initials(userName),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 3,
                ),
              ),
              child: _isPickingImage
                  ? const Padding(
                      padding: EdgeInsets.all(7),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.white,
                      size: 17,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = _currentUser?.fullName ?? 'Utilisateur';
    final userEmail = _currentUser?.email ?? 'email@example.com';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadProfileData,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _profileAvatar(userName),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          userEmail,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tableau de bord',
                    style: TextStyle(
                      color: _primaryTextColor(),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _statCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'Réservations',
                        value: '${_reservations.length}',
                      ),
                      const SizedBox(width: 12),
                      _statCard(
                        icon: Icons.favorite_rounded,
                        title: 'Favoris',
                        value: '$_favoriteCount',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _statCard(
                        icon: Icons.payments_rounded,
                        title: 'Total dépensé',
                        value: '${_totalSpent().toStringAsFixed(0)} DH',
                      ),
                      const SizedBox(width: 12),
                      _statCard(
                        icon: Icons.hotel_rounded,
                        title: 'Nuits réservées',
                        value: '${_totalNights()}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Text(
                    'Analyse statistique',
                    style: TextStyle(
                      color: _primaryTextColor(),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  StatChartCard(
                    title: 'Réservations par ville',
                    icon: Icons.location_city_rounded,
                    child: _reservationsByCityChart(),
                  ),

                  StatChartCard(
                    title: 'Dépenses par type de chambre',
                    icon: Icons.pie_chart_rounded,
                    child: _spentByRoomTypeChart(),
                  ),

                  StatChartCard(
                    title: 'Réservations vs Favoris',
                    icon: Icons.donut_large_rounded,
                    child: _summaryPieChart(),
                  ),

                  const SizedBox(height: 8),

                  _lastReservationCard(),

                  const SizedBox(height: 26),

                  _darkModeCard(),

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.reservations);
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Voir mes réservations'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.favorites);
                      },
                      icon: const Icon(Icons.favorite_rounded),
                      label: const Text('Voir mes favoris'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Déconnexion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}