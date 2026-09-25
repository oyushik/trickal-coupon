"""
HTML 구조 디버깅 스크립트
실제 페이지의 HTML 구조를 확인합니다.
"""
import sys
import os
import io

# Windows 환경에서 UTF-8 출력 설정
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import requests
from bs4 import BeautifulSoup


def debug_board_structure():
    """게시판 HTML 구조 디버깅"""
    url = "https://game.naver.com/lounge/Trickcal/board/31"

    print("=" * 60)
    print(f"페이지 가져오는 중: {url}")
    print("=" * 60)

    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }

    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        print(f"✓ 페이지를 성공적으로 가져왔습니다. (상태 코드: {response.status_code})\n")
    except requests.RequestException as e:
        print(f"❌ 페이지 가져오기 실패: {e}")
        return

    soup = BeautifulSoup(response.content, 'html.parser')

    # 1. 게시물 row 찾기
    print("=" * 60)
    print("1. <tr class='post_board_detail__1JkwM'> 찾기")
    print("=" * 60)

    post_rows = soup.find_all('tr', class_='post_board_detail__1JkwM')
    print(f"발견된 게시물 row: {len(post_rows)}개\n")

    if not post_rows:
        print("❌ 게시물 row를 찾지 못했습니다.")
        print("\n다른 가능한 class 이름들:")
        all_trs = soup.find_all('tr', class_=True)
        unique_classes = set()
        for tr in all_trs[:10]:  # 처음 10개만
            classes = tr.get('class', [])
            for cls in classes:
                unique_classes.add(cls)
        for cls in sorted(unique_classes):
            print(f"  - {cls}")
        return

    # 2. 각 게시물의 구조 분석
    print("=" * 60)
    print("2. 게시물 구조 분석 (처음 5개)")
    print("=" * 60)

    for i, row in enumerate(post_rows[:5], 1):
        print(f"\n게시물 {i}:")
        print("-" * 40)

        # 날짜 찾기
        date_spans = row.find_all('span', class_='post_board_information__28nF0')
        if date_spans:
            for span in date_spans:
                print(f"  날짜: {span.text.strip()}")
        else:
            print("  날짜: (없음)")
            # 대안 찾기
            all_spans = row.find_all('span', class_=True)
            print("  가능한 span 클래스들:")
            for span in all_spans[:3]:
                classes = span.get('class', [])
                text = span.text.strip()[:30]
                print(f"    - {classes}: {text}")

        # 링크 찾기
        link = row.find('a', href=True)
        if link:
            print(f"  제목: {link.text.strip()}")
            print(f"  링크: {link['href']}")
        else:
            print("  링크: (없음)")

    # 3. 10.13 날짜 게시물 찾기
    print("\n" + "=" * 60)
    print("3. 10.13 날짜 게시물 찾기")
    print("=" * 60)

    for row in post_rows:
        date_span = row.find('span', class_='post_board_information__28nF0')
        if date_span:
            date_text = date_span.text.strip()
            if "10.13" in date_text:
                link = row.find('a', href=True)
                title = link.text.strip() if link else "(제목 없음)"
                print(f"✓ 발견: {title} - {date_text}")

    print("\n완료!")


if __name__ == "__main__":
    debug_board_structure()
