import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';
import '../controllers/reservation_controller.dart';
import '../models/hotel_model.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../widgets/custom_button.dart';
import '../services/notification_service.dart';

/// Page de réservation.
/// Elle sert à créer une nouvelle réservation ou modifier une réservation existante.
class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthController _authController = AuthController();
  final ReservationController _reservationController =
      ReservationController();

  final TextEditingController _customerNameController =
      TextEditingController();
  final TextEditingController _guestsController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  String _roomType = 'Standard';
  bool _isLoading = false;

  HotelModel? _hotel;
  ReservationModel? _reservationToEdit;
  bool _didLoadArgs = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // On charge les arguments une seule fois pour ne pas remplir le formulaire plusieurs fois.
    if (_didLoadArgs) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    // Cas d'une nouvelle réservation depuis la page détails hôtel.
    if (args is HotelModel) {
      _hotel = args;
      _loadUserName();
    }

    // Cas de modification d'une réservation existante.
    if (args is ReservationModel) {
      _reservationToEdit = args;
      _fillFormForEdit(args);
    }

    _didLoadArgs = true;
  }

  /// Charge le nom de l'utilisateur connecté pour préremplir le champ client.
  Future<void> _loadUserName() async {
    final UserModel? user = await _authController.getCurrentUser();

    if (!mounted) return;

    if (user != null) {
      setState(() {
        _customerNameController.text = user.fullName;
      });
    }
  }

  /// Remplit le formulaire avec les informations d'une réservation à modifier.
  void _fillFormForEdit(ReservationModel reservation) {
    _customerNameController.text = reservation.customerName;
    _guestsController.text = reservation.guests.toString();
    _roomType = reservation.roomType;

    _checkInDate = DateTime.tryParse(reservation.checkInDate);
    _checkOutDate = DateTime.tryParse(reservation.checkOutDate);
  }

  /// Coefficient appliqué selon le type de chambre choisi.
  double _roomMultiplier() {
    if (_roomType == 'Deluxe') return 1.35;
    if (_roomType == 'Suite') return 1.75;
    return 1.0;
  }

  /// Calcule le nombre de nuits entre la date d'arrivée et la date de départ.
  int _calculateNights() {
    if (_checkInDate == null || _checkOutDate == null) {
      return 0;
    }

    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    return nights > 0 ? nights : 0;
  }

  /// Calcule le prix total selon le prix par nuit, le nombre de nuits et le type de chambre.
  double _calculateTotalPrice() {
    final nights = _calculateNights();

    if (_reservationToEdit != null) {
      return _reservationToEdit!.pricePerNight * nights * _roomMultiplier();
    }

    if (_hotel == null) {
      return 0;
    }

    return _hotel!.pricePerNight * nights * _roomMultiplier();
  }

  /// Ouvre le calendrier pour choisir la date d'arrivée ou de départ.
  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();

    final initialDate = isCheckIn
        ? (_checkInDate != null && _checkInDate!.isAfter(now)
            ? _checkInDate!
            : now)
        : (_checkOutDate != null && _checkOutDate!.isAfter(now)
            ? _checkOutDate!
            : now.add(const Duration(days: 1)));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: isCheckIn ? 'Date d’arrivée' : 'Date de départ',
      confirmText: 'Valider',
      cancelText: 'Annuler',
    );

    if (pickedDate == null) return;

    setState(() {
      if (isCheckIn) {
        _checkInDate = pickedDate;

        // Si la date de départ devient invalide, on la vide.
        if (_checkOutDate != null &&
            !_checkOutDate!.isAfter(_checkInDate!)) {
          _checkOutDate = null;
        }
      } else {
        _checkOutDate = pickedDate;
      }
    });
  }

  /// Validation du nombre de personnes.
  String? _validateGuests(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Le nombre de personnes est obligatoire';
    }

    final guests = int.tryParse(text);

    if (guests == null) {
      return 'Veuillez entrer un nombre valide';
    }

    if (guests <= 0) {
      return 'Le nombre de personnes doit être supérieur à 0';
    }

    if (guests > 8) {
      return 'Maximum 8 personnes par réservation';
    }

    return null;
  }

  /// Enregistre la réservation dans SQLite.
  /// Si on est en mode édition, la réservation est modifiée.
  /// Sinon, une nouvelle réservation est créée avec une notification.
  Future<void> _saveReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_checkInDate == null) {
      _showMessage('Veuillez choisir la date d’arrivée', AppColors.error);
      return;
    }

    if (_checkOutDate == null) {
      _showMessage('Veuillez choisir la date de départ', AppColors.error);
      return;
    }

    if (!_checkOutDate!.isAfter(_checkInDate!)) {
      _showMessage(
        'La date de départ doit être après la date d’arrivée',
        AppColors.error,
      );
      return;
    }

    if (_reservationToEdit == null && _hotel == null) {
      _showMessage(
        'Aucun hôtel sélectionné pour la réservation',
        AppColors.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isEdit = _reservationToEdit != null;

    final reservation = ReservationModel(
      id: _reservationToEdit?.id,
      userEmail: _reservationToEdit?.userEmail ?? '',
      hotelId: isEdit ? _reservationToEdit!.hotelId : _hotel!.id,
      hotelName: isEdit ? _reservationToEdit!.hotelName : _hotel!.name,
      city: isEdit ? _reservationToEdit!.city : _hotel!.city,
      pricePerNight:
          isEdit ? _reservationToEdit!.pricePerNight : _hotel!.pricePerNight,
      customerName: _customerNameController.text.trim(),
      checkInDate: _checkInDate!.toIso8601String(),
      checkOutDate: _checkOutDate!.toIso8601String(),
      guests: int.parse(_guestsController.text.trim()),
      roomType: _roomType,
      nights: _calculateNights(),
      totalPrice: _calculateTotalPrice(),
      createdAt: isEdit
          ? _reservationToEdit!.createdAt
          : DateTime.now().toIso8601String(),
    );

    if (isEdit) {
      await _reservationController.updateReservation(reservation);
    } else {
      await _reservationController.addReservation(reservation);

      await NotificationService.instance.showReservationNotification(
        hotelName: reservation.hotelName,
        city: reservation.city,
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    _showMessage(
      isEdit
          ? 'Réservation modifiée avec succès'
          : 'Réservation ajoutée avec succès',
      AppColors.success,
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.reservations,
      (route) => route.settings.name == AppRoutes.home,
    );
  }

  /// Affiche un message court en bas de l'écran.
  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  /// En-tête visuel de la page réservation.
  Widget _buildHotelHeader({
    required String hotelName,
    required String city,
    required double pricePerNight,
  }) {
    final imageUrl = _hotel?.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 205,
        width: double.infinity,
        color: AppColors.primary,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  return Container(
                    color: AppColors.primary,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _fallbackHotelHeader();
                },
              )
            else
              _fallbackHotelHeader(),

            // Dégradé pour rendre le texte visible sur l'image.
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.68),
                    Colors.black.withValues(alpha: 0.28),
                    Colors.black.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            Positioned(
              top: 18,
              left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.accent,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Réservation sécurisée',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.hotel_rounded,
                    color: AppColors.white,
                    size: 34,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hotelName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.white,
                        size: 17,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$city • ${pricePerNight.toStringAsFixed(0)} DH / nuit',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Affichage utilisé si l'image de l'hôtel ne se charge pas.
  Widget _fallbackHotelHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.apartment_rounded,
          color: AppColors.white,
          size: 76,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _reservationToEdit != null;

    final hotelName = isEdit
        ? _reservationToEdit!.hotelName
        : (_hotel?.name ?? 'Hôtel');

    final city = isEdit ? _reservationToEdit!.city : (_hotel?.city ?? '');

    final pricePerNight = isEdit
        ? _reservationToEdit!.pricePerNight
        : (_hotel?.pricePerNight ?? 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier réservation' : 'Nouvelle réservation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelHeader(
                  hotelName: hotelName,
                  city: city,
                  pricePerNight: pricePerNight,
                ),

                const SizedBox(height: 28),

                const Text(
                  'Informations de réservation',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _customerNameController,
                  decoration: _inputDecoration(
                    label: 'Nom du client',
                    icon: Icons.person_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est obligatoire';
                    }

                    if (value.trim().length < 3) {
                      return 'Le nom doit contenir au moins 3 caractères';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _guestsController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    label: 'Nombre de personnes',
                    icon: Icons.groups_rounded,
                  ),
                  validator: _validateGuests,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _roomType,
                  decoration: _inputDecoration(
                    label: 'Type de chambre',
                    icon: Icons.bed_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Standard',
                      child: Text('Standard'),
                    ),
                    DropdownMenuItem(
                      value: 'Deluxe',
                      child: Text('Deluxe'),
                    ),
                    DropdownMenuItem(
                      value: 'Suite',
                      child: Text('Suite'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _roomType = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _dateBox(
                        title: 'Arrivée',
                        value: _checkInDate == null
                            ? 'Choisir'
                            : _dateFormat.format(_checkInDate!),
                        icon: Icons.login_rounded,
                        onTap: () => _pickDate(isCheckIn: true),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _dateBox(
                        title: 'Départ',
                        value: _checkOutDate == null
                            ? 'Choisir'
                            : _dateFormat.format(_checkOutDate!),
                        icon: Icons.logout_rounded,
                        onTap: () => _pickDate(isCheckIn: false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                        'Nombre de nuits',
                        '${_calculateNights()} nuit(s)',
                      ),
                      const SizedBox(height: 10),
                      _summaryRow(
                        'Type de chambre',
                        _roomType,
                      ),
                      const Divider(height: 28),
                      _summaryRow(
                        'Total',
                        '${_calculateTotalPrice().toStringAsFixed(0)} DH',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : CustomButton(
                        text: isEdit
                            ? 'Enregistrer les modifications'
                            : 'Confirmer la réservation',
                        icon: isEdit
                            ? Icons.save_rounded
                            : Icons.check_circle_rounded,
                        onPressed: _saveReservation,
                      ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Décoration réutilisée par les champs du formulaire.
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
      ),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  /// Boîte cliquable pour choisir une date.
  Widget _dateBox({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ligne du résumé de réservation.
  Widget _summaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isTotal ? 17 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
            fontSize: isTotal ? 20 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}