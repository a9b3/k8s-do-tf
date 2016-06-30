var http = require('http')
var execSync = require('child_process').execSync
var util = require('util')

var server = http.createServer(function(req, res) {
  res.writeHead(200)

  http.get('http://www.google.com/index.html', function(httpRes) {
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
