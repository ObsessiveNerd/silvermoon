local pd <const> = playdate
local gfx <const> = playdate.graphics

TILE_SIZE = 8

import "CoreLibs/graphics"
import "CoreLibs/sprites"

class('Tile').extends(gfx.sprite)

function Tile:init(x, y, image)
    self.image = image
    self.visible = false
    self.blockSight = false
    self:setImage(self.image)
    local posX, posY = self:tilePosToWorldPos(x, y)
    self:moveTo(posX, posY)
end

function Tile:drawTile()
    gfx.pushContext(self.image)
        gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
        if self.visible then
            gfx.setColor(gfx.kColorWhite)
        elseif self.blocksSight and self.seen then
            gfx.setColor(gfx.kColorWhite)
        else
            gfx.setColor(gfx.kColorBlack)
        end
        gfx.fillRect(0, 0, TILE_SIZE, TILE_SIZE)
    gfx.popContext()
end

function Tile:tilePosToWorldPos(x, y)
    return (x) * TILE_SIZE, (y) * TILE_SIZE
end