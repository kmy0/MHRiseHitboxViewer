---@meta

---@class snow.BehaviorRoot : via.Behavior
---@class snow.SnowSingletonBehaviorRoot : snow.BehaviorRoot
---@class snow.enemy.EmBossCharacterBase : snow.enemy.EnemyCharacterBase
---@class snow.LobbyManager.HallPacket : via.clr.ManagedObject
---@class snow.hit.userdata.SnowRequestSetColliderUserDataRoot : via.physics.RequestSetColliderUserData
---@class snow.hit.userdata.BaseHitData : snow.hit.userdata.SnowRequestSetColliderUserDataRoot
---@class snow.hit.userdata.BaseAttachRequestSetData : snow.hit.userdata.BaseHitData
---@class snow.hit.userdata.BaseHitDamageRSData : snow.hit.userdata.BaseAttachRequestSetData
---@class snow.hit.userdata.BaseHitDamageShapeData : snow.hit.userdata.CommonAttachShapeData
---@class snow.hit.userdata.EmBaseHitDamageShapeData : snow.hit.userdata.BaseHitDamageShapeData
---@class snow.gui.GuiBaseBehavior : snow.gui.GuiRootBaseBehavior
---@class snow.gui.GuiRootBaseBehavior : snow.BehaviorRoot
---@class snow.enemy.EnemyPartsBreakData.PartsLossData : via.clr.ManagedObject
---@class snow.hit.userdata.BaseOtHitAttackRSData : snow.hit.userdata.PlayerSideAttackRSData
---@class snow.hit.userdata.EmBaseHitAttackRSData : snow.hit.userdata.BaseHitAttackRSData
---@class snow.hit.userdata.BaseHitAttackShapeData : snow.hit.userdata.CommonAttachShapeData

---@class snow.player.PlayerBase : snow.CharacterBase
---@field isServant fun(self: snow.player.PlayerBase): System.Boolean
---@field getPlayerIndex fun(self: snow.player.PlayerBase): snow.player.PlayerIndex
---@field isMasterPlayer fun(self: snow.player.PlayerBase): System.Boolean
---@field get_RefPlayerAIControl fun(self: snow.player.PlayerBase): snow.player.PlayerAIControl

---@class snow.player.PlayerManager : snow.SnowSingletonBehaviorRoot
---@field createPlayerName fun(self: snow.player.PlayerManager, index: snow.player.PlayerIndex): System.String
---@field findMasterPlayer fun(self: snow.player.PlayerManager): snow.player.PlayerBase

---@class snow.otomo.OtomoBase : snow.CharacterBase
---@field getOwnerMasterPlayer fun(self: snow.otomo.OtomoBase): snow.player.PlayerBase

---@class snow.gui.MessageManager : via.clr.ManagedObject
---@field getEnemyNameMessage fun(self: snow.gui.MessageManager ,em_type: snow.enemy.EnemyDef.EmTypes): System.String

---@class snow.enemy.EnemyCharacterBase : snow.CharacterBase
---@field get_EnemyType fun(self: snow.enemy.EnemyCharacterBase): snow.enemy.EnemyDef.EmTypes
---@field isEnableMystery fun(self: snow.enemy.EnemyCharacterBase): System.Boolean
---@field checkDie fun(self: snow.enemy.EnemyCharacterBase): System.Boolean
---@field get_isBossEnemy fun(self: snow.enemy.EnemyCharacterBase): System.Boolean
---@field get_RefEmUserData fun(self: snow.enemy.EnemyCharacterBase): snow.enemy.EnemyUserDataParam
---@field get_DamageParam fun(self: snow.enemy.EnemyCharacterBase): snow.enemy.EnemyDamageParam
---@field isActivateEnableMysteryCoreParts fun(self: snow.enemy.EnemyCharacterBase, part: snow.enemy.EnemyDef.PartsGroup): System.Boolean
---@field isActiveMysteryCoreParts fun(self: snow.enemy.EnemyCharacterBase, part: snow.enemy.EnemyDef.PartsGroup): System.Boolean
---@field getExtractiveType fun(self: snow.enemy.EnemyCharacterBase, part: snow.enemy.EnemyDef.PartsGroup): snow.enemy.EnemyDef.ExtractiveType
---@field getMeatAdjustValue fun(self: snow.enemy.EnemyCharacterBase, meat: snow.enemy.EnemyDef.Meat, meat_attr: snow.enemy.EnemyDef.MeatAttr, part: snow.enemy.EnemyDef.PartsGroup): System.UInt16

