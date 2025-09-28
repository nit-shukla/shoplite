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
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: p.images.isNotEmpty
                        ? PageView.builder(
                            itemCount: p.images.length,
                            itemBuilder: (context, index) => Hero(
                                  tag: 'product_${p.id}_${index}',
                                  child: CachedNetworkImage(
                                      imageUrl: p.images[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error)),
                                ))
                        : Hero(
                            tag: 'product_${p.id}',
                            child: CachedNetworkImage(
                                imageUrl: p.thumbnail,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error)),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${p.price}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.green),
                        ),
                        const SizedBox(height: 8),
                        Row(children: <Widget>[
                          ...List.generate(5, (index) {
                            return Icon(
                              index < p.rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text('${p.rating} / 5.0',
                              style: Theme.of(context).textTheme.titleSmall)
                        ]),
                        const SizedBox(height: 12),
                        Text(
                          p.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.payment),
                              label: const Text('Buy Now'),
                              onPressed: () {
                                final authState =
                                    context.read<AuthBloc>().state;
                                if (authState is Authenticated) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Buying now! (Mock)')));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please login to buy items')));
                                }
                              },
                            ),
                          )
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
