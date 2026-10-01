import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "map"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('DoorWorld').extends(gfx.sprite)

function DoorWorld:init(entity)
    self.locked = true;
    self.isOpen = false;

    self:setTag(TAGS.Door)
    self:setImage(GLOBAL_MAP:getEntityImage(entity))
    local px, py = GLOBAL_MAP:tileToWorld(entity.gridX, entity.gridY)
    self:setCollideRect(0, 0, entity.width * ZOOM, entity.height * ZOOM)
    self:setCenter(0, 0)
    self:moveTo(px, py)
    self:setScale(ZOOM)
    self:setZIndex(1000)
    self:add()
end

function DoorWorld:tryUnlock()
    if player.inventory.key > 0 then
        player.inventory.key -= 1
        self.locked = false
        print("Door unlocked!")
    else
        print("You need a key to unlock this door.")
    end
end

function DoorWorld:open()
    if self.locked then
        print("Door is locked!")
        return
    end
    GLOBAL_MAP:removeEntity(self)
    self:remove()
end