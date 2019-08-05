require("resources.scripts.timers")
require("item")
local TimerManager = createTManager();

local ptb = RegisterMod("PathToBlessing",0);

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


function ptb:mainLoop()
    TimerManager:updateTimers();
end
ptb:AddCallback( ModCallbacks.MC_POST_UPDATE,ptb.mainLoop);

