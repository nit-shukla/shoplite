import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplite/presentation/screens/product_detail.screen.dart';
import 'package:shoplite/presentation/screens/cart_screeen.dart';
import '../../logic/cart/cart_block.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';

import '../../logic/product/product_block.dart';
import '../../logic/product/product_event.dart';
import '../../logic/product/product_state.dart';

import '../../logic/cart/cart_event.dart';
import '../../widgets/ofline_banner.dart';
import '../../widgets/product_cart.dart';
import '../../logic/theme/theme_cubit.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProducts());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductBloc>().add(LoadMoreProducts());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopLite'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              } else {
                // Show login required dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Login Required'),
                    content: const Text('Please login to view your cart.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // The app will automatically redirect to login since user is not authenticated
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                );
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search products'),
                  onSubmitted: (v) =>
                      context.read<ProductBloc>().add(LoadProducts(query: v)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<ProductBloc>()
                      .add(LoadProducts(query: _searchController.text.trim()));
                },
                child: const Text('Search'),
              )
            ]),
          ),
          // Bloc Body
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProductLoaded) {
                  return Column(children: [
                    if (state.isOffline) const OfflineBanner(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => context
                            .read<ProductBloc>()
                            .add(LoadProducts(refresh: true)),
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 3 : 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount:
                              state.items.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, idx) {
                            if (idx >= state.items.length) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final p = state.items[idx];
                            return ProductCard(
                              product: p,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                          productId: p.id))),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  final authState =
                                      context.read<AuthBloc>().state;
                                  if (authState is Authenticated) {
                                    context
                                        .read<CartBloc>()
                                        .add(CartAddItem(p.toJson()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Added to cart')));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Please login to add items to cart')));
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ]);
                }
                if (state is ProductError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
