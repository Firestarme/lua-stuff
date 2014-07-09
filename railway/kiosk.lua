local com = require("component")
local ev = require("event")
local fs = require("filesystem")

local gpu = com.gpu

local w,h = gpu.getResolution()

function clear()

  gpu.fill(0,0,w,h," ")

end

function tbox(x,y,txt)
--[[
╔══════╗
║ test ║
╚══════╝
]]--

  gpu.set(x,y-1,"╔"..string.rep("═",string.len(txt)+2).."╗")
  gpu.set(x,y,"║ "..txt.." ║")
  gpu.set(x,y+1,"╚"..string.rep("═",string.len(txt)+2).."╝")

end

function s1(dest)

  local y1 = h/2
  local bl = (string.len(dest)+4)/2
  local bx = w/2 - blim
  local op
  
  clear()
  gpu.set((w/2)-25,1,"Please Select Destination")
  tbox(0,y1,"◄")
  tbox(w-5,y1,"►")
  tbox(bx,y1,dest)
  
  local e,addr,x,y,s,p = ev.pull("touch")
  
  if y1-1 < y and y < y1+1 then
   
    if 0 < x and x < 5 then
  
      op = -1
  
    elseif w-5 < x and x < w then
  
      op = +1
  
    elseif bx-bl < x and x < bx+bl
  
      op = 0
  
    end
  
  end
  
  return p,op
    
end

function loadDest()

  local s = fs.size()
  local h = fs.open("dest")
  local str = h:read(s)
  
  h:close()
  
  return str

end

local d = load

while true do

  s1()
  

end
