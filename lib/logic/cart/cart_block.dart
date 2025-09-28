// lib/logic/cart/cart_bloc.dart
import 'package:bloc/bloc.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;
  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<CartLoad>(_onLoad);
    on<CartAddItem>(_onAdd);
    on<CartRemoveItem>(_onRemove);
    on<CartUpdateQty>(_onUpdate);
    on<CartClear>(_onClear);
    add(CartLoad());
  }

  Future<void> _onLoad(CartLoad event, Emitter<CartState> emit) async {
    final m = await cartRepository.getCart();
    emit(CartLoaded(items: m));
  }

  Future<void> _onAdd(CartAddItem event, Emitter<CartState> emit) async {
    final current = state is CartLoaded ? (state as CartLoaded).items : {};
    final pid = event.productJson['id'].toString();
    final newMap = Map<String, dynamic>.from(current);
    if (newMap.containsKey(pid)) {
      final currentQty = newMap[pid]['qty'];
      if (currentQty is int) {
        newMap[pid]['qty'] = currentQty + 1;
      } else {
        newMap[pid]['qty'] = 1;
      }
    } else {
      newMap[pid] = {'product': event.productJson, 'qty': 1};
    }
    await cartRepository.saveCart(newMap);
    emit(CartLoaded(items: newMap));
  }

  Future<void> _onRemove(CartRemoveItem event, Emitter<CartState> emit) async {
    final current = state is CartLoaded ? (state as CartLoaded).items : {};
    final newMap = Map<String, dynamic>.from(current);
    newMap.remove(event.productId);
    await cartRepository.saveCart(newMap);
    emit(CartLoaded(items: newMap));
  }

  Future<void> _onUpdate(CartUpdateQty event, Emitter<CartState> emit) async {
    final current = state is CartLoaded ? (state as CartLoaded).items : {};
    final newMap = Map<String, dynamic>.from(current);
    if (newMap.containsKey(event.productId)) {
      if (event.qty <= 0) {
        newMap.remove(event.productId);
      } else {
        newMap[event.productId]['qty'] = event.qty;
      }
      await cartRepository.saveCart(newMap);
      emit(CartLoaded(items: newMap));
    }
  }

  Future<void> _onClear(CartClear event, Emitter<CartState> emit) async {
    await cartRepository.clearCart();
    emit(CartLoaded(items: {}));
  }
}
