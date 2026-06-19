local pd = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "tile"
import "PlaydateLDtkImporter/LDtk"
import "enemies/enemy_factory"
import "enemies/enemy_world"

local TILE_SIZE = 8
local enemyFactory = EnemyFactory()

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
    self.mapLoaded = false
end

--------------------------------------------------
-- PUBLIC SETUP
--------------------------------------------------
function Map:createMap()
    pd.display.setScale(ZOOM)
    if self.mapLoaded then
        self:reloadMap()
    else
        self:loadLDtk()
        self:buildTiles()
        self:createEntities()
        self.mapLoaded = true
    end
end

function Map:createEntities()
    for index, entity in ipairs( LDtk.get_entities( "Level_0" ) ) do
        --TEMP--
        if entity.name == "Monster" then
            local enemy = EnemyWorld(entity)
            table.insert(enemiesList, enemy)
        end
    end
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
            tile.seen = false
            tile:setVisible(false)

            
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

function Map:getTileImageForEntity(entity)
    local rectX = entity.tileset_rect.x
    local rectY = entity.tileset_rect.y
    local rectW = entity.tileset_rect.w
    local rectH = entity.tileset_rect.h

    local img = self.tileTable:getImage(rectX / rectW, rectY / rectH)
    return img
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

function Map:getTilePosition(px, py)
    local tx = math.floor(px / (TILE_SIZE * ZOOM)) + 1
    local ty = math.floor(py / (TILE_SIZE * ZOOM)) + 1
    return tx, ty
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

function Map:reloadMap()
    for x = 1, self.width do
        for y = 1, self.height do
            local tile = self:getTile(x, y)
            if tile then
                tile:add()
            end
        end
    end
end

function Map:clearMap()
    for x = 1, self.width do
        for y = 1, self.height do
            local tile = self:getTile(x, y)
            if tile then
                tile:remove()
            end
        end
    end
end

--------------------------------------------------
-- OPTIONAL DEBUG
--------------------------------------------------
function Map:debugPrintSize()
    print("Map size:", self.width, self.height)
end