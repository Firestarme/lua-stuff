local deb = true

local com = require("component")
local ev = require("event")

local mo = com.modem
local gpu = com.gpu

local refIx = {}
local ref = {}
local ply = {}
local pro = {} 

local proF = {}

local w = 64
local h = 10
gpu.setResolution(w,h)

function dprint(s)

  if deb then print(s) end

end

function receive(p)

  if not mo.isOpen(p) then mo.open(p) end
  if not mo.isOpen(7) then mo.open(7) end

  local e,la,ra,po,d,msg,msg2,msg3
  
  while true do

    e,la,ra,po,d,msg,msg2,msg3 = ev.pull("modem_message")
	print("msg Received on port "..po)
    
    if po == 7 then mo.send(ra,8,"ping") print("ping served") end
    if po == p then break end
	
  end
  
  return msg,msg2,msg3

end

function clear()

  gpu.fill(0,0,w+1,h+1," ")

end

function printCol(x,y,t,cw)

  for k,v in pairs(t) do 
    
	local ypos = y+k-1
	
    gpu.set(x,ypos,string.sub(v,0,cw))
	
	if ypos > h then break end
  
  end

end

function printCL(x,y,l)

  for i = y,l do 
  
    gpu.set(x,i,"║")
	
	if i > h then break end
  
  end

end

function Draw()

  if not deb then
  clear()
  printCol(1,1,ref,6)
  printCL(7,1,10)
  printCol(8,1,ply,38)
  printCL(47,1,10)
  printCol(48,1,pro,16)
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
  
  dprint("adding record: "..refIx[r].." : "..ref[rI].." : "..ply[rI])

end

function delRec(r)

  i = refIx[r]
  table.remove(refIx,r)
  
  table.remove(ref,i)
  table.remove(ply,i)
  table.remove(pro,i)
  
  upRefIx()

end

function setPro(r,s)

  pro[refIx[r]] = s

end

function proF.o(r,p)

  addRec(r,p)
  setPro("Order Sent")
  Draw()

end

function proF.r(r,p)

  setPro("Order Received")
  Draw()

end

function proF.l(r,p)

  setPro("Loco Deployed")
  Draw()

end

function proF.d(r,p)

  setPro("Order Dispached")
  Draw()

end

function proF.c(r,p)

  setPro("Order Complete")
  Draw()
  
  delRec(r)

end

Draw()

while true do 

  local r,s,p = receive(51)
  
  proF[s](r,p)

end
