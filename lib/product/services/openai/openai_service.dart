// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:smartdolap/core/utils/logger.dart';
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
    print('[OpenAIService] suggestRecipes başladı');
    print('[OpenAIService] Pantry: ${pantry.length} malzeme');
    print('[OpenAIService] Servings: $servings, Count: $count');
    final String pantryText = pantry
        .map(
          (Ingredient e) =>
              '${e.name}'
              '${e.quantity > 0 ? ' x${e.quantity}' : ''}'
              '${e.unit.isNotEmpty ? ' ${e.unit}' : ''}',
        )
        .join(', ');

    print('[OpenAIService] API isteği gönderiliyor...');
    final DateTime startTime = DateTime.now();
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
                '{"recipes":[{"title":"","ingredients":[],"steps":[],'
                '"calories":0,"durationMinutes":0,"difficulty":"kolay",'
                '"category":"kahvaltı","fiber":0}]}. Yalnızca JSON ver.',
          },
          <String, String>{
            'role': 'user',
            'content':
                'Dolap: [$pantryText]. En az $count tarif öner. '
                'Porsiyon: $servings kişilik. '
                '${query != null ? 'Arama: $query. ' : ''}'
                '${excludeTitles != null && excludeTitles.isNotEmpty ? 'Şu '
                          'başlıkları tekrar etme: '
                          '${excludeTitles.join(', ')}. ' : ''}'
                'Gerekirse ekstra malzeme ekleyebilirsin. '
                'Her tarif için imageUrl alanına uygun, '
                'telifsiz bir görsel (ör. üretim değil, '
                'stok görsel) ekle. '
                'Yalnızca JSON dön.',
          },
        ],
      },
    );

    final DateTime endTime = DateTime.now();
    final Duration duration = endTime.difference(startTime);
    print(
      '[OpenAIService] API yanıtı geldi - Süre: ${duration.inSeconds} saniye',
    );

    try {
      // Parse response safely
      final Map<String, dynamic> data2 = res.data as Map<String, dynamic>;
      
      // Validate response structure
      if (!data2.containsKey('choices')) {
        Logger.error('[OpenAIService] Invalid response structure - missing choices');
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
        Logger.error('[OpenAIService] Invalid message structure - missing content');
        throw const OpenAIParsingException('invalid_format');
      }

      final String content = message2['content'] as String;
      
      if (content.isEmpty) {
        Logger.error('[OpenAIService] Empty content');
        throw const OpenAIParsingException('empty_response');
      }

      // Parse JSON safely
      Map<String, dynamic> json;
      try {
        json = jsonDecode(content) as Map<String, dynamic>;
      } on FormatException catch (e, s) {
        Logger.error('[OpenAIService] JSON decode error', e, s);
        throw const OpenAIParsingException('invalid_format');
      }

      // Validate recipes array
      if (!json.containsKey('recipes')) {
        Logger.error('[OpenAIService] Invalid JSON structure - missing recipes');
        throw const OpenAIParsingException('invalid_format');
      }

      final dynamic recipesJson = json['recipes'];
      if (recipesJson is! List) {
        Logger.error('[OpenAIService] Invalid recipes format - not a list');
        throw const OpenAIParsingException('invalid_format');
      }

      final List<dynamic> recipes = recipesJson;
      print('[OpenAIService] ${recipes.length} tarif parse ediliyor...');

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
          if (!recipeMap.containsKey('title') || recipeMap['title'] is! String) {
            Logger.error('[OpenAIService] Invalid recipe - missing or invalid title');
            continue;
          }

          if (!recipeMap.containsKey('ingredients') || recipeMap['ingredients'] is! List) {
            Logger.error('[OpenAIService] Invalid recipe - missing or invalid ingredients');
            continue;
          }

          if (!recipeMap.containsKey('steps') || recipeMap['steps'] is! List) {
            Logger.error('[OpenAIService] Invalid recipe - missing or invalid steps');
            continue;
          }

          // Parse ingredients
          final List<String> ingredients = (recipeMap['ingredients'] as List<dynamic>)
              .map<String>((dynamic e) {
                if (e is String) {
                  return e;
                }
                if (e is Map<String, dynamic>) {
                  return (e['name'] as String?) ??
                      (e.values.first as String?) ??
                      e.toString();
                }
                return e.toString();
              })
              .toList();

          // Parse steps
          final List<String> steps = (recipeMap['steps'] as List<dynamic>)
              .map<String>((dynamic e) {
                if (e is String) {
                  return e;
                }
                if (e is Map<String, dynamic>) {
                  return (e['step'] as String?) ??
                      (e['text'] as String?) ??
                      (e.values.first as String?) ??
                      e.toString();
                }
                return e.toString();
              })
              .toList();

          result.add(RecipeSuggestion(
            title: recipeMap['title'] as String,
            ingredients: ingredients,
            steps: steps,
            calories: (recipeMap['calories'] as num?)?.toInt(),
            durationMinutes: (recipeMap['durationMinutes'] as num?)?.toInt(),
            difficulty: recipeMap['difficulty'] as String?,
            imageUrl: recipeMap['imageUrl'] as String?,
            category: recipeMap['category'] as String?,
            fiber: (recipeMap['fiber'] as num?)?.toInt(),
          ));
        } catch (e) {
          Logger.error('[OpenAIService] Error parsing individual recipe', e);
          // Continue with next recipe instead of failing completely
          continue;
        }
      }

      if (result.isEmpty) {
        Logger.error('[OpenAIService] No valid recipes parsed');
        throw const OpenAIParsingException('empty_response');
      }

      print(
        '[OpenAIService] suggestRecipes tamamlandı - ${result.length} tarif döndürüldü',
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
