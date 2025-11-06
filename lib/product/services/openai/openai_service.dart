// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';

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
        'response_format': {'type': 'json_object'},
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{
            'role': 'system',
            'content':
                'Yanıt dili Türkçe olsun. Şu şemada JSON döndür: {"items":[{"name":"","unit":"","quantity":1}]}',
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
    return items
        .map(
          (dynamic e) => Ingredient(
            name: (e['name'] as String?)?.trim() ?? '',
            unit: (e['unit'] as String?)?.trim() ?? '',
            quantity: (e['quantity'] is num)
                ? (e['quantity'] as num).toDouble()
                : 1.0,
          ),
        )
        .toList();
  }

  @override
  Future<List<RecipeSuggestion>> suggestRecipes(
    List<Ingredient> pantry, {
    int servings = 2,
    int count = 6,
    String? query,
    List<String>? excludeTitles,
  }) async {
    final String pantryText = pantry
        .map(
          (Ingredient e) =>
              '${e.name}${e.quantity > 0 ? ' x${e.quantity}' : ''}${e.unit.isNotEmpty ? ' ${e.unit}' : ''}',
        )
        .join(', ');

    final Response<dynamic> res = await _dio.post(
      '/chat/completions',
      options: Options(headers: _headers),
      data: <String, dynamic>{
        'model': 'gpt-4o-mini',
        'response_format': {'type': 'json_object'},
        'messages': <Map<String, String>>[
          <String, String>{
            'role': 'system',
            'content':
                'Yanıt dili Türkçe olsun. Şu şemada JSON ver: {"recipes":[{"title":"","ingredients":[],"steps":[],"calories":0,"durationMinutes":0,"difficulty":"kolay","category":"kahvaltı","fiber":0}]}. Yalnızca JSON ver.',
          },
          <String, String>{
            'role': 'user',
            'content':
                'Dolap: [$pantryText]. En az $count tarif öner. Porsiyon: $servings kişilik. '
                '${query != null ? 'Arama: $query. ' : ''}'
                '${excludeTitles != null && excludeTitles.isNotEmpty ? 'Şu başlıkları tekrar etme: ${excludeTitles.join(', ')}. ' : ''}'
                'Gerekirse ekstra malzeme ekleyebilirsin. Her tarif için imageUrl alanına uygun, telifsiz bir görsel URL’i (ör. üretim değil, stok görsel) ekle. Yalnızca JSON dön.',
          },
        ],
      },
    );

    final Map<String, dynamic> data2 = res.data as Map<String, dynamic>;
    final List<dynamic> choices2 = data2['choices'] as List<dynamic>;
    final Map<String, dynamic> message2 =
        (choices2.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>;
    final String content = message2['content'] as String;
    final Map<String, dynamic> json =
        jsonDecode(content) as Map<String, dynamic>;
    final List<dynamic> recipes =
        (json['recipes'] as List<dynamic>?) ?? <dynamic>[];
    return recipes
        .map(
          (dynamic r) => RecipeSuggestion(
            title: (r['title'] as String?) ?? '',
            ingredients:
                ((r['ingredients'] as List?)?.cast<String>()) ?? <String>[],
            steps: ((r['steps'] as List?)?.cast<String>()) ?? <String>[],
            calories: (r['calories'] as num?)?.toInt(),
            durationMinutes: (r['durationMinutes'] as num?)?.toInt(),
            difficulty: r['difficulty'] as String?,
            imageUrl: r['imageUrl'] as String?,
            category: r['category'] as String?,
            fiber: (r['fiber'] as num?)?.toInt(),
          ),
        )
        .toList();
  }
}
