# 📸 Pexels Görsel Entegrasyonu

SmartDolap, tarif görsellerini **Pexels API** kullanarak otomatik olarak bulup ekler.

## ✨ Özellikler

- ✅ Yüksek kaliteli, telif hakkı temiz yemek fotoğrafları
- ✅ OpenAI tarafından optimize edilmiş İngilizce arama terimleri
- ✅ Otomatik fallback: API yoksa placeholder icon gösterilir
- ✅ Akıllı önbellekleme (CachedNetworkImage ile)
- ✅ Ücretsiz: Saatte 200, ayda 20,000 istek

## 🚀 Kurulum

### 1. Pexels API Key Alma

1. [https://www.pexels.com/api/](https://www.pexels.com/api/) adresine gidin
2. **"Get Started"** butonuna tıklayın
3. GitHub veya Google hesabınızla giriş yapın
4. API Key'inizi kopyalayın

### 2. .env Dosyasını Yapılandırma

Proje root'unda `.env` dosyası oluşturun (yoksa):

```bash
# .env
OPENAI_API_KEY=sk-your-openai-key
PEXELS_API_KEY=your-pexels-api-key-here
```

⚠️ **Önemli:** `.env` dosyası `.gitignore`'da olmalı (zaten ekli)

### 3. Uygulamayı Çalıştırma

```bash
flutter clean
flutter pub get
flutter run
```

## 🔧 Teknik Detaylar

### Nasıl Çalışır?

1. **OpenAI Tarifler Üretir:**
   ```json
   {
     "title": "İmambayıldı",
     "imageSearchQuery": "stuffed eggplant turkish food high quality"
   }
   ```

2. **RecipeImageService Görseli Arar:**
   - OpenAI'den gelen `imageSearchQuery` kullanılır (İngilizce)
   - Pexels API'ye istek atılır
   - 5 sonuç arasından rastgele biri seçilir

3. **CachedImageWidget Gösterir:**
   - Görsel bulunduysa: Pexels URL'den yüklenir
   - Bulunamadıysa: Placeholder icon gösterilir
   - Tüm görseller otomatik cache'lenir

### Dosya Yapısı

```
lib/
├── core/
│   ├── di/
│   │   └── dependency_injection.dart    # Pexels DI setup
│   └── widgets/
│       └── cached_image_widget.dart     # Görsel widget
├── features/
│   └── recipes/
│       └── data/
│           └── services/
│               └── recipe_image_service.dart  # Ana görsel servisi
└── product/
    └── services/
        └── image_lookup_service.dart    # Pexels implementasyonu
```

### Dependency Injection

```dart
// lib/core/di/dependency_injection.dart

sl.registerLazySingleton<IImageLookupService>(
  () {
    final String? apiKey = dotenv.env['PEXELS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return const NoOpImageSearchService(); // Fallback
    }
    return PexelsImageSearchService(
      dio: sl<Dio>(instanceName: 'pexelsDio'),
      apiKey: apiKey,
    );
  },
);
```

### API Limitleri

| Plan    | Saat Başı | Aylık   | Fiyat    |
|---------|-----------|---------|----------|
| Free    | 200       | 20,000  | $0       |

**Öneri:** Üretim için rate limiting ekleyin:
```dart
// TODO: Implement rate limiting for production
if (_requestCount > 200) {
  return const NoOpImageSearchService();
}
```

## 🐛 Sorun Giderme

### Problem: Görseller Yüklenmiyor

**Çözüm 1:** API Key'i kontrol edin
```bash
# Terminal'de kontrol edin
grep PEXELS_API_KEY .env
```

**Çözüm 2:** Debug logları inceleyin
```bash
flutter run --verbose
# Şunu arayın: [PexelsImageSearchService]
```

**Çözüm 3:** Network erişimini kontrol edin
```dart
// Android: android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET"/>

// iOS: Zaten varsayılan açık
```

### Problem: "403 Forbidden" Hatası

**Sebep:** API key geçersiz veya limit aşıldı

**Çözüm:**
1. [Pexels Dashboard](https://www.pexels.com/api/documentation/) üzerinden key'i yenileyin
2. Günlük limiti kontrol edin
3. Farklı bir Pexels hesabı deneyin

### Problem: Görseller Çok Yavaş Yükleniyor

**Çözüm:** Görsel boyutunu küçültün
```dart
// lib/product/services/image_lookup_service.dart:195
final String? imageUrl = src?['medium'] as String?;
// Değiştir: 'medium' -> 'small' (daha hızlı)
```

## 📊 Monitoring

### Log Mesajları

```
[DI] Pexels image search enabled
[RecipeImageService] Searching for image: query="turkish breakfast menemen"
[PexelsImageSearchService] Selected random image (5 options): https://...
[RecipeImageService] Found image for "Menemen": https://...
```

### Başarısız Aramalar

```
[PexelsImageSearchService] No results for query: "xyz"
[RecipeImageService] No image found for "Tarif Adı" - will use placeholder
```

## 🔄 Alternatif Servisler

Pexels yerine başka servisleri aktif etmek için:

### Unsplash (Alternatif 1)
```dart
sl.registerLazySingleton<IImageLookupService>(
  () => UnsplashImageSearchService(
    dio: sl<Dio>(instanceName: 'unsplashDio'),
    accessKey: dotenv.env['UNSPLASH_ACCESS_KEY']!,
  ),
);
```

### Multi-Provider (Fallback Chain)
```dart
sl.registerLazySingleton<IImageLookupService>(
  () => MultiImageSearchService(
    services: [
      PexelsImageSearchService(...),
      UnsplashImageSearchService(...),
      GoogleImageSearchService(...),
    ],
  ),
);
```

## 📝 Notlar

- Görsel arama **sadece geçerli image URL yoksa** çalışır
- OpenAI bazen direkt URL döndürebilir (gelecekte)
- Tüm görseller `CachedNetworkImage` ile cache'lenir
- Offline modda önceden cache'lenmiş görseller gösterilir

## 🔗 Kaynaklar

- [Pexels API Documentation](https://www.pexels.com/api/documentation/)
- [Pexels API Guidelines](https://www.pexels.com/api/documentation/#guidelines)
- [CachedNetworkImage Package](https://pub.dev/packages/cached_network_image)

