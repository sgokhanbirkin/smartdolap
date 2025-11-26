# Smart-Dolap Projesi Yapılacaklar Listesi (TODO)

Bu liste, `ANALYSIS.md` raporunda belirtilen eksiklik ve önerilere dayanarak oluşturulmuştur. Görevler öncelik sırasına göre düzenlenmiştir.

## 1. Test Kapsamını Artır (Öncelik: Yüksek)

Projenin kararlılığını ve bakım kolaylığını artırmak için test kapsamı acilen genişletilmelidir.

- [ ] **Unit & Widget Testleri Ekle:**
  - [ ] `analytics` modülü için testler yaz.
  - [ ] `food_preferences` modülü için testler yaz.
  - [ ] `gamification` modülü için testler yaz.
  - [ ] `household` modülü için testler yaz.
  - [ ] `shopping` modülü için testler yaz.
  - [ ] `rate_limiting` modülü için testler yaz.
  - [ ] `onboarding` akışı için testler yaz.

- [ ] **Entegrasyon Testleri Oluştur:**
  - [ ] **Yeni Kullanıcı Akışı:** Kayıt olma, hane halkı oluşturma, yiyecek tercihlerini belirtme ve ana ekrana ulaşma akışını test et.
  - [ ] **Temel Kullanım Akışı:** Kiler'e ürün ekleme, eklenen ürüne göre tarif önermesi alma ve tarifi favorilere ekleme akışını test et.

## 2. Statik Kod Analizini Sıkılaştır (Öncelik: Orta)

Kod kalitesini ve tutarlılığını otomatik olarak güvence altına almak için lint kuralları sıkılaştırılmalıdır.

- [ ] `analysis_options.yaml` dosyasını incele.
- [ ] Flutter topluluğu tarafından önerilen ek lint kurallarını (`flutter_lints` dışında) araştır ve projeye ekle.

## 3. Backend Güvenliğini Gözden Geçir (Öncelik: Orta)

İstemci tarafındaki güvenlik önlemleri, sunucu tarafında da doğrulanmalıdır.

- [ ] `rate_limiting` mantığını Cloud Functions veya Firestore Güvenlik Kuralları ile sunucu tarafında uygula.
- [ ] Firestore Güvenlik Kurallarını (`firestore.rules`) detaylıca incele ve sadece yetkili kullanıcıların kendi verilerine erişebildiğinden emin ol.

## 4. Proje Belgelerini İyileştir (Öncelik: Düşük)

Projenin yeni geliştiriciler için anlaşılır ve kolay kurulabilir olmasını sağla.

- [ ] `README.md` dosyasını güncelle:
  - [ ] Detaylı proje kurulum adımları ekle (Flutter sürümü, Firebase CLI vb.).
  - [ ] `.env.example` dosyasının nasıl kopyalanıp `.env` olarak kullanılacağını açıkla.
  - [ ] Firebase projesinin nasıl yapılandırılacağına dair talimatlar ekle.
- [ ] Bu `TODO.md` dosyasını `docs` klasörüne taşı.