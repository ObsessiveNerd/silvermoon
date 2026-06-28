local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "Corelibs/crank"

import "player"
import "bullet"

class('Reload').extends()

local angle = 0

function Reload:init()
    self.ignoreClose = false
end

function Reload:setup()
    pd.display.setScale(1)
    gfx.setDrawOffset(0, 0)
    self.image = gfx.image.new("sprites/revolver_reload")
    self.revolverSprite = gfx.sprite.new(self.image)
    self.revolverSprite:moveTo(200, 120)
    self.revolverSprite:add()
    self:redrawBullets()
end

function Reload:setupScaled(scale, x, y)
    gfx.setDrawOffset(0, 0)
    self.image = gfx.image.new("sprites/revolver_reload")
    self.revolverSprite = gfx.sprite.new(self.image)
    self.revolverSprite:moveTo(x, y)
    self.revolverSprite:setScale(scale)
    self.revolverSprite:add()
    self:redrawBullets()
end

function Reload:redrawBullets()
    self.image = gfx.image.new("sprites/revolver_reload")
    self.revolverSprite:setImage(self.image)
    self.revolverSprite:setZIndex(1000)
    local bullets = player:getRevolver():getBullets()

    for i = 1, #bullets do
        local bullet = bullets[i]
        if bullet.loaded and not bullet.emptyCasing then
            self:addBullet(i)
        elseif bullet.loaded and bullet.emptyCasing then
            self:spentBullet(i)
        end
    end
    -- pd.display.flush() --temp fix for the reolver. Unsure why the "spent" bullets will sometimes all disappear
end

function Reload:update()
    angle += pd.getCrankTicks(360)
    if(angle < 0) then
        angle = 359.9
    end
    if angle >= 360 then
        angle = 0
    end

    self.revolverSprite:setRotation(angle)

    if pd.buttonJustPressed(pd.kButtonB) and not self.ignoreClose then
        setContext('World')
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        self:loadBullet()
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        local slot = self:getSlotFromAngle()
        player:getRevolver():ejectBullet(slot)
        self:redrawBullets()
    end
end

function Reload:ignoreCloseButton()
    self.ignoreClose = true
end

function Reload:addBullet(bulletSlot)
    local x = 0
    local y = 0
    local bulletRadius = 20

    if bulletSlot == 1 then
        x = 100
        y = 43
    elseif bulletSlot == 2 then
        x = 149
        y = 71
    elseif bulletSlot == 3 then
        x = 149
        y = 129
    elseif bulletSlot == 4 then
        x = 100
        y = 157
    elseif bulletSlot == 5 then
        x = 50
        y = 129
    elseif bulletSlot == 6 then
        x = 51
        y = 71
    else
        return
    end

    player:getRevolver():setIsLoaded(bulletSlot, true) --getBullets()[bulletSlot].loaded = true

    gfx.pushContext(self.image)
        gfx.fillCircleAtPoint(x, y, bulletRadius)
    gfx.popContext()
end

function Reload:spentBullet(bulletSlot)
    local x = 0
    local y = 0
    local bulletRadius = 10

    if bulletSlot == 1 then
        x = 100
        y = 43
    elseif bulletSlot == 2 then
        x = 149
        y = 71
    elseif bulletSlot == 3 then
        x = 149
        y = 129
    elseif bulletSlot == 4 then
        x = 100
        y = 157
    elseif bulletSlot == 5 then
        x = 50
        y = 129
    elseif bulletSlot == 6 then
        x = 51
        y = 71
    else
        return
    end

    gfx.pushContext(self.image)
        gfx.drawCircleAtPoint(x, y, bulletRadius)
    gfx.popContext()
end

function Reload:loadBullet()
    --determine the slot
    local slot = self:getSlotFromAngle()
    local bullet = player:getRevolver():getBulletAt(slot) --bullets[slot]
    if not bullet.loaded then
        self:addBullet(slot)
    end
end

function Reload:getAngleFromSlot(slot)
    if slot == 1 then
        return 0
    elseif slot == 2 then
        return 300
    elseif slot == 3 then
        return 240
    elseif slot == 4 then
        return 180
    elseif slot == 5 then
        return 120
    elseif slot == 6 then
        return 60
    end
end

function Reload:getSlotFromAngle()
    local slot = 1
    print("angle: " .. angle)
    if angle >= 10 and angle <= 92 then
        slot = 6
    elseif angle > 93 and angle <= 149 then
        slot = 5
    elseif angle > 150 and angle <= 209 then
        slot = 4
    elseif angle > 210 and angle <= 250 then
        slot = 3
    elseif angle > 251 and angle <= 340 then
        slot = 2
    elseif angle < 11 and angle >= 340 then
        slot = 1
    end
    return slot
end

function Reload:tearDown()
    currentBulletSlot = self:getSlotFromAngle()
    self.revolverSprite:remove()
end

function Reload:fire(x, y, xDir, yDir)
    local slot = self:getSlotFromAngle()
    local bullet = player:getRevolver():getBulletAt(slot)
    if bullet.loaded and not bullet.emptyCasing then
        Bullet(x, y, xDir, yDir)
        bullet.emptyCasing = true
    end
    slot += 1
    if slot > 6 then
        slot = 1
    end
    angle = self:getAngleFromSlot(slot)
end

function Reload:battleFire()
    local hasBullet = false
    local slot = self:getSlotFromAngle()
    local bullet = player:getRevolver():getBulletAt(slot)
    if bullet.loaded and not bullet.emptyCasing then
        bullet.emptyCasing = true
        hasBullet = true
    end
    slot += 1
    if slot > 6 then
        slot = 1
    end
    angle = self:getAngleFromSlot(slot)
    self.revolverSprite:setRotation(angle)
    self:redrawBullets()
    return hasBullet
end