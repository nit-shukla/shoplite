// lib/logic/product/product_state.dart
import '../../data/models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> items;
  final bool hasMore;
  final bool isOffline;
  ProductLoaded({required this.items, this.hasMore = false, this.isOffline = false});
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
