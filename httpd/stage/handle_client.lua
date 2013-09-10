local _=require 'leda'
local stage={}

local function strsplit (str)
	local words = {}
	
	for w in string.gmatch (str, "%S+") do
		table.insert (words, w)
	end
	
	return words
end

local function read_headers(sock,req)
	local headers = {}
	local prevval, prevname
	
	while 1 do
		local l,err = sock:receive()
		if (not l or l == "") then
			req.headers = headers
			return
		end
		local _,_, name, value = string.find (l, "^([^: ]+)%s*:%s*(.+)")
		name = string.lower (name or '')
		if name then
			prevval = headers [name]
			if prevval then
				value = prevval .. "," .. value
			end
			headers [name] = value
			prevname = name
		elseif prevname then
			headers [prevname] = headers [prevname] .. l
		end
	end
end

local function parse_url (req)
	local def_url = string.format ("http://%s%s", req.headers.host or "", req.cmd_url or "")
	
	req.parsed_url = url.parse (def_url or '')
	req.parsed_url.port = req.parsed_url.port or req.port
	req.built_url = url.build (req.parsed_url)
	req.relpath = url.unescape (req.parsed_url.path)
end

stage.handler=function(req)
	local err
	local cmdline, err = req.sock:receive()
	if not cmdline then
		req.sock:close()
		--print("Error receiving from client: ",err)
		return
	end
	req.cmd_mth, req.cmd_url, req.cmd_version = unpack (strsplit (cmdline))
	read_headers(req.sock,req)
	parse_url (req)
	if req.relpath=="/" then
      req.relpath="/index.html"
   end
   if string.find (req.relpath,"+*.lua$") or string.find (req.relpath,"+*.lp$") then
   	leda.send("dynamic",req)
   else
   	leda.send("static",req)
   end
end

stage.init=function ()
	require 'string'
	require 'table'
	url=require "socket.url"
end

function stage:bind(output)
	--assert(output.request,"Request port must be connected for stage '"..tostring(self).."'")
end

stage.name="Handle request"

return _.stage(stage)
