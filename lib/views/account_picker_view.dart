import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

/// Page utilisée après la déconnexion.
///
/// Elle affiche les comptes déjà enregistrés pour permettre
/// une reconnexion rapide, comme dans une vraie application.
class AccountPickerView extends StatefulWidget {
  const AccountPickerView({super.key});

  @override
  State<AccountPickerView> createState() => _AccountPickerViewState();
}

class _AccountPickerViewState extends State<AccountPickerView> {
  final AuthController _authController = AuthController();

  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Charge les comptes sauvegardés localement.
  Future<void> _loadUsers() async {
    final users = await _authController.getSavedUsers();

    if (!mounted) return;

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  /// Génère les initiales d'un utilisateur à partir de son nom.
  ///
  /// Exemple : Sara Laaroussi devient SL.
  String _initials(String name) {
    final cleanParts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (cleanParts.isEmpty) {
      return 'U';
    }

    if (cleanParts.length == 1) {
      return cleanParts.first.substring(0, 1).toUpperCase();
    }

    return '${cleanParts.first.substring(0, 1)}${cleanParts.last.substring(0, 1)}'
        .toUpperCase();
  }

  /// Redirige vers Login avec l'email du compte choisi.
  void _goToLogin(UserModel user) {
    Navigator.pushNamed(
      context,
      AppRoutes.login,
      arguments: {
        'email': user.email,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.hotel_rounded,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'HotelGo',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    const Text(
                      'Choisir un compte',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Sélectionnez un compte déjà enregistré ou créez un nouveau compte.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Expanded(
                      child: _users.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person_search_rounded,
                                    color: AppColors.primary,
                                    size: 72,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Aucun compte enregistré',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Créez un compte pour commencer.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.register,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                    ),
                                    label: const Text('Créer un compte'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _users.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final user = _users[index];

                                return InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => _goToLogin(user),
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.07),
                                          blurRadius: 22,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 27,
                                          backgroundColor: AppColors.primary,
                                          child: Text(
                                            _initials(user.fullName),
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.fullName,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                user.email,
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: AppColors.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Se connecter avec un autre email'),
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
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Créer un nouveau compte'),
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
      ),
    );
  }
}