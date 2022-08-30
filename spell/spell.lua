local modem = require("modem")
local event = require("event")
local serialization = require("serialization")

local discoveredBooksMeta = {}
local boughtWand = {}
local port = 8000
local flg = false

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
        end
    end
end