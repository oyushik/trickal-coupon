/// 쿠폰 엔티티
class Coupon {
  final int feedId;
  final String couponCode;
  final String title;
  final String createdDate;
  final DateTime discoveredAt;

  const Coupon({
    required this.feedId,
    required this.couponCode,
    required this.title,
    required this.createdDate,
    required this.discoveredAt,
  });

  @override
  String toString() {
    return 'Coupon(feedId: $feedId, couponCode: $couponCode, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coupon &&
        other.feedId == feedId &&
        other.couponCode == couponCode;
  }

  @override
  int get hashCode => feedId.hashCode ^ couponCode.hashCode;
}
