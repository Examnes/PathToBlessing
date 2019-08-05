function createTManager()
    local tmanager = {timers = {}}
    tmanager.__index = tmanager;

    function tmanager:updateTimers()
        for k,v in pairs(self.timers) do
            if v.startTime+v.Duration < Game():GetFrameCount() then
                v.CallBack(v.Extra)
                self.timers[k] = nil;
            end
        end
    end
    function tmanager:addTimer(timer_name,duration,extra_data,timer_callback)
        local timer = {};
        timer.startTime = Game():GetFrameCount();
        timer.Duration = duration;
        timer.CallBack = timer_callback;
        timer.Extra = extra_data;
        self.timers[timer_name] = timer;
    end
    return tmanager;
end



