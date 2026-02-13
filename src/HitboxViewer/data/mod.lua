---@class ModData
---@field map ModMap
---@field enum ModEnum
---@field initialized boolean

---@class (exact) ModMap
---@field update_order CharType[]

---@class (exact) ModEnum
---@field base_char BaseCharType.*
---@field shape ShapeType.*
---@field shape_dummy ShapeDummy.*
---@field char CharType.*
---@field box BoxType.*
---@field condition_type ConditionType.*
---@field element ElementType.*
---@field condition_result ConditionResult.*
---@field extract ExtractType.*
---@field break_state BreakType.*
---@field box_state BoxState.*
---@field default_hurtbox_state DefaultHurtboxState.*
---@field condition_state ConditionState.*
---@field hitbox_load_data HitBoxLoadDataType.*
---@field guard_type GuardType.*
---@field mystery_state MysteryType.*

local util_misc = require("HitboxViewer.util.misc.init")

---@class ModData
local this = {
    ---@diagnostic disable-next-line: missing-fields
    enum = {},
    ---@diagnostic disable-next-line: missing-fields
    map = {},
}

---@enum BaseCharType
this.enum.base_char = { ---@class BaseCharType.* : {[string]: integer}, {[integer]: string}
    Hunter = 1,
    BigMonster = 2,
    Pet = 3,
    SmallMonster = 4,
    Dummy = 5,
}
---@enum ShapeType
this.enum.shape = { ---@class ShapeType.* : {[string]: integer}, {[integer]: string}
    Sphere = 1,
    Capsule = 2,
    Box = 3,
    Cylinder = 4,
    Triangle = 5,
    ContinuousCapsule = 6,
    ContinuousSphere = 7,
    SlicedCylinder = 8,
    Donuts = 9,
    TrianglePole = 5,
}
---@enum ShapeDummy
this.enum.shape_dummy = { ---@class ShapeDummy.* : {[integer]: string}, {[string]: integer}
    [1] = "Sphere",
    [2] = "Capsule",
    [3] = "Box",
    [4] = "Cylinder",
    [5] = "Triangle",
    [9] = "Donuts",
}
---@enum CharType
this.enum.char = { ---@class CharType.* : {[string]: integer}, {[integer]: string}
    Player = 1,
    MasterPlayer = 2,
    SmallMonster = 3,
    BigMonster = 4,
    Pet = 5,
    Npc = 6,
    Dummy = 7,
}
---@enum BoxType
this.enum.box = { ---@class BoxType.* : {[string]: integer}, {[integer]: string}
    HurtBox = 1,
    HitBox = 2,
    GuardBox = 3,
    DummyBox = 4,
    CollisionBox = 5,
    CollisionContactBox = 6,
}
---@enum ConditionType
this.enum.condition_type = { ---@class ConditionType.* : {[string]: integer}, {[integer]: string}
    Element = 1,
    Break = 2,
    Mystery = 3,
    Extract = 4,
}
---@enum ElementType
this.enum.element = { ---@class ElementType.* : {[string]: integer}, {[integer]: string}
    All = 1,
    Strike = 2,
    Dragon = 3,
    Fire = 4,
    Ice = 5,
    Piyo = 6,
    Shell = 7,
    Slash = 8,
    Elect = 9,
    Water = 10,
}
---@enum ConditionResult
-- stylua: ignore
this.enum.condition_result = {  ---@class ConditionResult.* : {[string]: integer}, {[integer]: string}
    None = 1,
    Highlight = 2,
    Hide = 3,
}
---@enum ExtractType
this.enum.extract = { ---@class ExtractType.* : {[string]: integer}, {[integer]: string}
    Red = 1,
    White = 2,
    Orange = 3,
    None = 4,
}
---@enum BreakType
this.enum.break_state = { ---@class BreakType.* : {[string]: integer}, {[integer]: string}
    Yes = 1,
    No = 2,
    Broken = 3,
}
---@enum MysteryType
this.enum.mystery_state = { ---@class MysteryType.* : {[string]: integer}, {[integer]: string}
    Yes = 1,
    No = 2,
    Mystery = 3,
}
---@enum BoxState
this.enum.box_state = { ---@class BoxState.* : {[string]: integer}, {[integer]: string}
    None = 1,
    Draw = 2,
    Dead = 3,
}
---@enum DefaultHurtboxState
-- stylua: ignore
this.enum.default_hurtbox_state = { ---@class DefaultHurtboxState.* : {[string]: integer}, {[integer]: string}
    Draw = 1,
    Hide = 2,
}
---@enum ConditionState
this.enum.condition_state = { ---@class ConditionState.* : {[string]: integer}, {[integer]: string}
    Highlight = 1,
    Hide = 2,
}

---@enum HitBoxLoadDataType
-- stylua: ignore
this.enum.hitbox_load_data = { ---@class HitBoxLoadDataType.* : {[string]: integer}, {[integer]: string}
    base = 1,
    rsc = 2,
    shell = 3,
}
this.map.update_order = {
    this.enum.char.MasterPlayer,
    this.enum.char.BigMonster,
    this.enum.char.Player,
    this.enum.char.Pet,
    this.enum.char.Npc,
    this.enum.char.SmallMonster,
    this.enum.char.Dummy,
}
---@enum GuardType
this.enum.guard_type = { ---@class GuardType.* : {[string]: string}
    GUARD = "GUARD",
    HYPER = "HYPER",
    SUPER = "SUPER",
}

---@return boolean
function this.init()
    this.initialized = true
    return true
end

this.enum.base_char = util_misc.make_lookup(this.enum.base_char)
this.enum.shape = util_misc.make_lookup(this.enum.shape)
this.enum.shape_dummy = util_misc.make_lookup(this.enum.shape_dummy)
this.enum.char = util_misc.make_lookup(this.enum.char)
this.enum.box = util_misc.make_lookup(this.enum.box)
this.enum.condition_type = util_misc.make_lookup(this.enum.condition_type)
this.enum.element = util_misc.make_lookup(this.enum.element)
this.enum.condition_result = util_misc.make_lookup(this.enum.condition_result)
this.enum.extract = util_misc.make_lookup(this.enum.extract)
this.enum.break_state = util_misc.make_lookup(this.enum.break_state)
this.enum.mystery_state = util_misc.make_lookup(this.enum.mystery_state)
this.enum.default_hurtbox_state = util_misc.make_lookup(this.enum.default_hurtbox_state)
this.enum.condition_state = util_misc.make_lookup(this.enum.condition_state)
this.enum.hitbox_load_data = util_misc.make_lookup(this.enum.hitbox_load_data)

return this
