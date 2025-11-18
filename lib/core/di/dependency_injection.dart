import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/core/services/household_setup_service.dart';
import 'package:smartdolap/core/services/i_household_setup_service.dart';
import 'package:smartdolap/core/services/i_onboarding_service.dart';
import 'package:smartdolap/core/services/i_sync_service.dart';
import 'package:smartdolap/core/services/onboarding_service.dart';
import 'package:smartdolap/core/services/sync_service.dart';
import 'package:smartdolap/features/analytics/domain/use_cases/get_user_analytics_usecase.dart';
import 'package:smartdolap/features/analytics/presentation/viewmodel/analytics_cubit.dart';
import 'package:smartdolap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_cubit.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:smartdolap/features/auth/domain/use_cases/login_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/register_usecase.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/household/data/repositories/household_repository_impl.dart';
import 'package:smartdolap/features/household/data/repositories/message_repository_impl.dart';
import 'package:smartdolap/features/household/data/repositories/shared_recipe_repository_impl.dart';
import 'package:smartdolap/features/household/domain/repositories/i_household_repository.dart';
import 'package:smartdolap/features/household/domain/repositories/i_message_repository.dart';
import 'package:smartdolap/features/household/domain/repositories/i_shared_recipe_repository.dart';
import 'package:smartdolap/features/household/domain/use_cases/create_household_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/generate_invite_code_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/get_household_from_invite_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/get_household_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/join_household_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/send_message_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/share_recipe_usecase.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/household_cubit.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/share_cubit.dart';
import 'package:smartdolap/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:smartdolap/features/analytics/data/repositories/meal_consumption_repository_impl.dart';
import 'package:smartdolap/features/analytics/data/services/analytics_service_impl.dart';
import 'package:smartdolap/features/analytics/data/services/smart_notification_service_impl.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_meal_consumption_repository.dart';
import 'package:smartdolap/features/analytics/domain/services/i_analytics_service.dart';
import 'package:smartdolap/features/analytics/domain/services/i_smart_notification_service.dart';
import 'package:smartdolap/features/pantry/data/repositories/pantry_repository_impl.dart';
import 'package:smartdolap/features/pantry/data/services/pantry_notification_coordinator.dart';
import 'package:smartdolap/features/pantry/data/services/pantry_notification_scheduler.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_notification_coordinator.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/pantry/domain/services/i_pantry_notification_scheduler.dart';
import 'package:smartdolap/features/shopping/data/repositories/shopping_list_repository_impl.dart';
import 'package:smartdolap/features/shopping/data/services/shopping_list_service_impl.dart';
import 'package:smartdolap/features/shopping/domain/repositories/i_shopping_list_repository.dart';
import 'package:smartdolap/features/shopping/domain/services/i_shopping_list_service.dart';
import 'package:smartdolap/features/shopping/domain/use_cases/add_shopping_list_item_usecase.dart';
import 'package:smartdolap/features/shopping/domain/use_cases/complete_shopping_list_item_usecase.dart';
import 'package:smartdolap/features/shopping/domain/use_cases/delete_shopping_list_item_usecase.dart';
import 'package:smartdolap/features/shopping/domain/use_cases/update_shopping_list_item_usecase.dart';
import 'package:smartdolap/features/shopping/presentation/viewmodel/shopping_list_cubit.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/add_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/delete_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/list_pantry_items.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/update_pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/profile/data/profile_stats_service.dart';
import 'package:smartdolap/features/profile/data/prompt_preference_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_profile_stats_service.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_prompt_preference_service.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_user_recipe_repository.dart';
import 'package:smartdolap/features/recipes/data/repositories/recipes_repository_impl.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_cache_service.dart';
import 'package:smartdolap/features/recipes/data/services/recipe_image_service.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_cache_service.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipe_image_service.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/get_recipe_detail.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/suggest_recipes_from_pantry.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/data/repositories/comment_repository_impl.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_comment_repository.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/add_comment_usecase.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/delete_comment_usecase.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/watch_global_comments_usecase.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/watch_household_comments_usecase.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/comment_cubit.dart';
import 'package:smartdolap/features/food_preferences/data/repositories/food_preference_repository_impl.dart';
import 'package:smartdolap/features/food_preferences/domain/repositories/i_food_preference_repository.dart';
import 'package:smartdolap/features/food_preferences/domain/use_cases/get_all_food_preferences_usecase.dart';
import 'package:smartdolap/features/food_preferences/domain/use_cases/get_user_food_preferences_usecase.dart';
import 'package:smartdolap/features/food_preferences/domain/use_cases/save_user_food_preferences_usecase.dart';
import 'package:smartdolap/features/food_preferences/presentation/viewmodel/food_preferences_cubit.dart';
import 'package:smartdolap/product/services/expiry_notification_service.dart';
import 'package:smartdolap/product/services/i_expiry_notification_service.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart'
    show
        DuckDuckGoImageSearchService,
        GoogleImagesHtmlScrapingService,
        IImageLookupService,
        MultiImageSearchService,
        PexelsImageSearchService,
        UnsplashImageSearchService;
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:smartdolap/product/services/openai/openai_service.dart';
import 'package:smartdolap/product/services/storage/i_storage_service.dart';
import 'package:smartdolap/product/services/storage/storage_service.dart';

