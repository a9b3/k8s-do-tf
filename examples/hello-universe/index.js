var http = require('http')
var execSync = require('child_process').execSync
var util = require('util')

const helloWorldUrl = `http://${process.env.HELLO_WORLD_SERVICE_HOST}:${process.env.HELLO_WORLD_SERVICE_PORT}`

var server = http.createServer(function(req, res) {
  res.writeHead(200)

  http.get(helloWorldUrl, function(httpRes) {
    var data = `
    ${util.inspect(httpRes)}
    `
    res.end(data)
    httpRes.resume()
  })
  .on('error', function(e) {
    res.end(e)
  })
})

server.listen(8080)
