local component = require("component")
local event = require("event")
local serialization = require("serialization")
local sides = require("sides")

local trading = component.trading
local robot = component.robot
local item = {type = nil, value = nil}
local modem = component.modem

local invCnt = component.inventory_controller
local generator = component.generator

local port = 8000

local function trade(type, value, t)
    local remain = {}
    local stack

    item["type"] = type
    item["value"] = value
    modem.broadcast(port, serialization.serialize(item))
    local _, _, from, _, _, recv = event.pull("modem_message")
    if recv == "notfound" then
        t.trade()
        robot.select(6)
        robot.turn(true)
        robot.turn(true)
        invCnt.dropIntoSlot(sides.front, 1)
        robot.turn(false)
        robot.turn(false)

        for i = 1, 5, 1 do
            stack = invCnt.getStackInInternalSlot(i)
            table.insert(remain, stack)
        end
        modem.broadcast(port, serialization.serialize(remain))
        os.sleep(2)
        robot.turn(false)
        for i = 1, 5, 1 do
            robot.select(i)
            invCnt.suckFromSlot(sides.front, i)
        end
        robot.turn(true)
        os.sleep(1)
    end
end

modem.open(port)
while true do
    local trades = trading.getTrades()
    for key, tr in pairs(trades) do
        if type(tr) == "table" then
            local output = tr.getOutput()
            if output ~= nil then
                if output.name == "ebwizardry:spell_book" then
                    trade("book", output.damage, tr)
                elseif string.find(output.name, "master") ~= nil then
                    trade("wand", output.name, tr)
                end
            end
        end
    end
    if generator.count() < 64 then
        robot.select(5)
        generator.insert(64 - generator.count())
    end
    robot.swing(sides.front)
    os.sleep(2)
end