local char_cache = require("HitboxViewer.character.char_cache")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local e = require("HitboxViewer.util.game.enum")
local load_queue = require("HitboxViewer.box.hit.load_queue")
local util_game = require("HitboxViewer.util.game.init")
local util_ref = require("HitboxViewer.util.ref.init")

local mod_enum = data.mod.enum

local this = {}

function this.get_attack_pre(args)
    local config_mod = config.current.mod

    if not config_mod.enabled_hitboxes then
        return
    end

    local res_idx = util_ref.to_int(args[5])
    local rs_id = util_ref.to_int(args[6])
    local userdata = sdk.to_managed_object(args[8]) --[[@as snow.hit.userdata.BaseHitAttackRSData]]
    local attack_work = sdk.to_managed_object(args[2]) --[[@as snow.hit.AttackWork]]
    local rsc = attack_work:get_RSCCtrl()
    local game_object = rsc:get_GameObject()
    local char_base = util_game.get_component(game_object, "snow.CharacterBase") --[[@as snow.CharacterBase]]

    if char_base:getCharacterType() == e.get("snow.CharacterBase.CharacterType").Shell then
        ---@cast char_base snow.shell.ShellBase
        char_base = char_base:get_OwnerObject()
        game_object = char_base:get_GameObject()
    end

    local char = char_cache.get_char(game_object, char_base)

    if
        not char
        or char.distance > config_mod.draw.distance
        or config_mod.hitboxes.disable[mod_enum.char[char.type]]
    then
        return
    end

    load_queue:push_back({
        type = mod_enum.hitbox_load_data.rsc,
        char = char,
        rsc = rsc,
        res_idx = res_idx,
        req_idx = rs_id,
        userdata = userdata,
    })
end

return this
