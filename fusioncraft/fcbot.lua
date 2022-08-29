local component = require("component")
local sides = require("sides")
local event = require("event")

local modem = component.modem
local invCnt = component.inventory_controller
local me = component.robot

local port = 8888
local keyCount = 0

modem.open(port)

while true do
    local _, _, from, _, _, recv = event.pull("modem_message")
    if recv == "start" then
        keyCount = 0
        me.select(1)
        for i = 1, 27, 1 do
            invCnt.suckFromSlot(sides.front, i)
        end
        for i = 1, 16, 1 do
            me.select(i)
            local item = invCnt.getStackInInternalSlot(i)
            if item then
                local name = item.name
                if name == "draconicevolusion:tool_upgrade" then
                    keyCount = keyCount + 1
                else
                    invCnt.dropIntoSlot(sides.down, 1)
                end
            end
        end
        modem.broadcast(port, keyCount)
    elseif recv == "end" then
        me.turn(true)
        invCnt.suckFromSlot(sides.front, 1)
        me.turn(false)
    elseif recv == "complete" then
        for i = 1, 16, 1 do
            me.select(i)
            invCnt.dropIntoSlot(sides.front, i)
            os.sleep(0.2)
        end
    elseif recv >= 1 and recv <= 5 then
        me.select(recv)
        me.turn(true)
        invCnt.dropIntoSlot(sides.front, 1)
        me.turn(false)
    end
end