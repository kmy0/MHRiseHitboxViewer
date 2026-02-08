local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local load_queue = require("HitboxViewer.character.load_queue")

local this = {}

function this.get_base_pre(args)
    local char_base = sdk.to_managed_object(args[2]) --[[@as snow.CharacterBase]]
    load_queue:push_back({ tick = frame_counter.frame, char_base = char_base })
end

return this
