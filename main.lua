require("resources.scripts.timers")
require("item")
require("passiveitem")


local TimerManager = createTManager();
local ptb = RegisterMod("PathToBlessing",0);


------------------- GOLDEN WIND ITEM ------------------
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


    local SpiritOfLight = Passive:new(ptb,"Spirit of the light")
    SpiritOfLight.postDeath = false;
    SpiritOfLight.Fire = false
    SpiritOfLight.Delay = 0;
    SpiritOfLight.Speed = Vector(0,0);
    SpiritOfLight.familiarCount = 0;

    local function SpawnFollower(Type)
        return Isaac.Spawn(EntityType.ENTITY_FAMILIAR,Type,0,Isaac.GetPlayer(0).Position,Vector(0,0),Isaac.GetPlayer(0)):ToFamiliar()
    end

    SpiritOfLight.LightSoul = Isaac.GetEntityVariantByName("Spirit of light");
    local Dir = {
        [Direction.UP] = Vector(0,-1),
        [Direction.DOWN] = Vector(0,1),
        [Direction.LEFT] = Vector(-1,0),
        [Direction.RIGHT] = Vector(1,0)}
    SpiritOfLight.preventDeath = function(self)
        SpiritOfLight.postDeathFollower = SpawnFollower(SpiritOfLight.LightSoul);
    end 

    local DirString = 
    {
        [Direction.UP] = "Up",
        [Direction.DOWN] = "Down",
        [Direction.LEFT] = "Side",
        [Direction.RIGHT] = "Side"
    }

    local DirAngles =
    {
        [Direction.UP] = 270,
        [Direction.DOWN] = 90,
        [Direction.LEFT] = 180,
        [Direction.RIGHT] = 0
    }

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

    ptb:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,function(_,LightSoulEntity)
        LightSoulEntity.OrbitDistance = Vector(30,30);
        LightSoulEntity.OrbitSpeed = 0.01
        LightSoulEntity:AddToOrbit(7007)
    end,SpiritOfLight.LightSoul)
    
    ptb:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,function(_,LightSoulEntity) 
        local player = Isaac.GetPlayer(0);
        local FireDir = player:GetFireDirection();
        local MovementDir = player:GetMovementDirection();
        local sprite = LightSoulEntity:GetSprite();
        local data = LightSoulEntity:GetData();

        if data.Delay == nil then data.Delay = 0; end
        if data.Direct ~= MovementDir then if MovementDir ~= Direction.NO_DIRECTION then data.Direct = MovementDir end end
        LightSoulEntity.OrbitSpeed = 0.01
        LightSoulEntity.OrbitDistance = Vector(30,30);

        LightSoulEntity.Velocity = LightSoulEntity:GetOrbitPosition(player.Position + player.Velocity) - LightSoulEntity.Position;
        
        if data.Delay == 0 and FireDir ~= Direction.NO_DIRECTION then
            if SpiritOfLight.Speed then
                player:FireTear(LightSoulEntity.Position ,SpiritOfLight.Speed + Vector(1,1) ,false ,false ,false)
            end
            data.Delay = player.MaxFireDelay;
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
        elseif FireDir == Direction.NO_DIRECTION then
            if data.Direct == Direction.UP then
                sprite:Play("IdleUp",false)
            elseif data.Direct == Direction.DOWN then
                sprite:Play("IdleDown",false)
            elseif data.Direct == Direction.RIGHT then
                sprite.FlipX = false;
                sprite:Play("IdleSide",false)
            elseif data.Direct == Direction.LEFT then
                sprite.FlipX = true;
                sprite:Play("IdleSide",false)
            end 
        else
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
        end
        
        if data.Delay >=1 then data.Delay = data.Delay - 1; end
    end,SpiritOfLight.LightSoul)

    ptb:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_,Tear)
        local player = Isaac.GetPlayer(0);
        if Tear.SpawnerType == EntityType.ENTITY_PLAYER then
            if SpiritOfLight.postDeath then
                if ((Tear.Velocity.Y-1) ~= SpiritOfLight.Speed.Y) and ((Tear.Velocity.X-1) ~= SpiritOfLight.Speed.X) then
                    Tear:Remove();
                    SpiritOfLight.Speed = Tear.Velocity;
                else
                    Tear.Velocity = Tear.Velocity - Vector(1,1);
                end
            else
                if ((Tear.Velocity.Y-1) ~= SpiritOfLight.Speed.Y) and ((Tear.Velocity.X-1) ~= SpiritOfLight.Speed.X) then
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

