import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/authentication/controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
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
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: controller.emailFocus,
                        onEditingComplete: () {
                          controller.emailFocus.unfocus();
                          controller.passwordFocus.requestFocus();
                        },
                        onFieldSubmitted: (value) {
                          controller.emailFocus.unfocus();
                          controller.passwordFocus.requestFocus();
                        },
                        onSaved: (newValue) {
                          controller.emailFocus.unfocus();
                          controller.passwordFocus.requestFocus();
                        },
                        onTapOutside: (event) {
                          controller.emailFocus.unfocus();
                          controller.passwordFocus.requestFocus();
                        },
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => TextFormField(
                          controller: controller.passwordController,
                          obscureText: controller.obscurePassword.value,
                          focusNode: controller.passwordFocus,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                controller.obscurePassword.toggle();
                              },
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: controller.validateRequired,
                          onFieldSubmitted: (value) => controller.login(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
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
