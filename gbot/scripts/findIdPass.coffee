nodemailer = require('nodemailer');

transporter = nodemailer.createTransport(
    port: 587
    host: 'smtp.naver.com'
    service: 'naver'
   auth:
    user: "?"
    pass: '?'
  tls: ciphers: 'SSLv3')

module.exports = (robot) ->

  robot.hear /(.*)아이디\s?(잃?)(찾?)(까?)(.*)/i, (msg) ->
    msg.send('아이디찾기')

  # robot.hear /(.*)비밀?번호?\s?(잃?)(찾?)(까?)(.*)/i, (msg) ->
  #   mailOptions =
  #     from: 'sotongbox@naver.com'
  #     to: 'fkam12@naver.com'
  #     subject: '고컬쳐 이메일 test'
  #     html: '이메일 test'
  #
  #   transporter.sendMail mailOptions, (error, info) ->
  #     #Email not sent
  #     if error
  #       console.log error
  #     else
  #       console.log info
  #       transporter.close()
  #     return
