local _=require 'leda'
local util=require "httpd_util"

local response_headers=util.response_headers
local stdresp=util.stdresp

local stage={}

local bufsize=4096

stage.handler=function(req)
	local res={headers=response_headers()}
	local script=self.directory..req.relpath
	local file=io.open(script,"r")
	if not file then --file found
		local body="<html>Error: file '"..req.relpath.."' not found</html>"
		res.status_code=404
		res.headers["Content-Length"]=#body
		res.headers["Content-Type"]="text/html"
		req.sock:send(stdresp(res))
		req.sock:send(body)
		leda.send('close',req.sock, (req.headers['connection']=="close"))
		return
	else
		file:close()
		local output=dofile(self.directory..req.relpath)
		local content=output --table.concat(output)
		local res={headers=response_headers()}
  	 	res.headers["Content-Length"]=#content
 	  	res.headers["Content-Type"]="text/html"
 	  	res.status_code=200
		req.sock:send(stdresp(res)) --Send headers
		req.sock:send(content)
		leda.send('close',req.sock, (req.headers['connection']=="close"))
	end
end

stage.init=function() 
	old_print=print
	require 'os'
	require 'table'
	async=true require 'io'
end

function stage:bind(output)
	assert(self.directory,"Directory must be defined")
	assert(output.close,"Close output must be connected")
end

stage.name="CGI Lua"

return _.stage(stage)
