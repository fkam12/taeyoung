# 모듈 require
http = require 'http'
moment = require 'moment'
q = require 'q'
config = require '../config.json'

# 날씨 api
weather_api_key = config.weather.key
weather_version = config.weather.version

module.exports = (robot) ->
  robot.hear /다음주\s*(.*)\s?날씨\s*(.*)$/i, (msg) ->
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
  msg.http("http://apis.skplanetx.com/weather/forecast/6days?version=#{weather_version}&lat=#{geoCode.lat}&lon=#{geoCode.lng}&appKey=#{weather_api_key}")
    .get() (err, res, body) ->
      response = JSON.parse(body)

      # response data
      city = response.weather.forecast6days[0].grid.city
      county = response.weather.forecast6days[0].grid.county

      nextWeekSky = response.weather.forecast6days[0].sky.pmName7day
      nextWeekSkyCode = response.weather.forecast6days[0].sky.pmCode7day
      nextWeekMaxTmp = Math.floor(response.weather.forecast6days[0].temperature.tmax7day)
      nextWeekMinTmp = Math.floor(response.weather.forecast6days[0].temperature.tmin7day)

      additionalMsg = switch nextWeekSkyCode
        when "SKY_W01", "SKY_W02", "SKY_W03" then "`날씨가 무척 좋네요!`"
        when "SKY_W04" then "`하늘이 흐리네요!`"
        when "SKY_W07", "SKY_W09", "SKY_W10" then "`비가 와요! 우산챙기세요!`"
        when "SKY_W11", "SKY_W12", "SKY_W13" then "`눈길! 땅이 미끄러워요! 조심하세요!`"
        else "?"
      time = moment().add(168, 'h').format('MM월 DD일 HH시')
      msg.send "#{time}\n다음주 날씨입니다.\n#{city}의 하늘은 '#{nextWeekSky}'입니다.\n#{additionalMsg}\n내일 최저 기온은 #{nextWeekMinTmp}도, 최고 기온은 #{nextWeekMaxTmp}도 되겠습니다. "
