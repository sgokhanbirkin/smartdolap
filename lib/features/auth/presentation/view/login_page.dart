// ignore_for_file: lines_longer_than_80_chars
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/validators.dart';
import 'package:smartdolap/core/widgets/background_wrapper.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_view_model.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Login page - Authentication view
class LoginPage extends StatelessWidget {
  /// Login page constructor
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => BackgroundWrapper(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (BuildContext context, AuthState state) {
            state.when(
              initial: () {},
              loading: () {},
              authenticated: (User user) {
                debugPrint('[LoginPage] Authenticated - navigating to home');
                Navigator.of(context).pushReplacementNamed(AppRouter.home);
              },
              unauthenticated: () {},
              error: (AuthFailure failure) {},
            );
          },
          builder: (BuildContext context, AuthState state) {
            // Check for AuthLoading state
            final bool isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            if (isLoading) {
              return const Center(
                child: CustomLoadingIndicator(
                  type: LoadingType.pulsingGrid,
                  size: 50,
                ),
              );
            }

            // Check for AuthFailure state
            final AuthFailure? failure = state.maybeWhen(
              error: (AuthFailure failure) => failure,
              orElse: () => null,
            );

            if (failure != null) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(AppSizes.padding),
                      child: Text(
                        tr('auth_error'),
                        style: TextStyle(fontSize: AppSizes.textM),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(AppSizes.padding),
                      child: Text(
                        _getErrorMessage(failure),
                        style: TextStyle(fontSize: AppSizes.textM),
                      ),
                    ),
                    const _LoginForm(),
                  ],
                ),
              );
            }

            // Return login form for other states
            return const _LoginForm();
          },
        ),
      );

  String _getErrorMessage(AuthFailure failure) => failure.when(
        invalidCredentials: () => tr('invalid_credentials'),
        emailAlreadyInUse: () => tr('email_in_use'),
        weakPassword: () => tr('weak_password'),
        network: () => tr('network_error'),
        unknown: (String? message) => message ?? tr('unknown_error'),
      );
}

/// Login form widget - MVVM pattern
class _LoginForm extends StatefulWidget {
  /// Login form constructor
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.padding,
            vertical: AppSizes.verticalSpacingM,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(delay: 200.ms, duration: 400.ms),
                SizedBox(height: AppSizes.verticalSpacingL),
                Text(
                  tr('login_title'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: AppSizes.textXL,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
                SizedBox(height: AppSizes.verticalSpacingL),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.padding),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: true,
                          enableInteractiveSelection: true,
                          style: TextStyle(fontSize: AppSizes.textM),
                          decoration: InputDecoration(
                            labelText: tr('email'),
                            labelStyle: TextStyle(fontSize: AppSizes.textM),
                            prefixIcon: Icon(Icons.email, size: AppSizes.icon),
                          ),
                          validator: Validators.emailValidator,
                        ),
                        SizedBox(height: AppSizes.verticalSpacingL),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          enabled: true,
                          enableInteractiveSelection: true,
                          style: TextStyle(fontSize: AppSizes.textM),
                          decoration: InputDecoration(
                            labelText: tr('password'),
                            labelStyle: TextStyle(fontSize: AppSizes.textM),
                            prefixIcon: Icon(Icons.lock, size: AppSizes.icon),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: AppSizes.icon,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: Validators.passwordValidator,
                          onFieldSubmitted: (_) {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthViewModel>().login(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                SizedBox(height: AppSizes.verticalSpacingL),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthViewModel>().login(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, AppSizes.buttonHeight),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.buttonPaddingH,
                      vertical: AppSizes.buttonPaddingV,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                  ),
                  child: Text(
                    tr('login'),
                    style: TextStyle(fontSize: AppSizes.textM),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                SizedBox(height: AppSizes.verticalSpacingM),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRouter.register),
                  child: Text(
                    tr('dont_have_account_register'),
                    style: TextStyle(fontSize: AppSizes.textM),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      );
}
