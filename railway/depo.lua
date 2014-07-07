local rside = "south"


com = require("component")
col = require("colors")
s = require("sides")
se = require("serialization")
ev = require("event")

local mo = com.modem
local rs = com.redstone
local tm = com.ticketmachine

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


function receiveOrder()

  local ev,la,ra,p,d,ref,msg = os.pullEvent("modem_message")
  
  mo.send(ra,51,ref,"r")
  
  return ra,ref,msg
  
end

while true do 
  
  local ra,ref,o = receiveOrder()
  mo.send(ra,51,ref,"p")
	
  deploy(o)
	
  mo.send(ra,51,ref,"p")

end


