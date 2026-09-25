import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/router.dart';
import '../providers/theme_provider.dart';
import '../providers/uid_provider.dart';

/// 설정 화면
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUid();
  }

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  /// 현재 UID 로드
  Future<void> _loadCurrentUid() async {
    final uidState = ref.read(uidStateProvider);
    if (uidState.value != null) {
      _uidController.text = uidState.value!;
    }
  }

  /// UID 업데이트
  Future<void> _updateUid() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = _uidController.text.trim();

    try {
      await ref.read(uidStateProvider.notifier).setUid(uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UID가 업데이트되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('UID 업데이트 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// UID 삭제 확인 다이얼로그
  Future<void> _confirmDeleteUid() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('UID 삭제'),
        content: const Text('정말 UID를 삭제하시겠습니까?\n앱을 다시 시작하면 UID 입력 화면이 표시됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(uidStateProvider.notifier).clearUid();
      if (mounted) {
        context.go(AppRouter.uidSetup);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          // UID 설정 섹션
          _buildSection(
            title: 'UID 관리',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _uidController,
                        readOnly: !_isEditing,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: '게임 UID',
                          hintText: '트릭컬 리바이브 UID 입력',
                          suffixIcon: _isEditing
                              ? IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: _updateUid,
                                )
                              : IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() => _isEditing = true);
                                  },
                                ),
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
                      if (_isEditing) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() => _isEditing = false);
                                _loadCurrentUid();
                              },
                              child: const Text('취소'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _updateUid,
                              child: const Text('저장'),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _confirmDeleteUid,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'UID 삭제',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Divider(),

          // 테마 설정 섹션
          _buildSection(
            title: '테마',
            children: [
              ListTile(
                leading: Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(value);
                    }
                  },
                ),
                title: const Text('라이트 모드'),
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light),
              ),
              ListTile(
                leading: Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(value);
                    }
                  },
                ),
                title: const Text('다크 모드'),
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark),
              ),
              ListTile(
                leading: Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(value);
                    }
                  },
                ),
                title: const Text('시스템 설정 따라가기'),
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.system),
              ),
            ],
          ),

          const Divider(),

          // 앱 정보 섹션
          _buildSection(
            title: '앱 정보',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('앱 버전'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('면책 조항'),
                subtitle: const Text(
                  '쿠폰스탕스는 팬 프로젝트로, 에피드게임즈에서 제공하는 공식 서비스가 아닙니다.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRouter.disclaimer);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('문의하기'),
                subtitle: const Text('nicker.erasers_3y@icloud.com'),
                onTap: () {
                  // TODO: 이메일 앱 열기
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이메일 기능은 준비 중입니다')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 섹션 빌더
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...children,
      ],
    );
  }
}
