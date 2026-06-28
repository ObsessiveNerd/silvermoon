import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "player"
import "enemies/enemy_factory"
import "contexts/reload"

local pd = playdate
local gfx = playdate.graphics
local enemyFactory = EnemyFactory()
-- local reloadContext = Reload()

class('Battle').extends()

function Battle:init()
    self.x = 200
    self.y = 120
    self.isReloading = false
end

function Battle:setup()
    pd.display.setScale(1)
    self.reloadContext = Reload()
    local battleScreen = gfx.image.new("sprites/battle-screen")
    self.battleScreenSprite = gfx.sprite.new(battleScreen)
    self.battleScreenSprite:moveTo(200, 120)
    self.battleScreenSprite:add()

    self.background = gfx.image.new("sprites/temp-background")
    self.backgroundSprite = gfx.sprite.new(self.background)
    self.backgroundSprite:setScale(0.8)
    -- self.backgroundSprite:moveTo(200, 120)
    self.backgroundSprite:add()

    local cowboyIcon = gfx.image.new("sprites/temp-cowboy")
    self.cowboySprite = gfx.sprite.new(cowboyIcon)
    self.cowboySprite:moveTo(200, 200)
    self.cowboySprite:setScale(0.09)
    self.cowboySprite:add()

    local health, maxHealth = player:getHealthValues()
    self.playerHealthBar = StatusBar(200, 230, health, maxHealth, gfx.image.new("sprites/heart"), 0.5)

    --Here's where we'll create enemies
    self.numberoOfEnemies = 1
    self.numberOfEnemiesDefeated = 0
    self.enemy = enemyFactory:createEnemy("werewolf")
    self.enemy:addDiedListener(function() 
        print("Enemy died!")
        self.numberOfEnemiesDefeated = self.numberOfEnemiesDefeated + 1
    end)

    self.reloadContext:setupScaled(0.4, 350, 220)
    self.reloadContext:ignoreCloseButton()

end

function Battle:update()
    if self.isReloading then
        self.reloadContext:update()
        if pd.buttonJustPressed(pd.kButtonB) then
            self.isReloading = false
            print("Finished Reloading")
        end
    else
        if pd.buttonJustPressed(pd.kButtonA) then
            local hasBullet = self.reloadContext:battleFire()
            if hasBullet then
                self.enemy:takeDamage(10)
            end
        end
        if pd.buttonJustPressed(pd.kButtonB) then
            self.isReloading = true
            print("Reloading...")
        end
    end

    if self.numberOfEnemiesDefeated >= self.numberoOfEnemies then
        print("All enemies defeated! Returning to world.")
        setContext('World')
    end

    self.playerHealthBar:setValue(player.health)
end

function Battle:tearDown()
    self.enemy:tearDown()
    self.playerHealthBar:tearDown()
    self.reloadContext:tearDown()

    self.battleScreenSprite:remove()
    self.backgroundSprite:remove()
    self.cowboySprite:remove()
end