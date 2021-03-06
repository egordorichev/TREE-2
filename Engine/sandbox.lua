--A function that creates new sandboxed global environment.

local basexx = require("Engine.basexx")
local bit = require("bit")

local _LuaBCHeader = string.char(0x1B).."LJ"

return function(Machine, APIS)
  local GLOB = {
    assert       = assert,
    error        = error,
    ipairs       = ipairs,
    pairs        = pairs,
    next         = next,
    pcall        = pcall,
    select       = select,
    tonumber     = tonumber,
    tostring     = tostring,
    type         = type,
    unpack       = unpack,
    _VERSION     = _VERSION,
    xpcall       = xpcall,
    setmetatable = setmetatable,
    getmetatable = getmetatable,
    rawget       = rawget,
    rawset       = rawset,
    rawequal     = rawequal,
    string = {
      byte    = string.byte,
      char    = string.char,
      find    = string.find,
      format  = string.format,
      gmatch  = string.gmatch,
      gsub    = string.gsub,
      len     = string.len,
      lower   = string.lower,
      match   = string.match,
      rep     = string.rep,
      reverse = string.reverse,
      sub     = string.sub,
      upper   = string.upper
    },
    table = {
      insert = table.insert,
      maxn   = table.maxn,
      remove = table.remove,
      sort   = table.sort,
      concat = table.concat
    },
    math = {
      abs          = math.abs,
      acos         = math.acos,
      asin         = math.asin,
      atan         = math.atan,
      atan2        = math.atan2,
      ceil         = math.ceil,
      cos          = math.cos,
      cosh         = math.cosh,
      deg          = math.deg,
      exp          = math.exp,
      floor        = math.floor,
      fmod         = math.fmod,
      frexp        = math.frexp,
      huge         = math.huge,
      ldexp        = math.ldexp,
      log          = math.log,
      log10        = math.log10,
      max          = math.max,
      min          = math.min,
      modf         = math.modf,
      pi           = math.pi,
      pow          = math.pow,
      rad          = math.rad,
      random       = love.math.random, --Replaced with love.math versions
      randomseed   = love.math.setRandomSeed,
      sin          = math.sin,
      sinh         = math.sinh,
      sqrt         = math.sqrt,
      tan          = math.tan,
      tanh         = math.tanh,
      noise        = love.math.noise, --LOVE releated apis
      b64enc       = basexx.to_base64, --Will be replaced by love.math ones in love 0.11
      b64dec       = basexx.from_base64,
      hexenc       = basexx.to_hex,
      hexdec       = basexx.from_hex,
      compress     = function(...) return love.math.compress(...):getString() end,
      decompress   = love.math.decompress,
      isConvex     = love.math.isConvex,
      triangulate  = love.math.triangulate,
      noise        = love.math.noise,
      randomNormal = love.math.randomNormal
    },
    coroutine={
      create = coroutine.create,
      resume = coroutine.resume,
      yield  = coroutine.yield,
      status = coroutine.status
    },
    os={
      time  = os.time,
      clock = os.clock,
      date  = os.date
    },
    bit={
      cast    = bit.cast,
      bnot    = bit.bnot,
      band    = bit.band,
      bor     = bit.bor,
      bxor    = bit.bxor,
      lshift  = bit.lshift,
      rshift  = bit.rshift,
      arshift = bit.arshift,
      tobit   = bit.tobit,
      tohex   = bit.tohex,
      rol     = bit.rol,
      ror     = bit.ror,
      bswap   = bit.swap
    }
  }
  GLOB.getfenv = function(f)
    if type(f) ~= "function" then return error("bad argument #1 to 'getfenv' (function expected, got "..type(f)) end
    local ok, env = pcall(getfenv,f)
    if not ok then return error(env) end
    if env.love == love then env = {} end --Protection
    return env
  end
  GLOB.setfenv = function(f,env)
    if type(f) ~= "function" then return error("bad argument #1 to 'setfenv' (function expected, got "..type(f)) end
    if type(env) ~= "table" then return error("bad argument #2 to 'setfenv' (table expected, got "..type(env)) end
    local oldenv = getfenv(f)
    if oldenv.love == love then return end --Trying to make a crash ! evil.
    local ok, err = pcall(setfenv,f,env)
    if not ok then return error(err) end
  end
  GLOB.loadstring = function(data)
    if data:sub(1,3) == _LuaBCHeader then return error("LOADING BYTECODE IS NOT ALLOWED, YOU HACKER !") end
    local chunk, err = loadstring(data)
    if not chunk then return nil, err end
    setfenv(chunk,GLOB)
    return chunk
  end
  GLOB.load = function(iter,chunkname)
    if type(iter) ~= "function" then return error("Chunk Iterator should be a function, provided: "..type(iter)) end
    
    if chunkname and type(chunkname) ~= "string" then return error("Chunk Name should be a string or a nil, provided: "..type(chunkname)) end
    
    local first = true
    local function i()
      local line = iter()
      if first and line then
        if line:sub(1,3) == _LuaBCHeader then return error("LOADING BYTECODE IS NOT ALLOWED, YOU HACKER !") end
        first = false
      end
      return line
    end
    local ok, chunk = pcall(load,i,chunkname)
    if ok then
      setfenv(chunk,GLOB)
      return chunk
    else
      return error(chunk)
    end
  end
  GLOB.coroutine.sethook = function(co,...)
    if type(co) ~= "thread" then return error("bad argument #1 (thread expected, got "..type(co)..")") end
    local ok, err = pcall(debug.sethook,co,...)
    if not ok then return error(err) end
    return err
  end
  GLOB.coroutine.running = function()
    local curco = coroutine.running()
    if Machine and Machine.CO and curco == Machine.CO then return end
    return curco
  end
  
  GLOB.APIS = APIS
  for k,v in pairs(APIS) do
    GLOB[k] = v
  end
  
  GLOB._G=GLOB --Mirror Mirror
  
  setfenv(Machine.Chunk, GLOB)
  
  return GLOB
end