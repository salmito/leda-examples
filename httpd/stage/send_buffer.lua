local _=require 'leda'
local util=require "httpd_util"

local response_headers=util.response_headers
local stdresp=util.stdresp

local stage={}

stage.handler=function(sock,file,close)
	local content=cache.get(file)
	local res={headers=response_headers()}
  	res.headers["Content-Length"]=#content
 	res.headers["Content-Type"]="text/html"
 	res.status_code=200
	sock:send(stdresp(res)) --Send headers
	sock:send(content)
	leda.send('close',sock,close)
end

stage.init=function() 
	require 'os'
	require 'table'
	cache=require 'cache'
	async=true require 'io'
end

function stage:bind(output)
	assert(output.close,"Close output must be connected")
end

stage.name="Send buffer"

return _.stage(stage)
