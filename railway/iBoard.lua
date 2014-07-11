local com = require("component")
local ev = require("event")

local mo = com.modem
local gpu = com.gpu

local refIx = {}
local ref = {}
local ply = {}
local pro = {} 

local proPr = {o = "Order Sent",r = "Order Received",l = "Loco Deployed",d = "Order Dispatched"}

local w = 64
local h = 10
gpu.setResolution(w,h)

function receive(p)

  if not mo.isOpen(p) then mo.open(p) end
  if not mo.isOpen(7) then mo.open(7) end

  local e,la,ra,po,d,msg,msg2
  
  while true do

    e,la,ra,po,d,msg,msg2 = ev.pull("modem_message")
    
    if po == 7 then mo.send(ra,8,"ping") print("ping served") end
    if po == p then break end
	
  end
  
  return ra,msg,msg2,msg3

end

function clear()

  gpu.fill(0,0,w+1,h+1," ")

end

function printCol(x,y,t)

  for k,v in pairs(t) do 
    
	local ypos = y+k-1
	
    gpu.set(x,ypos,v)
	
	if ypos > h then break end
  
  end

end

function printCL(x,y,l)

  for i = y,l do 
  
    gpu.set(x,i,"║")
	
	if i > h then break end
  
  end

end

function upRefIx()

  for k,v in pairs(ref) do
  
    refIx[v] = k
  
  end

end

function addRec(r,p)

  local rI = #ref+1

  table.insert(ref,rI,r)
  table.insert(ply,#ply+1,p)
  
  refIx[r] = rI

end

function delRec(r)

  i = refIx[r]
  table.remove(refIx,r)
  
  table.remove(ref,1)
  table.remove(ply,1)
  table.remove(pro,1)
  
  upRefIx()

end

while true do 

  receive


end
