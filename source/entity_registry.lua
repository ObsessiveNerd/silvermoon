class("EntityRegistry").extends()

function EntityRegistry:init()
    self.factories = {}
end

function EntityRegistry:register(identifier, factory)
    assert(type(factory) == "function", "Entity factory must be a function")
    self.factories[identifier] = factory
end

function EntityRegistry:spawn(map, entity)
    local factory = self.factories[entity.identifier]
    if not factory then
        print("LDtk: no factory registered for entity '" .. entity.identifier .. "'")
        return nil
    end
    return factory(map, entity)
end
