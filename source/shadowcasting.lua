local pd <const> = playdate
local gfx <const> = playdate.graphics

import "map"

local multipliers = {
    {1, 0, 0, 1},   -- octant 0
    {0, 1, 1, 0},   -- octant 1
    {0, -1, 1, 0},  -- octant 2
    {-1, 0, 0, 1},  -- octant 3
    {-1, 0, 0, -1}, -- octant 4
    {0, -1, -1, 0}, -- octant 5
    {0, 1, -1, 0},  -- octant 6
    {1, 0, 0, -1},  -- octant 7
}

function computeFOV(px, py, radius)
    -- Step 1: clear visibility
    clearMap()

    -- player tile always visible
    setVisible(px, py)

    -- cast in 8 directions
    for i = 1, 8 do
        castLight(px, py, 1, 1.0, 0.0, radius,
            multipliers[i][1], multipliers[i][2],
            multipliers[i][3], multipliers[i][4]
        )
    end

    drawMap()
end

function castLight(cx, cy, row, startSlope, endSlope, radius, xx, xy, yx, yy)
    if startSlope < endSlope then return end

    local radiusSq = radius * radius

    for i = row, radius do
        local dx = -i
        local dy = -i

        local blocked = false
        local newStart = startSlope

        while dx <= 0 do
            local X = cx + dx * xx + dy * xy
            local Y = cy + dx * yx + dy * yy

            local lSlope = (dx - 0.5) / (dy + 0.5)
            local rSlope = (dx + 0.5) / (dy - 0.5)

            if startSlope < rSlope then
                dx = dx + 1
                goto continue
            elseif endSlope > lSlope then
                break
            end

            -- bounds check
            if X >= 1 and X <= MAP_WIDTH and Y >= 1 and Y <= MAP_HEIGHT then
                local distSq = dx * dx + dy * dy
                if distSq <= radiusSq then
                    setVisible(X, Y)
                end

                if blocked then
                    if map[X][Y].blockSight then
                        newStart = rSlope
                    else
                        blocked = false
                        startSlope = newStart
                    end
                else
                    if map[X][Y].blockSight and i < radius then
                        blocked = true
                        castLight(cx, cy, i + 1, startSlope, lSlope,
                            radius, xx, xy, yx, yy)
                        newStart = rSlope
                    end
                end
            end

            ::continue::
            dx = dx + 1
        end

        if blocked then break end
    end
end