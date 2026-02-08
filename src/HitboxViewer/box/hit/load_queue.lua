---@class HitBoxQueue : Queue
---@field push_back fun(self: HitBoxQueue, value: HitBoxLoadDataRsc | HitBoxLoadData)
---@field iter fun(self: HitBoxQueue, n: integer?): fun(): HitBoxLoadDataRsc | HitBoxLoadData

---@class (exact) HitBoxLoadData
---@field type HitBoxLoadDataType
---@field char Character
---@field rsc snow.RSCController
---@field userdata snow.hit.userdata.BaseHitAttackRSData?

---@class (exact) HitBoxLoadDataRsc : HitBoxLoadData
---@field res_idx integer
---@field req_idx integer

local attack_log = require("HitboxViewer.attack_log")
local base = require("HitboxViewer.box.hit.hitbox_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local queue = require("HitboxViewer.util.misc.queue")

local mod_enum = data.mod.enum
local enemy = { big_enemy = base, small_enemy = base }
local friend = { player = base, npc = base, pet = base }

---@class HitBoxQueue
local this = queue:new()

---@param load_data HitBoxLoadDataRsc
---@return fun(): integer, integer, integer
local function get_collidable_attack_work(load_data)
    ---@type [integer, integer, integer][]
    local ret = {}
    local index = 1

    local num_collidables = load_data.rsc:getNumCollidables(load_data.res_idx, load_data.req_idx)
    for i = 0, num_collidables do
        table.insert(ret, { load_data.res_idx, load_data.req_idx, i })
    end

    return function()
        if index <= #ret then
            local item = ret[index]
            index = index + 1
            return item[1], item[2], item[3]
            ---@diagnostic disable-next-line: missing-return
        end
    end
end

---@param load_data HitBoxLoadData
---@param index_fn fun(load_data: HitBoxLoadData): fun(): integer, integer, integer
---@return fun(): via.physics.Collidable, snow.hit.userdata.BaseHitAttackRSData, snow.hit.userdata.BaseHitAttackShapeData, integer, integer, integer
local function get_collidable(load_data, index_fn)
    ---@type [via.physics.Collidable, snow.hit.userdata.BaseHitAttackRSData, snow.hit.userdata.BaseHitAttackShapeData, integer, integer, integer][]
    local ret = {}
    local index = 1

    for resource_idx, set_idx, collidable_idx in index_fn(load_data) do
        local col = load_data.rsc:getCollidable(resource_idx, set_idx, collidable_idx)

        if not col then
            goto continue
        end

        local userdata = load_data.userdata
        if not userdata then
        end

        table.insert(
            ret,
            { col, userdata, col:get_UserData(), resource_idx, set_idx, collidable_idx }
        )
        ::continue::
    end

    return function()
        if index <= #ret then
            local item = ret[index]
            index = index + 1
            return item[1], item[2], item[3], item[4], item[5], item[6]
            ---@diagnostic disable-next-line: missing-return
        end
    end
end

function this.get()
    local config_mod = config.current.mod

    for load_data in this:iter() do
        local char = load_data.char

        for col, userdata, userdata_shape, resource_idx, set_idx, collidable_idx in
            get_collidable(load_data, get_collidable_attack_work)
        do
            local log_entry = attack_log.get_log_entry(
                char,
                userdata,
                userdata_shape,
                load_data.rsc,
                resource_idx
            )

            if
                char:has_hitbox(col)
                or not log_entry
                or config_mod.hitboxes.misc_type.disable[data.custom_attack_type.check(log_entry)]
                or config_mod.hitboxes.damage_type.disable[log_entry.damage_type]
                or config_mod.hitboxes.hit_condition.disable[log_entry.hit_condition]
            then
                goto continue
            end

            attack_log:log(log_entry)

            ---@type HitBoxBase?
            local box

            if char.type == mod_enum.char.Npc then
                ---@cast char Npc
                box = friend.npc:new(col, char, resource_idx, set_idx, collidable_idx, log_entry)
            elseif char.type == mod_enum.char.Player or char.type == mod_enum.char.MasterPlayer then
                ---@cast char Player
                box = friend.player:new(col, char, resource_idx, set_idx, collidable_idx, log_entry)
            elseif char.type == mod_enum.char.Pet then
                ---@cast char Pet
                box = friend.pet:new(col, char, resource_idx, set_idx, collidable_idx, log_entry)
            elseif char.type == mod_enum.char.BigMonster then
                ---@cast char BigEnemy
                box =
                    enemy.big_enemy:new(col, char, resource_idx, set_idx, collidable_idx, log_entry)
            elseif char.type == mod_enum.char.SmallMonster then
                ---@cast char SmallEnemy
                box = enemy.small_enemy:new(
                    col,
                    char,
                    resource_idx,
                    set_idx,
                    collidable_idx,
                    log_entry
                )
            end

            if box then
                char:add_hitbox(box)
            end

            ::continue::
        end
    end
end

return this
