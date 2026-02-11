local config = require("HitboxViewer.config.init")
local e = require("HitboxViewer.util.game.enum")
local game_lang = require("HitboxViewer.util.game.lang")
local s = require("HitboxViewer.util.ref.singletons")
local util_game = require("HitboxViewer.util.game.init")
local util_misc = require("HitboxViewer.util.misc.init")
local util_table = require("HitboxViewer.util.misc.table")

local this = {
    gui = require("HitboxViewer.data.gui"),
    snow = require("HitboxViewer.data.snow"),
    mod = require("HitboxViewer.data.mod"),
    custom_attack_type = require("HitboxViewer.data.custom_attack_type"),
}

local snow_map = this.snow.map

---@param type_def_name string
---@param t BoxSettings
---@param predicate (fun(key: string, value: any): boolean)?
---@param color integer?
local function write_fields_to_config(type_def_name, t, predicate, color)
    for name, _ in pairs(util_game.get_fields(type_def_name, predicate)) do
        t.disable[name] = false
        if color then
            t.color[name] = color
            t.color_enable[name] = false
        end
    end
end

---@param strings string[]
---@param table BoxSettings
---@param color integer?
---@param ignore_values string[]?
local function write_strings_to_config(strings, table, color, ignore_values)
    for _, name in ipairs(strings) do
        if ignore_values and util_table.contains(ignore_values, name) then
            goto continue
        end
        table.disable[name] = false
        if color then
            table.color[name] = color
            table.color_enable[name] = false
        end
        ::continue::
    end
end

---@return table<snow.enemy.EnemyDef.EmTypes, table<snow.enemy.EnemyDef.Meat, string>>
local function get_monster_part_names()
    ---@type table<snow.enemy.EnemyDef.EmTypes, table<snow.enemy.EnemyDef.Meat, string>>
    local ret = {}
    local monster_list = s.get("snow.gui.GuiManager"):get_refMonsterList()
    local monster_data = monster_list._MonsterBossData
    local lang = game_lang.get_language()

    util_game.do_something(monster_data._DataList, function(_, _, value)
        local em = value._EmType

        util_game.do_something(value._PartTableData, function(_, _, part)
            local part_type = part._Part
            local meat = part._EmPart
            local guid = monster_list:getMonsterPartName(part_type)

            util_table.set_nested_value(
                ret,
                { em, meat },
                game_lang.get_message_local(guid, lang, true)
            )
        end)
    end)

    return ret
end

---@param type_def_name string
---@param t table<string, string|integer>
---@return table<string, string|integer>
local function _get_more_data_fields(type_def_name, t)
    local type_def = sdk.find_type_definition(type_def_name) --[[@as RETypeDefinition]]
    for _, field in pairs(type_def:get_fields()) do
        local field_name = field:get_name()

        if not t[field_name] then
            goto continue
        end

        local field_type = field:get_type() --[[@as RETypeDefinition]]
        local field_type_name = field_type:get_full_name()

        if field_type:is_a("System.Enum") then
            e.new(field_type_name)
            t[field_name] = field_type_name
        end

        ::continue::
    end

    local parent = type_def:get_parent_type()
    if parent then
        return _get_more_data_fields(parent:get_full_name(), t)
    end

    return t
end

local function get_more_data_fields()
    snow_map.pl_more_data_fields = _get_more_data_fields(
        "snow.hit.userdata.PlHitAttackRSData",
        util_table.merge_t(
            snow_map.pl_more_data_fields,
            snow_map.pl_side_more_data_fields,
            snow_map.base_more_data_fields
        )
    )
    snow_map.ot_more_data_fields = _get_more_data_fields(
        "snow.hit.userdata.BaseOtHitAttackRSData",
        util_table.merge_t(
            snow_map.ot_more_data_fields,
            snow_map.pl_side_more_data_fields,
            snow_map.base_more_data_fields
        )
    )
    snow_map.em_more_data_fields = _get_more_data_fields(
        "snow.hit.userdata.EmBaseHitAttackRSData",
        util_table.merge_t(snow_map.em_more_data_fields, snow_map.base_more_data_fields)
    )
end

---@param em snow.enemy.EnemyDef.EmTypes
---@param meat snow.enemy.EnemyDef.Meat
---@return string
function this.get_em_part_name(em, meat)
    local ret = config.lang:tr("misc.text_name_missing")
    local em_data = snow_map.em_part_names[em]

    if not em_data then
        return ret
    end

    local name = em_data[meat]
    if name then
        ret = name
    end

    return ret
end

---@return boolean
function this.init()
    if not s.get("snow.gui.GuiManager") then
        return false
    end

    if
        not e.wrap_init(function()
            e.new("via.physics.ShapeType")
            e.new("snow.hit.HitWeight")
            e.new("snow.player.ActStatus")
            e.new("snow.hit.CustomShapeType")
            e.new("snow.enemy.EnemyDef.ExtractiveType")
            e.new("snow.enemy.EnemyDef.MeatAttr")
            e.new("snow.hit.DamageType")
            e.new("snow.hit.AttackConditionMatchHitAttr")
            e.new("snow.CharacterBase.CharacterType")

            local press_layers = sdk.find_type_definition("snow.hit.HitManager.Layer")
                :get_field("PressLayers")
                :get_data() --[[@as System.Array<System.UInt32>]]
            e.new("snow.hit.HitManager.Layer", function(_, value)
                return press_layers:Contains(value)
            end)
        end)
    then
        return false
    end

    ---@type string?
    local exc
    util_misc.try(function()
        get_more_data_fields()
    end, function(err)
        exc = err
    end)

    if exc then
        return false
    end

    snow_map.em_part_names = get_monster_part_names()

    local config_mod = config.default.mod

    write_strings_to_config(
        this.custom_attack_type.sorted,
        config_mod.hitboxes.misc_type,
        config.default_color
    )
    write_fields_to_config(
        "snow.hit.HitWeight",
        config_mod.pressboxes.press_level,
        nil,
        config.default_color
    )
    write_strings_to_config(
        util_table.values(e.get("snow.hit.HitManager.Layer").enum_to_field),
        config_mod.pressboxes.layer,
        config.default_color
    )
    write_strings_to_config(
        util_table.values(this.mod.enum.guard_type),
        config_mod.hurtboxes.guard_type,
        config.default_highlight_color
    )
    write_strings_to_config(
        util_table.values(e.get("snow.hit.DamageType").enum_to_field),
        config_mod.hitboxes.damage_type,
        config.default_color
    )
    write_strings_to_config(
        util_table.values(e.get("snow.hit.AttackConditionMatchHitAttr").enum_to_field),
        config_mod.hitboxes.hit_condition,
        config.default_color
    )

    config.current.mod = util_table.merge_t(config_mod, config.current.mod)

    return true
end

return this
