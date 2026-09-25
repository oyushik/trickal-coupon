import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/coupon.dart';

/// 쿠폰 카드 위젯
class CouponCard extends StatelessWidget {
  final Coupon coupon;
  final bool isChecked;
  final VoidCallback? onTap;

  const CouponCard({
    super.key,
    required this.coupon,
    this.isChecked = false,
    this.onTap,
  });

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  /// 쿠폰 코드 복사
  void _copyCouponCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.couponCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('쿠폰 코드 복사됨: ${coupon.couponCode}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 확인된 쿠폰의 색상 설정
    final textColor = isChecked ? Colors.grey[500] : null;
    final titleColor = isChecked ? Colors.grey[600] : null;
    final containerColor = isChecked
        ? Colors.grey[200]
        : Theme.of(context).colorScheme.primaryContainer;
    final iconColor = isChecked
        ? Colors.grey[400]
        : Theme.of(context).colorScheme.primary;
    final codeColor = isChecked
        ? Colors.grey[600]
        : Theme.of(context).colorScheme.primary;

    return Opacity(
      opacity: isChecked ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                coupon.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 쿠폰 코드
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 20,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          coupon.couponCode,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                    isChecked
                        ? OutlinedButton.icon(
                            onPressed: onTap,
                            icon: const Icon(Icons.input, size: 16),
                            label: const Text('입력하기'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              side: BorderSide(color: Colors.grey[400]!),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: onTap,
                            icon: const Icon(Icons.input, size: 16),
                            label: const Text('입력하기'),
                            style: FilledButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white!),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 발견 시간
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: textColor ?? Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(coupon.discoveredAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor ?? Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
