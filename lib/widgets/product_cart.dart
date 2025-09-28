import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final Widget? trailing;
  const ProductCard(
      {Key? key, required this.product, this.onTap, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_${product.id}',
              child: AspectRatio(
                aspectRatio: isWide ? 1.6 : 1.2,
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  fit: BoxFit.cover,
                  placeholder: (c, s) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (c, s, e) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(product.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('₹${product.price}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing!)
          ],
        ),
      ),
    );
  }
}
