var restify = require('restify');
var fs = require('fs');

function provision(req, res, next) {
  	var user = req.params.user;
	fs.appendFile('/root/lastark/users/users.provision', user+'\n', function(err) {
  		if (err) throw err;
        res.send('User: ' + user + ' added to provision queue.\n');
	});
	next();
}

function unmanage(req, res, next) {
  	var user = req.params.user;
    var file = '/root/lastark/users/users.txt';
	fs.readFile(file, 'utf8', function read(err, data) {
		if (err) {
			throw err;
		}

        var result = data.replace(user+"\n",'');

        fs.writeFile(file, result, 'utf8', function (err) {
            if (err) return console.log(err);
        });

        res.send('User: ' + user + ' removed from LastPass Management!');

	});
	next();
}

function manage(req, res, next) {
  	var user = req.params.user;
	fs.appendFile('/root/lastark/users/users.txt', user+'\n', function(err) {
  		if (err) throw err;
        res.send('User: ' + user + ' added to LastPass Management!');
	});
	next();
}

function list(req, res, next) {
    var file = '/root/lastark/users/users.txt';
	fs.readFile(file, 'utf8', function read(err, data) {
		if (err) {
			throw err;
		}
        res.send(data);

	});
	next();
}

var server = restify.createServer();
server.get('/provision/:user', provision);
server.get('/unmanage/:user', unmanage);
server.get('/manage/:user', manage);
server.get('/list', list);

server.listen(8080, function() {
  console.log('%s listening at %s', server.name, server.url);
});
