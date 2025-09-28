// lib/logic/cart/cart_event.dart
abstract class CartEvent {}

class CartLoad extends CartEvent {}

class CartAddItem extends CartEvent {
  final Map<String, dynamic> productJson;
  CartAddItem(this.productJson);
}

class CartRemoveItem extends CartEvent {
  final String productId;
  CartRemoveItem(this.productId);
}

class CartUpdateQty extends CartEvent {
  final String productId;
  final int qty;
  CartUpdateQty({required this.productId, required this.qty});
}

class CartClear extends CartEvent {}
