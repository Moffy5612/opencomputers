local component = require("component")
local sides = require("sides")

local chunkloader = component.chunkloader
local robot = component.robot
local redstone = component.redstone
local generator = component.generator
local navigation = component.navigation
local invCnt = component.inventory_controller

local mapSize = 128
local targetX = 0
local targetY = 0
local targetZ = 0
local x, y, z, sideX, sideY, sideZ
local fuelSlot = 4


local function refillFuel()
    robot.select(fuelSlot)
    if generator.count() < 64 then
        generator.insert(64 - generator.count())
        if robot.count() < 1 then
            fuelSlot = fuelSlot + 1
        end
    end
end

local function turnUntil(side)
    while side ~= navigation.getFacing() do
        robot.turn(true)
    end
end

local function toRelative(position)
    position = position % mapSize
    if position > mapSize / 2 then
        position = mapSize / 2 - position
    end
    return position
end

chunkloader.setActive(true)

while true do
    if redstone.getInput(sides.left) > 0 then
        break
    end
    os.sleep(0.02)
end

targetX = toRelative(targetX) + 1
targetY = targetY + 1
targetZ = toRelative(targetZ) + 1

while true do
    x, y, z = navigation.getPosition()
    if math.abs(x - targetX) < 1 then
        sideX = -1
    else
        sideX = x > targetX and sides.negx or sides.posx
    end
    if math.abs(y - targetY) < 1 then
        sideY = -1
    else
        sideY = y > targetY and sides.negy or sides.posy
    end
    if math.abs(z - targetZ) < 1 then
        sideZ = -1
    else 
        sideZ = z > targetZ and sides.negz or sides.posz
    end

    if sideX == -1 and sideY == -1 and sideZ == -1 then
        break
    else
        if sideY > -1 then
            robot.move(sideY)
            refillFuel()
        elseif sideX > -1 then
            turnUntil(sideX)
            robot.move(sides.front)
            refillFuel()
        elseif sideZ > -1 then
            turnUntil(sideZ)
            robot.move(sides.front)
            refillFuel()
        end
    end
end

robot.move(sides.back)
robot.select(1)
robot.use(sides.front)
robot.select(2)
invCnt.dropIntoSlot(sides.front, 2)
robot.select(3)
invCnt.dropIntoSlot(sides.front, 1)

redstone.setOutput(sides.front, 15)
os.sleep(0.02)
redstone.setOutput(sides.front, 0)
os.sleep(15)
chunkloader.setActive(false)