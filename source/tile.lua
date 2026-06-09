local pd <const> = playdate
local gfx <const> = playdate.graphics

TILE_SIZE = 8

import "CoreLibs/graphics"
import "CoreLibs/sprites"

class('Tile').extends(gfx.sprite)

function Tile:init(x, y, image)
    self.tileImage = image
    self.visible = false
    self.blockSight = false
    self.seen = false
    self:setImage(self.tileImage)
    -- self:setCenter(0, 0)
    -- local posX, posY = self:tilePosToWorldPos(x, y)
    self:moveTo(x, y)
end

function Tile:draw()
    if self.visible then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        self.tileImage:draw(0, 0)
    elseif self.blockSight and self.seen then
        gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, TILE_SIZE, TILE_SIZE)
    else
        gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, TILE_SIZE, TILE_SIZE)
    end
end

function Tile:tilePosToWorldPos(x, y)
    return x, y
end