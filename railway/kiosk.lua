local com = require("component")
local ev = require("event")
local fs = require("filesystem")

local gpu = com.gpu
local mo = com.modem
local tm = com.ticketmachine

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
  gpu.set((w/2)-25/2,1,"Please Select Destination")
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

function s2()

  clear()
  gpu.set(w/2-13,h/2+1,"Your Order Has Been Placed")
  gpu.set(w/2-37/2,h/2-1,"Track your order on the order screens")
  os.sleep(10)

end

function loadDest()

  local s = fs.size()
  local h = fs.open("dest")
  local str = h:read(s)
  
  h:close()
  
  return str

end

function receive(p)

 if not mo.isOpen(p) then mo.open(p) end

  while p ~= po do

    local ev,la,ra,po,d,msg = ev.pull("modem_message")
	
  end
  
  return ra,msg

end

function ping(dev)


  mo.broadcast(5,dev)
  local ra = receive(6)
  
  return ra

end

function order(sa,des)

  local ref = math.random(111111,999999)
  
  mo.send(sa,50,ref,des)
  
  tm.createTicket(des)

end

local d = loadDest()
local di = 1

local sa = ping("depo")

while true do

  p,op = s1()
  
  if op == 0 then
    
	order()
  
  end
  
  di = di + op
  
  if di > #d then di = 1 end
  if di < 1 then di = #d end

end
