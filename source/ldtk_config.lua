-- Central contract between LDtk and the game.  Keep identifiers here instead
-- of scattering map-specific strings through gameplay code.
LDtkConfig = {
    projectPath = "maps/testlevel.ldtk",
    defaultLevel = "Level_0",
    tileSize = 8,
    visualLayers = { "Ground_textures", "Unique_tiles", "Walls_AutoLayer" },
    collisionLayer = "Collision",
    entitiesLayer = "Entities",
    collision = {
        Empty = 0,
        Solid = 1,
        VisionBlocker = 2,
        MovementBlocker = 3,
    },
    entityAliases = {
        Player = "PlayerSpawn",
        Monster = "Enemy",
        KeyItem = "Item",
    }
}
