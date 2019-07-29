local ptb = RegisterMod("PathToBlessing");
local test_item = Isaac.GetItemIdByName("Desu");
function ptb:use_test( )	
    Isaac.DebugString("I am exit!");
end

ptb:AddCallback( ModCallbacks.MC_USE_ITEM, ptb.use_test, test_item ); 