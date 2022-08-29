local component = require("component")
local sides = require("sides")

local interface = component.block_refinedstorage_interface

local except = {
    "minecraft:enchanted_book",
    "minecraft:potion",
    "ic2:cable",
    "botania:specialflower",
    "rftoolsdim:known_dimlet",
    "industrialforegoing:mob_imprisonment_tool",
    "enderio:item_dark_steel_upgrade",
    "iceandfire:dragon_skull",
    "framppfeil.slashblade:slashbladenamed",
    "ebwizardry:spell_book",
    "ancientspellcraft:ancient_spellcraft_spell_book",
    "refinedstorage:portable_grid",
    "tfspellpack:twilight_spell_book"
}
local limit = 1000000
local flg

while true do
    local items = interface.getItems()
    for i, _ in ipairs(items) do
        if items[i].size > limit then
            interface.extractItem(items[i], items[i] - limit, sides.east)
            print("decreasing : " .. items[i].name)
        elseif items[i].size < limit then
            flg = false
            for j, _ in ipairs(except) do
                if except[j] == items[i].name then
                    flg = true
                    break
                end
            end
            if not flg then
                interface.extractItem(items[i], 64, sides.west)
                print("increasing : " .. items[i].name)
                os.sleep(20)
            end
        end
    end
end