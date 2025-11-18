#!/bin/bash

# CocoaPods Sync Fix Script
# Bu script CocoaPods sandbox senkronizasyon sorunlarını çözer

set -e

echo "🔧 CocoaPods Sync Fix Script başlatılıyor..."
echo ""

# 1. CocoaPods versiyonunu kontrol et
echo "📦 CocoaPods versiyonu kontrol ediliyor..."
POD_VERSION=$(pod --version)
echo "   CocoaPods versiyonu: $POD_VERSION"
echo ""

# 2. iOS dizinine git
cd "$(dirname "$0")/../ios" || exit 1

# 3. Eski Pods ve lock dosyalarını temizle
echo "🧹 Eski Pods ve lock dosyaları temizleniyor..."
rm -rf Pods
rm -f Podfile.lock
rm -rf .symlinks
echo "   ✓ Temizleme tamamlandı"
echo ""

# 4. Flutter clean
echo "🧹 Flutter cache temizleniyor..."
cd .. || exit 1
flutter clean > /dev/null 2>&1
echo "   ✓ Flutter clean tamamlandı"
echo ""

# 5. Flutter pub get
echo "📦 Flutter dependencies yükleniyor..."
flutter pub get > /dev/null 2>&1
echo "   ✓ Flutter pub get tamamlandı"
echo ""

# 6. Pod cache temizle
echo "🧹 CocoaPods cache temizleniyor..."
cd ios || exit 1
pod cache clean --all > /dev/null 2>&1 || true
echo "   ✓ Cache temizleme tamamlandı"
echo ""

# 7. Pod install
echo "📦 CocoaPods dependencies yükleniyor..."
pod install --repo-update
echo "   ✓ Pod install tamamlandı"
echo ""

# 8. Build test
echo "🔨 Build test ediliyor..."
cd .. || exit 1
if flutter build ios --no-codesign > /dev/null 2>&1; then
    echo "   ✅ Build başarılı!"
    echo ""
    echo "🎉 Tüm işlemler başarıyla tamamlandı!"
else
    echo "   ❌ Build başarısız. Lütfen hataları kontrol edin."
    exit 1
fi

