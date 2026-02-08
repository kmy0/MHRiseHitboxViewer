---@class CustomAttackType
---@field types table<string, fun(entry: AttackLogEntry): boolean>
---@field sorted string[]

---@diagnostic disable-next-line: unused-local
local util_table = require("HitboxViewer.util.misc.table")

---@class CustomAttackType
local this = {
    types = {},
    sorted = {},
}

-- All possible 'entry' data is located at HitboxViewer/attack_log.lua and HitboxViewer/data/snow.lua
-- keep in mind that booleans are strings

function this.types.Windbox(entry)
    return entry.userdata_type:is_a("snow.hit.userdata.HitAttackAppendShapeData")
end

function this.types.Unguardable(entry)
    return entry.more_data._GuardableType == 2
end

function this.types.FrontHitOnly(entry)
    ---@diagnostic disable-next-line: undefined-field
    return entry.userdata_shape._EnemyHitCheckVec == 0
end

function this.types.NoMotionValue(entry)
    return entry.motion_value == 0
end

---@param entry AttackLogEntry
---@return string?
function this.check(entry)
    entry.misc_type = nil
    for _, key in ipairs(this.sorted) do
        if this.types[key](entry) then
            entry.misc_type = key
            return key
        end
    end
end

-- Evaluation order
-- this.sorted = util_table.keys(this.types)
-- table.sort(this.sorted)
this.sorted = {
    "NoMotionValue",
    "FrontHitOnly",
    "Unguardable",
    "Windbox",
}

return this
