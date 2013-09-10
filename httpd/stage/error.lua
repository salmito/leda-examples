local _=require 'leda'
local stage={}

local errors={
404="File not found",
405="Method Not Allowed",
}

stage.handler=function(req,res)
	if errors[res.status] then
		
	end
end

stage.name="Debug"

return _.stage(stage)
