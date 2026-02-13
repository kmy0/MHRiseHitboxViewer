local char = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local load_queue = require("HitboxViewer.box.collision.load_queue")
local util_ref = require("HitboxViewer.util.ref.init")

local mod_enum = data.mod.enum

local this = {}

function this.hitcheck_pre(args)
    if config.current.mod.enabled_collisionboxes and char.is_quest() then
        local config_col = config.current.mod.collisionboxes
        local caller = sdk.to_managed_object(args[2]) --[[@as REManagedObject]]

        local ret = false
        if util_ref.is_a(caller, "snow.DamageReceiver") then
            ret = config_col.disable_damage
        elseif util_ref.is_a(caller, "snow.hit.HitSensor") then
            ret = config_col.disable_sensor
        elseif util_ref.is_a(caller, "snow.PushBehavior") then
            ret = config_col.disable_press
        else
            ret = config_col.disable_undefined
        end

        if ret then
            return
        end

        local col_info = sdk.to_valuetype(args[3], "via.physics.CollisionInfo") --[[@as via.physics.CollisionInfo]]
        local o = {
            col_a = col_info.CollidableA,
            col_b = col_info.CollidableB,
            col_point = col_info.ContactPoint.Position,
            caller = caller,
        }

        local char_a = char.cache.get_char(o.col_a:get_GameObject(), nil, true)
        local char_b = char.cache.get_char(o.col_b:get_GameObject(), nil, true)

        if not char_a or not char_b then
            return
        end

        if util_ref.is_a(caller, "snow.DamageReceiver") then
            if char_b.type == mod_enum.char.BigMonster then
                ret = config_col.disable_damage_enemy
            elseif
                char_b.type == mod_enum.char.Player or char_b.type == mod_enum.char.MasterPlayer
            then
                ret = config_col.disable_damage_player
            end
        elseif util_ref.is_a(caller, "snow.PushBehavior") then
            if char_b.type == mod_enum.char.BigMonster then
                ret = config_col.disable_press_enemy
            elseif
                char_b.type == mod_enum.char.Player or char_b.type == mod_enum.char.MasterPlayer
            then
                ret = config_col.disable_press_player
            end
        end

        if ret then
            return
        end

        ---@cast o CollisionBoxLoadData
        o.char_a = char_a
        o.char_b = char_b
        load_queue:push_back(o)
    end
end

return this
