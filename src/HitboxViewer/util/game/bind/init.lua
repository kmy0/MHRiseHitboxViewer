local e = require("HitboxViewer.util.game.enum")
local util_table = require("HitboxViewer.util.misc.table")

local this = {
    listener = require("HitboxViewer.util.game.bind.listener"),
    manager = require("HitboxViewer.util.game.bind.manager"),
    monitor = require("HitboxViewer.util.game.bind.monitor"),
    util = require("HitboxViewer.util.game.bind.util"),
}

---@return boolean
function this.init()
    if
        util_table.any({
            e.new("snow.Pad.Button", function(_, value)
                return value <= 65536
            end),
            e.new("via.hid.KeyboardKey", function(key, _)
                return not util_table.contains(
                    { "Control", "Menu", "DefinedEnter", "Shift", "Return", "OEM_5", "OEM_2" },
                    key
                )
            end),
            e.new("snow.StmInputManager.ActiveDevice"),
        }, function(_, value)
            return not value.ok
        end)
    then
        return false
    end

    return true
end

return this
