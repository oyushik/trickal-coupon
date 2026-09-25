# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Trickcal Coupon Notifier - A mobile app that monitors Naver Game Lounge for new coupons for the game "Trickcal Revive" and sends real-time push notifications to users. The app automatically fills in the user's UID and coupon code in a webview for one-click coupon redemption.

**Mission**: "Solve gamers' inconveniences through technology to provide the best gaming experience."

## Architecture

This is a **hybrid Firebase + Flutter project** with three main components:

### 1. Backend (Firebase Cloud Functions - Python)

- **Location**: `functions/`
- **Runtime**: Python 3.11+
- **Entry Point**: `functions/src/main.py`
- **Execution**: Scheduled every 1 minute via Cloud Scheduler

**Key Modules**:

- `src/scraper/coupon_scraper.py`: Scrapes Naver Game Lounge JSON API for new coupon posts
- `src/services/firestore_service.py`: Manages processed feed IDs, FCM tokens, and coupon history in Firestore
- `src/services/notification_service.py`: Sends FCM push notifications to all registered users

**Cloud Functions**:

- `scheduled_coupon_scraper`: Executes every 1 minute via Cloud Scheduler
- `scheduled_cleanup`: Executes daily at 3:00 AM to remove old records
- `manual_coupon_scraper`: HTTP endpoint for manual testing (supports `target_date` query parameter)

**Processing Flow**:

1. `CouponScraper` fetches today's posts from JSON API
2. Extracts coupon codes from post contents (pattern: `"nodes":[{"value":"COUPONCODE"}]`)
3. Checks Firestore to avoid duplicate notifications (using `processed_feeds` collection with `{date}_{feedId}` document IDs)
4. Retrieves all FCM tokens from `users` collection
5. Sends multicast push notification with coupon code in data payload
6. Saves to `coupons` collection for history tracking

### 2. Mobile App (Flutter - Dart)

- **Location**: `mobile/`
- **Architecture**: Clean Architecture (Data, Domain, Presentation layers)
- **State Management**: Riverpod 2.6+
- **Navigation**: GoRouter 14.6+
- **Secure Storage**: flutter_secure_storage 9.2+ (for UID)
- **Local Storage**: shared_preferences 2.3+ (for settings)

**Directory Structure**:

- `lib/core/`: Config (router, FCM, notification handler), constants, theme, utils
- `lib/data/`: Data sources, models, repository implementations
- `lib/domain/`: Entities, repository interfaces, use cases
- `lib/presentation/`: Pages, providers (Riverpod), widgets
- `lib/firebase_options.dart`: Generated Firebase configuration (via flutterfire configure)
- `lib/main.dart`: App entry point with Firebase & FCM initialization

**Key Features Implemented**:

- Firebase initialization on app startup
- FCM integration with notification handling
- UID management with secure storage
- Theme provider (light/dark mode support)
- Router configuration with conditional initial routes based on UID existence
- Notification click handling for webview navigation

### 3. Firebase Services

- **Firestore**: NoSQL database storing user data, FCM tokens, processed feeds, coupon history
- **FCM**: Push notification delivery
- **Cloud Scheduler**: Triggers scraper function every minute

## Development Commands

### Python Backend (Cloud Functions)

**Local Environment Setup**:

```bash
cd functions
python -m venv venv
# On Windows:
venv\Scripts\activate
# On Mac/Linux:
source venv/bin/activate

pip install -r requirements.txt
```

**Local Testing**:

```bash
cd functions
python src/main.py
# Or test specific scraper:
python src/scraper/coupon_scraper.py
# Test with specific date (for historical data testing):
python -c "from src.scraper.coupon_scraper import CouponScraper; s = CouponScraper(); print(s.scrape_today_coupons(target_date='20251016'))"
```

**Run Tests**:

```bash
cd functions
# Ensure you're in virtual environment first
pytest tests/
# Or specific test:
pytest tests/test_coupon_scraper.py
# Run tests with verbose output:
pytest tests/ -v
# Run tests with coverage:
pytest tests/ --cov=src
```

**Deploy to Firebase**:

```bash
# From project root
firebase deploy --only functions
# Or deploy everything:
firebase deploy
```

**View Logs**:

```bash
firebase functions:log
# Or real-time streaming:
firebase functions:log --only scheduled_coupon_scraper
```

### Flutter Mobile App

**Install Dependencies**:

```bash
cd mobile
flutter pub get
```

**Run App**:

```bash
cd mobile
flutter run
# Or on specific device:
flutter run -d chrome
flutter run -d android
```

**Build App**:

```bash
cd mobile
# Android APK:
flutter build apk
# Android App Bundle:
flutter build appbundle
# iOS:
flutter build ios
```

**Run Tests**:

```bash
cd mobile
flutter test
# Or specific test:
flutter test test/widget_test.dart
# Run tests with coverage:
flutter test --coverage
# View coverage report:
genhtml coverage/lcov.info -o coverage/html
```

**Code Analysis**:

```bash
cd mobile
# Run static analysis:
flutter analyze
# Auto-fix lint issues:
dart fix --apply
# Format code:
dart format lib/
```

### Firebase Management

**Firestore Rules & Indexes**:

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

**Test HTTP Endpoint Manually**:

