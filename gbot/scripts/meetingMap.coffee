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

  robot.hear /(.*)\s*지도(.*)?/i, (res) ->
    meetingName = decodeURIComponent(unescape(res.match[1]))
    console.log meetingName
    getReverseGeocode(res, meetingName)
    .then (geoCode) ->
        getMap(res, geoCode)
    .catch (err)->
        res.send '모임을 정확하게 입력해주시기 바랍니다 :)'

  getReverseGeocode = (res, meetingName) ->
    deferred= q.defer()
    pool.getConnection (err, connection) ->
      sql = 'select * from culture_event where cul_title = substr(?,2)'
      connection.query sql, [meetingName], (err, data) ->
        if err
          console.log err
        else
          console.log data
          # 위도, 경도
          lat = data[0].cul_WGSlat
          lng = data[0].cul_WGSlon
          placeName = data[0].cul_placeName
          res.http("https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&key=#{map_key}")
            # .query({
            #   address: placeName
            # })
            .get() (err, response, body) ->
              respond = JSON.parse(body)
              console.log respond
              if respond.status is "OK"
                geoCode = {
                  lat : respond.results[0].geometry.location.lat
                  lng : respond.results[0].geometry.location.lng
                }
                robot.brain.set "meetingLocation", geoCode
                deferred.resolve(geoCode)
              else
                deferred.reject(err)
    return deferred.promise
    connection.release()

#googleMap by api
getMap = (res, geoCode) ->
  res.envelope.fb = {
    richMsg: {
      attachment: {
        type: "image",
        payload: {
          url : "https://maps.googleapis.com/maps/api/staticmap?center=#{geoCode.lat},#{geoCode.lng}&zoom=16&size=400x400&markers=color:blue%7Clabel:S%7C#{geoCode.lat},#{geoCode.lng}&key=#{map_key}"
        }
      }
    }
  }
  res.send("모임의 위치를 표시합니다. :)")
