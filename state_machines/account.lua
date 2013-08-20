local _=require 'leda'

assert(pcall(require,'repl'),"This example requires luarepl, please install it before")

local function load_state()
	if self.file then
		local f=io.open(self.file,"r")
		if f then
			local state=assert(f:read("*a"))
			f:close()
			self=leda.decode(state)
		end
	end
end

local function save_state(file)
	if file then
		self.file=file
		local f=assert(io.open(self.file,"w"))
		assert(f:write(leda.encode(self)))
		f:close()
	end
end

local account=leda.stage{
	init=function () 
		require 'io'
		load_state()
	end,
   handler=function(op,...)
   	local arg={...}
      if op=='withdraw' then
      	local v=tonumber(arg[1])
      	assert(v>0.0,"Must withraw a positive ammount")
         self.balance=self.balance-v
        	save_state()
      elseif op=='deposit' then
      	local v=tonumber(arg[1])
      	assert(v>0.0,"Must deposit a positive ammount")
         self.balance=self.balance+v
        	save_state()
      elseif op=='balance' then
      	leda.send('balance',self.name,self.balance)
      elseif op=='load' then
      	local file=arg[1]
      	load_state(file)
     	else
     		print('Op not found')
      end
   end,
   bind=function(self,out)
   end,
   balance=1000,
   serial=true
}

local account1=leda.stage"Account 1"(account)
account1.balance=5000
account1.file='account1.dat'
local account2=leda.stage"Account 2"(account)
account2.balance=10000
account2.file='account2.dat'

local printer=leda.stage{
	handler=function(name,balance) 
		print("Balance of ",name," is ",balance)
	end,
	serial=true
}

local repl=require'leda.stage.util.repl'

local gr=leda.graph{
   account1:connect('balance',printer),
   account2:connect('balance',printer),
   repl(1)..account1,
   repl(2)..account2,
}

return gr:run()
