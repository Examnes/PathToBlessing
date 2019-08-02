local TManager = {timers = {}};
TManager.__index = TManager;

function TManager:updateTimers(time)
    for k,v in pairs(TManager.timers) do
        if v.startTime+v.Duration < time then
            v.CallBack(v.Extra)
            TManager.timers[k] = nil;
        end
    end
end

function TManager:addTimer(timer_name,duration,extra_data,timer_callback)
    local timer = {};
    timer.startTime = Game():GetFrameCount();
    timer.Duration = duration;
    timer.CallBack = timer_callback;
    timer.Extra = extra_data;
    TManager.timers[timer_name] = timer;
end

local ptb = RegisterMod("PathToBlessing");


ptb.COLL_TEST = Isaac.GetItemIdByName("Desu");
ptb.TEST_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/copypaste.anm2");
ptb.invulnerability = false;
 

function ptb:use_test( )	
    ptb.player:AddNullCostume(ptb.TEST_COSTUME)
    ptb.invulnerability = true;
    ptb.player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    ptb.player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	ptb.player:EvaluateItems()
    TManager:addTimer("test_item_use",120,nil,function()
        
        ptb.invulnerability = false;
        ptb.player:TryRemoveNullCostume(ptb.TEST_COSTUME);
        ptb.player:EvaluateItems()
    end)
end

function ptb:mainLoop()
    TManager:updateTimers(Game():GetFrameCount());
end

function ptb:onCache(EntityPlayer, Cache)
    if ptb.invulnerability then  
        if Cache == CacheFlag.CACHE_DAMAGE then 
            EntityPlayer.Damage = EntityPlayer.Damage + 5 
        end
        if Cache == CacheFlag.CACHE_FIREDELAY then 
            EntityPlayer.FireDelay = EntityPlayer.FireDelay - 5 
        end
        EntityPlayer.CanFly = true;
    end
end

function ptb:onDamage(TookDamage, DamageAmount, DamageFlag, DamageSource, DamageCountdownFrames)
    if ptb.invulnerability then return true end
end

function ptb:onStart(_,bool)
    ptb.player = Isaac.GetPlayer(0);
    ptb:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG,ptb.onDamage,ptb.player)
end

ptb:AddCallback( ModCallbacks.MC_USE_ITEM, ptb.use_test, ptb.COLL_TEST ); 

ptb:AddCallback( ModCallbacks.MC_POST_UPDATE,ptb.mainLoop);

ptb:AddCallback( ModCallbacks.MC_EVALUATE_CACHE,ptb.onCache)
