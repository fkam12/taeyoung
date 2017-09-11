mysql = require('mysql')
moment = require('moment')
pool = mysql.createPool
  connectionLimit : 20,
  host: 'us-cdbr-iron-east-05.cleardb.net',
  user: 'bd88da13beab08',
  password: 'd07eff66',
  database: 'heroku_583ab3ec4bffd6f'

module.exports = (robot) ->
 robot.hear /더보기|getAllList/i, (res) ->
   day = robot.brain.get("day")
   getAllList = robot.brain.get("getAllListFunction")
   console.log getAllList
   List = robot.brain.get("List")
   getAllList(robot, day, res, List)
