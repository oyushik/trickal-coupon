import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/coupon_model.dart';

/// Firestore와 통신하는 원격 데이터 소스
class FirebaseDatasource {
  final FirebaseFirestore _firestore;

  FirebaseDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ========== 컬렉션 참조 ==========

  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _couponsCollection => _firestore.collection('coupons');

  // ========== 사용자 관리 ==========

  /// 사용자 정보 저장 (FCM 토큰 기반 문서 ID)
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toFirestore());
    } catch (e) {
      throw FirebaseDataSourceException('사용자 정보 저장 실패: $e');
    }
  }

  /// 사용자 정보 조회
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw FirebaseDataSourceException('사용자 정보 조회 실패: $e');
    }
  }

  /// FCM 토큰으로 사용자 검색
  Future<UserModel?> getUserByToken(String fcmToken) async {
    try {
      final querySnapshot = await _usersCollection
          .where('fcm_token', isEqualTo: fcmToken)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return UserModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw FirebaseDataSourceException('토큰으로 사용자 검색 실패: $e');
    }
  }

  /// FCM 토큰 업데이트
  Future<void> updateFcmToken(String userId, String fcmToken) async {
    try {
      await _usersCollection.doc(userId).update({
        'fcm_token': fcmToken,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebaseDataSourceException('FCM 토큰 업데이트 실패: $e');
    }
  }

  /// 사용자 정보 삭제
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw FirebaseDataSourceException('사용자 정보 삭제 실패: $e');
    }
  }

  // ========== 쿠폰 이력 조회 ==========

  /// 모든 쿠폰 이력 조회 (최신순)
  Future<List<CouponModel>> getAllCoupons({int limit = 50}) async {
    try {
      final querySnapshot = await _couponsCollection
          .orderBy('discovered_at', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => CouponModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirebaseDataSourceException('쿠폰 이력 조회 실패: $e');
    }
  }

  /// 특정 날짜의 쿠폰 조회
  Future<List<CouponModel>> getCouponsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _couponsCollection
          .where('discovered_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('discovered_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('discovered_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CouponModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirebaseDataSourceException('날짜별 쿠폰 조회 실패: $e');
    }
  }

  /// 특정 쿠폰 조회
  Future<CouponModel?> getCoupon(String feedId) async {
    try {
      final doc = await _couponsCollection.doc(feedId).get();
      if (!doc.exists) return null;
      return CouponModel.fromFirestore(doc);
    } catch (e) {
      throw FirebaseDataSourceException('쿠폰 조회 실패: $e');
    }
  }

  /// 쿠폰 실시간 스트림 (최신 N개)
  Stream<List<CouponModel>> getCouponsStream({int limit = 20}) {
    try {
      return _couponsCollection
          .orderBy('discovered_at', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CouponModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw FirebaseDataSourceException('쿠폰 스트림 생성 실패: $e');
    }
  }
}

/// Firebase 데이터 소스 예외
class FirebaseDataSourceException implements Exception {
  final String message;

  FirebaseDataSourceException(this.message);

  @override
  String toString() => 'FirebaseDataSourceException: $message';
}
