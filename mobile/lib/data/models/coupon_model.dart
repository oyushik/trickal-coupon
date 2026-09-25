import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/coupon.dart';

/// Firestore와 엔티티 간 변환을 담당하는 쿠폰 모델
class CouponModel extends Coupon {
  const CouponModel({
    required super.feedId,
    required super.couponCode,
    required super.title,
    required super.createdDate,
    required super.discoveredAt,
  });

  /// Firestore 문서에서 CouponModel 생성
  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CouponModel(
      feedId: data['feed_id'] as int,
      couponCode: data['coupon_code'] as String,
      title: data['title'] as String,
      createdDate: data['created_date'] as String,
      discoveredAt: (data['discovered_at'] as Timestamp).toDate(),
    );
  }

  /// Map에서 CouponModel 생성 (FCM 알림 데이터용)
  factory CouponModel.fromMap(Map<String, dynamic> map) {
    return CouponModel(
      feedId: int.parse(map['feed_id'] as String),
      couponCode: map['coupon_code'] as String,
      title: map['title'] as String,
      createdDate: map['created_date'] as String? ?? '',
      discoveredAt: DateTime.now(),
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'feed_id': feedId,
      'coupon_code': couponCode,
      'title': title,
      'created_date': createdDate,
      'discovered_at': Timestamp.fromDate(discoveredAt),
    };
  }

  /// 일반 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'feed_id': feedId.toString(),
      'coupon_code': couponCode,
      'title': title,
      'created_date': createdDate,
      'discovered_at': discoveredAt.toIso8601String(),
    };
  }

  /// Coupon 엔티티에서 CouponModel 생성
  factory CouponModel.fromEntity(Coupon coupon) {
    return CouponModel(
      feedId: coupon.feedId,
      couponCode: coupon.couponCode,
      title: coupon.title,
      createdDate: coupon.createdDate,
      discoveredAt: coupon.discoveredAt,
    );
  }

  /// Coupon 엔티티로 변환
  Coupon toEntity() {
    return Coupon(
      feedId: feedId,
      couponCode: couponCode,
      title: title,
      createdDate: createdDate,
      discoveredAt: discoveredAt,
    );
  }
}
