Passive = {}
Passive.__index = Passive;

function Passive:new(mod,name)
    local item = {};
    item.stats = {};
    item.stats.damage = 0;
    item.stats.tears = 0;
    item.stats.speed = 0;
    item.stats.shotspeed = 0;
    item.stats.range = 0;
    item.stats.flight = false;
    item.playerhas = false;
    item.idle = function(EntityPlayer) end;
    item.onCollected = function() end;
    item.ID = Isaac.GetItemIdByName(name);
    item.name = name;
    item.shouldUseCache = false
    CollectibleType[name] = item.ID;

    mod:AddCallback( ModCallbacks.MC_POST_PEFFECT_UPDATE , function(EntityPlayer)
        if item.playerhas then return end
        if Isaac.GetPlayer(0):HasCollectible(item.ID) then
            item.onCollected()
            item.playerhas = true;
            
            if item.stats.damage then  Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_DAMAGE); item.shouldUseCache  = true;end
            if item.stats.tears then Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_FIREDELAY); item.shouldUseCache  = true;end
            if item.stats.speed then Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_SPEED); item.shouldUseCache  = true;end
            if item.stats.shotspeed then Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_SHOTSPEED); item.shouldUseCache  = true;end
            if item.stats.range then Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_RANGE); item.shouldUseCache  = true;end
            if item.stats.range then Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_RANGE); item.shouldUseCache  = true;end
            
            if item.shouldUseCache  then Isaac.GetPlayer(0):EvaluateItems(); end

        end
    end)

    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,function(_,EntityPlayer,Cache)

        if item.playerhas and item.shouldUseCache then

            if Cache == CacheFlag.CACHE_DAMAGE then 
                EntityPlayer.Damage = EntityPlayer.Damage + item.stats.damage; 
            end

            if Cache == CacheFlag.CACHE_FIREDELAY then
                EntityPlayer.MaxFireDelay = EntityPlayer.MaxFireDelay + item.stats.tears;
            end

            if Cache == CacheFlag.CACHE_FLYING then
               EntityPlayer.CanFly = EntityPlayer.CanFly or item.stats.flight;
            end

            if Cache == CacheFlag.CACHE_SPEED then
                EntityPlayer.MoveSpeed = EntityPlayer.MoveSpeed + item.stats.speed;
            end

            if Cache == CacheFlag.CACHE_SHOTSPEED then
                EntityPlayer.ShotSpeed = EntityPlayer.ShotSpeed + item.stats.shotspeed;
            end

            if Cache == CacheFlag.CACHE_RANGE then
                EntityPlayer.TearHeight = EntityPlayer.TearHeight - item.stats.range;
            end

        end

    end,Isaac.GetPlayer(0))

    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE,function(EntityPlayer)
        if item.playerhas then
            item.idle(EntityPlayer);
        end
    end)

    setmetatable(item,self);
    return item;
end