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
  robot.hear /(.*)에\s?관심(.*)/i, (res) ->
    category = decodeURIComponent(unescape(res.match[1]))
    category = category.trimLeft()
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

    day = robot.brain.get('day')
    amTime = robot.brain.get('amTime')
    pmTime = robot.brain.get('pmTime')
    goodWeatherList = robot.brain.get('goodWeather')
    if amTime
      getAmCategoryList(res, day, amTime, category)
    else if pmTime
      getPmCategoryList(res, day, pmTime, category)

getAmCategoryList = (res, day, amTime, category) ->
      pool.getConnection (err, connection) ->
          sql = "SELECT * FROM culture_event where cul_startDate > ? and cul_viewingTime in(?) and cate_no = (select cate_no from category where cate_name = ?) order by cul_startDate limit 0, 4"
          connection.query sql, [day, amTime, category], (err, results) ->
           if err
            console.log err
           else
            if results.length == 0
              res.send "해당 날짜에 모임이 없습니다.. :("
            else
             list = []
             for row in results
              meetDay = moment(row.cul_startDate).format("YYYY-MM-DD")
              meetingList = {
                title: "#{row.cul_title}",
                image_url: "https://cdn.pixabay.com/photo/2017/07/10/16/07/thank-you-2490552_1280.png",
                subtitle: "#{meetDay}"+" "+ "#{row.cul_viewingTime}"+ "시" + " "+"#{row.cul_content}",
                default_action: {
                  type: "web_url",
                  url: "https://cdn.pixabay.com/photo/2017/07/10/16/07/thank-you-2490552_1280.png",
                },
                buttons: [
                  {
                    title: "예매 하러 가기",
                    type: "web_url",
                    url: "http://localhost:8080/yg/eventDetail?cul_no=" + "#{row.cul_no}",
                  }
                ]
              }
              list.push(meetingList)
             console.log list
             res.envelope.fb = {
               richMsg : {
                attachment: {
                  type: "template",
                  payload: {
                    template_type: "list",
                    top_element_style: "large",
                    elements: list
                  }
                }
               }
             }
             res.send("#{category} 모임 입니다.\n'더보기'로 더 찾아보아요 :)")
            connection.release()

getPmCategoryList = (res, day, pmTime, category) ->
      pool.getConnection (err, connection) ->
          sql = "SELECT * FROM culture_event where cul_startDate > ? and cul_viewingTime in(?) and cate_no = (select cate_no from category where cate_name = ?) order by cul_startDate limit 0, 4"
          connection.query sql, [day, pmTime, category], (err, results) ->
           if err
            console.log err
           else
            if results.length == 0
              res.send "해당 날짜에 모임이 없습니다.. :("
            else
             list = []
             for row in results
              meetDay = moment(row.cul_startDate).format("YYYY-MM-DD")
              meetingList = {
                title: "#{row.cul_title}",
                image_url: "https://cdn.pixabay.com/photo/2017/07/10/16/07/thank-you-2490552_1280.png",
                subtitle: "#{meetDay}"+" "+ "#{row.cul_viewingTime}"+ "시" + " "+"#{row.cul_content}",
                default_action: {
                  type: "web_url",
                  url: "https://cdn.pixabay.com/photo/2017/07/10/16/07/thank-you-2490552_1280.png",
                },
                buttons: [
                  {
                    title: "예매 하러 가기",
                    type: "web_url",
                    url: "http://localhost:8080/yg/eventDetail?cul_no=" + "#{row.cul_no}",
                  }
                ]
              }
              list.push(meetingList)
             console.log list
             res.envelope.fb = {
               richMsg : {
                attachment: {
                  type: "template",
                  payload: {
                    template_type: "list",
                    top_element_style: "large",
                    elements: list
                  }
                }
               }
             }
             res.send("#{category} 모임 입니다.\n'더보기'로 더 찾아보아요 :)")
            connection.release()
