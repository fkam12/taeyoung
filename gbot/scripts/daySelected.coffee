mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 30,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

module.exports = (robot) ->
  robot.brain.set "allListValue" , 0
  allList = robot.brain.get("allListValue")
  robot.hear /(내가|난)\s?(.*)부터\s?시간(.*)?/i, (res) ->
    day = decodeURIComponent(unescape(res.match[2]))
    day = day.substring(day.indexOf("일"), -1)
    if day > 0 && day < 32
     day = moment().format("YYYY-MM-") + day
     robot.brain.set "day", day
     console.log day
     robot.brain.set "getAllListFunction", getAllList
     getAllList(robot, day, res, allList)
	   else
      res.send "양식에 맞게 적어주세요. :)"

 getAllList = (robot, day, res, allList) ->
       pool.getConnection (err, connection) ->
         sql = "select * from culture_event where cul_startDate >= ? limit ?, 4"
         console.log allList
         connection.query sql, [day, allList], (err, data) ->
           if err
             console.log err
           else if data.length == 0
             res.send "더 이상 리스트가 없습니다. :("
           else
             list = []
             meetLocations = []
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
              meetLocation = {
                lat : "#{row.cul_WGSlat}"
                lng : "#{row.cul_WGSlon}"
              }
              # list.push(row.cul_title + " " + moment(row.cul_startDate).format("MM월 DD일"),)
              list.push(meetingList)
              meetLocations.push(meetLocation)
              robot.brain.set "meetLocations" , meetLocations
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
             res.send("'더보기'로 더 찾아보아요 :) \n 몇시에 가실껀가요?")
             List = robot.brain.set "List" , allList + 4
            connection.release()
