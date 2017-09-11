mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 20,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

module.exports = (robot) ->
  # 카테고리 선택
  robot.hear /(.*)\s?모임만(.*)/i, (msg) ->
    category = decodeURIComponent(unescape(msg.match[1]))
    culture_categoryCheck = /문화\s?|예술/i
    style_categoryCheck = /패션\s?|뷰티/i
    edu_categoryCheck = /교\s?육/i
    contest_categoryCheck = /공\s?모\s?전/i
    hobby_categoryCheck = /취미\s?|활동/i
    book_categoryCheck = /북\s?|도서|에세이/i
    travel_categoryCheck = /여\s?행\s?/i
    etc_categoryCheck = /기\s?타|나머지/i
    if culture_categoryCheck.test(category)
      category = "문화/예술"
    if style_categoryCheck.test(category)
      category = "패션/뷰티"
    if edu_categoryCheck.test(category)
      category = "교육"
    if contest_categoryCheck.test(category)
      category = "공모전"
    if hobby_categoryCheck.test(category)
      category = "취미활동"
    if book_categoryCheck.test(category)
      category = "북에세이"
    if travel_categoryCheck.test(category)
      category = "여행"
    if etc_categoryCheck.test(category)
      category = "기타"

    goodWeatherList = robot.brain.get('goodWeather')
    if goodWeatherList
      pool.getConnection (err, connection) ->
          sql = "SELECT * FROM culture_event where cul_startDate in(?) and cate_no = (select cate_no from category where cate_name = ?) order by cul_startDate"
          connection.query sql, [goodWeatherList, category], (err, results) ->
           if err
            console.log err
           else
            if results.length == 0
              msg.send "해당 날짜에 모임이 없습니다.. :("
            else
              list = []
              for row in results
               list.push(row.cul_title + " " + moment(row.cul_startDate).format("MM월 DD일"),)
              lists = list + ""
             # 배열에서 , 생성된 문자 치환
              lists = lists.split(',').join("\n")
              weatherString = goodWeatherList + ""
              weatherGoodDay = weatherString.split(',').join("\n")
              msg.send "#{weatherGoodDay}\n"+ "맑은 날에 #{category} 모임이 있습니다\n"+"#{lists}"
            connection.release()
    else
      pool.getConnection (err, connection) ->
          sql = "SELECT * FROM culture_event where cate_no = (select cate_no from category where cate_name = ?) order by cul_startDate"
          connection.query sql, [category], (err, results) ->
            console.log category
            if results.length == 0 || err
              console.log err
              msg.send "해당 날짜에 모임이 없습니다.. :("
            else
              list = []
              for row in results
               list.push(row.cul_title + " " + moment(row.cul_startDate).format("MM월 DD일"),)
              lists = list + ""
             # 배열에서 , 생성된 문자 치환
              lists = lists.split(',').join("\n")
              msg.send "문화예술 카테고리에 해당하는 모임이 있습니다\n"+"#{lists}"
            connection.release()
