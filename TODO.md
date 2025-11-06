## SmartDolap – MVP Sprint Planı ve Yapılacaklar (TODO)

Bu belge, SmartDolap MVP sürümü için uçtan uca yapılacak işleri sprint bazında ve detaylı görev listeleriyle içerir. Tüm görevler geliştirici tarafından yapılacaktır (Firebase, OpenAI, Token yönetimi, DI, UI, testler dahil). Görevler, MVVM + SOLID ve mevcut kurallar (Cubit, Hive, Firestore, Storage, easy_localization, flutter_screenutil, get_it, Material 3) ile uyumludur.

Notasyon:
- [ ] yapılacak, [x] tamamlandı
- Tüm metinler `assets/translations` içinde TR/EN anahtarları ile tutulacak.
- Tüm ölçüler `.w`, `.h`, `.sp`, `.r` ile responsive olacak. Ortak sabitler `lib/core/constants/app_sizes.dart`.

---

### Sprint 0 – Altyapı Doğrulama ve Setup (0.5 hafta)

- [ ] Flutter 3.24+ ve Dart SDK doğrulaması, `flutter doctor`
- [ ] Firebase projeyi oluştur (iOS/Android paket adları eşleştir)
  - [ ] iOS `GoogleService-Info.plist` ekle
  - [ ] Android `google-services.json` ekle
  - [ ] `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` konfigürasyon kontrolü
- [ ] Firestore güvenlik kuralları (MVP basit):
  - [ ] `/users/{uid}` sadece owner read/write
  - [ ] `/users/{uid}/pantry/{itemId}` owner read/write
  - [ ] `/users/{uid}/achievements/{badgeId}` owner read/write
  - [ ] `/recipes/{recipeId}` read: true (MVP)
- [ ] Hive init ve kutu planı: `pantry_box`, `achievements_box`
- [ ] `.env` yönetimi (OpenAI API Key)
  - [ ] `flutter_dotenv` ekle, `assets/.env` (ör: `OPENAI_API_KEY=`)
  - [ ] `pubspec.yaml` assets bölümü güncelle, örnek `.env.example` ekle
  - [ ] README’de anahtarların nasıl ekleneceğini anlat
- [ ] CI (opsiyonel): `flutter analyze` ve format kontrolü için basit GitHub Actions

Çıktılar:
- Firebase bağlı ve çalışır
- `.env` yüklü, OpenAI anahtarı gizli tutuluyor
- Firestore/Hive stratejisi net

---

### Sprint 1 – Auth + Localization + Tema + Router (1 hafta)

- [x] EasyLocalization kurulu, `main.dart` ile entegre
- [x] Light/Dark tema (Material 3 + Google Fonts)
- [x] ScreenUtilInit ve responsive altyapı
- [x] Auth flow temel: `LoginPage`, `AuthCubit`, `LoginUseCase`
- [ ] Localization anahtarlarını tamamla:
  - [ ] `pantry_title`, `recipes_title`, `profile_title`
  - [ ] `pantry_empty_message`, `recipes_empty_message`, `profile_welcome_message`
  - [ ] Hata/başarı genel mesaj anahtarları
- [ ] Router genişlet:
  - [ ] Login → Home (`AppShell`)
  - [ ] Tarif Detay sayfası route
  - [ ] Pantry Add Item sayfası route
- [ ] Testler (var olan auth testleri yeşil): `auth_cubit_test.dart`, `login_usecase_test.dart`

Çıktılar:
- Auth girişleri çalışır, yerelleştirme tamam
- Navigasyon akışı net

---

### Sprint 2 – Pantry (Dolap) Modülü (1 hafta)

Domain & Model:
- [ ] Entity’ler (Freezed): `Ingredient`, `PantryItem`
  - `PantryItem`: id, name, quantity, expiryDate, createdAt, updatedAt
- [ ] Repository arayüzü: `IPantryRepository`
  - [ ] `listItems(uid)`, `addItem(uid, item)`, `updateItem(uid, item)`, `deleteItem(uid, id)`
- [ ] UseCase’ler: `ListPantryItems`, `AddPantryItem`, `UpdatePantryItem`, `DeletePantryItem`

Data Layer:
- [ ] Firestore implementasyonu: `/users/{uid}/pantry/{itemId}`
- [ ] Hive cache fallback (offline-first): `pantry_box`
  - [ ] Hive adapter’ları kaydet
  - [ ] Repository: network-öncelikli, hata/çevrimdışı durumunda Hive

Presentation:
- [ ] `PantryCubit` + sealed states: Initial/Loading/Loaded/Failure
- [ ] UI: Liste ekranı
  - [ ] `PantryItemCard` (responsive, `product/widgets`)
  - [ ] Boş durum `EmptyState` widget
  - [ ] Pull-to-refresh
- [ ] UI: Ekleme akışı
  - [ ] Manuel ekleme formu (isim, miktar, SKT)
  - [ ] Fotoğraftan ekleme (Vision stub; Sprint 3’te gerçek entegrasyon)

DI:
- [ ] `IPantryRepository`, UseCase’ler, `PantryCubit` kayıtları `core/di/dependency_injection.dart`

