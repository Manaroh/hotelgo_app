/// Modèle qui représente un hôtel affiché dans l'application.
///
/// Il contient toutes les informations nécessaires pour afficher un hôtel
/// dans la liste, dans la page détails et dans la page de réservation.
class HotelModel {
  final int id;
  final String name;
  final String city;
  final String country;
  final String imageUrl;
  final List<String> galleryImages;
  final double pricePerNight;
  final double rating;
  final int stars;
  final String description;
  final List<String> facilities;

  HotelModel({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.imageUrl,
    required this.galleryImages,
    required this.pricePerNight,
    required this.rating,
    required this.stars,
    required this.description,
    required this.facilities,
  });
}