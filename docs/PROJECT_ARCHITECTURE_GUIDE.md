# 🏗️ Flutter Proje Mimarisi ve Clean Code Rehberi

**Versiyon:** 1.0.0  
**Son Güncelleme:** 2024  
**Hedef:** Production-ready Flutter projeleri için standart mimari ve geliştirme prensipleri

---

## 📋 İçindekiler

1. [Genel Bakış](#genel-bakış)
2. [Proje Yapısı](#proje-yapısı)
3. [Architecture Patterns](#architecture-patterns)
4. [Clean Architecture Implementation](#clean-architecture-implementation)
5. [SOLID Principles](#solid-principles)
6. [Responsive Design Strategy](#responsive-design-strategy)
7. [Localization Strategy](#localization-strategy)
8. [Error Handling Strategy](#error-handling-strategy)
9. [Network Layer Architecture](#network-layer-architecture)
10. [Dependency Injection](#dependency-injection)
11. [Testing Strategy](#testing-strategy)
12. [Cursor Rules](#cursor-rules)
13. [Karşılaştırma Checklist](#karşılaştırma-checklist)

---

## Genel Bakış

Bu dökümantasyon, production-ready Flutter projeleri için standart mimari, clean code prensipleri ve best practice'leri içerir. Bu rehberi kullanarak:

- Yeni projelerde tutarlı mimari kurabilirsiniz
- Mevcut projelerinizi bu standartlara göre değerlendirebilirsiniz
- Code review süreçlerinde referans olarak kullanabilirsiniz
- Takım içi standartları oluşturabilirsiniz

---

## Proje Yapısı

### Klasör Organizasyonu

```
lib/
├── core/                          # Core Infrastructure (Framework-agnostic)
│   ├── init/                      # Initialization Layer
│   │   ├── config/                # Configuration files
│   │   │   └── api_config.dart    # API configuration (env-based)
│   │   ├── storage/               # Storage abstractions
│   │   │   ├── cache_manager.dart # Abstract cache interface
│   │   │   └── token_storage.dart # Token storage interface
│   │   └── app_locator.dart       # Dependency Injection setup
│   │
│   ├── network/                   # Network Infrastructure
│   │   ├── client/                # HTTP Client
│   │   │   ├── dio_client.dart    # Dio wrapper (single source of truth)
│   │   │   └── network_config.dart# Network configuration
│   │   ├── interceptors/          # Dio Interceptors
│   │   │   ├── auth_interceptor.dart    # Token injection
│   │   │   └── log_interceptor.dart     # Request/response logging
│   │   ├── parsers/               # Response Parsers (Strategy Pattern)
│   │   │   ├── response_handler.dart    # Orchestration layer
│   │   │   ├── response_parser.dart     # Abstract parser interface
│   │   │   ├── error_response_parser.dart # Error extraction
│   │   │   └── status_code_mapper.dart  # Status code mapping
│   │   └── response/              # Response Models
│   │       ├── api_response.dart  # Standard API response wrapper
│   │       └── result.dart        # Functional error handling (Result Pattern)
│   │
│   ├── error/                     # Error Handling
│   │   ├── app_error.dart         # Error type hierarchy (sealed classes)
│   │   └── error_localization.dart# Error message localization
│   │
│   ├── services/                  # Core Services (Cross-cutting concerns)
│   │   ├── connectivity_service.dart
│   │   └── telemetry_service.dart
│   │
│   ├── router/                    # Navigation
│   │   └── app_router.dart
│   │
│   └── utils/                     # Utilities
│       ├── register_validator.dart
│       ├── text_truncation_utils.dart
│       └── url_utils.dart
│
├── features/                      # Feature Modules (Self-contained)
│   ├── auth/                      # Authentication Feature
│   │   ├── model/                 # Feature-specific models
│   │   │   ├── login_request.dart
│   │   │   ├── login_response.dart
│   │   │   ├── register_request.dart
│   │   │   └── register_response.dart
│   │   │
│   │   ├── service/               # Business Logic Layer
│   │   │   └── auth_service.dart  # Interface + Implementation
│   │   │
│   │   ├── state/                 # State Management (Cubit)
│   │   │   ├── auth_cubit.dart
│   │   │   └── auth_state.dart    # Immutable state classes
│   │   │
│   │   ├── view_model/            # ViewModel Layer (Business Logic Orchestration)
│   │   │   └── auth_view_model.dart
│   │   │
│   │   ├── view/                  # UI Screens
│   │   │   ├── login_view.dart
│   │   │   └── register_view.dart
│   │   │
│   │   └── widgets/               # Feature-specific widgets
│   │       ├── auth_header.dart
│   │       ├── social_login_row.dart
│   │       └── ...
│   │
│   ├── home/                      # Home Feature (same structure)
│   ├── profile/                   # Profile Feature (same structure)
│   └── splash/                    # Splash Feature
│
├── product/                       # Product-Specific Layer (App-specific concerns)
│   ├── cache/                     # Project-specific cache implementations
│   │   ├── movie_cache.dart
│   │   └── profile_cache.dart
│   │
│   ├── config/                    # Project constants and configurations
│   │   ├── auth_layout_constants.dart
│   │   ├── limited_offer_config.dart
│   │   └── poster_strip_config.dart
│   │
│   ├── localization/              # Localization keys
│   │   └── locale_keys.dart
│   │
│   ├── model/                     # Project-specific models
│   │   └── user_profile.dart
│   │
│   ├── theme/                     # Theme Configuration
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_gradients.dart
│   │   └── app_typography.dart
│   │
│   └── widgets/                   # Shared reusable widgets
│       ├── app_bottom_nav.dart
│       ├── app_button.dart
│       ├── app_input_field.dart
│       ├── app_scaffold.dart
│       └── ...
│
└── main.dart                      # Entry Point
```

### Klasör Organizasyon Prensipleri

#### ✅ Core Layer
- **Amaç:** Framework-agnostic, reusable infrastructure
- **İçerik:** Network, storage, error handling, DI, utilities
- **Bağımlılık:** Flutter'a bağımlı değil (mümkün olduğunca)
- **Test:** Unit testlerle tamamen test edilebilir

#### ✅ Features Layer
- **Amaç:** Self-contained, bağımsız özellikler
- **Yapı:** Her feature kendi model, service, state, view_model, view, widgets klasörlerine sahip
- **Bağımlılık:** Core'a bağımlı, diğer feature'lara bağımlı değil
- **İlke:** Feature'lar birbirinden bağımsız olmalı, sadece core üzerinden iletişim kurmalı

#### ✅ Product Layer
- **Amaç:** Proje-spesifik, domain-specific kod
- **İçerik:** Cache implementations, config constants, theme, shared widgets
- **Not:** Core'daki abstract interface'lerin concrete implementation'ları burada olabilir

---

## Architecture Patterns

### MVVM + Cubit Architecture

```
┌─────────────────────────────────────────┐
│           PRESENTATION LAYER            │
│  ┌──────────┐    ┌───────────┐         │
│  │   View   │───▶│ ViewModel │         │
│  └──────────┘    └─────┬─────┘         │
│                        │                 │
│                        ▼                 │
│                   ┌──────────┐          │
│                   │  Cubit   │          │
│                   │ (State)  │          │
│                   └──────────┘          │
└───────────────────────┬─────────────────┘
                        │
                        │ Service Calls
                        ▼
┌─────────────────────────────────────────┐
│           SERVICE LAYER                 │
│  ┌──────────────────────────────┐      │
│  │   Service Interface          │      │
│  │   + Implementation           │      │
│  └──────────────┬───────────────┘      │
└─────────────────┼───────────────────────┘
                  │
                  │ HTTP Requests
                  ▼
┌─────────────────────────────────────────┐
│           NETWORK LAYER                 │
│  ┌──────────────────────────────┐      │
│  │        DioClient             │      │
│  │  ┌────────────┐  ┌─────────┐│      │
│  │  │Interceptors│  │ Parsers ││      │
│  │  └────────────┘  └─────────┘│      │
│  └──────────────────────────────┘      │
└─────────────────────────────────────────┘
```

### Data Flow

```
1. User Interaction (View)
   ↓
2. ViewModel method called
   ↓
3. ViewModel calls Service
   ↓
4. Service makes HTTP request via DioClient
   ↓
5. DioClient returns Result<T>
   ↓
6. ViewModel processes Result
   ↓
7. ViewModel updates Cubit state
   ↓
8. Cubit emits new state
   ↓
9. View rebuilds with new state
```

### Component Responsibilities

#### View Layer
- **Sorumluluk:** UI rendering, user interaction handling
- **Pattern:** StatelessWidget (mümkün olduğunca)
- **Kullanım:** BlocBuilder/BlocListener ile state'i dinler

```dart
class HomeView extends StatelessWidget {
  final HomeViewModel viewModel;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.isPageLoading) {
          return const LoadingWidget();
        }
        
        if (state.errorMessage != null) {
          return ErrorWidget(message: state.errorMessage!);
        }
        
        return MoviesList(movies: state.movies);
      },
    );
  }
}
```

#### ViewModel Layer
- **Sorumluluk:** Business logic orchestration, service coordination
- **Pattern:** Plain class (not a widget)
- **Kullanım:** Service'leri çağırır, Cubit'i günceller

```dart
class HomeViewModel {
  final HomeService _service;
  final HomeCubit _cubit;
  
  Future<void> loadInitialMovies() async {
    _cubit.setLoading(true);
    
    final result = await _service.fetchMovies(1);
    
    result.fold(
      (movies) => _cubit.setMoviesLoaded(movies),
      (error) => _cubit.setError(error.toLocalizedKey()),
    );
  }
}
```

#### Cubit (State Management)
- **Sorumluluk:** State management, state emission
- **Pattern:** Cubit from flutter_bloc
- **Kullanım:** Immutable state, Equatable for comparison

```dart
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState.initial());
  
  void setMoviesLoaded({required List<MovieModel> movies}) {
    emit(state.copyWith(
      movies: movies,
      isPageLoading: false,
    ));
  }
}

class HomeState extends Equatable {
  final List<MovieModel> movies;
  final bool isPageLoading;
  final String? errorMessage;
  
  // Immutable state with copyWith
}
```

#### Service Layer
- **Sorumluluk:** API communication, data transformation
- **Pattern:** Interface + Implementation
- **Kullanım:** DioClient kullanır, Result<T> döner

```dart
abstract class HomeService {
  Future<Result<PagedMoviesResponse>> fetchMovies(int page);
  Future<Result<void>> toggleFavorite(String movieId);
}

class HomeServiceImpl implements HomeService {
  final DioClient _client;
  
  @override
  Future<Result<PagedMoviesResponse>> fetchMovies(int page) async {
    return await _client.get<PagedMoviesResponse>(
      '/movie/list',
      queryParameters: {'page': page},
      fromJson: PagedMoviesResponse.fromJson,
    );
  }
}
```

---

## Clean Architecture Implementation

### Layer Separation

Clean Architecture'da üç ana katman vardır:

1. **Presentation Layer** (View, ViewModel, Cubit)
2. **Domain Layer** (Business Logic - Service'lerde)
3. **Data Layer** (Network, Storage - Core'da)

### Dependency Rule

```
Inner layers should NOT depend on outer layers
Outer layers CAN depend on inner layers

Core (inner) ← Features (middle) ← Product (outer)
```

### Interface-Based Design

Her Service bir interface'e sahip olmalı:

```dart
// ✅ DO: Interface tanımla
abstract class HomeService {
  Future<Result<List<Movie>>> fetchMovies();
}

// ✅ DO: Implementation'ı inject et
class HomeServiceImpl implements HomeService {
  final DioClient _client;
  // ...
}

// ❌ DON'T: Direkt concrete class'a bağımlı ol
class HomeViewModel {
  final HomeServiceImpl service; // ❌ Bad
  final HomeService service; // ✅ Good
}
```

---

## SOLID Principles

### Single Responsibility Principle (SRP)

Her sınıfın tek bir değişme nedeni olmalı.

```dart
// ✅ DO: Ayrı sorumluluklar
class ResponseHandler {
  Result<T> handleResponse<T>(...) { ... } // Sadece response handling
}

class ErrorResponseParser {
  AppError parseError(...) { ... } // Sadece error parsing
}

// ❌ DON'T: Çoklu sorumluluk
class ResponseProcessor {
  Result<T> handleResponse<T>(...) { ... }
  AppError parseError(...) { ... }
  void logError(...) { ... }
  void cacheData(...) { ... }
}
```

### Open/Closed Principle (OCP)

Sınıflar genişletmeye açık, değişikliğe kapalı olmalı.

```dart
// ✅ DO: Abstract interface kullan
abstract class ResponseParser {
  bool parseSuccess(Map<String, dynamic> data);
  String? extractMessage(Map<String, dynamic> data);
}

class DefaultResponseParser implements ResponseParser {
  // Default implementation
}

class CustomResponseParser implements ResponseParser {
  // Custom implementation without modifying existing code
}

// ❌ DON'T: Her durum için if-else
class ResponseParser {
  bool parseSuccess(Map<String, dynamic> data, String type) {
    if (type == 'default') { ... }
    else if (type == 'custom') { ... }
    // Her yeni tip için değişiklik gerekir
  }
}
```

### Liskov Substitution Principle (LSP)

Türetilmiş sınıflar, temel sınıfların yerine kullanılabilir olmalı.

```dart
// ✅ DO: Interface contract'ını koru
abstract class TokenStorage {
  Future<String?> getToken();
  Future<void> saveToken(String token);
}

class SecureTokenStorage implements TokenStorage {
  // Implementation doesn't break the contract
}

// Test'te mock kullanılabilir
class MockTokenStorage implements TokenStorage {
  // Mock implementation
}
```

### Interface Segregation Principle (ISP)

İstemciler kullanmadıkları interface'lerden bağımlı olmamalı.

```dart
// ✅ DO: İnce interface'ler
abstract class HomeService {
  Future<Result<List<Movie>>> fetchMovies();
}

abstract class FavoriteService {
  Future<Result<void>> toggleFavorite(String id);
}

// ❌ DON'T: Kalın interface (Fat Interface)
abstract class MovieService {
  Future<Result<List<Movie>>> fetchMovies();
  Future<Result<void>> toggleFavorite(String id);
  Future<Result<void>> addReview(...);
  Future<Result<void>> shareMovie(...);
  // HomeService sadece fetchMovies kullanır ama diğer metodlardan da sorumlu
}
```

### Dependency Inversion Principle (DIP)

Yüksek seviyeli modüller, düşük seviyeli modüllere bağımlı olmamalı. Her ikisi de abstraction'lara bağımlı olmalı.

```dart
// ✅ DO: Abstraction'a bağımlı
class HomeViewModel {
  final HomeService _service; // Interface
  final HomeCubit _cubit;
  
  HomeViewModel({
    required HomeService service, // Dependency injection
    required HomeCubit cubit,
  }) : _service = service, _cubit = cubit;
}

// ❌ DON'T: Concrete class'a bağımlı
class HomeViewModel {
  final HomeServiceImpl _service; // Concrete class
  // Değiştirilemez, test edilemez
}
```

---

## Responsive Design Strategy

### Flutter ScreenUtil Setup

```dart
// main.dart
ScreenUtilInit(
  designSize: const Size(375, 812), // iPhone X design size
  minTextAdapt: true,
  builder: (context, child) {
    return MaterialApp(...);
  },
  child: const AppEntryShell(),
)
```

### Responsive Extensions

```dart
// ✅ DO: ScreenUtil extensions kullan
Container(
  width: 100.w,        // Width responsive
  height: 50.h,        // Height responsive
  padding: EdgeInsets.all(16.r), // Radius responsive
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp), // Font size responsive
  ),
)

// ❌ DON'T: Hardcoded değerler
Container(
  width: 100,          // ❌ Fixed width
  height: 50,          // ❌ Fixed height
  padding: EdgeInsets.all(16), // ❌ Fixed padding
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16), // ❌ Fixed font size
  ),
)
```

### Responsive Checklist

- [ ] Tüm `width`, `height` değerleri `.w`, `.h` extension'ları kullanıyor
- [ ] Tüm `padding`, `margin`, `spacing` değerleri responsive
- [ ] Tüm `borderRadius` değerleri `.r` kullanıyor
- [ ] Tüm `fontSize` değerleri `.sp` kullanıyor
- [ ] `SizedBox` boyutları responsive
- [ ] `BoxShadow` blur ve offset değerleri responsive
- [ ] `ImageFilter.blur` sigma değerleri responsive

### Widget Responsive Pattern

```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 50.h,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Text(
        'Responsive Text',
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }
}
```

---

## Localization Strategy

### Easy Localization Setup

```dart
// main.dart
await EasyLocalization.ensureInitialized();

runApp(
  EasyLocalization(
    supportedLocales: const [
      Locale('tr'),
      Locale('en'),
    ],
    path: 'assets/translations',
    fallbackLocale: const Locale('tr'),
    child: const ShartflixApp(),
  ),
);
```

### Locale Keys Pattern

```dart
// product/localization/locale_keys.dart
class LocaleKeys {
  LocaleKeys._();
  
  // Feature-based organization
  static const auth_login_title = 'auth.login.title';
  static const auth_login_subtitle = 'auth.login.subtitle';
  static const auth_errors_loginFailed = 'auth.errors.loginFailed';
  
  // Error keys
  static const errors_network_timeout = 'errors.network.timeout';
  static const errors_server_notFound = 'errors.server.notFound';
}
```

### Translation Files

```json
// assets/translations/tr.json
{
  "auth": {
    "login": {
      "title": "Giriş Yap",
      "subtitle": "Hesabınıza giriş yapın"
    },
    "errors": {
      "loginFailed": "Giriş başarısız"
    }
  },
  "errors": {
    "network": {
      "timeout": "Bağlantı zaman aşımına uğradı"
    }
  }
}
```

### Usage Pattern

```dart
// ✅ DO: LocaleKeys constant kullan
Text(LocaleKeys.auth_login_title.tr())

// ❌ DON'T: Hardcoded string
Text('Giriş Yap')

// ✅ DO: Error localization
error.toLocalizedKey().tr()

// ❌ DON'T: Hardcoded error messages
Text('Connection timeout')
```

### Localization Checklist

- [ ] Tüm UI text'leri `LocaleKeys` ile tanımlı
- [ ] Her feature için translation key'leri organize edilmiş
- [ ] Error mesajları localized
- [ ] `tr()` extension'ı kullanılıyor (hardcoded string yok)
- [ ] Fallback locale tanımlı
- [ ] Tüm desteklenen diller için translation dosyaları mevcut

---

## Error Handling Strategy

### Sealed Error Hierarchy

```dart
sealed class AppError implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  
  const AppError({
    required this.message,
    this.code,
    this.statusCode,
  });
}

final class NetworkError extends AppError {
  final bool isTimeout;
  final bool isNoConnection;
  // ...
}

final class ServerError extends AppError { ... }
final class ValidationError extends AppError { ... }
final class UnauthorizedError extends AppError { ... }
final class UnknownError extends AppError { ... }
```

### Result Pattern

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

// Extension for fold pattern
extension ResultExtension<T> on Result<T> {
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Failure(:final error) => onFailure(error),
    };
  }
}
```

### Usage Pattern

```dart
// ✅ DO: Result pattern kullan
final result = await service.fetchMovies();

result.fold(
  (movies) => _cubit.setMoviesLoaded(movies),
  (error) => _cubit.setError(error.toLocalizedKey()),
);

// ❌ DON'T: Exception throwing
try {
  final movies = await service.fetchMovies();
  _cubit.setMoviesLoaded(movies);
} catch (e) {
  _cubit.setError(e.toString()); // Error handling inconsistent
}
```

### Error Localization

```dart
extension AppErrorLocalization on AppError {
  String toLocalizedKey() {
    return switch (this) {
      NetworkError(isTimeout: true) => LocaleKeys.errors_network_timeout,
      NetworkError(isNoConnection: true) => LocaleKeys.errors_network_noConnection,
      ServerError(statusCode: 404) => LocaleKeys.errors_server_notFound,
      // ...
    };
  }
}
```

---

## Network Layer Architecture

### DioClient Pattern

```dart
class DioClient {
  final Dio dio;
  final ResponseHandler _responseHandler;
  final StatusCodeMapper _statusCodeMapper;
  
  DioClient(
    TokenStorage tokenStorage, {
    ConnectivityService? connectivityService,
    ResponseHandler? responseHandler,
    StatusCodeMapper? statusCodeMapper,
  }) : _responseHandler = responseHandler ?? const ResponseHandler(),
       _statusCodeMapper = statusCodeMapper ?? const StatusCodeMapper() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl, // From .env
      connectTimeout: ApiConfig.defaultTimeout,
      receiveTimeout: ApiConfig.defaultTimeout,
    ));
    
    dio.interceptors.addAll([
      AuthInterceptor(tokenStorage),
      RetryInterceptor(...),
      DebugLogInterceptor(),
    ]);
  }
  
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    // Connectivity check
    // Request execution
    // Response handling
    // Error mapping
  }
}
```

### Response Parsing Strategy

```dart
// Abstract parser interface
abstract class ResponseParser {
  bool parseSuccess(Map<String, dynamic> data);
  String? extractMessage(Map<String, dynamic> data);
  Map<String, dynamic>? parseMeta(Map<String, dynamic> data);
}

// Default implementation
class DefaultResponseParser implements ResponseParser {
  @override
  bool parseSuccess(Map<String, dynamic> data) {
    return data['success'] as bool? ?? false;
  }
  
  // ...
}

// Error parser (Strategy Pattern)
class ErrorResponseParser {
  AppError? parseError(Map<String, dynamic> data, int? statusCode) {
    // Early return pattern
    if (data['error'] == null) return null;
    
    final errorData = data['error'];
    if (errorData is! Map) return null;
    
    final message = errorData['message'] as String?;
    if (message == null) return null;
    
    return ServerError(
      message: message,
      statusCode: statusCode,
    );
  }
}
```

### Status Code Mapping

```dart
class StatusCodeMapper {
  final Map<int, AppError Function(String?, int?)> _handlers;
  
  const StatusCodeMapper()
      : _handlers = {
          400: (msg, code) => ValidationError(message: msg ?? 'Bad request', statusCode: code),
          401: (_, __) => const UnauthorizedError(),
          403: (msg, code) => ServerError(message: msg ?? 'Forbidden', statusCode: code),
          404: (msg, code) => ServerError(message: msg ?? 'Not found', statusCode: code),
          // ...
        };
  
  AppError mapStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    if (statusCode == null) {
      return const UnknownError(message: 'Unknown status code');
    }
    
    final handler = _handlers[statusCode];
    if (handler != null) {
      return handler(
        _extractMessage(response),
        statusCode,
      );
    }
    
    // Default handler for unmapped status codes
    return ServerError(
      message: _extractMessage(response) ?? 'Server error',
      statusCode: statusCode,
    );
  }
}
```

### Network Checklist

- [ ] Merkezi `DioClient` kullanılıyor (tek source of truth)
- [ ] Base URL `.env` dosyasından okunuyor
- [ ] Token injection `AuthInterceptor` ile otomatik
- [ ] Retry mechanism uygulanmış
- [ ] Connectivity check yapılıyor
- [ ] Response parsing Strategy Pattern ile
- [ ] Error mapping map-based (switch-case değil)
- [ ] Tüm network çağrıları `Result<T>` döner
- [ ] Logging interceptor mevcut (debug mode'da)

---

## Dependency Injection

### GetIt Setup

```dart
// core/init/app_locator.dart
final locator = GetIt.instance;

Future<void> initCoreDependencies() async {
  // Singleton: Uygulama boyunca tek instance
  locator.registerSingleton<TokenStorage>(
    SecureTokenStorage(...),
  );
  
  // LazySingleton: İlk kullanımda oluşturulur, sonra aynı instance döner
  locator.registerLazySingleton<DioClient>(
    () => DioClient(
      locator<TokenStorage>(),
      connectivityService: locator<ConnectivityService>(),
    ),
  );
}

Future<void> initAuthDependencies() async {
  locator.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(
      locator<DioClient>(),
      locator<TokenStorage>(),
    ),
  );
  
  // Factory: Her çağrıda yeni instance
  locator.registerFactory<AuthCubit>(
    () => AuthCubit(),
  );
  
  locator.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(
      service: locator<AuthService>(),
      cubit: locator<AuthCubit>(),
    ),
  );
}
```

### Registration Patterns

```dart
// Singleton: Tek instance (services, storage)
locator.registerSingleton<Service>(ServiceImpl());

// LazySingleton: Lazy initialization (heavy objects)
locator.registerLazySingleton<Service>(() => ServiceImpl());

// Factory: Her seferinde yeni instance (Cubits genelde factory)
locator.registerFactory<Cubit>(() => Cubit());
```

### Usage Pattern

```dart
// ✅ DO: Locator'dan al
final viewModel = locator<HomeViewModel>();
final service = locator<HomeService>();

// ❌ DON'T: Direkt instantiate
final viewModel = HomeViewModel(
  service: HomeServiceImpl(...), // Dependencies manuel inject ediliyor
  cubit: HomeCubit(),
);
```

### DI Checklist

- [ ] Tüm dependencies `app_locator.dart`'da register edilmiş
- [ ] Feature-based dependency initialization (initAuthDependencies, initHomeDependencies)
- [ ] Singleton pattern doğru kullanılmış (services için lazySingleton, cubits için factory)
- [ ] Circular dependency yok
- [ ] Test'lerde mock'lar inject edilebiliyor

---

## Testing Strategy

### Test Structure

```
test/
├── core/                    # Core layer tests
│   ├── network/
│   │   └── parsers/
│   └── cache/
│
├── features/                # Feature tests
│   ├── auth/
│   │   └── widgets/
│   └── home/
│       └── widgets/
│
├── integration/             # Integration tests
│   ├── auth_service_integration_test.dart
│   └── home_service_integration_test.dart
│
├── product/                 # Product layer tests
│   └── cache/
│
└── helpers/
    └── test_helpers.dart    # Test utilities
```

### Test Helpers

```dart
// test/helpers/test_helpers.dart
void setupTestScreenSize() {
  ScreenUtil.init(
    const BoxConstraints(
      maxWidth: 375,
      maxHeight: 812,
    ),
    designSize: const Size(375, 812),
    orientation: Orientation.portrait,
  );
  
  // Suppress overflow errors in tests
  FlutterError.onError = (details) {
    if (details.exception is FlutterError &&
        details.exception.toString().contains('overflowed')) {
      return; // Suppress overflow errors
    }
    FlutterError.presentError(details);
  };
}

void resetTestScreenSize() {
  ScreenUtil.reset();
}
```

### Widget Test Pattern

```dart
// ✅ DO: Test helper kullan
void main() {
  setUp(() {
    setupTestScreenSize();
  });
  
  tearDown(() {
    resetTestScreenSize();
  });
  
  testWidgets('HomeView displays movies', (tester) async {
    // Arrange
    final mockViewModel = MockHomeViewModel();
    // ...
    
    // Act
    await tester.pumpWidget(...);
    
    // Assert
    expect(find.text('Movie Title'), findsOneWidget);
  });
}
```

### Integration Test Pattern

```dart
// ✅ DO: Service + Network layer test
void main() {
  late HomeService homeService;
  late MockDioClient mockDioClient;
  
  setUp(() {
    mockDioClient = MockDioClient();
    homeService = HomeServiceImpl(mockDioClient);
  });
  
  test('fetchMovies returns success with valid response', () async {
    // Arrange
    when(() => mockDioClient.get<PagedMoviesResponse>(
      any(),
      queryParameters: any(named: 'queryParameters'),
      fromJson: any(named: 'fromJson'),
    )).thenAnswer((_) async => Success(mockResponse));
    
    // Act
    final result = await homeService.fetchMovies(1);
    
    // Assert
    expect(result, isA<Success<PagedMoviesResponse>>());
  });
}
```

### Testing Checklist

- [ ] Widget testler responsive değerler için `setupTestScreenSize` kullanıyor
- [ ] Service layer için integration testler mevcut
- [ ] Mock'lar `mocktail` ile oluşturulmuş
- [ ] Test data'ları gerçekçi (API response formatına uygun)
- [ ] Error scenario'ları test edilmiş
- [ ] State management (Cubit) test edilmiş

---

## Cursor Rules

Aşağıdaki Cursor Rules'ı `.cursorrules` dosyasına ekleyin veya proje başlangıcında kullanın:

```markdown
# Flutter Project Architecture Rules

## Architecture
- Use MVVM + Cubit pattern
- Clean Architecture principles (Core → Features → Product)
- Feature-based folder structure
- Each feature should be self-contained (model, service, state, view_model, view, widgets)

## Code Quality
- Follow SOLID principles
- Single Responsibility: Each class should have one reason to change
- Use interfaces for services (abstract class Service + Implementation)
- Dependency Injection via get_it
- Result pattern for error handling (no exceptions in business logic)

## Responsive Design
- Use flutter_screenutil for all dimensions
- All width/height values: `.w`, `.h`
- All padding/margin/spacing: `.w`, `.h`
- All borderRadius: `.r`
- All fontSize: `.sp`
- NEVER use hardcoded numeric values for UI dimensions

## Localization
- All UI text must use LocaleKeys constants
- Use `.tr()` extension for translations
- Error messages must be localized
- NO hardcoded strings in UI

## Network Layer
- Single DioClient instance (singleton)
- Base URL from .env file
- Result<T> pattern for all network calls
- Strategy Pattern for response parsing
- Map-based status code mapping (no long switch-case)

## Error Handling
- Sealed error hierarchy (AppError with subtypes)
- Result pattern (Success/Failure) instead of exceptions
- Error localization via extension methods

## State Management
- Cubit for state management
- Immutable state classes with Equatable
- ViewModel for business logic orchestration
- View only for UI rendering

## Testing
- Widget tests with setupTestScreenSize
- Integration tests for service layer
- Mock dependencies with mocktail
- Use realistic test data (matching API response format)

## File Organization
- Core layer: Framework-agnostic infrastructure
- Features layer: Self-contained feature modules
- Product layer: App-specific implementations and configs
- Each feature: model/, service/, state/, view_model/, view/, widgets/

## Dependency Injection
- Register all dependencies in app_locator.dart
- Feature-based initialization functions
- Use lazySingleton for services, factory for Cubits
- No circular dependencies

## Code Style
- Use early return pattern (avoid deep nesting)
- Maximum method length: 30-40 lines
- Descriptive variable and method names
- Comments only for complex business logic
- Remove debugPrint statements from production code
```

---

## Karşılaştırma Checklist

Bu checklist'i kullanarak yeni veya mevcut projelerinizi bu standartlara göre değerlendirebilirsiniz:

### 📁 Proje Yapısı

- [ ] `lib/core/` klasörü mevcut (framework-agnostic infrastructure)
- [ ] `lib/features/` klasörü mevcut (feature-based structure)
- [ ] `lib/product/` klasörü mevcut (app-specific code)
- [ ] Her feature kendi modülünde (model, service, state, view_model, view, widgets)
- [ ] Core katmanı Flutter'a bağımlı değil (mümkün olduğunca)

### 🏗️ Architecture

- [ ] MVVM + Cubit pattern uygulanmış
- [ ] ViewModel layer mevcut (business logic orchestration)
- [ ] Service layer interface + implementation pattern
- [ ] State management Cubit ile
- [ ] Immutable state classes (Equatable)

### 🎨 Responsive Design

- [ ] `flutter_screenutil` kurulu ve kullanılıyor
- [ ] Tüm width/height değerleri `.w`, `.h` kullanıyor
- [ ] Tüm padding/margin değerleri responsive
- [ ] Tüm borderRadius değerleri `.r` kullanıyor
- [ ] Tüm fontSize değerleri `.sp` kullanıyor
- [ ] Hardcoded numeric değer yok (UI dimensions için)

### 🌍 Localization

- [ ] `easy_localization` kurulu
- [ ] `LocaleKeys` class mevcut (tüm translation key'leri)
- [ ] Translation dosyaları (`tr.json`, `en.json`) mevcut
- [ ] Tüm UI text'leri `LocaleKeys` kullanıyor
- [ ] `.tr()` extension kullanılıyor
- [ ] Hardcoded string yok (UI'da)

### 🔌 Network Layer

- [ ] Merkezi `DioClient` mevcut (singleton)
- [ ] Base URL `.env` dosyasından okunuyor
- [ ] `AuthInterceptor` mevcut (token injection)
- [ ] `RetryInterceptor` mevcut
- [ ] Response parsing Strategy Pattern ile
- [ ] Status code mapping map-based
- [ ] Tüm network calls `Result<T>` döner
- [ ] Error handling comprehensive

### 🛡️ Error Handling

- [ ] `AppError` sealed hierarchy mevcut
- [ ] `Result<T>` pattern kullanılıyor
- [ ] Error localization mevcut
- [ ] Business logic'te exception throwing yok (Result pattern kullanılıyor)

### 💉 Dependency Injection

- [ ] `get_it` kurulu
- [ ] `app_locator.dart` mevcut
- [ ] Tüm dependencies register edilmiş
- [ ] Feature-based initialization functions
- [ ] Singleton/LazySingleton/Factory doğru kullanılmış

### 🧪 Testing

- [ ] Widget testler mevcut
- [ ] Integration testler mevcut (service layer)
- [ ] Test helpers mevcut (`setupTestScreenSize` vs.)
- [ ] Mock dependencies kullanılıyor (`mocktail`)
- [ ] Test data gerçekçi (API formatına uygun)

### 📋 SOLID Principles

- [ ] **SRP**: Her sınıf tek sorumluluğa sahip
- [ ] **OCP**: Interface-based design, genişletilebilir
- [ ] **LSP**: Interface implementations substitutable
- [ ] **ISP**: İnce interface'ler
- [ ] **DIP**: Abstraction'lara bağımlılık

### 📦 Dependencies

- [ ] `flutter_bloc` (state management)
- [ ] `get_it` (dependency injection)
- [ ] `dio` (networking)
- [ ] `easy_localization` (localization)
- [ ] `flutter_screenutil` (responsive design)
- [ ] `flutter_dotenv` (environment variables)
- [ ] `mocktail` (testing)

### ✅ Code Quality

- [ ] `flutter analyze` sonucu: 0 error, 0 warning
- [ ] Early return pattern kullanılıyor (nested if yok)
- [ ] Method length makul (30-40 satır max)
- [ ] Descriptive naming
- [ ] `debugPrint` production code'da yok

---

## Proje Analiz Komutu

Yeni bir projeyi analiz etmek için aşağıdaki komutları çalıştırın:

```bash
# Flutter analyze
flutter analyze

# Test coverage
flutter test --coverage

# Dependency check
flutter pub deps

# Lint check
flutter pub run flutter_lints:lint
```

---

## Sonuç

Bu dökümantasyon, production-ready Flutter projeleri için standart mimari ve geliştirme prensiplerini içerir. Yeni projelerde bu standartları uygulayarak:

- Tutarlı kod yapısı
- Kolay bakım ve ölçeklenebilirlik
- Yüksek test edilebilirlik
- Clean code prensipleri
- Professional architecture

sağlayabilirsiniz.

Her projede bu checklist'i kullanarak eksiklikleri tespit edebilir ve iyileştirmeler yapabilirsiniz.

