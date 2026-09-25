import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/coupon.dart';
import 'providers.dart';

/// 쿠폰 목록 스트림 Provider
final couponsStreamProvider = StreamProvider<List<Coupon>>((ref) {
  final getCouponsStream = ref.watch(getCouponsStreamProvider);
  return getCouponsStream.call(limit: 20);
});

/// 쿠폰 목록 FutureProvider (일회성 조회)
final couponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final getCoupons = ref.watch(getCouponsProvider);
  return await getCoupons.call(limit: 50);
});

/// 선택된 쿠폰 Provider
final selectedCouponProvider = StateProvider<Coupon?>((ref) => null);
