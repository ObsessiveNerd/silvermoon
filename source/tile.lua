local pd <const> = playdate
local gfx <const> = playdate.graphics

TILE_SIZE = 8

import "CoreLibs/graphics"
import "CoreLibs/sprites"

class('Tile').extends(gfx.sprite)

local BLACK_TILE = gfx.image.new(TILE_SIZE, TILE_SIZE)

gfx.pushContext(BLACK_TILE)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, TILE_SIZE, TILE_SIZE)
gfx.popContext()

function Tile:init(x, y, image)
    Tile.super.init(self)

    self.tileImage = image

    self.visible = false
    self.blockSight = false
    self.seen = false
    self:setSize(TILE_SIZE, TILE_SIZE)
    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:setImage(BLACK_TILE)
end

function Tile:setVisible(isVisible)
    self.visible = isVisible
    if isVisible then
        self:setImage(self.tileImage)
    else
        self:setImage(BLACK_TILE)
    end
end

function Tile:tilePosToWorldPos(x, y)
    return x, y
end