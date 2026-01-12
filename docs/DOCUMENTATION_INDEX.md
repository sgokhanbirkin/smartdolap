# SmartDolap - Dokümantasyon İndeksi

> **Son Güncelleme:** 2026-01-11

## 📂 Dosya Organizasyonu

### Root Seviyesi (Aktif Takip)
- `status.md` - Çözülen problemler ve durum logu

### `/docs/sprints/` - Sprint Dökümanları
- `SPRINT_1_SUMMARY.md` - İlk sprint özeti
- `SPRINT_2_SUMMARY.md` - İkinci sprint özeti (Warning cleanup dahil)
- `MOBILE_PLAN.md` - Mobil geliştirme planı
- `MOBILE_IMPLEMENTATION_SUMMARY.md` - Mobil implementasyon detayları
- `MOBILE_INTEGRATION.md` - Mobil entegrasyon

### `/docs/backend/` - Backend Dökümanları
- `BACKEND_PLAN.md` - Backend API planı, endpoint'ler

### `/docs/archive/` - Arşiv
- `WARNING_CLEANUP_SUMMARY.md` - Warning temizleme v1
- `WARNING_CLEANUP_FINAL_SUMMARY.md` - Warning temizleme final
- `ANALYSIS_REPORT.md` - İlk proje analizi
- `PEXELS_SETUP.md` - Pexels API kurulum

### `/docs/` - Teknik Dökümanlar
- `README.md` - Proje ana dokümantasyonu
- `ROADMAP.md` - Proje yol haritası
- `PROBLEMS_TRACKER.md` - Aktif problem listesi
- `LINT_RULES_EXPLANATION.md` - Lint kuralları ve performans açıklaması
- `PROJECT_ARCHITECTURE_GUIDE.md` - Mimari rehber
- `MVVM_MIGRATION_PLAN.md` - MVVM migration planı
- `ARCHITECTURE_COMPLIANCE_PLAN.md` - Mimari uyumluluk planı
- `APP_ICON_SPLASH_SETUP.md` - App icon ve splash screen kurulum rehberi

## 🎯 Hızlı Erişim

### Yeni Başlayanlar İçin
1. `docs/README.md` - Kurulum ve başlangıç
2. `docs/PROJECT_ARCHITECTURE_GUIDE.md` - Mimari anlayışı
3. `docs/sprints/MOBILE_PLAN.md` - Geliştirme planı

### Geliştiriciler İçin
1. `docs/PROBLEMS_TRACKER.md` - Çözülecek problemler
2. `status.md` - Çözüm örnekleri ve durum
3. `docs/LINT_RULES_EXPLANATION.md` - Kod kalitesi kuralları

### Backend Geliştiriciler İçin
1. `docs/backend/BACKEND_PLAN.md` - API endpoint'leri
2. `docs/README.md` - Firebase setup

### Sprint Takibi
1. `docs/sprints/SPRINT_2_SUMMARY.md` - Son sprint
2. `docs/ROADMAP.md` - Gelecek planlar
3. `docs/PROBLEMS_TRACKER.md` - Aktif işler
4. `status.md` - Çözülen problemler ve durum

## 📊 Proje Durumu (2026-01-11)

### Kod Kalitesi
- ✅ Lint Errors: 0
- ✅ Lint Warnings: 0
- ✅ Build Status: Clean
- ✅ Test Status: Passing

### Tamamlanan Sprint'ler
- ✅ Sprint 1: Temel özellikler
- ✅ Sprint 2: Barcode scanner + Warning cleanup + Audio feedback + Branding

### Aktif Geliştirme
- 🔄 Sprint 3 planlanıyor
- 📋 Problem sayısı: Bakınız `docs/PROBLEMS_TRACKER.md`

## 🔄 Dokümantasyon Güncelleme Kuralları

1. **Sprint bitince:**
   - Sprint summary oluştur → `/docs/sprints/`
   - `status.md` güncelle
   - `docs/ROADMAP.md` güncelle

2. **Problem çözünce:**
   - `docs/PROBLEMS_TRACKER.md` güncelle
   - `status.md` ekle

3. **Yeni özellik eklenince:**
   - `docs/README.md` güncelle
   - İlgili sprint doc güncelle

4. **Eski dökümanlar:**
   - `/docs/archive/` taşı
   - Bu index'ten referansı kaldır

## 📝 Dokümantasyon Yazım Kuralları

- Markdown formatı kullan
- Başlıklar için emoji kullan (opsiyonel)
- Kod blokları için dil belirt
- Tarih formatı: YYYY-MM-DD
- Her dosyada "Son Güncelleme" tarihi olsun

## 🔗 Harici Kaynaklar

- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase Docs](https://firebase.google.com/docs)
- [OpenAI API](https://platform.openai.com/docs)
- [Pexels API](https://www.pexels.com/api/documentation/)

---

**Not:** Bu index dosyası düzenli olarak güncellenir. Yeni döküman eklerken buraya da ekleyin!
