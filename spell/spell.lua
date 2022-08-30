local component = require("component")
local event = require("event")
local serialization = require("serialization")
local sides = require("sides")

local interface = component.block_refinedstorage_interface
local modem = component.modem

local discoveredBooksMeta = {}
local boughtWand = {}
local port = 8000
local flg = false

local function refill()
    local _, _, from, _, _, recv = event.pull("modem_message")
    local remain = serialization.unserialize(recv)
    for key, value in pairs(remain) do
        if value.size < 64 then
            interface.extractItem(value, 64 - value.size, sides.east)
        end
    end
end

modem.open(port)
while true do
    local _, _, from, _, _, recv = event.pull("modem_message")
    local item = serialization.unserialize(recv)
    if item["type"] == "book" then
        flg = false
        for key, value in pairs(discoveredBooksMeta) do
            if item["value"] == value then
                flg = true
                break
            end
        end
        if flg then
            modem.broadcast(port, "found")
        else
            modem.broadcast(port, "notfound")
            table.insert(discoveredBooksMeta, item["value"])
            refill()
        end

    elseif item["type"] == "wand" then
        flg = false
        for key, value in pairs(boughtWand) do
            if item["value"] == value then
                flg = true
                break
            end
        end
        if flg then
            modem.broadcast(port, "found")
        else
            modem.broadcast(port, "notfound")
            table.insert(boughtWand, item["value"])
            refill()
        end
    end
end