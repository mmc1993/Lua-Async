local Async = {
    mCo = nil,      --  coroutine
    mFlag = "ok",   --  ok/no
    mIter = 0,
    mArgs = {},
    mCaller = {},
    mErrorFn = function()end,
}

function Async.Copy(src)
    if type(src) == "table" then
        local ret = {}
        for k, v in pairs(src) do
            ret[k] = Async.Copy(v)
        end
        return ret
    end
    return src
end

function Async.Bind(fn, ...)
    local params = {...}
    return function(...)
        local args = {}
        for k, v in pairs(params) do
            table.insert(args, v)
        end
        for i, v in ipairs({...}) do
            table.insert(args, v)
        end
        return fn(table.unpack(args))
    end
end

function Async:Next(flag, ...)
    self.mFlag, self.mArgs = flag, { ... }
    local status = not self.mCo and "dead"
            or coroutine.status(self.mCo)
    if status == "suspended" then
        coroutine.resume(self.mCo)
    elseif status == "dead" then
        local fn = Async.Bind(self.Exec,self)
        self.mCo = coroutine.create(fn)
        coroutine.resume(self.mCo)
    elseif status == "running" then
        return true
    end
    return false
end

function Async:Reg(flag, func)
    assert(type(flag) == "string")
    assert(type(func) == "function")
    table.insert(self.mCaller, { mFunc = func,
                                 mFlag = flag })
    if #self.mCaller - self.mIter == 1 then
        self:Next(self.mFlag, table.unpack(self.mArgs))
    end
    return self
end

function Async:Exec()
    while self.mIter < #self.mCaller do
        local caller = self.mCaller[self.mIter + 1]
        if self.mFlag == caller.mFlag then
            local stat, ret = xpcall(caller.mFunc,
                Async.mErrorFn,
                Async.Bind(self.Next, self, "ok"),
                Async.Bind(self.Next, self, "no"),
                table.unpack(self.mArgs))
            if not ret then coroutine.yield(self.mCo) end
        end
        self.mIter = self.mIter + 1
    end
end

function Async:Ok(func) return self:Reg("ok", func) end
function Async:No(func) return self:Reg("no", func) end
function Async:Error(fn) self.mErrorFn = fn end

function Async.New(...)
    local instance = Async.Copy(Async)
    instance.mFlag = "ok" 
    instance.mArgs = {...}
    return instance
end

return Async
