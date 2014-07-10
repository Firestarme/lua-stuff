local rside = "south"


com = require("component")
c = require("colors")
si = require("sides")
se = require("serialization")
ev = require("event")

local mo = com.modem
local rs = com.redstone
local tm = com.ticketmachine

local s = si[rside]

function pulse(s,c,d)

	rs.setBundledOutput(s,c,15)
	os.sleep(d)
	rs.setBundledOutput(s,c,0)

end

function wait(s,c,v,d)

  while rs.getBundledInput(s,c) ~= v do

    os.sleep(d)
  
  end

end

function deployLoco()

  pulse(s,c.lightblue,2)
  wait(s,c.yellow,15,5)
  pulse(s,c.orange,2)

end


function deploy(des)

  tm.createTicket(des)
  
  pulse(s,c.white,2)
  wait(s,c.magenta,15,5)
  pulse(s,c.orange,2)
 
end

function receive(p)

  if not mo.isOpen(p) then mo.open(p) end
  if not mo.isOpen(5) then mo.open(5) end

  while p ~= po do

    local ev,la,ra,po,d,msg,msg2 = ev.pull("modem_message")
    
    if po == 5 then mo.send(ra,6,"ping") print("ping served") end
    
  end
  
  return ra,msg,msg2

end


function receiveOrder()

  local ra,ref,msg = receive(50)
  
  mo.send(ra,51,ref,"r")
  
  return ra,ref,msg
  
end

mo.open(50)

while true do 
  
  local ra,ref,o = receiveOrder()
  
  print("order received :"..ref.." - "..o)
  mo.send(ra,51,ref,"r")
  
  deployLoco()
  
  print("loco deployed :"..ref)
  mo.send(ra,51,ref,"l")
  
  deploy(o)
	
  print("order deployed :"..ref)
  mo.send(ra,51,ref,"d")

end


