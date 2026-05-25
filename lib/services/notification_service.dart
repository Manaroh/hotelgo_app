import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service responsable des notifications locales.
///
/// Dans HotelGo, ce service est utilisé pour afficher une notification
/// lorsque l'utilisateur confirme une réservation.
class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialise le système de notifications.
  ///
  /// Cette méthode est appelée au démarrage de l'application.
  /// Le booléen _isInitialized évite d'initialiser le service plusieurs fois.
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Sur les versions récentes d'Android, l'autorisation est obligatoire
    // pour pouvoir afficher des notifications.
    await androidPlugin?.requestNotificationsPermission();

    _isInitialized = true;
  }

  /// Affiche une notification après une réservation confirmée.
  ///
  /// Le nom de l'hôtel et la ville sont ajoutés dans le message
  /// pour rendre la notification plus claire pour l'utilisateur.
  Future<void> showReservationNotification({
    required String hotelName,
    required String city,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reservation_channel',
      'Réservations',
      channelDescription: 'Notifications liées aux réservations HotelGo',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Réservation confirmée',
      body: 'Votre réservation à $hotelName, $city a bien été enregistrée.',
      notificationDetails: notificationDetails,
    );
  }
}