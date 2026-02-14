---@class (exact) PlayerHurtBox : HurtBoxBase
---@field guard_box GuardBox
---@field parent Player

local data = require("HitboxViewer.data.init")
local guard_box = require("HitboxViewer.box.hurt.guard")
local hurtbox_base = require("HitboxViewer.box.hurt.hurtbox_base")

local mod_enum = data.mod.enum

---@class PlayerHurtBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hurtbox_base })

---@param collidable via.physics.Collidable
---@param parent Player
---@param resource_idx integer
---@param set_idx integer
---@param collidable_idx integer
---@return PlayerHurtBox?
function this:new(collidable, parent, resource_idx, set_idx, collidable_idx)
    local o = hurtbox_base.new(self, collidable, parent, resource_idx, set_idx, collidable_idx)

    if not o then
        return
    end

    ---@cast o PlayerHurtBox
    setmetatable(o, self)
    o.guard_box = guard_box:new(parent, o)
    return o
end

---@return BoxState, HurtBoxBase[]?
function this:update()
    ---@type HurtBoxBase[]?
    local ret
    local box_state = self.parent:check_iframe() and mod_enum.box_state.None
        or hurtbox_base.update(self)

    if box_state == mod_enum.box_state.Draw then
        ret = {}
        table.insert(ret, self)
    end

    if box_state == mod_enum.box_state.Draw then
        local guard_state = self.guard_box:update()
        if guard_state == mod_enum.box_state.Draw then
            ---@cast ret HurtBoxBase[]
            table.insert(ret, self.guard_box)
        end
    end
    return box_state, ret
end

return this
