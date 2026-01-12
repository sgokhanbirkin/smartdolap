# 🗺️ SmartDolap Development Roadmap

This roadmap outlines the strategic transition from a mobile-only application to a robust, backend-driven architecture.

## 🏗️ Sprint 1: Mobile Borçları Temizleme (The "Cleanup" Sprint)
**Hedef:** Backend'e geçmeden önce Flutter tarafında yarım kalan "Seri Barkod" ve "Kayıt" akışını bitirmek. Uygulama "Standalone" olarak hatasız çalışmalı.

### Mobil (Flutter)
- [ ] **Seri Tarama UI - Önizleme Ekranı (Review Screen)**
    -   *Logic:* "Cashier Mode" tamamlandığında taranan ürünleri listeleyen, miktarlarını düzenlemeye veya silmeye izin veren ara ekran (ReviewPage).
    -   *Action:* `ScannedItemsReviewPage` oluşturulacak.
- [ ] **Domain Logic - `BulkAddPantryItemsUseCase`**
    -   *Logic:* Listeyi (`List<ScannedProduct>`) alıp `PantryItem` nesnelerine çevirecek ve topluca Firestore'a yazacak.
    -   *Action:* Atomic Batch Write kullanılacak.
- [ ] **Hata Yönetimi (Manual Fallback)**
    -   *Logic:* Barkod bulunamadığında kullanıcıya "Bulunamadı, manuel ekle veya bilinmeyen listesine at" seçeneği sunulacak.
- [ ] **Offline Sync**
    -   *Logic:* İnternet yoksa taranan toplu liste `Hive` (SyncQueue) içine atılacak. Bağlantı geldiğinde `SyncWorkerCubit` bunları işleyecek.

---

## 🛡️ Sprint 2: Backend Temelleri & Güvenlik (The "Foundation" Sprint)
**Hedef:** Node.js/Cloud Functions backend'ini ayağa kaldırmak ve güvenliği sağlamak.

### Backend (Firebase Cloud Functions)
- [ ] **Setup**
    -   Node.js projesi ve `firebase-admin` kurulumu.
- [ ] **Auth Middleware**
    -   Flutter'dan gelen `Authorization: Bearer <ID_TOKEN>` başlığını doğrulayan Express middleware veya Callable Function kontrolü.
- [ ] **OpenAI Proxy**
    -   API Key güvenliği için OpenAI istekleri backend üzerinden yapılacak.
    -   *Endpoint:* `POST /api/ai/generateRecipe`

### Mobil (Flutter)
- [ ] **API Katmanı Refactor**
    -   `OpenAIService` artık Cloud Function endpoint'ine istek atacak.
    -   Tüm HTTP isteklerine otomatik token ekleyen `AuthInterceptor` yazılacak.

---

## ⚡ Sprint 3: Ürün Servisi ve Caching (The "Performance" Sprint)
**Hedef:** OpenFoodFacts limitlerini aşmak ve performansı artırmak.

### Backend
- [ ] **Product Service**
    -   *Endpoint:* `GET /api/product/:barcode`
- [ ] **Smart Caching (Read-Through)**
    -   1. **Firestore DB** kontrol et (Kendi veritabanımız).
    -   2. Yoksa **OpenFoodFacts** API'sine git.
    -   3. Sonucu **Firestore**'a kaydet (Cache süresi eklenebilir).
    -   4. Cevabı dön.

### Mobil
- [ ] **Repo Update**
    -   `ProductLookupRepository` artık doğrudan OpenFoodFacts yerine bizim backend'i çağıracak.

---

## 🤝 Sprint 4: Entegrasyon ve Veri Dışa Aktarımı (The "Integration" Sprint)
**Hedef:** Dış sistemlere entegrasyon.

### Backend
- [ ] **MyInventory API**
    -   *Endpoint:* `GET /api/inventory`
- [ ] **Receipt Parser (Opsiyonel)**
    -   Fiş görselini işleyip JSON'a çeviren servis (Google Vision API).

### Mobil
- [ ] **E2E Test**
    -   Login -> Scan -> Backend Cache -> DB -> Notification akışının testi.
