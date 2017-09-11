
config = require '../config.json'


# 구글 맵 키
map_key = config.google_map_key

module.exports = (robot) ->
 robot.hear /위치\s?지도/g, (res) ->
     if userLocations
      robot.brain.set "userLocations" , userLocations
      console.log userLocations
      userLo = robot.brain.get("userLocations")
      if userLo
        res.envelope.fb = {
          richMsg: {
            attachment: {
              type: "image",
              payload: {
                url : "https://maps.googleapis.com/maps/api/staticmap?center=#{userLo.lat},#{userLo.lng}&zoom=16&size=400x400&markers=color:blue%7Clabel:S%7C#{userLo.lat},#{userLo.lng}&key=#{map_key}"
              }
            }
          }
        }
        res.send()
      else
        res.send "위치를 잡을 수가 없네요 :'( \n 다시 한 번 위치를 전송해주세요! :)"
