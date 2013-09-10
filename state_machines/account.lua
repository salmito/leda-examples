local _=require 'leda'

assert(pcall(require,'repl'),"This example requires luarepl, please install it before")

local function load_state(file)
	if file then
		self.file=file
	end
	if self.file then
		local f=io.open(self.file,"r")
		if f then
			local state=assert(f:read("*a"))
			f:close()
			self=leda.decode(state)
			if leda.output[log] then
				leda.send('log',self.name..": Read "..#state.." bytes from file "..self.file)
			end
		end
	end
end

local function save_state(file)
	self.file=file or self.file
	if self.file then
		local f=assert(io.open(self.file,"w"))
		local state=leda.encode(self)
		assert(f:write(state))
		f:close()
		if leda.output[log] then
			leda.send('log',self.name..": Write "..#state.." bytes to file "..self.file)
		end
	end
end

local function withdraw_f(v)
     	assert(v>0.0,"Must withdraw a positive ammount")
      self.balance=self.balance-v
      leda.send('log',"Withdraw  "..v.." from account "..self.name)
     	save_state()
end

local function deposit_f(v)
    	assert(v>0.0,"Must deposit a positive ammount")
      self.balance=self.balance+v
     	save_state()
      leda.send('log',"Deposit  "..v.." to account "..self.name)
end

local function balance_f()
      	leda.send('balance',"Balance of ",self.name,'is',self.balance)
end

local account=leda.stage{
	init=function () 
		require 'io'
		--defining global functions for each 'op'   end,
   	withdraw=withdraw_f
   	deposit=deposit_f
   	balance=balance_f
   	load=load_state
   	save=save_state
   	--Loading initial state
		load_state()
	end,
   handler=function(op,...)
   	
   	if op and type(_G[op])=='function' then
   		_G[op](...)
   	else
	      leda.send('log',self.name..": Op "..tostring(op).." not defined")
	   end
   end,
   bind=function(self,out)
   end,
   balance=1000,
   serial=true
}

local account1=leda.stage"A1"(account)
account1.balance=5000
account1.file='account1.dat'
local account2=leda.stage"A2"(account)
account2.balance=10000
account2.file='account2.dat'

local printer=leda.stage{
	handler=function(...) 
		print(...)
	end,
	serial=true
}

local gr=leda.graph{
   account1:connect('balance',printer),
   account2:connect('balance',printer),
   account1:connect('log',printer),
   account2:connect('log',printer),
	require'leda.stage.util.repl'
}

--gr:plot()

print([[Try:
	leda.send('A1','balance')
	leda.send('A1','deposit',1000)
	leda.send('A2','withdraw',4000)
	leda.send('A2','balance')
	leda.quit() --> to exit
]])

return gr:run()
