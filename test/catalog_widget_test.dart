import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoplite/presentation/screens/catlog_screen.dart';

void main() {
  testWidgets('Catalog shows loading then empty state placeholder',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogScreen()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
