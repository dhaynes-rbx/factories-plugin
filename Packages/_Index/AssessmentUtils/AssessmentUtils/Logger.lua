local RunService = game:GetService("RunService")
--!strict
local Packages = script.parent.Parent
local Dash = require(Packages.Dash)
local tls = require(script.Parent.tls)
local deepcopy = require(script.Parent.Deepcopy)

--[[--
    @classmod Logger class
]]

type Context = {
    level: string?,
    name: string?,
    prefix: string?,
    player: Player?,
}

type Sink = {
    maxLevel: number,
    log: (Logger, message: string, context: Context) -> nil,
}

type Cache = {
    sinks: { [number]: Sink },
    context: Context,
    version: number,
}

type Logger = {
    name: string,
    sinks: { [number]: Sink },
    children: { [Logger]: boolean },
    parent: Logger,
    context: { string: Context },
    version: number,
    active: { [number]: boolean },
    Levels: {
        [string]: string,
        fromString: (string) -> string | nil,
    },
    LevelOrder: { string },
    new: (parent: Logger, name: string, isRoot: boolean) -> Logger,
    init: (instantiateRoot: boolean) -> nil,
    get: (name: string?) -> Logger,
    setParent: (Logger, parent: Logger) -> nil,
    getChild: (Logger, name: string) -> Logger | nil,
    addSink: (Logger, sink: Sink) -> nil,
    newSink: (Logger, level: string, logFunction: (string, Context) -> nil) -> nil,
    setContext: (Logger, context: Context) -> nil,
    dispatchSinks: (Logger, message: string, context: Context) -> nil,
    fatalError: (Logger, ...string) -> nil,
    error: (Logger, ...string) -> nil,
    warning: (Logger, ...string) -> nil,
    info: (Logger, ...string) -> nil,
    debug: (Logger, ...string) -> nil,
    trace: (Logger, ...string) -> nil,
}

local Logger = {}
Logger.__index = Logger

--[[--
    @table Levels Available log levels
    @field Error
    @field Warning
    @field Info
    @field Debug
    @field Trace
]]
Logger.Levels = {
    FatalError = "FatalError",
    Error = "Error",
    Warning = "Warning",
    Info = "Info",
    Debug = "Debug",
    Trace = "Trace",
}

local levelOrder = {
    Logger.Levels.FatalError,
    Logger.Levels.Error,
    Logger.Levels.Warning,
    Logger.Levels.Info,
    Logger.Levels.Debug,
    Logger.Levels.Trace,
}

local levelRank = {}
for k, v in pairs(levelOrder) do
    levelRank[v] = k
end

--[[--
    @function Levels.fromString Finds and returns a logger level from string
    @string Logger level as string
    @treturn string|nil - Matching Logger.Level or nil
]]
function Logger.Levels.fromString(str: string): string | nil
    if type(str) ~= "string" then
        return nil
    end
    for _, k in pairs(levelOrder) do
        if string.lower(k) == string.lower(str) then
            return k
        end
    end
    return nil
end

--[[--
    @function new Constructor
    @tparam Logger parent - Parent logger
    @string name - Name of logger
    @tparam boolean isRoot - True if this is meant to be the root logger
    @treturn Logger - New instance of Logger
]]
function Logger.new(parent: Logger, name: string, isRoot: boolean): Logger
    isRoot = isRoot or false
    -- Don't call init on root
    if isRoot == false then
        Logger.init(false)
    end
    local logger = {
        name = name or "",
        sinks = {},
        children = {},
        parent = parent,
        context = {},
        version = 1,
        active = {},
    }

    for k, _ in pairs(Logger.Levels) do
        if parent then
            logger.active[k] = parent.active[k]
        else
            logger.active[k] = false
        end
    end

    if parent then
        parent.children[logger] = true
    end

    setmetatable(logger, Logger)
    return logger
end

--[[--
    @lfunction setActive Activate `level` and above logging levels.
    @string level - Log level
    @string node - Logger to effect
]]
local function setActive(level: string, node: Logger): nil
    local maxLevel = levelRank[level]
    if maxLevel then
        for n = 1, maxLevel do
            node.active[levelOrder[n]] = true
        end
        for k, _ in pairs(node.children) do
            setActive(level, k)
        end
    end
end

--[[--
    @function init Initializes this logger
]]
function Logger.init(instantiateRoot: boolean): nil
    if Logger.root == nil then
        -- Listen for global logs
        local logService = game:GetService("LogService")
        logService.MessageOut:Connect(globalLogger)
        instantiateRoot = true
    end

    if instantiateRoot then
        Logger.root = Logger.new(nil, "", true)
        -- Default logger to info level
        setActive(Logger.Levels.Info, Logger.root)
    end
end

--[[--
    @function get Finds and returns a logger or creates it if it doesn't already exist
    @string name - Name of the logger. The hierarchy of loggers is built on paths split by `.`.
    @treturn Logger - The found or new logger
]]
function Logger.get(name: string?): Logger
    if Logger.root == nil then
        Logger.init(true)
    end
    if name == nil then
        return Logger.root
    end
    local parts = name:split(".")
    local log = Logger.root
    for _, part in ipairs(parts) do
        local logChild = log:getChild(part)
        if logChild == nil then
            logChild = Logger.new(log, part)
        end
        log = logChild
    end
    return log
