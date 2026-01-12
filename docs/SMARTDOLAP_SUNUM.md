# 🍽️ SmartDolap - Sunum Dokümanı

> **Akıllı Kiler ve Tarif Öneri Asistanı**  
> Son Güncelleme: 12 Ocak 2026

---

## 📋 İçindekiler
1. [Proje Vizyonu](#-proje-vizyonu)
2. [Problem ve Çözüm](#-problem-ve-çözüm)
3. [Sistem Mimarisi](#-sistem-mimarisi)
4. [Mobil Uygulama](#-mobil-uygulama-flutter)
5. [Backend API](#-backend-api-firebase-functions)
6. [Admin Panel](#-admin-panel-react)
7. [Teknoloji Altyapısı](#-teknoloji-altyapısı)
8. [Gelecek Planları](#-gelecek-planları)
9. [Teknik Metrikler](#-teknik-metrikler)

---

## 🎯 Proje Vizyonu

**SmartDolap**, evdeki malzemeleri yöneten ve bu malzemelere göre yapay zeka destekli tarif önerileri sunan **3 bileşenli** bir sistemdir.

### Misyon
> "Mutfaktaki israfı azalt, yemek yapmayı kolaylaştır."

### Hedef Kitle
- 🏠 Evde yemek yapan bireyler ve aileler
- 🥗 Sağlıklı beslenmeye önem verenler
- 💰 Bütçesini kontrol etmek isteyenler

---

## ❓ Problem ve Çözüm

| Problem | SmartDolap Çözümü |
|---------|-------------------|
| Buzdolabında ne var bilmiyoruz | **Akıllı Kiler** - Tek bakışta envanter |
| "Ne yapsam" sorusu her gün | **AI Tarif Önerileri** - GPT-4o ile öneriler |
| Tariflerdeki malzemeler evde yok | **Akıllı Eşleme** - Eldekilerle yapılabilenler |
| Aile bireylerinin farklı tercihleri | **Kişiselleştirme** - Vegan, keto, glutensiz |

---

## 🏗 Sistem Mimarisi

```
┌─────────────────────────────────────────────────────────────────┐
│                      SmartDolap Ecosystem                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   📱 MOBILE APP          🖥️ ADMIN PANEL        ☁️ BACKEND       │
│   ─────────────          ─────────────         ─────────        │
│   Flutter (iOS/Android)  React + Vite          Firebase Func    │
│   13 Feature Modülü      8 Sayfa               23+ Endpoint     │
│   357+ Dart Dosyası      39 Bileşen            4,330+ Satır     │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   🔥 FIREBASE SERVICES                                          │
│   ────────────────────                                          │
│   Auth | Firestore | Storage | Cloud Functions | Hosting        │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   🤖 EXTERNAL APIs                                              │
│   ────────────────                                              │
│   OpenAI GPT-4o | Pexels Images | OpenFoodFacts Barcodes        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 Mobil Uygulama (Flutter)

### Özellikler

| Modül | Özellik | Detay |
|-------|---------|-------|
| 🔐 **Auth** | Giriş/Kayıt | Email, Firebase Auth |
| 🏠 **Household** | Hane Yönetimi | QR ile katılım, aile paylaşımı |
| 📦 **Pantry** | Kiler | Barkod tarama, kategori, SKT takibi |
| 🍳 **Recipes** | Tarifler | AI önerileri, favoriler, geçmiş |
| 🥗 **Preferences** | Tercihler | Diyet, mutfak, alerji |
| 👤 **Profile** | Profil | XP, rozetler, istatistikler |
| 🎮 **Gamification** | Oyunlaştırma | Seviye, başarılar |
| 🛒 **Shopping** | Alışveriş | Liste oluşturma, PDF export |

### Mimari
- **MVVM + Clean Architecture**
- **13 Feature Modülü** (auth, barcode, pantry, recipes, profile, vb.)
- **Hive** çevrimdışı cache
- **Cubit** state management

---

## ☁️ Backend API (Firebase Functions)

### Durum: ✅ Production Ready

| Phase | Durum | Endpoint | Kod Satırı |
|-------|-------|----------|------------|
| Phase 1 | ✅ Complete | 10+ | 3,000+ |
| Phase 2 | ✅ Complete | 13+ | 1,330+ |
| **Toplam** | ✅ | **23+** | **4,330+** |

### Ana Özellikler

| Özellik | Açıklama | İyileşme |
|---------|----------|----------|
| **Toplu Barkod Tarama** | 50 barkod/istek | %80 hızlı |
| **Görsel Önbellekleme** | Firebase Storage | 3-5x hızlı |
| **Türkçe İsim Desteği** | AI çevirisi | %95 Türkçe |
| **Kategori Standardizasyonu** | Fuzzy matching | 13 kategori |
| **Admin Dashboard API** | Analytics | Gerçek zamanlı |

### API Endpoint Kategorileri

```
📊 Dashboard
   GET /admin/dashboard/overview
   GET /admin/dashboard/user-behavior
   GET /admin/dashboard/popular-products
   GET /admin/dashboard/charts-data

📦 Ürün İşlemleri
   POST /bulk-scan (toplu barkod)
   GET  /admin/products
   POST /admin/products
   PUT  /admin/products/:id
   DELETE /admin/products/:id

🔧 Admin İşlemleri
   GET  /admin/monitoring/*
   POST /admin/migrate-categories
   GET  /admin/export/*
   GET  /admin/submissions/*
```

---

## 🖥️ Admin Panel (React)

### Teknolojiler
| Teknoloji | Kullanım |
|-----------|----------|
| React 18 | UI Framework |
| Vite | Build Tool |
| TypeScript | Programlama |
| Material-UI | Tasarım |
| Recharts | Grafikler |
| React Query | State |
| Firebase Hosting | Deployment |

### Sayfalar

| Sayfa | Özellik |
|-------|---------|
| 📊 **Dashboard** | Genel istatistik, grafikler |
| 👥 **Users** | Kullanıcı yönetimi |
| 📦 **Pantry** | Kiler analitikleri |
| 🍳 **Recipes** | Tarif istatistikleri |
| 📝 **Submissions** | Ürün incelemeleri |
| 📦 **Products** | Ürün CRUD |
| 📈 **Monitoring** | Sistem izleme |
| ⚙️ **Settings** | Ayarlar |

### Proje Yapısı
```
admin-panel/src/
├── components/     # 21 bileşen
├── pages/          # 8 sayfa
├── services/       # 3 servis (firebase, api, auth)
├── contexts/       # Auth context
└── types/          # TypeScript tipleri
```

---

## 🛠 Teknoloji Altyapısı

### Tam Stack Özeti

| Katman | Teknoloji | Detay |
|--------|-----------|-------|
| **Mobil** | Flutter 3.24+ | iOS & Android |
| **Admin** | React 18 + Vite | Web Panel |
| **Backend** | TypeScript + Express | Firebase Functions |
| **Database** | Cloud Firestore | NoSQL |
| **Auth** | Firebase Auth | Email/Password |
| **Storage** | Firebase Storage | Görseller |
| **AI** | OpenAI GPT-4o Mini | Tarif üretimi |
| **Images** | Pexels API | Tarif görselleri |
| **Barcodes** | OpenFoodFacts | Ürün bilgisi |

---

## 🚀 Gelecek Planları

### Kısa Vadeli (1-2 Ay)
- ✅ Backend Phase 1 & 2 tamamlandı
- 🔄 Admin Panel ürün CRUD
- 📲 Bildirimler (SKT uyarıları)
- 🔄 Offline sync iyileştirmesi

### Orta Vadeli (3-6 Ay)
- 📷 Fiş okuma (OCR)
- 📅 Haftalık meal planning
- 👥 Sosyal özellikler
- 📱 Home screen widget'ları

### Uzun Vadeli (6+ Ay)
- 🌐 Web uygulaması (Flutter Web)
- ⌚ Akıllı saat desteği
- 🏠 Akıllı ev entegrasyonu
- 🛒 Online market siparişi

---

## 📊 Teknik Metrikler

### Tüm Projeler Özeti

| Proje | Dosya Sayısı | Kod Satırı | Durum |
|-------|--------------|------------|-------|
| **Mobil (Flutter)** | 357+ | 50,000+ | ✅ Production |
| **Backend (TS)** | 31 | 4,330+ | ✅ Production Ready |
| **Admin (React)** | 39 | 5,000+ | ✅ Active |
| **Toplam** | **427+** | **59,330+** | ✅ |

### Performans İyileştirmeleri
```
Kategori Doğruluğu:  70% → 95% (+25%)
Görsel Yükleme:     2-3s → 0.5s (-70%)
Toplu Tarama (10):   10s → 1-2s (-80%)
Türkçe İsim:         40% → 95% (+55%)
```

### Kod Kalitesi
- ✅ Lint Warning: 0
- ✅ Lint Error: 0
- ✅ TypeScript Strict Mode
- ✅ ESLint Configured

---

## 👥 Ekip & Demo

| | |
|---|---|
| **Geliştirici** | Gökhan Birkin |
| **Platform** | iOS, Android, Web (Admin) |
| **Durum** | Aktif Geliştirme |

### Demo Bilgileri
```
Email: demo@smartdolap.app
Password: Demo123!
```

---

> **"Akıllı mutfak, mutlu ev."** 🏠✨
