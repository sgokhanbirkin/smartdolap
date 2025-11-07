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

**Core MVP Sprints:**
- Sprint 0 (0.5 hafta): Setup & konfigürasyon
- Sprint 1 (1 hafta): Auth, Localization, Tema, Router
- Sprint 2 (1 hafta): Pantry modülü (CRUD + offline)
- Sprint 3 (1 hafta): OpenAI + Recipes, Storage
- Sprint 4 (1 hafta): Gamification + Profil + kalite

**UI/UX Enhancement Sprints:**
- Sprint 5 (0.5 hafta): Pantry UI/UX Enhancements
- Sprint 6 (0.5 hafta): Recipes UI/UX Enhancements
- Sprint 7 (0.5 hafta): Profile & General UI/UX Enhancements
- Sprint 8 (0.5 hafta): Advanced Features & Polish

**Toplam MVP Süresi:** ~4.5 hafta
**Toplam UI/UX Enhancement Süresi:** ~2 hafta
**Toplam Proje Süresi:** ~6.5 hafta

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
- ✅ **Test Coverage: UseCase (11 test) + Cubit (8 test) = 19 test ✅**

**Sprint 3 - Recipes:** %98 tamamlandı ✅
- ✅ OpenAI entegrasyonu (suggest, categorize)
- ✅ Infinite scroll, search, filter
- ✅ Favorite recipes
- ✅ Recipe images, categories, missing badges
- ✅ Shimmer loading animasyonu
- ✅ Resim URL düzeltmeleri (ImageLookupService)
- ✅ Storage Service entegrasyonu (RecipeDetailPage'de "Yaptım" butonu)
- ✅ **Test Coverage: UseCase (4 test) + Cubit (5 test) = 9 test ✅**
- ✅ GetRecipeDetail use case eklendi

**Sprint 4 - Profile & Gamification:** %85 tamamlandı
- ✅ Profile page (XP, stats, preferences)
- ✅ Prompt preferences (custom diet/cuisine/tone/goal)
- ✅ Language selection, Logout
- ✅ Basic XP system
- ✅ UserRecipe sistemi (manuel tarif ekleme, collection card)
- ✅ UserRecipeFormPage (tarif ekleme formu)
- ✅ **Test Coverage: ProfileStatsService (8 test) + PromptPreferenceService (5 test) = 13 test ✅**
- ✅ "Yaptım" button → XP trigger (RecipeDetailPage'de zaten implement edilmiş)
- ⏳ Badge system logic eksik
- ⏳ Firestore sync eksik

**UI/UX:** %95 tamamlandı
- ✅ Modern Material 3 tasarımı
- ✅ Lottie animasyonları
- ✅ Kategori renk sistemi ve görselleştirme
- ✅ Kategori badge'leri ve filtreleme
- ⏳ Accessibility kontrolleri eksik

### 🔄 Kalan İşler (Priorite Sırasına Göre)

#### 1. Test Coverage ✅ TAMAMLANDI
- [x] Pantry UseCase birim testleri (mock repo ile) - 4 dosya, 11 test
- [x] Pantry Cubit testleri (başarılı, hata, boş durum senaryoları) - 1 dosya, 8 test
- [x] Recipes UseCase birim testleri (mock servislerle) - 1 dosya, 4 test
- [x] Recipes Cubit testleri (infinite scroll, search, filter senaryoları) - 1 dosya, 5 test
- [x] Profile servis testleri (ProfileStatsService, PromptPreferenceService) - 2 dosya, 13 test

**Toplam Test Sayısı: 41 test, hepsi geçti ✅**

#### 2. Storage Service (Firebase Storage) ✅ TAMAMLANDI
- [x] `IStorageService` interface tanımla
- [x] `StorageService` implementasyonu (Firebase Storage ile)
- [x] Recipe image upload (kullanıcı tarif fotoğrafı ekleme) - RecipeDetailPage'de entegre edildi
- [x] Storage servisini DI'ya kaydet
- [ ] Image upload akışı (pantry item fotoğrafı için) - UI entegrasyonu eksik
- [ ] UI entegrasyonu (AddPantryItemPage'e fotoğraf ekleme butonu)

#### 3. Badge System & Gamification
- [ ] Badge entity ve kuralları tanımla (ör: "İlk Tarif", "10 Tarif", "Fotoğrafçı")
- [ ] Badge award logic (ProfileStatsService'e entegre et)
- [ ] Firestore sync (`/users/{uid}/achievements/{badgeId}`)
- [ ] Badge gösterimi (ProfilePage'de rozet grid)
- ✅ "Yaptım✅" button → XP trigger (RecipeDetailPage'de zaten var)
- [ ] XP hesaplama (tarif süresi/zorluk oranlı) - **NOT: Şu anda sabit XP (50 base, +25 fotoğraflı)**

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

### 📈 Genel İlerleme: ~92% tamamlandı (Core Features), UI/UX Enhancements planlandı

**Son Güncelleme:** Bugün eklenen özellikler:
- ✅ Pull-to-refresh (Pantry sayfası)
- ✅ Kategori renk sistemi (`CategoryColors` utility)
- ✅ Kategori badge'leri (kart üstünde)
- ✅ Kategori filtreleme renklendirmesi
- ✅ Çeviri düzeltmeleri (name/display_name)
- ✅ UserRecipe sistemi (Profile sayfasında)
- ✅ Shimmer loading animasyonu (Recipes sayfası)
- ✅ Resim URL düzeltmeleri (ImageLookupService entegrasyonu)
- ✅ Recipe Detail "Yaptım" butonu UI iyileştirmesi
- ✅ **Test Coverage tamamlandı (41 test, hepsi geçti)**
- ✅ **Storage Service tamamlandı ve RecipeDetailPage'e entegre edildi**
- ✅ **UI/UX Enhancement sprintleri planlandı (Sprint 5-8)**

---

### Sprint 5 – UI/UX Enhancements: Pantry Module (0.5 hafta)

**Hedef:** Pantry modülünde kullanıcı deneyimini iyileştirmek ve modern etkileşimler eklemek.

**Pantry Sayfası İyileştirmeleri:**
- [ ] **Swipe-to-Delete:** Ürün kartlarına sağa kaydırma ile silme özelliği
  - [ ] `Dismissible` widget entegrasyonu
  - [ ] Silme animasyonu ve geri alma (undo) özelliği
  - [ ] Haptic feedback (vibration) ekleme
- [ ] **Kamera ile Ürün Ekleme:** Fotoğrafla ürün ekleme akışı
  - [ ] `AddPantryItemPage`'e kamera butonu ekleme
  - [ ] OpenAI Vision API ile fotoğraftan ürün tanıma
  - [ ] Fotoğrafı Firebase Storage'a yükleme (`StorageService` kullanarak)
  - [ ] Loading state ve hata yönetimi
- [ ] **Son Kullanma Tarihi Bildirimleri:** Yaklaşan SKT için bildirim sistemi
  - [ ] Local notification servisi kurulumu (`flutter_local_notifications`)
  - [ ] SKT kontrolü (3 gün, 1 gün, geçmiş)
  - [ ] Bildirim zamanlama ve gösterimi
  - [ ] Bildirim ayarları (Profile sayfasında toggle)

**Pantry Item Card İyileştirmeleri:**
- [ ] **Hover/Tap Feedback:** Daha belirgin dokunma geri bildirimi
  - [ ] Ripple effect iyileştirmesi
  - [ ] Scale animation on tap
- [ ] **Quick Actions:** Kart üzerinde hızlı aksiyonlar
  - [ ] Miktar artırma/azaltma butonları (inline)
  - [ ] SKT düzenleme quick action

**Çıktılar:**
- Pantry modülünde daha akıcı ve modern kullanıcı deneyimi
- Fotoğrafla ürün ekleme özelliği aktif
- SKT bildirimleri çalışır durumda

---

### Sprint 6 – UI/UX Enhancements: Recipes Module (0.5 hafta)

**Hedef:** Recipes modülünde görselleştirme ve navigasyon iyileştirmeleri.

**Recipes Sayfası İyileştirmeleri:**
- [ ] **Favori Tarifler Rafı İyileştirmesi:**
  - [ ] "Tümünü Gör" butonu ekleme (favori tarifler sayfasına yönlendirme)
  - [ ] Favori rafında boş durum mesajı iyileştirmesi
  - [ ] Favori sayısı badge'i
- [ ] **Tarif Kartları Görselleştirme:**
  - [ ] Hazırlık süresi badge'i (duration varsa)
  - [ ] Zorluk seviyesi badge'i (difficulty varsa)
  - [ ] Kalori bilgisi görselleştirmesi (kalori çubuğu veya badge)
  - [ ] Kart hover/press animasyonları
- [ ] **Tarif Detay Sayfası İyileştirmeleri:**
  - [ ] Adımlar için ilerleme göstergesi (progress bar)
  - [ ] Adım tamamlama checkbox'ları (interaktif)
  - [ ] Malzeme listesi için checkbox'lar (dolapta var/yok kontrolü)
  - [ ] Paylaş butonu (share functionality)
  - [ ] Print butonu (tarifi yazdırma)

**Recipes Filter İyileştirmeleri:**
- [ ] Filter chip'lerde aktif filtre sayısı badge'i
- [ ] Filter reset butonu
- [ ] Filter geçmişi (son kullanılan filtreler)

**Çıktılar:**
- Recipes sayfasında daha zengin görselleştirme
- Tarif detay sayfasında daha interaktif deneyim
- Favori tarifler için özel sayfa

---

### Sprint 7 – UI/UX Enhancements: Profile & General (0.5 hafta)

**Hedef:** Profile modülü ve genel uygulama deneyimini iyileştirmek.

**Profile Sayfası İyileştirmeleri:**
- [ ] **XP Çubuğu Animasyonu:**
  - [ ] Level up animasyonu (Lottie veya custom animation)
  - [ ] XP kazanıldığında animasyonlu artış
  - [ ] Level up bildirimi (dialog veya snackbar)
- [ ] **Badge Koleksiyonu Görselleştirmesi:**
  - [ ] Badge grid layout (MasonryGridView veya GridView)
  - [ ] Badge kartları (icon, isim, açıklama, kazanma tarihi)
  - [ ] Kilitli badge'ler için blur effect
  - [ ] Badge detay sayfası (badge'e tıklanınca)
- [ ] **Yapılan Tarifler Koleksiyonu:**
  - [ ] Filtreleme (kategori, tarih, fotoğraflı/fotoğrafsız)
  - [ ] Sıralama (tarih, kategori, alfabetik)
  - [ ] Grid/List görünüm toggle
  - [ ] Tarif detay sayfasına navigasyon

**Genel UI/UX İyileştirmeleri:**
- [ ] **Dark Mode Toggle:**
  - [ ] Profile sayfasına dark mode toggle butonu
  - [ ] Sistem temasına göre otomatik geçiş seçeneği
  - [ ] Tema değişim animasyonu
- [ ] **Pull-to-Refresh İyileştirmesi:**
  - [ ] Lottie animasyonu ile custom refresh indicator
  - [ ] Haptic feedback ekleme
- [ ] **Empty State İyileştirmeleri:**
  - [ ] Daha fazla Lottie animasyonu
  - [ ] Rehberlik mesajları ve aksiyon butonları
  - [ ] Empty state'lerde "Nasıl başlarım?" rehberi

**Çıktılar:**
- Profile sayfasında gamification öğeleri daha görsel
- Dark mode desteği aktif
- Genel uygulama deneyimi daha akıcı ve rehberlik edici

---

### Sprint 8 – Advanced Features & Polish (0.5 hafta)

**Hedef:** İleri seviye özellikler ve son rötuşlar.

**Gelişmiş Özellikler:**
- [ ] **Tarif Paylaşma:**
  - [ ] Tarif detay sayfasında paylaş butonu
  - [ ] Deep link desteği (`smartdolap://recipe/{id}`)
  - [ ] Paylaşım formatı (text, image, link)
- [ ] **Tarif Yazdırma:**
  - [ ] Print functionality (flutter printing paketi)
  - [ ] PDF oluşturma ve paylaşma
- [ ] **Offline Mode İyileştirmeleri:**
  - [ ] Offline indicator badge
  - [ ] Offline modda çalışan özellikler gösterimi
  - [ ] Sync durumu göstergesi

**Performans İyileştirmeleri:**
- [ ] Image caching iyileştirmesi (`cached_network_image` paketi)
- [ ] List lazy loading optimizasyonu
- [ ] Build optimizasyonları (`const` widget kullanımı artırma)

**Çıktılar:**
- Uygulama daha performanslı ve kullanıcı dostu
- Paylaşma ve yazdırma özellikleri aktif

---

### 📅 UI/UX Sprint Takvimi

- Sprint 5 (0.5 hafta): Pantry UI/UX Enhancements
- Sprint 6 (0.5 hafta): Recipes UI/UX Enhancements
- Sprint 7 (0.5 hafta): Profile & General UI/UX Enhancements
- Sprint 8 (0.5 hafta): Advanced Features & Polish

**Toplam UI/UX Sprint Süresi:** ~2 hafta

---

## 🔍 Eksikler ve Geliştirme Alanları (Detaylı Analiz)

### ⚠️ Kritik Eksikler (Yüksek Öncelik)

#### 1. Sprint 6 - Filter Improvements (Tamamlandı ✅)
- [x] Filter dialog ve mantığı (mevcut)
- [x] **Filter chip'lerde aktif filtre sayısı badge'i** (Filter icon yanında badge eklendi)
- [x] **Filter reset butonu** (Filter dialog'da mevcut)
- [ ] **Filter geçmişi** (son kullanılan filtreleri kaydet ve hızlı erişim) - Düşük öncelik
- [ ] Filter state persistence (Hive'da sakla, uygulama açılışında geri yükle) - Düşük öncelik

#### 2. Badge System & Gamification Logic
- [ ] **Badge entity tanımla** (`Badge` class: id, name, description, icon, unlockCondition, unlockedAt)
- [ ] **Badge kuralları** (ör: "İlk Tarif", "10 Tarif", "Fotoğrafçı", "Hızlı Aşçı")
- [ ] **Badge award logic** (`ProfileStatsService`'e entegre et)
- [ ] **Firestore sync** (`/users/{uid}/achievements/{badgeId}`)
- [ ] **Badge gösterimi** (ProfilePage'de rozet grid, kilitli badge'ler blur)
- [ ] **Badge detay sayfası** (badge'e tıklanınca açıklama ve kazanma tarihi)

#### 3. Recipe Detail UseCase & Repository (Tamamlandı ✅)
- [x] **`GetRecipeDetail` use case** eklendi
- [x] **`IRecipesRepository.getRecipeDetail(id)`** metodu eklendi
- [x] **Repository implementasyonu** (Firestore'dan okuma)
- [ ] **RecipesCubit'e entegre et** (RecipeDetailPage'de use case kullan) - Opsiyonel (şu anda direkt Recipe entity kullanılıyor)

#### 4. Favorites Page (Ayrı Sayfa) (Tamamlandı ✅)
- [x] **Favorites sayfası oluştur** (`favorites_page.dart`)
- [x] **Route ekle** (`/recipes/favorites`)
- [ ] **Grid/List görünüm toggle** - Düşük öncelik
- [ ] **Filtreleme** (kategori, tarih) - Düşük öncelik
- [ ] **Sıralama** (tarih, alfabetik) - Düşük öncelik
- [x] **"Tümünü Gör" butonu** RecipesPage'den bu sayfaya yönlendirme

### 🚀 Önemli Geliştirmeler (Orta Öncelik)

#### 5. Deep Linking & Navigation
- [ ] **Deep link desteği** (`smartdolap://recipe/{id}`, `smartdolap://pantry/{itemId}`)
- [ ] **`go_router` veya `uni_links` paketi** entegrasyonu
- [ ] **Deep link handler** (AppRouter'a ekle)
- [ ] **Share functionality** (RecipeDetailPage'de zaten var, deep link ekle)

#### 6. Image Caching & Performance
- [ ] **`cached_network_image` paketi** ekle ve entegre et
- [ ] **RecipeCard ve RecipeDetailPage**'de `CachedNetworkImage` kullan
- [ ] **Image placeholder** iyileştirmesi (Lottie animasyonu)
- [ ] **Image error handling** iyileştirmesi (retry butonu)
- [ ] **Lazy loading optimizasyonu** (ListView.builder kullanımı kontrolü)

#### 7. Dark Mode Toggle
- [ ] **Profile sayfasına dark mode toggle** butonu ekle
- [ ] **Sistem temasına göre otomatik geçiş** seçeneği
- [ ] **Tema değişim animasyonu** (smooth transition)
- [ ] **Tema tercihini Hive'da sakla** (ProfileStatsService'e ekle)

#### 8. Offline Mode & Sync
- [ ] **Offline indicator badge** (AppBar'da veya floating badge)
- [ ] **Sync durumu göstergesi** (ProfilePage'de sync butonu)
- [ ] **Offline modda çalışan özellikler** gösterimi (Hive cache kullanımı)
- [ ] **Sync conflict resolution** (Firestore ve Hive arasında)

#### 9. User Recipe Collection Enhancements
- [ ] **Filtreleme** (kategori, tarih, fotoğraflı/fotoğrafsız)
- [ ] **Sıralama** (tarih, kategori, alfabetik)
- [ ] **Grid/List görünüm toggle**
- [ ] **Tarif detay sayfasına navigasyon** (UserRecipe'den RecipeDetailPage'e)

#### 10. XP System Improvements
- [ ] **Tarif süresi/zorluk oranlı XP hesaplama** (şu anda sabit: 50 base, +25 fotoğraflı)
- [ ] **XP formülü:** `baseXP + (durationBonus) + (difficultyBonus) + (photoBonus)`
- [ ] **Level up animasyonu** (Lottie veya custom animation)
- [ ] **Level up bildirimi** (dialog veya snackbar)

### 🎨 UI/UX İyileştirmeleri (Düşük Öncelik)

#### 11. Accessibility (Erişilebilirlik)
- [ ] **Touch target kontrolü** (min 48x48 dp, tüm butonlar)
- [ ] **Contrast ratio kontrolü** (WCAG AA standardı)
- [ ] **Screen reader desteği** (Semantic labels, `Semantics` widget)
- [ ] **Keyboard navigation** desteği (focus management)
- [ ] **Accessibility testleri** (widget testlerinde)

#### 12. Empty State İyileştirmeleri
- [ ] **Daha fazla Lottie animasyonu** (her empty state için özel)
- [ ] **Rehberlik mesajları** ve aksiyon butonları
- [ ] **"Nasıl başlarım?" rehberi** (onboarding flow)

#### 13. Pull-to-Refresh İyileştirmesi
- [ ] **Lottie animasyonu** ile custom refresh indicator
- [ ] **Haptic feedback** ekleme (zaten var, iyileştirilebilir)

### 🔧 Teknik İyileştirmeler

#### 14. Error Handling & Retry
- [ ] **Network error handling** iyileştirmesi (retry butonu)
- [ ] **OpenAI API error handling** (rate limit, timeout)
- [ ] **Firestore error handling** (permission denied, network error)
- [ ] **Global error handler** (ErrorWidget, error boundary)

#### 15. Build Optimizations
- [ ] **`const` widget kullanımı** artırma (tüm statik widget'lar)
- [ ] **Build method optimizasyonu** (extract widgets, use builders)
- [ ] **Memory leak kontrolü** (dispose metodları, stream subscriptions)

#### 16. CI/CD & Quality
- [ ] **GitHub Actions workflow** (`flutter analyze`, `flutter test`)
- [ ] **Code coverage raporu** (coverage package)
- [ ] **Pre-commit hooks** (format, lint)
- [ ] **Release notes template**

#### 17. Documentation
- [ ] **API documentation** (dartdoc comments, tüm public API'ler)
- [ ] **Architecture diagram** güncelle (MVVM + SOLID)
- [ ] **User guide** (TR/EN, screenshot'lar ile)
- [ ] **Developer guide** (setup, contribution, coding standards)

### 📱 Platform-Specific Features

#### 18. iOS Specific
- [ ] **App Store metadata** (screenshots, description)
- [ ] **iOS notification permissions** (zaten var, test et)
- [ ] **iOS deep linking** (Universal Links)

#### 19. Android Specific
- [ ] **Play Store metadata** (screenshots, description)
- [ ] **Android notification permissions** (zaten var, test et)
- [ ] **Android deep linking** (App Links)

### 🧪 Test Coverage Expansion

#### 20. Integration Tests
- [ ] **E2E testler** (login → pantry → recipe → detail → "Yaptım")
- [ ] **Widget testleri** (kritik widget'lar için)
- [ ] **Repository testleri** (Firestore mock ile)

#### 21. Performance Tests
- [ ] **Memory profiling** (DevTools ile)
- [ ] **Performance profiling** (frame rate, build time)
- [ ] **Network profiling** (API call optimization)

---

## 📊 Güncel Durum Özeti

### ✅ Tamamlanan Sprintler
- **Sprint 0-1:** %100 ✅
- **Sprint 2 (Pantry):** %100 ✅
- **Sprint 3 (Recipes):** %98 ✅ (GetRecipeDetail eklendi)
- **Sprint 4 (Profile):** %85 ✅ (Badge system eksik)
- **Sprint 5 (Pantry UI/UX):** %100 ✅
- **Sprint 6 (Recipes UI/UX):** %90 ✅ (Filter improvements tamamlandı)

### ⏳ Kalan İşler (Öncelik Sırasına Göre)

**Yüksek Öncelik (1-2 hafta):**
1. ✅ Filter Improvements (Sprint 6 tamamlandı)
2. ✅ Recipe Detail UseCase (tamamlandı)
3. ✅ Favorites Page (tamamlandı)
4. Badge System & Gamification Logic

**Orta Öncelik (2-3 hafta):**
5. Deep Linking
6. Image Caching
7. Dark Mode Toggle
8. Offline Mode Indicators
9. User Recipe Collection Enhancements
10. XP System Improvements

**Düşük Öncelik (3-4 hafta):**
11. Accessibility
12. Empty State İyileştirmeleri
13. Pull-to-Refresh İyileştirmesi
14. Error Handling & Retry
15. Build Optimizations
16. CI/CD & Quality
17. Documentation

**Genel İlerleme:** ~88% tamamlandı (Core Features), UI/UX Enhancements %80 tamamlandı

**Son Güncelleme:** Bugün eklenen özellikler:
- ✅ Recipe Cards badge'leri (duration, calories, difficulty)
- ✅ Recipe Detail progress indicators ve checkbox'lar
- ✅ Share ve Print functionality
- ✅ Custom animations entegrasyonu

---

## 🔧 SOLID Prensipleri Refactoring Görevleri

### 📊 Sayfa Dosyaları Analizi (Satır Sayıları)

**Hedef:** Tüm sayfa dosyaları maksimum 300 satır olmalı ve SOLID prensiplerine uygun olmalı (Single Responsibility, widget'lara bölünmeli).

**Mevcut Durum:**
- ✅ **RecipesPage** - 441 satır → ✅ **Tamamlandı** (widget'lara bölündü: FavoritesShelfWidget, FilterDialogWidget, GetSuggestionsDialogWidget, CompactRecipeCardWidget, ShimmerCardWidget)
- ✅ **RecipeDetailPage** - 353 satır → ✅ **Tamamlandı** (widget'lara bölündü: HeroImageWidget, RecipeChipsWidget, ProgressCardWidget, IngredientsListWidget, StepsListWidget, MarkAsMadeButtonWidget)
- ✅ **ProfilePage** - 240 satır → ✅ **Tamamlandı** (widget'lara bölündü: HeroCardWidget, PromptPreviewCardWidget, StatsTablesWidget, CollectionCardWidget, PreferenceControlsWidget, SettingsMenuWidget, LanguageDialogWidget, ThemeDialogWidget, ChipGroupWidget)
- ⚠️ **AddPantryItemPage** - 855 satır → ✅ **Tamamlandı** (334 satır, widget'lara bölündü: CategoryStatusChipWidget, CameraIngredientDialogWidget, PantryItemNameFieldWidget, CategorySelectorWidget, PantryItemQuantityUnitWidget, ExpiryDatePickerWidget)
- ⚠️ **PantryPage** - 687 satır → ✅ **Tamamlandı** (359 satır, widget'lara bölündü: PantryHeaderWidget, CategoryFilterChipsWidget, ViewModeToggleWidget, PantryItemDismissibleWidget, PantryItemGroupWidget)
- ✅ **UserRecipeFormPage** - 258 satır → ✅ Kabul edilebilir
- ✅ **PantryItemDetailPage** - 207 satır → ✅ Kabul edilebilir
- ✅ **LoginPage** - 223 satır → ✅ Kabul edilebilir
- ✅ **RegisterPage** - 203 satır → ✅ Kabul edilebilir
- ✅ **RecipesDiscoverPage** - 87 satır → ✅ Kabul edilebilir

### 🎯 Refactoring Planı

#### 1. AddPantryItemPage Refactoring (855 satır → ~250 satır hedef)

**Hedef:** Widget'lara bölerek SOLID prensiplerine uygun hale getirmek.

**Çıkarılacak Widget'lar:**
- [ ] **PantryItemFormWidget** - Form alanları (name, quantity, unit, expiry date)
- [ ] **CategorySelectorWidget** - Kategori seçimi ve AI kategori önerisi
- [ ] **ImagePickerWidget** - Kamera/galeri seçimi ve görsel önizleme
- [ ] **CameraIngredientDialogWidget** - Kamera ile ürün ekleme dialog'u (ingredient selection)
- [ ] **CategoryStatusChipWidget** - Kategori durumu gösterimi (loading, suggested, locked)
- [ ] **UnitDropdownWidget** - Birim seçimi dropdown'u
- [ ] **ExpiryDatePickerWidget** - Son kullanma tarihi seçici

**Ana Sayfa Sorumlulukları:**
- Form validation
- State management (controllers, timers)
- Navigation ve submit logic
- Dialog gösterimi koordinasyonu

**Hedef Dosya Yapısı:**
```
lib/features/pantry/presentation/
├── view/
│   └── add_pantry_item_page.dart (~250 satır)
└── widgets/
    ├── pantry_item_form_widget.dart
    ├── category_selector_widget.dart
    ├── image_picker_widget.dart
    ├── camera_ingredient_dialog_widget.dart
    ├── category_status_chip_widget.dart
    ├── unit_dropdown_widget.dart
    └── expiry_date_picker_widget.dart
```

**Öncelik:** 🔴 YÜKSEK (En uzun dosya)

---

#### 2. PantryPage Refactoring (687 satır → ~300 satır hedef)

**Hedef:** Widget'lara bölerek SOLID prensiplerine uygun hale getirmek.

**Çıkarılacak Widget'lar:**
- [ ] **PantryHeaderWidget** - Başlık ve arama çubuğu
- [ ] **CategoryFilterChipsWidget** - Kategori filtreleme çipleri
- [ ] **PantryItemListWidget** - Ürün listesi (flat/grouped view)
- [ ] **PantryItemGroupWidget** - Kategori gruplu görünüm
- [ ] **PantryItemDismissibleWidget** - Swipe-to-delete wrapper
- [ ] **ViewModeToggleWidget** - Flat/Grouped görünüm toggle
- [ ] **UndoSnackbarWidget** - Silme işlemi geri alma snackbar'ı

**Ana Sayfa Sorumlulukları:**
- State management (search, filter, view mode)
- BlocProvider/BlocBuilder koordinasyonu
- Pull-to-refresh logic
- Undo logic koordinasyonu

**Hedef Dosya Yapısı:**
```
lib/features/pantry/presentation/
├── view/
│   └── pantry_page.dart (~300 satır)
└── widgets/
    ├── pantry_header_widget.dart
    ├── category_filter_chips_widget.dart
    ├── pantry_item_list_widget.dart
    ├── pantry_item_group_widget.dart
    ├── pantry_item_dismissible_widget.dart
    ├── view_mode_toggle_widget.dart
    └── undo_snackbar_widget.dart
```

**Öncelik:** 🟡 ORTA (İkinci en uzun dosya)

---

### ✅ Tamamlanan Refactoring'ler

#### RecipesPage Refactoring (1120 satır → 441 satır)
- ✅ FavoritesShelfWidget
- ✅ FilterDialogWidget
- ✅ GetSuggestionsDialogWidget
- ✅ CompactRecipeCardWidget
- ✅ ShimmerCardWidget

#### RecipeDetailPage Refactoring (606 satır → 353 satır)
- ✅ HeroImageWidget
- ✅ RecipeChipsWidget
- ✅ ProgressCardWidget
- ✅ IngredientsListWidget
- ✅ StepsListWidget
- ✅ MarkAsMadeButtonWidget

#### ProfilePage Refactoring (1061 satır → 240 satır)
- ✅ HeroCardWidget
- ✅ PromptPreviewCardWidget
- ✅ StatsTablesWidget
- ✅ CollectionCardWidget
- ✅ PreferenceControlsWidget
- ✅ SettingsMenuWidget
- ✅ LanguageDialogWidget
- ✅ ThemeDialogWidget
- ✅ ChipGroupWidget

---

### 📋 Refactoring Checklist

**AddPantryItemPage:**
- [x] Widget'ları oluştur (7 widget)
- [x] Ana sayfayı refactor et (~250 satır)
- [x] Test et (form validation, AI categorization, camera flow)
- [x] Linter hatalarını düzelt
- [x] Responsive ve localization kontrolü

**PantryPage:**
- [x] Widget'ları oluştur (5 widget)
- [x] Ana sayfayı refactor et (~300 satır)
- [x] Test et (search, filter, swipe-to-delete, pull-to-refresh)
- [x] Linter hatalarını düzelt
- [x] Responsive ve localization kontrolü

---

### 🎯 SOLID Prensipleri Kontrol Listesi

Her refactoring sonrası kontrol edilecekler:
- ✅ **Single Responsibility:** Her widget tek bir sorumluluğa sahip mi?
- ✅ **Open/Closed:** Widget'lar genişletmeye açık, değişikliğe kapalı mı?
- ✅ **Liskov Substitution:** Widget'lar birbirinin yerine kullanılabilir mi? (gerekirse)
- ✅ **Interface Segregation:** Widget'lar sadece ihtiyaç duydukları prop'ları alıyor mu?
- ✅ **Dependency Inversion:** Widget'lar concrete implementation'lara değil, abstraction'lara bağımlı mı?

**Hedef:** Tüm sayfa dosyaları maksimum 300 satır ve SOLID prensiplerine uygun.

---
