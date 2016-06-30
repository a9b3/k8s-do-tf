var http = require('http')
var execSync = require('child_process').execSync
var util = require('util')

var server = http.createServer(function(req, res) {
  res.writeHead(200)
  var inetInfo = execSync('ip a')

  var data = `Hello World

  remoteAddress:

${util.inspect(req.socket.remoteAddress)}

  request headers:

${util.inspect(req.headers)}

  inet:

${inetInfo}
  `

  res.end(data)
})

server.listen(8080)
