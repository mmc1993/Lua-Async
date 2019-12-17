# Lua-Async

这是一个基于协程的异步调用库, 该库的设计思路类似JavaScript的Promise, 但相比Promise, 它有更多的灵活性.

```Lua
--  引入Async
local Async = require("Async")

--  创建Async
--  可传递参数到接下来的调用中
Async.New(...)

--  注册异步调用
Async.New(...)
:Ok(function(ok, no, ...) return no() end)  --  在Ok管道注册回调, 之后进入No管道
:No(function(ok, no, ...) return ok() end)  --  在No管道注册回调, 之后进入Ok管道
:Ok(function(ok, no, ...) return no() end)  --  在Ok管道注册回调, 之后进入No管道
:No(function(ok, no, ...) return ok() end)  --  在No管道注册回调, 之后进入Ok管道

--  异常捕获
Async.New(...)
:Error(function() print("捕获异常...") end) --  注册异常捕获函数
:Ok(function(ok, no, ...) return no() end)  --  在Ok管道注册回调, 之后进入No管道
:No(function(ok, no, ...) return ok() end)  --  在No管道注册回调, 之后进入Ok管道
:Ok(function(ok, no, ...) return no() end)  --  在Ok管道注册回调, 之后进入No管道
:No(function(ok, no, ...) return ok() end)  --  在No管道注册回调, 之后进入Ok管道
```
## JavaScript Promise 对比
**Js版本**
```Js
new Promise((resolve, reject) => {
    resolve();  //  下一步
})
.then((resolve, reject) => {
    reject();  //  下一步
})
.catch(() => { 
    //  异常处理
})
```

**Lua版本**
```Lua
require("Async").New()
:Ok(function(ok, no)
    return ok()     --  下一步
end)
:Ok(function(ok, no)
    return no()     --  下一步
end)
:No(function(ok, no)
    return no()     --  异常处理
end)
```

## 简单的使用例子

```Lua
--  一个简易的定时器
local Timer = {
    mTasks = {}
}

--  为定时器插入一个任务
function Timer:Insert(tick, func)
    table.insert(self.mTasks, { mTick = os.clock() + tick, mFunc = func })
end

--  更新定时器
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

--  3层嵌套异步调用
Timer:Insert(2, function() 
    print("clock: \t", os.date("%y-%m-%d %H:%M:%S"))
    Timer:Insert(2, function()
        print("clock: \t", os.date("%y-%m-%d %H:%M:%S"))
        Timer:Insert(2, function()
            print("clock: \t", os.date("%y-%m-%d %H:%M:%S"))
        end)
    end)
end)

--  通过Async 3层异步调用
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

**调用结果**
> C:\MyWork\Git\Lua-Async>lua demo.lua
> clock:          19-12-17 21:00:23
> Async clock:    19-12-17 21:00:23
> clock:          19-12-17 21:00:25
> Async clock:    19-12-17 21:00:25
> clock:          19-12-17 21:00:27
> Async clock:    19-12-17 21:00:27
```

**调用结果**
C:\MyWork\Git\Lua-Async>lua demo.lua

clock:          19-12-17 21:00:23

Async clock:    19-12-17 21:00:23

clock:          19-12-17 21:00:25

Async clock:    19-12-17 21:00:25

clock:          19-12-17 21:00:27

Async clock:    19-12-17 21:00:27