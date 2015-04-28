# 打码兔 Node.js SDK
[![NPM](http://www.dama2.com/Public/images/logo.png)](http://www.dama2.com)

-----

### Install
not post to npm, pelease wait some days
```
$ npm install dama2 --save
```

-----

### Test
modify the appID, appKey, username, password at first
```
$ mocha test
```

-----

### Usage

```
Dama2 = require('dama2')
 
appID = 'your appID';
appKey = 'your appKey';
user = 'username';
pwd = 'password';
dama2 = new Dama2(appID, appKey, user, pwd);

// login
dama2.login(function(error, auth) {

  // read user info
  dama2.readUserInfo(function(error, userInfo) {
    ...
  })

  // get verify code by file
  dama2.decodeFile(44, 'test.jpg', null, 30, function (error, result) {
    ...
  })

  // get verify code by url
  dama2.decode(44, 'http://www.dama2.com/Index/imgVerify',
    null, null, null, null, function (error, result){
    ...
  })

})
      
```

-----

### API
All of dama2's api follow the rule
the first param alway is Error object, the other is the real data.

#### constructor(appId, appKey, username, password, apiBaseUrl)
```
// apiBaseUrl, default is http://api.dama2.com:7788, not require
var dama2 = new Dama2(appId, appKey, username, password)
```

#### login(callback)
```
// auth is dama2 authed string, for other api
dama2.login(function(error, auth) {
  ...
})
```

#### register(userInfoObj, appID, appKey, callback)
```
// userInfoObj = {
    user: 'username',
    pwd: 'password',
    qq: 'qq number',
    email: 'email',
    tel: 'tel number'
}
dama2.register(userInfoObj, appID, appKey, function(error, result) {
  ..
})
```

#### readUserInfo(callback)
```
// must logined, otherwise throw error
dama2.readUserInfo(function(error, userInfo){
  ...
})
```

#### getBalance(callback)
```
// must logined
dama2.getBalance(function(error, balanceInfo){
  ...
})
```

#### decode(type, url, len=0, timeout=60, cookie='', referer='', callback)
```
// type is your verify code type, http://wiki.dama2.com/index.php?n=ApiDoc.Pricedesc
// url is verify code image's url
dama2.decode(44, 'http://www.google.com/img1.jpg', 0, 0, 0, 0, function(error, result){
  ...
})
```

#### decodeFile(type, filePath, len=0, timeout=60, callback)
```
type is your verify code type
dama2.decodeFile(44, '/home/gj/img.jpg', 0, 60, function(error, result) {
  ....
})
```

#### getResult(id, callback)
```
// id is in result of decode or decodeFile function
// after decode, you need call getResult to get the result of the verify code image
dama2.getResult(id, function(error, result) {
  ...
})
```

#### reportError(id, callback)
```
// when the verify code is wrong, you can report it to service
dama2.reportError(id, function(error, result) {
  ...
})
```

#### simpleDecode(type, url, referer, callback)
```
// auto call getResult after decode
dama2.simpleDecode(44, 'http://baidu.com/img1.jpg', '', function(error, id, ret){
  ...
})
```

#### simpleDecodeFile(type, filePath, callback)
```
// auto call getResult after decodeFile
dama2.simpleDecodeFile(44, 'http://baidu.com/img1.jpg', function(error, id, ret){
  ...
})
```

-----

### TODO
1.batch decode
2.wait decode finish then callback
3.emit event when decode finish