---@class (exact) CollisionLogEntry
---@field caller_name string
---@field char_a CollisionLogEntryBase
---@field char_b CollisionLogEntryBase

---@class (exact) CollisionLogEntryBase
---@field char_id number
---@field char_name string
---@field col {
--- resource_idx: integer,
--- set_idx: integer,
--- collidable_idx: integer,
--- }

---@class (exact) CollisionLogEntryWithTimestamp : CollisionLogEntry, Timestamp

---@class CollisionLog
---@field entries CircularBuffer<CollisionLogEntry>
---@field this_tick table<string, boolean>
---@field last_tick integer

local circular_buffer = require("HitboxViewer.util.misc.circular_buffer")
local config = require("HitboxViewer.config.init")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local util_ref = require("HitboxViewer.util.ref.init")
local util_table = require("HitboxViewer.util.misc.table")

---@class CollisionLog
local this = {
    entries = circular_buffer:new(config.max_table_size),
    this_tick = {},
    last_tick = -1,
}

---@param entry CollisionLogEntryWithTimestamp
local function make_key(entry)
    local key_a = entry.char_a
    local key_b = entry.char_b
    return string.format(
        "%s|%s|%s|%s-%s|%s|%s|%s",
        key_a.char_id,
        key_a.col.resource_idx,
        key_a.col.set_idx,
        key_a.col.collidable_idx,
        key_b.char_id,
        key_b.col.resource_idx,
        key_b.col.set_idx,
        key_b.col.collidable_idx
    )
end

---@param entry CollisionLogEntryWithTimestamp
---@return boolean
function this:log(entry)
    if frame_counter.frame ~= self.last_tick then
        self.last_tick = frame_counter.frame
        self.this_tick = {}
    end

    local key = make_key(entry)
    if not self.this_tick[key] then
        if not config.current.mod.collisionboxes.pause_collision_log then
            self.entries:push_back(entry)
        end

        self.this_tick[key] = true
        return true
    end
    return false
end

function this:clear()
    self.entries:clear()
    self.this_tick = {}
    self.last_tick = -1
end

---@param load_data CollisionBoxLoadData
---@return CollisionLogEntryWithTimestamp?
function this.get_log_entry(load_data)
    local dummy = {
        resource_idx = config.lang:tr("misc.text_name_missing"),
        set_idx = config.lang:tr("misc.text_name_missing"),
        collidable_idx = config.lang:tr("misc.text_name_missing"),
    }
    local col_a = load_data.char_a.collidable_to_indexes[load_data.col_a:get_UserData()] or dummy
    local col_b = load_data.char_b.collidable_to_indexes[load_data.col_b:get_UserData()] or dummy

    ---@type CollisionLogEntry
    local ret = {
        caller_name = util_ref.whoami(load_data.caller),
        char_a = {
            char_id = load_data.char_a.id,
            char_name = load_data.char_a.name,
            col = col_a,
        },
        char_b = {
            char_id = load_data.char_b.id,
            char_name = load_data.char_b.name,
            col = col_b,
        },
    }

    return this.attach_timestamp_to_log_entry(ret)
end

---@param collision_log_entry CollisionLogEntry
---@return CollisionLogEntryWithTimestamp
function this.attach_timestamp_to_log_entry(collision_log_entry)
    return util_table.merge(collision_log_entry, { os_clock = os.clock() })
end

return this
