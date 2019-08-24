require("resources.scripts.timers")
require("item")
require("passiveitem")


local TimerManager = createTManager();
local ptb = RegisterMod("PathToBlessing",0);

local function print(str) 
    Isaac.DebugString(tostring(str))
end

------------------- GOLDEN WIND ITEM -------------------
local GoldenWind = Item:new(ptb,"Desu",TimerManager);
GoldenWind.BuffFlag = true;
GoldenWind.BuffDuration = 240;
GoldenWind.Damage = 5;
GoldenWind.Tears = -5;
GoldenWind.Flight = true;
GoldenWind.Costume = Isaac.GetCostumeIdByPath("gfx/characters/copypaste.anm2");

GoldenWind.Use = function(self)
    Isaac.GetPlayer(0):AddNullCostume(self.Costume);
    self.Invincibility = true;
end

GoldenWind.PostBaff = function(self)
    Isaac.GetPlayer(0):TryRemoveNullCostume(self.Costume);
    self.Invincibility = false;
end
-------------------------------------------------------

---------------------Spirit of light-------------------

local function SpawnFollower(Type)
    return Isaac.Spawn(EntityType.ENTITY_FAMILIAR,Type,0,Isaac.GetPlayer(0).Position,Vector(0,0),nil):ToFamiliar()
end

local SpiritOfLight = Passive:new(ptb,"Spirit of the light")
SpiritOfLight.postDeath = false;

SpiritOfLight.Fire = false
SpiritOfLight.Delay = 0;
SpiritOfLight.Speed = Vector(0,0);

SpiritOfLight.LightSoul = Isaac.GetEntityVariantByName("Spirit of light");
local Dir = 
{
    [Direction.UP] = Vector(0,-1),
    [Direction.DOWN] = Vector(0,1),
    [Direction.LEFT] = Vector(-1,0),
    [Direction.RIGHT] = Vector(1,0)
}
SpiritOfLight.preventDeath = function(self)
    Isaac.DebugString("isaac is gay!");
    SpiritOfLight.postDeathFollower = SpawnFollower(SpiritOfLight.LightSoul);
end

SpiritOfLight.onCollected = function(self)
    
end

SpiritOfLight.idle = function(self)

end


ptb:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,function(_,tookDamage, amount, flag, source, frames)
    if SpiritOfLight.postDeath == false and SpiritOfLight.playerhas then
        if tookDamage.Type == EntityType.ENTITY_PLAYER then 
            if Isaac.GetPlayer(0):GetHearts()<=amount then
                if Isaac.GetPlayer(0):GetSoulHearts()<=amount then
                    Isaac.GetPlayer(0):SetFullHearts()
                    SpiritOfLight.preventDeath();
                    SpiritOfLight.postDeath = true;
                    return false;
                end
            end
        end
    end
end)

local function makeTear(Ent,_Direction)
    return Game():Spawn(EntityType.ENTITY_TEAR,TearVariant.BLUE,Ent.Position,_Direction,ent,0,Ent.InitSeed):ToTear()
end


ptb:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,function(_,Entity_Familiar) 
    local player = Isaac.GetPlayer(0);
    local FireDir = player:GetFireDirection();
    local sprite = Entity_Familiar:GetSprite();
    Entity_Familiar.Position = player.Position+Vector(math.sin(Isaac.GetFrameCount()/100)*30,math.cos(Isaac.GetFrameCount()/100)*30);

    if FireDir == Direction.UP then
        sprite:Play("IdleUp",false)
    elseif FireDir == Direction.DOWN then
        sprite:Play("IdleDown",false)
    elseif FireDir == Direction.RIGHT then
        sprite.FlipX = false;
        sprite:Play("IdleSide",false)
    elseif FireDir == Direction.LEFT then
        sprite.FlipX = true;
        sprite:Play("IdleSide",false)
    end 

    if SpiritOfLight.Delay == 0 and SpiritOfLight.Fire then
        if SpiritOfLight.Speed then
            player:FireTear(Entity_Familiar.Position ,SpiritOfLight.Speed + Vector(1,1) ,false ,false ,false)
        end
        SpiritOfLight.Delay = player.MaxFireDelay;
        SpiritOfLight.Fire = false;
        if player:GetFireDirection() == Direction.UP then
            sprite:Play("ShootUp",false)
        elseif  player:GetFireDirection() == Direction.DOWN then
            sprite:Play("ShootDown",false)
        elseif  player:GetFireDirection() == Direction.RIGHT then
            sprite.FlipX = false;
            sprite:Play("ShootSide",false)
        elseif  player:GetFireDirection() == Direction.LEFT then
            sprite.FlipX = true;
            sprite:Play("ShootSide",false)
        end 
    end

    if SpiritOfLight.Delay >=1 then SpiritOfLight.Delay = SpiritOfLight.Delay - 1; end
end,SpiritOfLight.LightSoul)

ptb:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_,Tear)
    local player = Isaac.GetPlayer(0);
    if Tear.SpawnerType == EntityType.ENTITY_PLAYER then
        SpiritOfLight.Fire = true;
        if SpiritOfLight.postDeath then
            if ((Tear.Velocity.Y-1) ~= SpiritOfLight.Speed.Y) and ((Tear.Velocity.X-1) ~= SpiritOfLight.Speed.X) then
                Tear:Remove();
                SpiritOfLight.Speed = Tear.Velocity;
            else
                Tear.Velocity = Tear.Velocity - Vector(1,1);
            end
        end
    end

end)

ptb:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,function(_,EntityPlayer,Cache)
    if Cache == CacheFlag.CACHE_DAMAGE then 
        SpiritOfLight.pDamage = EntityPlayer.Damage;
    end
end,Isaac.GetPlayer(0))
-------------------------------------------------------


function ptb:mainLoop()
    TimerManager:updateTimers();
end
ptb:AddCallback( ModCallbacks.MC_POST_UPDATE,ptb.mainLoop);

