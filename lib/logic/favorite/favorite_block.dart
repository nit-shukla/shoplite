
// lib/bloc/favorites/favorites_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/favorite_repository.dart';


/// Events
abstract class FavoritesEvent {}
class LoadFavorites extends FavoritesEvent {}
class ToggleFavorite extends FavoritesEvent {
  final int productId;
  ToggleFavorite(this.productId);
}

/// States
abstract class FavoritesState {}
class FavoritesInitial extends FavoritesState {}
class FavoritesLoaded extends FavoritesState {
  final List<int> favorites;
  FavoritesLoaded(this.favorites);
}

/// Bloc
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository repository;
  FavoritesBloc(this.repository) : super(FavoritesInitial()) {

    // Load favorites from Hive
    on<LoadFavorites>((event, emit) {
      emit(FavoritesLoaded(repository.getFavorites()));
    });

    // Toggle favorite
    on<ToggleFavorite>((event, emit) async {
      await repository.toggleFavorite(event.productId);
      emit(FavoritesLoaded(repository.getFavorites()));
    });
  }
}
