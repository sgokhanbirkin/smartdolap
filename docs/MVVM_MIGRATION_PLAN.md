# 🔄 MVVM Migration Plan

**Tarih:** Kasım 2024  
**Durum:** Planlama Aşaması  
**Öncelik:** Yüksek

---

## 📊 Mevcut Durum vs Hedef

### ❌ Mevcut Yapı (Cubit-Only)
```
View → Cubit → UseCase → Repository
```

**Sorunlar:**
- Cubit'ler hem state management hem business logic yapıyor (SRP ihlali)
- View'lar direkt Cubit metodlarını çağırıyor
- Business logic test edilmesi zor

### ✅ Hedef Yapı (MVVM + Cubit)
```
View → ViewModel → Cubit (State Only) → Service/UseCase → Repository
```

**Faydalar:**
- ViewModel: Business logic orchestration
- Cubit: Sadece state management
- View: Sadece UI rendering
- Her katman tek sorumluluğa sahip (SRP)

---

## 🏗️ Mimari Değişiklik

### Yeni Klasör Yapısı (Her Feature İçin)
```
lib/features/pantry/
├── data/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── use_cases/
└── presentation/
    ├── view/
    │   └── pantry_page.dart          # Sadece UI
    ├── viewmodel/
    │   ├── pantry_view_model.dart    # ✨ YENİ: Business logic
    │   ├── pantry_cubit.dart         # Sadece state emit
    │   └── pantry_state.dart
    └── widgets/
```

---

## 📋 Migration Adımları

### Adım 1: Cubit'i Sadeleştir (State-Only)

**Önce (Mevcut):**
```dart
class PantryCubit extends Cubit<PantryState> {
  final ListPantryItems listPantryItems;
  final AddPantryItem addPantryItem;
  // ... use cases

  Future<void> add(String householdId, PantryItem item) async {
    try {
      await addPantryItem(householdId: householdId, item: item);
      await notificationCoordinator.handleItemAdded(item);
    } catch (e) {
      emit(PantryFailure(e.toString()));
    }
  }
}
```

**Sonra (State-Only):**
```dart
class PantryCubit extends Cubit<PantryState> {
  PantryCubit() : super(const PantryInitial());

  void setLoading() => emit(const PantryLoading());
  
  void setLoaded(List<PantryItem> items) => emit(PantryLoaded(items));
  
  void setError(String message) => emit(PantryFailure(message));
}
```

### Adım 2: ViewModel Oluştur (Business Logic)

```dart
class PantryViewModel {
  PantryViewModel({
    required this.cubit,
    required this.listPantryItems,
    required this.addPantryItem,
    required this.updatePantryItem,
    required this.deletePantryItem,
    required this.notificationCoordinator,
  });

  final PantryCubit cubit;
  final ListPantryItems listPantryItems;
  final AddPantryItem addPantryItem;
  final UpdatePantryItem updatePantryItem;
  final DeletePantryItem deletePantryItem;
  final IPantryNotificationCoordinator notificationCoordinator;

  StreamSubscription<List<PantryItem>>? _sub;

  Future<void> watch(String householdId) async {
    cubit.setLoading();
    await _sub?.cancel();
    _sub = listPantryItems(householdId: householdId).listen(
      (items) => cubit.setLoaded(items),
      onError: (e) => cubit.setError(e.toString()),
    );
  }

  Future<void> add(String householdId, PantryItem item) async {
    try {
      await addPantryItem(householdId: householdId, item: item);
      await notificationCoordinator.handleItemAdded(item);
    } catch (e) {
      cubit.setError(e.toString());
    }
  }

  Future<void> update(String householdId, PantryItem item) async {
    // Business logic here
  }

  Future<void> remove(String householdId, String itemId) async {
    // Business logic here
  }

  void dispose() {
    _sub?.cancel();
  }
}
```

### Adım 3: View'ı Güncelle

**Önce:**
```dart
class PantryPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantryCubit, PantryState>(
      builder: (context, state) {
        // View direkt cubit metodlarını çağırıyor
        onPressed: () => context.read<PantryCubit>().add(householdId, item),
      },
    );
  }
}
```

**Sonra:**
```dart
class PantryPage extends StatelessWidget {
  final PantryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantryCubit, PantryState>(
      builder: (context, state) {
        // View, ViewModel üzerinden işlem yapıyor
        onPressed: () => viewModel.add(householdId, item),
      },
    );
  }
}
```

### Adım 4: DI Güncelle

```dart
// dependency_injection.dart

// Cubit - State only
sl.registerFactory<PantryCubit>(() => PantryCubit());

// ViewModel - Business logic
sl.registerFactory<PantryViewModel>(
  () => PantryViewModel(
    cubit: sl<PantryCubit>(),
    listPantryItems: sl<ListPantryItems>(),
    addPantryItem: sl<AddPantryItem>(),
    updatePantryItem: sl<UpdatePantryItem>(),
    deletePantryItem: sl<DeletePantryItem>(),
    notificationCoordinator: sl<IPantryNotificationCoordinator>(),
  ),
);
```

---

## 📅 Migration Sırası (Öncelik)

| Feature | Öncelik | Karmaşıklık | Tahmini Süre |
|---------|---------|-------------|--------------|
| **Pantry** | 1 | Orta | 2-3 saat |
| **Auth** | 2 | Düşük | 1-2 saat |
| **Recipes** | 3 | Yüksek | 4-5 saat |
| **Profile** | 4 | Orta | 2-3 saat |
| **Shopping** | 5 | Düşük | 1-2 saat |
| **Household** | 6 | Orta | 2-3 saat |
| **Analytics** | 7 | Düşük | 1-2 saat |
| **Food Preferences** | 8 | Düşük | 1-2 saat |

**Toplam Tahmini Süre:** 15-22 saat

---

## ✅ Checklist (Her Feature İçin)

- [ ] ViewModel sınıfı oluştur
- [ ] Cubit'i state-only yap (business logic kaldır)
- [ ] View'ı ViewModel kullanacak şekilde güncelle
- [ ] DI'da ViewModel register et
- [ ] Unit testler yaz (ViewModel için)
- [ ] Mevcut testleri güncelle

---

## 🚀 Başlangıç: Pantry Feature

İlk olarak Pantry feature'ını migrate edelim mi?

Bu feature:
- Orta karmaşıklıkta
- İyi bir örnek teşkil eder
- Diğer feature'lar için template olur

