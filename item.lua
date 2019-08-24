require("resources.scripts.timers")
Item = {}
Item.__index = Item;

function get_field_names(t)
    local names = {}
    local i,v=next(t,nil)
    while i do
        table.insert(names,i)
        i,v=next(t,i)
    end
    return names
end

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
        end
    end,Isaac.GetPlayer(0));

    mod:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG,function(_,TookDamage, DamageAmount, DamageFlag, DamageSource,DamageCountdownFrames)
        if item.Invincibility and TookDamage.Type == EntityType.ENTITY_PLAYER then return false end
    end)

    setmetatable(item,self);
    return item;
end