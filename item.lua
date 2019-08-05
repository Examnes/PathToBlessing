require("resources.scripts.timers")
Item = {}
Item.__index = Item;

function Item:new(mod,name,tmanager)
    local item = {};
    item.Use = function() end;
    item.Idle = function() end;
    item.PostBaff = function() end;
    item.PlayerHas = false;
    item.ID = Isaac.GetItemIdByName(name);
    item.BuffDuration = 0;
    item.BuffFlag = false;
    item.BaffActivated = false;

    item.Damage = 0;
    item.Tears = 0;
    item.Speed = 0;
    item.Flight = false;
    item.Invincibility = false;

    mod:AddCallback( ModCallbacks.MC_USE_ITEM, function()
        if not item.PlayerHas then
             item.PlayerHas = true 
        end
        item:Use();
        if item.BuffFlag then
            item.BaffActivated = true;
            Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_ALL);
            Isaac.GetPlayer(0):EvaluateItems();
            tmanager:addTimer(name.."-s temporary baff timer",item.BuffDuration,nil,function()
                item.BaffActivated = false;
                Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_ALL);
                Isaac.GetPlayer(0):EvaluateItems();
                item:PostBaff();
            end)
        end
    end, item.ID);

    mod:AddCallback( ModCallbacks.MC_POST_UPDATE,function() if item.PlayerHas then item:Idle() end end);

    mod:AddCallback( ModCallbacks.MC_EVALUATE_CACHE,function(_,EntityPlayer,Cache)
        Isaac.DebugString("Hay i am debug: "..tostring(EntityPlayer))
        if item.BaffActivated then  
            if Cache == CacheFlag.CACHE_DAMAGE then 
                EntityPlayer.Damage = EntityPlayer.Damage + item.Damage; 
            end
            if Cache == CacheFlag.CACHE_FIREDELAY then
                EntityPlayer.MaxFireDelay = EntityPlayer.MaxFireDelay + item.Tears;
            end
            if Cache == CacheFlag.CACHE_FLYING then
               EntityPlayer.CanFly = item.Flight;
            end
            if Cache == CacheFlag.CACHE_SPEED then
                EntityPlayer.Speed = item.Speed;
            end
        end
    end,Isaac.GetPlayer(0));

    mod:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG,function(TookDamage, DamageAmount, DamageFlag, DamageSource,DamageCountdownFrames)
        if item.Invincibility and TookDamage.Type == EntityType.ENTITY_PLAYER then return false end
    end)

    setmetatable(item,self);
    return item;
end