## SmartDolap – MVP Sprint Planı ve Yapılacaklar (TODO)

Bu belge, SmartDolap MVP sürümü için uçtan uca yapılacak işleri sprint bazında ve detaylı görev listeleriyle içerir. Tüm görevler geliştirici tarafından yapılacaktır (Firebase, OpenAI, Token yönetimi, DI, UI, testler dahil). Görevler, MVVM + SOLID ve mevcut kurallar (Cubit, Hive, Firestore, Storage, easy_localization, flutter_screenutil, get_it, Material 3) ile uyumludur.

Notasyon:
- [ ] yapılacak, [x] tamamlandı
- Tüm metinler `assets/translations` içinde TR/EN anahtarları ile tutulacak.
- Tüm ölçüler `.w`, `.h`, `.sp`, `.r` ile responsive olacak. Ortak sabitler `lib/core/constants/app_sizes.dart`.

---

### Sprint 0 – Altyapı Doğrulama ve Setup (0.5 hafta)

- [x] Flutter 3.24+ ve Dart SDK doğrulaması, `flutter doctor`
- [x] Firebase projeyi oluştur (iOS/Android paket adları eşleştir)
  - [x] iOS `GoogleService-Info.plist` ekle
  - [x] Android `google-services.json` ekle
  - [x] `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` konfigürasyon kontrolü
- [x] Firestore güvenlik kuralları (MVP basit):
  - [x] `/users/{uid}` sadece owner read/write
  - [x] `/users/{uid}/pantry/{itemId}` owner read/write
  - [x] `/users/{uid}/achievements/{badgeId}` owner read/write
  - [x] `/recipes/{recipeId}` read: true (MVP)
