---@class (exact) AttackLogEntryBase
---@field char_type string
---@field char_id string | integer
---@field char_name string
---@field userdata_type RETypeDefinition
---@field userdata_shape snow.hit.userdata.BaseHitAttackShapeData
---@field resource_path string
---@field resource_idx integer

---@class (exact) AttackLogEntryData
---@field motion_value integer
---@field element number | string
---@field status number | string
---@field part_break number | string
---@field mount number | string
---@field damage_type string
---@field misc_type string?
---@field hit_condition string?
---@field stun number | string
---@field sharpness integer | string
---@field attack_id string
---@field more_data table<string, any>

---@class (exact) Timestamp
---@field os_clock number

---@class (exact) AttackLogEntry : AttackLogEntryData, AttackLogEntryBase
---@class (exact) AttackLogEntryWithTimestamp : AttackLogEntry, Timestamp

---@class AttackLog
---@field entries CircularBuffer<AttackLogEntry>
---@field this_tick table<string, boolean>
---@field open_entries table<integer, boolean>
---@field last_tick integer

local circular_buffer = require("HitboxViewer.util.misc.circular_buffer")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local e = require("HitboxViewer.util.game.enum")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local util_ref = require("HitboxViewer.util.ref.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum

---@class AttackLog
local this = {
    entries = circular_buffer:new(config.max_table_size),
    this_tick = {},
    open_entries = {},
    last_tick = -1,
}

---@param t table<string, any>
local function fix_data(t)
    for k, v in pairs(t) do
        local value_t = type(v)
        if value_t == "boolean" then
            t[k] = tostring(v)
        elseif value_t == "number" and string.find(v, "%.") then
            local precision = 10 ^ -3
            t[k] = math.floor((v + precision / 2) / precision) * precision
        end
    end
end

---@param t AttackLogEntryData
---@param userdata snow.hit.userdata.BaseHitAttackRSData
---@param field_map table<string, string|integer>
local function get_more_data(t, userdata, field_map)
    for field_name, field_type in pairs(field_map) do
        ---@diagnostic disable-next-line: no-unknown
        local value = userdata[field_name]

        if type(field_type) == "string" then
            t.more_data[field_name] = e.get(field_type)[value]
            if not t.more_data[field_name] then -- assume bit flag
                local str = e.get(field_type):get_flags(value)
                t.more_data[field_name] = util_table.empty(str) and value
                    or string.format("%s (%s)", table.concat(str, " | "), value)
            end
        else
            t.more_data[field_name] = value
        end
    end
end

---@param entry AttackLogEntryWithTimestamp
---@return boolean
function this:log(entry)
    if frame_counter.frame ~= self.last_tick then
        self.last_tick = frame_counter.frame
        self.this_tick = {}
    end

    if not self.this_tick[entry.attack_id] then
        if not config.current.mod.hitboxes.pause_attack_log then
            self.entries:push_back(entry)
        end

        self.this_tick[entry.attack_id] = true
        return true
    end
    return false
end

function this:clear()
    self.entries:clear()
    self.this_tick = {}
    self.open_entries = {}
    self.last_tick = -1
end

---@param userdata snow.hit.userdata.PlHitAttackRSData
---@return AttackLogEntryData
function this.get_player_data(userdata)
    local ret = {
        motion_value = userdata._BaseDamage,
        element = userdata._SubRate,
        status = userdata._DebuffRate,
        damage_type = e.get("snow.hit.DamageType")[userdata._DamageType],
        part_break = userdata._PartsBreakRate,
        mount = userdata._BaseWireAttackDamage,
        stun = userdata._BasePiyoValue,
        sharpness = userdata._ReduceSharpnessRate,
        attack_id = userdata:ToString(),
        more_data = {},
    }

    get_more_data(ret, userdata, data.snow.map.pl_more_data_fields)
    return ret
end

---@param userdata snow.hit.userdata.EmBaseHitAttackRSData
---@param userdata_shape snow.hit.userdata.EmHitAttackShapeData
---@return AttackLogEntryData
function this.get_enemy_data(userdata, userdata_shape)
    local data_missing_string = config.lang:tr("misc.text_data_missing")
    local hit_condition =
        e.get("snow.hit.AttackConditionMatchHitAttr")[userdata_shape._ConditionMatchHitAttr]

    local ret = {
        motion_value = userdata._BaseDamage,
        element = data_missing_string,
        status = data_missing_string,
        damage_type = e.get("snow.hit.DamageType")[userdata._DamageType],
        part_break = data_missing_string,
        mount = data_missing_string,
        stun = userdata._BasePiyoValue,
        sharpness = data_missing_string,
        attack_id = userdata:ToString(),
        hit_condition = hit_condition,
        more_data = {
            _HitCondition = hit_condition,
        },
    }

    get_more_data(ret, userdata, data.snow.map.em_more_data_fields)
    return ret
end

---@param userdata snow.hit.userdata.BaseOtHitAttackRSData
---@return AttackLogEntryData
function this.get_pet_data(userdata)
    local data_missing_string = config.lang:tr("misc.text_data_missing")
    local ret = {
        motion_value = userdata._BaseDamage,
        element = userdata._SubRate,
        status = userdata._DebuffRate,
        damage_type = e.get("snow.hit.DamageType")[userdata._DamageType],
        part_break = userdata._PartsBreakRate,
        mount = userdata._BaseWireAttackDamage,
        stun = userdata._BasePiyoValue,
        sharpness = data_missing_string,
        attack_id = userdata:ToString(),
        more_data = {},
    }

    get_more_data(ret, userdata, data.snow.map.ot_more_data_fields)
    return ret
end

---@param char Character
---@param userdata snow.hit.userdata.BaseHitAttackRSData
---@param userdata_shape snow.hit.userdata.BaseHitAttackShapeData
---@param rsc snow.RSCController
---@param resource_idx integer
---@return AttackLogEntryWithTimestamp?
function this.get_log_entry(char, userdata, userdata_shape, rsc, resource_idx)
    if char.hitbox_userdata_cache[userdata] then
        return this.attach_timestamp_to_log_entry(char.hitbox_userdata_cache[userdata])
    end

    ---@type AttackLogEntryData
    local entry_data

    if util_ref.is_a(userdata, "snow.hit.userdata.PlHitAttackRSData") then
        ---@cast userdata snow.hit.userdata.PlHitAttackRSData
        entry_data = this.get_player_data(userdata)
    elseif util_ref.is_a(userdata, "snow.hit.userdata.EmBaseHitAttackRSData") then
        ---@cast userdata snow.hit.userdata.EmBaseHitAttackRSData
        ---@cast userdata_shape snow.hit.userdata.EmHitAttackShapeData
        entry_data = this.get_enemy_data(userdata, userdata_shape)
    elseif util_ref.is_a(userdata, "snow.hit.userdata.BaseOtHitAttackRSData") then
        ---@cast userdata snow.hit.userdata.BaseOtHitAttackRSData
        entry_data = this.get_pet_data(userdata)
    end

    if not entry_data then
        return
    end

    fix_data(entry_data)
    fix_data(entry_data.more_data)
    local _rsc = rsc:get_RSC()
    local set_group = _rsc:getRequestSetGroups(resource_idx)
    local resource = set_group:get_Resource()

    ---@type AttackLogEntryBase
    local entry_base = {
        char_type = mod_enum.char.MasterPlayer == char.type and "Self" or mod_enum.char[char.type],
        char_id = char.id,
        char_name = char.name,
        userdata_type = userdata:get_type_definition() --[[@as RETypeDefinition]],
        resource_idx = resource_idx,
        resource_path = resource:get_ResourcePath(),
        userdata_shape = userdata_shape,
    }

    local attack_log_entry = util_table.merge(entry_base, entry_data) --[[@as AttackLogEntry]]
    char.hitbox_userdata_cache[userdata] = attack_log_entry

    return this.attach_timestamp_to_log_entry(attack_log_entry)
end

---@param attack_log_entry AttackLogEntry
---@return AttackLogEntryWithTimestamp
function this.attach_timestamp_to_log_entry(attack_log_entry)
    return util_table.merge(attack_log_entry, { os_clock = os.clock() })
end

return this
