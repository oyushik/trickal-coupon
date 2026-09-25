import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/coupon_provider.dart';
import '../providers/uid_provider.dart';
import '../providers/coupon_status_provider.dart';
import '../widgets/coupon_card.dart';
import '../../core/config/router.dart';

/// 홈 화면 - 쿠폰 목록 표시
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsStream = ref.watch(couponsStreamProvider);
    final uidState = ref.watch(uidStateProvider);
    final couponStatusSet = ref.watch(couponStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('쿠폰스탕스'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRouter.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          // UID 표시 카드
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(
                  'UID: ${uidState.value ?? "로딩 중..."}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          // 쿠폰 목록
          Expanded(
            child: couponsStream.when(
              data: (coupons) {
                if (coupons.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 쿠폰이 없습니다',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '새 쿠폰이 등록되면 푸시 알림을 보내드립니다',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 24),
                        // // 테스트 버튼
                        // ElevatedButton.icon(
                        //   onPressed: () {
                        //     // 테스트용 쿠폰 코드
                        //     const testCouponCode = 'TESTCOUPON123';
                        //     context.push(
                        //       '${AppRouter.webview}?uid=${uidState.value ?? ""}&couponCode=$testCouponCode',
                        //     );
                        //   },
                        //   icon: const Icon(Icons.science),
                        //   label: const Text('웹뷰 테스트'),
                        //   style: ElevatedButton.styleFrom(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 24,
                        //       vertical: 12,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // 스트림이 자동으로 업데이트되므로 별도 처리 불필요
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      final isChecked = couponStatusSet.contains(coupon.feedId);

                      return CouponCard(
                        coupon: coupon,
                        isChecked: isChecked,
                        onTap: () {
                          // WebView로 이동 (웹뷰 내부에서 markAsChecked 호출)
                          ref.read(selectedCouponProvider.notifier).state =
                              coupon;
                          context.push(
                            '${AppRouter.webview}?uid=${uidState.value ?? ""}&couponCode=${coupon.couponCode}&feedId=${coupon.feedId}',
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '쿠폰 목록을 불러올 수 없습니다',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
