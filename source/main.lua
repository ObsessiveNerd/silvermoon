import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "player"
import "contexts/world"
import "contexts/reload"
import "contexts/door"
import "contexts/battle"


local pd <const> = playdate
local gfx <const> = playdate.graphics
ZOOM = 2

TAGS = {
    Player = 1,
    Enemy = 2,
    Wall = 3,
}

player = Player()
enemiesList = {}

local contexts = {
    ['World'] = World(),
    ['Reload'] = Reload(),
    ['Door'] = Door(),
    ['Battle'] = Battle()
}

currentContext = contexts['World']
currentContext:setup()

function playdate.update()
    currentContext:update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end

function setContext(newContext)
    print("Switching context to " .. newContext)
    local context = contexts[newContext]
    if context then
        currentContext:tearDown()
        currentContext = context
        currentContext:setup()
    end
end