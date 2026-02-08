---@class MysteryCondition : ConditionBase
---@field sub_type MysteryType

local condition_base = require("HitboxViewer.box.hurt.conditions.condition_base")
local data = require("HitboxViewer.data.init")

local mod_enum = data.mod.enum

---@class MysteryCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@param color integer?
---@param state ConditionState?
---@param key integer?
---@param sub_type MysteryType?
---@return MysteryCondition
function this:new(state, color, key, sub_type)
    local o = condition_base.new(self, mod_enum.condition_type.Mystery, state, color, key)
    setmetatable(o, self)
    ---@cast o MysteryCondition
    o.sub_type = sub_type or mod_enum.mystery_state.Yes
    return o
end

---@param args table<string, any>
---@return MysteryCondition
function this:new_from_serial(args)
    return this.new(self, args.state, args.color, args.key, args.sub_type)
end

---@param part_group PartGroup
---@return ConditionResult, integer
function this:check(part_group)
    local match = (
        part_group.part_data.can_mystery_core
        and (part_group.part_data.is_mystery_core and "Mystery" or "Yes")
    ) or "No"
    if match == mod_enum.mystery_state[self.sub_type] then
        return self.state == mod_enum.condition_state.Highlight
                and mod_enum.condition_result.Highlight
            or mod_enum.condition_result.Hide,
            self.color
    end
    return mod_enum.condition_result.None, 0
end

return this