```bash
# After deployment, use the URL from deployment output:
curl https://REGION-PROJECT_ID.cloudfunctions.net/manual_coupon_scraper
# Test with specific date:
curl "https://REGION-PROJECT_ID.cloudfunctions.net/manual_coupon_scraper?target_date=20251016"
# Send test notification without scraping:
curl "https://REGION-PROJECT_ID.cloudfunctions.net/manual_coupon_scraper?test=true"
```

**View Function Logs**:

```bash
# Stream logs for scheduled function:
firebase functions:log --only scheduled_coupon_scraper
# Stream logs for cleanup function:
firebase functions:log --only scheduled_cleanup
# View all function logs:
firebase functions:log
```

## Critical Implementation Details

### Scraping Strategy

- **Data Source**: Naver Game Lounge JSON API (not HTML scraping)
- **API URL**: `https://comm-api.game.naver.com/nng_main/v1/community/lounge/Trickcal/feed?boardId=31&buffFilteringYN=N&limit=25&offset=0&order=NEW`
- **Coupon Extraction**: Regex pattern `"value"\s*:\s*"([^"]+)"` to find values in JSON `contents` field
- **Validation**: Coupon codes must be 4-20 alphanumeric characters only
- **Target Site for Redemption**: `https://coupon.a.prod.service.trickcal.io/`

### Duplicate Prevention

- Uses Firestore document IDs in format `{YYYYMMDD}_{feedId}` in `processed_feeds` collection
- Checks existence before sending notification using `is_feed_processed_today()` in `firestore_service.py`
- Automatic cleanup via `scheduled_cleanup` function:
  - Runs daily at 3:00 AM (scheduled in `main.py`)
  - Removes `processed_feeds` older than 7 days
  - Removes `coupons` history older than 14 days
  - Configurable retention periods via function parameters

### Push Notification Structure

```python
notification={
    title: '🎁 새로운 쿠폰이 등록되었습니다!',
    body: f'쿠폰 코드: {coupon_code}'
},
data={
    'coupon_code': coupon_code,
    'title': title,
    'feed_id': str(feed_id),
    'type': 'coupon_notification'
}
```

### Webview Auto-fill (Planned)

When user taps notification, Flutter app should:

1. Open in-app webview to coupon redemption site
2. Use JavaScript injection to auto-fill UID (from `flutter_secure_storage`) and coupon code (from notification data)
3. User only needs to complete reCAPTCHA and tap submit button

## Firestore Collections Schema

**users**:

- `fcm_token`: String (device FCM registration token)
- `uid`: String (user's in-game UID)
- `created_at`: Timestamp

**processed_feeds**:

- Document ID: `{YYYYMMDD}_{feedId}`
- `feed_id`: Number
- `coupon_code`: String
- `title`: String
- `processed_at`: Timestamp
- `date`: String (YYYYMMDD)

**coupons** (history):

- Document ID: `{feedId}`
- `feed_id`: Number
- `coupon_code`: String
- `title`: String
- `created_date`: String (timestamp from API)
- `discovered_at`: Timestamp

## Known Risks & Mitigation

1. **HTML/API Structure Changes**: Naver may change their JSON API structure. Monitor scraper logs regularly and update parsing logic in `coupon_scraper.py` if needed.

2. **IP Blocking**: Current scraping interval is 1 minute. If blocked, increase interval or rotate User-Agent headers.

3. **reCAPTCHA Hardening**: If webview auto-fill fails due to stricter reCAPTCHA policies, fallback to copying coupon code to clipboard and opening external browser.

## Development Phase Status

- [x] Phase 1: Project structure and local scraper
- [x] Phase 2: Firebase backend setup (scraping works, notification service ready)
- [x] Phase 3: Flutter basic architecture (Clean Architecture, Riverpod setup)
- [x] Phase 4: FCM integration in Flutter app (initialization, notification handling)
- [x] Phase 5: UID management (secure storage integration)
- [x] Phase 6: Theme system (light/dark mode)
- [ ] Phase 7: Flutter UI implementation (webview with auto-fill, coupon history)
- [ ] Phase 8: Beta testing and bug fixes
- [ ] Phase 9: Play Store deployment
- [ ] Phase 10: iOS support

## Environment Configuration

**Python Functions**:

- `functions/.env.example` shows required environment variables (currently minimal)
- Firebase Admin SDK credentials are auto-managed when deployed

**Flutter**:

- Firebase configuration files are generated via `flutterfire configure` (not yet run)
- UID stored locally using `flutter_secure_storage`
- FCM token registration happens on app startup

## Testing Approach

**Backend Testing**:

- **Unit Tests**: `functions/tests/test_coupon_scraper.py` - Tests coupon extraction and validation logic
- **Debug Tool**: `functions/tests/debug_html.py` - Helper for debugging HTML/JSON parsing
- **Date-Specific Testing**: Use `target_date` parameter to test historical data:
  ```python
  scraper = CouponScraper()
  coupons = scraper.scrape_today_coupons(target_date="20251016")
  ```
- **Mock Services**: Mock Firestore and FCM services for isolated testing (services check for availability)
- **Manual HTTP Testing**: Use `manual_coupon_scraper` endpoint with query parameters for end-to-end testing

**Mobile Testing**:

- **Widget Tests**: Located in `mobile/test/` directory
- **Integration Testing**:
  1. Deploy backend to Firebase
  2. Use `manual_coupon_scraper` HTTP endpoint to trigger test notifications
  3. Verify notification receipt and handling in Flutter app
- **Local Testing**: Firebase emulators can be used for local development (requires `firebase emulators:start`)