---------------------Sunset on a bill------------------

    local SunsetOnABill = Passive:new(ptb,"Sunset on a bill");
    SunsetOnABill.alreadySummonedOnThisFloor = false;
    SunsetOnABill.familiarDestructionCounter = 0;
    SunsetOnABill.familiar = nil;
    SunsetOnABill.onCollected = function()
        Isaac.GetPlayer(0):AddCoins(50);
    end

    ptb:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION ,function(_,Pickup,Collider,Low)
        if Pickup.Variant == PickupVariant.PICKUP_COIN and Isaac.GetPlayer(0):GetNumCoins()<99 then
            if not SunsetOnABill.alreadySummonedOnThisFloor then
                local chance = RNG():RandomInt(100);
                if chance > 50 then 
                    SunsetOnABill.familiar = SpawnFollower(SpiritOfLight.LightSoul);
                    SunsetOnABill.alreadySummonedOnThisFloor = true;
                end
            end
        end
    end)

    ptb:AddCallback(ModCallbacks.MC_POST_NEW_ROOM ,function(_) 
        if SunsetOnABill.playerhas and SunsetOnABill.alreadySummonedOnThisFloor then 
            SunsetOnABill.familiarDestructionCounter = SunsetOnABill.familiarDestructionCounter + 1;
            if SunsetOnABill.familiarDestructionCounter >= 3 then 
                SunsetOnABill.familiar:Die();
                SunsetOnABill.familiarDestructionCounter = 0;
            end
        end
    end)

    ptb:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL ,function(_)
        SunsetOnABill.alreadySummonedOnThisFloor = false;
        SunsetOnABill.familiarDestructionCounter = 0;
    end)
-------------------------------------------------------


---------------------------Ray-------------------------
local Ray = Passive:new(ptb,"Ray");
Ray.Ray = Isaac.GetEntityVariantByName("RayEntity");
Ray.Delay = 2;
Ray.Charge = 28;
Ray.tuple = nil;
Ray.onCollected = function()
    SpawnFollower(Ray.Ray)
end

ptb:AddCallback(ModCallbacks.MC_FAMILIAR_INIT , function(_,RayEntity)
    local data = RayEntity:GetData()
    data.delay = Ray.Delay;
    data.charge = 0;
    data.lastDirection = Direction.DOWN;
    if Ray.tuple == nil then
        RayEntity.Parent = Isaac.GetPlayer(0);
        Ray.tuple = RayEntity;
    else
        RayEntity.Parent = Ray.tuple;
        Ray.tuple = RayEntity;
    end
end, Ray.Ray)

function Follow(self)
    local player = Isaac.GetPlayer(0);
    local direction = player:GetMovementDirection();
    local firedirection = player:GetFireDirection();

    if direction == Direction.NO_DIRECTION then direction = Direction.DOWN end
    if firedirection ~= Direction.NO_DIRECTION then direction = firedirection end

    if direction == Direction.DOWN then
        direction = Direction.LEFT;
    elseif direction == Direction.UP then
        direction = Direction.RIGHT;
    elseif direction == Direction.LEFT then
        direction = Direction.UP;
    else
        direction = Direction.DOWN;
    end
    self.Velocity = ((self.Parent.Position + Dir[direction]*30) - self.Position)/6
end

ptb:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE , function(_,RayEntity)
    local player = Isaac.GetPlayer(0);
    local FireDir = player:GetFireDirection();
    local MovementDir = player:GetMovementDirection();
    local sprite = RayEntity:GetSprite();
    local data = RayEntity:GetData();
    Follow(RayEntity);
    if MovementDir == Direction.NO_DIRECTION then MovementDir = Direction.DOWN; end
    if FireDir ~= Direction.NO_DIRECTION then
        data.lastDirection = FireDir;
        if data.charge < Ray.Charge then
            if FireDir == Direction.LEFT then
                sprite.FlipX = true;
            else
                sprite.FlipX = false;
            end
            sprite:Play("FloatCharge"..DirString[FireDir]);
            data.charge = data.charge + 1;
        end
    elseif data.charge == Ray.Charge then
        if data.lastDirection == Direction.LEFT then
            sprite.FlipX = true;
        else
            sprite.FlipX = false;
        end
        sprite:Play("FloatShoot"..DirString[data.lastDirection]);
        EntityLaser.ShootAngle (5, RayEntity.Position, DirAngles[data.lastDirection], 5, Vector(10,-20), RayEntity);
        data.charge = 0;
    else
        if not sprite:IsPlaying("FloatShoot"..DirString[data.lastDirection]) or sprite:IsFinished("FloatShoot"..DirString[data.lastDirection]) then
            if MovementDir == Direction.LEFT then
                sprite.FlipX = true;
            else
                sprite.FlipX = false;
            end
            sprite:Play("Float"..DirString[MovementDir]);
        end
        data.charge = 0;
    end
    local time = Isaac.GetFrameCount();
    if time%500==0 then 
        if true then
            for i = 0, 15 do
                Isaac.Spawn(Isaac.GetEntityTypeByName("Fire"),Isaac.GetEntityVariantByName("Fire"),0,RayEntity.Position,Vector(math.sin((2 * math.pi/15)*i),math.cos((2 * math.pi/15)*i)),RayEntity);
            end
        end
    end
end, Ray.Ray)
-------------------------------------------------------

function ptb:mainLoop()
    TimerManager:updateTimers();
end
ptb:AddCallback( ModCallbacks.MC_POST_UPDATE,ptb.mainLoop);

