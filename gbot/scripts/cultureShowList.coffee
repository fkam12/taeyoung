mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 20,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

module.exports = (robot) ->
  # 15일에 모임 있니?
  robot.hear /(.*)에\s?(?=모임)(.?)/i, (msg) ->
    pool.getConnection (err, connection) ->
     day = decodeURIComponent(unescape(msg.match[1]))
     day = day.substring(1,day.indexOf("일"), -1)
     if day > 0 && day < 32
       if day > 0 && day < 10
          day = "0" + day
        startDay = moment().format("YYYY/MM/"+day)
        sql = "SELECT * FROM culture_event where cul_startDate= ? order by cul_startDate"
        connection.query sql, [startDay], (err, results) ->
          if results.length == 0
            msg.send "해당 날짜에 모임이 없습니다.. :("
          if err
            console.log err
          else
            list = []
            for row in results
             robot.brain.set 'cultureList', list
             list.push(row.cul_title + " " + moment(row.cul_startDate).format("MM월 DD일"),)
            lists = list + ""
           # 배열에서 , 생성된 문자 치환
            lists = lists.split(',').join("\n")
            msg.send "#{lists}"
          connection.release()


  # 15일부터 20일까지 모임 있어?
  robot.hear /(.*)부터\s?(.*)까지\s?(?=모임)(.?)/i, (msg) ->
   pool.getConnection (err, connection) ->
    stDay = decodeURIComponent(unescape(msg.match[1]))
    enDay = decodeURIComponent(unescape(msg.match[2]))
    stDay = stDay.substring(1,stDay.indexOf("일"),-1)
    enDay = enDay.substring(enDay.indexOf("일"),-1)
    if stDay > 0 && stDay < 32 || enDay > 0 && enDay < 32
      if stDay > 0 && stDay < 10 || enDay > 0 && enDay < 10
        stDay = "0" + stDay
        enDay = "0" + enDay
       startDay = moment().format("YYYY/MM/"+stDay)
       endDay = moment().format("YYYY/MM/"+enDay)
       console.log startDay + '첫'
       console.log endDay + '끝'
       sql2 = "SELECT * FROM culture_event where cul_startDate >= ? and cul_startDate <= ? order by cul_startDate"
       connection.query sql2, [startDay, endDay], (err, results) ->
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
     else
      msg.send "날짜를 정확하게 입력해주세요! :)"
