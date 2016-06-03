var http = require('http');

var server = http.createServer(function(request, response) {
  response.writeHead(200, {'Content-Type': 'text/html'});
  response.write(`<!DOCTYPE html>
<html>
<head>
  <title>Node.js dummy</title>
</head>
<body>
  Hello World!
</body>
</html>
  `);
  response.end();
});

server.listen(80);
console.log('Server is listening');
