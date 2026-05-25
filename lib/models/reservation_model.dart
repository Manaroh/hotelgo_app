/// Modèle qui représente une réservation d'hôtel.
///
/// Ce modèle est utilisé avec SQLite pour créer, lire, modifier
/// et supprimer les réservations de l'utilisateur connecté.
class ReservationModel {
  final int? id;
  final String userEmail;
  final int hotelId;
  final String hotelName;
  final String city;
  final double pricePerNight;
  final String customerName;
  final String checkInDate;
  final String checkOutDate;
  final int guests;
  final String roomType;
  final int nights;
  final double totalPrice;
  final String createdAt;

  ReservationModel({
    this.id,
    this.userEmail = '',
    required this.hotelId,
    required this.hotelName,
    required this.city,
    required this.pricePerNight,
    required this.customerName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.roomType,
    required this.nights,
    required this.totalPrice,
    required this.createdAt,
  });

  /// Convertit une réservation en Map.
  ///
  /// Cette méthode est nécessaire pour insérer ou mettre à jour
  /// une réservation dans la base de données SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'city': city,
      'pricePerNight': pricePerNight,
      'customerName': customerName,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'guests': guests,
      'roomType': roomType,
      'nights': nights,
      'totalPrice': totalPrice,
      'createdAt': createdAt,
    };
  }

  /// Crée une réservation à partir d'une Map venant de SQLite.
  ///
  /// Cette méthode permet de transformer les lignes de la base de données
  /// en objets Dart faciles à manipuler dans les vues.
  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'],
      userEmail: map['userEmail'] ?? '',
      hotelId: map['hotelId'],
      hotelName: map['hotelName'],
      city: map['city'],
      pricePerNight: map['pricePerNight'],
      customerName: map['customerName'],
      checkInDate: map['checkInDate'],
      checkOutDate: map['checkOutDate'],
      guests: map['guests'],
      roomType: map['roomType'],
      nights: map['nights'],
      totalPrice: map['totalPrice'],
      createdAt: map['createdAt'],
    );
  }

  /// Crée une copie de la réservation avec quelques valeurs modifiées.
  ///
  /// Cette méthode est pratique surtout lors de la modification d'une réservation,
  /// car elle évite de recréer manuellement tous les champs.
  ReservationModel copyWith({
    int? id,
    String? userEmail,
    int? hotelId,
    String? hotelName,
    String? city,
    double? pricePerNight,
    String? customerName,
    String? checkInDate,
    String? checkOutDate,
    int? guests,
    String? roomType,
    int? nights,
    double? totalPrice,
    String? createdAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userEmail: userEmail ?? this.userEmail,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      city: city ?? this.city,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      customerName: customerName ?? this.customerName,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      roomType: roomType ?? this.roomType,
      nights: nights ?? this.nights,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}