---@class (exact) BigEnemyHurtBox : HurtBoxBase
---@field part_group PartGroup

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local hurtbox_base = require("HitboxViewer.box.hurt.hurtbox_base")
local part_group = require("HitboxViewer.box.hurt.part_group")

local mod_enum = data.mod.enum

---@class BigEnemyHurtBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hurtbox_base })

---@param collidable via.physics.Collidable
---@param parent BigEnemy
---@param resource_idx integer
---@param set_idx integer
---@param collidable_idx integer
---@return BigEnemyHurtBox?
function this:new(collidable, parent, resource_idx, set_idx, collidable_idx)
    local o = hurtbox_base.new(self, collidable, parent, resource_idx, set_idx, collidable_idx)

    if not o then
        return
    end

    local userdata = collidable:get_UserData() --[[@as snow.hit.userdata.EmHitDamageShapeData]]
    local parent_userdata = userdata:get_ParentUserData() --[[@as snow.hit.userdata.EmHitDamageRSData]]

    ---@cast o BigEnemyHurtBox
    setmetatable(o, self)
    o.part_group = part_group:new(
        parent.parts,
        parent.base,
        parent_userdata:get_Group(),
        userdata:get_Meat(),
        o
    )

    if not o.part_group then
        return
    end
    return o
end

---@return BoxState
function this:update_data()
    local config_mod = config.current.mod

    if not self.part_group.is_show then
        return mod_enum.box_state.None
    end

    if
        not self.part_group.is_highlight
        and (
            (
                config_mod.hurtboxes.default_state ~= mod_enum.default_hurtbox_state.Draw
                and self.part_group.condition ~= mod_enum.condition_result.Highlight
            ) or self.part_group.condition == mod_enum.condition_result.Hide
        )
    then
        return mod_enum.box_state.None
    end

    if self.part_group.is_highlight then
        self.color = config_mod.hurtboxes.color.highlight
    elseif self.part_group.condition == mod_enum.condition_result.Highlight then
        self.color = self.part_group.condition_color
    else
        return hurtbox_base.update_data(self)
    end

    return mod_enum.box_state.Draw
end

return this
