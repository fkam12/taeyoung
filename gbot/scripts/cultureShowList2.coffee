mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 20,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

# 8월 15일 모임
module.exports = (robot) ->
  robot.hear /(\d{1,2})월\s?(\d{1,2})일에?\s?(?=모임)(.?)/i, (msg) ->
   pool.getConnection (err, connection) ->
     mon = decodeURIComponent(unescape(msg.match[1]))
     day = decodeURIComponent(unescape(msg.match[2]))
     if mon > 0 && mon < 13 && day > 0 && day < 32
       if mon > 0 && mon < 10
         mon = "0" + mon
       if day > 0 && day < 10
         day = "0" + day
       queryData = moment().format("YYYY/"+ mon + "/"+ day)
       sql3 = "SELECT * FROM culture_event where cul_startDate = ? order by cul_startDate"
       connection.query sql3, [queryData], (err, results) ->
         if results.length == 0
           msg.send "해당 날짜에는 모임이 없군요 :("
         if err
           console.log err
         else
           list = []
           for row in results
            list.push(row.cul_title + " " + moment(row.cul_startDate).format("MM월 DD일"),)
           lists = list + ""
          # 배열에서 , 생성된 문자 치환
           lists = lists.split(',').join("\n")
          # robot.brain.get ( 'my-list') == [1]
           msg.send "#{lists}"
         connection.release()
     else msg.send "날짜 형식이 정확하지 않네요 :("
