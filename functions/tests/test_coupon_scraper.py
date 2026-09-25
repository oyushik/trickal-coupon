"""
쿠폰 스크래퍼 통합 테스트
10/13 날짜의 게시물을 기준으로 테스트합니다.
"""
import sys
import os
import io

# Windows 환경에서 UTF-8 출력 설정
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# 상위 디렉토리를 Python path에 추가
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from src.scraper.coupon_scraper import CouponScraper


def test_coupon_code_validation():
    """쿠폰 코드 검증 로직 테스트"""
    print("=" * 60)
    print("쿠폰 코드 검증 로직 테스트")
    print("=" * 60)

    scraper = CouponScraper()

    test_cases = [
        ("TRICKCAL2024", True, "영문+숫자 조합"),
        ("ABC123XYZ", True, "영문+숫자 조합"),
        ("GLOBOLOPEN", True, "영문만"),
        ("ABCDEFGH", True, "영문만"),
        ("12345678", True, "숫자만"),
        ("쿠폰코드", False, "한글 포함"),
        ("COUPON-CODE", False, "특수문자(-) 포함"),
        ("COUPON CODE", False, "공백 포함"),
        ("CODE!123", False, "특수문자(!) 포함"),
        ("", False, "빈 문자열"),
        ("   ", False, "공백만"),
        ("ABC", False, "너무 짧음 (6자 미만)"),
        ("A" * 21, False, "너무 김 (20자 초과)"),
    ]

    all_passed = True

    for code, expected, description in test_cases:
        result = scraper.is_valid_coupon_code(code)
        status = "✓" if result == expected else "❌"

        if result != expected:
            all_passed = False

        display_code = code if len(code) < 30 else f"{code[:27]}..."
        print(f"{status} '{display_code}' -> {result} (예상: {expected}) - {description}")

    return all_passed


def test_scrape_coupons():
    """쿠폰 스크래핑 테스트 (10/13 날짜 기준)"""
    print("\n" + "=" * 60)
    print("쿠폰 스크래핑 테스트 (10/13 날짜 기준)")
    print("=" * 60)

    scraper = CouponScraper()

    # 10/13 날짜로 테스트
    coupons = scraper.scrape_today_coupons(target_date="20251013")

    if not coupons:
        print("❌ 10/13에 쿠폰을 찾지 못했습니다.")
        print("   해당 날짜에 쿠폰 게시물이 없거나 API 응답이 변경되었을 수 있습니다.")
        return False

    print(f"✓ {len(coupons)}개의 쿠폰을 찾았습니다.\n")

    for i, coupon in enumerate(coupons, 1):
        print(f"쿠폰 {i}:")
        print(f"  코드: {coupon['coupon_code']}")
        print(f"  제목: {coupon['title']}")
        print(f"  Feed ID: {coupon['feed_id']}")
        print(f"  작성일시: {coupon['created_date']}\n")

    return True


def test_duplicate_prevention():
    """중복 알림 방지 테스트"""
    print("=" * 60)
    print("중복 알림 방지 테스트")
    print("=" * 60)

    scraper = CouponScraper()

    # 첫 번째 스크래핑
    print("첫 번째 스크래핑 실행...")
    coupons_first = scraper.scrape_today_coupons(target_date="20251013")
    first_count = len(coupons_first)
    print(f"✓ 첫 번째 스크래핑: {first_count}개 발견\n")

    if first_count == 0:
        print("⚠️  테스트할 쿠폰이 없어 중복 방지 테스트를 건너뜁니다.")
        return True

    # 두 번째 스크래핑 (같은 scraper 인스턴스)
    print("두 번째 스크래핑 실행 (같은 인스턴스)...")
    coupons_second = scraper.scrape_today_coupons(target_date="20251013")
    second_count = len(coupons_second)
    print(f"두 번째 스크래핑: {second_count}개 발견")

    if second_count == 0:
        print("✓ 중복 방지 성공! 이미 처리된 쿠폰은 다시 반환되지 않습니다.")
        return True
    else:
        print(f"❌ 중복 방지 실패! {second_count}개가 다시 반환되었습니다.")
        return False


def test_api_response():
    """API 응답 구조 테스트"""
    print("\n" + "=" * 60)
    print("API 응답 구조 테스트")
    print("=" * 60)

    scraper = CouponScraper()
    data = scraper.get_feeds_json()

    if not data:
        print("❌ API 응답을 받지 못했습니다.")
        return False

    print(f"✓ API 응답 성공 (code: {data.get('code')})")

    content = data.get('content', {})
    feeds = content.get('feeds', [])
    total_count = content.get('totalCount', 0)

    print(f"  전체 게시물 수: {total_count}")
    print(f"  받아온 게시물 수: {len(feeds)}")

    if feeds:
        first_feed = feeds[0]
        print(f"\n  최신 게시물:")
        print(f"    Feed ID: {first_feed.get('feedId')}")
        print(f"    제목: {first_feed.get('title')}")
        print(f"    작성일시: {first_feed.get('createdDate')}")

    return True


def main():
    """메인 테스트 실행"""
    print("\n")
    print("*" * 60)
    print("트릭컬 쿠폰 스크래퍼 통합 테스트")
    print("*" * 60)
    print()

    # 1. API 응답 구조 테스트
    api_result = test_api_response()

    # 2. 쿠폰 코드 검증 로직 테스트
    validation_result = test_coupon_code_validation()

    # 3. 쿠폰 스크래핑 테스트
    scraping_result = test_scrape_coupons()

    # 4. 중복 방지 테스트
    duplicate_result = test_duplicate_prevention()

    # 최종 결과
    print("\n" + "=" * 60)
    print("테스트 결과 요약")
    print("=" * 60)
    print(f"API 응답: {'✓ 통과' if api_result else '❌ 실패'}")
    print(f"쿠폰 코드 검증: {'✓ 통과' if validation_result else '❌ 실패'}")
    print(f"쿠폰 스크래핑: {'✓ 통과' if scraping_result else '❌ 실패'}")
    print(f"중복 방지: {'✓ 통과' if duplicate_result else '❌ 실패'}")

    if api_result and validation_result and scraping_result and duplicate_result:
        print("\n🎉 모든 테스트를 통과했습니다!")
        return 0
    else:
        print("\n⚠️  일부 테스트가 실패했습니다.")
        return 1


if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)
