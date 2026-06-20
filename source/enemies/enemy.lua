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
    self.slashImage = gfx.image.new("sprites/TEMP_Slash")
    self.slashSprite = gfx.sprite.new(self.slashImage)
    self.slashSprite:setCenter(0.5, 0.5)
    self.slashSprite:setScale(0.5)
    self.diedListeners = {}
    self.health = health
    self.maxHealth = health
    self.attackSpeed = attackSpeed * 1000
    self.attackPower = attackPower
    self.isShaking = false
    self.dodgedAttack = false
    self.slideSpeed = 20

    self.targetX = 200
    self.targetY = 100

    self:setImage(image)
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

    local pauseForDodge = pd.timer.new(100, 
    function() 
        self:dealDamage()
        self.attackTimer = pd.timer.new(self.attackSpeed, function() self:attack() end)
        self.attackTimer:start()

        
        pd.resetElapsedTime() 
    end)
    pauseForDodge:start()
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
        self:moveBy(100, 0)
    else
        print("attack NOT dodged, dealing damage")
        self.slashSprite:add()
        self.slashSprite:moveTo(200, 200)

        local removeSlash = pd.timer.new(200, function() 
            self.slashSprite:remove()
        end)
        removeSlash:start()
        player:takeDamage(self.attackPower)
    end
    self.dodgedAttack = false
end

function Enemy:update()
    local dt = pd.getElapsedTime()
    self:updateShake(dt)

    if self.isShaking and pd.buttonJustPressed(pd.kButtonDown)  then
        self.dodgedAttack = not self.dodgedAttack --negate this here so that if the button is spammed, it might fuck you up
    end

    local spriteX, spriteY = self:getPosition()
    if (spriteX ~= self.targetX or spriteY ~= self.targetY) and not self.isShaking then
        local moveByX = 1
        if spriteX > self.targetX then
            moveByX = -1
        end
        self:moveBy(moveByX * self.slideSpeed, 0)
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