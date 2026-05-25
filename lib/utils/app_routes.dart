/// Classe qui regroupe toutes les routes de navigation de l'application.
/// 
/// L'objectif est d'éviter d'écrire les chemins directement dans les vues.
/// Cela rend le code plus propre et plus facile à maintenir.
class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String accountPicker = '/account-picker';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String hotelDetails = '/hotel-details';
  static const String booking = '/booking';
  static const String reservations = '/reservations';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String apiExplore = '/api-explore';
}