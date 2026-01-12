// ignore_for_file: public_member_api_docs, avoid_print

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as fb show User;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:smartdolap/core/services/api_service.dart';
import 'package:smartdolap/core/services/product_cache_service.dart';
import 'package:smartdolap/features/barcode/data/services/open_food_facts_service.dart';

// Simple Fake for Auth
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  fb.User? get currentUser => null; // No user logged in
}

void main() {
  final di = GetIt.instance;

  setUpAll(() async {
    print('🚀 Setting up test dependencies...');

    // Reset GetIt if needed
    await di.reset();

    // Register mocks
    di.registerLazySingleton<FirebaseAuth>(() => FakeFirebaseAuth());

    // Register real services
    di.registerLazySingleton<ApiService>(() => ApiService(di<FirebaseAuth>()));

    di.registerLazySingleton<ProductCacheService>(() => ProductCacheService());

    di.registerLazySingleton<OpenFoodFactsService>(
      () => OpenFoodFactsService(
        apiService: di<ApiService>(),
        productCache: di<ProductCacheService>(),
      ),
    );
  });

  test('Health Check', () async {
    print('\n📋 Test 1: Health Check');
    final apiService = di<ApiService>();
    try {
      final result = await apiService.healthCheck();
      print('✅ Health check successful: $result');
      expect(result['status'], equals('ok'));
    } catch (e) {
      print('❌ Health check failed: $e');
      rethrow;
    }
  });

  test('Product Lookup (Network)', () async {
    print('\n📋 Test 2: Product Lookup');
    final service = di<OpenFoodFactsService>();
    const String barcode = '3017620422003'; // Nutella

    final stopwatch = Stopwatch()..start();
    final result = await service.lookupProduct(barcode);
    stopwatch.stop();

    expect(result.isFound, isTrue);
    print('✅ Product found: ${result.product?.name}');
    print('⏱️ Response time: ${stopwatch.elapsedMilliseconds}ms');
  });

  test('Product Lookup (Cache)', () async {
    print('\n📋 Test 3: Product Cache');
    final service = di<OpenFoodFactsService>();
    const String barcode = '3017620422003'; // Same barcode

    final stopwatch = Stopwatch()..start();
    final result = await service.lookupProduct(barcode);
    stopwatch.stop();

    expect(result.isFound, isTrue);
    print('✅ Cached result: ${result.product?.name}');
    print('⏱️ Response time: ${stopwatch.elapsedMilliseconds}ms ⚡');

    // Cache access should be very fast (<100ms is generous for memory access)
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
}
