
--TODO:перенести реализацию в timers.lua (я хз как)
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
ptb.hasTest = false;
ptb.TestBaff = false;

function ptb:use_test( )	
    if not ptb.hasTest then ptb.hasTest = true end
    Isaac.GetPlayer(0):AddNullCostume(ptb.TEST_COSTUME);
    ptb.invulnerability = true;
    ptb.TestBaff = true;
    Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
    Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_FLYING);
	Isaac.GetPlayer(0):EvaluateItems();
    TManager:addTimer("test_item_use",120,nil,function();
        ptb.invulnerability = false;
        ptb.TestBaff = false;
        Isaac.GetPlayer(0):TryRemoveNullCostume(ptb.TEST_COSTUME);
        Isaac.GetPlayer(0):EvaluateItems();
    end)
end

function ptb:mainLoop()
    TManager:updateTimers(Game():GetFrameCount());
end

function ptb:onCache(EntityPlayer, Cache)
    Isaac.DebugString(tostring(ptb.TestBaff).." "..tostring(EntityPlayer))
    if ptb.TestBaff then  
        if Cache == CacheFlag.CACHE_DAMAGE then 
            EntityPlayer.Damage = EntityPlayer.Damage+5; 
        end
        if Cache == CacheFlag.CACHE_FIREDELAY then 
            EntityPlayer.MaxFireDelay = EntityPlayer.MaxFireDelay-5;
        end
        if Cache == CacheFlag.CACHE_FLYING then
            EntityPlayer.CanFly = true;
        end
    end
end

function ptb:onDamag(TookDamage, DamageAmount, DamageFlag, DamageSource, DamageCountdownFrames)
    if ptb.invulnerability then return true end
end

ptb:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG,ptb.onDamag,Isaac.GetPlayer(0))

ptb:AddCallback( ModCallbacks.MC_USE_ITEM, ptb.use_test, ptb.COLL_TEST ); 

ptb:AddCallback( ModCallbacks.MC_POST_UPDATE,ptb.mainLoop);

ptb:AddCallback( ModCallbacks.MC_EVALUATE_CACHE,ptb.onCache)
