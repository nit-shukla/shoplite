import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplite/app.dart';
import 'package:shoplite/data/repositories/auth_repository.dart';
import 'package:shoplite/data/repositories/product_repository.dart';
import 'package:shoplite/data/repositories/cart_repository.dart';
import 'package:shoplite/data/repositories/favorite_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'logic/auth/auth_bloc.dart';
import 'logic/auth/auth_event.dart';
import 'logic/cart/cart_block.dart';
import 'logic/product/product_block.dart';
import 'logic/favorite/favorite_block.dart';
import 'logic/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final authRepository = AuthRepository();
  final productRepository = ProductRepository();
  final cartRepository = CartRepository();
  final favoritesRepository = FavoritesRepository();
  await favoritesRepository.init();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        create: (_) =>
            AuthBloc(authRepository: authRepository)..add(AuthStarted()),
      ),
      BlocProvider<ThemeCubit>(
        create: (_) => ThemeCubit(),
      ),
      BlocProvider<ProductBloc>(
        create: (_) => ProductBloc(productRepository: productRepository),
      ),
      BlocProvider<CartBloc>(
        create: (_) => CartBloc(cartRepository: cartRepository),
      ),
      BlocProvider<FavoritesBloc>(
        create: (_) => FavoritesBloc(favoritesRepository)..add(LoadFavorites()),
      ),
    ],
    child: const ShopLiteApp(),
  ));
}
