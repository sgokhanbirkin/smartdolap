import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:smartdolap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:smartdolap/features/auth/domain/use_cases/login_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/register_usecase.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';

/// Dependency injection service locator
final GetIt sl = GetIt.instance;

/// Setup dependency injection locator
Future<void> setupLocator() async {
  // Hive
  await Hive.initFlutter();
  // Burada ileride adapter register edilecek (Ingredient, vb.)

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
}
