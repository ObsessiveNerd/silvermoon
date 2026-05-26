local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

class('Bullet').extends(gfx.sprite)

local bulletSpeed = 5

function Bullet:init(x, y, dirX, dirY)
    local image = gfx.image.new("sprites/bullet")
    self:setImage(image)
    self:moveTo(x, y)
    self.dirX = dirX
    self.dirY = dirY

    if dirX ~= 0 then
        self:setRotation(90)
    end

    pd.timer.performAfterDelay(1000, function() self:remove() end)
    self:add()
end

function Bullet:update()
    self:moveBy(self.dirX * bulletSpeed, self.dirY * bulletSpeed)
end