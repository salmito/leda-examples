local _=require 'leda'
local stage={}

stage.handler=function(req)
	print('===== REQUEST ===')
	for k,v in pairs(req) do print(k,v) end
	print('===== REQUEST URL ===')
	for k,v in pairs(req.parsed_url) do print(k,v) end
	print('===== REQUEST HEADERS ===')
	for k,v in pairs(req.headers) do print(k,v) end
	print('===== END ===')
end

stage.name="Debug"

return _.stage(stage)
