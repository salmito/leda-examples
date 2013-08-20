local _=require'leda'

--This stage splits a vector in elements
local split=_.stage'Split'{
   handler=function(array)
      for k,v in ipairs(array) do
         leda.push({v})
      end
   end
}

--This stage merges sorted arrays
local merge=_.stage'Merge'{
   handler=function(array1,array2)
      local i1,i2=1,1
      local size1,size2=#array1,#array2
      local t={}
      while i1<=size1 or i2<=size2 do
         if i1>size1 then --array1 finished
            t[#t+1]=array2[i2]
            i2=i2+1
         elseif i2>size2 then --array2 finished
            t[#t+1]=array1[i1]
            i1=i1+1
         else --Still have two arrays
            if array1[i1] < array2[i2] then --array1 is lower
               t[#t+1]=array1[i1]
               i1=i1+1
            else
               t[#t+1]=array2[i2]
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
         leda.push(array,last)
         pair=false
      else
         last=array
         pair=true
      end
   end,
   serial=true
}

--Application graph
local g=leda.graph'MergeSort'{
   split..window,
   window..merge,
   merge'merged'..window,
}

--Test vector
local vector={10,7,9,8,4,5,2,1,3,6,11,15}

--Put the test vector into the split stage's input queue
split:push(vector)
--Set the vector size to the merge stage
merge.size=#vector

--Executes
local result=g:run()--{controller=require'leda.controller.interactive'}

--Print results
for i,v in ipairs(result) do
   print('array['..i..']',v)
end
