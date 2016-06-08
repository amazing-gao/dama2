request = require 'request'
crypto = require 'crypto'
_ = require 'lodash'
fs = require 'fs'

desEncode = (param)->
  key = new Buffer(param.key);
  iv = new Buffer(if param.iv then param.iv else 0)
  plaintext = param.plaintext
  alg = param.alg
  autoPad = param.autoPad

  cipher = crypto.createCipheriv(alg, key, iv);
  cipher.setAutoPadding(autoPad)
  ciph = cipher.update(plaintext, 'utf8', 'hex');
  ciph += cipher.final('hex');

postJson = (uri, opts, cb)->
  options =
    url: uri
    json: true

  options = _.merge options, opts
  return request.post options, cb

class Dama2
  constructor:(@_appId, @_appKey, @_username, @_password, @_baseUrl = 'http://api.dama2.com:7788')->
    @_auth = ''
    @_logined = false
    throw new Error unless @_appId and @_appKey and @_username and @_password

  _genDamatuEncInfo: (preauth, user, pwd, key)->
    md5 = crypto.createHash 'md5'
    md5.update pwd
    pwd = md5.digest 'hex'
    encData = "#{preauth}\n#{user}\n#{pwd}"

    key16 = []
    for i in [0...31] by 2
      key16.push "0x#{key[i]}#{key[i+1]}"

    key8 = []
    for i in [0...8] by 1
      key8[i] = Number(key16[i])^Number(key16[i+8])&0xff

    param =
      alg: 'des-ecb',
      autoPad: true,
      key: key8,
      plaintext: encData,
      iv: null
    return desEncode param, key8

  _preAuth: (user, pwd, appKey, cb)->
    postJson "#{@_baseUrl}/app/preauth", {}, (error, resp, body)=>
      return cb error if error
      return cb new Error body.desc if Number(body.ret) != 0

      # 获取预授权信息
      encinfo = @_genDamatuEncInfo body.auth, user, pwd, appKey
      cb error, encinfo

  ###
  注册普通用户，非开发者
  userInfoObj
    user    String 用户名
    pwd     String 密码
    qq      String QQ号
    email   String 邮箱
    tel     String 电话
  ###
  register: (userInfoObj, appID, appKey, cb)->
    return new Error 'invalid user info' unless userInfoObj.user and userInfoObj.pwd and userInfoObj.qq and userInfoObj.email and userInfoObj.tel

    @_preAuth userInfoObj.user, userInfoObj.pwd, appKey, (error, encinfo)=>

      postJson "#{@_baseUrl}/app/register", form:{appID, encinfo, qq:userInfoObj.qq, email:userInfoObj.email, tel:userInfoObj.tel}, (error, resp, body)=>
        cb error, body

  login: (cb)->
    return cb null, @_auth if @_logined and @_auth

    @_preAuth @_username, @_password, @_appKey, (error, encinfo)=>
      return cb error if error

      postJson "#{@_baseUrl}/app/login", form:{appID: @_appId, encinfo: encinfo}, (error, resp, body)=>
        return cb error if error
        return cb new Error body.desc if Number(body.ret) != 0
        @_auth = body.auth if body.auth and body.auth != @_auth
        @_logined = true
        cb error, @_auth

  readUserInfo: (cb)->
    return cb new Error 'not login' unless @_logined
    postJson "#{@_baseUrl}/app/readInfo", form:{auth:@_auth}, (error, resp, body)=>
      return cb error if error
      return cb new Error body.desc if Number(body.ret) != 0
      @_auth = body.auth if body.auth and body.auth != @_auth
      cb error, body

  getBalance: (cb)->
    return cb new Error 'not login' unless @_logined
    postJson "#{@_baseUrl}/app/getBalance", form:{auth:@_auth}, (error, resp, body)=>
      return cb error if error
      return cb new Error body.desc if Number(body.ret) != 0
      @_auth = body.auth if body.auth and body.auth != @_auth
      cb error, body

  decode: (type, url, len = 0, timeout = 60, cookie = '', referer = '', cb)->
    return cb new Error 'not login' unless @_logined
    return cb new Error 'no type' unless type
    return cb new Error 'no url' unless url

    postJson "#{@_baseUrl}/app/decodeURL", {form:{auth: @_auth, url, type, len, timeout, cookie, referer}}, (error, resp, body)=>
      return cb error if error
      return cb new Error body.desc if Number(body.ret) != 0
      @_auth = body.auth if body.auth and body.auth != @_auth
      cb error, body

  simpleDecode:(type, url, referer, cb)->
    @decode type, url, null, null, null, referer, (error, result)=>
      return cb error if error
      return cb new Error result.desc if Number(result.ret) != 0

      id = result.id
      @getResult id, (error, result)=>
        return cb error if error
        return cb new Error result.desc if Number(result.ret) != 0
        cb error, id, result.result

  decodeFile: (type, filePath, len = 0, timeout = 60, cb)->
    return cb new Error 'not login' unless @_logined
    return cb new Error 'no type' unless type
    return cb new Error 'file not exists' unless fs.existsSync filePath
    postJson "#{@_baseUrl}/app/decode", {formData:{auth: @_auth, type, len, timeout, file:fs.createReadStream(filePath)}}, (error, resp, body)=>
      return cb error if error
      return cb new Error body.desc if Number(body.ret) != 0
      @_auth = body.auth if body.auth and body.auth != @_auth
      cb error, body

  simpleDecodeFile: (type, filePath, cb)->
    @decodeFile type, filePath, 0, 30, (error, result)=>
      return cb error if error
      return cb new Error result.desc if Number(result.ret) != 0

      id = result.id
      @getResult id, (error, result)=>
        return cb error if error
        return cb new Error result.desc if Number(result.ret) != 0
        cb error, id, result.result

  getResult: (id, cb)->
    return cb new Error 'not login' unless @_logined
    return cb new Error 'no id' unless id
    postJson "#{@_baseUrl}/app/getResult", form:{auth: @_auth, id}, (error, resp, body)=>
      return cb error if error
      return cb new Error body.desc if Number(body.ret) != 0
      @_auth = body.auth if body.auth and body.auth != @_auth
      cb error, body

  reportError: (id, cb)->
    return cb new Error 'not login' unless @_logined
    return cb new Error 'no id' unless id
    postJson "#{@_baseUrl}/app/reportError", form:{auth: @_auth, id}, (error, resp, body)->
      return cb error if error
      return cb new Error body.desc if Number(body.ret) != 0
      @_auth = body.auth if body.auth and body.auth != @_auth
      cb error, body

module.exports = Dama2
