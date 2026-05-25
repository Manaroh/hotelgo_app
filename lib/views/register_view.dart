import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Page de création de compte.
///
/// Elle contient un formulaire complet avec validation pour créer
/// un nouvel utilisateur localement.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthController _authController = AuthController();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  /// Valide le formulaire puis crée le compte.
  ///
  /// Si l'inscription réussit, l'utilisateur est envoyé vers Login
  /// avec l'email et le mot de passe préremplis.
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final errorMessage = await _authController.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compte créé avec succès. Connectez-vous maintenant.'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.login,
      arguments: {
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passwordController.text,
      },
    );
  }

  @override
  void dispose() {
    // Libération des controllers après fermeture de la page.
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,

            // Les erreurs de saisie apparaissent pendant que l'utilisateur écrit.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                const SizedBox(height: 20),

                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppColors.white,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Create Account',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Créez votre compte pour réserver vos hôtels préférés facilement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 36),

                CustomTextField(
                  label: 'Nom complet',
                  hint: 'Ex: Manar Ouahabi',
                  icon: Icons.person_rounded,
                  controller: _fullNameController,
                  validator: Validators.validateName,
                  autofillHints: const [AutofillHints.name],
                ),

                const SizedBox(height: 18),

                CustomTextField(
                  label: 'Email',
                  hint: 'exemple@gmail.com',
                  icon: Icons.email_rounded,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  autofillHints: const [AutofillHints.email],
                ),

                const SizedBox(height: 18),

                CustomTextField(
                  label: 'Mot de passe',
                  hint: 'Minimum 6 caractères',
                  icon: Icons.lock_rounded,
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.validatePassword,
                  autofillHints: const [AutofillHints.newPassword],
                ),

                const SizedBox(height: 18),

                CustomTextField(
                  label: 'Confirmer mot de passe',
                  hint: 'Répétez votre mot de passe',
                  icon: Icons.verified_user_rounded,
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    return Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    );
                  },
                  autofillHints: const [AutofillHints.newPassword],
                ),

                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.primary,
                      )
                    : CustomButton(
                        text: 'Create Account',
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: _register,
                      ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Vous avez déjà un compte ? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}