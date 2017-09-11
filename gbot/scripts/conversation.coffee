hi = [
  "안녕하세요! Gbot입니다! ^_^ \n 무엇을 도와드릴까요? \n 저는 추천 및 상담을 해주는 챗봇입니다 \n '도움'으로 요청해보세요! :D",
  "GO! culture!입니다. 반갑습니다! :D \n 저는 모임 추천 및 상담을 해주는 챗봇입니다 \n
  '도움'으로 요청해보세요! :D"
]

module.exports = (robot) ->
  robot.hear /(.*)안녕|하이|ㅎㅇ(.*)/i, (msg) ->
    hello = msg.random hi
    msg.send "#{hello}"

  robot.hear /핑/i, (res) ->
    res.send "퐁"