---@class snow.LobbyManager.HunterInfo : snow.LobbyManager.HallPacket
---@field _name System.String
---@field _memberIndex System.Int32

---@class snow.LobbyManager : snow.SnowSingletonBehaviorRoot
---@field getMyOfflineHunterName fun(self: snow.LobbyManager): System.String
---@field getLobbyHunterInfoList fun(self: snow.LobbyManager): System.Array<snow.LobbyManager.HunterInfo>

---@class snow.player.PlayerAIControl : snow.BehaviorRoot
---@field get_ServantInfo fun(self: snow.player.PlayerAIControl): snow.ai.ServantInfo

---@class snow.ai.ServantInfo : via.clr.ManagedObject
---@field get_ServantName fun(self: snow.ai.ServantInfo): System.String

---@class snow.RSCController : snow.hit.RSCAPIWrapper
---@field get_DamageResourceIndex fun(self: snow.RSCController): System.UInt32
---@field get_DamageRSIDList fun(self: snow.RSCController): System.Array<System.UInt32>
---@field checkEnabledRequestSet fun(self: snow.RSCController, resource_idx: System.UInt32, rs_id: System.UInt32): System.Boolean

---@class snow.hit.RSCAPIWrapper : snow.BehaviorRoot
---@field get_RSC fun(self: snow.hit.RSCAPIWrapper): via.physics.RequestSetCollider
---@field getNumCollidables fun(self: snow.hit.RSCAPIWrapper, resource_idx: System.UInt32, rs_id: System.UInt32): System.UInt32
---@field getCollidable fun(self: snow.hit.RSCAPIWrapper, resource_idx: System.UInt32, rs_id: System.UInt32, col_idx: System.UInt32): via.physics.Collidable

---@class snow.PushBehavior : snow.hit.push.PushBehaviorBase
---@field get_Weight fun(self: snow.PushBehavior): snow.hit.HitWeight

---@class snow.hit.push.PushBehaviorBase : snow.BehaviorRoot
---@field get_PushResourceIndex fun(self: snow.hit.push.PushBehaviorBase): System.UInt32
---@field get_PushRequestSetsWorks fun(self: snow.hit.push.PushBehaviorBase): System.Array<snow.hit.RequestSetsWork>

---@class snow.hit.RequestSetsWork : via.clr.ManagedObject
---@field get_Ids fun(self: snow.hit.RequestSetsWork): System.Array<System.UInt32>

---@class snow.player.PlayerQuestBase : snow.player.PlayerBase
---@field isActionStatusTag fun(self: snow.player.PlayerQuestBase, act: snow.player.ActStatus): System.Boolean
---@field getGuardAngleRange fun(self: snow.player.PlayerQuestBase): System.Single
---@field checkMuteki fun(self: snow.player.PlayerQuestBase): System.Boolean
---@field checkSuperArmor fun(self: snow.player.PlayerQuestBase): System.Boolean
---@field checkHyperArmor fun(self: snow.player.PlayerQuestBase): System.Boolean

---@class snow.CharacterBase : snow.BehaviorRoot
---@field getDirection fun(self: snow.CharacterBase): Vector3f
---@field get_Pos fun(self: snow.CharacterBase): Vector3f
---@field getCharacterType fun(self: snow.CharacterBase): snow.CharacterBase.CharacterType

---@class snow.hit.userdata.EmHitDamageRSData : snow.hit.userdata.BaseHitDamageRSData
---@field get_Group fun(self: snow.hit.userdata.EmHitDamageRSData): snow.enemy.EnemyDef.PartsGroup

---@class snow.hit.userdata.EmHitDamageShapeData : snow.hit.userdata.EmBaseHitDamageShapeData
---@field get_Meat fun(self: snow.hit.userdata.EmHitDamageShapeData): snow.enemy.EnemyDef.Meat

---@class snow.hit.userdata.CommonAttachShapeData : snow.hit.userdata.BaseHitData
---@field _CustomShapeType snow.hit.CustomShapeType

---@class snow.gui.GuiManager : snow.SnowSingletonBehaviorRoot
---@field get_refMonsterList fun(self: snow.gui.GuiManager): snow.gui.GuiMonsterList

