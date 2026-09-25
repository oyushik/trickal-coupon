"""
Firestore 테스트 데이터 정리 스크립트
"""
import sys
import os

# UTF-8 인코딩 설정
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# functions 디렉토리를 Python 경로에 추가
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'functions'))

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
    from datetime import datetime
except ImportError:
    print("❌ Firebase Admin SDK가 설치되지 않았습니다.")
    print("실행: pip install firebase-admin")
    sys.exit(1)


def delete_collection(db, collection_name, batch_size=100):
    """
    컬렉션의 모든 문서를 삭제합니다.

    Args:
        db: Firestore 클라이언트
        collection_name: 삭제할 컬렉션 이름
        batch_size: 배치 크기
    """
    collection_ref = db.collection(collection_name)
    docs = collection_ref.limit(batch_size).stream()

    deleted = 0
    for doc in docs:
        print(f'  삭제 중: {doc.id}')
        doc.reference.delete()
        deleted += 1

    if deleted >= batch_size:
        return delete_collection(db, collection_name, batch_size)

    return deleted


def delete_by_date_prefix(db, collection_name, date_prefix):
    """
    특정 날짜 접두사로 시작하는 문서만 삭제합니다.

    Args:
        db: Firestore 클라이언트
        collection_name: 컬렉션 이름
        date_prefix: 날짜 접두사 (예: "20251013")
    """
    collection_ref = db.collection(collection_name)

    # 날짜로 시작하는 문서 찾기
    docs = collection_ref.where('date', '==', date_prefix).stream()

    deleted = 0
    for doc in docs:
        print(f'  삭제 중: {doc.id}')
        doc.reference.delete()
        deleted += 1

    return deleted


def main():
    """메인 함수"""
    print("=" * 50)
    print("🧹 Firestore 테스트 데이터 정리")
    print("=" * 50)
    print()

    # Firebase Admin SDK 초기화
    if not firebase_admin._apps:
        try:
            firebase_admin.initialize_app()
            print("✅ Firebase Admin SDK 초기화 완료")
        except Exception as e:
            print(f"❌ Firebase 초기화 실패: {e}")
            print("\n💡 해결 방법:")
            print("1. 프로젝트 루트에서 실행하세요")
            print("2. GOOGLE_APPLICATION_CREDENTIALS 환경 변수가 설정되어 있는지 확인하세요")
            print("3. 또는 Firebase 프로젝트에 배포된 상태에서 실행하세요")
            sys.exit(1)

    db = firestore.client()
    print()

    # 1. users 컬렉션 삭제
    print("[1/3] 👥 users 컬렉션 정리...")
    try:
        deleted = delete_collection(db, 'users')
        print(f"✅ {deleted}개의 사용자 문서 삭제 완료\n")
    except Exception as e:
        print(f"❌ 삭제 실패: {e}\n")

    # 2. processed_feeds 컬렉션에서 20251013 관련 문서 삭제
    print("[2/3] 📋 processed_feeds 컬렉션 정리 (20251013)...")
    try:
        deleted = delete_by_date_prefix(db, 'processed_feeds', '20251013')
        print(f"✅ {deleted}개의 processed_feeds 문서 삭제 완료\n")
    except Exception as e:
        print(f"❌ 삭제 실패: {e}\n")

    # 3. coupons 컬렉션 (선택사항 - 전체 삭제하지 않고 확인만)
    print("[3/3] 🎁 coupons 컬렉션 확인...")
    try:
        coupons_ref = db.collection('coupons')
        docs = list(coupons_ref.limit(5).stream())
        print(f"ℹ️  현재 {len(docs)}개의 쿠폰 문서가 있습니다")
        print("   (쿠폰 히스토리는 보존됩니다)\n")
    except Exception as e:
        print(f"❌ 확인 실패: {e}\n")

    print("=" * 50)
    print("✅ Firestore 정리 완료!")
    print("=" * 50)
    print()
    print("💡 다음 단계:")
    print("1. Flutter 앱을 다시 설치하세요: flutter install")
    print("2. 앱을 실행하고 UID를 등록하세요")
    print("3. 테스트를 진행하세요")
    print()


if __name__ == "__main__":
    main()
