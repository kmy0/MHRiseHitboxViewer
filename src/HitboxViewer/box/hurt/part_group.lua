---@class (exact) PartGroup
---@field is_show boolean
---@field is_highlight boolean
---@field name string
---@field part_data PartData
---@field condition ConditionResult
---@field condition_color integer
---@field hurtboxes BigEnemyHurtBox[]
---@field key string
---@field last_updated integer

---@class (exact) PartData
---@field hitzone table<string, integer>
---@field part_group snow.enemy.EnemyDef.PartsGroup
---@field meat snow.enemy.EnemyDef.Meat
---@field is_enabled boolean
---@field can_break boolean
---@field is_broken boolean
---@field can_lost boolean
---@field can_mystery_core boolean
---@field is_mystery_core boolean
---@field extract string
---@field _enemy_base snow.enemy.EmBossCharacterBase
---@field _enemy_damage snow.enemy.EnemyDamageParam
---@field _rsc snow.RSCController
---@field _resource_idx integer
---@field _rs_id integer

local conditions = require("HitboxViewer.box.hurt.conditions.init")
local data = require("HitboxViewer.data.init")
local e = require("HitboxViewer.util.game.enum")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local util_game = require("HitboxViewer.util.game.init")
local util_misc = require("HitboxViewer.util.misc.init")

local mod_enum = data.mod.enum

---@class PartGroup
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param enemy_base snow.enemy.EmBossCharacterBase
---@param part_group snow.enemy.EnemyDef.PartsGroup
---@param meat snow.enemy.EnemyDef.Meat
---@param enemy_hurtbox BigEnemyHurtBox
---@return PartData
local function get_part_data(enemy_base, part_group, meat, enemy_hurtbox)
    local enemy_param = enemy_base:get_RefEmUserData()
    local enemy_tune = enemy_param:get_TuneDataUserData()

    local can_mystery_core = false
    util_misc.try(function()
        can_mystery_core = enemy_base:isEnableMystery()
            and enemy_base:isActivateEnableMysteryCoreParts(part_group)
    end)

    ---@type PartData
    local ret = {
        is_enabled = false,
        extract = e.get("snow.enemy.EnemyDef.ExtractiveType")[enemy_base:getExtractiveType(
            part_group
        )],
        can_break = enemy_tune:getPartsBreakMaxLevel(part_group) > 0,
        is_broken = false,
        is_mystery_core = false,
        part_group = part_group,
        meat = meat,
        can_mystery_core = can_mystery_core,
        can_lost = enemy_tune:getPartsLossData(part_group) ~= nil,
        hitzone = {},
        _enemy_base = enemy_base,
        _enemy_damage = enemy_base:get_DamageParam(),
        _rsc = util_game.get_component(enemy_base:get_GameObject(), "snow.RSCController") --[[@as snow.RSCController]],
        _resource_idx = enemy_hurtbox.resource_idx,
        _rs_id = enemy_hurtbox.set_idx,
    }
    return ret
end

---@param cache table<string, PartGroup>
---@param enemy_base snow.enemy.EmBossCharacterBase
---@param part_group snow.enemy.EnemyDef.PartsGroup
---@param meat snow.enemy.EnemyDef.Meat
---@param enemy_hurtbox BigEnemyHurtBox
---@return PartGroup
function this:new(cache, enemy_base, part_group, meat, enemy_hurtbox)
    ---@type PartGroup
    local o
    local key = string.format("%s|%s", part_group, meat)
    if not cache[key] then
        o = {
            is_show = true,
            is_highlight = false,
            hurtboxes = {},
            condition = mod_enum.condition_result.None,
            condition_color = 0,
            part_data = get_part_data(enemy_base, part_group, meat, enemy_hurtbox),
            name = data.get_em_part_name(enemy_base:get_EnemyType(), meat),
            key = key,
            last_updated = 0,
        }
        setmetatable(o, self)
    else
        o = cache[key]
    end

    cache[key] = o
    table.insert(o.hurtboxes, enemy_hurtbox)
    return o
end

---@protected
function this:_update_hitzones()
    for attr_name, meat_attr in e.iter("snow.enemy.EnemyDef.MeatAttr") do
        self.part_data.hitzone[attr_name] = self.part_data._enemy_base:getMeatAdjustValue(
            self.part_data.meat,
            meat_attr,
            self.part_data.part_group
        )
    end
end

---@param conds table<ConditionType, ConditionBase[]>?>
function this:update(conds)
    local enabled = false

    util_misc.try(function()
        enabled = self.part_data._rsc:checkEnabledRequestSet(
            self.part_data._resource_idx,
            self.part_data._rs_id
        )
    end)

    local changed = self.part_data.is_enabled ~= enabled

    if not self.part_data.is_enabled and not changed and self.last_updated ~= 0 then
        self.last_updated = frame_counter.frame
        return
    end

    self.part_data.is_enabled = enabled

    if
        self.part_data.can_break
        and not self.part_data.is_broken
        and (not conds or conds[mod_enum.condition_type.Break])
    then
        if self.part_data.can_lost then
            self.part_data.is_broken =
                self.part_data._enemy_damage:isPartsLoss(self.part_data.part_group)
        else
            self.part_data.is_broken =
                self.part_data._enemy_damage:isPartsBreak(self.part_data.part_group)
        end
    end

    if
        self.part_data.can_mystery_core and (not conds or conds[mod_enum.condition_type.Mystery])
    then
        self.part_data.is_mystery_core =
            self.part_data._enemy_base:isActiveMysteryCoreParts(self.part_data.part_group)
    end

    if not conds then
        self:_update_hitzones()
    elseif conds[mod_enum.condition_type.Element] then
        for _, cond in pairs(conds[mod_enum.condition_type.Element]) do
            ---@cast cond ElementCondition
            if cond.sub_type == mod_enum.element.All then
                self:_update_hitzones()
                break
            end

            local attr_name = mod_enum.element[cond.sub_type]
            self.part_data.hitzone[attr_name] = self.part_data._enemy_base:getMeatAdjustValue(
                self.part_data.meat,
                e.get("snow.enemy.EnemyDef.MeatAttr")[attr_name],
                self.part_data.part_group
            )
        end
    end

    self.condition, self.condition_color = conditions.check_part_group(self)
    self.last_updated = frame_counter.frame
end

---@return boolean
function this:is_updated()
    return frame_counter.frame - self.last_updated < 60 * 3
end

---@param elem_name string
function this:get_hitzone(elem_name)
    return self.part_data.hitzone[elem_name]
end

return this
