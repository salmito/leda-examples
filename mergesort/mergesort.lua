local _=require'leda'

local init=leda.gettime()

local function split(array)
	local len=#array
	assert(len>1,"cannot split a unit vector")
	local splitn=math.ceil(len/2)
	local a1,a2=memarray(splitn),memarray(len-splitn)
	memarray.memcpy(a1:ptr(),array:ptr(),(splitn)*memarray.sizeof('double'))
	memarray.memcpy(a2:ptr(),array:ptr(splitn),(len-splitn)*memarray.sizeof('double'))
	return a1,a2
end

--This stage splits a vector in elements
local split=_.stage'Split'{
	init=function() 
		memarray=require 'leda.memarray'
		require'math'
	end,
   handler=function(array1,array2)
   	local len1=#array1
   	if len1>1 then
   		leda.send('loopback',split(array1))
   	else
   		leda.push(array1)
   	end
   	if array2 then
	   	local len2=#array2
	   	if len2>1 then
	   			leda.send('loopback',split(array2))
	   	else
		   		leda.push(array2)
	     	end
	 	end
   end,
   bind=function(self,out,graph)
   	if not out.loopback then
   		graph:add(self:connect('loopback',self))
   	end
   end
}

--This stage merges sorted arrays
local merge=_.stage'Merge'{
	init=function()
		memarray=require'leda.memarray'
	end,
   handler=function(array1)
   	local array2=leda.debug.wait_event()
      local i1,i2=1,1
      local size1,size2=#array1,#array2
      print("Merge",size1,size2,size1+size2)
      local t=memarray(size1+size2)
      local ti=0
      while i1<=size1 or i2<=size2 do
         if i1>size1 then --array1 finished
         	ti=ti+1
            t[ti]=array2[i2]
            i2=i2+1
         elseif i2>size2 then --array2 finished
           	ti=ti+1
            t[ti]=array1[i1]
            i1=i1+1
         else --Still have two arrays
            if array1[i1] < array2[i2] then --array1 is lower
             	ti=ti+1
               t[ti]=array1[i1]
               i1=i1+1
            else
              	ti=ti+1
               t[ti]=array2[i2]
               i2=i2+1
            end
         end
      end
      if #t==self.size then -- Sort finished
         leda.quit(t) --Stop the pipeline return t to the run function
      else
         leda.send('merged',t)
      end
   end,
   bind=function(self)
      assert(self.size and self.size%2==0,"Size field must have the array size and must be even")
   end
}

--This stage is a window of size 2, it accumulates events and passes two by two
local window=_.stage'Window'{
   handler=function(array)
      if pair==true then
	   	print("Emparelhou",#array,#last,#array+#last)
         leda.push(array,last)
         pair=false
      else
        	print('recebeu',#array)
         last=array
         pair=true
      end
   end,
   last_size=0,
   serial=true
}

--Application graph
local g=leda.graph'MergeSort'{
   split..merge,
   --window..merge,
   merge'merged'..merge,
}

--Test vector
local vector=vector or {10,7,9,8,4,5,2,1,3,6,11,15}
local v=require 'leda.memarray'(#vector)
for i=1,#vector do
	v[i]=vector[i]
end

--Put the test vector into the split stage's input queue
split:push(v)
--Set the vector size to the merge stage
merge.size=#vector

--Executes
g:part(g:all()):map('localhost')
--g:plot()
local result=g:run()--{controller=require"leda.controller.http"}--{controller=require'leda.controller.interactive'}

--Print results
for i=1,#result do
   print('array['..i..']',result[i])
end
