---@class CallQueue
---@field queue (fun(): boolean)[]

local util_table = require("HitboxViewer.util.misc.table")

---@class CallQueue
local this = {
    queue = {},
}

---@param fn fun(): boolean
function this.push_back(fn)
    table.insert(this.queue, fn)
end

function this.execute()
    if util_table.empty(this.queue) then
        return
    end

    local next_queue = {}
    for i = 1, #this.queue do
        local fn = this.queue[i]
        local res = fn()
        if res then
            table.insert(next_queue, fn)
        end
    end

    this.queue = next_queue
end

return this
