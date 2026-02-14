---@class (exact) PlayerHurtBox : HurtBoxBase
---@field guard_box GuardBox
---@field parent Player

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local e = require("HitboxViewer.util.game.enum")
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

---@return BoxState
function this:update_data()
    local config_mod = config.current.mod

    if self.parent.damage_reflex_type == -1 then
        return hurtbox_base.update_data(self)
    end

    local enum_name = e.get("snow.player.DamageReflexInfo.Type")[self.parent.damage_reflex_type]
    if config_mod.hurtboxes.damage_reflex.disable[enum_name] then
        return mod_enum.box_state.None
    end

    if config_mod.hurtboxes.damage_reflex.color_enable[enum_name] then
        self.color = config_mod.hurtboxes.damage_reflex.color[enum_name]
    else
        self.color = config_mod.hurtboxes.damage_reflex.color.one_color
    end
    return mod_enum.box_state.Draw
end

---@return BoxState, HurtBoxBase[]?
function this:update()
    ---@type HurtBoxBase[]?
    local ret
    local box_state = (self.parent.damage_reflex_type == -1 and self.parent:check_iframe())
            and mod_enum.box_state.None
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
