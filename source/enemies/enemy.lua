local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "statusBar"

class('Enemy').extends(gfx.sprite)

local shakeTime = 0
local shakeDuration = 50  -- ms
local shakeMagnitude = 5  -- pixels (keep small for subtle effect)

function Enemy:init(image, health, attackSpeed, attackPower)
    self.diedListeners = {}
    self.health = health
    self.maxHealth = health
    self.attackSpeed = attackSpeed * 1000
    self.attackPower = attackPower
    self.isShaking = false
    self.dodgedAttack = false
    self:setImage(image)
    -- self:setImageDrawMode(gfx.kDrawModeWhiteTransparent)
    self:moveTo(200, 100)
    self:add()

    self.healthBar = StatusBar(200, 20, health, health, nil)
    self.originalX, self.originalY = self:getPosition()

    self.attackTimer = pd.timer.new(attackSpeed * 1000, function() self:attack() end)
    self.attackTimer:start()
end

function Enemy:addDiedListener(listener)
    table.insert(self.diedListeners, listener)
end

function Enemy:startShake()
    print("starting shake")
    shakeTime = shakeDuration
    self.isShaking = true
end

function Enemy:endShake()
    shakeTime = 0
    self.isShaking = false
    self:moveTo(self.originalX, self.originalY)
    self.attackTimer = pd.timer.new(self.attackSpeed, function() self:attack() end)
    self.attackTimer:start()
    self:dealDamage()
    pd.resetElapsedTime()
end

function Enemy:updateShake(dt)
    if shakeTime > 0 then
        shakeTime -= dt
        local offsetX = math.random(-shakeMagnitude, shakeMagnitude)
        local offsetY = math.random(-shakeMagnitude, shakeMagnitude)
        self:moveTo(self.originalX + offsetX, self.originalY + offsetY)
    elseif shakeTime <= 0 then
        if self.isShaking then
            self:endShake()
        end
    end
end

function Enemy:attack()
    self:startShake()
end

function Enemy:dealDamage()
    if self.dodgedAttack then
        print("Attack dodged!")
    else
        print("attack NOT dodged, dealing damage")
        -- player:takeDamage(self.attackPower)
    end
    self.dodgedAttack = false
end

function Enemy:update()
    local dt = pd.getElapsedTime()
    self:updateShake(dt)

    if self.isShaking and pd.buttonJustPressed(pd.kButtonDown)  then
        self.dodgedAttack = true
    end

end

function Enemy:takeDamage(damage)
    self.health -= damage
    self.healthBar:updateValue(-damage)
    if self.health <= 0 then
        self:remove()
        self.healthBar:tearDown()
        for _, listener in ipairs(self.diedListeners) do
            listener()
        end
    end
end

function Enemy:tearDown()
    self:remove()
    self.healthBar:tearDown()
    self.attackTimer:remove()
end