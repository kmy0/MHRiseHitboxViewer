---@class (exact) SnowData
---@field map SnowMap

---@class (exact) SnowMap
---@field em_part_names table<snow.enemy.EnemyDef.EmTypes, table<snow.enemy.EnemyDef.Meat, string>>
---@field base_more_data_fields table<string, string|integer>
---@field pl_side_more_data_fields table<string, string|integer>
---@field pl_more_data_fields table<string, string|integer>
---@field ot_more_data_fields table<string, string|integer>
---@field em_more_data_fields table<string, string|integer>

---@class SnowData
local this = {
    map = {
        em_part_names = {},
        more_data_field_enum = {},
        base_more_data_fields = {
            _Priority = -1,
            _HitStartDelay = -1,
            _HitEndDelay = -1,
            _HitIdUpdateLoopNum = -1,
            _DamageType = -1,
            _HitAttr = -1,
            _DamageDegree = -1,
            _Power = -1,
            _BasePiyoValue = -1,
            _BaseAttackAttr = -1,
            _ObjectBreakType = -1,
            _BaseDamage = -1,
            _BaseAttackElement = -1,
            _BaseAttackElementValue = -1,
            _BaseDebuffType = -1,
            _BaseDebuffValue = -1,
            _BaseDebuffSec = -1,
            _BaseDebuffType2 = -1,
            _BaseDebuffValue2 = -1,
            _BaseDebuffSec2 = -1,
            _BaseDebuffType3 = -1,
            _BaseDebuffValue3 = -1,
            _BaseDebuffSec3 = -1,
        },
        pl_side_more_data_fields = {
            _SharpnessType = -1,
            _HitUiType = -1,
            _JustStartDelay = -1,
            _JustEndDelay = -1,
            _BaseStaminaDamage = -1,
            _SubRate = -1,
            _DebuffRate = -1,
            _BreakRate = -1,
            _BaseWireAttackDamage = -1,
            _PartsBreakRate = -1,
        },
        pl_more_data_fields = {
            _SpecialPoint = -1,
            _ReduceSharpnessRate = -1,
            _HitStopType = -1,
            _HitStopTime = -1,
            _GimmickDamageType = -1,
            _BaseGimmikDamage = -1,
            _HitMarkType = -1,
            _PlayerAttackAttr = -1,
        },
        ot_more_data_fields = {
            _GimmickDamageType = -1,
            _BaseGimmikDamage = -1,
            _HitMarkType = -1,
            _OtomoAttackAttr = -1,
            _OtomoSupportType = -1,
        },
        em_more_data_fields = {
            _DamageTypeValue = -1,
            _GuardableType = -1,
            _BaseEm2EmDamageType = -1,
            _HitMarkType = -1,
            _BaseHyakuryuObjectBreakDamage = -1,
            _MarionetteEnemyBaseDamage = -1,
            _MarionetteEnemyDamageType = -1,
            _MarionetteEnemyBaseDamageS = -1,
            _MarionetteEnemyBaseDamageM = -1,
            _MarionetteEnemyBaseDamageL = -1,
            _IsMysteryDebuff = -1,
            _MysteryDebuffSec = -1,
        },
    },
}

return this
