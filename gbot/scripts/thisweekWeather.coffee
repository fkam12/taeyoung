# 모듈 require
http = require 'http'
moment = require 'moment'
q = require 'q'
config = require '../config.json'

# 날씨 api
weather_api_key = config.weather.key
weather_version = config.weather.version

module.exports = (robot) ->
  robot.hear /이번주\s*(.*)\s?날씨\s*(.*)$|맑은\s?날\s?언제(.*)$/i, (msg) ->
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

        # 오늘 날씨
        todaySky = response.weather.summary[0].today.sky.name
        todaySkyCode = response.weather.summary[0].today.sky.code
        todayTime = moment().format('MM월DD일HH시')

        # 내일 날씨
        tomorrowSky = response.weather.summary[0].tomorrow.sky.name
        tomorrowSkyCode = response.weather.summary[0].tomorrow.sky.code
        tomorrowTime = moment().add(24, 'h').format('MM월DD일HH시')

        # 모레 날씨
        afterTSky = response.weather.summary[0].dayAfterTomorrow.sky.name
        afterTSkyCode = response.weather.summary[0].dayAfterTomorrow.sky.code
        afterTime = moment().add(48, 'h').format('MM월DD일HH시')


        msg.http("http://apis.skplanetx.com/weather/forecast/6days?version=#{weather_version}&lat=#{geoCode.lat}&lon=#{geoCode.lng}&appKey=#{weather_api_key}")
          .get() (err, res, body) ->

            response = JSON.parse(body)
            # 3일 뒤 날씨
            day3Sky = response.weather.forecast6days[0].sky.pmName3day
            day3SKyCode = response.weather.forecast6days[0].sky.pmCode3day
            # 4일 뒤 날씨
            day4Sky = response.weather.forecast6days[0].sky.pmName4day
            day4SKyCode = response.weather.forecast6days[0].sky.pmCode4day
            # 5일 뒤 날씨
            day5Sky = response.weather.forecast6days[0].sky.pmName5day
            day5SKyCode = response.weather.forecast6days[0].sky.pmCode5day
            # 6일 뒤 날씨
            day6Sky = response.weather.forecast6days[0].sky.pmName6day
            day6SKyCode = response.weather.forecast6days[0].sky.pmCode6day
            # 7일 뒤 날씨
            day7Sky = response.weather.forecast6days[0].sky.pmName7day
            day7SKyCode = response.weather.forecast6days[0].sky.pmCode7day

            WeatherSkyNameList = []
            WeatherSkyNameList.push(todaySky)
            WeatherSkyNameList.push(tomorrowSky)
            WeatherSkyNameList.push(afterTSky)
            WeatherSkyNameList.push(day3Sky)
            WeatherSkyNameList.push(day4Sky)
            WeatherSkyNameList.push(day5Sky)
            WeatherSkyNameList.push(day6Sky)
            WeatherSkyNameList.push(day7Sky)

            console.log WeatherSkyNameList
            console.log todaySkyCode
            console.log tomorrowSkyCode

            goodWeatherList = []
            if todaySkyCode == 'SKY_D01' || todaySkyCode == 'SKY_D02' || todaySkyCode == 'SKY_D03'
              goodWeatherList.push(moment().format('YYYY-MM-DD'))
              # robot.brain.set "goodWeather", moment().format('YYYY-MM-DD')
              # goodWeatherList = robot.brain.get('goodWeather')

            if tomorrowSkyCode == 'SKY_M01' || todaySkyCode == 'SKY_M02' || todaySkyCode == 'SKY_M03'
              goodWeatherList.push(moment().add(24, 'h').format('YYYY-MM-DD'))

            if afterTSkyCode == 'SKY_M01' || afterTSkyCode == 'SKY_M02' || afterTSkyCode == 'SKY_M03'
              goodWeatherList.push(moment().add(48, 'h').format('YYYY-MM-DD'))

            if day3SKyCode == 'SKY_W01' || day3SKyCode == 'SKY_W02' || day3SKyCode == 'SKY_W03'
              goodWeatherList.push(moment().add(72, 'h').format('YYYY-MM-DD'))

            if day4SKyCode == 'SKY_W01' || day4SKyCode == 'SKY_W02' || day4SKyCode == 'SKY_W03'
              goodWeatherList.push(moment().add(96, 'h').format('YYYY-MM-DD'))

            if day5SKyCode == 'SKY_W01' || day5SKyCode == 'SKY_W02' || day5SKyCode == 'SKY_W03'
              goodWeatherList.push(moment().add(120, 'h').format('YYYY-MM-DD'))

            if day6SKyCode == 'SKY_W01' || day6SKyCode == 'SKY_W02' || day6SKyCode == 'SKY_W03'
              goodWeatherList.push(moment().add(144, 'h').format('YYYY-MM-DD'))

            if day7SKyCode == 'SKY_W01' || day7SKyCode == 'SKY_W02' || day7SKyCode == 'SKY_W03'
              goodWeatherList.push(moment().add(168, 'h').format('YYYY-MM-DD'))


            # 맑은 날씨를 Redis로 사용
            robot.brain.set "goodWeather", goodWeatherList
            goodWeather = robot.brain.get("goodWeather")


            day3Time = moment().add(72, 'h').format('MM월DD일HH시')
            day4Time = moment().add(96, 'h').format('MM월DD일HH시')
            day5Time = moment().add(120, 'h').format('MM월DD일HH시')
            day6Time = moment().add(144, 'h').format('MM월DD일HH시')
            day7Time = moment().add(168, 'h').format('MM월DD일HH시')


            # goodWeather = WeatherSkyNameList.filter((item, index, array) ->
            #  return item.search(/[눈비흐]+/);
            # )

            # WeatherSkyWeekList = []
            # WeatherSkyWeekList.push(todayTime)
            # WeatherSkyWeekList.push(tomorrowTime)
            # WeatherSkyWeekList.push(afterTime)
            # WeatherSkyWeekList.push(day3Time)
            # WeatherSkyWeekList.push(day4Time)
            # WeatherSkyWeekList.push(day5Time)
            # WeatherSkyWeekList.push(day6Time)
            # WeatherSkyWeekList.push(day7Time)
            #
            # console.log WeatherSkyNameList
            # console.log goodWeather
            #
            # console.log WeatherSkyWeekList
            # robot.brain.set 'goodWeather', list

            msg.send "#{todayTime} 날씨는 '#{todaySky}'입니다.\n
#{tomorrowTime} 날씨는 '#{tomorrowSky}'입니다.\n
#{afterTime} 날씨는 '#{afterTSky}'입니다.\n
#{day3Time} 날씨는 '#{day3Sky}'입니다.\n
#{day4Time} 날씨는 '#{day4Sky}'입니다.\n
#{day5Time} 날씨는 '#{day5Sky}'입니다.\n
#{day6Time} 날씨는 '#{day6Sky}'입니다.\n
#{day7Time} 날씨는 '#{day7Sky}'입니다."
