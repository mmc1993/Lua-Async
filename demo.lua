local Timer = {
    mTasks = {}
}

function Timer:Insert(tick, func)
    table.insert(self.mTasks, { mTick = os.clock() + tick, mFunc = func })
end

function Timer:Update(tick)
    local dels = {}
    local time = os.clock()
    for k, task in pairs(self.mTasks) do
        if task.mTick <= time then
            table.insert(dels, k)
            task.mFunc()
        end
    end

    for i, v in ipairs(dels) do
        self.mTasks[v] = nil
    end
end

Timer:Insert(2, function() 
    print("clock: \t", os.date("%y-%m-%d %H:%M:%S"))
    Timer:Insert(2, function()
        print("clock: \t", os.date("%y-%m-%d %H:%M:%S"))
        Timer:Insert(2, function()
            print("clock: \t", os.date("%y-%m-%d %H:%M:%S"))
        end)
    end)
end)

require("Async").New()
:Ok(function(ok, no)
    Timer:Insert(2, function() print("Async clock: ", os.date("%y-%m-%d %H:%M:%S")) ok() end)
end)
:Ok(function(ok, no)
    Timer:Insert(2, function() print("Async clock: ", os.date("%y-%m-%d %H:%M:%S")) ok() end)
end)
:Ok(function(ok, no)
    Timer:Insert(2, function() print("Async clock: ", os.date("%y-%m-%d %H:%M:%S")) ok() end)
end)

while true do
    Timer:Update(os.clock())
end