local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "tile"
import "PlaydateLDtkImporter/LDtk"
import "ldtk_config"
import "ldtk_world"
import "entity_registry"
import "enemies/enemy_world"
import "entities/door_world"

local TILE_SIZE <const> = LDtkConfig.tileSize

class("Map").extends()

function Map:init()
    self.map = {}
    self.visibleTiles = {}
    self.entities = {}
    self.collisionSprites = {}
    self.width, self.height = 0, 0
    self.tileTable = nil
    self.mapLoaded = false
    self.levelIdentifier = nil
    self.registry = EntityRegistry()
    self:registerEntityFactories()
end

function Map:createMap(levelIdentifier)
    pd.display.setScale(ZOOM)
    levelIdentifier = levelIdentifier or LDtkConfig.defaultLevel
    if self.mapLoaded and self.levelIdentifier == levelIdentifier then
        self:reloadMap()
        return
    end

    if self.mapLoaded then self:destroyMap() end
    self.levelIdentifier = levelIdentifier
    self:loadLDtk(levelIdentifier)
    self:buildTiles()
    self:buildCollision()
    self:createEntities()
    self.mapLoaded = true
end

function Map:loadLDtk(levelIdentifier)
    self.world = LDtkWorld(LDtkConfig.projectPath)
    self.world:load()
    self.level = self.world:getLevel(levelIdentifier)
    LDtk.load(LDtkConfig.projectPath)
    self.tileTable = gfx.imagetable.new("sprites/test-table-8-8")

    self.layers = {}
    for _, layerName in ipairs(LDtkConfig.visualLayers) do
        -- A missing optional visual layer is harmless, but is reported clearly.
        local layer = self.world:getLayer(self.level, layerName)
        if layer then
            self.layers[layerName] = LDtk.create_tilemap(levelIdentifier, layerName)
        else
            print("LDtk: visual layer not found: " .. layerName)
        end
    end
    assert(next(self.layers), "LDtk level has no configured visual layers")
end

function Map:buildTiles()
    local source = self.layers[LDtkConfig.visualLayers[1]]
    local w, h = source:getSize()
    self.width, self.height = w, h
    MAP_WIDTH, MAP_HEIGHT = w, h

    for x = 1, w do
        self.map[x] = {}
        for y = 1, h do
            local image = self:getTileImageAt(x, y)
            local tile = Tile((x - 1) * TILE_SIZE * ZOOM, (y - 1) * TILE_SIZE * ZOOM, image, false)
            tile.blockSight = false -- visibility comes exclusively from Collision.
            tile:setZIndex(10)
            self.map[x][y] = tile
            tile:add()
        end
    end
end

function Map:getTileImageAt(x, y)
    -- Later layers visually override earlier layers, matching the old renderer.
    local id = 0
    for _, layerName in ipairs(LDtkConfig.visualLayers) do
        local layer = self.layers[layerName]
        if layer then
            local candidate = layer:getTileAtPosition(x, y)
            if candidate and candidate ~= 0 then id = candidate end
        end
    end
    return self.tileTable:getImage(id == 0 and 1 or id)
end

function Map:buildCollision()
    self.collision = {}
    local collisionLayer = self.world:getIntGrid(self.level, LDtkConfig.collisionLayer)
    if not collisionLayer then
        print("LDtk: no Collision IntGrid; using deprecated Walls_AutoLayer fallback")
    end
    for x = 1, self.width do
        self.collision[x] = {}
        for y = 1, self.height do
            local value = collisionLayer and self.world:getIntGridValue(collisionLayer, x, y) or self:legacyWallValue(x, y)
            self.collision[x][y] = value
            if self:isBlocked(x, y) then self:createCollisionSprite(x, y) end
        end
    end
end

function Map:legacyWallValue(x, y)
    local walls = self.layers["Walls_AutoLayer"]
    if not walls then return LDtkConfig.collision.Empty end
    local id = walls:getTileAtPosition(x, y)
    return (id and id ~= 0) and LDtkConfig.collision.Solid or LDtkConfig.collision.Empty
end

function Map:createCollisionSprite(x, y)
    local sprite = gfx.sprite.new()
    sprite:setCenter(0, 0)
    sprite:setTag(TAGS.Wall)
    sprite:setCollideRect(0, 0, TILE_SIZE * ZOOM, TILE_SIZE * ZOOM)
    sprite:moveTo((x - 1) * TILE_SIZE * ZOOM, (y - 1) * TILE_SIZE * ZOOM)
    sprite:setVisible(false)
    sprite:add()
    self.collisionSprites[x .. ":" .. y] = sprite
end

function Map:getCollisionValue(x, y)
    return self.collision[x] and self.collision[x][y] or LDtkConfig.collision.Solid
end

function Map:isBlocked(x, y)
    local value = self:getCollisionValue(x, y)
    return value == LDtkConfig.collision.Solid or value == LDtkConfig.collision.MovementBlocker
end

function Map:isOpaque(x, y)
    local value = self:getCollisionValue(x, y)
    return value == LDtkConfig.collision.Solid or value == LDtkConfig.collision.VisionBlocker
end

