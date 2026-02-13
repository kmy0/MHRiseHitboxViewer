---@class (exact) Player : FriendCharacter
---@field base snow.player.PlayerQuestBase
---@field guard_type GuardType?
---@field direction Vector3f
---@field hurtboxes table<via.physics.Collidable, PlayerHurtBox>

local char_cls = require("HitboxViewer.character.char_base")
local data = require("HitboxViewer.data.init")
local e = require("HitboxViewer.util.game.enum")
local util_misc = require("HitboxViewer.util.misc.init")
local util_ref = require("HitboxViewer.util.ref.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum

---@class Player
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = char_cls })

---@param type CharType
---@param base snow.player.PlayerQuestBase
---@param name string
---@return Player
function this:new(type, base, name)
    local o = char_cls.new(self, type, base, name)
    ---@cast o Player
    setmetatable(o, self)

    return o
end

function this:update_direction()
    self.direction = self.base:getDirection()
end

function this:update_guard()
    util_misc.try(function()
        if self.base:isActionStatusTag(e.get("snow.player.ActStatus").Guard) then
            self.guard_type = mod_enum.guard_type.GUARD
        elseif self.base:checkHyperArmor() then
            self.guard_type = mod_enum.guard_type.HYPER
        elseif self.base:checkSuperArmor() then
            self.guard_type = mod_enum.guard_type.SUPER
        else
            self.guard_type = nil
        end
    end, function(_)
        self.guard_type = nil
    end)

    if self.guard_type then
        self:update_direction()
    end
end

function this:get_guard_direction()
    return self.direction
end

---@return boolean
function this:is_quest()
    return util_ref.is_a(self.base, "snow.player.PlayerQuestBase")
end

function this:is_dummybox_disabled()
    if self.type == mod_enum.char.MasterPlayer then
        return util_table.empty(self.dummyboxes)
    end
    return char_cls.is_dummybox_disabled(self)
end

---@return HurtBoxBase[]?
function this:update_hurtboxes()
    if self:is_hurtbox_disabled() then
        return
    end

    self:update_guard()

    local ret = {}
    for col, box in pairs(self.hurtboxes) do
        local box_state, boxes = box:update()
        if box_state == mod_enum.box_state.Draw and boxes then
            table.move(boxes, 1, #boxes, #ret + 1, ret)
        elseif box_state == mod_enum.box_state.Dead then
            self.hurtboxes[col] = nil
        end
    end

    if not util_table.empty(ret) then
        return ret
    end
end

return this
