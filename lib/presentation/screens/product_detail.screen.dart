// lib/presentation/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cart/cart_block.dart';
import '../../logic/cart/cart_event.dart';
import '../../logic/favorite/favorite_block.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepository _repo = ProductRepository();
  late Future<ProductModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    // If productId == -1 used to open cart via AppBar action in catalog example; show cart
    if (widget.productId == -1) {
      // navigate to cart screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const _CartWrapper()));
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: FutureBuilder<ProductModel>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final p = snap.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // images carousel
                SizedBox(
                  height: 300,
                  child: PageView(
                    children: p.images.isNotEmpty
                        ? p.images
                            .map((url) => Hero(
                                tag: 'product_${p.id}',
                                child: CachedNetworkImage(
                                    imageUrl: url, fit: BoxFit.cover)))
                            .toList()
                        : [
                            Hero(
                                tag: 'product_${p.id}',
                                child: CachedNetworkImage(
                                    imageUrl: p.thumbnail, fit: BoxFit.cover))
                          ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title,
                            style: Theme.of(context).textTheme.headline6),
                        const SizedBox(height: 8),
                        Text('₹${p.price}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.star, size: 16),
                          const SizedBox(width: 4),
                          Text('${p.rating}')
                        ]),
                        const SizedBox(height: 12),
                        Text(p.description),
                        const SizedBox(height: 20),
                        Row(children: [
                          IconButton(
                            icon: Builder(builder: (context) {
                              final isFav =
                                  context.select<FavoritesBloc, bool>((b) {
                                final st = b.state;
                                if (st is FavoritesLoaded)
                                  return st.favorites.contains(p.id);
                                return false;
                              });
                              return Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.red : null);
                            }),
                            onPressed: () => context
                                .read<FavoritesBloc>()
                                .add(ToggleFavorite(p.id)),
                            tooltip: 'Favorite',
                          ),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Add to Cart'),
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
                          ),
                        ]),
                      ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartWrapper extends StatelessWidget {
  const _CartWrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Lazily import cart screen to avoid circular imports
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(
          child: Text('Open cart screen from main navigation in your app.')),
    );
  }
}
