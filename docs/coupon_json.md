## 변수

json_url = "https://comm-api.game.naver.com/nng_main/v1/community/lounge/Trickcal/feed?boardId=31&buffFilteringYN=N&limit=25&offset=0&order=NEW"

## 설명

- json은 기본적으로 이렇게 구성되어 있다.

```json
{
  "code": 200,
  "message": null,
  "content": {
    "offset": 0,
    "count": 25,
    "totalCount": 68,
    "feeds": [...]
  }
}
```

- 게시물들은 feeds의 각 항목인 feed로 되어 있다.

```json
"feed": {
          "feedId": 6787506,
          "originalLoungeId": "Trickcal",
          "loungeId": "Trickcal",
          "gameId": "GM_NCR_006014",
          "contentId": "nng-Trickcal-6787506",
          "title": "[쿠폰] 세계로 뻗어나가는 볼따구! 글로벌 오픈 기념 쿠폰 지급 안내(~10월 19일)",
          "iconTypes": [
            "PHOTO"
          ],
          "feedType": "FEED",
          "buff": 34,
          "nerf": 0,
          "repImageUrl": "https://nng-phinf.pstatic.net/MjAyNTEwMTNfMzcg/MDAxNzYwMzQ1MDU4Nzg0.BAB7gmIpG-RTVxkajukpXYWXVGRWbyvUeat1d3f5g2wg.ZeRKtPii_VWGFlIiwqpoyQs6gwPQoyVGdUmEMUwdN0Eg.PNG/3_3.png",
          "attachCount": 3,
          "attachIconType": "PHOTO",
          "createdDate": "20251013180002",
          "updatedDate": "20251013180002",
          "contents": "..."
}
```

- 오늘 날짜에 해당하는 것만 찾아내려면 "createdDate"의 값의 앞 문자 8개를 파싱했을 때 오늘 날짜와 맞는지 확인하면 될 것 같다.
- 가장 최상위 feed의 createdDate를 검사해서 파싱했을 때 오늘 날짜보다 과거일 경우 종료(새 게시물 없음). 오늘 날짜일 경우 전체 로직 진행 후 다음 feed의 createdDate도 검사(하루에 2개가 올라왔을 가능성)
- 여기서 "contents"에 해당 게시물의 하위 요소들이 포함되어 있다.
- "contents"의 값 중에서 다음과 같은 형태로 된 것을 찾아야 한다. 예시: `\"nodes\":[{\"id\":\"SE-b00b0891-2dd0-4fb5-b2e2-e4b0f0da2b9d\",\"value\":\"GLOBOLOPEN\",\"style\":{\"fontColor\":\"#000000\",\"fontFamily\":\"system\",\"fontSizeCode\":\"fs15\",\"italic\":false,\"@ctype\":\"nodeStyle\"},\"@ctype\":\"textNode\"}]`
- 아마 \"nodes\"의 \"value\":\"여기 내용이 영어 또는 숫자로만 되어있는 경우\" 를 식별하면 될 것 같다.

## 중요! 생각난 것

- **생각해 보니, 1분에 한 번씩 스크래핑 로직이 작동할 때 이미 스크래핑해서 알림이 완료된 쿠폰 게시물이 있으면 안 되니까, 그날 하루 동안 이미 알림이 완료된 것들을 식별할 로직도 필요할 것 같다! 조건에 부합해서 스크래핑+알림 로직이 완료됐을 경우, 그 feed의 "feedId": 6787506 값을 어떤 자료구조에 담아서 그날 하루 동안만 식별할 수 있도록 만들면 좋지 않을까?**
