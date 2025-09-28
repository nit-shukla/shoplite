// lib/logic/cart/cart_state.dart
abstract class CartState {}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final Map<String, dynamic> items; // productId -> {product, qty}
  CartLoaded({required this.items});
}