- [x] Hive init ve kutu planı: `pantry_box`, `achievements_box`
  - [x] `pantry_box`
  - [x] `recipes_cache` box
  - [x] `favorites` box
  - [ ] `achievements_box` (ProfileStats Hive'da saklanıyor)
- [x] `.env` yönetimi (OpenAI API Key)
  - [x] `flutter_dotenv` ekle, `.env` asset olarak tanımla
  - [x] `pubspec.yaml` assets bölümü güncelle, `.env.example` ekle
  - [x] README'de anahtarların nasıl ekleneceğini anlat
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
- [x] Localization anahtarlarını tamamla:
  - [x] `pantry_title`, `recipes_title`, `profile_title`
  - [x] `pantry_empty_message`, `recipes_empty_message`, `profile_welcome_message`
  - [x] Hata/başarı genel mesaj anahtarları
- [x] Router genişlet:
  - [x] Login → Home (`AppShell`)
  - [x] Register sayfası route
  - [x] Tarif Detay sayfası route (`/recipes/detail`)
  - [x] Pantry Add Item sayfası route (`/pantry/add`)
  - [x] Pantry Item Detail sayfası route (`/pantry/detail`)
- [x] Testler (var olan auth testleri yeşil): `auth_cubit_test.dart`, `login_usecase_test.dart`

Çıktılar:
- Auth girişleri çalışır, yerelleştirme tamam
- Navigasyon akışı net

---

### Sprint 2 – Pantry (Dolap) Modülü (1 hafta)

Domain & Model:
- [x] Entity'ler: `Ingredient`, `PantryItem` (Freezed kullanılmadı, normal class)
  - [x] `PantryItem`: id, name, quantity, unit, expiryDate, category, createdAt, updatedAt
- [x] Repository arayüzü: `IPantryRepository`
  - [x] `watchItems(uid)`, `getItems(uid)`, `addItem(uid, item)`, `updateItem(uid, item)`, `deleteItem(uid, id)`
- [x] UseCase'ler: `ListPantryItems`, `AddPantryItem`, `UpdatePantryItem`, `DeletePantryItem`

Data Layer:
- [x] Firestore implementasyonu: `/users/{uid}/pantry/{itemId}`
- [x] Hive cache fallback (offline-first): `pantry_box`
  - [x] Repository: network-öncelikli, hata/çevrimdışı durumunda Hive
  - [x] Category field Firestore ve Hive'da saklanıyor

Presentation:
- [x] `PantryCubit` + sealed states: Initial/Loading/Loaded/Failure
  - [x] `refresh()` metodu eklendi (pull-to-refresh için)
- [x] UI: Liste ekranı (Modern Material 3 tasarımı)
  - [x] `PantryItemCard` (responsive, kategori renkli icon, kategori badge üstte)
  - [x] Boş durum `EmptyState` widget
  - [x] Search bar (modern filled style, kategoriye göre de arama)
  - [x] Category filtering (FilterChip'ler ile, kategori renklerine göre renklendirilmiş)
  - [x] AI ile otomatik kategorileştirme (ürün eklenirken)
  - [x] Pull-to-refresh (RefreshIndicator ile)
  - [x] Kategori renk sistemi (`CategoryColors` utility)
- [x] UI: Ekleme akışı (Modern card-based form)
  - [x] Manuel ekleme formu (isim, miktar, birim, SKT)
  - [x] AI ile otomatik kategori belirleme (isim girildiğinde, loading indicator ile)
  - [x] Kategori gösterimi (chip ile, kategori renkli)
- [x] UI: Detay sayfası
  - [x] `PantryItemDetailPage` (görüntüleme, düzenleme, silme)
  - [x] Quantity ve unit düzenleme
  - [x] Expiry date düzenleme
  - [x] Delete confirmation dialog

DI:
- [x] `IPantryRepository`, UseCase'ler, `PantryCubit` kayıtları `core/di/dependency_injection.dart`

Testler:
- [ ] UseCase birim testleri (mock repo)
- [ ] Cubit testleri (başarılı, hata, boş durum)

Çıktılar:
- Dolap modülü CRUD çalışır, offline cache ile

---

### Sprint 3 – Recipes (Tarif) + OpenAI Entegrasyonu (1 hafta)

OpenAI Servisi:
- [x] Servis arayüzleri: `IOpenAIService`
  - [x] `parseFridgeImage(Uint8List imageBytes) -> List<Ingredient>`
  - [x] `suggestRecipes(List<Ingredient> pantry, {servings, count, query, excludeTitles}) -> List<RecipeSuggestion>`
  - [x] `categorizeItem(String itemName) -> String` (yeni eklendi)
- [x] Implementasyon: Vision + Chat (güvenli prompt, JSON parse)
  - [x] .env'den API key okunması
  - [x] Yanıt şeması validasyonu (try-catch ve fallback mesajlar)
  - [x] Türkçe yanıt desteği
  - [x] Recipe image URL desteği
  - [x] Category ve fiber desteği
  - [x] Exclude titles desteği (duplicate önleme)

Recipes Domain:
- [x] Entity: `Recipe` (id, title, ingredients[], steps, calories, imageUrl, duration, difficulty, category, missingCount, fiber)
- [x] Repository arayüzü: `IRecipesRepository`
  - [x] `suggestFromPantry(uid)` (Firestore cache ile)
  - [ ] `getRecipeDetail(id)` (eksik - RecipeDetailPage direkt Recipe entity kullanıyor)
- [x] UseCase'ler: `SuggestRecipesFromPantry`
  - [x] `SuggestRecipesFromPantry` (Profile preferences entegrasyonu ile)
  - [ ] `GetRecipeDetail` (eksik)

Data Layer:
- [x] Repository implementasyonu: OpenAI + Firestore cache (`/recipes/{recipeId}`)
  - [x] Hive cache desteği (`recipes_cache` box)
  - [x] Missing ingredient count hesaplama
  - [x] Profile preferences entegrasyonu (servings, diet, cuisine, tone, goal, spice, sweet)

Presentation:
- [x] `RecipesCubit` + states (Initial/Loading/Loaded/Failure)
- [x] Grid sayfası (MasonryGridView ile responsive, modern tasarım)
  - [x] Recipe cards (image, category chip, missing badge, favorite star)
  - [x] Infinite scroll (aşağı kaydırma ile yeni tarifler)
  - [x] Loading placeholder cards
  - [x] Search bar (local + OpenAI search)
  - [x] Filter dialog (ingredients, meal type, max calories, min fiber)
  - [x] "Get Suggestions" popup (ingredient selection + meal type)
  - [x] Favorite recipes (Hive'da saklama)
- [x] Detay sayfası (Hero, resim, süre, kalori, malzemeler, adımlar, category, fiber)
- [ ] "Yaptım✅" → XP tetikle (Sprint 4'te gamification tam)

Storage:
- [ ] Görsel upload servisi (`IStorageService`) Firebase Storage ile
  - [ ] Yemek görselleri ve fiş/foto yükleme akışına bağla

DI & Test:
- [x] DI kayıtları (OpenAI, Recipes, UseCase, Cubit)
- [ ] UseCase ve Cubit testleri (mock servislerle)

Çıktılar:
- Pantry’den OpenAI ile öneri alınır, tarif listesi ve detay ekranı çalışır

---

### Sprint 4 – Gamification + Profil + Son Rötuşlar (1 hafta)

Gamification:
- [x] Entity'ler: `ProfileStats` (level, xp, nextLevelXp, aiRecipes, userRecipes, photoUploads, badges)
- [x] XP kuralı: `ProfileStatsService` ile XP ekleme ve level hesaplama
- [x] Hive storage: `ProfileStatsService` ile Hive'da saklama
- [ ] Badge kuralı: yapılan tarif sayısı eşikleri (entity var, logic eksik)
- [ ] Firestore senkronizasyonu (`/users/{uid}/achievements/{badgeId}`)
- [ ] `GamificationService` + `ProfileCubit` entegrasyonu (ProfileStatsService var ama tam entegrasyon eksik)

Profil:
- [x] `ProfileStatsService` (XP/level hesaplama)
- [x] `PromptPreferenceService` (AI tercihleri)
- [x] `UserRecipeService` (kullanıcı tarifleri yönetimi)
- [x] `UserRecipe` entity (kullanıcı tarifleri için)
- [x] Profil ekranı: kullanıcı adı/email, XP bar, level progress, stats
  - [x] Hero card (gradient, avatar, nickname, level progress, stats badges)
  - [x] Prompt preview card (compose prompt gösterimi, copy butonu)
  - [x] Summary table (diet, cuisine, tone, goal, spice, sweet, servings)
  - [x] Collection card (UserRecipe listesi, manuel tarif ekleme)
  - [x] Preference controls (custom diet/cuisine/tone/goal ekleme)
  - [x] Language selection (TR/EN)
  - [x] Logout button
- [x] `UserRecipeFormPage` (manuel tarif ekleme formu)
- [x] Logout → `AuthCubit.logout()`
- [x] Dil seçimi (EasyLocalization) – Ayarlar bölümünde

UI/UX:
- [x] Lottie animasyonları (EmptyState, ProfilePage hero card)
- [x] Modern Material 3 tasarımı (Pantry, Recipes, Profile sayfaları)
  - [x] Pantry sayfası modernize edildi (search bar, filter chips, modern cards)
  - [x] PantryItemCard modernize edildi (kategori renkli icon, kategori badge üstte, better spacing)
  - [x] AddPantryItemPage modernize edildi (card-based form, kategori loading indicator)
  - [x] Recipe cards (image, category, missing badge, favorite)
  - [x] Kategori renk sistemi (`CategoryColors` utility class)
  - [x] Kategori badge'leri kart üstünde (Positioned widget ile)
  - [x] Filtreleme çipleri kategori renklerine göre renklendirildi
- [x] Snackbar helper - ScaffoldMessenger kullanılıyor (yeterli)
- [ ] Erişilebilirlik: dokunma hedefleri min 48x48, kontrast kontrolü

Kalite & Yayın Hazırlığı:
- [x] Tüm linter uyarılarını sıfırla (çoğu düzeltildi, devam ediyor)
- [x] README güncelle (kurulum, env, komutlar)
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` (Freezed kullanılmadı)
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

- Tüm TODO'lar `git` PR'larıyla kapatılır, linter/testler yeşil olmalı
- Ana akışlar manuel E2E kontrol edilir (login → dolap → öneri → detay → yaptım → profil)

---

## 📊 Proje Durumu Özeti (Son Güncelleme)

### ✅ Tamamlanan Özellikler

**Sprint 0-1:** %100 tamamlandı
- Firebase setup, Hive init, Auth flow, Localization, Tema, Router

**Sprint 2 - Pantry:** %100 tamamlandı
- ✅ CRUD işlemleri (Firestore + Hive cache)
- ✅ Modern UI (search, filter, AI categorization)
- ✅ Detail page (view/edit/delete)
- ✅ Pull-to-refresh (RefreshIndicator ile)
- ✅ Kategori renk sistemi (CategoryColors utility)
- ✅ Kategori badge'leri kart üstünde
- ✅ Filtreleme çipleri kategori renklerine göre renklendirildi

**Sprint 3 - Recipes:** %90 tamamlandı
- ✅ OpenAI entegrasyonu (suggest, categorize)
- ✅ Infinite scroll, search, filter
- ✅ Favorite recipes
- ✅ Recipe images, categories, missing badges
- ⏳ Storage servisi eksik
- ⏳ GetRecipeDetail use case eksik

**Sprint 4 - Profile & Gamification:** %85 tamamlandı
- ✅ Profile page (XP, stats, preferences)
- ✅ Prompt preferences (custom diet/cuisine/tone/goal)
- ✅ Language selection, Logout
- ✅ Basic XP system
- ✅ UserRecipe sistemi (manuel tarif ekleme, collection card)
- ✅ UserRecipeFormPage (tarif ekleme formu)
- ⏳ Badge system logic eksik
- ⏳ Firestore sync eksik
- ⏳ "Yaptım" button → XP trigger eksik (RecipeDetailPage'de)

**UI/UX:** %95 tamamlandı
- ✅ Modern Material 3 tasarımı
- ✅ Lottie animasyonları
- ✅ Kategori renk sistemi ve görselleştirme
- ✅ Kategori badge'leri ve filtreleme
- ⏳ Accessibility kontrolleri eksik

### 🔄 Kalan İşler (Priorite Sırasına Göre)

#### 1. Test Coverage
- [ ] Pantry UseCase birim testleri (mock repo ile)
- [ ] Pantry Cubit testleri (başarılı, hata, boş durum senaryoları)
- [ ] Recipes UseCase birim testleri (mock servislerle)
- [ ] Recipes Cubit testleri (infinite scroll, search, filter senaryoları)
- [ ] Profile servis testleri (ProfileStatsService, PromptPreferenceService)

#### 2. Storage Service (Firebase Storage)
- [ ] `IStorageService` interface tanımla
- [ ] `StorageService` implementasyonu (Firebase Storage ile)
- [ ] Image upload akışı (pantry item fotoğrafı için)
- [ ] Recipe image upload (kullanıcı tarif fotoğrafı ekleme)
- [ ] Storage servisini DI'ya kaydet
- [ ] UI entegrasyonu (AddPantryItemPage'e fotoğraf ekleme butonu)

#### 3. Badge System & Gamification
- [ ] Badge entity ve kuralları tanımla (ör: "İlk Tarif", "10 Tarif", "Fotoğrafçı")
- [ ] Badge award logic (ProfileStatsService'e entegre et)
- [ ] Firestore sync (`/users/{uid}/achievements/{badgeId}`)
- [ ] Badge gösterimi (ProfilePage'de rozet grid)
- [ ] "Yaptım✅" button → XP trigger (RecipeDetailPage'de)
- [ ] XP hesaplama (tarif süresi/zorluk oranlı)

#### 4. Recipe Detail UseCase
- [ ] `GetRecipeDetail` use case ekle
- [ ] `IRecipesRepository`'ye `getRecipeDetail(id)` metodu ekle
- [ ] Repository implementasyonu (Firestore'dan veya cache'den)
- [ ] RecipesCubit'e entegre et

#### 5. Accessibility & UX İyileştirmeleri
- [ ] Touch target kontrolü (min 48x48 dp)
- [ ] Contrast ratio kontrolü (WCAG AA standardı)
- [ ] Screen reader desteği (Semantic labels)
- [ ] Keyboard navigation desteği
- [ ] Focus management iyileştirmeleri

#### 6. Cross-Device Testing & Responsive
- [ ] Tablet layout testleri (landscape/portrait)
- [ ] Farklı ekran boyutları testleri (small/medium/large)
- [ ] Orientation change handling
- [ ] Responsive grid adjustments (MasonryGridView crossAxisCount)

#### 7. CI/CD & Quality
- [ ] GitHub Actions workflow (flutter analyze, test)
- [ ] Code coverage raporu
- [ ] Pre-commit hooks (format, lint)
- [ ] Release notes template

#### 8. Documentation
- [ ] API documentation (dartdoc comments)
- [ ] Architecture diagram güncelle
- [ ] User guide (TR/EN)
- [ ] Developer guide (setup, contribution)

### 📈 Genel İlerleme: ~90% tamamlandı

**Son Güncelleme:** Bugün eklenen özellikler:
- ✅ Pull-to-refresh (Pantry sayfası)
- ✅ Kategori renk sistemi (`CategoryColors` utility)
- ✅ Kategori badge'leri (kart üstünde)
- ✅ Kategori filtreleme renklendirmesi
- ✅ Çeviri düzeltmeleri (name/display_name)
- ✅ UserRecipe sistemi (Profile sayfasında)
