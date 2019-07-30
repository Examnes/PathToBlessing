
function setupTimerManager()
    local TManager;
    TManager.timers = {};
    return TManager;
end

function TimersManager:updateTimers(time)
    table.foreach(this.timers,function(k,v)
        if not v.startTime then v.startTime = time end
        if v.startTime+v.Duration < time then
            v.CallBack(v.Extra)
            table.remove(this.timers,k)
        end
    end)
end

function TimersManager:addTimer(timer_name,duration,extra_data,timer_callback)
    local timer = {};
    timer.Duration = duration;
    timer.CallBack = timer_callback;
    timer.Extra = extra_data;
    this.timers[timer_name] = timer;
end