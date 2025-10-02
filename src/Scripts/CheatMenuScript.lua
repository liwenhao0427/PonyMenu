
mod.flags = { }

function mod.updateExtraSelectorText()
    local screen = DeepCopyTable(ScreenData.ExtraSelector)
    for i, button in pairs(ScreenData.ExtraSelector.ComponentData.Background.Children) do
        if mod.flags[i] then
            if mod.flags[i] == "ON" then
                button.TextArgs.Color = Color.Blue
                button.Text = "已启用" .. button.Data.OriText
                CreateScreenFromData(screen, button)
            else
                button.TextArgs.Color = Color.Red
                button.Text = "取消" .. button.Data.OriText
                CreateScreenFromData(screen, button)
            end
        else
            if button.Data.OriText then
                button.TextArgs.Color = Color.White
                button.Text = button.Data.OriText
            end
        end
    end
end

function mod.updateExtraSelectorTextForInit(screen)
    for i, button in pairs(screen.ComponentData.Background.Children) do
        if mod.flags[i] then
            if mod.flags[i] == "ON" then
                button.TextArgs.Color = Color.Blue
                button.Text = "已启用" .. button.Data.OriText
            else
                button.TextArgs.Color = Color.Red
                button.Text = "取消" .. button.Data.OriText
            end
        else
            if button.Data.OriText then
                button.TextArgs.Color = Color.White
                button.Text = button.Data.OriText
            end
        end
    end
end

function mod.setFlagForButton(button)
    if mod.flags[button.Key] then
        mod.flags[button.Key] = nil
        ModifyTextBox({ Id = button.Id, Text = button.OriText, Color = Color.White })
        debugShowText("取消" .. button.OriText)
        PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
    else
        mod.flags[button.Key] = button.Id
        ModifyTextBox({ Id = button.Id, Text = "取消" .. button.OriText, Color = Color.Red })
        debugShowText(button.OriText)
        PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    end
end


function mod.setOnForButton(button)
    if not mod.flags[button.Key] then
        mod.flags[button.Key] = "ON"
        ModifyTextBox({ Id = button.Id, Text = "已启用" .. button.OriText, Color = Color.Blue })
        debugShowText(button.OriText)
        PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    end
end

-- 设置必出混沌门
function mod.setChaosGate(screen, button)
    mod.setFlagForButton(button)
end

-- 必定出英雄稀有度祝福
function mod.setHeroic(screen, button)
    mod.setFlagForButton(button)
end

-- 不再出现资源房间
function mod.setNoRewardRoom(screen, button)
    mod.setFlagForButton(button)
end

-- 设置无限掷骰
function mod.setInfiniteRoll(screen, button)
    mod.setFlagForButton(button)
    if mod.flags[button.Key] then
        infiniteRoll = true
        local trait = GetHeroTrait("MetaToRunMetaUpgrade")
        if trait and trait.MetaConversionUses then
            trait.MetaConversionUses = 99
        end
        RerollCosts.Hammer = 1
    else
        infiniteRoll = false
        RerollCosts.Hammer = -1
        --RemoveTrait(CurrentRun.Hero, "DoorRerollMetaUpgrade")
        --RemoveTrait(CurrentRun.Hero, "PanelRerollMetaUpgrade")
    end
end

