local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "tile"
import "PlaydateLDtkImporter/LDtk"

MAP_WIDTH = 20
MAP_HEIGHT = 20

local TILE_SIZE = 8
local TILES_PER_ROW = 43
local jsonData = nil
tempItems = {}
map = {}
visibleTiles = {}
local tiles = nil

-- for x = 1, MAP_WIDTH do
--     map[x] = {}
--     for y = 1, MAP_HEIGHT do
--         map[x][y] = Tile(x - 1, y - 1, gfx.image.new(TILE_SIZE, TILE_SIZE))
--     end
-- end

function setBlocksSight(x, y)
    map[x][y].blockSight = true
end

function createBlockedSightTile(x, y)
    local image = gfx.image.new("sprites/debug-tile-32")
    local sprite = gfx.sprite.new(image)
    sprite:moveTo((x-1) * (TILE_SIZE), (y-1) * (TILE_SIZE))
    setBlocksSight(x, y)
    -- for xOffset = 0, 3 do
    --     for yOffset = 0, 3 do
    --         setBlocksSight(x + xOffset - 1, y + yOffset - 1)
    --     end
    -- end
    table.insert(tempItems, sprite)
end

-- createBlockedSightTile(12, 12)
-- createBlockedSightTile(12, 13)
-- createBlockedSightTile(12, 14)
-- createBlockedSightTile(12, 15)

-- createBlockedSightTile(15, 18)
-- createBlockedSightTile(15, 19)
-- createBlockedSightTile(15, 20)
-- createBlockedSightTile(16, 20)
-- createBlockedSightTile(17, 20)
-- createBlockedSightTile(18, 20)

-- createBlockedSightTile(13, 2)
-- createBlockedSightTile(13, 13)

function createMap()


    loadMap()
    -- drawMap()
    -- for x = 1, MAP_WIDTH do
    --     for y = 1, MAP_HEIGHT do
    --         map[x][y]:add()
    --     end
    -- end

    --  for i = 1, #tempItems do
    --     tempItems[i]:add()
    -- end
end

function clearMap()
    for i, tile in ipairs(visibleTiles) do
        tile.visible = false
    end
    visibleTiles = {}
end

-- function drawMap()
--     for x = 1, MAP_WIDTH do
--         for y = 1, MAP_HEIGHT do
--             local tile = map[x][y]
--             tile:drawTile()
--         end
--     end
-- end

function setVisible(x, y)
    map[x][y].visible = true
    map[x][y].seen = true
    table.insert(visibleTiles, map[x][y])
end

function removeMap()
    for x = 1, MAP_WIDTH do
        for y = 1, MAP_HEIGHT do
            map[x][y]:remove()
        end
    end
    for i = 1, #tempItems do
        tempItems[i]:remove()
    end
end

function loadMap()

   LDtk.load("maps/testlevel.ldtk")
   local tilemap = LDtk.create_tilemap("Level_0")
   
    -- gfx.pushContext()
        pd.display.setScale(2)
        tilemap:draw(0, 0)
    -- gfx.popContext()

   for index, entity in ipairs( LDtk.get_entities( "Level_0" ) ) do
	print("Entity: " .. entity.name )
    -- if entity.name=="Player" then
		-- player.sprite:add()
		-- player.init( entity )
	end
end