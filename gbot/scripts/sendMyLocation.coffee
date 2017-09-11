config = require '../config.json'


# 구글 맵 키
map_key = config.google_map_key

module.exports = (robot) ->
 robot.hear /(내|나의)\s?위치/g, (res) ->
     res.envelope.fb = {
       richMsg : {
           text: "위치를 보내 주세요!",
           quick_replies:[
             {
               content_type : "location"
             }
           ]
         }
       }
     res.send("위치를 보낸 후 \n 구글 맵으로 보시려면 '위치 지도'를 입력하세요 :)")
