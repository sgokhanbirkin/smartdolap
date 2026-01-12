# 📱 Mobile App Integration Guide

**Backend API Deployment:** In Progress  
**Target:** Flutter Mobile App (Smart Dolap)  
**Date:** 2026-01-10

---

## 🎯 Overview

Bu rehber, deploy edilen backend API'yi Flutter mobile app'e entegre etmek için gereken tüm adımları içerir.

---

## 📍 Step 1: Backend API URL'ini Al

Deployment tamamlandıktan sonra, Firebase Console'dan function URL'ini alacağız:

```
https://us-central1-smart-do-76854.cloudfunctions.net/api
```

**Veya terminal'den:**
```bash
firebase functions:config:get
```

---

## 🔧 Step 2: Mobile App'te API Base URL'i Güncelle

### Dosya: `lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  // Backend API Base URL
  static const String baseUrl = 
    'https://us-central1-smart-do-76854.cloudfunctions.net/api';
  
  // API Endpoints
  static const String healthCheck = '/health';
  static const String generateRecipe = '/api/ai/generateRecipe';
  static const String getProduct = '/api/product'; // + /:barcode
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

---

## 🔐 Step 3: API Service Oluştur/Güncelle

### Dosya: `lib/core/services/api_service.dart`

```dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/api_constants.dart';

class ApiService {
  late final Dio _dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get Firebase ID token
          final user = _auth.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors
          print('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get(ApiConstants.healthCheck);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Generate recipes
  Future<List<Recipe>> generateRecipes({
    required List<String> ingredients,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.generateRecipe,
        data: {
          'ingredients': ingredients,
          if (preferences != null) 'preferences': preferences,
        },
      );

      if (response.data['success'] == true) {
        final recipesData = response.data['data']['recipes'] as List;
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception(response.data['error'] ?? 'Failed to generate recipes');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get product by barcode
  Future<Product> getProduct(String barcode) async {
    try {
      final response = await _dio.get('${ApiConstants.getProduct}/$barcode');

      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Product not found');
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

---

## 📦 Step 4: Recipe Model Güncelle

Backend'in döndüğü format ile uyumlu olmalı:

### Dosya: `lib/features/recipes/data/models/recipe_model.dart`

```dart
class Recipe {
  final String name;
  final String description;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final int prepTime;
  final int cookTime;

  Recipe({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List)
          .map((i) => RecipeIngredient.fromJson(i))
          .toList(),
      instructions: List<String>.from(json['instructions']),
      prepTime: json['prepTime'] as int,
      cookTime: json['cookTime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
      'prepTime': prepTime,
      'cookTime': cookTime,
    };
  }
}

class RecipeIngredient {
  final String name;
  final String amount;