---@class snow.gui.GuiMonsterList : snow.gui.GuiBaseBehavior
---@field getMonsterPartName fun(self: snow.gui.GuiMonsterList, part: snow.data.monsterList.PartType): System.Guid
---@field _MonsterBossData snow.data.monsterList.MonsterListBossData

---@class snow.data.monsterList.MonsterListBossData : via.UserData
---@field _DataList System.Array<snow.data.monsterList.BossMonsterData>

---@class snow.data.monsterList.BossMonsterData : snow.data.monsterList.MonsterBasicData
---@field _PartTableData System.Array<snow.data.monsterList.BossMonsterData.PartData>

---@class snow.data.monsterList.MonsterBasicData : via.clr.ManagedObject
---@field _EmType snow.enemy.EnemyDef.EmTypes

---@class snow.data.monsterList.BossMonsterData.PartData : via.clr.ManagedObject
---@field _Part snow.data.monsterList.PartType
---@field _EmPart snow.enemy.EnemyDef.Meat

---@class snow.enemy.EnemyUserDataParam : via.Component
---@field get_TuneDataUserData fun(self: snow.enemy.EnemyUserDataParam): snow.enemy.EnemyDataTune

---@class snow.enemy.EnemyDataTune : via.UserData
---@field getPartsBreakMaxLevel fun(self: snow.enemy.EnemyDataTune, part: snow.enemy.EnemyDef.PartsGroup): System.Int32
---@field getPartsLossData fun(self: snow.enemy.EnemyDataTune, part: snow.enemy.EnemyDef.PartsGroup): snow.enemy.EnemyPartsBreakData.PartsLossData

---@class snow.enemy.EnemyDamageParam : via.clr.ManagedObject
---@field isPartsBreak fun(self: snow.enemy.EnemyDamageParam, part: snow.enemy.EnemyDef.PartsGroup): System.Boolean
---@field isPartsLoss fun(self: snow.enemy.EnemyDamageParam, part: snow.enemy.EnemyDef.PartsGroup): System.Boolean

---@class snow.shell.ShellBase : snow.CharacterBase
---@field get_OwnerObject fun(self: snow.shell.ShellBase): snow.CharacterBase

---@class snow.hit.AttackWork : via.clr.ManagedObject
---@field get_RSCCtrl fun(self: snow.hit.AttackWork): snow.RSCController

---@class snow.hit.userdata.BaseHitAttackRSData : snow.hit.userdata.BaseAttachRequestSetData
---@field _Priority snow.hit.HitPriority
---@field _HitStartDelay System.Int16
---@field _HitEndDelay System.Int16
---@field _HitIdUpdateLoopNum System.SByte
---@field _DamageType snow.hit.DamageType
---@field _HitAttr snow.hit.HitAttr
---@field _DamageDegree System.Single
---@field _Power System.Byte
---@field _BasePiyoValue System.SByte
---@field _BaseAttackAttr snow.hit.AttackAttr
---@field _ObjectBreakType snow.hit.ObjectBreakType
---@field _BaseDamage System.Int32
---@field _BaseAttackElement snow.hit.AttackElement
---@field _BaseAttackElementValue System.Byte
---@field _BaseDebuffType snow.hit.DebuffType
---@field _BaseDebuffValue System.Byte
---@field _BaseDebuffSec System.Single
---@field _BaseDebuffType2 snow.hit.DebuffType
---@field _BaseDebuffValue2 System.Byte
---@field _BaseDebuffSec2 System.Single
---@field _BaseDebuffType3 snow.hit.DebuffType
---@field _BaseDebuffValue3 System.Byte
---@field _BaseDebuffSec3 System.Single

---@class snow.hit.userdata.PlHitAttackRSData : snow.hit.userdata.PlayerSideAttackRSData
---@field _ReduceSharpnessRate System.Single

---@class snow.hit.userdata.PlayerSideAttackRSData : snow.hit.userdata.BaseHitAttackRSData
---@field _SubRate System.Single
---@field _DebuffRate System.Single
---@field _BaseWireAttackDamage System.Single
---@field _PartsBreakRate System.Single

---@class snow.hit.userdata.EmHitAttackShapeData : snow.hit.userdata.BaseHitAttackShapeData
---@field _ConditionMatchHitAttr snow.hit.AttackConditionMatchHitAttr
