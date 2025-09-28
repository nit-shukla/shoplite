// lib/presentation/widgets/offline_banner.dart
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final String text;
  const OfflineBanner({Key? key, this.text = 'You are offline — showing cached items'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orangeAccent,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(text, style: const TextStyle(color: Colors.black87)),
    );
  }
}
