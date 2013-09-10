local _=require'leda'

--Set to false to disable logging
--this will prevent it from connecting to othrer stages
local logging=true

return _.stage{
	handler=function(...)
		print(...)
	end,
	bind=function(self,out,g)
		--insert myself in 'log' output of all stages of the graph
		if (not self.added) and logging then
			for s in pairs(g:stages()) do
				g:add(s:connect('log',self))
			end
			self.added=true
		end
	end
}
