---@class HurtBoxQueue : Queue
---@field push_back fun(self: HurtBoxQueue, value: BoxLoadData)
---@field iter fun(self: HurtBoxQueue, n: integer): fun(): BoxLoadData

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local queue = require("HitboxViewer.util.misc.queue")

local mod_enum = data.mod.enum
local enemy = {
    big_enemy = require("HitboxViewer.box.hurt.big_enemy"),
    small_enemy = require("HitboxViewer.box.hurt.hurtbox_base"),
}
local friend = {
    player = require("HitboxViewer.box.hurt.player"),
    npc = require("HitboxViewer.box.hurt.hurtbox_base"),
    pet = require("HitboxViewer.box.hurt.hurtbox_base"),
}

---@class HurtBoxQueue
local this = queue:new()

function this.get()
    for load_data in this:iter(config.max_hurtbox_loads) do
        ---@type HurtBoxBase?
        local box
        local char = load_data.char

        if char.type == mod_enum.char.Npc then
            ---@cast char Npc
            box = friend.npc:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx
            )
        elseif char.type == mod_enum.char.Player or char.type == mod_enum.char.MasterPlayer then
            ---@cast char Player
            box = friend.player:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx
            )
        elseif char.type == mod_enum.char.Pet then
            ---@cast char Pet
            box = friend.pet:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx
            )
        elseif char.type == mod_enum.char.BigMonster then
            ---@cast char BigEnemy
            box = enemy.big_enemy:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx
            )
        elseif char.type == mod_enum.char.SmallMonster then
            ---@cast char SmallEnemy
            box = enemy.small_enemy:new(
                load_data.col,
                char,
                load_data.resource_idx,
                load_data.set_idx,
                load_data.collidable_idx
            )
        end

        if box then
            char:add_hurtbox(box)
        end
    end
end

return this
