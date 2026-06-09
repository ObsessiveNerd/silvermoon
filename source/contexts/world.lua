local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "Corelibs/crank"

import "map"
import "shadowcasting"
import "enemies/enemy_factory"

class('World').extends()

function World:init()
    self.map = Map()

    -- self.enemyFactory = EnemyFactory()
    -- for i = 1, 1 do
    --     local enemyData = {
    --         type = "werewolf",
    --         x = 9,
    --         y = 9,
    --         index = i
    --     }
    --     table.insert(enemiesList, enemyData)
    -- end
end

function World:setup()
    self.map:createMap()
    -- player:add()
    -- for _, enemy in ipairs(enemiesList) do
    --     self.enemyFactory:addEnemyToMap(enemy.type, enemy.x, enemy.y, enemy.index)
    -- end
end

function World:update()
    player:update()
    if(pd.buttonJustPressed(pd.kButtonB)) then
        setContext('Reload')
        return
    end

    -- if pd.buttonJustPressed(pd.kButtonA) then
    --     setContext('Battle')
    -- end
end

function World:tearDown()
    player:remove()
    self.map:clearMap()
end