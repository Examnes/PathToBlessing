require("resources.scripts.timers")
local TimerManager = createTManager();

local ptb = RegisterMod("PathToBlessing",0);

ptb.COLL_TEST = Isaac.GetItemIdByName("Desu");
ptb.TEST_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/copypaste.anm2");
ptb.invulnerability = false;
ptb.hasTest = false;
ptb.TestBaff = false;

function ptb:use_test( )	
    if not ptb.hasTest then ptb.hasTest = true end
    Isaac.GetPlayer(0):AddNullCostume(ptb.TEST_COSTUME);--вотнуть стрелу в колено
    ptb.invulnerability = true;--включить щиты
    ptb.TestBaff = true;--добавить статы
    Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
    Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_FLYING);
	Isaac.GetPlayer(0):EvaluateItems();
    TimerManager:addTimer("test_item_use",240,nil,function();
        ptb.invulnerability = false;
        ptb.TestBaff = false;
        Isaac.GetPlayer(0):TryRemoveNullCostume(ptb.TEST_COSTUME);
        Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_DAMAGE);
        Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
        Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_FLYING);
        Isaac.GetPlayer(0):EvaluateItems();
    end) -- то, что произойдет по истичении 120 кадров (карета превращается в тыкву)
end

function ptb:mainLoop()
    TimerManager:updateTimers();
end

function ptb:onCache(EntityPlayer,Cache)
    if ptb.TestBaff then  
            if Cache == CacheFlag.CACHE_DAMAGE then 
                EntityPlayer.Damage = EntityPlayer.Damage + 5; 
            end
            if Cache == CacheFlag.CACHE_FIREDELAY then
                EntityPlayer.MaxFireDelay = EntityPlayer.MaxFireDelay - 5;
            end
            if Cache == CacheFlag.CACHE_FLYING then
               EntityPlayer.CanFly = true;
            end
        end
end

function ptb:onDamage(TookDamage, DamageAmount, DamageFlag, DamageSource,DamageCountdownFrames)
    if ptb.invulnerability and TookDamage.Type == EntityType.ENTITY_PLAYER then return false end
end

ptb:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG,ptb.onDamage)

ptb:AddCallback( ModCallbacks.MC_USE_ITEM, ptb.use_test, ptb.COLL_TEST ); 

ptb:AddCallback( ModCallbacks.MC_POST_UPDATE,ptb.mainLoop);

ptb:AddCallback( ModCallbacks.MC_EVALUATE_CACHE,ptb.onCache,Isaac.GetPlayer(0))
