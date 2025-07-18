import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../shared/shared.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Password visibility toggle
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    // Clean up controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login action
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Call auth provider login method
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      // Check if login was successful
      final authStatus = ref.read(authProvider);
      if (authStatus.isAuthenticated && mounted) {
        context.go('/home');
      } else if (authStatus.error != null && mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authStatus.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Handle back navigation
  void _handleBack() {
    // Navigate back to first screen
    context.go('/first');
  }

  @override
  Widget build(BuildContext context) {
    // Get localization instance
    final l10n = context.l10n;
    // Watch auth state for loading and error handling
    final authStatus = ref.watch(authProvider);
    final isLoading = authStatus.isLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Login',
            style: AppTextStyles.appBarTitle,
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: AppDecorations.headerGradient,
          ),
          elevation: 0,
          leading: CustomBackButton(
            onPressed: _handleBack,
            tooltip: l10n.back,
          ),
        ),
        // Using GradientBackground widget
        body: GradientBackground(
          child: LoadingOverlay(
            isLoading: isLoading,
            loadingText: l10n.signingIn,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),

                    // Welcome title using centralized text styles
                    Text(
                      l10n.welcome,
                      style: AppTextStyles.headline2,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Subtitle
                    Text(
                      l10n.niceToSeeYou,
                      style: AppTextStyles.subtitle,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Login form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email field using CustomTextField widget
                          CustomTextField(
                            controller: _emailController,
                            hintText: l10n.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.emailRequired;
                              }
                              if (!value.contains('@')) {
                                return l10n.emailInvalid;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Password field using CustomTextField widget
                          CustomTextField(
                            controller: _passwordController,
                            hintText: l10n.password,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _isPasswordHidden,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.secondaryIcon,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordHidden = !_isPasswordHidden;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.passwordRequired;
                              }
                              if (value.length < 6) {
                                return l10n.passwordTooShort;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(l10n.forgotPasswordComingSoon),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.forgotPassword,
                                style: AppTextStyles.linkSecondary,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Login button - uses theme automatically
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              child: Text(
                                l10n.login,
                                style: AppTextStyles.buttonLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Section divider using custom widget
                    SectionDivider(title: l10n.orSignInWith),

                    const SizedBox(height: AppSpacing.lg),

                    // Social login buttons using SocialLoginButton widget
                    Row(
                      children: [
                        // Google login
                        Expanded(
                          child: SocialLoginButton(
                            icon: Icons.g_mobiledata,
                            text: l10n.google,
                            onPressed: () {
                              // TODO: Implement Google login
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.googleSignInComingSoon),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: AppSpacing.md),

                        // Facebook login
                        Expanded(
                          child: SocialLoginButton(
                            icon: Icons.facebook,
                            text: l10n.facebook,
                            onPressed: () {
                              // TODO: Implement Facebook login
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.facebookSignInComingSoon),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Sign up prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.noAccount,
                          style: AppTextStyles.linkSecondary,
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/register');
                          },
                          child: Text(
                            l10n.register,
                            style: AppTextStyles.link,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
