local here = "spawn"

local com = require("component")
local ev = require("event")
local fs = require("filesystem")
local ser = require("serialization")
local uc = require("unicode")

local gpu = com.gpu
local mo = com.modem
local tm = com.ticketmachine

function nilC(var,desc)

assert(var ~= nil,desc.." is nil")

end

function clear(w,h)

  gpu.fill(0,0,w+1,h+1," ")

end

function tbox(x,y,txt)
--[[
╔══════╗
║ test ║
╚══════╝
]]--

  local len = uc.len(txt)+2

  gpu.set(x,y-1,"╔"..string.rep("═",len).."╗")
  gpu.set(x,y,"║ "..txt.." ║")
  gpu.set(x,y+1,"╚"..string.rep("═",len).."╝")

end

function s1(dest)

  local w = 25 
  local h = 8
  gpu.setResolution(w,h)
  
  local y1 = h/2
  local l = uc.len(dest)+4
  local bx = (w-l)/2
  local op = 0
  
  nilC(dest,"dest")
  
  clear(w,h)
  gpu.set((w/2)-11,1,"Please Select Destination")
  tbox(1,y1,"◄")
  tbox(w-4,y1,"►")
  tbox(bx,y1,dest)
  
  local e,addr,x,y,s,p = ev.pull("touch")
  
  if y1-1 <= y and y <= y1+1 then
   
    if 1 <= x and x <= 6 then
  
      op = -1
  
    elseif w-4 <= x and x <= w-1 then
  
      op = 1
  
    elseif bx <= x and x <= bx+l then
  
      op = "sel"
  
    end
  
  end
  
  return p,op
    
end

function s2(ref)

  local w = 50
  local h = 16
  gpu.setResolution(w,h)
  
  clear(w,h)
  
  
  gpu.set(w/2-13,h/2-1,"Your Order Has Been Placed")
  gpu.set(w/2-37/2,h/2,"Track your order on the order screens")
  local str = "your order Refrence is: "..ref
  gpu.set(w/2-string.len(str)/2,h/2+1,str)
  gpu.set(w/2-12,h/2+3,"Collect Your Ticket Below")
  gpu.set(w/2-2,h/2+5,[[_||_]])
  gpu.set(w/2-3,h/2+6,[[\    /]])
  gpu.set(w/2-2,h/2+7,[[\  /]])
  gpu.set(w/2-1,h/2+8,[[\/]])
  
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

function ping(p,dev)
  
  print("Pinging "..dev.." on port "..p)
  
  mo.broadcast(p,dev)
  local ra,msg = receive(p+1)
  
  print("Ping Sucessful")
  
   nilC(ra,"P-Adress")
  
  return ra

end

function order(sa,reta,des)
  
  nilC(sa,"Address")
  nilC(des,"Destination")
  
  local ref = math.random(111111,999999)
  mo.send(sa,50,reta,ref,here)
  mo.send(reta,51,ref,"o",p)
  
  tm.createTicket(des)
  
  return ref

end

local d = ser.unserialize(loadDest("main/dest"))
local di = 1

local sa = ping(5,"depo")
local reta = ping(7,"iBoard")

while true do
  
  local dest = d[di]
  p,op = s1(dest)
  
  if op == "sel" then
    
    local r = order(sa,reta,dest)
    op = 0
	s2(r)
  
  end
  
  di = di + op
  
  if di > #d then di = 1 end
  if di < 1 then di = #d end

end
