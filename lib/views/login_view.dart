import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Page de connexion de l'application.
///
/// Elle permet à un utilisateur déjà enregistré de se connecter
/// avec son email et son mot de passe.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = AuthController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _didLoadArguments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // On charge les arguments une seule fois pour éviter d'écraser
    // ce que l'utilisateur écrit ensuite dans les champs.
    if (_didLoadArguments) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      final email = args['email'];
      final password = args['password'];

      // L'email peut être prérempli depuis la page de choix de compte
      // ou après la création d'un nouveau compte.
      if (email is String) {
        _emailController.text = email;
      }

      // Le mot de passe est prérempli après l'inscription pour faciliter
      // la première connexion.
      if (password is String) {
        _passwordController.text = password;
      }
    }

    _didLoadArguments = true;
  }

  /// Vérifie le formulaire puis lance la connexion.
  ///
  /// Si les informations sont correctes, l'utilisateur est redirigé
  /// vers la page d'accueil.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final errorMessage = await _authController.login(
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
        content: Text('Connexion réussie'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  void dispose() {
    // Les controllers sont libérés pour éviter les fuites mémoire.
    _emailController.dispose();
    _passwordController.dispose();
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

            // La validation se met à jour pendant que l'utilisateur écrit.
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
                    Icons.lock_open_rounded,
                    color: AppColors.white,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Connectez-vous pour gérer vos réservations et découvrir les meilleurs hôtels.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 36),

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
                  hint: 'Entrez votre mot de passe',
                  icon: Icons.lock_rounded,
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.validatePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                ),

                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.primary,
                      )
                    : CustomButton(
                        text: 'Login',
                        icon: Icons.login_rounded,
                        onPressed: _login,
                      ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Vous n’avez pas de compte ? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.register,
                        );
                      },
                      child: const Text(
                        'Créer un compte',
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