local cache = require("HitboxViewer.util.misc.cache")
local e = require("HitboxViewer.util.game.enum")
local s = require("HitboxViewer.util.ref.singletons")

local this = {}

---@return "KEYBOARD" | "PAD"
function this.get_input_device()
    local active_device = s.get("snow.StmInputManager")._ActiveDevice
    return e.get("snow.StmInputManager.ActiveDevice")[active_device._ActiveDevice] == "Pad"
            and "PAD"
        or "KEYBOARD"
end

---@return snow.Pad.Device
function this.get_pad()
    return s.get("snow.Pad").hard
end

---@return snow.GameKeyboard.HardwareKeyboard
function this.get_kb()
    return s.get("snow.GameKeyboard").hardKeyboard
end

this.get_pad = cache.memoize(this.get_pad)
this.get_kb = cache.memoize(this.get_kb)

return this
