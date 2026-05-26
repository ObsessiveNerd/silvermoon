local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "enemies/enemy"
import "enemies/enemy_world"

class('EnemyFactory').extends()

function EnemyFactory:createEnemy(type)
    if type == "werewolf" then
        local werewolfImage = gfx.image.new("sprites/werewolf")
        return Enemy(werewolfImage, 40, 2.4, 8)
    -- elseif type == "orc" then
    --     local orcImage = gfx.image.new("sprites/orc")
    --     return Enemy(orcImage, 50, 0.5, 10)
    else
        error("Unknown enemy type: " .. type)
    end
end

function EnemyFactory:addEnemyToMap(type, x, y, worldIndex)
    if type == "werewolf" then
        local werewolfImage = gfx.image.new("sprites/world_monster_temp")
        return EnemyWorld(werewolfImage, x, y, worldIndex)
    -- elseif type == "orc" then
    --     local orcImage = gfx.image.new("sprites/orc")
    --     return Enemy(orcImage, 50, 0.5, 10)
    else
        error("Unknown enemy type: " .. type)
    end

end