end

local LOG_WARNING_COOLDOWN_SECONDS: number = 5
local callStackCounter: number = 0
local lastLogWarning: number = 0
--[[--
    @lfunction globalLogger Pipes global logs through this logger
    @string message - The log
    @tparam Enum.MessageType type - The type of message
]]
function globalLogger(message: string, type: Enum.MessageType): nil
    -- Call stacks are logged line by line, ignore them
    if string.find(message, "Stack Begin", 1, true) == 1 then
        callStackCounter = callStackCounter + 1
    elseif string.find(message, "Stack End", 1, true) == 1 then
        callStackCounter = callStackCounter - 1
    end
    if callStackCounter > 0 then
        return
    elseif string.find(message, "^", 1, true) == nil then
        -- Throttle these warnings
        if tick() - lastLogWarning > LOG_WARNING_COOLDOWN_SECONDS then
            warn("^Logs using print|warn|error will not be tracked. Please use Logger.")
            lastLogWarning = tick()
        end
        local logLevel = "unknown"
        if Logger.root then
            if type == Enum.MessageType.MessageOutput then
                logLevel = Logger.Levels.Debug
            elseif type == Enum.MessageType.MessageInfo then
                logLevel = Logger.Levels.Info
            elseif type == Enum.MessageType.MessageWarning then
                logLevel = Logger.Levels.Warning
            elseif type == Enum.MessageType.MessageError then
                logLevel = Logger.Levels.Error
            end
            processLog(logLevel, Logger.root, table.pack(message))
        end
    end
end

--[[--
    @lfunction getCache Returns the log cache for a given Logger
    @string node - The log
    @return Cache - The requested cache
]]
local function getCache(node: Logger): Cache
    local key = "log_node_" .. tostring(node)
    local cache: Cache = tls[key]
    if cache == nil then
        cache = {
            sinks = {},
            context = {},
        }
        tls[key] = cache
    end
    return cache
end

--[[--
    @lfunction setDirty Set the dirty flag for `node` and all its children.
    @string node - Logger to effect
]]
local function setDirty(node: Logger): nil
    node.version = node.version + 1
    for k, _ in pairs(node.children) do
        setDirty(k)
    end
end

--[[--
    @lfunction isDirty Determines if cache is dirty for given node
    @string node - Logger
    @return bool - True if dirty
]]
local function isDirty(node: Logger): boolean
    return node.version ~= getCache(node).version
end

--[[--
    @lfunction updateCache Updates the context and sinks cache for `node` and its ancestors.
    @string node - Logger
    @return string - The name of the node
]]
local function updateCache(node: Logger): string
    local cache = getCache(node)
    if not isDirty(node) then
        return cache.context.name
    end

    if not node.parent then
        cache.context = Dash.join(node.context, { name = node.name })
        cache.context.name = node.name
        cache.sinks = node.sinks
        cache.version = node.version
        return node.name
    end

    local parentName = updateCache(node.parent)
    local name = (parentName:len() > 0 and parentName .. "." or "") .. node.name

    -- Dictionary join the context. List join the sinks. Concatenate the prefixes.
    local parentCache = getCache(node.parent)
    cache.context = Dash.join(parentCache.context, node.context, { name = name })
    if parentCache.context.prefix and node.context.prefix then
        cache.context.prefix = parentCache.context.prefix .. node.context.prefix
    end
    cache.sinks = Dash.append({}, parentCache.sinks, node.sinks)
    cache.version = node.version

    return name
end

--[[--
    @lfunction processLog Processes the log
    @tparam Logger.Levels - Logger level
    @tparam Logger node - Logger
    @tparam any args - Additional arguments
]]
function processLog(level: string, node: Logger, args: any): nil
    if isDirty(node) then
        updateCache(node)
    end

    -- Collect per-log context.
    local fullContext = {
        level = level,
        rawMessage = args,
    }

    -- Call any functions in the context.
    for k, v in pairs(getCache(node).context) do
        if type(v) == "function" then
            fullContext[k] = v()
        else
            fullContext[k] = v
        end
    end

    -- Interpolate the log message.
    local interpMsg
    if args.n == 0 then
        interpMsg = "LUMBERYAK INTERNAL: No log message given"
    else
        interpMsg = args[1]
    end
    if fullContext.prefix then
        interpMsg = fullContext.prefix .. interpMsg
    end

    if interpMsg:find("{") then
        local i = 1
        interpMsg = (
            interpMsg:gsub("{(.-)}", function(w)
                -- Treat {} as a positional arg.
                if w == "" then
                    i = i + 1
                    return tostring(args[i])
                end
                local c = fullContext[w]
                return c and tostring(c)
            end)
        )
        if i < args.n then
            interpMsg = interpMsg .. "\nLUMBERYAK INTERNAL: Too many arguments given for format string"
        elseif i > args.n then
            interpMsg = interpMsg .. "\nLUMBERYAK INTERNAL: Too few arguments given for format string"
        end
    elseif args.n > 1 then
        interpMsg = interpMsg .. "\nLUMBERYAK INTERNAL: Too many arguments given for format string"
    end

    node:dispatchSinks(interpMsg, fullContext)
    return interpMsg
