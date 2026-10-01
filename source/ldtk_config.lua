-- Central contract between LDtk and the game.  Keep identifiers here instead
-- of scattering map-specific strings through gameplay code.
LDtkConfig = {
    projectPath = "maps/testlevel.ldtk",
    defaultLevel = "Level_0",
    tileSize = 8,
    visualLayers = { "Ground_textures", "Unique_tiles", "Collision" },
    collisionLayer = "Collision",
    entitiesLayer = "Entities",
    collision = {
        Undrawn = 0,
        Empty = 1,
        Solid = 2,
        VisionBlocker = 3,
        MovementBlocker = 4,
    },
    entityAliases = {
        Player = "PlayerSpawn",
        Monster = "Enemy",
        KeyItem = "Item",
    }
}
