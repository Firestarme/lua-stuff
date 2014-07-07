local rside = "south"


com = require("component")
col = require("colors")
s = require("side")
se = require("serialization")
ev = require("event")

local mo = com.modem
local rs = com.redstone
local tm = com.ticketmachine

local queue = {}

function deploy(des)

  tm.createTicket(des)
  rs.setBundledOutput(s[rside],col.white,15)
  
  while not rs.getBundledInput(s[rside],col.magenta,15) do

    os.sleep(2)
  
  end
  
  rs.setBundledOutput(s[rside],col.orange,15)
  os.sleep(2)
  rs.setBundledOutput(s[rside],col.white,0)
  rs.setBundledOutput(s[rside],col.orange,15)
 
end

function getNextOrder(t)

  local v = t[1]
  table.remove(t,1)
  return v
  
end

function addOrder(t,v)

  t[#t+1] = v
  return v	
  
end

function receiveOrder(la,ra,p,d,msg)

  local o = se.unserialize(msg)
  o.addr = ra
  addOrder(queue,se.unserialize(msg))
 
  mo.send(ra,51,o.ref,"r")

end


ev.listen("modem",receiveOrder)

while true do 
  
  if #queue > 0 then
  
    local o = getNextOrder(queue)
	mo.send(o.a,51,o.ref,"p")
	
	deploy(o.des)
	
	mo.send(o.a,51,o.ref,"p")
	
  end

end


