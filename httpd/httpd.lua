local _=require 'leda'
assert(pcall(require,arg[1] or 'config'),"Missing config file. Use "..arg[-1].." "..arg[0].." <config_path_without_.lua>")
conf=require(arg[1] or 'config')
assert(conf.port,"Invalid configuration, server port undefined")

local server=require 'stage.server'
local handle=require 'stage.handle_client'
--local cache=require 'stage.cache'

--local debug=require 'stage.debug'

local send_file=require 'stage.send_file'
local send_buffer=require 'stage.send_buffer'
local run_script=require 'stage.run_script'
local close=require 'stage.close'
local log=require 'stage.log'

send_file.directory=conf.webroot
run_script.directory=conf.webroot
--cache.size=conf.cache_size
server.port=conf.port

local httpd=leda.graph "HTTP Server" {
	leda.connect(server,"client",handle,"local"),
	leda.connect(handle,"static",send_file,"local"),
--	leda.connect(handle,"static",cache,"local"),
--	leda.connect(cache,"miss",send_file,"local"),
--	leda.connect(cache,"hit",send_buffer,"local"),
	leda.connect(send_buffer,"close",close,"local"),
	leda.connect(handle,"dynamic",run_script,"local"),
	leda.connect(run_script,"close",close,"local"),
	leda.connect(send_file,"close",close,"local"),
--	leda.connect(send_file,"add",cache,"local"),
	leda.connect(close,"client",handle,"local"),
	log, --log stage connects itself with other stages in the graph
}
--httpd:plot("g.png")

local controller=nil
local mapar=leda.scheduler.cpu()*4098
if conf.controller_port then
	controller=require 'leda.controller.http'.get(leda.scheduler.cpu(),conf.controller_port,conf.controller_user,conf.controller_pass)
else
	controller=require 'leda.controller.interactive'.get(leda.kernel.cpu())
end

return httpd:run{controller=controller,mapar=maxpar}
