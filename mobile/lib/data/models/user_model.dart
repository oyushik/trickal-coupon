import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

/// Firestore와 엔티티 간 변환을 담당하는 사용자 모델 (FCM 토큰만 저장)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fcmToken,
    required super.createdAt,
    super.updatedAt,
  });

  /// Firestore 문서에서 UserModel 생성
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      fcmToken: data['fcm_token'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Map에서 UserModel 생성
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      fcmToken: map['fcm_token'] as String,
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] is Timestamp
              ? (map['updated_at'] as Timestamp).toDate()
              : DateTime.parse(map['updated_at'] as String))
          : null,
    );
  }

  /// Firestore에 저장할 Map으로 변환 (FCM 토큰만)
  Map<String, dynamic> toFirestore() {
    return {
      'fcm_token': fcmToken,
      'created_at': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  /// 일반 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// User 엔티티에서 UserModel 생성
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fcmToken: user.fcmToken,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// User 엔티티로 변환
  User toEntity() {
    return User(
      id: id,
      fcmToken: fcmToken,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// FCM 토큰 업데이트를 위한 copyWith
  @override
  UserModel copyWith({
    String? id,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
