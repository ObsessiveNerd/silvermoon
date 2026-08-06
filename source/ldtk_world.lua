import "CoreLibs/json"

-- LDtkWorld reads metadata the tile importer does not expose (IntGrid values,
-- entity fields and stable entity ids).  Tile graphics are still created by
-- PlaydateLDtkImporter in map.lua.
class("LDtkWorld").extends()

function LDtkWorld:init(path)
    self.path = path
    self.data = nil
end

function LDtkWorld:load()
    local file = playdate.file.open(self.path, playdate.file.kFileRead)
    assert(file, "Could not open LDtk project: " .. self.path)
    local contents = file:read(file:getSize())
    file:close()
    self.data = json.decode(contents)
    assert(self.data, "Could not decode LDtk project: " .. self.path)
end

function LDtkWorld:getLevel(identifier)
    assert(self.data, "LDtkWorld:load() must be called first")
    for _, level in ipairs(self.data.levels or {}) do
        if level.identifier == identifier then return level end
    end
    error("LDtk level not found: " .. tostring(identifier))
end

function LDtkWorld:getLayer(level, identifier)
    for _, layer in ipairs(level.layerInstances or {}) do
        if layer.__identifier == identifier then return layer end
    end
    return nil
end

function LDtkWorld:getLayerType(layer)
    for _, definition in ipairs(self.data.defs.layers or {}) do
        if definition.uid == layer.layerDefUid then return definition.type end
    end
    return nil
end

function LDtkWorld:getTileset(uid)
    for _, tileset in ipairs(self.data.defs.tilesets or {}) do
        if tileset.uid == uid then return tileset end
    end
    return nil
end

function LDtkWorld:getIntGrid(level, identifier)
    local layer = self:getLayer(level, identifier)
    if not layer then return nil end
    if self:getLayerType(layer) ~= "IntGrid" then
        error("LDtk layer '" .. identifier .. "' must be an IntGrid layer")
    end
    return layer
end

function LDtkWorld:getIntGridValue(layer, x, y)
    if x < 1 or y < 1 or x > layer.__cWid or y > layer.__cHei then
        return LDtkConfig.collision.Solid
    end
    return layer.intGridCsv[(y - 1) * layer.__cWid + x] or 0
end

function LDtkWorld:getEntities(level, layerIdentifier)
    local layer = self:getLayer(level, layerIdentifier)
    if not layer then return {} end
    if self:getLayerType(layer) ~= "Entities" then
        error("LDtk layer '" .. layerIdentifier .. "' must be an Entities layer")
    end

    local entities = {}
    for _, instance in ipairs(layer.entityInstances or {}) do
        local fields = {}
        for _, field in ipairs(instance.fieldInstances or {}) do
            fields[field.__identifier] = field.__value
        end
        table.insert(entities, {
            identifier = instance.__identifier,
            iid = instance.iid,
            x = instance.px[1], y = instance.px[2],
            gridX = math.floor(instance.px[1] / layer.__gridSize) + 1,
            gridY = math.floor(instance.px[2] / layer.__gridSize) + 1,
            width = instance.width, height = instance.height,
            tile = instance.__tile,
            fields = fields,
            raw = instance,
        })
    end
    return entities
end
