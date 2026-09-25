import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/uid_provider.dart';
import '../providers/providers.dart';
import '../../core/config/router.dart';

/// UID 등록 화면
class UidSetupPage extends ConsumerStatefulWidget {
  const UidSetupPage({super.key});

  @override
  ConsumerState<UidSetupPage> createState() => _UidSetupPageState();
}

class _UidSetupPageState extends ConsumerState<UidSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  /// UID 저장 + 푸시 알림 설정 (트랜잭션)
  Future<void> _handleSaveUid() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = _uidController.text.trim();

      // 트랜잭션 방식으로 UID + FCM 토큰 등록
      final userRepository = ref.read(userRepositoryProvider);
      await userRepository.setupUserWithNotification(uid);

      // UID Provider 상태 업데이트
      await ref.read(uidStateProvider.notifier).loadUid();

      if (!mounted) return;

      // 성공 시 홈 화면으로 이동
      context.go(AppRouter.home);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 설정 완료! 푸시 알림을 받을 준비가 되었습니다'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // 사용자 친화적 에러 메시지
      String errorMessage = '설정에 실패했습니다';
      if (e.toString().contains('알림 권한')) {
        errorMessage = '푸시 알림 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = '네트워크 연결을 확인해주세요';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '재시도',
            textColor: Colors.white,
            onPressed: _handleSaveUid,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 앱 아이콘/로고
              const Icon(Icons.card_giftcard, size: 80, color: Colors.green),
              const SizedBox(height: 24),

              // 제목
              Text(
                '쿠폰스탕스',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // 설명
              Text(
                '새로운 쿠폰을 실시간으로 알려드립니다',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // UID 입력 폼
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UID 입력',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _uidController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        hintText: '인게임 UID를 입력하세요',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'UID를 입력해주세요';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                          return 'UID는 숫자로만 구성되어야 합니다';
                        }
                        if (value.trim().length > 10) {
                          return 'UID는 최대 10자리까지 입력 가능합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💡 UID는 게임 설정에서 확인할 수 있습니다',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 저장 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSaveUid,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
