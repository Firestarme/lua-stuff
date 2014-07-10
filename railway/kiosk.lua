local com = require("component")
local ev = require("event")
local fs = require("filesystem")
local ser = require("serialization")

local gpu = com.gpu
local mo = com.modem
local tm = com.ticketmachine

local w,h = gpu.getResolution()

function nilC(var,desc)

assert(var ~= nil,desc.." is nil")

end

function clear()

  gpu.fill(0,0,w+1,h+1," ")

end

function tbox(x,y,txt)
--[[
╔══════╗
║ test ║
╚══════╝
]]--

  local len
  
  if txt == "◄" or txt == "►" then len = 3
  else len = string.len(txt)+2 end

  gpu.set(x,y-1,"╔"..string.rep("═",len).."╗")
  gpu.set(x,y,"║ "..txt.." ║")
  gpu.set(x,y+1,"╚"..string.rep("═",len).."╝")

end

function s1(dest)

  local y1 = h/2
  local l = string.len(dest)+4
  local bx = (w-l)/2
  local op = 0
  
  nilC(dest,"dest")
  
  clear()
  gpu.set((w/2)-25/2,1,"Please Select Destination")
  tbox(1,y1,"◄")
  tbox(w-4,y1,"►")
  tbox(bx,y1,dest)
  
  local e,addr,x,y,s,p = ev.pull("touch")
  
  if y1-1 < y and y < y1+1 then
   
    if 1 < x and x < 6 then
  
      op = -1
  
    elseif w-4 < x and x < w-1 then
  
      op = 1
  
    elseif bx < x and x < bx+l then
  
      op = "sel"
  
    end
  
  end
  
  error("X: "..x.." Y: "..y)
  
  return p,op
    
end

function s2(ref)

  clear()
  gpu.set(w/2-13,h/2-1,"Your Order Has Been Placed")
  gpu.set(w/2-37/2,h/2,"Track your order on the order screens")
  local str = "your order Refrence is: "..ref
  gpu.set(w/2-string.len(str)/2,h/2+1,str)
  os.sleep(20)

end

function loadDest(path)

  local s = fs.size(path)
  local h = fs.open(path)
  local str = h:read(s)
  
  h:close()
  
  print("loaded: "..str)
  
  return str

end

function receive(p)

  if not mo.isOpen(p) then mo.open(p) end
 
  local e,la,ra,po,d,msg

  while true do

    e,la,ra,po,d,msg = ev.pull("modem_message")
    print("msg Received on port "..po)
  
    if po == p then break end
  
  end
  
  nilC(ra,"R-Address")
  
  return ra,msg

end

function ping(dev)


  mo.broadcast(5,dev)
  local ra,msg = receive(6)
  
  print("Ping Sucessful")
  
   nilC(ra,"P-Adress")
  
  return ra

end

function order(sa,des)
  
  nilC(sa,"Address")
  nilC(des,"Destination")
  
  local ref = math.random(111111,999999)
  mo.send(sa,50,ref,des)
  
  tm.createTicket(des)
  
  return ref

end

local d = ser.unserialize(loadDest("main/dest"))
local di = 1

local sa = ping("depo")

while true do
  
  local dest = d[di]
  p,op = s1(dest)
  
  if op == "sel" then
    
    local r = order(sa,dest)
    op = 0
	s2(r)
  
  end
  
  di = di + op
  
  if di > #d then di = 1 end
  if di < 1 then di = #d end

end
