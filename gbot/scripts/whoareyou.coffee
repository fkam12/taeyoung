creater = [
  "전 17년 WDA 7조에서 만든 Gbot\nGO culture! 도우미챗봇이에요! :O :D",
  "저는 Gbot이라고 해요.\nGO culture! 도우미챗봇이에요! :D ^_^ "
]

module.exports = (robot) ->
  robot.hear /넌?\s?(?=누구.*)/i, (msg) ->
    create = msg.random creater
    msg.send "#{create}"
