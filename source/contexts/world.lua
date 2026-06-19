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
    GLOBAL_MAP = Map()
end

function World:setup()
    GLOBAL_MAP:createMap()
    player:add()
end

function World:update()
    player:update()
    if(pd.buttonJustPressed(pd.kButtonB)) then
        setContext('Reload')
        return
    end
end

function World:tearDown()
    player:remove()
    GLOBAL_MAP:clearMap()
end