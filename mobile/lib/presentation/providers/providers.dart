import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/uid_storage.dart';
import '../../data/datasources/local/coupon_status_storage.dart';
import '../../data/datasources/remote/firebase_datasource.dart';
import '../../data/datasources/remote/fcm_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/coupon_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../domain/usecases/save_uid.dart';
import '../../domain/usecases/get_uid.dart';
import '../../domain/usecases/has_uid.dart';
import '../../domain/usecases/get_coupons.dart';
import '../../domain/usecases/get_coupons_stream.dart';
import '../../domain/usecases/get_coupon_redemption_url.dart';

// ========== Data Sources ==========

/// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// FlutterSecureStorage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

/// UidStorage Provider
final uidStorageProvider = Provider<UidStorage>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return UidStorage(secureStorage: secureStorage);
});

/// FirebaseDatasource Provider
final firebaseDatasourceProvider = Provider<FirebaseDatasource>((ref) {
  return FirebaseDatasource(firestore: FirebaseFirestore.instance);
});

/// FcmDatasource Provider
final fcmDatasourceProvider = Provider<FcmDatasource>((ref) {
  return FcmDatasource(messaging: FirebaseMessaging.instance);
});

/// CouponStatusStorage Provider
final couponStatusStorageProvider = Provider<CouponStatusStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CouponStatusStorage(prefs);
});

// ========== Repositories ==========

/// UserRepository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final uidStorage = ref.watch(uidStorageProvider);
  final firebaseDatasource = ref.watch(firebaseDatasourceProvider);
  final fcmDatasource = ref.watch(fcmDatasourceProvider);

  return UserRepositoryImpl(
    uidStorage: uidStorage,
    firebaseDatasource: firebaseDatasource,
    fcmDatasource: fcmDatasource,
  );
});

/// CouponRepository Provider
final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  final firebaseDatasource = ref.watch(firebaseDatasourceProvider);

  return CouponRepositoryImpl(
    firebaseDatasource: firebaseDatasource,
  );
});

// ========== Use Cases ==========

/// SaveUid UseCase Provider
final saveUidProvider = Provider<SaveUid>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return SaveUid(userRepository);
});

/// GetUid UseCase Provider
final getUidProvider = Provider<GetUid>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return GetUid(userRepository);
});

/// HasUid UseCase Provider
final hasUidProvider = Provider<HasUid>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return HasUid(userRepository);
});

/// GetCoupons UseCase Provider
final getCouponsProvider = Provider<GetCoupons>((ref) {
  final couponRepository = ref.watch(couponRepositoryProvider);
  return GetCoupons(couponRepository);
});

/// GetCouponsStream UseCase Provider
final getCouponsStreamProvider = Provider<GetCouponsStream>((ref) {
  final couponRepository = ref.watch(couponRepositoryProvider);
  return GetCouponsStream(couponRepository);
});

/// GetCouponRedemptionUrl UseCase Provider
final getCouponRedemptionUrlProvider = Provider<GetCouponRedemptionUrl>((ref) {
  final couponRepository = ref.watch(couponRepositoryProvider);
  return GetCouponRedemptionUrl(couponRepository);
});
