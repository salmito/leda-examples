local _=require 'leda'
local stage={}

stage.handler=function(sock,close)
	if close==true then
--	   print("Closing socket",sock)
		sock:close()
	else
--   	print("Keeping socket alive",sock)
		leda.send("client",{sock=sock})
	end
end

stage.name="Close connection"

return _.stage(stage)
