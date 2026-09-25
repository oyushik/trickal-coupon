/// 사용자 엔티티 (FCM 토큰만 저장, UID는 로컬에만 저장)
class User {
  /// 사용자 문서 ID (FCM 토큰을 기반으로 생성)
  final String id;

  /// FCM 토큰
  final String fcmToken;

  /// 생성 일시
  final DateTime createdAt;

  /// 마지막 업데이트 일시
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.fcmToken,
    required this.createdAt,
    this.updatedAt,
  });

  /// copyWith 메서드
  User copyWith({
    String? id,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, fcmToken: ${fcmToken.substring(0, 20)}..., createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.fcmToken == fcmToken &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fcmToken.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
