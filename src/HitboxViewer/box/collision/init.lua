local config = require("HitboxViewer.config.init")
local load_queue = require("HitboxViewer.box.collision.load_queue")
local m = require("HitboxViewer.util.ref.methods")

local this = {
    hook = require("HitboxViewer.box.collision.hook"),
}

function this.get()
    load_queue:get()
end

---@return boolean
function this.init()
    if config.current.mod.enabled_collisionboxes then
        m.hook(
            "snow.hit.ICollidersExtention.hitCheckCustomShape(via.physics.IColliders, via.physics.CollisionInfo, System.Boolean)",
            this.hook.hitcheck_pre
        )
        m.hook(
            "snow.hit.push.PushBehaviorBase.poolPressInfo(via.physics.CollisionInfo)",
            this.hook.hitcheck_pre
        )
    end

    return true
end

return this
