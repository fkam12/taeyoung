mysql = require 'mysql'
q = require 'q'
http = require 'http'
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

  robot.hear /길\s*찾(.*)?/i, (res) ->
    userLo = robot.brain.get("userLocations")
    destination = robot.brain.get("meetingLocation")
    if !destination
     res.send "'모임' 지도로 먼저 검색해주세요 :)"
    else
     getDirectionsMap(res, userLo, destination)


#googleMap by api
getDirectionsMap = (res, userLo, destination) ->
  console.log userLo.lat
  console.log userLo.lng
  console.log destination.lat
  console.log destination.lng
  res.envelope.fb = {
    richMsg: {
      attachment: {
        type: "image",
        payload: {
          url : "https://maps.googleapis.com/maps/api/staticmap?size=400x400&path=color:0x0000ff|weight:5|#{userLo.lat},#{userLo.lng}|#{destination.lat},#{destination.lng}&key=#{map_key}"
        }
      }
    }
  }
  res.send("현재 위치에서 모임까지 대략적인 위치를 표시합니다. :)")
