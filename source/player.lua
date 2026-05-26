import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "contexts/reload"
import "revolver"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends()

currentDirection = 'Down'

function Player:init(revolver)
    self.revolver = Revolver()
    playerImage = gfx.image.new("sprites/player")
    self.viewRadius = 4
    self.tileX = 10
    self.tileY = 10
    self.speed = 3
    self.playerSprite = gfx.sprite.new(playerImage)
    local posX, posY = (self.tileX - 1) * (TILE_SIZE), (self.tileY - 1) * (TILE_SIZE)
    print("Initializing player at: ", posX, posY)
    self.playerSprite:moveTo(posX, posY)
    self.playerSprite:setTag(TAGS.Player)
    self.maxHealth = 100
    self.health = 100
end

function Player:add()
    self.playerSprite:add()
    self.playerSprite:setCollideRect(0, 0, TILE_SIZE, TILE_SIZE)
    self.playerSprite:moveTo((self.tileX - 1) * (TILE_SIZE), (self.tileY - 1) * (TILE_SIZE))
    local x, y = self.playerSprite:getPosition()
    gfx.setDrawOffset(-x + 200, -y + 120)
    computeFOV(self.tileX, self.tileY, self.viewRadius)
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
        local goalX, goalY = x + moveX * self.speed, y + moveY * self.speed
        
        local actualX, actualY, collisions, numberOfCollisions = self.playerSprite:moveWithCollisions(goalX, goalY) --TODO: we'll have to normalize the vector before applying speed at some point
        for i=1, numberOfCollisions do
            if collisions[i].other:getTag() == TAGS.Enemy then
                collisions[i].other:removeFromWorld()
                setContext('Battle')
                return
            end
        end

        local x, y = self.playerSprite:getPosition()
        local tx, ty = self:getTilePosition(x, y)
        if tx ~= self.tileX or ty ~= self.tileY then
            self.tileX = tx
            self.tileY = ty
            computeFOV(self.tileX, self.tileY, self.viewRadius)
        end
        gfx.setDrawOffset(-x + 200, -y + 120)
    end

    -- if pd.buttonJustPressed(pd.kButtonA) then
    --     local x, y = self.playerSprite:getPosition()
    --     local xDir = 0
    --     local yDir = 0

    --     if currentDirection == 'Up' then
    --         yDir = -1
    --     elseif currentDirection == 'Down' then
    --         yDir = 1
    --     elseif currentDirection == 'Left' then
    --         xDir = -1
    --     elseif currentDirection == 'Right' then
    --         xDir = 1
    --     end

    --     self.revolver:fire(x, y, xDir, yDir)
    -- end
end

function Player:getTilePosition(px, py)
    local tx = math.floor(px / TILE_SIZE) + 1
    local ty = math.floor(py / TILE_SIZE) + 1
    return tx, ty
end

function Player:getHealthValues()
    return self.health, self.maxHealth
end

function Player:getMapTilePos()
    return self.tileX, self.tileY
end

function Player:remove()
    gfx.setDrawOffset(0, 0)
    self.playerSprite:remove()
end

function Player:getRevolver()
    return self.revolver
end