Testler:
- [ ] UseCase birim testleri (mock repo)
- [ ] Cubit testleri (başarılı, hata, boş durum)

Çıktılar:
- Dolap modülü CRUD çalışır, offline cache ile

---

### Sprint 3 – Recipes (Tarif) + OpenAI Entegrasyonu (1 hafta)

OpenAI Servisi:
- [ ] Servis arayüzleri: `IOpenAIService`
  - [ ] `parseReceiptOrFridgeImage(Uint8List imageBytes) -> List<Ingredient>`
  - [ ] `suggestRecipes(List<Ingredient> pantry) -> List<Recipe>`
- [ ] Implementasyon: Vision + Chat (güvenli prompt, JSON parse)
  - [ ] .env’den API key okunması
  - [ ] Yanıt şeması validasyonu (try-catch ve fallback mesajlar)

Recipes Domain:
- [ ] Entity: `Recipe` (id, title, ingredients[], steps, calories, imageUrl, duration, difficulty)
- [ ] Repository arayüzü: `IRecipesRepository`
  - [ ] `suggestFromPantry(uid)`, `getRecipeDetail(id)`
- [ ] UseCase’ler: `SuggestRecipesFromPantry`, `GetRecipeDetail`

Data Layer:
- [ ] Repository implementasyonu: OpenAI + Firestore cache (`/recipes/{recipeId}`)

Presentation:
- [ ] `RecipesCubit` + states
- [ ] Grid sayfası (zaten responsive): gerçek veriyle bağla
- [ ] Detay sayfası (Hero, resim, süre, kalori, malzemeler, adımlar)
- [ ] “Yaptım✅” → XP tetikle (Sprint 4’te gamification tam)

Storage:
- [ ] Görsel upload servisi (`IStorageService`) Firebase Storage ile
  - [ ] Yemek görselleri ve fiş/foto yükleme akışına bağla

DI & Test:
- [ ] DI kayıtları (OpenAI, Recipes, Storage, UseCase, Cubit)
- [ ] UseCase ve Cubit testleri (mock servislerle)

Çıktılar:
- Pantry’den OpenAI ile öneri alınır, tarif listesi ve detay ekranı çalışır

---

### Sprint 4 – Gamification + Profil + Son Rötuşlar (1 hafta)

Gamification:
- [ ] Entity’ler: `XPEvent`, `Badge`
- [ ] XP kuralı: tarif süresi/zorluk oranlı
- [ ] Badge kuralı: yapılan tarif sayısı eşikleri
- [ ] Hive + Firestore senkronizasyonu (`/users/{uid}/achievements/{badgeId}`)
- [ ] `GamificationService` + `ProfileCubit` entegrasyonu

Profil:
- [ ] `ProfileCubit` (kullanıcı bilgisi, XP, rozet listesi)
- [ ] Profil ekranı: kullanıcı adı/email, XP bar, rozetler
- [ ] Logout → `AuthCubit.logout()`
- [ ] Dil seçimi (EasyLocalization) v2 – Ayarlar bölümü (opsiyonel)

UI/UX:
- [ ] Lottie animasyonları (yüklemeler, başarılar)
- [ ] Snackbar yerine `context.showSnackBar()` helper (core/utils)
- [ ] Erişilebilirlik: dokunma hedefleri min 48x48, kontrast kontrolü

Kalite & Yayın Hazırlığı:
- [ ] Tüm linter uyarılarını sıfırla
- [ ] README güncelle (kurulum, env, komutlar)
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Çapraz cihaz testleri (telefon/tablet/landscape)

Çıktılar:
- XP/rozet sistemi temel haliyle aktif, profil akışı tamam

---

### Ek Teknik Notlar ve Kurallar

- SOLID: Kullanım alanları (UseCase) arayüzlere bağımlı, implementasyonlar DI ile enjekte edilir.
- Error handling: Tüm async işlemler try-catch; `AuthFailure`, `RepositoryFailure` gibi sealed failure tipleri.
- Test stratejisi: UseCase ve Cubit bazlı birim testleri; UI widget testleri kritik akışlar için.
- Güvenlik: OpenAI key sadece runtime’da `.env` üzerinden okunmalı; depo dışına çıkar.
- Performans: Liste ekranlarında `const` widget kullanımı, `BlocConsumer` ile minimal rebuild.
- Responsive: Tüm padding/font/icon boyutları `AppSizes` üzerinden.

---

### Sprint Bazlı Takvim (Özet)

- Sprint 0 (0.5 hafta): Setup & konfigürasyon
- Sprint 1 (1 hafta): Auth, Localization, Tema, Router
- Sprint 2 (1 hafta): Pantry modülü (CRUD + offline)
- Sprint 3 (1 hafta): OpenAI + Recipes, Storage
- Sprint 4 (1 hafta): Gamification + Profil + kalite

Toplam: ~4.5 hafta (MVP)

---

### İzleme ve Tamamlama Kriterleri

- Tüm TODO’lar `git` PR’larıyla kapatılır, linter/testler yeşil olmalı
- Ana akışlar manuel E2E kontrol edilir (login → dolap → öneri → detay → yaptım → profil)