end

--[[--
    @lfunction log Logs a message
    @tparam Logger.Levels - Logger level
    @tparam Logger node - Logger
    @tparam any args - Additional arguments
]]
function log(level: string, node: Logger, args: any): nil
    local interpMsg = processLog(level, node, args)
    if string.find(interpMsg, "^", 1, true) ~= nil then
        return
    end
    -- Prior to piping output, we add a recognizable character to avoid sending the log back through sinks.
    local consoleMsg = "^" .. interpMsg
    if level == Logger.Levels.Trace or level == Logger.Levels.Info or level == Logger.Levels.Debug then
        print(consoleMsg)
    elseif level == Logger.Levels.Warning then
        warn(consoleMsg)
    elseif level == Logger.Levels.Error then
        task.spawn(function()
            error(consoleMsg)
        end)
    elseif level == Logger.Levels.FatalError then
        error(consoleMsg)
    end
end

--[[--
    @function setParent Set the parent of this Logger and update its cache, active bits and dirty bit.
    @tparam Logger parent - The intended parent
]]
function Logger:setParent(parent: Logger): nil
    if self.parent then
        self.parent.children[self] = nil
    end

    updateCache(parent)
    self.parent = parent
    self.parent.children[self] = true

    local maxLevel = -1
    for _, sink in pairs(getCache(parent).sinks) do
        local sinkLevel = levelRank[sink.maxLevel]
        if sinkLevel then
            maxLevel = math.max(maxLevel, levelRank[sink.maxLevel])
        end
    end

    if maxLevel > -1 then
        setActive(levelOrder[maxLevel], self)
    end

    setDirty(self)
end

--[[--
    @function getChild Finds and returns the child of this logger by name
    @string name - Name of the child logger
    @treturn Logger|nil Child logger if found
]]
function Logger:getChild(name: string): Logger | nil
    for child, _ in pairs(self.children) do
        if child.name == name then
            return child
        end
    end
    return nil
end

--[[--
    @function addSink Adds a new log handler
    @tparam Sink sink - The sink object
]]
function Logger:addSink(sink: Sink): nil
    setActive(sink.maxLevel, self)
    table.insert(self.sinks, sink)
    setDirty(self)
end

--[[--
    @function newSink Creates a new log handler and adds it to this Logger
    @tparam string level
    @tparam (string,Context)->nil logFunction
]]
function Logger:newSink(level: string, logFunction: (string, Context) -> nil): nil
    local sink = {
        maxLevel = level,
        log = function(self, message, context)
            logFunction(message, context)
        end,
    }
    self:addSink(sink)
end

--[[--
    @function setContext Sets the active context on this logger
    @tparam Context context
]]
function Logger:setContext(context: Context): nil
    self.context = context
    setDirty(self)
end

--[[--
    @function dispatchSinks Sends logs to all sinks
    @string message - The message
    @tparam Context context - The log context
]]
function Logger:dispatchSinks(message: string, context: Context): nil
    -- Sinks don't need to understand what FatalError is, so prior to dispatching we change to error.
    if context.level == Logger.Levels.FatalError then
        context = deepcopy(context)
        context.level = Logger.Levels.Error
    end
    -- Send the message to any sinks that are listening to the right level.
    local rank = levelRank[context.level]
    for _, k in pairs(getCache(self).sinks) do
        if levelRank[k.maxLevel] and levelRank[k.maxLevel] >= rank then
            k:log(message, context)
        end
    end
end

--[[--
    @function fatalError - Logs an error level log stopping the thread it is called from.
    @tparam any ...
]]
function Logger:fatalError(...)
    if not self.active[Logger.Levels.FatalError] then
        return
    end
    log(Logger.Levels.FatalError, self, table.pack(...))
end

--[[--
    @function error - Logs an error level log
    @tparam any ...
]]
function Logger:error(...)
    if not self.active[Logger.Levels.Error] then
        return
    end
    log(Logger.Levels.Error, self, table.pack(...))
end

--[[--
    @function warning - Logs a warning level log
    @tparam any ...
]]
function Logger:warning(...)
    if not self.active[Logger.Levels.Warning] then
        return
    end
    log(Logger.Levels.Warning, self, table.pack(...))
end

--[[--
    @function info - Logs an info level log
    @tparam any ...
]]
function Logger:info(...)
    if not self.active[Logger.Levels.Info] then
        return
    end
    log(Logger.Levels.Info, self, table.pack(...))
end

--[[--
    @function debug - Logs a debug level log
    @tparam any ...
]]
function Logger:debug(...)
    if not self.active[Logger.Levels.Debug] then
        return
    end
    log(Logger.Levels.Debug, self, table.pack(...))
end

--[[--
    @function trace - Logs a trace level log
    @tparam any ...
]]
function Logger:trace(...)
    if not self.active[Logger.Levels.Trace] then
        return
    end
    log(Logger.Levels.Trace, self, table.pack(...))
end

return Logger
