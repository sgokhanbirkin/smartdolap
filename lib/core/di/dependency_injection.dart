import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:smartdolap/features/auth/domain/use_cases/login_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/register_usecase.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/pantry/data/repositories/pantry_repository_impl.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/add_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/delete_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/list_pantry_items.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/update_pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/recipes/data/repositories/recipes_repository_impl.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/suggest_recipes_from_pantry.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'package:smartdolap/product/services/openai/openai_service.dart';

/// Dependency injection service locator
final GetIt sl = GetIt.instance;

/// Setup dependency injection locator
Future<void> setupLocator() async {
  // Hive
  await Hive.initFlutter();
  // Burada ileride adapter register edilecek (Ingredient, vb.)
  await dotenv.load(fileName: '.env');
  // Local cache boxes
  await Hive.openBox<dynamic>('recipes_cache');

  // Firebase
  sl.registerLazySingleton<fb.FirebaseAuth>(() => fb.FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Auth — DIP: arayüz → implementasyon
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl<fb.FirebaseAuth>()),
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
    () => PantryRepositoryImpl(sl<FirebaseFirestore>()),
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
    ),
  );

  // OpenAI
  sl.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: 'https://api.openai.com/v1')),
  );
  sl.registerLazySingleton<IOpenAIService>(() => OpenAIService(dio: sl()));

  // Recipes
  sl.registerLazySingleton<IRecipesRepository>(
    () => RecipesRepositoryImpl(sl<FirebaseFirestore>(), sl(), sl()),
  );
  sl.registerFactory(() => SuggestRecipesFromPantry(sl()));
  sl.registerFactory(() => RecipesCubit(suggest: sl(), openAI: sl()));
}
