# gbot (GO culture 프로젝트의 챗봇)
### 제작기간 2017.07.01 ~ 2017.09.20

gbot은 규칙 기반의 챗봇입니다. [facebook][facebook]에서 만나 보실 수 있습니다.

[Hubot][hubot] 봇 프레임워크로 [coffeescript][coffee]를 바탕으로 제작하였습니다.

서버는 [node.js][node.js]로 [Heroku][heroku] (해외 무료 호스팅 서버)를 사용하였습니다.


[heroku]: http://www.heroku.com
[hubot]: http://hubot.github.com
[node.js]: https://nodejs.org/ko/
[facebook]: https://www.facebook.com/messages/t/1504573752914456
[coffee]: http://coffeescript.org/

gbot 사용 설명서 `도움`.

    나 : 안녕 처음 왔어
    나 : 내가 15일부터 시간이 있어
    나 : 오후쯤 갈꺼야
    나 : '카테고리'에 관심있어
    나 : 가까운데 보여줘
    나 : 내 위치
    나 : 내 주변 모임 보여줘
    나 : ‘모임’ 지도
    나 : 길 찾아 줘
    나 : ‘모임’ 예매 할래

    외

    나 : 오늘|내일|모레|다음주 '지역'날씨는 어때?
    나 : 이번주 '지역'날씨는 어떠니?

### 어댑터

어댑터는 gbot의 서비스를 제공할 인터페이스 입니다.
저는 이것을 페이스북에 연동하였습니다.

### 참고자료

[9XD봇][9XD] 많은 도움이 되었습니다. 감사드립니다.