  RecipeIngredient({
    required this.name,
    required this.amount,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String,
      amount: json['amount'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}
```

---

## 🛒 Step 5: Product Model Güncelle

### Dosya: `lib/features/pantry/data/models/product_model.dart`

```dart
class Product {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final String category;
  final int cachedAt;

  Product({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.category,
    required this.cachedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
      cachedAt: json['cachedAt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      if (brand != null) 'brand': brand,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'category': category,
      'cachedAt': cachedAt,
    };
  }
}
```

---

## 🔄 Step 6: Mevcut Kodları Güncelle

### 6.1: OpenAI Service'i Backend'e Yönlendir

**Eski kod (direkt OpenAI):**
```dart
// lib/features/recipes/data/datasources/openai_remote_datasource.dart
final response = await openai.chat.completions.create(...);
```

**Yeni kod (Backend API):**
```dart
// lib/features/recipes/data/datasources/recipe_remote_datasource.dart
final apiService = ApiService();
final recipes = await apiService.generateRecipes(
  ingredients: pantryItems.map((item) => item.name).toList(),
  preferences: {
    'dietary': userPreferences.dietary,
    'cuisine': userPreferences.cuisine,
  },
);
```

### 6.2: Product Lookup'ı Backend'e Yönlendir

**Eski kod (direkt OpenFoodFacts):**
```dart
final response = await http.get(
  Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json')
);
```

**Yeni kod (Backend API):**
```dart
final apiService = ApiService();
final product = await apiService.getProduct(barcode);
```

---

## 🧪 Step 7: Test Et

### 7.1: Health Check Testi

```dart
void testHealthCheck() async {
  final apiService = ApiService();
  try {
    final result = await apiService.healthCheck();
    print('✅ Health check: ${result['message']}');
  } catch (e) {
    print('❌ Health check failed: $e');
  }
}
```

### 7.2: Recipe Generation Testi

```dart
void testRecipeGeneration() async {
  final apiService = ApiService();
  try {
    final recipes = await apiService.generateRecipes(
      ingredients: ['domates', 'makarna', 'peynir'],
      preferences: {
        'dietary': ['vegetarian'],
        'cuisine': 'italian',
      },
    );
    print('✅ Generated ${recipes.length} recipes');
    for (final recipe in recipes) {
      print('  - ${recipe.name}');
    }
  } catch (e) {
    print('❌ Recipe generation failed: $e');
  }
}
```

### 7.3: Product Lookup Testi

```dart
void testProductLookup() async {
  final apiService = ApiService();
  try {
    final product = await apiService.getProduct('3017620422003'); // Nutella
    print('✅ Product found: ${product.name}');
    print('  Brand: ${product.brand}');
    print('  Category: ${product.category}');
  } catch (e) {
    print('❌ Product lookup failed: $e');
  }
}
```

---

## 🚨 Error Handling

Backend'den gelen hata formatı:

```json
{
  "success": false,
  "error": "Error message here"
}
```

**Örnek error handling:**

```dart
try {
  final recipes = await apiService.generateRecipes(...);
} on DioException catch (e) {
  if (e.response != null) {
    final errorData = e.response!.data;
    if (errorData['success'] == false) {
      // Backend error
      final errorMessage = errorData['error'];
      print('Backend error: $errorMessage');
    }
  } else {
    // Network error
    print('Network error: ${e.message}');
  }
} catch (e) {
  // Other errors
  print('Unexpected error: $e');
}
```

---

## 📊 Response Formats

### Success Response (Recipe)
```json
{
  "success": true,
  "data": {
    "recipes": [
      {
        "name": "Pasta Pomodoro",
        "description": "Classic Italian pasta",
        "ingredients": [
          {"name": "pasta", "amount": "200g"},
          {"name": "tomato", "amount": "3 pieces"}
        ],
        "instructions": ["Boil pasta", "Make sauce", "Mix together"],
        "prepTime": 10,
        "cookTime": 20
      }
    ],
    "generatedAt": "2026-01-10T09:00:00Z"
  }
}
```

### Success Response (Product)
```json
{
  "success": true,
  "data": {
    "barcode": "3017620422003",
    "name": "Nutella",
    "brand": "Ferrero",
    "imageUrl": "https://...",
    "category": "spreads",
    "cachedAt": 1704873600000
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": "ingredients must be a non-empty array"
}
```

---

## 🔐 Authentication Flow

1. **User login** → Firebase Auth
2. **Get ID token** → `await user.getIdToken()`
3. **Add to request** → `Authorization: Bearer <token>`
4. **Backend verifies** → Firebase Admin SDK
5. **Request processed** → Response returned

**Token refresh:** Firebase SDK otomatik olarak token'ı refresh eder.

---

## ⚡ Performance Tips

1. **Caching:** Backend zaten product'ları cache'liyor (30 gün)
2. **Retry Logic:** Network hatalarında retry ekle
3. **Loading States:** API çağrıları sırasında loading göster
4. **Error Messages:** Kullanıcı dostu hata mesajları göster

---

## 📝 Checklist

### Backend Hazırlık
- [x] Functions deployed
- [x] Environment variables set
- [x] Health check working
- [ ] Function URL alındı

### Mobile Integration
- [ ] `api_constants.dart` oluşturuldu
- [ ] `ApiService` class'ı oluşturuldu
- [ ] `Recipe` model güncellendi
- [ ] `Product` model güncellendi
- [ ] Dio package eklendi (`pubspec.yaml`)
- [ ] OpenAI calls backend'e yönlendirildi
- [ ] Product lookup backend'e yönlendirildi

### Testing
- [ ] Health check testi
- [ ] Recipe generation testi
- [ ] Product lookup testi
- [ ] Error handling testi
- [ ] Authentication testi

---

## 🎯 Next Steps

1. **Deployment tamamlanınca:**
   - Function URL'ini al
   - `ApiConstants.baseUrl`'i güncelle

2. **Mobile app'te:**
   - Dio package ekle: `flutter pub add dio`
   - ApiService'i implement et
   - Mevcut OpenAI/OpenFoodFacts çağrılarını değiştir
   - Test et

3. **Production'a geç:**
   - Staging'de test et
   - Production'a deploy et
   - Monitoring ekle

---

**Deployment Status:** 🔄 In Progress  
**Estimated Completion:** ~5 dakika

Deployment tamamlandığında function URL'ini paylaşacağım!
