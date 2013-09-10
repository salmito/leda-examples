--Webserver configuration

return {
	--TCP port to listen for clients
	port=8081,
	--Webroot Directory
	webroot='./webroot/',
	--Size of memory cache (100MB)
	cache_size=100*1024*1024,
	--controller configuration
	controller_port=8082,
	controller_user='user',
	controller_pass='pass',
}
