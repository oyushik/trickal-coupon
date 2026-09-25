import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../providers/coupon_status_provider.dart';

/// 쿠폰 입력 웹뷰 화면
class WebViewPage extends ConsumerStatefulWidget {
  final String? uid;
  final String? couponCode;
  final int? feedId;

  const WebViewPage({
    super.key,
    this.uid,
    this.couponCode,
    this.feedId,
  });

  @override
  ConsumerState<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends ConsumerState<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _markAsChecked();
  }

  /// 쿠폰을 확인됨으로 표시
  void _markAsChecked() {
    if (widget.feedId != null) {
      // 웹뷰 진입 시 즉시 체크 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(couponStatusProvider.notifier).markAsChecked(widget.feedId!);
        debugPrint('✅ 쿠폰 확인 처리: feedId=${widget.feedId}');
      });
    }
  }

  /// 에러 타입에 따른 사용자 친화적 메시지
  String _getErrorMessage(WebResourceErrorType? errorType) {
    if (errorType == null) {
      return '페이지를 불러올 수 없습니다';
    }

    switch (errorType) {
      case WebResourceErrorType.hostLookup:
      case WebResourceErrorType.connect:
        return '인터넷 연결을 확인해주세요';
      case WebResourceErrorType.timeout:
        return '요청 시간이 초과되었습니다';
      case WebResourceErrorType.fileNotFound:
        return '페이지를 찾을 수 없습니다';
      default:
        return '페이지를 불러올 수 없습니다';
    }
  }

  /// 페이지 재시도 (자동입력 포함)
  Future<void> _retry() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
    });
    await _controller.reload();
  }

  /// WebView 초기화
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // User-Agent를 일반 브라우저처럼 설정 (봇 차단 우회)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _errorMessage = null;
            });
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            if (!_hasError) {
              _autoFillInputs();
            }
          },
          onWebResourceError: (error) {
            debugPrint('WebView 오류: ${error.description}');
            setState(() {
              _hasError = true;
              _isLoading = false;
              _errorMessage = _getErrorMessage(error.errorType);
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConstants.couponRedemptionUrl));
  }

  /// UID와 쿠폰 코드 자동 입력 및 스크롤
  Future<void> _autoFillInputs() async {
    // 페이지 로딩 완료 후 약간의 지연
    await Future.delayed(const Duration(milliseconds: 500));

    // JavaScript로 자동 입력 및 스크롤 (이벤트 발생 포함)
    final jsCode = '''
      (function() {
        try {
          // 입력 필드 찾기
          var userIdInput = document.getElementById('${AppConstants.userIdInputId}');
          var couponInput = document.getElementById('${AppConstants.couponCodeInputId}');

          // 입력 이벤트를 발생시키는 함수 (실제 타이핑처럼 보이게)
          function setInputValue(element, value) {
            if (!element) return;

            // 값 설정
            element.value = value;

            // 실제 사용자 입력처럼 이벤트 발생
            element.dispatchEvent(new Event('input', { bubbles: true }));
            element.dispatchEvent(new Event('change', { bubbles: true }));
            element.dispatchEvent(new Event('blur', { bubbles: true }));
          }

          // 자동 입력 (이벤트 포함)
          ${widget.uid != null ? "setInputValue(userIdInput, '${widget.uid}');" : ""}
          ${widget.couponCode != null ? "setInputValue(couponInput, '${widget.couponCode}');" : ""}

          // 입력 필드로 스크롤
          var targetElement = couponInput || userIdInput;
          if (targetElement) {
            targetElement.scrollIntoView({
              behavior: 'smooth',
              block: 'center',
              inline: 'center'
            });
          }

          console.log('자동 입력 및 스크롤 완료');
        } catch (e) {
          console.error('자동 입력 실패:', e);
        }
      })();
    ''';

    try {
      await _controller.runJavaScript(jsCode);
      debugPrint('✅ 자동 입력 및 스크롤 완료: UID=${widget.uid}, Coupon=${widget.couponCode}');
    } catch (e) {
      debugPrint('❌ 자동 입력 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쿠폰 입력'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_hasError)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? '페이지를 불러올 수 없습니다',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 시도'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
