# SmartDolap

SmartDolap; Firebase, Hive ve OpenAI üzerine kurulu akıllı kiler (pantry) + tarif öneri asistanıdır. Uygulama MVVM, Cubit ve SOLID ilkelerine göre katmanlanır; Material 3, EasyLocalization ve ScreenUtil ile responsive bir deneyim sunar.

## Başlıca Özellikler
- Firebase Auth ile e‑posta/şifre tabanlı giriş ve kayıt akışı
- Firestore + Hive destekli çevrimdışı kiler yönetimi, manuel ürün ekleme
- OpenAI GPT‑4o Mini ile dolaptaki malzemelerden tarif önerileri, yerel cache
- TR/EN yerelleştirme, koyu/açık tema, responsive grid tabanlı tarif listesi
- Modüler DI (`get_it`) ve servis/repodan ayrılmış use-case yapısı

## Gereksinimler
- Flutter 3.24+ / Dart 3.8+
- Firebase projesi (iOS/Android paket adları eşleştirilmiş, `firebase_options.dart` üretilmiş)
- OpenAI API anahtarı
- Pexels API anahtarı (tarif görselleri için, ücretsiz)

## Kurulum
1. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
2. `.env` dosyası oluşturup API anahtarlarınızı tanımlayın:
   ```bash
   # .env dosyası oluşturun (proje root'unda)
   OPENAI_API_KEY=your_openai_api_key_here
   PEXELS_API_KEY=your_pexels_api_key_here
   ```
   > **Pexels API Key Alma:**
   > 1. [https://www.pexels.com/api/](https://www.pexels.com/api/) adresine gidin
   > 2. Ücretsiz hesap oluşturun (GitHub/Google ile giriş yapabilirsiniz)
   > 3. API anahtarınızı kopyalayın
   > 4. Ücretsiz limitler: Saatte 200, ayda 20,000 istek
   > 
   > `.env` dosyası `.gitignore` altında tutulur; build öncesi mevcut olmalıdır.
3. Firebase konfigürasyon dosyalarınızı platform dizinlerine ekleyin:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. (Opsiyonel) Hive kutularının cihazda açılabilmesi için uygulamayı en az bir kez debug modda çalıştırın.

## Dokümantasyon

Detaylı dokümantasyon için `/docs` klasörüne bakın:
- **Sprint Raporları:** `/docs/sprints/`
- **Backend Planı:** `/docs/backend/`
- **Arşiv:** `/docs/archive/`
- **Problem Takibi:** `/docs/PROBLEMS_TRACKER.md`
- **Çözülen Problemler:** `/status.md` (root dizin)
- **Yol Haritası:** `/docs/ROADMAP.md`

## Geliştirme Komutları
- Uygulamayı çalıştırma:
  ```bash
  flutter run
  ```
- Kod analizleri:
  ```bash
  flutter analyze
  ```
- Birim testleri:
  ```bash
  flutter test
  ```

## Ortam Değişkenleri
| Adı              | Açıklama                                    | Gerekli |
|------------------|---------------------------------------------|---------|
| `OPENAI_API_KEY` | OpenAI tarif üretimi için API anahtarı     | ✅ Evet  |
| `PEXELS_API_KEY` | Pexels yemek görselleri için API anahtarı  | ✅ Evet  |

`flutter_dotenv`, `.env` dosyasını asset olarak bundle ettiği için yayın derlemelerinden önce güncel anahtarın yer aldığı dosyanın bulunduğundan emin olun. Farklı ortamlara özel anahtarları CI/CD pipeline’ında kopyalayabilir veya yayın öncesi `dart-define` gibi alternatif mekanizmalarla enjeksiyon yapabilirsiniz.

## Mimari Notlar
- **Katmanlar:** `features/<module>` içinde domain/data/presentation ayrımı, ortak kodlar `lib/core` ve `lib/product` altında.
- **DI:** `lib/core/di/dependency_injection.dart` Hive/Firebase/servis kayıtlarını yönetir. Yeni servis eklerken burada factory/lazy singleton tanımlayın.
- **Yerelleştirme:** `assets/translations/` altında TR/EN json dosyaları bulunur; yeni anahtarları iki dilde de ekleyin.
- **Cache:** Tarifler `recipes_cache`, kiler verileri `pantry_box` Hive kutularında saklanır. Offline senaryolarda önce cache, ardından Firestore kullanılır.

Detaylı sprint planı ve kalan işler için `TODO.md` dosyasını inceleyebilirsiniz.
