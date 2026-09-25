import '../../domain/entities/coupon.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../datasources/remote/firebase_datasource.dart';

/// CouponRepository 구현체
class CouponRepositoryImpl implements CouponRepository {
  final FirebaseDatasource _firebaseDatasource;

  /// 쿠폰 입력 사이트 기본 URL
  static const String _couponRedemptionBaseUrl =
      'https://coupon.a.prod.service.trickcal.io/';

  CouponRepositoryImpl({
    required FirebaseDatasource firebaseDatasource,
  }) : _firebaseDatasource = firebaseDatasource;

  // ========== 쿠폰 조회 ==========

  @override
  Future<List<Coupon>> getAllCoupons({int limit = 50}) async {
    final couponModels = await _firebaseDatasource.getAllCoupons(limit: limit);
    return couponModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Coupon>> getCouponsByDate(DateTime date) async {
    final couponModels = await _firebaseDatasource.getCouponsByDate(date);
    return couponModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Coupon?> getCouponById(String feedId) async {
    final couponModel = await _firebaseDatasource.getCoupon(feedId);
    return couponModel?.toEntity();
  }

  @override
  Stream<List<Coupon>> getCouponsStream({int limit = 20}) {
    return _firebaseDatasource
        .getCouponsStream(limit: limit)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  // ========== 쿠폰 등록 URL 생성 ==========

  @override
  String getCouponRedemptionUrl({String? uid, String? couponCode}) {
    // 기본 URL만 반환 (JavaScript로 자동 입력 처리)
    return _couponRedemptionBaseUrl;
  }
}
