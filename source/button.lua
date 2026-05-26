local gfx <const> = playdate.graphics
local pd <const> = playdate

class('Button').extends(gfx.sprite)
local buttonText = "{{Debug}}"
local action = nil

local textX = 6
local textY = 6

function Button:init(x, y, width, height, text, action)
    self.buttonImage = gfx.image.new(width, height)
    self.buttonText = text
    self.action = action

    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self:setImage(self.buttonImage)
    self:drawButton(self.x, self.y, self.width, self.height, self.buttonText, false)
    self:moveTo(x, y)
    self:add()
end

function Button:setSelected(select)
    self:drawButton(self.x, self.y, self.width, self.height, self.buttonText, select)
end

function Button:drawButton(x, y, w, h, text, selected)
    local radius = 6
    gfx.pushContext(self.buttonImage)
        --Fill Color
        if selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(0, 0, self.width, self.height, radius)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRoundRect(0, 0, self.width, self.height, radius)
            gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
            gfx.setColor(gfx.kColorBlack)
        end
    
        -- Draw border
        gfx.drawRoundRect(0, 0, self.width, self.height, radius) 
        -- Draw text
        gfx.drawTextAligned(text, w/2, h/2 - 8, kTextAlignment.center)
    gfx.popContext()
end

function Button:setText(text)
    self.buttonText = text
    self:drawButton(self.x, self.y, self.width, self.height, self.buttonText, false)
end

function Button:performAction()
    if self.action then
        return self.action()
    end
end