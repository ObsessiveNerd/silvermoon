local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "tile"
import "PlaydateLDtkImporter/LDtk"

local TILE_SIZE = 8

class("Map").extends()

--------------------------------------------------
-- INIT
--------------------------------------------------
function Map:init()
    self.map = {}
    self.visibleTiles = {}

    self.width = 0
    self.height = 0

    self.tileTable = nil

    self.walls = nil
    self.ground = nil
    self.unique = nil
end

--------------------------------------------------
-- PUBLIC SETUP
--------------------------------------------------
function Map:createMap()
    self:loadLDtk()
    self:buildTiles()
end

--------------------------------------------------
-- LDtk loading (data only)
--------------------------------------------------
function Map:loadLDtk()
    LDtk.load("maps/testlevel.ldtk")

    self.tileTable =
        gfx.imagetable.new("sprites/test-table-8-8")

    self.walls =
        LDtk.create_tilemap("Level_0", "Walls_AutoLayer")

    self.ground =
        LDtk.create_tilemap("Level_0", "Ground_textures")

    self.unique =
        LDtk.create_tilemap("Level_0", "Unique_tiles")
end

--------------------------------------------------
-- BUILD TILE OBJECTS
--------------------------------------------------
function Map:buildTiles()
    local w, h = self.walls:getSize()

    self.width = w
    self.height = h

    MAP_WIDTH = w
    MAP_HEIGHT = h

    local emptyIDs =
        LDtk.get_empty_tileIDs(
            "Level_0",
            "Just_a_wall",
            "Walls_AutoLayer"
        )

    local emptyLookup = {}
    local wallLookup = {}
    
    for _, id in ipairs(emptyIDs) do
        emptyLookup[id] = true
    end

    local wallIDs = 
        LDtk.get_tileIDs(
            "Level_0",
            "Just_a_wall",
            "Walls_AutoLayer"
        )

        for _, id in ipairs(wallIDs) do
            wallLookup[id] = true
        end
    for x = 1, w do
        self.map[x] = {}

        for y = 1, h do

            local groundID = self.ground:getTileAtPosition(x, y)
            local wallID = self.walls:getTileAtPosition(x, y)
--HATE
            if groundID == nil then
                groundID = 0
            end

            if groundID > 0 and wallID ~= nil and wallID > 0 then
                groundID = 0
            end
-- HATE

            local uniqueID = self.unique:getTileAtPosition(x, y)

            local isWall =
                wallID ~= nil and wallID ~= 0 and wallLookup[wallID]

            local image =
                self:getTileImage(groundID, uniqueID, wallID)

            local tileX = (x - 1) * TILE_SIZE * ZOOM
            local tileY = (y - 1) * TILE_SIZE * ZOOM
            local tile = nil

            if self.map[x][y] == nil then
                tile = Tile(tileX, tileY, image)
                self.map[x][y] = tile
            end

            tile.blockSight = isWall
            tile.visible = false
            tile.seen = false

            
            tile:add()
        end
    end
end

--------------------------------------------------
-- TILE GRAPHICS LOOKUP
--------------------------------------------------
function Map:getTileImage(groundID, uniqueID, wallID)

    local id =
        uniqueID ~= 0 and uniqueID or groundID

    if id == 0 then id = wallID end
    if id == 0 then id = 1 end
    if id == nil then id = 0 end

    return self.tileTable:getImage(id)
end

--------------------------------------------------
-- TILE ACCESS HELPERS
--------------------------------------------------
function Map:getTile(x, y)
    if not self.map then
        return nil
    end

    if not self.map[x] then return nil end
    return self.map[x][y]
end

--------------------------------------------------
-- FOV INTERFACE (IMPORTANT)
--------------------------------------------------
function Map:isOpaque(x, y)
    local tile = self:getTile(x, y)
    if not tile then return true end
    return tile.blockSight
end

function Map:setVisible(x, y)
    local tile = self:getTile(x, y)
    if not tile then print("Tile not found at:", x, y) return end
    tile:setVisible(true)
    table.insert(self.visibleTiles, tile)
end

function Map:clearVisibility()
    for _, tile in ipairs(self.visibleTiles) do
        tile:setVisible(false)
    end
    self.visibleTiles = {}
end

--------------------------------------------------
-- OPTIONAL DEBUG
--------------------------------------------------
function Map:debugPrintSize()
    print("Map size:", self.width, self.height)
end