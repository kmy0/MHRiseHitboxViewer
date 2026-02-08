---@class (exact) BigEnemy : EnemyCharacter
---@field base snow.enemy.EmBossCharacterBase
---@field parts table<string, PartGroup>
---@field pg_queue PGUpdateQueue

---@class (exact) PGUpdateQueue : Queue
---@field queue string[]
---@field get fun(self: PGUpdateQueue): fun(): string

local char_cls = require("HitboxViewer.character.char_base")
local conditions = require("HitboxViewer.box.hurt.conditions.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local queue = require("HitboxViewer.util.misc.queue")
local util_misc = require("HitboxViewer.util.misc.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum

---@class BigEnemy
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = char_cls })

---@param base snow.enemy.EmBossCharacterBase
---@param name string
---@return BigEnemy
function this:new(base, name)
    local o = char_cls.new(self, mod_enum.char.BigMonster, base, name)
    ---@cast o BigEnemy
    setmetatable(o, self)
    o.parts = {}
    o.pg_queue = queue:new() --[[@as PGUpdateQueue]]

    return o
end

---@return boolean
function this:is_dead()
    local ret = false
    util_misc.try(function()
        ret = not self:is_valid() or self.base:checkDie()
    end)

    return ret
end

---@return PartGroup[]
function this:get_sorted_part_groups()
    local ret = {}
    for _, part_group in pairs(self.parts) do
        table.insert(ret, part_group)
    end

    ---@param x PartGroup
    ---@param y PartGroup
    ---@return boolean
    table.sort(ret, function(x, y)
        if x.key < y.key then
            return true
        end
        return false
    end)
    return ret
end

---@return HurtBoxBase[]?
function this:update_hurtboxes()
    if self:is_hurtbox_disabled() then
        return
    end

    local ret = {}
    if config.gui.current.gui.hurtbox_info.is_opened or not conditions:empty() then
        ---@type table<ConditionType, ConditionBase[]>?>
        local conds
        if not config.gui.current.gui.hurtbox_info.is_opened then
            conds = conditions.get_all()
        end

        if self.pg_queue:empty() then
            self.pg_queue:extend_back(util_table.keys(self.parts))
        end

        for part_key in self.pg_queue:iter(config.max_part_group_updates) do
            local part_group = self.parts[part_key]
            if part_group then
                part_group:update(conds)
            end
        end
    else
        self.pg_queue:clear()
    end

    local boxes = self:_update_boxes(self.hurtboxes)
    if boxes then
        table.move(boxes, 1, #boxes, #ret + 1, ret)
    end

    if not util_table.empty(ret) then
        return ret
    end
end

return this
