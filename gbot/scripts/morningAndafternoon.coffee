mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 20,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

module.exports = (robot) ->
  robot.hear /(.*)쯤\s?갈(.*)$/i, (res) ->
    am_and_pm = decodeURIComponent(unescape(res.match[1]))
    am_and_pm = am_and_pm.trimLeft()
    day = robot.brain.get("day")
    console.log day
    if am_and_pm == "오전"
      amTime = ['08','09','10','11']
      robot.brain.set "amTime", amTime
      getAmMeetingList(robot, day, res, amTime)
    else if am_and_pm == "오후"
      pmTime = ['12','13','14','15','16','17','18']
      robot.brain.set "pmTime", pmTime
      getPmMeetingList(robot, day, res, pmTime)
    else
      res.send "양식에 맞게 작성해주세요 :)"


getAmMeetingList = (robot, day, res, amTime) ->
  pool.getConnection (err, connection) ->
    sql = "select * from culture_event where cul_startDate >= ? and cul_viewingTime in(?) limit 0, 4"
    connection.query sql, [day, amTime], (err, data) ->
      if err
       console.log err
      else if data.length == 0
       console.log "해당하는 모임들이 없네요. :'("
      else
       list = []
       for row in data
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
       res.send("'더보기'로 더 찾아보아요 :) \n 카테고리를 정해주세요!")
      connection.release()


getPmMeetingList = (robot, day, res, pmTime) ->
  pool.getConnection (err, connection) ->
    sql = "select * from culture_event where cul_startDate > ? and cul_viewingTime in(?) limit 0, 4"
    connection.query sql, [day, pmTime], (err, data) ->
      if err
       console.log err
      else if data.length == 0
       console.log "해당하는 모임들이 없네요. :'("
      else
       list = []
       for row in data
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
       res.send("'더보기'로 더 찾아보아요 :) \n 카테고리를 정해주세요!")
      connection.release()
