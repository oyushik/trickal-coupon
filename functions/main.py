"""
Firebase Cloud Functions 메인 진입점
"""
import logging
from typing import Dict, Any

try:
    import firebase_admin
    from firebase_admin import credentials
    from firebase_functions import scheduler_fn

    # Firebase Admin SDK 초기화
    if not firebase_admin._apps:
        firebase_admin.initialize_app()
except ImportError:
    # 로컬 테스트 환경
    scheduler_fn = None

from src.scraper.coupon_scraper import CouponScraper
from src.services.firestore_service import get_firestore_service
from src.services.notification_service import get_notification_service

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def process_coupons() -> Dict[str, Any]:
    """
    쿠폰 스크래핑 및 알림 전송 로직

    Returns:
        처리 결과 딕셔너리
    """
    logger.info("Starting coupon scraping process")

    # 서비스 초기화
    scraper = CouponScraper()
    firestore_service = get_firestore_service()
    notification_service = get_notification_service()

    # 1. 오늘 쿠폰 스크래핑
    coupons = scraper.scrape_today_coupons()

    if not coupons:
        logger.info("No new coupons found")
        return {
            'status': 'success',
            'coupons_found': 0,
            'notifications_sent': 0
        }

    logger.info(f"Found {len(coupons)} new coupon(s)")

    # 2. 각 쿠폰 처리
    notifications_sent = 0

    for coupon in coupons:
        feed_id = coupon['feed_id']
        coupon_code = coupon['coupon_code']
        title = coupon['title']
        created_date = coupon['created_date']

        # Firestore에서 중복 확인
        if firestore_service.is_feed_processed_today(feed_id):
            logger.info(f"Feed {feed_id} already processed today, skipping")
            continue

        logger.info(f"Processing coupon: {coupon_code} (Feed ID: {feed_id})")

        # 3. FCM 토큰 가져오기
        fcm_tokens = firestore_service.get_all_fcm_tokens()

        if not fcm_tokens:
            logger.warning("No FCM tokens found, skipping notification")
        else:
            # 4. 푸시 알림 전송
            result = notification_service.send_coupon_notification(
                tokens=fcm_tokens,
                coupon_code=coupon_code,
                title=title,
                feed_id=feed_id
            )

            notifications_sent += result['success']
            logger.info(
                f"Notification sent: {result['success']} success, "
                f"{result['failure']} failure"
            )

        # 5. Firestore에 기록
        firestore_service.mark_feed_as_processed(feed_id, coupon_code, title)
        firestore_service.save_coupon_history(feed_id, coupon_code, title, created_date)

    logger.info("Coupon scraping process completed")

    return {
        'status': 'success',
        'coupons_found': len(coupons),
        'notifications_sent': notifications_sent
    }


# Cloud Scheduler로 1분마다 실행되는 함수
if scheduler_fn:
    @scheduler_fn.on_schedule(schedule="every 1 minutes")
    def scheduled_coupon_scraper(event: scheduler_fn.ScheduledEvent) -> None:
        """
        1분마다 실행되는 스케줄 함수

        Args:
            event: 스케줄 이벤트
        """
        try:
            result = process_coupons()
            logger.info(f"Scheduled run completed: {result}")
        except Exception as e:
            logger.error(f"Error in scheduled coupon scraper: {e}", exc_info=True)
            raise

    @scheduler_fn.on_schedule(schedule="every day 03:00")
    def scheduled_cleanup(event: scheduler_fn.ScheduledEvent) -> None:
        """
        매일 새벽 3시에 실행되는 정리 함수
        - 14일 이상 지난 쿠폰 삭제
        - 7일 이상 지난 processed_feeds 삭제

        Args:
            event: 스케줄 이벤트
        """
        try:
            firestore_service = get_firestore_service()

            # 오래된 쿠폰 정리 (14일)
            firestore_service.cleanup_old_coupons(days_to_keep=14)

            # 오래된 처리 완료 기록 정리 (7일)
            firestore_service.cleanup_old_processed_feeds(days_to_keep=7)

            logger.info("Scheduled cleanup completed")
        except Exception as e:
            logger.error(f"Error in scheduled cleanup: {e}", exc_info=True)
            raise


# HTTP 엔드포인트 (수동 테스트용)
if scheduler_fn:
    from firebase_functions import https_fn

    @https_fn.on_request()
    def manual_coupon_scraper(req: https_fn.Request) -> https_fn.Response:
        """
        수동으로 호출할 수 있는 HTTP 엔드포인트

        Query Parameters:
            target_date: 테스트용 날짜 (예: 20251013), 생략 시 오늘 날짜

        Args:
            req: HTTP 요청

        Returns:
            HTTP 응답
        """
        try:
            # 쿼리 파라미터에서 target_date 추출
            target_date = req.args.get('target_date')

            # 서비스 초기화
            scraper = CouponScraper()
            firestore_service = get_firestore_service()
            notification_service = get_notification_service()

            # 1. 쿠폰 스크래핑 (target_date 전달)
            coupons = scraper.scrape_today_coupons(target_date=target_date)

            if not coupons:
                logger.info("No new coupons found")
                return https_fn.Response(
                    response=str({
                        'status': 'success',
                        'coupons_found': 0,
                        'notifications_sent': 0,
                        'target_date': target_date or 'today'
                    }),
                    status=200,
                    headers={"Content-Type": "application/json"}
                )

            logger.info(f"Found {len(coupons)} new coupon(s)")

            # 2. 각 쿠폰 처리
            notifications_sent = 0

            for coupon in coupons:
                feed_id = coupon['feed_id']
                coupon_code = coupon['coupon_code']
                title = coupon['title']
                created_date = coupon['created_date']

                # Firestore에서 중복 확인
                if firestore_service.is_feed_processed_today(feed_id):
                    logger.info(f"Feed {feed_id} already processed today, skipping")
                    continue

                logger.info(f"Processing coupon: {coupon_code} (Feed ID: {feed_id})")

                # 3. FCM 토큰 가져오기
                fcm_tokens = firestore_service.get_all_fcm_tokens()

                if not fcm_tokens:
                    logger.warning("No FCM tokens found, skipping notification")
                else:
                    # 4. 푸시 알림 전송
                    result = notification_service.send_coupon_notification(
                        tokens=fcm_tokens,
                        coupon_code=coupon_code,
                        title=title,
                        feed_id=feed_id
                    )

                    notifications_sent += result['success']
                    logger.info(
                        f"Notification sent: {result['success']} success, "
                        f"{result['failure']} failure"
                    )

                # 5. Firestore에 기록
                firestore_service.mark_feed_as_processed(feed_id, coupon_code, title)
                firestore_service.save_coupon_history(feed_id, coupon_code, title, created_date)

            result = {
                'status': 'success',
                'coupons_found': len(coupons),
                'notifications_sent': notifications_sent,
                'target_date': target_date or 'today'
            }

            return https_fn.Response(
                response=str(result),
                status=200,
                headers={"Content-Type": "application/json"}
            )
        except Exception as e:
            logger.error(f"Error in manual coupon scraper: {e}", exc_info=True)
            return https_fn.Response(
                response=str({'error': str(e)}),
                status=500,
                headers={"Content-Type": "application/json"}
            )


# 로컬 테스트용
if __name__ == "__main__":
    print("Running coupon scraper locally...")
    result = process_coupons()
    print(f"Result: {result}")
