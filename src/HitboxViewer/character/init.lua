local frame_cache = require("HitboxViewer.util.misc.frame_cache")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local util_game = require("HitboxViewer.util.game.init")

local this = {
    hook = require("HitboxViewer.character.hook"),
    cache = require("HitboxViewer.character.char_cache"),
    queue = require("HitboxViewer.character.load_queue"),
}

function this.create_all_chars()
    local chars = util_game.get_all_components("snow.CharacterBase")

    util_game.do_something(chars, function(_, _, value)
        this.queue:push_back({
            tick = frame_counter.frame,
            game_object = value:get_GameObject(),
            char_base = value,
        })
    end)
end

function this.get()
    this.queue.get()
end

---@param char_enum CharType
---@return Character[]?
function this.get_sorted_chars(char_enum)
    ---@type Character[]
    local ret = {}
    if not this.cache.by_type_by_gameobject[char_enum] then
        return
    end

    for _, char_obj in pairs(this.cache.by_type_by_gameobject[char_enum]) do
        table.insert(ret, char_obj)
    end

    table.sort(ret, function(x, y)
        if x.order < y.order then
            return true
        end
        return false
    end)
    return ret
end

function this.get_master_player()
    return this.cache:get_master_player()
end

---@return boolean
function this.is_quest()
    local master_player = this.get_master_player()
    if not master_player then
        return false
    end

    return master_player:is_quest()
end

this.is_quest = frame_cache.memoize(this.is_quest)

return this
