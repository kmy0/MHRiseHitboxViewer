---@class (exact) FriendCharacter : Character
---@class (exact) Pet : FriendCharacter
---@class (exact) Npc : FriendCharacter
---@class (exact) MasterPlayer : Player

---@class (exact) EnemyCharacter : Character
---@class (exact) SmallEnemy : EnemyCharacter

local bigenemy = require("HitboxViewer.character.big_enemy")
local char_cls = require("HitboxViewer.character.char_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local player = require("HitboxViewer.character.player")
local s = require("HitboxViewer.util.ref.singletons")

local mod_enum = data.mod.enum

local this = {}

---@param char_base snow.player.PlayerBase
---@return string
local function get_hunter_name(char_base)
    ---@type string?
    local ret
    if char_base:isServant() then
        local ai_control = char_base:get_RefPlayerAIControl()
        local servant_info = ai_control:get_ServantInfo()
        ret = servant_info:get_ServantName()
    elseif char_base:isMasterPlayer() then
        ret = s.get("snow.LobbyManager"):getMyOfflineHunterName()
    end

    return ret or config.lang:tr("misc.text_name_missing")
end

---@param char_base snow.player.PlayerBase
---@return Player | Npc
local function get_hunter_data(char_base)
    local type = char_base:isServant() and mod_enum.char.Npc
        or (char_base:isMasterPlayer() and mod_enum.char.MasterPlayer or mod_enum.char.Player)
    local name = get_hunter_name(char_base)

    if type == mod_enum.char.Npc then
        ---@type Npc
        return char_cls:new(type, char_base, name)
    end

    return player:new(type, char_base --[[@as snow.player.PlayerQuestBase]], name)
end

---@param char_base snow.otomo.OtomoBase
---@return Pet?
local function get_pet_data(char_base)
    local owner = char_base:getOwnerMasterPlayer()

    if not owner then
        return
    end

    local ret = char_cls:new(
        mod_enum.char.Pet,
        char_base,
        string.format("%s - %s", get_hunter_name(owner), config.lang:tr("misc.text_pet"))
    )
    ---@type Pet
    return ret
end

---@param base_char_type BaseCharType
---@param char_base snow.enemy.EmBossCharacterBase | snow.enemy.EnemyCharacterBase
---@return SmallEnemy | BigEnemy
local function get_enemy_data(base_char_type, char_base)
    local em_type = char_base:get_EnemyType()
    local name = s.get("snow.gui.MessageManager"):getEnemyNameMessage(em_type)
        or config.lang:tr("misc.text_name_missing")
    if base_char_type == mod_enum.base_char.BigMonster then
        ---@cast char_base snow.enemy.EmBossCharacterBase
        return bigenemy:new(char_base, name)
    end
    ---@type SmallEnemy
    return char_cls:new(mod_enum.char.SmallMonster, char_base, name)
end

---@param base_char_type BaseCharType
---@param char_base snow.CharacterBase
---@return Character?
function this.get_character(base_char_type, char_base)
    if base_char_type == mod_enum.base_char.Hunter then
        ---@cast char_base snow.player.PlayerBase
        return get_hunter_data(char_base)
    end

    if base_char_type == mod_enum.base_char.Pet then
        ---@cast char_base snow.otomo.OtomoBase
        return get_pet_data(char_base)
    end

    if
        base_char_type == mod_enum.base_char.BigMonster
        or base_char_type == mod_enum.base_char.SmallMonster
    then
        ---@cast char_base snow.enemy.EmBossCharacterBase | snow.enemy.EnemyCharacterBase
        return get_enemy_data(base_char_type, char_base)
    end
end

return this
