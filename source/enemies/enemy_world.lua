local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "map"
import "player"

class('EnemyWorld').extends(gfx.sprite)

function EnemyWorld:init(entity)
    self.image = GLOBAL_MAP:getTileImageForEntity(entity)
    
    self.worldIndex = worldIndex
    self.speed = 5
    self.viewRadius = 5
    
    self:setImage(self.image)
    self:add()

    local posX, posY = entity.world_position.x * ZOOM, entity.world_position.y * ZOOM;
    self:setCollideRect(0, 0, TILE_SIZE, TILE_SIZE)
    self:setTag(TAGS.Enemy)
    self:moveTo(posX, posY)
    self:setZIndex(1000)
    self:setScale(ZOOM)
    
end

function EnemyWorld:update()
    if player ~= nil then
        self:moveTowardsPlayer()
    end
end

function EnemyWorld:moveTowardsPlayer()
    local playerX, playerY = player:getPosition()
    local enemyX, enemyY = self:getPosition()

    local distance = math.sqrt((playerX - enemyX) ^ 2 + (playerY - enemyY) ^ 2)
    if (distance / TILE_SIZE) > self.viewRadius then
        return
    end
    
    local playerTileX, playerTileY = GLOBAL_MAP:getTilePosition(playerX, playerY)
    local enemyTileX, enemyTileY = GLOBAL_MAP:getTilePosition(enemyX, enemyY)

    local moveX, moveY = 0, 0

    if playerTileX == enemyTileX then
        if playerTileY < enemyTileY then
            moveY = -1
        elseif playerTileY > enemyTileY then
            moveY = 1
        end
    elseif playerTileY == enemyTileY then
        if playerTileX < enemyTileX then
            moveX = -1
        elseif playerTileX > enemyTileX then
            moveX = 1
        end
    end

    local goalX = enemyX + moveX * self.speed
    local goalY = enemyY + moveY * self.speed

    local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
    for i = 1, numberOfCollisions do
        if collisions[i].other:getTag() == TAGS.Player then
            self:removeFromWorld()
            setContext('Battle')
            return
        end
    end
end

function EnemyWorld:removeFromWorld()
    table.remove(enemiesList, self.worldIndex)
    self:remove()
end