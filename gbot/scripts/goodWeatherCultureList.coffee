mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 20,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

module.exports = (robot) ->
  # # 맑은날 카테고리 선택
  # robot.hear /.*\s?(맑은\s?날에?)|(비가?\s?안\s?오는\s?날에?)|(비가?\s?오지\s?않는\s?날에?)\s?문화\s?예술\s모임(.*)/i, (msg) ->
  #   good_WeatherList = robot.brain.get('goodWeather')
  #   console.log good_WeatherList
  #   pool.getConnection (err, connection) ->
  #       sql = "SELECT * FROM culture_event where cul_startDate in(?) and cate_no = '1' order by cul_startDate"
  #       connection.query sql, [good_WeatherList], (err, results) ->
  #         if results.length == 0
  #           msg.send "해당 날짜에 모임이 없습니다.. :("
  #         if err
  #           console.log err
  #         else
  #           list = []
  #           for row in results
  #            list.push(row.cul_title + " " + moment(row.cul_startDate).format("MM월 DD일"),)
  #           lists = list + ""
  #          # 배열에서 , 생성된 문자 치환
  #           lists = lists.split(',').join("\n")
  #           weatherString = good_WeatherList + ""
  #           weatherGoodDay = weatherString.split(',').join("\n")
  #           msg.send "#{weatherGoodDay}\n"+ "맑은 날에 해당하는 모임이 있습니다\n"+"#{lists}"
  #         connection.release()

  # 맑은 날 전체
  robot.hear /.*\s?(맑은\s?날에?)|(비가?\s?안\s?오는\s?날에?)|(비가?\s?오지\s?않는\s?날에?)\s?모임(.*)/i, (res) ->
    good_WeatherList = robot.brain.get('goodWeather')
    console.log good_WeatherList
    goodWeatherList(robot, res, good_WeatherList)


goodWeatherList = (robot, res, good_WeatherList) ->
    pool.getConnection (err, connection) ->
      sql = "SELECT * FROM culture_event where cul_startDate in(?) order by cul_startDate"
      connection.query sql, [good_WeatherList], (err, results) ->
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
            # list.push(row.cul_title + " " + moment(row.cul_startDate).format("MM월 DD일"),)
            list.push(meetingList)
            #  msg.send "#{day} 이후 모임들은 #{lists} 입니다. 몇시에 가실 껀가요?"
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
           res.send("'맑은날 더보기'로 더 찾아보아요 :)")
          connection.release()
