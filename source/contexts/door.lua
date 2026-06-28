import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd = playdate
local gfx = playdate.graphics

class('Door').extends()

function Door:init()
    self.x = 325 --not sure why I have to use these values
    self.y = 180

    self.image = gfx.image.new("sprites/temp-door")
    self.sprite = gfx.sprite.new(self.image)

    self.w, self.h = self.image:getSize()
    self.crankSpeed = 0.5
end

function Door:setup()
    pd.display.setScale(1)
    self.angle = 0
    self.sprite:moveTo(self.x + (self.w/2), self.y)
    self.sprite:setCenter(1, 0.5) -- right hinge
    self.sprite:add()
end

function Door:update()
    local crank = playdate.getCrankChange()

    self.angle += crank * self.crankSpeed
    self.angle = math.max(0, math.min(90, self.angle))

    self:render()

    if pd.buttonJustPressed(pd.kButtonB) then
        setContext('World')
    end
end

function Door:render()
    local angle = math.rad(self.angle)
    local sx = math.max(0.05, math.cos(angle))

    local img = self.image:scaledImage(sx, 1)

    self.sprite:setImage(img)
    self.sprite:moveTo(self.x + (self.w/2), self.y)
    self.sprite:setCenter(1, 0.5)
end

function Door:tearDown()
    self.sprite:remove()
end

--Amusing
-- function Door:render()

--     local angle = math.rad(self.angle)

--     local sx = math.max(0.05, math.cos(angle))
--     local open = math.sin(angle)

--     local img = gfx.image.new(self.w, self.h)

--     gfx.pushContext(img)

--         -- draw scaled base
--         self.image:drawScaled(0, 0, sx, 1)

--         -- fake perspective: dark + slight offset overlay
--         gfx.setColor(gfx.kColorBlack)
--         gfx.setDitherPattern(0.3, gfx.image.kDitherTypeBayer2x2)

--         local shadowWidth = (1 - sx) * self.w

--         gfx.fillRect(0, 0, shadowWidth, self.h)

--     gfx.popContext()

--     self:setImage(img)
--     self:setCenter(1, 0.5)
--     self:moveTo(self.x, self.y)
-- end