"""
좀비 FCM 토큰 자동 삭제 기능 테스트
"""
import pytest
from unittest.mock import Mock, MagicMock
from src.services.notification_service import NotificationService


class TestTokenCleanup:
    """FCM 토큰 정리 기능 테스트"""

    def test_permanent_error_detection(self):
        """영구 오류 코드 감지 테스트"""
        service = NotificationService()

        # UNREGISTERED 오류
        assert service._is_permanent_error('UNREGISTERED') is True

        # INVALID_ARGUMENT 오류
        assert service._is_permanent_error('INVALID_ARGUMENT') is True

        # SENDER_ID_MISMATCH 오류
        assert service._is_permanent_error('SENDER_ID_MISMATCH') is True

        # 일시적 오류 (재시도 가능)
        assert service._is_permanent_error('UNAVAILABLE') is False
        assert service._is_permanent_error('INTERNAL') is False
        assert service._is_permanent_error(None) is False

    def test_error_code_extraction_from_exception(self):
        """예외에서 에러 코드 추출 테스트"""
        service = NotificationService()

        # code 속성이 있는 예외
        exception = Mock()
        exception.code = 'UNREGISTERED'
        assert service._get_error_code(exception) == 'UNREGISTERED'

        # 문자열에서 파싱
        exception = Exception("Error sending message: UNREGISTERED token")
        error_code = service._get_error_code(exception)
        assert error_code == 'UNREGISTERED'

        # None 예외
        assert service._get_error_code(None) is None

    def test_send_coupon_notification_returns_failed_tokens(self):
        """알림 전송 시 실패한 토큰 반환 테스트"""
        service = NotificationService()

        # messaging이 None인 경우 (mock 모드)
        result = service.send_coupon_notification(
            tokens=['token1', 'token2'],
            coupon_code='TEST123',
            title='테스트',
            feed_id=123
        )

        # 반환값에 failed_tokens 키가 있어야 함
        assert 'success' in result
        assert 'failure' in result
        assert 'failed_tokens' in result
        assert isinstance(result['failed_tokens'], list)

    def test_empty_token_list(self):
        """빈 토큰 리스트 처리 테스트"""
        service = NotificationService()

        result = service.send_coupon_notification(
            tokens=[],
            coupon_code='TEST123',
            title='테스트',
            feed_id=123
        )

        assert result['success'] == 0
        assert result['failure'] == 0
        assert result['failed_tokens'] == []


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
