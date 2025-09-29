import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplite/data/repositories/product_repository.dart';
import 'package:shoplite/logic/product/product_block.dart';
import 'package:shoplite/logic/product/product_state.dart';
import 'package:shoplite/presentation/screens/catlog_screen.dart';

import 'catalog_widget_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  group('CatalogScreen', () {
    late MockProductRepository mockProductRepository;
    late ProductBloc productBloc;

    setUp(() {
      mockProductRepository = MockProductRepository();
      productBloc = ProductBloc(productRepository: mockProductRepository);
    });

    testWidgets('Catalog shows loading then empty state placeholder',
        (tester) async {
      when(mockProductRepository.fetchProducts(
              limit: anyNamed('limit'), skip: anyNamed('skip')))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(
        BlocProvider<ProductBloc>(
          create: (context) => productBloc,
          child: const MaterialApp(
            home: CatalogScreen(),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Await a bit to allow the bloc to emit states
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.text('No products found.'), findsOneWidget);
    });
  });
}
