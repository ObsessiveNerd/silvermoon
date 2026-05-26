local pd <const> = playdate
local gfx <const> = playdate.graphics

import "bullet"

class('Revolver').extends()

local currentBulletSlot = 1
local bullets = 
{
    {loaded = false, type = 'none', emptyCasing = false},
    {loaded = false, type = 'none', emptyCasing = false},
    {loaded = false, type = 'none', emptyCasing = false},
    {loaded = false, type = 'none', emptyCasing = false},
    {loaded = false, type = 'none', emptyCasing = false},
    {loaded = false, type = 'none', emptyCasing = false},
}

function Revolver:init()

end

function Revolver:getBullets()
    return bullets
end

function Revolver:setIsLoaded(slot, isLoaded)
    bullets[slot].loaded = isLoaded
end

function Revolver:ejectBullet(slot)
    bullets[slot].loaded = false
    bullets[slot].emptyCasing = false
end

function Revolver:getBulletAt(slot)
    return bullets[slot]
end