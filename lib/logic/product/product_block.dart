// lib/logic/product/product_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  final int _limit = 20;
  int _skip = 0;
  bool _hasMore = true;
  List<ProductModel> _items = [];
  String? _currentQuery;
  String? _currentCategory;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoad);
    on<LoadMoreProducts>(_onLoadMore);
  }

  Future<void> _onLoad(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    _skip = 0;
    _hasMore = true;
    _currentQuery = event.query;
    _currentCategory = event.category;

    List<ProductModel> fetchedItems;
    bool isOffline = false;

    // Check network connectivity first
    final connectivityResult = await (Connectivity().checkConnectivity());
    final isConnected = connectivityResult != ConnectivityResult.none;

    if (!isConnected) {
      isOffline = true; // Definitely offline
      // Attempt to load from cache immediately
      try {
        fetchedItems = await productRepository.fetchProducts(
            limit: _limit,
            skip: _skip,
            query: _currentQuery,
            category: _currentCategory);
      } catch (err) {
        emit(ProductError(err.toString()));
        return;
      }
    } else {
      // Online, try network call first
      try {
        fetchedItems = await productRepository.fetchProducts(
            limit: _limit,
            skip: _skip,
            query: _currentQuery,
            category: _currentCategory);
        isOffline = false; // Network call succeeded
      } catch (e) {
        // Network call failed, but we are supposedly online. This could be
        // a server error or a temporary hiccup. Try cache as fallback.
        isOffline = true; // Treat as offline for this fetch operation
        try {
          fetchedItems = await productRepository.fetchProducts(
              limit: _limit,
              skip: _skip,
              query: _currentQuery,
              category: _currentCategory);
        } catch (err) {
          emit(ProductError(err.toString()));
          return;
        }
      }
    }

    _items = fetchedItems;
    _hasMore = fetchedItems.length == _limit;
    emit(ProductLoaded(items: _items, hasMore: _hasMore, isOffline: isOffline));
  }

  Future<void> _onLoadMore(
      LoadMoreProducts event, Emitter<ProductState> emit) async {
    if (!_hasMore) return;
    if (state is ProductLoaded) {
      List<ProductModel> moreItems;
      bool isOffline = false;

      final connectivityResult = await (Connectivity().checkConnectivity());
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        isOffline = true;
        try {
          moreItems = await productRepository.fetchProducts(
              limit: _limit,
              skip: _skip,
              query: _currentQuery,
              category: _currentCategory);
        } catch (err) {
          // Optionally emit an error, or just return if no more cached data is expected.
          return;
        }
      } else {
        try {
          _skip += _limit;
          moreItems = await productRepository.fetchProducts(
              limit: _limit,
              skip: _skip,
              query: _currentQuery,
              category: _currentCategory);
          isOffline = false;
        } catch (e) {
          isOffline = true;
          try {
            moreItems = await productRepository.fetchProducts(
                limit: _limit,
                skip: _skip,
                query: _currentQuery,
                category: _currentCategory);
          } catch (err) {
            return;
          }
        }
      }

      _items = List.from(_items)..addAll(moreItems);
      _hasMore = moreItems.length == _limit;
      emit(ProductLoaded(
          items: _items, hasMore: _hasMore, isOffline: isOffline));
    }
  }
}
