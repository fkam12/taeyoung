fb = require('hubot-fb')

mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 20,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

config = require '../config.json'


# 구글 맵 키
map_key = config.google_map_key

module.exports = (robot) ->
  robot.hear /가까운\s?순?데?(.*)\s?(.*)|내\s?주변(.*)?모임(.*)?/i, (res) ->
    notLoc = "'내 위치'로 사용자님의 위치를 보내주세요 :)"
    userLoc = global.userLocations
    if userLoc && notLoc
      robot.brain.set "userLocations" , userLocations
      getNearList(robot, res, userLocations)
    else
      res.send "#{notLoc}"


getNearList = (robot, res, userLocations) ->
  pool.getConnection (err, connection) ->
   sql = "select *,
  (6371*acos(cos(radians("+userLocations.lat+"))*cos(radians(cul_WGSlat))*cos(radians(cul_WGSlon)
  -radians("+userLocations.lng+"))+sin(radians("+userLocations.lat+"))*sin(radians(cul_WGSlat))))

  as distance
  from culture_event
  having distance <= 5
  order by distance
  limit 0, 4"
   connection.query sql, (err, data) ->
     if err
       console.log err
     else
      day = robot.brain.get("day")
      list = []
      for row in data
       distance = row.distance
       dis = Math.floor(distance * 100)/100
       meetday = moment(row.cul_startDate).format("YYYY-MM-DD")
       meetingList = {
         title: "#{row.cul_title} "+" 약"+ "#{dis}km",
         image_url: "https://cdn.pixabay.com/photo/2017/07/10/16/07/thank-you-2490552_1280.png",
         subtitle: "#{meetday}"+" "+ "#{row.cul_viewingTime}"+ "시" + " "+"#{row.cul_content}",
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

      #  robot.brain.set "meetLocations" , meetLocations
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
      res.send("현재 위치에서 5km 이내의 모임을 나타냅니다. \n '거리 순 더보기'로 더 찾아보아요 :) \n '모임' 지도를 입력하시면 지도를 보실 수 있습니다. :)")
