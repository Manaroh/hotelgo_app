import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/review_controller.dart';
import '../models/hotel_model.dart';
import '../models/review_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

/// Page de détails d'un hôtel.
///
/// Cette page affiche toutes les informations importantes d'un hôtel :
/// image principale, nom, ville, prix, note, description, galerie,
/// équipements, avis clients et bouton de réservation.
class HotelDetailsView extends StatefulWidget {
  const HotelDetailsView({super.key});

  @override
  State<HotelDetailsView> createState() => _HotelDetailsViewState();
}

class _HotelDetailsViewState extends State<HotelDetailsView> {
  final ReviewController _reviewController = ReviewController();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _galleryScrollController = ScrollController();

  HotelModel? _hotel;
  List<ReviewModel> _reviews = [];
  double _averageRating = 0;
  bool _isLoadingReviews = true;
  bool _didLoadArgs = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Les arguments sont chargés une seule fois pour éviter de relancer
    // le chargement des avis à chaque rebuild de la page.
    if (_didLoadArgs) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is HotelModel) {
      _hotel = args;
      _averageRating = args.rating;
      _loadReviews();
    }

    _didLoadArgs = true;
  }

  /// Charge les avis liés à l'hôtel sélectionné.
  ///
  /// La note moyenne est recalculée à partir des avis sauvegardés.
  Future<void> _loadReviews() async {
    if (_hotel == null) return;

    final reviews = await _reviewController.getReviewsByHotel(_hotel!.id);

    if (!mounted) return;

    setState(() {
      _reviews = reviews;
      _averageRating = _reviewController.calculateAverageRating(
        hotelBaseRating: _hotel!.rating,
        reviews: reviews,
      );
      _isLoadingReviews = false;
    });
  }

  /// Formate une date ISO en format lisible.
  ///
  /// Exemple : 2026-05-25 devient 25/05/2026.
  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);

    if (date == null) {
      return isoDate;
    }

    return _dateFormat.format(date);
  }

  /// Affiche les étoiles selon une note donnée.
  ///
  /// La note est arrondie pour afficher des étoiles pleines ou vides.
  Widget _stars(double rating, {double size = 20}) {
    final rounded = rating.round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rounded ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.accent,
          size: size,
        ),
      ),
    );
  }

  /// Ouvre une image de la galerie en aperçu plein écran.
  ///
  /// InteractiveViewer permet à l'utilisateur de zoomer l'image.
  void _openImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 320,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: AppColors.white,
                              size: 64,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.55),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Section galerie d'images.
  ///
  /// Les images sont affichées horizontalement avec une scrollbar visible.
  /// Chaque image peut être ouverte en aperçu avec zoom.
  Widget _gallerySection(HotelModel hotel) {
    if (hotel.galleryImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Galerie d’images',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              children: const [
                Icon(
                  Icons.swipe_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                SizedBox(width: 4),
                Text(
                  'Glissez',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        Scrollbar(
          controller: _galleryScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          radius: const Radius.circular(20),
          thickness: 5,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 125,
              child: ListView.separated(
                controller: _galleryScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: hotel.galleryImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final imageUrl = hotel.galleryImages[index];

                  return GestureDetector(
                    onTap: () => _openImagePreview(imageUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.network(
                            imageUrl,
                            width: 165,
                            height: 125,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 165,
                                height: 125,
                                color: AppColors.primary,
                                child: const Icon(
                                  Icons.image_not_supported_rounded,
                                  color: AppColors.white,
                                  size: 44,
                                ),
                              );
                            },
                          ),

                          // Petit compteur pour montrer la position de l'image.
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${index + 1}/${hotel.galleryImages.length}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Icône indiquant que l'image peut être agrandie.
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.zoom_in_rounded,
                                color: AppColors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Ouvre le formulaire d'ajout d'avis dans un BottomSheet.
  ///
  /// L'utilisateur choisit une note et écrit un commentaire.
  Future<void> _openReviewSheet() async {
    if (_hotel == null) return;

    _commentController.clear();
    double selectedRating = 5;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Ajouter un avis',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _hotel!.name,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Votre note',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Sélection de la note par clic sur les étoiles.
                    Row(
                      children: List.generate(
                        5,
                        (index) {
                          final value = index + 1.0;

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                selectedRating = value;
                              });
                            },
                            child: Icon(
                              value <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: AppColors.accent,
                              size: 38,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Commentaire',
                        hintText: 'Décrivez votre expérience...',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(
                          Icons.rate_review_rounded,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final errorMessage =
                              await _reviewController.addOrUpdateReview(
                            hotelId: _hotel!.id,
                            rating: selectedRating,
                            comment: _commentController.text,
                          );

                          if (!mounted) return;

                          if (errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Avis ajouté avec succès'),
                              backgroundColor: AppColors.success,
                            ),
                          );

                          _loadReviews();
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Enregistrer l’avis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Carte d'un avis client.
  ///
  /// Elle affiche le nom de l'utilisateur, la date, la note et le commentaire.
  Widget _reviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  review.userName.isEmpty
                      ? 'U'
                      : review.userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              _stars(review.rating, size: 18),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            review.comment,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Section des avis clients.
  ///
  /// Elle affiche un chargement, une liste vide ou les avis existants.
  Widget _reviewsSection() {
    if (_isLoadingReviews) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Avis clients',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _openReviewSheet,
              icon: const Icon(Icons.add_comment_rounded),
              label: const Text('Ajouter'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (_reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  color: AppColors.primary,
                  size: 42,
                ),
                SizedBox(height: 12),
                Text(
                  'Aucun avis pour cet hôtel',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Soyez le premier à partager votre expérience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ..._reviews.map(_reviewCard),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _galleryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotel = _hotel;

    if (hotel == null) {
      return const Scaffold(
        body: Center(
          child: Text('Aucun hôtel sélectionné'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: AppColors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'hotel-${hotel.id}',
                child: Image.network(
                  hotel.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
                      child: const Icon(
                        Icons.hotel_rounded,
                        color: AppColors.white,
                        size: 90,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de l'hôtel et prix par nuit.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${hotel.pricePerNight.toStringAsFixed(0)} DH',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${hotel.city}, ${hotel.country}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _stars(_averageRating, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        '${_averageRating.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_reviews.length} avis)',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    hotel.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _gallerySection(hotel),

                  const SizedBox(height: 28),

                  const Text(
                    'Équipements',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: hotel.facilities.map((facility) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              facility,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  _reviewsSection(),

                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.booking,
                          arguments: hotel,
                        );
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Réserver maintenant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}