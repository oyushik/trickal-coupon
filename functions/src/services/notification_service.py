"""
FCM 푸시 알림 서비스
"""
from typing import List, Dict, Optional
import logging

try:
    from firebase_admin import messaging
    from firebase_admin.exceptions import FirebaseError
except ImportError:
    messaging = None
    FirebaseError = Exception

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class NotificationService:
    """FCM 푸시 알림을 전송하는 서비스"""

    # 영구 오류 코드 (토큰이 무효화되어 삭제가 필요한 경우)
    PERMANENT_ERROR_CODES = {
        'UNREGISTERED',           # 토큰이 등록 해제됨 (앱 삭제, 토큰 만료)
        'INVALID_ARGUMENT',       # 잘못된 토큰 형식
        'SENDER_ID_MISMATCH',     # 프로젝트 불일치
    }

    def __init__(self):
        """알림 서비스 초기화"""
        if messaging is None:
            logger.warning("Firebase Messaging not available. Using mock mode.")

    def send_coupon_notification(
        self,
        tokens: List[str],
        coupon_code: str,
        title: str,
        feed_id: int
    ) -> Dict[str, any]:
        """
        모든 사용자에게 쿠폰 알림을 전송합니다.

        Args:
            tokens: FCM 토큰 리스트
            coupon_code: 쿠폰 코드
            title: 게시물 제목
            feed_id: Feed ID

        Returns:
            {
                'success': 성공 수,
                'failure': 실패 수,
                'failed_tokens': 영구 오류로 삭제가 필요한 토큰 리스트
            }
        """
        if not tokens:
            logger.warning("No FCM tokens to send notification")
            return {'success': 0, 'failure': 0, 'failed_tokens': []}

        if messaging is None:
            logger.warning("Firebase Messaging not available, skipping notification")
            return {'success': 0, 'failure': len(tokens), 'failed_tokens': []}

        try:
            # FCM 메시지 생성
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title='🎁 새로운 쿠폰이 등록되었습니다!',
                    body=f'쿠폰 코드: {coupon_code}'
                ),
                data={
                    'coupon_code': coupon_code,
                    'title': title,
                    'feed_id': str(feed_id),
                    'type': 'coupon_notification'
                },
                tokens=tokens
            )

            # 멀티캐스트 전송 (send_each_for_multicast 또는 send_all 사용)
            response = messaging.send_each_for_multicast(message)

            logger.info(
                f"Notification sent: {response.success_count} success, "
                f"{response.failure_count} failure out of {len(tokens)} tokens"
            )

            # 실패한 토큰 중 영구 오류인 것만 추출
            failed_tokens = []
            if response.failure_count > 0:
                for idx, resp in enumerate(response.responses):
                    if not resp.success:
                        token = tokens[idx]
                        error_code = self._get_error_code(resp.exception)

                        logger.warning(
                            f"Failed to send to token {idx} (code: {error_code}): {resp.exception}"
                        )

                        # 영구 오류인 경우 삭제 대상 목록에 추가
                        if self._is_permanent_error(error_code):
                            failed_tokens.append(token)
                            logger.info(
                                f"Token marked for deletion (permanent error): "
                                f"{token[:20]}... (error: {error_code})"
                            )

            if failed_tokens:
                logger.info(f"Total {len(failed_tokens)} tokens marked for deletion")

            return {
                'success': response.success_count,
                'failure': response.failure_count,
                'failed_tokens': failed_tokens
            }

        except Exception as e:
            logger.error(f"Error sending notification: {e}", exc_info=True)
            return {'success': 0, 'failure': len(tokens), 'failed_tokens': []}

    def _get_error_code(self, exception: Optional[Exception]) -> Optional[str]:
        """
        FCM 예외에서 에러 코드를 추출합니다.

        Args:
            exception: FCM 예외 객체

        Returns:
            에러 코드 문자열 또는 None
        """
        if exception is None:
            return None

        # MessagingError에서 code 속성 추출
        if hasattr(exception, 'code'):
            return exception.code

        # 문자열에서 에러 코드 파싱 시도
        error_str = str(exception)
        for error_code in self.PERMANENT_ERROR_CODES:
            if error_code in error_str:
                return error_code

        return None

    def _is_permanent_error(self, error_code: Optional[str]) -> bool:
        """
        영구 오류인지 판별합니다 (토큰 삭제가 필요한 경우).

        Args:
            error_code: 에러 코드

        Returns:
            영구 오류이면 True
        """
        if error_code is None:
            return False

        return error_code in self.PERMANENT_ERROR_CODES

    def send_test_notification(self, token: str) -> bool:
        """
        테스트 알림을 전송합니다.

        Args:
            token: FCM 토큰

        Returns:
            성공 여부
        """
        if messaging is None:
            logger.warning("Firebase Messaging not available")
            return False

        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title='쿠폰스탕스',
                    body='알림이 정상적으로 작동합니다! 🎉'
                ),
                data={
                    'type': 'test_notification'
                },
                token=token
            )

            response = messaging.send(message)
            logger.info(f"Test notification sent: {response}")
            return True

        except Exception as e:
            logger.error(f"Error sending test notification: {e}")
            return False


# 싱글톤 인스턴스
_notification_service = None


def get_notification_service() -> NotificationService:
    """NotificationService 싱글톤 인스턴스를 반환합니다."""
    global _notification_service
    if _notification_service is None:
        _notification_service = NotificationService()
    return _notification_service
