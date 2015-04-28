assert = require 'better-assert'
Dama2 = require '../index.js'

appID = '37277'
appKey = '2e71bd86b69e1082958187076620b591'
user = 'test'
pwd = 'test'

describe '打码兔，请先设置你的用户信息', ()->
  dama2 = new Dama2 appID, appKey, user, pwd
  requestID = ''

  it '注册', (done)->
    @timeout 10000
    user =
      user: "#{Math.round(Math.random() * 10000)}#{Math.round(Math.random() * 1000)}#{Math.round(Math.random() * 1000)}",
      pwd: 'test'
      qq: "#{Math.round(Math.random() * 1000)}#{Math.round(Math.random() * 1000)}#{Math.round(Math.random() * 1000)}",
      email: "#{Math.round(Math.random() * 1000)}#{Math.round(Math.random() * 1000)}#{Math.round(Math.random() * 1000)}@163.com",
      tel: "18515#{Math.round(Math.random() * 1000)}891"

    dama2.register user, '372771', '1e71bd86b69e1082958187076620b591', (error, result)->
      console.log error if error
      assert error is null
      assert result
      done()

  it '登录', (done)->
    @timeout 10000
    dama2.login (error, auth)->
      console.log error if error
      assert error is null
      assert auth
      done()

  it '获取用户信息', (done)->
    @timeout 10000
    dama2.readUserInfo (error, result)->
      console.log error if error
      assert error is null
      assert result
      done()

  it '获取余额', (done)->
    @timeout 10000
    dama2.getBalance (error, result)->
      console.log error if error
      assert error is null
      assert result
      done()

  it '打码文件', (done)->
    @timeout 10000
    dama2.decodeFile 44, "#{__dirname}/test.jpg", null, 30, (error, result)->
      console.log error if error
      assert error is null
      assert result.id
      done()

  it '简单打码文件', (done)->
    @timeout 10000
    dama2.simpleDecodeFile 44, "#{__dirname}/test.jpg", (error, id, result)->
      console.log error if error
      assert error is null
      assert id
      assert result == 'AEYAYY'
      done()

  it '打码URL', (done)->
    @timeout 10000
    dama2.decode 44, 'http://www.dama2.com/Index/imgVerify',
      null, null, null, null, (error, result)->
        console.log error if error
        requestID = result.id
        assert error is null
        assert result
        done()

  it '简单打码URL', (done)->
    @timeout 10000
    dama2.simpleDecode 44, 'http://reg.163.com/services/getimg?v=1430186526236&num=6&type=2&id=c9deebf3c01db3f2fb0de2d0edf263b9adf46920', '', (error, id, result)->
        console.log error if error
        assert error is null
        assert id
        assert result
        done()

  it '获取打码结果', (done)->
    @timeout 10000
    dama2.getResult requestID, (error, result)->
      console.log error if error
      assert error is null
      assert result
      done()

  it '报告错误', (done)->
    @timeout 10000
    dama2.reportError requestID, (error, result)->
      console.log error if error
      assert error is null
      assert result
      done()