function Map:setCollisionValue(x, y, value)
    if not (self.collision[x] and self.collision[x][y] ~= nil) then return false end
    local key = x .. ":" .. y
    local wasBlocked = self:isBlocked(x, y)
    self.collision[x][y] = value
    local isBlocked = self:isBlocked(x, y)
    if wasBlocked and not isBlocked and self.collisionSprites[key] then
        self.collisionSprites[key]:remove()
        self.collisionSprites[key] = nil
    elseif not wasBlocked and isBlocked then
        self:createCollisionSprite(x, y)
    end
    if player then
        local px, py = player:getMapTilePos()
        computeFOV(px, py, player.viewRadius)
    end
    return true
end

function Map:worldToTile(px, py)
    return math.floor(px / (TILE_SIZE * ZOOM)) + 1, math.floor(py / (TILE_SIZE * ZOOM)) + 1
end

function Map:tileToWorld(x, y)
    return (x - 1) * TILE_SIZE * ZOOM, (y - 1) * TILE_SIZE * ZOOM
end

function Map:getTilePosition(px, py) return self:worldToTile(px, py) end
function Map:getTile(x, y) return self.map[x] and self.map[x][y] or nil end

function Map:createEntities()
    for _, entity in ipairs(self.world:getEntities(self.level, LDtkConfig.entitiesLayer)) do
        entity.identifier = LDtkConfig.entityAliases[entity.identifier] or entity.identifier
        local spawned = self.registry:spawn(self, entity)
        if spawned then table.insert(self.entities, spawned) end
    end
end

function Map:registerEntityFactories()
    self.registry:register("PlayerSpawn", function(map, entity)
        player.tileX, player.tileY = entity.gridX, entity.gridY
        return nil
    end)
    self.registry:register("Enemy", function(map, entity)
        local enemy = EnemyWorld(entity)
        table.insert(enemiesList, enemy)
        return enemy
    end)
    self.registry:register("Item", function(map, entity)
        return map:createEntitySprite(entity, TAGS.Key, true)
    end)
    self.registry:register("NPC", function(map, entity)
        return map:createEntitySprite(entity, nil, false)
    end)
    self.registry:register("Interactable", function(map, entity)
        local sprite = map:createEntitySprite(entity, nil, entity.fields.blocksMovement == true)
        if entity.fields.blocksSight == true then map:setCollisionValue(entity.gridX, entity.gridY, LDtkConfig.collision.VisionBlocker) end
        return sprite
    end)
    self.registry:register("Door", function(map, entity)
        local door = DoorWorld(entity)
        return door
    end)
    self.registry:register("Light", function(_, entity)
        return { ldtkEntity = entity, radius = entity.fields.radius or 4, enabled = entity.fields.enabled ~= false, flicker = entity.fields.flicker == true }
    end)
end

function Map:createEntitySprite(entity, tag, blocksMovement)
    local image = self:getEntityImage(entity)
    local sprite = gfx.sprite.new(image)
    local px, py = self:tileToWorld(entity.gridX, entity.gridY)
    sprite:setCenter(0, 0)
    sprite:moveTo(px, py)
    sprite:setScale(ZOOM)
    sprite:setZIndex(1000)
    if tag then sprite:setTag(tag) end
    if blocksMovement then sprite:setCollideRect(0, 0, entity.width * ZOOM, entity.height * ZOOM) end
    sprite:add()
    return sprite
end

function Map:getEntityImage(entity)
    -- __tile is optional in LDtk.  A neutral fallback keeps placeholder
    -- entities visible without hard-coding image ids per entity type.
    if entity.tile then
        local tileset = self.world:getTileset(entity.tile.tilesetUid)
        assert(tileset, "LDtk entity references an unknown tileset")
        local columns = math.floor(tileset.pxWid / tileset.tileGridSize)
        local index = (entity.tile.y / TILE_SIZE) * columns + (entity.tile.x / TILE_SIZE) + 1
        return self.tileTable:getImage(index)
    end
    return self.tileTable:getImage(1)
end

function Map:setVisible(x, y)
    local tile = self:getTile(x, y)
    if not tile then return end
    tile:setVisible(true)
    table.insert(self.visibleTiles, tile)
end

function Map:clearVisibility()
    for _, tile in ipairs(self.visibleTiles) do tile:setVisible(false) end
    self.visibleTiles = {}
end

function Map:reloadMap()
    for x = 1, self.width do for y = 1, self.height do self.map[x][y]:add() end end
    for _, sprite in pairs(self.collisionSprites) do sprite:add() end
    for _, entity in ipairs(self.entities) do if entity.add then entity:add() end end
end

function Map:clearMap()
    for x = 1, self.width do for y = 1, self.height do self.map[x][y]:remove() end end
    for _, sprite in pairs(self.collisionSprites) do sprite:remove() end
    for _, entity in ipairs(self.entities) do if entity.remove then entity:remove() end end
    for _, enemy in ipairs(enemiesList) do enemy:remove() end
end

function Map:destroyMap()
    self:clearMap()
    self.map, self.entities, self.collisionSprites = {}, {}, {}
    self.mapLoaded = false
end

function Map:removeEntity(entity)
    for i, value in ipairs(self.entities) do
        if value == entity then table.remove(self.entities, i); entity:remove(); return true end
    end
    return false
end
