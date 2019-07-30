require("timers")

local ptb = RegisterMod("PathToBlessing");
local test_item = Isaac.GetItemIdByName("Desu");

local TimerManager = setupTimerManager();


function ptb:use_test( )	
    Isaac.DebugString("I am exit!");
    TimerManager.addTimer("test_item_use",20,"hah gaay!",function(str)
        Isaac.DebugString(str);
    end)
end

function ptb:mainLoop()
    TimerManager.updateTimers(Game():GetFrameCount());
end

ptb:AddCallback( ModCallbacks.MC_USE_ITEM, ptb.use_test, test_item ); 
ptb:AddCallback( ModCallbacks.MC_POST_UPDATE,ptb.mainLoop);