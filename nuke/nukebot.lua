local component = require("component")
local sides = require("sides")

local chunkloader = component.chunkloader
local robot = component.robot
local redstone = component.redstone
local generator = component.generator
local navigation = component.navigation
local invCnt = component.inventory_controller


local farX = 0
local farY = 0
local farZ = 0

local x, y, z, sideX, sideY, sideZ
local fuelSlot = 4
local n
local flg

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

local function moveX()
    n = robot.move(sides.front)
    if n == nil then
        robot.swing(sides.front)
        robot.move(sides.front)
    end
end

local function moveY(side)
    n = robot.move(side)
    if n == nil then
        robot.swing(side)
        robot.move(side)
    end
end

local function moveZ()
    n = robot.move(sides.front)
    if n == nil then
        robot.swing(sides.front)
        robot.move(sides.front)
    end
end

chunkloader.setActive(true)

while true do
    if redstone.getInput(sides.left) > 0 then
        break
    end
    os.sleep(0.02)
end
while true do
    local waypoints = navigation.findWaypoints(navigation.getRange())
    if waypoints.n == 0 then
        print("No Waypoints")
        os.exit(0, true)
    end
    flg = false
    for key, waypoint in pairs(waypoints) do
        if(type(waypoint) == "table" and waypoint.label == "nuke_target") then
            farX = waypoint.position[1]
            farY = waypoint.position[2]
            farZ = waypoint.position[3]
            flg = true
            break
        end
    end
    
    if not flg then
        print("No \"nuke_target\" waypoint")
        os.exit(0, true)
    end
    if math.abs(farX) < 1 then
        sideX = -1
    else
        sideX = farX < 0 and sides.negx or sides.posx
    end
    if math.abs(farY) < 1 then
        sideY = -1
    else
        sideY = farY < 0 and sides.negy or sides.posy
    end
    if math.abs(farZ) < 1 then
        sideZ = -1
    else 
        sideZ = farZ < 0 and sides.negz or sides.posz
    end

    if sideX == -1 and sideY == -1 and sideZ == -1 then
        break
    else
        if sideY > -1 then
            moveY(sideY)
            refillFuel()
        elseif sideX > -1 then
            turnUntil(sideX)
            moveX()
            refillFuel()
        elseif sideZ > -1 then
            turnUntil(sideZ)
            moveZ()
            refillFuel()
        end
    end
end

robot.move(sides.back)
robot.select(1)
robot.place(sides.front)
robot.select(2)
invCnt.dropIntoSlot(sides.front, 2)
robot.select(3)
invCnt.dropIntoSlot(sides.front, 1)

redstone.setOutput(sides.front, 15)
os.sleep(0.02)
redstone.setOutput(sides.front, 0)
os.sleep(15)
chunkloader.setActive(false)