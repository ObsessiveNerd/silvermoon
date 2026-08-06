# LDtk map importer

The game loads both the graphical tile layers and the gameplay data in an LDtk
project. Tile graphics continue to use `PlaydateLDtkImporter`, while
`LDtkWorld` reads the LDtk JSON for IntGrid collision, entity fields, and
stable entity IDs.

`Map:createMap(levelIdentifier)` loads a level (default: `Level_0`). The map
owns collision and visibility data; gameplay should use its APIs instead of
reading visual wall tiles:

```lua
map:isBlocked(tileX, tileY)
map:isOpaque(tileX, tileY)
map:worldToTile(worldX, worldY)
map:tileToWorld(tileX, tileY)
map:setCollisionValue(tileX, tileY, value)
```

Tile coordinates are one-based. LDtk coordinates are zero-based pixels. World
coordinates are LDtk pixels multiplied by `ZOOM`; `tileToWorld(1, 1)` is
therefore `(0, 0)`. The project uses 8x8 source tiles.

## Required LDtk setup

Use these layer identifiers, in this order:

1. `Ground_textures` — Tiles layer for the base terrain.
2. `Unique_tiles` — Tiles layer for decorative tiles above the ground.
3. `Walls_AutoLayer` — AutoLayer for wall artwork. This is visual only.
4. `Collision` — IntGrid layer. This is the authoritative movement and
   visibility source.
5. `Entities` — Entities layer.

The code draws the visual layers in the order configured in `ldtk_config.lua`.
Add a layer name there if the game gains another visual layer. `Collision` and
`Entities` must use the exact names above unless the configuration is changed.

Configure the `Collision` IntGrid with the following values:

| Value | Name | Movement | Light / FOV |
| --- | --- | --- | --- |
| 0 | `Empty` | passable | transparent |
| 1 | `Solid` | blocked | blocked |
| 2 | `VisionBlocker` | passable | blocked |
| 3 | `MovementBlocker` | blocked | transparent |

Paint collision independently of artwork. A wall normally receives `Solid`,
but foliage, windows, fences, smoke, or hidden boundaries can use the other
two values. This separation is important for the shadowcasting lighting/FOV
system: it calls `Map:isOpaque()` and never infers sight blocking from a tile
image.

The current `testlevel.ldtk` has no `Collision` layer yet. It continues to
run using its `Walls_AutoLayer` as a deprecated `Solid` fallback. Add and paint
`Collision` before relying on the new behavior; the fallback cannot represent
values 2 or 3.

## Entities

Create entities using these identifiers:

| Entity | Required fields | Optional fields |
| --- | --- | --- |
| `PlayerSpawn` | — | — |
| `Enemy` | `enemyType` | `facing`, `patrolId` |
| `NPC` | `dialogueId` | `facing` |
| `Item` | `itemId`, `quantity` | — |
| `Interactable` | `interactionId` | `blocksMovement` (Bool), `blocksSight` (Bool) |
| `Door` | `targetLevel`, `targetEntity` | `locked` (Bool), `keyId`, `startsOpen` (Bool) |
| `Light` | `radius` (Int) | `enabled` (Bool), `flicker` (Bool) |

An entity tile is optional. When supplied it is used as the entity sprite;
otherwise the importer uses a visible placeholder tile. The factory receives a
normalized table:

```lua
{
  identifier = "Door", iid = "...",
  x = 32, y = 48,              -- LDtk pixels
  gridX = 5, gridY = 7,        -- one-based grid cells
  width = 8, height = 8,
  tile = { x = 0, y = 0 },     -- optional LDtk __tile data
  fields = { startsOpen = false },
  raw = entityInstance
}
```

For compatibility, old test-map identifiers are aliased automatically:
`Player` becomes `PlayerSpawn`, `Monster` becomes `Enemy`, and `KeyItem`
becomes `Item`. Migrate maps to the names above when convenient.

## Adding an entity type

Register the type once in `Map:registerEntityFactories()` (or move that
registration to a dedicated module as the game grows):

```lua
self.registry:register("Chest", function(map, entity)
  local sprite = map:createEntitySprite(entity, TAGS.Interactable, true)
  sprite.ldtkEntity = entity
  return sprite
end)
```

The factory may return a Playdate sprite or another game object. It can use
`entity.fields` for authored data. Unknown entity types write a warning and
are skipped, rather than stopping level loading.

## Doors and future lighting

The imported door sprite has `setOpen(isOpen)`. Closing sets its cell to
`Solid`; opening sets it to `Empty`. Either change rebuilds the affected
collision sprite and refreshes the player FOV. More complex doors can preserve
the previous IntGrid value or set `MovementBlocker`/`VisionBlocker` explicitly.

`Light` entities are currently imported as light descriptors with `radius`,
`enabled`, and `flicker`. The active lighting implementation remains the
player's shadowcast FOV, but light sources can use the same `isOpaque()` grid,
so a later multi-light implementation will not require reauthoring maps.

## New-map checklist

1. Use 8px grids for tile and entity layers.
2. Create the five named layers in the required order.
3. Paint all movement and sight rules into `Collision`.
4. Add a `PlayerSpawn` and any gameplay entities with the documented fields.
5. Configure tile graphics in `ldtk_config.lua` if the layer names or tileset
   differ from the current project.
6. Test solid collision, each special collision value, an unknown entity, and
   an opening/closing door.
