local _=require 'leda'
local stage={}

local cache={}

local current_size=0

stage.handler=function(req,file,size,content)
	if req=='add' then
		if size>self.size then
			return leda.send('log',"Cannot put object into cache")
		end
		self.size=self.size+size
		cache[file]={content,size}
	end
	if cache[file] then
	else
		leda.send('miss',req)
	end
end

function stage.init() 
	cache={}
end

function stage:bind(output)
	assert(output.hit,"Hit output must be connected")
	assert(output.miss,"Miss output must be connected")
end

stage.serial=true

stage.name="Cache"

return _.stage(stage)
