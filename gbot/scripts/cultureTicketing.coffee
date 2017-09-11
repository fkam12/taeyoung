mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 20,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

ticketAnswer = [
  "찾아주셔서 감사합니다! 링크로 안내해드리겠습니다.",
  "아래의 버튼을 누르시면 자세한 정보가 있습니다."
]

module.exports = (robot) ->
  robot.hear /(.*)\s*예매(.*)?/i, (res) ->
    selected = decodeURIComponent(unescape(res.match[1]))
    console.log selected
    ans = res.random ticketAnswer
    pool.getConnection (err, connection) ->
      sql1 = "SELECT * FROM culture_event WHERE cul_title = substr(?, 2)"
      connection.query sql1, [selected], (err, data) ->
       if err
        res.send "고장났습니다."
       else if data.length == 0
        res.send "해당 모임은 없습니다. :'("
       else
        console.log data
        meetingDay = moment(data[0].cul_startDate).format('YY/MM/DD')
        endTime = moment(data[0].endDay).format('YY/MM/DD')
        # res.send("#{data[0].cul_name}\n#{ans} \n#{data[0].link} \n행사날짜 #{startTime} \n마감날짜 #{endTime}" )
        res.envelope.fb = {
          richMsg: {
            attachment: {
              type: "template",
              payload: {
                template_type: "generic",
                elements : [
                  {
                    title : "#{data[0].cul_title}\n#{ans} \n모임날짜 #{meetingDay}",
                    image_url : "https://cdn.pixabay.com/photo/2017/07/10/16/07/thank-you-2490552_1280.png",
                    buttons: [
                      {
                        type: "web_url",
                        url: "http://localhost:8080/yg/eventDetail?cul_no=" + "#{data[0].cul_no}",
                        title: "예매하러 가기"
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
        res.send()
       connection.release()
