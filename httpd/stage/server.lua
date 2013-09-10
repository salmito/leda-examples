local _=require 'leda'
local config=require 'config'
local stage={}

stage.handler=function()
    local server_sock=assert(socket.bind("*",self.port))
--    print("SERVER: Started on port",self.port)
    while true do
       local cli_sock=assert(server_sock:accept())
       cli_sock:setoption ("tcp-nodelay", true)
       local cli, cport = cli_sock:getpeername()
       local req={sock=cli_sock}
       if leda.send('client',req) then 
       	leda.send('log',"Incoming client: "..cli..":"..cport)
       else
	       leda.send('log',self.name..": Error sending event: "..cli..":"..cport)
	       cli_sock:close()
       end
   end
end

stage.init=function ()
	require 'leda.utils.socket'
end

function stage:bind(output)
	assert(output.client,"Stage '"..tostring(self).."' must be connected through 'client' port")
	assert(self.port,"Port field must be defined for stage '"..tostring(self).."'")
	self.port=assert(tonumber(self.port),"Port field must be a number")
end

stage.autostart=true

stage.name="Wait client"

return _.stage(stage)
