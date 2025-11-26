// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/validators.dart';
import 'package:smartdolap/core/widgets/background_wrapper.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/product/router/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BackgroundWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              tr('register_title'),
              style: TextStyle(fontSize: AppSizes.textL),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (BuildContext context, AuthState state) {
                state.when(
                  initial: () {},
                  loading: () {},
                  authenticated: (domain.User user) {
                    debugPrint(
                        '[RegisterPage] Authenticated - navigating to household setup');
                    // Navigate to household setup after registration
                    Navigator.of(context)
                        .pushReplacementNamed(AppRouter.householdSetup);
                  },
                  unauthenticated: () {},
                  error: (AuthFailure failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_getErrorMessage(failure)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
              builder: (BuildContext context, AuthState state) {
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

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.padding,
                      vertical: AppSizes.verticalSpacingM,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.person_add_rounded,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(delay: 200.ms, duration: 400.ms),
                          SizedBox(height: AppSizes.verticalSpacingL),
                          Text(
                            tr('register_title'),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: AppSizes.textXL,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fadeIn(delay: 300.ms)
                              .slideY(begin: 0.3, end: 0),
                          SizedBox(height: AppSizes.verticalSpacingL),
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(AppSizes.padding),
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    controller: _nameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    enabled: true,
                                    enableInteractiveSelection: true,
                                    style: TextStyle(fontSize: AppSizes.textM),
                                    decoration: InputDecoration(
                                      labelText: tr('display_name'),
                                      labelStyle:
                                          TextStyle(fontSize: AppSizes.textM),
                                      prefixIcon: Icon(Icons.person,
                                          size: AppSizes.icon),
                                    ),
                                  ),
                                  SizedBox(height: AppSizes.verticalSpacingL),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    enabled: true,
                                    enableInteractiveSelection: true,
                                    style: TextStyle(fontSize: AppSizes.textM),
                                    validator: Validators.emailValidator,
                                    decoration: InputDecoration(
                                      labelText: tr('email'),
                                      labelStyle:
                                          TextStyle(fontSize: AppSizes.textM),
                                      prefixIcon: Icon(Icons.email,
                                          size: AppSizes.icon),
                                    ),
                                  ),
                                  SizedBox(height: AppSizes.verticalSpacingL),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    enabled: true,
                                    enableInteractiveSelection: true,
                                    style: TextStyle(fontSize: AppSizes.textM),
                                    validator: Validators.passwordValidator,
                                    decoration: InputDecoration(
                                      labelText: tr('password'),
                                      labelStyle:
                                          TextStyle(fontSize: AppSizes.textM),
                                      prefixIcon: Icon(Icons.lock,
                                          size: AppSizes.icon),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: AppSizes.icon,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                    onFieldSubmitted: (_) {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().register(
                                              email:
                                                  _emailController.text.trim(),
                                              password:
                                                  _passwordController.text,
                                              displayName: _nameController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _nameController.text.trim(),
                                            );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                          SizedBox(height: AppSizes.verticalSpacingL),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthCubit>().register(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                            displayName: _nameController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _nameController.text.trim(),
                                          );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  Size(double.infinity, AppSizes.buttonHeight),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.buttonPaddingH,
                                vertical: AppSizes.buttonPaddingV,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radius),
                              ),
                            ),
                            child: Text(
                              tr('register'),
                              style: TextStyle(fontSize: AppSizes.textM),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 500.ms)
                              .slideY(begin: 0.2, end: 0),
                          SizedBox(height: AppSizes.verticalSpacingM),
                          TextButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).pushReplacementNamed(AppRouter.login),
                            child: Text(
                              tr('have_account_login'),
                              style: TextStyle(fontSize: AppSizes.textM),
                            ),
                          ).animate().fadeIn(delay: 600.ms),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
