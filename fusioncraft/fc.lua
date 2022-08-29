local component = require("component")
local sides = require("sides")
local event = require("event")

local interface = component.block_refinedstorage_interface
local redstone = component.redstone
local modem = component.modem

local port = 8888

local function pulse(side)
    redstone.setOutput(side, 15)
    os.sleep(0.1)
    redstone.setOutput(side, 0)
end

modem.open(port)

while true do
    while true do
        if redstone.getInput(sides.down) > 0 then
            pulse(sides.south)
            modem.broadcast(port, "start")
            break
        end
        os.sleep(0.02)
    end

    local _, _, from, _, _, recv = event.pull("modem_message")
    local patterns = interface.getPatterns()
    for i = 1, recv, 1 do
        modem.broadcast(port, i)
        for j = 1, #patterns, 1 do
            interface.scheduleTask(patterns[j], 1)
            os.sleep(6)
            pulse(sides.up)
            os.sleep(6)
        end
        modem.broadcast(port, "end")
    end
    pulse(sides.south)
    os.sleep(1)
    modem.broadcast(port, "complete")
end