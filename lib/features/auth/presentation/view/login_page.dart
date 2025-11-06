// ignore_for_file: lines_longer_than_80_chars
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/validators.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Login page - Authentication view
class LoginPage extends StatelessWidget {
  /// Login page constructor
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: BlocListener<AuthCubit, AuthState>(
        listener: (BuildContext context, AuthState state) {
          state.when(
            initial: () {},
            loading: () {},
            authenticated: (User user) {
              Navigator.of(context).pushReplacementNamed(AppRouter.home);
            },
            unauthenticated: () {},
            error: (AuthFailure failure) {},
          );
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState state) {
            // Check for AuthLoading state
            final bool isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            if (isLoading) {
              return Center(
                child: SizedBox(
                  height: AppSizes.iconXL,
                  width: AppSizes.iconXL,
                  child: CircularProgressIndicator(strokeWidth: 3.w),
                ),
              );
            }

            // Check for AuthFailure state
            final AuthFailure? failure = state.maybeWhen(
              error: (AuthFailure failure) => failure,
              orElse: () => null,
            );

            if (failure != null) {
              return Column(
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
              );
            }

            // Return login form for other states
            return const _LoginForm();
          },
        ),
      ),
    ),
  );

  String _getErrorMessage(AuthFailure failure) => failure.when(
    invalidCredentials: () => 'Geçersiz email veya şifre',
    emailAlreadyInUse: () => 'Bu email adresi zaten kullanılıyor',
    weakPassword: () => 'Şifre çok zayıf',
    network: () => 'Ağ hatası. Lütfen bağlantınızı kontrol edin',
    unknown: (String? message) => message ?? 'Bir hata oluştu',
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
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.symmetric(
      horizontal: AppSizes.padding,
      vertical: AppSizes.verticalSpacingM,
    ),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: AppSizes.verticalSpacingL),
          Text(
            tr('login_title'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: AppSizes.textXL,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.verticalSpacingL),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: AppSizes.textM),
            decoration: InputDecoration(
              labelText: tr('email'),
              labelStyle: TextStyle(fontSize: AppSizes.textM),
              prefixIcon: Icon(Icons.email, size: AppSizes.icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              contentPadding: EdgeInsets.all(AppSizes.padding),
            ),
            validator: Validators.emailValidator,
          ),
          SizedBox(height: AppSizes.verticalSpacingL),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(fontSize: AppSizes.textM),
            decoration: InputDecoration(
              labelText: tr('password'),
              labelStyle: TextStyle(fontSize: AppSizes.textM),
              prefixIcon: Icon(Icons.lock, size: AppSizes.icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              contentPadding: EdgeInsets.all(AppSizes.padding),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
          ),
          SizedBox(height: AppSizes.verticalSpacingL),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<AuthCubit>().login(
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
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRouter.register),
            child: Text(tr('dont_have_account_register')),
          ),
        ],
      ),
    ),
  );
}
