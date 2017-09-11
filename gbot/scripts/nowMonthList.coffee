mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 20,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

module.exports = (robot) ->
  robot.hear /이번\s?달\s?모임.*/i, (msg) ->
   m = moment()
   NowDay = m.format("YYYY-MM-DD")
   # 현재 달의 마지막 날
   Month_LastDay = m.format("YYYY-MM-") + moment().daysInMonth()
   pool.getConnection (err, connection) ->
     sql5 = "SELECT * FROM culture_event where cul_startDate >= ? and cul_startDate <= ? order by cul_startDate"
     connection.query sql5, [NowDay, Month_LastDay], (err, results) ->
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
