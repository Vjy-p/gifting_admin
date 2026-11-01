import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/core/theme/theme_controller.dart';
import 'package:gifting_admin/features/authentication/controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  final passwordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();

  bool obscurePassword = true;

  final controller = Get.find<LoginController>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              tooltip: ThemeController.to.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              onPressed: () => ThemeController.to.toggleTheme(),
              icon: Icon(
                ThemeController.to.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tribe Green Admin',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to manage corporate gifting enquiries.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: emailFocus,
                        onEditingComplete: () {
                          emailFocus.unfocus();
                          passwordFocus.requestFocus();
                        },
                        onFieldSubmitted: (value) {
                          emailFocus.unfocus();
                          passwordFocus.requestFocus();
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        focusNode: passwordFocus,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              obscurePassword = !obscurePassword;
                              setState(() {});
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: controller.validateRequired,
                        onFieldSubmitted: (value) {
                          if (formKey.currentState?.validate() == true) {
                            controller.login(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  if (formKey.currentState?.validate() ==
                                      true) {
                                    controller.login(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );
                                  }
                                },
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
