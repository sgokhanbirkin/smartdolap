# Auth Feature - Clean Architecture

Bu feature Clean Architecture prensiplerine göre yapılandırılmıştır.

## Yapı

```
auth/
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── auth_failure.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── i_auth_repository.dart
│   └── use_cases/
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       └── register_usecase.dart
└── presentation/
    ├── view/
    │   ├── login_page.dart
    │   └── register_page.dart
    └── viewmodel/
        ├── auth_cubit.dart
        └── auth_state.dart
```

## Kurulum

Freezed dosyalarını generate etmek için:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Kullanım

DI yapısı `lib/core/di/di.dart` içinde tanımlanmıştır. 
`initDependencies()` fonksiyonunu uygulama başlangıcında çağırın.

