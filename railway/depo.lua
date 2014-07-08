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
  pulse(s,c.lime,2)

end


function deploy(des)

  tm.createTicket(des)
  
  pulse(s,c.white,2)
  wait(s,c.purple,15,5)
  pulse(s,c.lime,1)
 
end


function receiveOrder()

  local ev,la,ra,p,d,ref,msg = ev.pull("modem_message")
  
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


