import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "contexts/reload"
import "revolver"
import "map"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends()

currentDirection = 'Down'

function Player:init(revolver)
    self.revolver = Revolver()
    playerImage = gfx.image.new("sprites/proto1")
    self.viewRadius = 4
    self.tileX = 5
    self.tileY = 5
    self.speed = 3
    self.maxHealth = 100
    self.health = 100

    self.playerSprite = gfx.sprite.new(playerImage)
    self.playerSprite:setTag(TAGS.Player)
    self.playerSprite:setZIndex(1000)
    self.playerSprite:setScale(ZOOM)
    self.playerSprite:setCollideRect(0, 0, TILE_SIZE, TILE_SIZE)

end

function Player:add()
    self.playerSprite:add()
    local posX, posY = (self.tileX - 1) * (TILE_SIZE * ZOOM), (self.tileY - 1) * (TILE_SIZE * ZOOM)
    self.playerSprite:moveTo(posX, posY)
    self:updateCamera(posX, posY)    
    computeFOV(self.tileX, self.tileY, self.viewRadius)
end

function Player:updateCamera(x, y)
    gfx.setDrawOffset(
            -x + 200 / ZOOM,
            -y + 120 / ZOOM
        )
end

function Player:getPosition()
    return self.playerSprite:getPosition()
end

function Player:update()
    local needsUpdate = false
    local moveX = 0
    local moveY = 0
    
    if pd.buttonIsPressed(pd.kButtonUp) then
        moveY = -1
        needsUpdate = true
        currentDirection = 'Up'
    elseif pd.buttonIsPressed(pd.kButtonDown) then
        moveY = 1
        needsUpdate = true
        currentDirection = 'Down'
    end
    if pd.buttonIsPressed(pd.kButtonLeft) then
        moveX = -1
        needsUpdate = true
        currentDirection = 'Left'
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        moveX = 1
        needsUpdate = true
        currentDirection = 'Right'
    end
    
    if needsUpdate then
        local x, y = self.playerSprite:getPosition()
        local goalX = x + moveX * self.speed
        local goalY = y + moveY * self.speed
        
        local actualX, actualY, collisions, numberOfCollisions = self.playerSprite:moveWithCollisions(goalX, goalY)
        for i = 1, numberOfCollisions do
            if collisions[i].other:getTag() == TAGS.Enemy then
                collisions[i].other:removeFromWorld()
                setContext('Battle')
                return
            end
        end

        local tx, ty = GLOBAL_MAP:getTilePosition(x, y)
        if tx ~= self.tileX or ty ~= self.tileY then
            self.tileX = tx
            self.tileY = ty
            computeFOV(self.tileX, self.tileY, self.viewRadius)
        end
        self:updateCamera(x, y)
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        local x, y = self.playerSprite:getPosition()
        local xDir = 0
        local yDir = 0

        if currentDirection == 'Up' then
            yDir = -1
        elseif currentDirection == 'Down' then
            yDir = 1
        elseif currentDirection == 'Left' then
            xDir = -1
        elseif currentDirection == 'Right' then
            xDir = 1
        end

        self.revolver:fire(x, y, xDir, yDir)
    end
end

function Player:getHealthValues()
    return self.health, self.maxHealth
end

function Player:getMapTilePos()
    return self.tileX, self.tileY
end

function Player:remove()
    self.playerSprite:remove()
end

function Player:getRevolver()
    return self.revolver
end