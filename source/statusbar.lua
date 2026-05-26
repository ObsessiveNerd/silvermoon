local gfx <const> = playdate.graphics
local pd <const> = playdate

local maxValue = 100

class('StatusBar').extends(gfx.sprite)

function StatusBar:init(x, y, value, maxValue, icon, xScale)
    self.posX = x
    self.posY = y
    self.value = value
    self.maxValue = maxValue
    self.xScale = xScale or 1
    if icon then
        self.icon = gfx.sprite.new(icon)
        self.icon:moveTo(x - 65 * (xScale or 1), y)
    end
    self:setScale(xScale or 1, 1)
    self:setup()
end

function StatusBar:updateValue(newValue)
    self.value += newValue
    if self.value > self.maxValue then
        self.value = self.maxValue
    end
    if self.value < 0 then
        self.value = 0
    end

    local barImage = gfx.image.new("images/bar_outline")
    gfx.pushContext(barImage)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        local barWidth = (self.value / self.maxValue) * 100
        gfx.fillRect(0, 0, barWidth, 10)
    gfx.popContext()
    self:setImage(barImage)
end

function StatusBar:tearDown()
    if self.icon then
        self.icon:remove()
    end
    self:remove()
end

function StatusBar:setup()
    local barImage = gfx.image.new("images/bar_outline")
    gfx.pushContext(barImage)
    if self.icon then
        self.addSprite(self.icon)
    end
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        local barWidth = (self.value / self.maxValue) * 100
        gfx.fillRect(0, 0, barWidth, 10)
    gfx.popContext()
    self:setImage(barImage)
    self:moveTo(self.posX, self.posY)
    self:add()
end