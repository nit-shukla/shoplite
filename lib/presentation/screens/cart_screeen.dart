// lib/presentation/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cart/cart_block.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/cart/cart_state.dart';
import '../../logic/cart/cart_event.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  double _total(Map<String, dynamic> items) {
    double total = 0;
    items.forEach((k, v) {
      final product = v['product'] as Map<String, dynamic>;
      final qty = v['qty'] as int;
      total += (product['price'] as num).toDouble() * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Center(child: Text('Please login to view your cart'));
        }
        return BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoaded) {
              final items = state.items;
              if (items.isEmpty)
                return const Center(child: Text('Cart is empty'));
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final pid = items.keys.elementAt(index);
                        final v = items[pid];
                        final product = v['product'] as Map<String, dynamic>;
                        final qty = v['qty'] as int;
                        return ListTile(
                          leading: Image.network(product['thumbnail'],
                              width: 56, height: 56, fit: BoxFit.cover),
                          title: Text(product['title']),
                          subtitle: Text('₹${product['price']} x $qty'),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  final newQty = qty - 1;
                                  context.read<CartBloc>().add(CartUpdateQty(
                                      productId: pid, qty: newQty));
                                }),
                            Text('$qty'),
                            IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  context.read<CartBloc>().add(CartUpdateQty(
                                      productId: pid, qty: qty + 1));
                                }),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  context
                                      .read<CartBloc>()
                                      .add(CartRemoveItem(pid));
                                }),
                          ]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(children: [
                      Text('Total: ₹${_total(items).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // mock place order
                          context.read<CartBloc>().add(CartClear());
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                      title: const Text('Order Placed'),
                                      content: const Text(
                                          'Your order was placed successfully (mock).'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'))
                                      ]));
                        },
                        child: const Text('Place Order'),
                      )
                    ]),
                  )
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      }),
    );
  }
}
