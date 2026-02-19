---@class (exact) TrailBox : BoxBase
---@field trail_buffer nil
---@field last_pos nil
---@field o_color integer
---@field o_outline_color integer
---@field outline_color integer
---@field draw_outline boolean
---@field frame integer
---@field life integer

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local frame_counter = require("HitboxViewer.util.misc.frame_counter")
local util_game = require("HitboxViewer.util.game.init")

local mod_enum = data.mod.enum

---@class TrailBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param box BoxBase
---@param life integer
---@return TrailBox
function this:new(box, life)
    local o = {
        o_color = box.color,
        color = box.color,
        o_outline_color = config.current.mod.draw.outline_color,
        outline_color = config.current.mod.draw.outline_color,
        draw_outline = config.current.mod.trailboxes.outline,
        frame = frame_counter.frame,
        life = life,
        shape_data = {},
        shape_type = box.shape_type,
        type = box.type,
        distance = box.distance,
        pos = box.pos:clone(),
        sort = -1,
        is_enabled = true,
    }
    ---@cast o TrailBox
    setmetatable(o, self)

    o:_update_shape(box.shape_data)
    return o
end

---@protected
---@param shape_data ShapeData
function this:_update_shape(shape_data)
    for k, v in
        pairs(shape_data --[[@as table<string, userdata | number>]])
    do
        if type(v) == "userdata" then
            ---@diagnostic disable-next-line: no-unknown
            self.shape_data[k] = (v --[[@as Vector3f | Matrix4x4f]]):clone()
        else
            ---@diagnostic disable-next-line: no-unknown
            self.shape_data[k] = v
        end
    end
end

---@protected
---@param color integer
---@return integer
function this:_update_color(color)
    local age = frame_counter.frame - self.frame
    local life_ratio = 1.0 - (age / self.life)

    local a = math.floor(((color >> 24) & 0xFF) * life_ratio)
    local r = (color >> 16) & 0xFF --[[@as integer]]
    local g = (color >> 8) & 0xFF --[[@as integer]]
    local b = color & 0xFF --[[@as integer]]

    return (a << 24) | (r << 16) | (g << 8) | b
end

---@return BoxState
function this:update_data()
    if frame_counter.frame - self.frame > self.life then
        return mod_enum.box_state.Dead
    end

    if config.current.mod.trailboxes.fade then
        self.color = self:_update_color(self.o_color)
        self.outline_color = self:_update_color(self.o_outline_color)
    end

    return mod_enum.box_state.Draw
end

---@return BoxState
function this:update_shape()
    self.distance = (util_game.get_camera_origin() - self.pos):length()
    return mod_enum.box_state.Draw
end

---@return BoxState
function this:update()
    self:update_shape()
    return self:update_data()
end

return this
