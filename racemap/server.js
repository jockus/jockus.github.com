var connect = require('connect');
console.log( __dirname + "/racemap/www" );
connect.createServer(
    connect.static(__dirname + "/racemap/www")
).listen(8080);
