import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

/// Première page affichée au lancement de l'application.
///
/// Elle sert à présenter rapidement le logo HotelGo avant
/// de rediriger l'utilisateur vers la page Welcome.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _goToWelcome();
  }

  /// Attend quelques secondes puis redirige vers la page d'accueil.
  ///
  /// Le mounted permet d'éviter d'utiliser le context si la page
  /// n'est plus affichée.
  Future<void> _goToWelcome() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Dégradé utilisé pour donner une entrée plus moderne à l'application.
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 58,
                backgroundColor: AppColors.white,
                child: Icon(
                  Icons.hotel_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 28),
              Text(
                'HotelGo',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Book your perfect stay',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}