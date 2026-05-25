import '../models/hotel_model.dart';

/// Contrôleur responsable de la gestion des hôtels.
///
/// Dans ce projet, les hôtels principaux sont stockés localement afin d'avoir
/// des données stables pour l'affichage, la recherche, les filtres,
/// les détails, les favoris et les réservations.
class HotelController {
  /// Liste locale des hôtels disponibles dans l'application.
  ///
  /// Chaque hôtel contient :
  /// - un identifiant unique ;
  /// - le nom, la ville et le pays ;
  /// - une image principale ;
  /// - une galerie d'images ;
  /// - le prix par nuit ;
  /// - la note et le nombre d'étoiles ;
  /// - une description ;
  /// - les équipements disponibles.
  final List<HotelModel> _hotels = [
    HotelModel(
      id: 1,
      name: 'Hilton Tangier Al Houara Resort',
      city: 'Tanger',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 1210,
      rating: 4.7,
      stars: 5,
      description:
          'Un établissement premium situé dans la région de Tanger, adapté aux séjours de détente, aux voyages professionnels et aux vacances en bord de mer.',
      facilities: [
        'Wi-Fi gratuit',
        'Piscine',
        'Parking',
        'Restaurant',
        'Salle de sport',
      ],
    ),
    HotelModel(
      id: 2,
      name: 'Barceló Tanger',
      city: 'Tanger',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 1770,
      rating: 4.4,
      stars: 5,
      description:
          'Hôtel situé face à la mer à Tanger, proche du centre-ville et adapté aux séjours touristiques ou professionnels.',
      facilities: [
        'Wi-Fi gratuit',
        'Vue mer',
        'Piscine',
        'Restaurant',
        'Parking',
      ],
    ),
    HotelModel(
      id: 3,
      name: 'Kenzi Tower Hotel',
      city: 'Casablanca',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 1480,
      rating: 4.6,
      stars: 5,
      description:
          'Un hôtel urbain haut standing au style moderne, idéal pour les voyages d’affaires et les séjours au centre de Casablanca.',
      facilities: [
        'Wi-Fi gratuit',
        'Business center',
        'Restaurant',
        'Spa',
        'Parking',
      ],
    ),
    HotelModel(
      id: 4,
      name: 'ONOMO Hotel Casablanca City Center',
      city: 'Casablanca',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 680,
      rating: 4.2,
      stars: 4,
      description:
          'Hôtel moderne au centre de Casablanca, adapté aux séjours business et loisirs avec chambres confortables et services pratiques.',
      facilities: [
        'Wi-Fi gratuit',
        'Salle de sport',
        'Business center',
        'Restaurant',
      ],
    ),
    HotelModel(
      id: 5,
      name: 'ibis Casablanca City Center',
      city: 'Casablanca',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 450,
      rating: 4.1,
      stars: 3,
      description:
          'Hôtel économique et pratique situé au centre de Casablanca, proche de la médina, du port et des transports.',
      facilities: [
        'Wi-Fi gratuit',
        'Restaurant',
        'Bar',
        'Climatisation',
      ],
    ),
    HotelModel(
      id: 6,
      name: 'Mövenpick Mansour Eddahbi',
      city: 'Marrakech',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1596436889106-be35e843f974?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 1740,
      rating: 4.8,
      stars: 5,
      description:
          'Un hôtel de prestige à Marrakech avec architecture élégante, espaces de détente, services premium et proximité des zones touristiques.',
      facilities: [
        'Spa',
        'Piscine',
        'Restaurant',
        'Jardin',
        'Service chambre',
      ],
    ),
    HotelModel(
      id: 7,
      name: 'ibis Marrakech Centre Gare',
      city: 'Marrakech',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 560,
      rating: 4.0,
      stars: 3,
      description:
          'Hôtel 3 étoiles situé près de la gare de Marrakech, pratique pour les courts séjours et les déplacements urbains.',
      facilities: [
        'Wi-Fi gratuit',
        'Piscine',
        'Restaurant',
        'Parking',
      ],
    ),
    HotelModel(
      id: 8,
      name: 'ONOMO Hotel Rabat Terminus',
      city: 'Rabat',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 1020,
      rating: 4.3,
      stars: 4,
      description:
          'Hôtel urbain moderne situé au centre de Rabat, proche des quartiers administratifs et commerciaux.',
      facilities: [
        'Wi-Fi gratuit',
        'Salle de sport',
        'Restaurant',
        'Business center',
      ],
    ),
    HotelModel(
      id: 9,
      name: 'ibis Rabat Agdal',
      city: 'Rabat',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 570,
      rating: 4.0,
      stars: 3,
      description:
          'Hôtel 3 étoiles pratique à Rabat Agdal, adapté aux voyages professionnels et aux courts séjours.',
      facilities: [
        'Wi-Fi gratuit',
        'Restaurant',
        'Bar',
        'Climatisation',
      ],
    ),
    HotelModel(
      id: 10,
      name: 'Hyatt Place Taghazout Bay',
      city: 'Agadir',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 890,
      rating: 4.5,
      stars: 5,
      description:
          'Un hôtel moderne proche de la mer, adapté aux vacances, aux familles et aux séjours de détente dans la région d’Agadir.',
      facilities: [
        'Vue mer',
        'Piscine',
        'Wi-Fi gratuit',
        'Restaurant',
        'Activités',
      ],
    ),
    HotelModel(
      id: 11,
      name: 'Tildi Hotel & Spa',
      city: 'Agadir',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 403,
      rating: 4.1,
      stars: 4,
      description:
          'Hôtel 4 étoiles au cœur d’Agadir, proche de la plage, avec piscine extérieure et espace spa.',
      facilities: [
        'Wi-Fi gratuit',
        'Piscine',
        'Spa',
        'Restaurant',
      ],
    ),
    HotelModel(
      id: 12,
      name: 'Palais Faraj Suites & Spa',
      city: 'Fès',
      country: 'Maroc',
      imageUrl:
          'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1590073242678-70ee3fc28f8e?auto=format&fit=crop&w=1200&q=80',
      ],
      pricePerNight: 760,
      rating: 4.6,
      stars: 5,
      description:
          'Un établissement de charme à Fès, inspiré du style marocain traditionnel, idéal pour découvrir la culture et l’architecture de la ville.',
      facilities: [
        'Spa',
        'Terrasse',
        'Wi-Fi gratuit',
        'Décoration traditionnelle',
        'Restaurant',
      ],
    ),
  ];

  /// Retourne tous les hôtels disponibles.
  ///
  /// Cette méthode est utilisée dans la page d'accueil pour afficher
  /// la liste complète avant l'application des filtres.
  List<HotelModel> getAllHotels() {
    return _hotels;
  }

  /// Cherche un hôtel par son identifiant.
  ///
  /// Elle est utile pour retrouver les informations d'un hôtel
  /// à partir d'une réservation, d'un favori ou d'une page détails.
  HotelModel? getHotelById(int id) {
    try {
      return _hotels.firstWhere((hotel) => hotel.id == id);
    } catch (_) {
      // Si aucun hôtel n'est trouvé, on retourne null au lieu de provoquer une erreur.
      return null;
    }
  }

  /// Normalise un texte pour rendre la recherche plus souple.
  ///
  /// Exemple : "Fès" devient "fes".
  /// Cela permet à l'utilisateur de chercher une ville ou un hôtel
  /// sans être bloqué par les accents ou les majuscules.
  String _normalizeText(String value) {
    String text = value.trim().toLowerCase();

    const accents = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'å': 'a',
      'ç': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ñ': 'n',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'ÿ': 'y',
    };

    accents.forEach((accent, normal) {
      text = text.replaceAll(accent, normal);
    });

    return text;
  }

  /// Recherche et filtre les hôtels selon plusieurs critères.
  ///
  /// Les critères disponibles sont :
  /// - texte de recherche ;
  /// - nombre d'étoiles ;
  /// - prix maximum ;
  /// - ville sélectionnée.
  ///
  /// Tous les critères sont combinés pour donner un résultat précis.
  List<HotelModel> searchAndFilterHotels({
    required String query,
    int? stars,
    double? maxPrice,
    String? city,
  }) {
    final normalizedQuery = _normalizeText(query);
    final normalizedCity = city == null ? null : _normalizeText(city);

    return _hotels.where((hotel) {
      final hotelName = _normalizeText(hotel.name);
      final hotelCity = _normalizeText(hotel.city);
      final hotelCountry = _normalizeText(hotel.country);

      // Recherche par nom d'hôtel, ville ou pays.
      final matchesQuery = normalizedQuery.isEmpty ||
          hotelName.contains(normalizedQuery) ||
          hotelCity.contains(normalizedQuery) ||
          hotelCountry.contains(normalizedQuery);

      // Filtre par nombre d'étoiles.
      final matchesStars = stars == null || hotel.stars == stars;

      // Filtre par prix maximum.
      final matchesPrice = maxPrice == null || hotel.pricePerNight <= maxPrice;

      // Filtre par ville sélectionnée dans les destinations populaires.
      final matchesCity =
          normalizedCity == null || hotelCity == normalizedCity;

      return matchesQuery && matchesStars && matchesPrice && matchesCity;
    }).toList();
  }
}