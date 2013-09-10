local _=require 'leda'
local util=require "httpd_util"

local response_headers=util.response_headers
local stdresp=util.stdresp
local stage={}

local bufsize=4096

stage.handler=function(req,add_to_cache)
	local res={headers=response_headers()}
	local file=io.open(self.directory..req.relpath,"r")
	if file then --file found
		local size = file:seek("end")    -- get file size
      file:seek("set")
     	file=io.open(self.directory..req.relpath,"r")
      res.headers["Content-Length"]=size
      res.headers["Content-Type"]="text/html"
      res.status_code=200
		req.sock:send(stdresp(res)) --Send headers
		local buffer=file:aread(bufsize)
		local content={}
		while buffer do
			table.insert(content,buffer)
			req.sock:send(buffer)
			buffer=file:aread(bufsize)
		end
		if add_to_cache then
			leda.send('add','add',req.relpath,table.concat(content))
		end
		leda.send('close',req.sock,(req.headers['connection']=="close"))
		return
	else
		local body="<html>Error: file '"..req.relpath.."' not found</html>"
		res.status_code=404
		res.headers["Content-Length"]=#body
		res.headers["Content-Type"]="text/html"
		req.sock:send(stdresp(res))
		req.sock:send(body)
		leda.send('close',req.sock,not (req.headers['connection']=="keep-alive"))
	end
end

stage.init=function() 
	require 'os'
	require 'table'
	async=true 
	require 'io'
end

function stage:bind(output)
	assert(self.directory,"Directory must be defined")
	assert(output.close,"Close output must be connected")
end

stage.name="Send file"

return _.stage(stage)
