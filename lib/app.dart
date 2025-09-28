import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shoplite/presentation/screens/catlog_screen.dart';
import 'package:shoplite/presentation/screens/login_screen.dart';

import 'package:shoplite/theme/app_theme.dart';

import 'logic/auth/auth_bloc.dart';
import 'logic/auth/auth_state.dart';
import 'logic/theme/theme_cubit.dart';

class ShopLiteApp extends StatelessWidget {
  const ShopLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(builder: (context, themeMode) {
      return MaterialApp(
        title: 'ShopLite',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const CatalogScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      );
    });
  }
}