-- 本轮额外冲刺次数+1
function mod.setExtrarush(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    AddTraitToHero( { FromLoot = true, TraitData = GetProcessedTraitData( { Unit = CurrentRun.Hero, TraitName = 'CheatExtraRush' , Rarity = "Common" } ) } )
    curExtraRushCount = 0
end

-- 金币+100
function mod.setMoreMoney(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    AddResource( "Money", 100, "RunStart" )
end

function mod.GetFamiliar(familyName, screen)
    GameState.FamiliarsUnlocked[familyName] = true
    CurrentRun.FamiliarsUnlocked[familyName] = true
    mod.CloseBoonSelector(screen)
    debugShowText("已解锁宠物，下次进入房间生效！")
    SetAnimation({ Name = "Melinoe_Kneel", DestinationId = CurrentRun.Hero.ObjectId })
    wait( 6 * 0.85 )
    SetAnimation({ Name = "MelinoeIdleWeaponless", DestinationId = CurrentRun.Hero.ObjectId })
    thread( PlayVoiceLines, GlobalVoiceLines.FamiliarRecruitedVoiceLines )
    thread( CheckQuestStatus )
end


-- 获取乌鸦魔宠
function mod.GetRavenFamiliar(screen, button)
    mod.GetFamiliar("RavenFamiliar", screen)
end

function mod.GetFrogFamiliar(screen, button)
    mod.GetFamiliar("FrogFamiliar", screen)
end

function mod.GetCatFamiliar(screen, button)
    mod.GetFamiliar("CatFamiliar", screen)
end

function mod.GetHoundFamiliar(screen, button)
    mod.GetFamiliar("HoundFamiliar", screen)
end

function mod.GetPolecatFamiliar(screen, button)
    mod.GetFamiliar("PolecatFamiliar", screen)
end

function mod.RollChosen(screen, button)
    mod.setFlagForButton(button)
end

function mod.StartWithWeaponUpgrade(screen, button)
    mod.setFlagForButton(button)
end

-- NPC 配置表，包含每个 NPC 的默认 GameStateRequirements
local NPCConfig = {
    Artemis = {
        BaseEncounter = "BaseArtemisCombat",
        DefaultGameStateRequirements = {
            {
                PathTrue = { "GameState", "EncountersCompletedCache", "ArtemisCombatIntro" },
            },
            {
                PathFalse = { "CurrentRun", "UseRecord", "NPC_Artemis_Field_01" },
            },
            {
                Path = { "CurrentRun", "BiomeDepthCache" },
                Comparison = ">=",
                Value = 4,
            },
            NamedRequirements = { "NoRecentFieldNPCEncounter" },
            NamedRequirementsFalse = { "StandardPackageBountyActive", "SurfaceRouteLockedByTyphonKill" },
        }
    },
    Arachne = {
        BaseEncounter = "BaseArachneCombat",
        DefaultGameStateRequirements = {
            {
                PathTrue = { "GameState", "EncountersCompletedCache", "ArachneCombatF" },
            },
            {
                Path = { "CurrentRun", "EncountersOccurredBiomeCache" },
                HasNone = { "ArachneCombatF", "ArachneCombatG", "ArachneCombatN" },
            },
            NamedRequirements = { "NoRecentArachneEncounter" },
        }
    },
    Athena = {
        BaseEncounter = "BaseAthenaCombat",
        DefaultGameStateRequirements = {
            {
                PathTrue = { "GameState", "EncountersCompletedCache", "AthenaCombatIntro" },
            },
            {
                PathFalse = { "CurrentRun", "UseRecord", "NPC_Athena_01" },
            },
            {
                Path = { "CurrentRun", "BiomeDepthCache" },
                Comparison = ">=",
                Value = 4,
            },
            {
                PathFalse = { "CurrentRun", "ExpiredKeepsakes", "AthenaEncounterKeepsake" },
            },
            NamedRequirements = { "NoRecentFieldNPCEncounter" },
            NamedRequirementsFalse = { "StandardPackageBountyActive", "SurfaceRouteLockedByTyphonKill" },
        }
    },
    Heracles = {
        BaseEncounter = "BaseHeraclesCombat",
        DefaultGameStateRequirements = {
            {
                Path = { "CurrentRun", "EncountersCompletedCache" },
                SumOf = { "HeraclesCombatIntro", "HeraclesCombatN", "HeraclesCombatN2", "HeraclesCombatO", "HeraclesCombatO2", "HeraclesCombatP", "HeraclesCombatP2" },
                Comparison = "<=",
                Value = 0,
            },
            {
                PathTrue = { "GameState", "EncountersCompletedCache", "HeraclesCombatIntro" },
            },
            NamedRequirements = { "NoRecentHeraclesEncounter", "NoRecentFieldNPCEncounter" },
            NamedRequirementsFalse = { "StandardPackageBountyActive" },
        }
    },
    Icarus = {
        BaseEncounter = "BaseIcarusCombat",
        DefaultGameStateRequirements = {
            {
                PathFalse = { "CurrentRun", "UseRecord", "NPC_Icarus_01" },
            },
            {
                Path = { "CurrentRun", "BiomeDepthCache" },
                Comparison = ">=",
                Value = 3,
            },
            {
                Path = { "GameState", "BiomeVisits", "O" },
                Comparison = ">",
                Value = 1,
            },
            NamedRequirements = { "NoRecentFieldNPCEncounter" },
            NamedRequirementsFalse = { "StandardPackageBountyActive" },
        }
    },
    Nemesis = {
        BaseEncounter = "BaseNemesisCombat",
        DefaultGameStateRequirements = {
            {
                PathTrue = { "GameState", "EncountersCompletedCache", "NemesisCombatIntro" },
            },
            {
                PathTrue = { "GameState", "TextLinesRecord", "NemesisGetFreeItemIntro01" },
            },
            {
                Path = { "CurrentRun", "EncountersOccurredCache" },
                HasNone = { "NemesisCombatIntro", "NemesisCombatF", "NemesisCombatG", "NemesisCombatH", "NemesisCombatI" },
            },
            {
                Path = { "CurrentRun", "BiomeDepthCache" },
                Comparison = ">=",
                Value = 4,
            },
            NamedRequirements = { "NoRecentNemesisEncounter", "NoRecentFieldNPCEncounter" },
            NamedRequirementsFalse = { "StandardPackageBountyActive", "HecateMissing" },
        }
    }
}

-- 通用函数：设置或重置 NPC 的 AlwaysForce 和 GameStateRequirements
local function setNPCCombatAlwaysForce(npcName, enable)
    local config = NPCConfig[npcName]
    if not config then
        debugShowText("错误：未找到 NPC 配置 - " .. npcName)
        return
    end

    local encounter = EncounterData[config.BaseEncounter]
    if not encounter then
        debugShowText("错误：未找到 EncounterData - " .. config.BaseEncounter)
        return
    end

    if enable then
        -- 强制触发，简化 GameStateRequirements
        encounter.AlwaysForce = true
        encounter.GameStateRequirements = {
            {
                PathTrue = { "GameState", "EncountersCompletedCache", config.BaseEncounter .. "Intro" },
            }
        }
    else
        -- 恢复默认 GameStateRequirements
        encounter.AlwaysForce = false
        encounter.GameStateRequirements = DeepCopyTable(config.DefaultGameStateRequirements)
    end
end

-- 新增函数：同时对所有 NPC 设置或重置强制触发
function mod.AlwaysAllNPCCombat(screen, button)
    mod.setFlagForButton(button)
    local enable = mod.flags[button.Key]
    for npcName, _ in pairs(NPCConfig) do
        setNPCCombatAlwaysForce(npcName, enable)
    end
end

-- 针对每个 NPC 的函数，调用通用函数
function mod.AlwaysArtemisCombat(screen, button)
    mod.setFlagForButton(button)
    setNPCCombatAlwaysForce("Artemis", mod.flags[button.Key])
end

function mod.AlwaysArachneCombat(screen, button)
    mod.setFlagForButton(button)
    setNPCCombatAlwaysForce("Arachne", mod.flags[button.Key])
end

function mod.AlwaysAthenaCombat(screen, button)
    mod.setFlagForButton(button)
    setNPCCombatAlwaysForce("Athena", mod.flags[button.Key])
end

function mod.AlwaysHeraclesCombat(screen, button)
    mod.setFlagForButton(button)
    setNPCCombatAlwaysForce("Heracles", mod.flags[button.Key])
end

function mod.AlwaysIcarusCombat(screen, button)
    mod.setFlagForButton(button)
    setNPCCombatAlwaysForce("Icarus", mod.flags[button.Key])
end

function mod.AlwaysNemesisCombat(screen, button)
    mod.setFlagForButton(button)
    setNPCCombatAlwaysForce("Nemesis", mod.flags[button.Key])
end

-- 辅助函数：深拷贝表，确保恢复默认配置时不修改原始数据
function DeepCopyTable(orig)
    local copy = {}
    for k, v in pairs(orig) do
        if type(v) == "table" then
            copy[k] = DeepCopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function mod.ExpiringTimeThreshold(screen, button)
    mod.setFlagForButton(button)
    if mod.flags[button.Key] then
        EffectData.ChillEffect.EffectData.ExpiringTimeThreshold = 0.1;
    else
        EffectData.ChillEffect.EffectData.ExpiringTimeThreshold = 8;
    end
end

function mod.TorchNumAdd(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    local props = WeaponData.WeaponTorchSpecial.ChargeWeaponStages[1].WeaponProperties
    if props.NumProjectiles < 30 then
        props.NumProjectiles = props.NumProjectiles + 1
        props.ProjectileAngleOffset = math.rad(360 / props.NumProjectiles)
        debugShowText("当前数量 " .. tostring(props.NumProjectiles))
    else
        debugShowText("已达到最大数量 30")
    end
end

function mod.TorchNumRestore(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
    local props = WeaponData.WeaponTorchSpecial.ChargeWeaponStages[1].WeaponProperties
    props.NumProjectiles = 2
    props.ProjectileAngleOffset = math.rad(180)
    debugShowText("当前数量 " .. tostring(props.NumProjectiles))
end


function mod.FasterLevelUp(screen, button)
    mod.setFlagForButton(button)
    if mod.flags[button.Key] then
        TraitSetData.Keepsakes.GiftTrait.ChamberThresholds = {1, 1}
    else
        TraitSetData.Keepsakes.GiftTrait.ChamberThresholds = {25, 50}
    end
end


-- 配置表：存储默认值以便恢复
local DefaultConfig = {
    TorchSpecial = {
        NumProjectiles = 2,  -- 默认投射物数量
        ProjectileAngleOffset = nil,  -- 默认角度偏移
    },
    AxeExAttack = {
        ChargeWeaponStages = 		
        {
            { ManaCost = 10, WeaponProperties = { NumProjectiles = 1, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.32, ChannelSlowEventOnEnter = true, HideStageReachedFx = true },
            { ManaCost = 11, WeaponProperties = { NumProjectiles  = 2, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, HideStageReachedFx = true },
            { ManaCost = 12, WeaponProperties = { NumProjectiles  = 3, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, HideStageReachedFx = true },
            { ManaCost = 13, WeaponProperties = { NumProjectiles  = 4, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, HideStageReachedFx = true },
            { ManaCost = 14, WeaponProperties = { NumProjectiles  = 5, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, HideStageReachedFx = true },
            { ManaCost = 15, WeaponProperties = { NumProjectiles  = 6, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, HideStageReachedFx = true },
            { ManaCost = 16, WeaponProperties = { NumProjectiles  = 7, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, HideStageReachedFx = true },
            { ManaCost = 17, WeaponProperties = { NumProjectiles  = 8, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, HideStageReachedFx = true },
            { ManaCost = 18, WeaponProperties = { NumProjectiles  = 9, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, HideStageReachedFx = true },
            { ManaCost = 19, WeaponProperties = { NumProjectiles  = 10, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, HideStageReachedFx = true },
            { ManaCost = 20, WeaponProperties = { NumProjectiles  = 11, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11, },
		},
    },
    WeaponCoverage = {
        AngleCoverage = 220,  -- 默认角度覆盖
    },
    AxeSpinProjectile = {
        ArcEnd = -1080,  -- 默认弧线结束角度
    },
    MagnetismConsumable = {
        MagnetismEscalateDelay = 10.0,
        MagnetismHintRemainingTime = 5.0,
    },
    LobWeapon = {
        MaxAmmo = 4,  -- 默认弹药上限
    },
}

-- 按钮2：调整斧头EX攻击为一次性50个投射物（基于 Axe diff）
function mod.AxeMultiProjectile(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    mod.setFlagForButton(button)
    if mod.flags[button.Key] then
        WeaponData.WeaponAxe.ChargeWeaponStages = {
            { ManaCost = 20, WeaponProperties = { NumProjectiles  = 11, FireEndGraphic = "Melinoe_Axe_AttackEx1_End" }, Wait = 0.11 },
        }
        debugShowText("斧头EX攻击投射物设置为11，等待时间0.11秒")
    else
        -- 恢复默认值
        WeaponData.WeaponAxe.ChargeWeaponStages = DeepCopyTable(DefaultConfig.AxeExAttack.ChargeWeaponStages)
        debugShowText("恢复默认斧头EX攻击配置")
    end
end

-- 按钮3：调整武器效果覆盖角度为360度（基于 AngleCoverage diff）
function mod.FullCoverage(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    mod.setFlagForButton(button)
    local weapons = { "WeaponAxe" }  -- 可扩展到其他武器，如WeaponLob
    for _, weaponName in ipairs(weapons) do
        local weaponData = WeaponData[weaponName]
        if weaponData then
            for _, effect in ipairs(weaponData.Effects or {}) do
                if effect.AngleCoverage then
                    if mod.flags[button.Key] then
                        effect.AngleCoverage = 360
                        debugShowText(weaponName .. "覆盖角度设置为360度")
                    else
                        effect.AngleCoverage = DefaultConfig.WeaponCoverage.AngleCoverage
                        debugShowText(weaponName .. "恢复默认覆盖角度: 220度")
                    end
                end
            end
        end
    end
end

-- 按钮4：调整投射物弧线结束角度为-10800（基于 ArcEnd diff）
function mod.ExtendedArc(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    mod.setFlagForButton(button)
    local projectileName = "ProjectileAxeSpin"  -- 基于diff
    local projectileData = ProjectileData[projectileName]
    if projectileData then
        if mod.flags[button.Key] then
            projectileData.ArcEnd = -10800
            debugShowText("投射物弧线结束角度设置为-10800度")
        else
            projectileData.ArcEnd = DefaultConfig.AxeSpinProjectile.ArcEnd
            debugShowText("恢复默认弧线结束角度: -1080度")
        end
    else
        debugShowText("错误：未找到投射物 " .. projectileName)
    end
end

-- 按钮5：加速磁性效果（基于 Magnetism diff）
function mod.FastMagnetism(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    mod.setFlagForButton(button)
    local consumableName = "LobAmmoPack"  -- 假设为LobAmmoPack，基于ConsumableData
    local consumableData = ConsumableData[consumableName]
    if consumableData then
        if mod.flags[button.Key] then
            consumableData.MagnetismEscalateDelay = 1
            consumableData.MagnetismHintRemainingTime = 0.5
            debugShowText("磁性效果延迟设置为1秒，提示时间0.5秒")
        else
            consumableData.MagnetismEscalateDelay = DefaultConfig.MagnetismConsumable.MagnetismEscalateDelay
            consumableData.MagnetismHintRemainingTime = DefaultConfig.MagnetismConsumable.MagnetismHintRemainingTime
            debugShowText("恢复默认磁性效果: 延迟10秒，提示5秒")
        end
    else
        debugShowText("错误：未找到消耗品 " .. consumableName)
    end
end

-- 按钮6：调整Lob武器最大弹药为20（基于 MaxAmmo diff）
function mod.LobMaxAmmo(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    mod.setFlagForButton(button)
    local weaponData = WeaponData.WeaponLob
    if weaponData then
        if mod.flags[button.Key] then
            weaponData.MaxAmmo = 20
            debugShowText("Lob武器最大弹药设置为20")
        else
            weaponData.MaxAmmo = DefaultConfig.LobWeapon.MaxAmmo
            debugShowText("恢复默认最大弹药: 4")
        end
    else
        debugShowText("错误：未找到WeaponLob")
    end
end

-- 给我恢复
function mod.setRestoreHealth(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    Heal( CurrentRun.Hero, {HealAmount = 1000 })
end

-- 给我充能
function mod.setRestoreMana(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    CurrentRun.Hero.Mana =  CurrentRun.Hero.MaxMana
    thread( UpdateHealthUI, triggerArgs )
    thread( UpdateManaMeterUI, triggerArgs )
end

-- 击杀加1%概率掉落祝福
function mod.setDropLoot(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    metaupgradeDropBoonBoost = metaupgradeDropBoonBoost + 0.01
    if metaupgradeDropBoonBoost > 0.1 then
        metaupgradeDropBoonBoost = 0.1
    end
    debugShowText('当前概率' .. metaupgradeDropBoonBoost*1000 .. '%')
end

-- 关闭击杀概率掉落祝福
function mod.setStopDropLoot(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
    metaupgradeDropBoonBoost = 0
end

function patchSpendResource( fun )
    function newFun(name, amount, source, args)
        -- return true
        -- 父函数，照常执行
        fun(name, 0, source, args)
    end
    return newFun
end
function patchSpendResources( fun )
    function newFun(resourceCosts, source, args )
        -- 父函数，照常执行
        fun(nil, source, args )
    end
    return newFun
end
function patchHasResources( fun )
    function newFun(resourceCost )
        return true
    end
    return newFun
end
function patchHasResource( fun )
    function newFun( name, amount )
        return true
    end
    return newFun
end
function patchHasResourceCost( fun )
    function newFun( resourceCosts )
        if not resourceCosts then
            return false
        end
        for name, amount in pairs( resourceCosts ) do
            if amount > 0 then
                return true
            end
        end
        return false
    end
    return newFun
end

function patchRequireAffordableMetaUpgrade(fun)
    function newFun( source, args )
        return true
    end
    return newFun
end

function patchGetCurrentMetaUpgradeCost( upgradeName )
    function newFun( )
        return 0
    end
    return newFun
end

PreRequireAffordableMetaUpgrade = nil
PreGetCurrentMetaUpgradeCost = nil

-- 免费购买
function mod.FreeToBuy(screen, button)
    mod.setFlagForButton(button)
    if mod.flags[button.Key] then
        SpendResource = patchSpendResource(SpendResource)
        SpendResources = patchSpendResources(SpendResources)
        HasResources = patchHasResources(HasResources)
        HasResource = patchHasResource(HasResource)
        -- HasResourceCost = patchHasResourceCost(HasResourceCost)
        -- RequireAffordableMetaUpgrade = patchRequireAffordableMetaUpgrade(RequireAffordableMetaUpgrade)
        GetCurrentMetaUpgradeCost = patchGetCurrentMetaUpgradeCost(GetCurrentMetaUpgradeCost)
    else
        SpendResource = PreSpendResource
        SpendResources = PreSpendResources
        HasResources = PreHasResources
        HasResource = PreHasResource
        -- HasResourceCost = PreHasResourceCost
        -- RequireAffordableMetaUpgrade = PreRequireAffordableMetaUpgrade
        GetCurrentMetaUpgradeCost = PreGetCurrentMetaUpgradeCost
    end
end

function ShowDepthCounter()
    local screen = { Name = "RoomCount", Components = {} }
    screen.ComponentData = {
        RoomCount = DeepCopyTable(ScreenData.TraitTrayScreen.ComponentData.RoomCount)
    }
    CreateScreenFromData(screen, screen.ComponentData)
end


PreHasResource = nil
PreHasResourceCost = nil

-- 打开我的修改页面
function mod.ExtraSelectorLoadPage()
    if not initPreFun then
        PreSetTraitsOnLoot = SetTraitsOnLoot
        PreKillEnemy = KillEnemy
        PreSetTransformingTraitsOnLoot = SetTransformingTraitsOnLoot
        PreIsSecretDoorEligible = IsSecretDoorEligible
        PreChooseRoomReward = ChooseRoomReward
        PreAttemptReroll = AttemptReroll
        PreAttemptPanelReroll = AttemptPanelReroll
        PreHasAccessToTool = HasAccessToTool
        PreSpendResource = SpendResource
        PreSpendResources = SpendResources
        PreHasResources = HasResources
        PreHasResource = HasResource
        PreHasResourceCost = HasResourceCost
        PreRequireAffordableMetaUpgrade = RequireAffordableMetaUpgrade
        PreGetCurrentMetaUpgradeCost = GetCurrentMetaUpgradeCost
        initPreFun = true
        EphyraZoomOutPre = EphyraZoomOut
    end

    if IsScreenOpen("ExtraSelector") then
        return
    end
    local screen = DeepCopyTable(ScreenData.ExtraSelector)

    mod.BoonManagerPageButtons(screen, screen.Name)
    mod.UpdateScreenData()
    --CloseInventoryScreen(screen, screen.ComponentData.ActionBar.Children.CloseButton)

    screen.FirstPage = 0
    screen.LastPage = 0
    screen.CurrentPage = screen.FirstPage

    local components = screen.Components

    mod.updateExtraSelectorTextForInit(screen)

    OnScreenOpened(screen)
    CreateScreenFromData(screen, screen.ComponentData)
    SetColor({ Id = components.BackgroundTint.Id, Color = Color.Black })
    SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.0, Duration = 0 })
    SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })
    wait(0.3)

    SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
    screen.KeepOpen = true
    HandleScreenInput(screen)
end

--function mod.GiveConsumableToPlayer(screen, button)
--    DropMinorConsumable( button.Consumable.key )
--    -- MapState.RoomRequiredObjects = {}
--    -- 	if button.Consumable.UseFunctionName and button.Consumable.UseFunctionName == "OpenTalentScreen" then
--    --         DropMinorConsumable( button.Consumable.key )
--    -- --     	if not CurrentRun.ConsumableRecord["SpellDrop"] then
--    -- --             PlaySound({ Name = "/Leftovers/SFX/OutOfAmmo" })
--    -- -- 			return
--    -- -- 		end
--    -- -- 		mod.CloseConsumableSelector(screen)
--    -- 	end
--    -- 	UseConsumableItem(button.Consumable, {}, CurrentRun.Hero)
--end


EphyraZoomOutPre = nil
function EphyraZoomOut_override( usee )
    debugShowText('1')
    AddInputBlock({ Name = "EphyraZoomOut" })
    AddTimerBlock( CurrentRun, "EphyraZoomOut" )
    SessionMapState.BlockPause = true
    thread( HideCombatUI, "EphyraZoomOut", { SkipHideObjectives = true } )
    SetInvulnerable({ Id = CurrentRun.Hero.ObjectId })

    UseableOff({ Id = usee.ObjectId })

    ClearCameraClamp({ LerpTime = 0.8 })
    thread( SendCritters, { MinCount = 20, MaxCount = 20, StartX = 0, RandomStartOffsetX = 1200, StartY = 300, MinAngle = 75, MaxAngle = 115, MinSpeed = 400, MaxSpeed = 2000, MinInterval = 0.001, MaxInterval = 0.001, GroupName = "CrazyDeathBats" } )
    PanCamera({ Id = CurrentRun.Hero.ObjectId, OffsetY = -350, Duration = 1.0, EaseIn = 0, EaseOut = 0, Retarget = true })
    FocusCamera({ Fraction = CurrentRun.CurrentRoom.ZoomFraction * 0.95, Duration = 1, ZoomType = "Ease" })

    wait( 0.50 )

    local groupName = "Combat_Menu_Backing"
    local idsCreated = {}

    ScreenAnchors.EphyraZoomBackground = CreateScreenObstacle({ Name = "rectangle01", Group = "Combat_Menu", X = ScreenCenterX, Y = ScreenCenterY })
    table.insert( idsCreated, ScreenAnchors.EphyraZoomBackground )
    SetScale({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 5 })
    SetColor({ Ids = { ScreenAnchors.EphyraZoomBackground }, Color = Color.Black })
    SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 0, Duration = 0 })
    SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 1.0, Duration = 0.2 })

    local letterboxIds = {}
    if ScreenState.NeedsLetterbox then
        local letterboxId = CreateScreenObstacle({ Name = "BlankObstacle", X = ScreenCenterX, Y = ScreenCenterY, Group = "Combat_Menu", Animation = "GUI\\Graybox\\NativeAspectRatioFrame", Alpha = 0.0 })
        table.insert( letterboxIds, letterboxId )
        SetAlpha({ Id = letterboxId, Fraction = 1.0, Duration = 0.2, EaseIn = 0.0, EaseOut = 1.0 })
    elseif ScreenState.NeedsPillarbox then
        local pillarboxLeftId = CreateScreenObstacle({ Name = "BlankObstacle", X = ScreenState.PillarboxLeftX, Y = ScreenCenterY, ScaleX = ScreenState.PillarboxScaleX, Group = "Combat_Menu", Animation = "GUI\\SideBars_01", Alpha = 0.0 })
        table.insert( letterboxIds, pillarboxLeftId )
        SetAlpha({ Id = pillarboxLeftId, Fraction = 1.0, Duration = 0.2, EaseIn = 0.0, EaseOut = 1.0 })
        FlipHorizontal({ Id = pillarboxLeftId })
        local pillarboxRightId = CreateScreenObstacle({ Name = "BlankObstacle", X = ScreenState.PillarboxRightX, Y = ScreenCenterY, ScaleX = ScreenState.PillarboxScaleX, Group = "Combat_Menu", Animation = "GUI\\SideBars_01", Alpha = 0.0 })
        table.insert( letterboxIds, pillarboxRightId )
        SetAlpha({ Id = pillarboxRightId, Fraction = 1.0, Duration = 0.2, EaseIn = 0.0, EaseOut = 1.0 })
    end

    wait( 0.21 )

    ScreenAnchors.EphyraMapId = CreateScreenObstacle({ Name = "rectangle01", Group = groupName, X = ScreenCenterX, Y = ScreenCenterY })
    table.insert( idsCreated, ScreenAnchors.EphyraMapId )
    SetAnimation({ Name = usee.MapAnimation, DestinationId = ScreenAnchors.EphyraMapId })
    SetHSV({ Id = ScreenAnchors.EphyraMapId, HSV = { 0, -0.15, 0 }, ValueChangeType = "Add" })

    local exitDoorsIPairs = CollapseTableOrdered( MapState.OfferedExitDoors )
    local sortedDoors = {}
    for index, door in ipairs( exitDoorsIPairs ) do
        if not door.SkipUnlock then
            local room = door.Room
            local rawScreenLocation = ObstacleData[usee.Name].ScreenLocations[door.ObjectId]
            if rawScreenLocation ~= nil then
                door.ScreenLocationX = rawScreenLocation.X
                door.ScreenLocationY = rawScreenLocation.Y
                table.insert( sortedDoors, door )
            end
        end
    end
    table.sort( sortedDoors, EphyraZoomOutDoorSort )

    local attachedCircles = {}
    for index, door in ipairs( sortedDoors ) do
        local room = door.Room
        local screenLocation = { X = door.ScreenLocationX + ScreenCenterNativeOffsetX, Y = door.ScreenLocationY + ScreenCenterNativeOffsetY }
        local rewardBackingId = CreateScreenObstacle({ Name = "BlankGeoObstacle", Group = groupName, X = screenLocation.X, Y = screenLocation.Y, Scale = 0.6 })
        if room.RewardStoreName == "MetaProgress" then
            SetAnimation({ Name = "RoomRewardAvailable_Back_Meta", DestinationId = rewardBackingId })
        else
            SetAnimation({ Name = "RoomRewardAvailable_Back_Run", DestinationId = rewardBackingId })
        end
        table.insert( attachedCircles, rewardBackingId )

        local rewardIconId = CreateScreenObstacle({ Name = "RoomRewardPreview", Group = groupName, X = screenLocation.X, Y = screenLocation.Y, Scale = 0.6 })
        SetColor({ Id = rewardIconId, Color = { 0,0,0,1} })
        table.insert( attachedCircles, rewardIconId )
        local rewardHidden = false
        if HasHeroTraitValue( "HiddenRoomReward" ) then
            SetAnimation({ DestinationId = rewardIconId, Name = "ChaosPreview" })
            rewardHidden = true
        elseif room.ChosenRewardType == nil or room.ChosenRewardType == "Story" then
            SetAnimation({ DestinationId = rewardIconId, Name = "StoryPreview", SuppressSounds = true })
        elseif room.ChosenRewardType == "Shop" then
            SetAnimation({ DestinationId = rewardIconId, Name = "ShopPreview", SuppressSounds = true })
        elseif room.ChosenRewardType == "Boon" and room.ForceLootName then
            local previewIcon = LootData[room.ForceLootName].DoorIcon or LootData[room.ForceLootName].Icon
            if room.BoonRaritiesOverride ~= nil and LootData[room.ForceLootName].DoorUpgradedIcon ~= nil then
                previewIcon = LootData[room.ForceLootName].DoorUpgradedIcon
            end
            SetAnimation({ DestinationId = rewardIconId, Name = previewIcon, SuppressSounds = true })
        elseif room.ChosenRewardType == "Devotion" then

            local rewardIconAId = CreateScreenObstacle({ Name = "RoomRewardPreview", Group = groupName, X = screenLocation.X + 12, Y = screenLocation.Y - 11, Scale = 0.6 })
            SetColor({ Id = rewardIconAId, Color = { 0,0,0,1} })
            SetAnimation({ DestinationId = rewardIconAId, Name = LootData[room.Encounter.LootAName].DoorIcon, SuppressSounds = true })
            table.insert( attachedCircles, rewardIconAId )

            local rewardIconBId = CreateScreenObstacle({ Name = "RoomRewardPreview", Group = groupName, X = screenLocation.X - 12, Y = screenLocation.Y + 11, Scale = 0.6 })
            SetColor({ Id = rewardIconBId, Color = { 0,0,0,1} })
            SetAnimation({ DestinationId = rewardIconBId, Name = LootData[room.Encounter.LootBName].DoorIcon, SuppressSounds = true })
            table.insert( attachedCircles, rewardIconBId )
        else
            local animName = room.ChosenRewardType
            local lootData = LootData[room.ChosenRewardType]
            if lootData ~= nil then
                animName = lootData.DoorIcon or lootData.Icon or animName
            end
            local consumableData = ConsumableData[room.ChosenRewardType]
            if consumableData ~= nil then
                animName = consumableData.DoorIcon or consumableData.Icon or animName
            end
            SetAnimation({ DestinationId = rewardIconId, Name = animName, SuppressSounds = true })
        end

        local subIcons = PopulateDoorRewardPreviewSubIcons( door, { ChosenRewardType = chosenRewardType, RewardHidden = rewardHidden } )

        -- MOD Start
        if CurrentRun.PylonRooms and CurrentRun.PylonRooms[room.Name] then
            debugShowText('PylonRooms')
            table.insert(subIcons, "GUI\\Icons\\GhostPack")
        end
        if Contains(room.LegalEncounters, "HealthRestore") then
            debugShowText('HealthRestore')
            table.insert(subIcons, "ExtraLifeHeart")
        end
        if room.HarvestPointsAllowed > 0 then
            debugShowText('HarvestPointsAllowed')
            table.insert(subIcons, "GatherIcon")
        end
        if room.ShovelPointSuccess and HasAccessToTool("ToolShovel") then
            debugShowText('ToolShovel')
            table.insert(subIcons, "ShovelIcon")
        end
        if room.FishingPointSuccess and HasAccessToTool("ToolFishingRod") then
            debugShowText('ToolFishingRod')
            table.insert(subIcons, "FishingIcon")
        end
        if room.PickaxePointSuccess and HasAccessToTool("ToolPickaxe") then
            debugShowText('ToolPickaxe')
            table.insert(subIcons, "PickaxeIcon")
        end
        if room.ExorcismPointSuccess and HasAccessToTool("ToolExorcismBook") then
            debugShowText('ToolExorcismBook')
            table.insert(subIcons, "ExorcismIcon")
        end

        if room.RewardPreviewIcon ~= nil and not HasHeroTraitValue("HiddenRoomReward") then
            debugShowText('RewardPreviewIcon')
            table.insert(subIcons, room.RewardPreviewIcon)
        end
        -- MOD End

        local iconSpacing = 30
        local numSubIcons = #subIcons
        local isoOffset = iconSpacing * -0.5 * (numSubIcons - 1)
        for i, iconData in ipairs( subIcons ) do
            local iconId = CreateScreenObstacle({ Name = "BlankGeoObstacle", Group = groupName, Scale = 0.6 })
            local offsetAngle = 330
            if IsHorizontallyFlipped({ Id = door.ObjectId }) then
                offsetAngle = 30
                FlipHorizontal({ Id = iconId })
            end
            local offset = CalcOffset( math.rad( offsetAngle ), isoOffset )
            Attach({ Id = iconId, DestinationId = rewardBackingId, OffsetX = offset.X, OffsetY = offset.Y, OffsetZ = -60, })
            SetAnimation({ DestinationId = iconId, Name = iconData.Animation or iconData.Name })
            table.insert( attachedCircles, iconId )
            isoOffset = isoOffset + iconSpacing
        end

        if IsHorizontallyFlipped({ Id = door.ObjectId }) then
            local ids = ( { rewardBackingId, rewardIconId } )
            if not IsEmpty( ids ) then
                FlipHorizontal({ Ids = ids })
            end
        end

    end

    local melScreenLocation = ObstacleData[usee.Name].ScreenLocations[usee.ObjectId]
    ScreenAnchors.MelIconId = nil
    if melScreenLocation ~= nil then
        ScreenAnchors.MelIconId = CreateScreenObstacle({ Name = "rectangle01", Group = groupName, X = melScreenLocation.X + ScreenCenterNativeOffsetX, Y = melScreenLocation.Y + ScreenCenterNativeOffsetY, Scale = 1.5 })
        table.insert( idsCreated, ScreenAnchors.MelIconId )
        SetAnimation({ Name = "Mel_Icon", DestinationId = ScreenAnchors.MelIconId })
    end

    SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 0.0, Duration = 0.35 })
    PlaySound({ Name = "/Leftovers/World Sounds/MapZoomInShort" })
    wait( 0.5 )

    local zoomOutTime = 0.5

    ScreenAnchors.EphyraZoomBackground = CreateScreenObstacle({ Name = "rectangle01", Group = groupName, X = ScreenCenterX, Y = ScreenCenterY })
    table.insert( idsCreated, ScreenAnchors.EphyraZoomBackground )
    SetScale({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 5 })
    SetColor({ Ids = { ScreenAnchors.EphyraZoomBackground }, Color = Color.Black })
    SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground }, Fraction = 0, Duration = 0 })

    PlayInteractAnimation( usee.ObjectId )

    --FocusCamera({ Fraction = 0.195, Duration = 1, ZoomType = "Ease" })
    --PanCamera({ Id = 664260, Duration = 1.0, EaseIn = 0.3, EaseOut = 0.3 })

    wait(0.3)
    local notifyName = "ephyraZoomBackIn"
    NotifyOnControlPressed({ Names = { "Use", "Rush", "Shout", "Attack2", "Attack1", "Attack3", "AutoLock", "Cancel", }, Notify = notifyName })
    waitUntil( notifyName )
    PlaySound({ Name = "/Leftovers/World Sounds/MapZoomInShort" })

    --FocusCamera({ Fraction = CurrentRun.CurrentRoom.ZoomFraction * 1.0, Duration = 0.5, ZoomType = "Ease" })
    --PanCamera({ Id = CurrentRun.Hero.ObjectId, Duration = 0.5 })

    Move({ Id = ScreenAnchors.LetterBoxTop, Angle = 90, Distance = 150, EaseIn = 0.99, EaseOut = 1.0, Duration = 0.5 })
    Move({ Id = ScreenAnchors.LetterBoxBottom, Angle = 270, Distance = 150, EaseIn = 0.99, EaseOut = 1.0, Duration = 0.5 })
    SetAlpha({ Ids = { ScreenAnchors.EphyraZoomBackground, ScreenAnchors.MelIconId, ScreenAnchors.EphyraMapId, }, Fraction = 0, Duration = 0.25 })
    SetAlpha({ Ids = attachedCircles, Fraction = 0, Duration = 0.15 })
    SetAlpha({ Ids = letterboxIds, Fraction = 0, Duration = 0.15 })
    Destroy({ Ids = attachedCircles })

    local exitDoorsIPairs = CollapseTableOrdered( MapState.OfferedExitDoors )
    for index, door in ipairs( exitDoorsIPairs ) do
        if not door.SkipUnlock then
            SetScale({ Id = door.DoorIconId, Fraction = 1, Duration = 0.15 })
            AddToGroup({ Id = door.DoorIconId, Name = "FX_Standing_Top", DrawGroup = true })
        end
    end

    PanCamera({ Id = CurrentRun.Hero.ObjectId, OffsetY = 0, Duration = 0.65, EaseIn = 0, EaseOut = 0, Retarget = true })
    FocusCamera({ Fraction = CurrentRun.CurrentRoom.ZoomFraction, Duration = 0.65, ZoomType = "Ease" })
    local roomData = RoomData[CurrentRun.CurrentRoom.Name]
    if not roomData.IgnoreClamps then
        local cameraClamps = roomData.CameraClamps or GetDefaultClampIds()
        DebugAssert({ Condition = #cameraClamps ~= 1, Text = "Exactly one camera clamp on a map is non-sensical" })
        SetCameraClamp({ Ids = cameraClamps, SoftClamp = roomData.SoftClamp })
    end
    wait(0.45)

    thread( ShowCombatUI, "EphyraZoomOut" )
    --SetAlpha({ Ids = { ScreenAnchors.LetterBoxTop, ScreenAnchors.LetterBoxBottom, }, Fraction = 0, Duration = 0.25 })

    RemoveTimerBlock( CurrentRun, "EphyraZoomOut" )
    RemoveInputBlock({ Name = "EphyraZoomOut" })
    SessionMapState.BlockPause = false

    wait( 0.4 )
    Destroy({ Ids = { ScreenAnchors.LetterBoxTop, ScreenAnchors.LetterBoxBottom, ScreenAnchors.EphyraZoomBackground, ScreenAnchors.MelIconId, ScreenAnchors.EphyraMapId } })

    wait( 0.35 )
    SetVulnerable({ Id = CurrentRun.Hero.ObjectId })
    UseableOn({ Id = usee.ObjectId })

    Destroy({ Ids = idsCreated })
    Destroy({ Ids = letterboxIds })
end
