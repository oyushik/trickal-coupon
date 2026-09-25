"""
Firestore 데이터베이스 서비스
feedId 추적, 사용자 FCM 토큰 관리
"""
from typing import List, Set, Optional
import logging
from datetime import datetime, timedelta

try:
    from firebase_admin import firestore
    import firebase_admin
except ImportError:
    # 로컬 테스트 환경에서는 mock 사용
    firestore = None
    firebase_admin = None

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class FirestoreService:
    """Firestore 데이터베이스 작업을 처리하는 서비스"""

    def __init__(self):
        """Firestore 클라이언트 초기화"""
        if firestore is None:
            logger.warning("Firebase Admin SDK not available. Using mock mode.")
            self.db = None
        else:
            try:
                self.db = firestore.client()
                logger.info("Firestore client initialized")
            except Exception as e:
                logger.error(f"Failed to initialize Firestore client: {e}")
                self.db = None

    def is_feed_processed_today(self, feed_id: int) -> bool:
        """
        오늘 이미 처리된 feedId인지 확인합니다.

        Args:
            feed_id: Feed ID

        Returns:
            이미 처리되었으면 True
        """
        if not self.db:
            logger.warning("Firestore not available, returning False")
            return False

        try:
            today = datetime.now().strftime("%Y%m%d")
            doc_ref = self.db.collection('processed_feeds').document(f"{today}_{feed_id}")
            doc = doc_ref.get()

            return doc.exists

        except Exception as e:
            logger.error(f"Error checking if feed {feed_id} is processed: {e}")
            return False

    def mark_feed_as_processed(self, feed_id: int, coupon_code: str, title: str):
        """
        feedId를 처리 완료로 표시합니다.

        Args:
            feed_id: Feed ID
            coupon_code: 쿠폰 코드
            title: 게시물 제목
        """
        if not self.db:
            logger.warning("Firestore not available, skipping mark as processed")
            return

        try:
            today = datetime.now().strftime("%Y%m%d")
            doc_ref = self.db.collection('processed_feeds').document(f"{today}_{feed_id}")

            doc_ref.set({
                'feed_id': feed_id,
                'coupon_code': coupon_code,
                'title': title,
                'processed_at': firestore.SERVER_TIMESTAMP,
                'date': today
            })

            logger.info(f"Marked feed {feed_id} as processed")

        except Exception as e:
            logger.error(f"Error marking feed {feed_id} as processed: {e}")

    def get_all_fcm_tokens(self) -> List[str]:
        """
        모든 사용자의 FCM 토큰을 가져옵니다.

        Returns:
            FCM 토큰 리스트
        """
        if not self.db:
            logger.warning("Firestore not available, returning empty list")
            return []

        try:
            logger.info("Starting to retrieve FCM tokens from Firestore...")
            users_ref = self.db.collection('users')
            docs = users_ref.stream()

            tokens = []
            doc_count = 0
            for doc in docs:
                doc_count += 1
                user_data = doc.to_dict()
                logger.info(f"Processing user document {doc.id}: {user_data}")
                fcm_token = user_data.get('fcm_token')
                if fcm_token:
                    tokens.append(fcm_token)
                    logger.info(f"Added FCM token from user {doc.id}: {fcm_token[:20]}...")
                else:
                    logger.warning(f"User {doc.id} has no fcm_token field")

            logger.info(f"Retrieved {len(tokens)} FCM tokens from {doc_count} user documents")
            return tokens

        except Exception as e:
            logger.error(f"Error retrieving FCM tokens: {e}", exc_info=True)
            return []

    def delete_fcm_token(self, fcm_token: str) -> bool:
        """
        만료된 FCM 토큰을 Firestore에서 삭제합니다.

        Args:
            fcm_token: 삭제할 FCM 토큰

        Returns:
            삭제 성공 여부
        """
        if not self.db:
            logger.warning("Firestore not available, skipping token deletion")
            return False

        try:
            # fcm_token 필드로 사용자 문서 검색
            users_ref = self.db.collection('users')
            query = users_ref.where('fcm_token', '==', fcm_token).limit(1)
            docs = query.stream()

            deleted = False
            for doc in docs:
                doc.reference.delete()
                logger.info(f"Deleted user document {doc.id} with token {fcm_token[:20]}...")
                deleted = True
                break

            if not deleted:
                logger.warning(f"No user found with token {fcm_token[:20]}...")

            return deleted

        except Exception as e:
            logger.error(f"Error deleting FCM token: {e}", exc_info=True)
            return False

    def delete_fcm_tokens_batch(self, fcm_tokens: List[str]) -> int:
        """
        여러 FCM 토큰을 일괄 삭제합니다.

        Args:
            fcm_tokens: 삭제할 FCM 토큰 리스트

        Returns:
            삭제된 토큰 개수
        """
        if not self.db:
            logger.warning("Firestore not available, skipping batch deletion")
            return 0

        if not fcm_tokens:
            return 0

        try:
            deleted_count = 0
            users_ref = self.db.collection('users')

            # 각 토큰에 대해 삭제 수행
            for fcm_token in fcm_tokens:
                query = users_ref.where('fcm_token', '==', fcm_token).limit(1)
                docs = query.stream()

                for doc in docs:
                    doc.reference.delete()
                    logger.info(f"Deleted user document {doc.id} with token {fcm_token[:20]}...")
                    deleted_count += 1
                    break

            logger.info(f"Batch deleted {deleted_count} out of {len(fcm_tokens)} tokens")
            return deleted_count

        except Exception as e:
            logger.error(f"Error batch deleting FCM tokens: {e}", exc_info=True)
            return 0

    def save_coupon_history(self, feed_id: int, coupon_code: str, title: str, created_date: str):
        """
        쿠폰 발견 이력을 저장합니다.

        Args:
            feed_id: Feed ID
            coupon_code: 쿠폰 코드
            title: 게시물 제목
            created_date: 게시물 작성일시
        """
        if not self.db:
            logger.warning("Firestore not available, skipping coupon history")
            return

        try:
            coupon_ref = self.db.collection('coupons').document(str(feed_id))

            coupon_ref.set({
                'feed_id': feed_id,
                'coupon_code': coupon_code,
                'title': title,
                'created_date': created_date,
                'discovered_at': firestore.SERVER_TIMESTAMP
            })

            logger.info(f"Saved coupon history for feed {feed_id}")

        except Exception as e:
            logger.error(f"Error saving coupon history: {e}")

    def cleanup_old_processed_feeds(self, days_to_keep: int = 7):
        """
        오래된 처리 완료 기록을 삭제합니다.

        Args:
            days_to_keep: 보관할 일수 (기본 7일)
        """
        if not self.db:
            logger.warning("Firestore not available, skipping cleanup")
            return

        try:
            cutoff_date = (datetime.now() - timedelta(days=days_to_keep)).strftime("%Y%m%d")

            processed_ref = self.db.collection('processed_feeds')
            old_docs = processed_ref.where('date', '<', cutoff_date).stream()

            deleted_count = 0
            for doc in old_docs:
                doc.reference.delete()
                deleted_count += 1

            logger.info(f"Cleaned up {deleted_count} old processed feed records")

        except Exception as e:
            logger.error(f"Error cleaning up old records: {e}")

    def cleanup_old_coupons(self, days_to_keep: int = 14):
        """
        오래된 쿠폰 이력을 삭제합니다.

        Args:
            days_to_keep: 보관할 일수 (기본 14일)
        """
        if not self.db:
            logger.warning("Firestore not available, skipping cleanup")
            return

        try:
            cutoff_datetime = datetime.now() - timedelta(days=days_to_keep)

            coupons_ref = self.db.collection('coupons')
            old_docs = coupons_ref.where('discovered_at', '<', cutoff_datetime).stream()

            deleted_count = 0
            for doc in old_docs:
                doc.reference.delete()
                deleted_count += 1

            logger.info(f"Cleaned up {deleted_count} old coupon records (older than {days_to_keep} days)")

        except Exception as e:
            logger.error(f"Error cleaning up old coupons: {e}")


# 싱글톤 인스턴스
_firestore_service = None


def get_firestore_service() -> FirestoreService:
    """FirestoreService 싱글톤 인스턴스를 반환합니다."""
    global _firestore_service
    if _firestore_service is None:
        _firestore_service = FirestoreService()
    return _firestore_service
