# 모듈 require
http = require 'http'
moment = require 'moment'
q = require 'q'
config = require '../config.json'

# 날씨 api
weather_api_key = config.weather.key
weather_version = config.weather.version

module.exports = (robot) ->
  robot.hear /오늘\s*(.*)\s?날씨\s*(.*)$/i, (msg) ->
    location = decodeURIComponent(unescape(msg.match[1]))
    getGeocode(msg, location)
    .then (geoCode) ->
        getWeather(msg, geoCode, location)
    .catch (err)->
        msg.send '그런 지역은 없습니다....'

# getGeocode by Google map
getGeocode = (msg, location) ->
  deferred= q.defer()
  msg.http("https://maps.googleapis.com/maps/api/geocode/json")
    .query({
      address: location
    })
    .get() (err, res, body) ->
      response = JSON.parse(body)
      if response.status is "OK"
        geoCode = {
          lat : response.results[0].geometry.location.lat
          lng : response.results[0].geometry.location.lng
        }
        deferred.resolve(geoCode)
      else
        deferred.reject(err)
  return deferred.promise

  # getWeather by api
getWeather = (msg, geoCode, location) ->
  msg.http("http://apis.skplanetx.com/weather/summary?version=#{weather_version}&lat=#{geoCode.lat}&lon=#{geoCode.lng}&appKey=#{weather_api_key}")
    .get() (err, res, body) ->
      response = JSON.parse(body)

      # response data
      city = response.weather.summary[0].grid.city
      county = response.weather.summary[0].grid.county

      todaySky = response.weather.summary[0].today.sky.name
      todaySkyCode = response.weather.summary[0].today.sky.code
      todayMaxTmp = Math.floor(response.weather.summary[0].today.temperature.tmax)
      todayMinTmp = Math.floor(response.weather.summary[0].today.temperature.tmin)

      additionalMsg = switch todaySkyCode
        when "SKY_D01", "SKY_D02" then "`날씨가 무척 좋네요!`"
        when "SKY_D03", "SKY_D04" then "`하늘이 흐리네요!`"
        when "SKY_D05" then "`비가 와요! 우산챙기세요!`"
        when "SKY_D06" then "`눈길! 땅이 미끄러워요! 조심하세요!`"
        when "SKY_D07" then "`땅이 질척!`"
        else "?"
      time = moment().format('MM월 DD일 HH시')
      msg.send "#{time}\n오늘의 날씨입니다.\n#{city}의 하늘은 '#{todaySky}'입니다.\n#{additionalMsg}\n오늘 최저 기온은 #{todayMinTmp}도, 최고 기온은 #{todayMaxTmp}도 되겠습니다. "
