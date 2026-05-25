import 'package:flutter/material.dart';

import 'controllers/theme_controller.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';

import 'views/splash_view.dart';
import 'views/welcome_view.dart';
import 'views/account_picker_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/home_view.dart';
import 'views/hotel_details_view.dart';
import 'views/booking_view.dart';
import 'views/reservations_view.dart';
import 'views/favorites_view.dart';
import 'views/profile_view.dart';
import 'views/api_explore_view.dart';

import 'services/notification_service.dart';

/// Point d'entrée principal de l'application HotelGo.
/// 
/// Avant d'afficher l'interface, on initialise les services nécessaires :
/// - le thème choisi par l'utilisateur ;
/// - le service des notifications locales.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chargement du thème sauvegardé localement pour garder le choix de l'utilisateur.
  await ThemeController.instance.loadThemeMode();

  // Initialisation des notifications utilisées après la confirmation d'une réservation.
  await NotificationService.instance.init();

  runApp(const HotelGoApp());
}

/// Widget racine de l'application.
/// 
/// Il contient la configuration globale :
/// - thème clair ;
/// - thème sombre ;
/// - routes de navigation ;
/// - première page affichée.
class HotelGoApp extends StatelessWidget {
  const HotelGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // AnimatedBuilder permet de reconstruire l'application si le thème change.
      animation: ThemeController.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'HotelGo',
          debugShowCheckedModeBanner: false,

          // Définition des deux thèmes de l'application.
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // Le ThemeController décide si on affiche le mode clair ou sombre.
          themeMode: ThemeController.instance.themeMode,

          // L'application commence toujours par le Splash Screen.
          initialRoute: AppRoutes.splash,

          // Liste centralisée des routes utilisées dans toute l'application.
          routes: {
            AppRoutes.splash: (context) => const SplashView(),
            AppRoutes.welcome: (context) => const WelcomeView(),
            AppRoutes.accountPicker: (context) => const AccountPickerView(),
            AppRoutes.login: (context) => const LoginView(),
            AppRoutes.register: (context) => const RegisterView(),
            AppRoutes.home: (context) => const HomeView(),
            AppRoutes.hotelDetails: (context) => const HotelDetailsView(),
            AppRoutes.booking: (context) => const BookingView(),
            AppRoutes.reservations: (context) => const ReservationsView(),
            AppRoutes.favorites: (context) => const FavoritesView(),
            AppRoutes.profile: (context) => const ProfileView(),
            AppRoutes.apiExplore: (context) => const ApiExploreView(),
          },
        );
      },
    );
  }
}