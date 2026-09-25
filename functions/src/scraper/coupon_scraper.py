"""
네이버 게임 라운지 쿠폰 스크래퍼 (JSON API 기반)
게시물 목록 조회부터 쿠폰 코드 추출까지 통합 처리
"""
import requests
import json
import re
from datetime import datetime
from typing import List, Dict, Optional, Set
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class CouponScraper:
    """JSON API를 사용하여 네이버 게임 라운지에서 쿠폰을 스크래핑하는 클래스"""

    JSON_API_URL = (
        "https://comm-api.game.naver.com/nng_main/v1/community/lounge/Trickcal/feed?boardId=31&buffFilteringYN=N&limit=25&offset=0&order=NEW"
    )

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Referer': 'https://game.naver.com/'
        })
        # 오늘 처리된 feedId 추적 (메모리 기반, 실제 운영에서는 Firestore 사용)
        self.processed_feed_ids: Set[int] = set()

    def get_feeds_json(self) -> Optional[Dict]:
        """JSON API로부터 게시물 목록을 가져옵니다."""
        try:
            response = self.session.get(self.JSON_API_URL, timeout=10)
            response.raise_for_status()
            data = response.json()

            if data.get('code') == 200:
                logger.info("Successfully fetched feeds JSON")
                return data
            else:
                logger.error(f"API returned error code: {data.get('code')}")
                return None

        except requests.RequestException as e:
            logger.error(f"Failed to fetch feeds JSON: {e}")
            return None
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON response: {e}")
            return None

    def get_today_date_string(self) -> str:
        """오늘 날짜를 'YYYYMMDD' 형식으로 반환합니다."""
        return datetime.now().strftime("%Y%m%d")

    def is_today_post(self, created_date: str, target_date: Optional[str] = None) -> bool:
        """
        게시물이 오늘 작성되었는지 확인합니다.

        Args:
            created_date: "20251013180002" 형식의 날짜
            target_date: 테스트용 날짜 (예: "20251013")

        Returns:
            오늘 날짜면 True
        """
        date_string = target_date if target_date else self.get_today_date_string()
        post_date = created_date[:8]  # 앞 8자리만 추출
        return post_date == date_string

    def extract_coupon_code_from_contents(self, contents: str) -> Optional[str]:
        """
        contents 필드에서 쿠폰 코드를 추출합니다.

        nodes 배열의 value 중 영문+숫자로만 구성된 문자열을 찾습니다.
        예시 패턴: "nodes":[{"value":"GLOBOLOPEN"}]
        """
        try:
            # contents를 문자열로 변환
            contents_str = contents if isinstance(contents, str) else json.dumps(contents)

            # "value":"XXX" 패턴 추출
            value_pattern = r'"value"\s*:\s*"([^"]+)"'
            values = re.findall(value_pattern, contents_str)

            for value in values:
                # 영문과 숫자로만 구성되었는지 확인
                if self.is_valid_coupon_code(value):
                    logger.info(f"Found coupon code in contents: {value}")
                    return value

            logger.debug("No valid coupon code found in contents")
            return None

        except Exception as e:
            logger.error(f"Error extracting coupon code from contents: {e}")
            return None

    def is_valid_coupon_code(self, text: str) -> bool:
        """
        텍스트가 유효한 쿠폰 코드인지 확인합니다.
        조건: 영문 알파벳과 숫자로만 구성, 4-20자
        """
        text = text.strip()
        if not text or len(text) < 4 or len(text) > 20:
            return False

        pattern = r'^[a-zA-Z0-9]+$'
        return bool(re.match(pattern, text))

    def filter_today_feeds(
        self,
        feeds: List[Dict],
        target_date: Optional[str] = None
    ) -> List[Dict]:
        """
        오늘 날짜의 피드만 필터링하고 쿠폰 코드를 추출합니다.

        Args:
            feeds: feed 객체 리스트
            target_date: 테스트용 날짜 (예: "20251013")

        Returns:
            처리된 쿠폰 정보 리스트
        """
        date_string = target_date if target_date else self.get_today_date_string()
        logger.info(f"Filtering feeds for date: {date_string}")

        today_coupons = []

        for item in feeds:
            # feeds 배열의 각 항목은 {"feed": {...}} 형태로 감싸져 있음
            feed = item.get('feed', {})

            feed_id = feed.get('feedId')
            created_date = feed.get('createdDate', '')
            title = feed.get('title', '')

            # 날짜 확인
            if not self.is_today_post(created_date, target_date):
                # 첫 번째 게시물이 오늘 날짜가 아니면 더 이상 확인 불필요
                logger.info(f"Feed {feed_id} is not from today, stopping search")
                break

            # 이미 처리된 feedId인지 확인
            if feed_id in self.processed_feed_ids:
                logger.info(f"Feed {feed_id} already processed, skipping")
                continue

            logger.info(f"Processing feed {feed_id}: {title}")

            # contents에서 쿠폰 코드 추출
            contents = feed.get('contents', '')
            coupon_code = self.extract_coupon_code_from_contents(contents)

            if coupon_code:
                today_coupons.append({
                    'feed_id': feed_id,
                    'title': title,
                    'coupon_code': coupon_code,
                    'created_date': created_date
                })

                # 처리된 feedId 추가
                self.processed_feed_ids.add(feed_id)
                logger.info(f"✓ Coupon found: {coupon_code} in feed {feed_id}")
            else:
                logger.warning(f"No coupon code found in feed {feed_id}: {title}")

        logger.info(f"Total coupons found for {date_string}: {len(today_coupons)}")
        return today_coupons

    def scrape_today_coupons(self, target_date: Optional[str] = None) -> List[Dict]:
        """
        오늘 올라온 쿠폰을 스크래핑합니다.

        Args:
            target_date: 테스트용 날짜 (예: "20251013")

        Returns:
            쿠폰 정보 리스트 [{'feed_id': int, 'title': str, 'coupon_code': str, 'created_date': str}]
        """
        data = self.get_feeds_json()

        if not data:
            logger.error("Failed to get feeds data")
            return []

        feeds = data.get('content', {}).get('feeds', [])

        if not feeds:
            logger.warning("No feeds found in response")
            return []

        return self.filter_today_feeds(feeds, target_date)

    def mark_as_processed(self, feed_id: int):
        """feedId를 처리 완료로 표시합니다."""
        self.processed_feed_ids.add(feed_id)
        logger.debug(f"Marked feed {feed_id} as processed")

    def is_processed(self, feed_id: int) -> bool:
        """feedId가 이미 처리되었는지 확인합니다."""
        return feed_id in self.processed_feed_ids

    def clear_processed_ids(self):
        """처리된 feedId 목록을 초기화합니다. (자정에 호출)"""
        self.processed_feed_ids.clear()
        logger.info("Cleared processed feed IDs")

    def get_processed_count(self) -> int:
        """처리된 feedId 개수를 반환합니다."""
        return len(self.processed_feed_ids)


if __name__ == "__main__":
    # 간단한 테스트
    scraper = CouponScraper()
    coupons = scraper.scrape_today_coupons()

    if coupons:
        print(f"\n발견된 쿠폰: {len(coupons)}개")
        for coupon in coupons:
            print(f"\n- 쿠폰 코드: {coupon['coupon_code']}")
            print(f"  제목: {coupon['title']}")
            print(f"  Feed ID: {coupon['feed_id']}")
            print(f"  작성일시: {coupon['created_date']}")
    else:
        print("\n오늘 올라온 쿠폰이 없습니다.")
