---@class ColQueue : Queue
---@field push_back fun(self: ColQueue, value: ColLoadData)
---@field iter fun(self: ColQueue, n: integer): fun(): ColLoadData

---@class (exact) ColLoadData
---@field char Character
---@field rsc snow.RSCController
---@field push snow.PushBehavior

---@class (exact) BoxLoadData : ColLoadData
---@field col via.physics.Collidable
---@field resource_idx integer
---@field set_idx integer
---@field collidable_idx integer

local config = require("HitboxViewer.config.init")
local hurtbox = require("HitboxViewer.box.hurt.init")
local pressbox = require("HitboxViewer.box.press.init")
local queue = require("HitboxViewer.util.misc.queue")
local util_game = require("HitboxViewer.util.game.init")

---@class ColQueue
local this = queue:new()

---@param load_data ColLoadData
---@return fun(): integer, integer, integer
local function get_collidable_hurt(load_data)
    ---@type [integer, integer, integer][]
    local ret = {}
    local index = 1
    local resource_idx = load_data.rsc:get_DamageResourceIndex()

    util_game.do_something(load_data.rsc:get_DamageRSIDList(), function(_, _, value)
        local num_collidables = load_data.rsc:getNumCollidables(resource_idx, value)
        for i = 0, num_collidables do
            table.insert(ret, { resource_idx, value, i })
        end
    end)

    return function()
        if index <= #ret then
            local item = ret[index]
            index = index + 1
            return item[1], item[2], item[3]
            ---@diagnostic disable-next-line: missing-return
        end
    end
end

---@param load_data ColLoadData
---@return fun(): integer, integer, integer
local function get_collidable_press(load_data)
    ---@type [integer, integer, integer][]
    local ret = {}
    local index = 1
    local resource_idx = load_data.push:get_PushResourceIndex()

    util_game.do_something(load_data.push:get_PushRequestSetsWorks(), function(_, _, work)
        util_game.do_something(work:get_Ids(), function(_, _, value)
            local num_collidables = load_data.rsc:getNumCollidables(resource_idx, value)
            for i = 0, num_collidables do
                table.insert(ret, { resource_idx, value, i })
            end
        end)
    end)

    return function()
        if index <= #ret then
            local item = ret[index]
            index = index + 1
            return item[1], item[2], item[3]
            ---@diagnostic disable-next-line: missing-return
        end
    end
end

---@param load_data ColLoadData
---@param index_fn fun(load_data: ColLoadData): fun(): integer, integer, integer
---@return fun(): BoxLoadData
local function get_collidable(load_data, index_fn)
    ---@type BoxLoadData[]
    local ret = {}
    local index = 1

    for resource_idx, set_idx, collidable_idx in index_fn(load_data) do
        local col = load_data.rsc:getCollidable(resource_idx, set_idx, collidable_idx)

        if not col then
            goto continue
        end

        ---@type BoxLoadData
        local boxloaddata = {
            col = col,
            resource_idx = resource_idx,
            set_idx = set_idx,
            collidable_idx = collidable_idx,
            char = load_data.char,
            rsc = load_data.rsc,
            push = load_data.push,
        }
        table.insert(ret, boxloaddata)
        ::continue::
    end

    return function()
        if index <= #ret then
            local item = ret[index]
            index = index + 1
            return item
            ---@diagnostic disable-next-line: missing-return
        end
    end
end

function this.get()
    for load_data in this:iter(config.max_char_loads) do
        for box_data in get_collidable(load_data, get_collidable_hurt) do
            hurtbox.queue:push_back(box_data)
        end

        for box_data in get_collidable(load_data, get_collidable_press) do
            pressbox.queue:push_back(box_data)
        end
    end
end

return this
