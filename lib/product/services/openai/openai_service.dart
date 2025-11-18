// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/core/utils/tonl_encoder.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:smartdolap/product/services/openai/openai_parsing_exception.dart';

/// OpenAI Service implementation
/// Follows Single Responsibility Principle - only handles OpenAI API communication
class OpenAIService implements IOpenAIService {
  OpenAIService({Dio? dio, String? apiKey})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://api.openai.com/v1')),
      _apiKey = apiKey ?? (dotenv.maybeGet('OPENAI_API_KEY') ?? '');

  final Dio _dio;
  final String _apiKey;

  Map<String, String> get _headers => <String, String>{
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  @override
  Future<List<Ingredient>> parseFridgeImage(Uint8List imageBytes) async {
    final String b64 = base64Encode(imageBytes);
    final Response<dynamic> res = await _dio.post(
      '/chat/completions',
      options: Options(headers: _headers),
      data: <String, dynamic>{
        'model': 'gpt-4o-mini',
        'response_format': <String, String>{'type': 'json_object'},
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{
            'role': 'system',
            'content':
                'Yanıt dili Türkçe olsun. Şu şemada JSON döndür: '
                '{"items":[{"name":"","unit":"","quantity":1}]}',
          },
          <String, dynamic>{
            'role': 'user',
            'content': <Map<String, dynamic>>[
              <String, String>{'type': 'text', 'text': 'Detect ingredients.'},
              <String, String>{
                'type': 'image_url',
                'image_url': 'data:image/png;base64,$b64',
              },
            ],
          },
        ],
      },
    );

    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    final List<dynamic> choices = data['choices'] as List<dynamic>;
    final Map<String, dynamic> message =
        (choices.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>;
    final String content = message['content'] as String;
    final Map<String, dynamic> json =
        jsonDecode(content) as Map<String, dynamic>;
    final List<dynamic> items =
        (json['items'] as List<dynamic>?) ?? <dynamic>[];
    return items.map((Object? e) {
      final Map<String, dynamic>? itemMap = e as Map<String, dynamic>?;
      if (itemMap == null) {
        return const Ingredient(name: '');
      }
      return Ingredient(
        name: (itemMap['name'] as String?)?.trim() ?? '',
        unit: (itemMap['unit'] as String?)?.trim() ?? '',
        quantity: (itemMap['quantity'] is num)
            ? (itemMap['quantity'] as num).toDouble()
            : 1.0,
      );
    }).toList();
  }

  @override
  Future<List<RecipeSuggestion>> suggestRecipes(
    List<Ingredient> pantry, {
    int servings = 2,
    int count = 6,
    String? query,
    List<String>? excludeTitles,
  }) async {
    // Convert pantry to TONL format for token optimization
    final List<Map<String, dynamic>> pantryList = pantry.map((Ingredient e) {
      return <String, dynamic>{
        'name': e.name,
        'quantity': e.quantity,
        'unit': e.unit,
      };
    }).toList();
    final String pantryTONL = TONLEncoder.encode(<String, dynamic>{
      'pantry': pantryList,
    });

    final DateTime startTime = DateTime.now();
    final Response<dynamic> res = await _dio.post(
      '/chat/completions',
      options: Options(headers: _headers),
      data: <String, dynamic>{
        'model': 'gpt-4o-mini',
        'messages': <Map<String, String>>[
          <String, String>{
            'role': 'system',
            'content':
                'Yanıt dili Türkçe olsun. Aşağıdaki veri TONL formatında. '
                'TONL formatını şöyle parse et:\n'
                '• Lines with [count]{fields}: are array headers, data rows follow\n'
                '• Lines with {fields}: are object headers, field: value pairs follow\n'
                '• Indentation (2 spaces) indicates nesting levels\n'
                '• Default delimiter is comma\n'
                '• Value types: unquoted numbers/booleans, quoted strings, null\n\n'
                'Yanıtını TONL formatında ver. Şema:\n'
                'recipes[count]{title,ingredients,steps,calories,durationMinutes,difficulty,category,fiber}:\n'
                '  title1, [ing1,ing2], [step1,step2], calories, minutes, difficulty, category, fiber\n'
                '  title2, [ing3,ing4], [step3,step4], calories, minutes, difficulty, category, fiber\n\n'
                'Örnek TONL formatı:\n'
                'recipes[2]{title,ingredients,steps,calories,durationMinutes,difficulty,category,fiber}:\n'
                '  Menemen, [yumurta,domates,biber], [Domatesleri doğra,Yumurtaları kır], 250, 15, kolay, kahvaltı, 5\n'
                '  Omlet, [yumurta,peynir], [Yumurtaları çırp,Tavada pişir], 200, 10, kolay, kahvaltı, 3',
          },
          <String, String>{
            'role': 'user',
            'content':
                'Dolap verileri (TONL formatında):\n$pantryTONL\n\n'
                'En az $count tarif öner. '
                'Porsiyon: $servings kişilik. '
                '${query != null ? 'Arama: $query. ' : ''}'
                '${excludeTitles != null && excludeTitles.isNotEmpty ? 'Şu '
                          'başlıkları tekrar etme: '
                          '${excludeTitles.join(', ')}. ' : ''}'
                'Gerekirse ekstra malzeme ekleyebilirsin. '
                'Yanıtını TONL formatında ver.',
          },
        ],
      },
    );

    final DateTime endTime = DateTime.now();
    // Duration logged for performance monitoring
    final Duration _duration = endTime.difference(startTime);
    Logger.info(
      '[OpenAIService] Recipe suggestion took ${_duration.inMilliseconds}ms',
    );

    try {
      // Parse response safely
      final Map<String, dynamic> data2 = res.data as Map<String, dynamic>;

      // Validate response structure
      if (!data2.containsKey('choices')) {
        Logger.error(
          '[OpenAIService] Invalid response structure - missing choices',
        );
        throw const OpenAIParsingException('invalid_format');
      }

      final List<dynamic> choices2 = data2['choices'] as List<dynamic>;
      if (choices2.isEmpty) {
        Logger.error('[OpenAIService] Empty choices array');
        throw const OpenAIParsingException('empty_response');
      }

      final Map<String, dynamic> message2 =
          (choices2.first as Map<String, dynamic>)['message']
              as Map<String, dynamic>;

      if (!message2.containsKey('content')) {
        Logger.error(
          '[OpenAIService] Invalid message structure - missing content',
        );
        throw const OpenAIParsingException('invalid_format');
      }

      final String content = message2['content'] as String;

      if (content.isEmpty) {
        Logger.error('[OpenAIService] Empty content');
        throw const OpenAIParsingException('empty_response');
      }

      // Parse TONL or JSON response safely
      Map<String, dynamic> json;
      try {
        // Try TONL first (more efficient)
        if (content.trim().startsWith('#version') ||
            content.contains('[') && content.contains(']{')) {
          json = TONLEncoder.decode(content) as Map<String, dynamic>;
          Logger.info(
            '[OpenAIService] Successfully parsed TONL response. Content length: ${content.length}',
          );
          Logger.info(
            '[OpenAIService] TONL parsed JSON keys: ${json.keys.toList()}',
          );
        } else {
          // Fallback to JSON
          json = jsonDecode(content) as Map<String, dynamic>;
          Logger.info('[OpenAIService] Parsed JSON response (fallback)');
          Logger.info('[OpenAIService] JSON keys: ${json.keys.toList()}');
        }
      } on FormatException catch (e, s) {
        final String preview = content.length > 500
            ? '${content.substring(0, 500)}...'
            : content;
        Logger.error(
          '[OpenAIService] TONL/JSON decode error. Content preview: $preview',
          e,
          s,
        );
        throw const OpenAIParsingException('invalid_format');
      } catch (e, s) {
        final String preview = content.length > 500
            ? '${content.substring(0, 500)}...'
            : content;
        Logger.error(
          '[OpenAIService] Parse error. Content preview: $preview',
          e,
          s,
        );
        throw const OpenAIParsingException('invalid_format');
      }

      // Validate recipes array
      if (!json.containsKey('recipes')) {
        Logger.error(
          '[OpenAIService] Invalid JSON structure - missing recipes. JSON keys: ${json.keys.toList()}',
        );
        throw const OpenAIParsingException('invalid_format');
      }

      final dynamic recipesJson = json['recipes'];
      if (recipesJson is! List) {
        Logger.error(
          '[OpenAIService] Invalid recipes format - not a list. Type: ${recipesJson.runtimeType}, Value: $recipesJson',
        );
        throw const OpenAIParsingException('invalid_format');
      }

      final List<dynamic> recipes = recipesJson;

      // Debug: Log the full JSON structure
      Logger.info('[OpenAIService] JSON structure keys: ${json.keys.toList()}');
      Logger.info(
        '[OpenAIService] Recipes type: ${recipesJson.runtimeType}, Length: ${recipes.length}',
      );

      // Log full content if recipes array is empty
      if (recipes.isEmpty) {
        Logger.error(
          '[OpenAIService] Recipes array is empty. Full JSON: $json',
        );
        Logger.error(
          '[OpenAIService] Full content preview (first 1000 chars): ${content.substring(0, content.length > 1000 ? 1000 : content.length)}',
        );
      } else {
        Logger.info(
          '[OpenAIService] Found ${recipes.length} recipes in response. First recipe preview: ${recipes.first.toString().substring(0, recipes.first.toString().length > 200 ? 200 : recipes.first.toString().length)}',
        );
      }

      // Parse each recipe with schema validation
      final List<RecipeSuggestion> result = <RecipeSuggestion>[];
      for (final Object? r in recipes) {
        try {
          final Map<String, dynamic>? recipeMap = r as Map<String, dynamic>?;
          if (recipeMap == null) {
            Logger.error('[OpenAIService] Null recipe map');
            continue;
          }

          // Schema validation - required fields
          if (!recipeMap.containsKey('title') ||
              recipeMap['title'] is! String) {
            Logger.error(
              '[OpenAIService] Invalid recipe - missing or invalid title: $recipeMap',
            );
            continue;
          }

          final String title = recipeMap['title'] as String;
          if (title.trim().isEmpty) {
            Logger.error('[OpenAIService] Empty title in recipe');
            continue;
          }

          // Parse ingredients (handle both TONL string format and JSON List)
          List<String> ingredients = <String>[];
          final dynamic ingredientsData = recipeMap['ingredients'];
          if (ingredientsData is List) {
            ingredients = ingredientsData
                .map<String>((dynamic e) {
                  if (e is String) {
                    return e.trim();
                  }
                  if (e is Map<String, dynamic>) {
                    return ((e['name'] as String?) ??
                            (e.values.first as String?) ??
                            e.toString())
                        .trim();
                  }
                  return e.toString().trim();
                })
                .where((String e) => e.isNotEmpty)
                .toList();
          } else if (ingredientsData is String) {
            // TONL format: parse comma-separated string like "[ing1,ing2,ing3]"
            final String cleaned = ingredientsData
                .replaceAll('[', '')
                .replaceAll(']', '')
                .trim();
            if (cleaned.isNotEmpty) {
              ingredients = cleaned
                  .split(',')
                  .map((String e) => e.trim())
                  .where((String e) => e.isNotEmpty)
                  .toList();
            }
          } else if (!recipeMap.containsKey('ingredients')) {
            Logger.error(
              '[OpenAIService] Invalid recipe - missing ingredients: $recipeMap',
            );
            continue;
          }

          // Validate that we have at least one ingredient
          if (ingredients.isEmpty) {
            Logger.error(
              '[OpenAIService] Invalid recipe - empty ingredients: $recipeMap',
            );
            continue;
          }

          // Parse steps (handle both TONL string format and JSON List)
          List<String> steps = <String>[];
          final dynamic stepsData = recipeMap['steps'];
          if (stepsData is List) {
            steps = stepsData
                .map<String>((dynamic e) {
                  if (e is String) {
                    return e.trim();
                  }
                  if (e is Map<String, dynamic>) {
                    return ((e['step'] as String?) ??
                            (e['text'] as String?) ??
                            (e.values.first as String?) ??
                            e.toString())
                        .trim();
                  }
                  return e.toString().trim();
                })
                .where((String e) => e.isNotEmpty)
                .toList();
          } else if (stepsData is String) {
            // TONL format: parse comma-separated string like "[step1,step2,step3]"
            final String cleaned = stepsData
                .replaceAll('[', '')
                .replaceAll(']', '')
                .trim();
            if (cleaned.isNotEmpty) {
              steps = cleaned
                  .split(',')
                  .map((String e) => e.trim())
                  .where((String e) => e.isNotEmpty)
                  .toList();
            }
          } else if (!recipeMap.containsKey('steps')) {
            Logger.error(
              '[OpenAIService] Invalid recipe - missing steps: $recipeMap',
            );
            continue;
          }

          // Validate that we have at least one step
          if (steps.isEmpty) {
            Logger.error(
              '[OpenAIService] Invalid recipe - empty steps: $recipeMap',
            );
            continue;
          }

          result.add(
            RecipeSuggestion(
              title: recipeMap['title'] as String,
              ingredients: ingredients,
              steps: steps,
              calories: (recipeMap['calories'] as num?)?.toInt(),
              durationMinutes: (recipeMap['durationMinutes'] as num?)?.toInt(),
              difficulty: recipeMap['difficulty'] as String?,
              imageUrl:
                  null, // Image will be fetched separately via ImageLookupService
              category: recipeMap['category'] as String?,
              fiber: (recipeMap['fiber'] as num?)?.toInt(),
            ),
          );
        } catch (e, s) {
          Logger.error(
            '[OpenAIService] Error parsing individual recipe: $r',
            e,
            s,
          );
          // Continue with next recipe instead of failing completely
          continue;
        }
      }

      if (result.isEmpty) {
        Logger.error(
          '[OpenAIService] No valid recipes parsed. Total recipes in response: ${recipes.length}. Parsed recipes array preview: ${recipes.length > 3 ? recipes.take(3).toString() : recipes.toString()}',
        );
        throw const OpenAIParsingException('empty_response');
      }

      Logger.info(
        '[OpenAIService] Successfully parsed ${result.length} recipes from ${recipes.length} total',
      );

      return result;
    } on OpenAIParsingException {
      rethrow;
    } on FormatException catch (e, s) {
      Logger.error('[OpenAIService] JSON format error', e, s);
      throw const OpenAIParsingException('invalid_format');
    } catch (e, s) {
      Logger.error('[OpenAIService] Unexpected error during parsing', e, s);
      throw const OpenAIParsingException('unknown');
    }
  }

  @override
  Future<String> categorizeItem(String itemName) async {
    final Response<dynamic> res = await _dio.post(
      '/chat/completions',
      options: Options(headers: _headers),
      data: <String, dynamic>{
        'model': 'gpt-4o-mini',
        'response_format': <String, String>{'type': 'json_object'},
        'messages': <Map<String, String>>[
          <String, String>{
            'role': 'system',
            'content':
                'Yanıt dili Türkçe olsun. Şu şemada JSON ver: '
                '{"category":"kategori_adı"}. Kategori: Süt Ürünleri, '
                'Sebze, Meyve, Et/Tavuk/Balık, Bakliyat, Tahıl, '
                'Baharat, İçecek, Diğer. Yalnızca JSON dön.',
          },
          <String, String>{
            'role': 'user',
            'content': 'Bu ürünü kategorize et: $itemName',
          },
        ],
      },
    );

    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    final List<dynamic> choices = data['choices'] as List<dynamic>;
    final Map<String, dynamic> message =
        (choices.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>;
    final String content = message['content'] as String;
    final Map<String, dynamic> json =
        jsonDecode(content) as Map<String, dynamic>;
    return (json['category'] as String?) ?? 'Diğer';
  }
}
