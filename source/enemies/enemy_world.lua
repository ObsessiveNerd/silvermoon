local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "map"

class('EnemyWorld').extends(gfx.sprite)

function EnemyWorld:init(image, x, y, worldIndex)
    self:setImage(image)
    self:add()
    local xPos, yPos = (x - 1) * (TILE_SIZE), (y - 1) * (TILE_SIZE)
    self:setCollideRect(0, 0, TILE_SIZE, TILE_SIZE)
    self:setTag(TAGS.Enemy)
    self:moveTo(xPos, yPos)
    self.worldIndex = worldIndex
end

function EnemyWorld:removeFromWorld()
    table.remove(enemiesList, self.worldIndex)
    self:remove()
end