/// Dependency injection service locator
final GetIt sl = GetIt.instance;

/// Setup dependency injection locator
Future<void> setupLocator() async {
  // Hive
  await Hive.initFlutter();
  // Burada ileride adapter register edilecek (Ingredient, vb.)
  await dotenv.load();
  // Local cache boxes
  await Hive.openBox<dynamic>('recipes_cache');
  await Hive.openBox<dynamic>('pantry_box');
  await Hive.openBox<dynamic>('profile_box');
  await Hive.openBox<dynamic>('profile_stats_box');
  await Hive.openBox<dynamic>('app_settings');
  if (!sl.isRegistered<Box<dynamic>>(instanceName: 'pantryBox')) {
    sl.registerLazySingleton<Box<dynamic>>(
      () => Hive.box<dynamic>('pantry_box'),
      instanceName: 'pantryBox',
    );
  }
  // Prompt preference service - DIP: Register via interface
  if (!sl.isRegistered<IPromptPreferenceService>()) {
    sl.registerLazySingleton<IPromptPreferenceService>(
      () => PromptPreferenceService(Hive.box<dynamic>('profile_box')),
    );
  }
  // Register concrete implementation for backward compatibility if needed
  if (!sl.isRegistered<PromptPreferenceService>()) {
    sl.registerLazySingleton<PromptPreferenceService>(
      () => sl<IPromptPreferenceService>() as PromptPreferenceService,
    );
  }
  // Onboarding service - DIP: Register via interface
  if (!sl.isRegistered<IOnboardingService>()) {
    sl.registerLazySingleton<IOnboardingService>(
      () => OnboardingService(Hive.box<dynamic>('app_settings')),
    );
  }
  // Register concrete implementation for backward compatibility if needed
  if (!sl.isRegistered<OnboardingService>()) {
    sl.registerLazySingleton<OnboardingService>(
      () => sl<IOnboardingService>() as OnboardingService,
    );
  }
  // Household setup service - DIP: Register via interface
  if (!sl.isRegistered<IHouseholdSetupService>()) {
    sl.registerLazySingleton<IHouseholdSetupService>(
      () => HouseholdSetupService(Hive.box<dynamic>('app_settings')),
    );
  }
  if (!sl.isRegistered<UserRecipeService>()) {
    sl.registerLazySingleton<UserRecipeService>(
      () => UserRecipeService(Hive.box<dynamic>('profile_box')),
    );
  }
  // Register UserRecipeService as IUserRecipeRepository (DIP)
  if (!sl.isRegistered<IUserRecipeRepository>()) {
    sl.registerLazySingleton<IUserRecipeRepository>(
      () => sl<UserRecipeService>(),
    );
  }
  // Recipe services - DIP: Register via interfaces
  if (!sl.isRegistered<IRecipeCacheService>()) {
    sl.registerLazySingleton<IRecipeCacheService>(
      () => RecipeCacheService(Hive.box<dynamic>('recipes_cache')),
    );
  }
  // Register concrete implementation for backward compatibility if needed
  if (!sl.isRegistered<RecipeCacheService>()) {
    sl.registerLazySingleton<RecipeCacheService>(
      () => sl<IRecipeCacheService>() as RecipeCacheService,
    );
  }
  if (!sl.isRegistered<IRecipeImageService>()) {
    sl.registerLazySingleton<IRecipeImageService>(
      () => RecipeImageService(sl<IImageLookupService>()),
    );
  }
  // Register concrete implementation for backward compatibility if needed
  if (!sl.isRegistered<RecipeImageService>()) {
    sl.registerLazySingleton<RecipeImageService>(
      () => sl<IRecipeImageService>() as RecipeImageService,
    );
  }
  // Firebase
  sl.registerLazySingleton<fb.FirebaseAuth>(() => fb.FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Auth — DIP: arayüz → implementasyon
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl<fb.FirebaseAuth>(), sl<FirebaseFirestore>()),
  );
  sl.registerFactory(() => LoginUseCase(sl()));
  sl.registerFactory(() => LogoutUseCase(sl()));
  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      registerUseCase: sl(),
      repository: sl(),
    ),
  );

  // Pantry
  sl.registerLazySingleton<IPantryRepository>(
    () => PantryRepositoryImpl(
      sl<FirebaseFirestore>(),
      sl<Box<dynamic>>(instanceName: 'pantryBox'),
    ),
  );
  sl.registerFactory(() => ListPantryItems(sl()));
  sl.registerFactory(() => AddPantryItem(sl()));
  sl.registerFactory(() => UpdatePantryItem(sl()));
  sl.registerFactory(() => DeletePantryItem(sl()));
  sl.registerFactory(
    () => PantryCubit(
      listPantryItems: sl(),
      addPantryItem: sl(),
      updatePantryItem: sl(),
      deletePantryItem: sl(),
      notificationCoordinator: sl<IPantryNotificationCoordinator>(),
    ),
  );

  // HTTP clients
  sl.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: 'https://api.openai.com/v1')),
  );

  // Image lookup services - Multi-service with fallback chain
  // Priority: Google HTML Scraping > Pexels > Unsplash > DuckDuckGo (fallback)
  // Google scraping is first because:
  // - Free and unlimited (user's phone makes the request)
  // - No API key needed
  // - Each user has their own IP (no rate limiting issues)
  // - Google bot detection is less suspicious from user devices
  sl.registerLazySingleton<IImageLookupService>(() {
    final List<IImageLookupService> services = <IImageLookupService>[];

    // Try Google Images HTML scraping FIRST (free, unlimited, user's phone)
    services.add(GoogleImagesHtmlScrapingService(Dio()));

    // Try Pexels API second (free, 200 requests/hour, requires API key)
    final String? pexelsApiKey = dotenv.env['PEXELS_API_KEY'];
    if (pexelsApiKey != null && pexelsApiKey.isNotEmpty) {
      services.add(PexelsImageSearchService(dio: Dio(), apiKey: pexelsApiKey));
    }

    // Try Unsplash API third (free, 50 requests/hour, requires API key)
    final String? unsplashAccessKey = dotenv.env['UNSPLASH_ACCESS_KEY'];
    if (unsplashAccessKey != null && unsplashAccessKey.isNotEmpty) {
      services.add(
        UnsplashImageSearchService(dio: Dio(), accessKey: unsplashAccessKey),
      );
    }

    // Fallback to DuckDuckGo (always available, but unreliable)
    services.add(DuckDuckGoImageSearchService(Dio()));

    return MultiImageSearchService(services: services);
  });

  // Backward compatibility - register DuckDuckGo as ImageLookupService (old name)
  // Note: This is deprecated, use IImageLookupService instead
  sl.registerLazySingleton<DuckDuckGoImageSearchService>(
    () => DuckDuckGoImageSearchService(Dio()),
  );

  // OpenAI
  sl.registerLazySingleton<IOpenAIService>(() => OpenAIService(dio: sl()));

  // Storage
  sl.registerLazySingleton<IStorageService>(
    () => StorageService(sl<FirebaseStorage>()),
  );

  // Notifications - DIP: Register via interface
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin.new,
  );
  sl.registerLazySingleton<IExpiryNotificationService>(
    () => ExpiryNotificationService(sl<FlutterLocalNotificationsPlugin>()),
  );
  // Register concrete implementation for backward compatibility if needed
  sl.registerLazySingleton<ExpiryNotificationService>(
    () => sl<IExpiryNotificationService>() as ExpiryNotificationService,
  );
  // Pantry notification coordinator - DIP: Register via interface
  sl.registerLazySingleton<IPantryNotificationCoordinator>(
    () => PantryNotificationCoordinator(sl<IExpiryNotificationService>()),
  );
  // Register concrete implementation for backward compatibility if needed
  sl.registerLazySingleton<PantryNotificationCoordinator>(
    () => sl<IPantryNotificationCoordinator>() as PantryNotificationCoordinator,
  );

  // Pantry notification scheduler - DIP: Register via interface
  sl.registerFactory<IPantryNotificationScheduler>(
    () => PantryNotificationScheduler(sl<IPantryNotificationCoordinator>()),
  );

  // Analytics repositories - DIP: Register via interfaces
  sl.registerLazySingleton<IMealConsumptionRepository>(
    () => MealConsumptionRepositoryImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<IAnalyticsRepository>(
    () => AnalyticsRepositoryImpl(
      sl<FirebaseFirestore>(),
      sl<IMealConsumptionRepository>(),
      sl<IPantryRepository>(),
    ),
  );

  // Analytics services - DIP: Register via interfaces
  sl.registerLazySingleton<IAnalyticsService>(
    () => AnalyticsServiceImpl(
      sl<IAnalyticsRepository>(),
      sl<IMealConsumptionRepository>(),
    ),
  );

  // Analytics use cases
  sl.registerFactory(() => GetUserAnalyticsUseCase(sl()));

  // Analytics cubit
  sl.registerFactory(() => AnalyticsCubit(getUserAnalytics: sl()));

  // Profile cubit
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      prefService: sl<IPromptPreferenceService>(),
      statsService: sl<IProfileStatsService>(),
      userRecipeService: sl<UserRecipeService>(),
      authCubit: sl<AuthCubit>(),
    ),
  );

  // Smart notification service - DIP: Register via interface
  sl.registerLazySingleton<ISmartNotificationService>(
    () => SmartNotificationServiceImpl(
      sl<IMealConsumptionRepository>(),
      sl<IPantryRepository>(),
      sl<IShoppingListRepository>(),
      sl<IExpiryNotificationService>(),
    ),
  );

  // Shopping list repository - DIP: Register via interface
  sl.registerLazySingleton<IShoppingListRepository>(
    () => ShoppingListRepositoryImpl(sl<FirebaseFirestore>()),
  );

  // Shopping list service - DIP: Register via interface
  sl.registerLazySingleton<IShoppingListService>(
    () => ShoppingListServiceImpl(
      sl<IShoppingListRepository>(),
      sl<IPantryRepository>(),
    ),
  );

  // Shopping list use cases
  sl.registerFactory(() => AddShoppingListItemUseCase(sl()));
  sl.registerFactory(() => UpdateShoppingListItemUseCase(sl()));
  sl.registerFactory(() => DeleteShoppingListItemUseCase(sl()));
  sl.registerFactory(() => CompleteShoppingListItemUseCase(sl()));

  // Shopping list cubit
  sl.registerFactory(
    () => ShoppingListCubit(
      shoppingListRepository: sl(),
      addShoppingListItem: sl(),
      updateShoppingListItem: sl(),
      deleteShoppingListItem: sl(),
      completeShoppingListItem: sl(),
    ),
  );

  // Profile services - must be registered before SyncService - DIP: Register via interface
  if (!sl.isRegistered<IProfileStatsService>()) {
    sl.registerLazySingleton<IProfileStatsService>(
      () => ProfileStatsService(Hive.box<dynamic>('profile_stats_box')),
    );
  }
  // Register concrete implementation for backward compatibility if needed
  if (!sl.isRegistered<ProfileStatsService>()) {
    sl.registerLazySingleton<ProfileStatsService>(
      () => sl<IProfileStatsService>() as ProfileStatsService,
    );
  }
  sl.registerLazySingleton<IBadgeRepository>(
    () => BadgeRepositoryImpl(sl<FirebaseFirestore>()),
  );

  // Sync service - DIP: Register via interface
  if (!sl.isRegistered<ISyncService>()) {
    sl.registerLazySingleton<ISyncService>(
      () => SyncService(
        firestore: sl<FirebaseFirestore>(),
        pantryRepository: sl<IPantryRepository>(),
        recipesRepository: sl<IRecipesRepository>(),
        pantryBox: sl<Box<dynamic>>(instanceName: 'pantryBox'),
        recipeCacheService: sl<IRecipeCacheService>(),
      ),
    );
  }
  // Register concrete implementation for backward compatibility if needed
  if (!sl.isRegistered<SyncService>()) {
    sl.registerLazySingleton<SyncService>(
      () => sl<ISyncService>() as SyncService,
    );
  }

  // Recipes
  sl.registerLazySingleton<IRecipesRepository>(
    () => RecipesRepositoryImpl(
      sl<FirebaseFirestore>(),
      sl(),
      sl(),
      sl<IPromptPreferenceService>(),
      sl<IRecipeImageService>(),
      sl<IRecipeCacheService>(),
    ),
  );
  sl.registerFactory(() => SuggestRecipesFromPantry(sl()));
  sl.registerFactory(() => GetRecipeDetail(sl()));
  sl.registerFactory(
    () => RecipesCubit(
      suggest: sl(),
      openAI: sl(),
      promptPreferences: sl<IPromptPreferenceService>(),
      imageLookup: sl<IImageLookupService>(),
      cacheService: sl<IRecipeCacheService>(),
      imageService: sl<IRecipeImageService>(),
      userRecipeRepository: sl(),
      recipesRepository: sl(),
    ),
  );

  // Household - DIP: Register via interfaces
  sl.registerLazySingleton<IHouseholdRepository>(
    () => HouseholdRepositoryImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<IMessageRepository>(
    () => MessageRepositoryImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ISharedRecipeRepository>(
    () => SharedRecipeRepositoryImpl(sl<FirebaseFirestore>()),
  );

  // Comment Repository
  sl.registerLazySingleton<ICommentRepository>(
    () => CommentRepositoryImpl(sl<FirebaseFirestore>()),
  );

  // Comment Use Cases
  sl.registerLazySingleton<WatchGlobalCommentsUseCase>(
    () => WatchGlobalCommentsUseCase(sl<ICommentRepository>()),
  );
  sl.registerLazySingleton<WatchHouseholdCommentsUseCase>(
    () => WatchHouseholdCommentsUseCase(sl<ICommentRepository>()),
  );
  sl.registerLazySingleton<AddCommentUseCase>(
    () => AddCommentUseCase(sl<ICommentRepository>()),
  );
  sl.registerLazySingleton<DeleteCommentUseCase>(
    () => DeleteCommentUseCase(sl<ICommentRepository>()),
  );

  // Comment Cubit
  sl.registerFactory<CommentCubit>(
    () => CommentCubit(
      watchGlobalCommentsUseCase: sl<WatchGlobalCommentsUseCase>(),
      watchHouseholdCommentsUseCase: sl<WatchHouseholdCommentsUseCase>(),
      addCommentUseCase: sl<AddCommentUseCase>(),
      deleteCommentUseCase: sl<DeleteCommentUseCase>(),
    ),
  );

  // Household use cases
  sl.registerFactory(() => CreateHouseholdUseCase(sl()));
  sl.registerFactory(() => GetHouseholdUseCase(sl()));
  sl.registerFactory(() => JoinHouseholdUseCase(sl()));
  sl.registerFactory(() => GenerateInviteCodeUseCase(sl()));
  sl.registerFactory(() => GetHouseholdFromInviteUseCase(sl()));
  sl.registerFactory(() => ShareRecipeUseCase(sl()));
  sl.registerFactory(() => SendMessageUseCase(sl()));

  // Household cubits
  sl.registerFactory<HouseholdCubit>(
    () => HouseholdCubit(
      createHouseholdUseCase: sl(),
      getHouseholdUseCase: sl(),
      joinHouseholdUseCase: sl(),
      generateInviteCodeUseCase: sl(),
      getHouseholdFromInviteUseCase: sl(),
      repository: sl(),
    ),
  );

  // Share cubit
  sl.registerFactory<ShareCubit>(
    () => ShareCubit(
      messageRepository: sl(),
      sharedRecipeRepository: sl(),
      sendMessageUseCase: sl(),
      shareRecipeUseCase: sl(),
    ),
  );

  // Food Preferences
  sl.registerLazySingleton<IFoodPreferenceRepository>(
    () => FoodPreferenceRepositoryImpl(sl<FirebaseFirestore>()),
  );
  sl.registerFactory(() => GetAllFoodPreferencesUseCase(sl()));
  sl.registerFactory(() => GetUserFoodPreferencesUseCase(sl()));
  sl.registerFactory(() => SaveUserFoodPreferencesUseCase(sl()));
  sl.registerFactory<FoodPreferencesCubit>(
    () => FoodPreferencesCubit(
      getAllFoodPreferencesUseCase: sl(),
      getUserFoodPreferencesUseCase: sl(),
      saveUserFoodPreferencesUseCase: sl(),
    ),
  );
}
