// ===== Register Screen =====
// lib/features/auth/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/extensions/navigation_extensions.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../shared/shared.dart';
import '../controllers/register_controller.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    AppLogger.info('RegisterScreen initialized');

    // Сбрасываем форму при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registerControllerProvider.notifier).resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Получаем данные из нового контроллера
    final controller = ref.read(registerControllerProvider.notifier);
    final state = ref.watch(registerControllerProvider);
    final isLoading = state.isLoading;
    final isPasswordHidden = state.isPasswordHidden;
    final isConfirmPasswordHidden = state.isConfirmPasswordHidden;

    // Слушатели без изменений...
    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (authState) {
          if (authState.isAuthenticated && mounted) {
            final redirect = context.queryParam('redirect');
            if (redirect != null && redirect.isNotEmpty) {
              context.go(redirect);
            } else {
              context.goToHome();
            }
          }
        },
      );
    });

    // Слушаем общие ошибки из контроллера
    ref.listen(
      registerControllerProvider.select((state) => state.generalError),
      (previous, current) {
        if (current != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(current),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: controller.clearError,
              ),
            ),
          );
        }
      },
    );

    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Register', style: AppTextStyles.appBarTitle),
          centerTitle: true,
          flexibleSpace: Container(decoration: AppDecorations.headerGradient),
          elevation: 0,
          leading: CustomBackButton(
            onPressed: () => context.goToFirst(),
            tooltip: l10n.back,
          ),
        ),
        body: GradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  Text(l10n.createAccount, style: AppTextStyles.headline2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.startYourJourney,
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email поле
                        CustomTextField(
                          controller: _emailController,
                          hintText: l10n.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.next,
                          onChanged: controller.updateEmail,
                          validator: (_) => state.emailError,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Password поле
                        CustomTextField(
                          controller: _passwordController,
                          hintText: l10n.password,
                          prefixIcon: Icons.lock_outline,
                          obscureText: isPasswordHidden,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.next,
                          onChanged: controller.updatePassword,
                          validator: (_) => state.passwordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.secondaryIcon,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Confirm Password поле
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: l10n.confirmPassword,
                          prefixIcon: Icons.lock_outline,
                          obscureText: isConfirmPasswordHidden,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleRegister(),
                          onChanged: controller.updateConfirmPassword,
                          validator: (_) => state.confirmPasswordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.secondaryIcon,
                            ),
                            onPressed:
                                controller.toggleConfirmPasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Terms and Conditions с checkbox
                        PrimaryCard(
                          padding: AppSpacing.paddingMD,
                          onTap: controller.toggleTermsAgreement,
                          child: Row(
                            children: [
                              Checkbox(
                                value: state.agreedToTerms,
                                onChanged: isLoading
                                    ? null
                                    : (_) => controller.toggleTermsAgreement(),
                                activeColor: AppColors.primaryButton,
                                checkColor: AppColors.primaryButtonText,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  l10n.termsAndConditions,
                                  style: AppTextStyles.caption,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Register button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleRegister,
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryButtonText,
                                      ),
                                    ),
                                  )
                                : Text(
                                    l10n.register,
                                    style: AppTextStyles.buttonLarge,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.haveAccount,
                        style: AppTextStyles.linkSecondary,
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final redirect = context.queryParam('redirect');
                                context.goToLogin(redirect: redirect);
                              },
                        child: Text(l10n.login, style: AppTextStyles.link),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    // Синхронизируем значения контроллеров с состоянием
    final controller = ref.read(registerControllerProvider.notifier);
    controller.updateEmail(_emailController.text);
    controller.updatePassword(_passwordController.text);
    controller.updateConfirmPassword(_confirmPasswordController.text);

    // Вызываем регистрацию
    await controller.register();
  }
}
