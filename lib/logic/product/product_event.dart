// lib/logic/product/product_event.dart
abstract class ProductEvent {}

class LoadProducts extends ProductEvent {
  final bool refresh;
  final String? query;
  final String? category;
  LoadProducts({this.refresh = false, this.query, this.category});
}

class LoadMoreProducts extends ProductEvent {}
