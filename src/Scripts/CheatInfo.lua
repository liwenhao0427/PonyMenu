-- 击杀时有概率掉落祝福
metaupgradeDropBoonBoost = 0
-- 无限Roll
infiniteRoll = false
-- 额外冲刺次数【仅房间生效，获得祝福】
extraRushCount = 0
-- 默认配置稀有度
RaritySet = 'Rare'
-- CheckRoomExitsReady 不收集资源无法离开
-- SpawnStoreItemInWorld 喀戎商店


function logMessage( message )
	debugShowText(message)
end

-- function displayLogs()
--     local logText = table.concat(logs, "\n")
--     if ScreenAnchors.LogDisplay then
--         ModifyTextBox({ Id = ScreenAnchors.LogDisplay.Id, Text = logText })
--     else
--         ScreenAnchors.LogDisplay = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_UI", X = 100, Y = 100 })
--         CreateTextBox({ Id = ScreenAnchors.LogDisplay.Id, Text = logText, FontSize = 14, Color = Color.White, Font = "AlegreyaSansSCRegular", ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset = {0, 2}, Justification = "Left" })
--     end
-- end

-- 强制英雄
function patchSetTraitsOnLoot( fun )
    function SetTraitsOnLoot( lootData, args )
        fun(lootData, args)
        for k, item in pairs( lootData.UpgradeOptions ) do
            if item.Rarity then 
                item.Rarity = 'Heroic' 
            end
        end
    end
    return SetTraitsOnLoot
end

function patchSetTransformingTraitsOnLoot( fun )
    function SetTransformingTraitsOnLoot( lootData, upgradeChoiceData )
        fun(lootData, upgradeChoiceData)
        for k, item in pairs( lootData.UpgradeOptions ) do
            if item.Rarity then 
                item.Rarity = 'Heroic' 
            end
        end
    end
    return SetTransformingTraitsOnLoot
end



AddRerolled = false
curExtraRushCount = extraRushCount
-- 每轮游戏刚开始时进行的操作
function patchEachRun(fun)
    function newFun(prevRun, args)
        -- 父函数，照常执行
        CurrentRun = fun(prevRun, args)
        
        -- 初始化
        AddRerolled = false
        curExtraRushCount = extraRushCount
        -- for k, debugBoon in pairs( initBoons ) do
        --     CreateLoot({ Name = debugBoon, DestinationId = CurrentRun.Hero.ObjectId, OffsetX = math.random(-500,500), OffsetY = math.random(-500,500) })
        -- end
        -- 击杀时随机获取祝福
        -- Kill = patchKill(Kill)
        return CurrentRun
    end
	return newFun
end




-- 永远返回真的函数
function alwaysTrue()
    return true
end

-- WeaponUpgrade 武器升级 Devotion 双神 RoomMoneyDrop 钱 MaxHealthDrop MaxManaDrop 最大血/蓝 HermesUpgrade 赫尔墨斯 HephaestusUpgrade 锤神 StackUpgrade 祝福升级  TalentDrop 大招 AirBoost  Boon 随机祝福 ArtemisUpgrade 猎神【会报错】
local resource = "GiftDrop,MetaCurrencyDrop,MetaCardPointsCommonDrop,MemPointsCommonDrop"
local replaceList = {
    -- 蜜露
    GiftDrop = {
        target =  'Boon',
        chance = 0.3,
        text =  '蜜露替换为随机祝福',
    },
    Boon = {
        chance = 0.1,
        target = 'WeaponUpgrade',
        text = '随机祝福替换为武器升级',
    },
    -- 三项基本资源
    MetaCurrencyDrop = {
        target = 'MaxHealthDrop',
        text = '骨骸替换为最大生命',
    },
    MetaCardPointsCommonDrop = {
        target = 'MaxManaDrop',
        text = '尘灰替换为最大法力',
    },
    MemPointsCommonDrop = {
        target = 'HermesUpgrade',
        text = '魂魄替换为赫尔墨斯祝福',
    },
}
-- 房间奖励
function patchChooseRoomReward(fun)
    function newFun(run, room, rewardStoreName, previouslyChosenRewards, args)
        -- 父函数，照常执行,获取房间名称
        name = fun(run, room, rewardStoreName, previouslyChosenRewards, args)
        -- 替换为祝福
        if name and replaceList[name] ~= nil and (replaceList[name].chance == nil or RandomChance(replaceList[name].chance)  ) then
            debugShowText(replaceList[name].text)
            name = replaceList[name].target
        end
        return name
    end
	return newFun
end



-- 混沌门必定出现
function patchIsSecretDoorEligible(fun)
    function newFun(currentRun, currentRoom)
        if IsGameStateEligible( currentRun, currentRoom, NamedRequirementsData.ForceSecretDoorRequirements) then
            return true
        end
        return false
    end
	return newFun
end


-- 每次进新房间之前触发
function patchBeforeEachRoom( fun )
    function newFun()
        -- 父函数，照常执行
        fun()

        -- 击杀时随机获取祝福
        -- KillEnemy = patchKill(KillEnemy)
        -- -- 强制出英雄稀有度祝福
        -- if forceHeroic then
        --     SetTraitsOnLoot = patchSetTraitsOnLoot(SetTraitsOnLoot)
        --     SetTransformingTraitsOnLoot = patchSetTransformingTraitsOnLoot(SetTransformingTraitsOnLoot)
        -- end
        -- -- 强制chaos
        -- if forceSecretDoor then
        --     IsSecretDoorEligible = patchIsSecretDoorEligible(IsSecretDoorEligible)
        -- end
        -- -- 不出现资源房间
        -- if forceTraitRoom then
        --     ChooseRoomReward = patchChooseRoomReward(ChooseRoomReward)
        -- end
        -- 额外冲刺次数
        -- if curExtraRushCount > 0 then 
        --     -- TraitData.CheatExtraRush.Name = '额外冲刺次数+' .. extraRushCount
        --     -- TraitData.CheatExtraRush.RarityLevels.Heroic.Multiplier = extraRushCount
        --     AddTraitToHero( { FromLoot = true, TraitData = GetProcessedTraitData( { Unit = CurrentRun.Hero, TraitName = 'CheatExtraRush' , Rarity = "Heroic" } ) } )
        --     curExtraRushCount = 0
        -- end
        -- 无限Roll
        if infiniteRoll then
            CurrentRun.NumRerolls = 9
            if not AddRerolled then
				-- 塔罗牌
				AddTraitToHero({
					TraitData = GetProcessedTraitData({
						Unit = CurrentRun.Hero,
						TraitName = "DoorRerollMetaUpgrade"
					}),
					SkipNewTraitHighlight = true,
					SkipQuestStatusCheck = true,
					SkipActivatedTraitUpdate = true,
				})
				-- 塔罗牌
				AddTraitToHero({
					TraitData = GetProcessedTraitData({
						Unit = CurrentRun.Hero,
						TraitName = "PanelRerollMetaUpgrade"
					}),
					SkipNewTraitHighlight = true,
					SkipQuestStatusCheck = true,
					SkipActivatedTraitUpdate = true,
				})
                AddRerolled = true
            end
			-- local trait = GetHeroTrait("MetaToRunMetaUpgrade")
			-- if trait and trait.MetaConversionUses then
			-- 	trait.MetaConversionUses = 3
			-- end 
        end
    end
	return newFun
end

-- AttemptReroll Roll
-- Roll祝福
function patchAttemptReroll( fun )
    function newFun(run, target)
        -- 父函数，照常执行
        local lastRoll = run.NumRerolls 
        fun(run, target)
        run.NumRerolls = lastRoll
		if trait and trait.MetaConversionUses then
			trait.MetaConversionUses = 99
		end 
    end
	return newFun
end
-- Roll 门
function patchAttemptPanelReroll(fun)
    function newFun(screen, button)
        -- 父函数，照常执行
        local lastRoll = CurrentRun.NumRerolls 
        fun(screen, button)
        CurrentRun.NumRerolls = lastRoll
		if trait and trait.MetaConversionUses then
			trait.MetaConversionUses = 99
		end 
    end
	return newFun
end


-- 按下G/RT时操作
-- Debug
-- 初始化原来的函数一次，用以还原
initPreFun = false
PreSetTraitsOnLoot = nil
PreKillEnemy = nil
PreSetTransformingTraitsOnLoot = nil
PreIsSecretDoorEligible = nil
PreChooseRoomReward = nil
PreAttemptReroll = nil
PreAttemptPanelReroll = nil
PreHasAccessToTool = nil
PreSpendResource = nil
PreSpendResources = nil
PreHasResources = nil


function openCheatScreen() 
	-- 初始化原来的函数一次，用以还原
	if not initPreFun then 
		PreSetTraitsOnLoot = SetTraitsOnLoot
		PreKillEnemy = KillEnemy
		PreSetTransformingTraitsOnLoot = SetTransformingTraitsOnLoot
		PreIsSecretDoorEligible = IsSecretDoorEligible
		PreChooseRoomReward = ChooseRoomReward
		PreAttemptReroll = AttemptReroll
		PreAttemptPanelReroll = AttemptPanelReroll
		PreHasAccessToTool = HasAccessToTool
		initPreFun = true
	end
	OpenDebugEnemyCheatScreen()
end

-- -- 主神列表
-- initBoons = { "ZeusUpgrade", "HeraUpgrade", "PoseidonUpgrade", "ApolloUpgrade", "DemeterUpgrade", "AphroditeUpgrade", "HephaestusUpgrade", "HestiaUpgrade", "HermesUpgrade" }

-- 击杀敌人时触发
function patchKill( fun )
    function newFun(victim, triggerArgs)
        -- 父函数，照常执行
        fun(victim, triggerArgs)
        local debugBoons = { "ZeusUpgrade", "HeraUpgrade", "PoseidonUpgrade", "ApolloUpgrade", "DemeterUpgrade", "AphroditeUpgrade", "HephaestusUpgrade", "HestiaUpgrade", "HermesUpgrade" }
        if victim ~= CurrentRun.Hero and metaupgradeDropBoonBoost > 0 and EnemyData[victim.Name] ~= nil then
            if( RandomChance(metaupgradeDropBoonBoost) )  then
                warningShowTest("击杀掉落祝福!")
                CreateLoot({ Name = debugBoons[math.random(1,#debugBoons)], DestinationId = CurrentRun.Hero.ObjectId, OffsetX = math.random(-500,500), OffsetY = math.random(-500,500)}) 
            end
        end
    end
	return newFun
end


function debugShowText( text )
    thread( InCombatText, CurrentRun.Hero.ObjectId, text, 0.8, { SkipShadow = true } )
end


function warningShowTest(text)
    thread( InCombatTextArgs, { TargetId = CurrentRun.Hero.ObjectId, Text = text, Duration = 1.0, ShadowScaleX = 0.7 } )
end




function isInDiyTraitData(str)
	for _, value in ipairs(DiyTraitData) do
		if value == str then
			return true
		end
	end
	return false
end


-- 自定义祝福列表
OverwriteTableKeys( TraitData,
{
    CheatExtraRush = {
        Name= 'CheatExtraRush',
		CustomTitle= "额外冲刺",
		Description = "获得额外冲刺次数，普通1、稀有2、史诗3、英雄4",
		InheritFrom = { "BaseTrait", "LegacyTrait", "AirBoon" },
		BlockStacking = true,
		Icon = "Boon_Poseidon_36",
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.00,
			},
			Rare =
			{
				Multiplier = 2.00,
			},
			Epic =
			{
				Multiplier = 3.00,
			},
			Heroic =
			{
				Multiplier = 10.00,
			}
		},
		PropertyChanges =
		{
			{
				WeaponNames = WeaponSets.HeroBlinkWeapons,
				WeaponProperty = "ClipSize",
				BaseValue = 1,
				ChangeType = "Add",
				ReportValues = { ReportedBonusSprint = "ChangeValue"},
			},
		},
	},
    CheatTraitSpeed = {
        Name = "CheatTraitSpeed",
		CustomTitle= "额外移速",
		Description = "获得额外移速，普通1.0、稀有1.5、史诗2.0、英雄2.5",
		InheritFrom = { "BaseTrait", "LegacyTrait", "WaterBoon" },
		Icon = "Boon_Poseidon_36",
		BlockStacking = true,
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.5,
			},
			Epic =
			{
				Multiplier = 2.0,
			},
			Heroic =
			{
				Multiplier = 2.5,
			}
		},
        -- DamageOnFireWeapons =
		-- {
		-- 	WeaponNames = WeaponSets.HeroRangedWeapons,
		-- 	ExcludeLinked = true,
		-- 	Damage =
		-- 	{
		-- 		BaseMin = 3,
		-- 		BaseMax = 6,
		-- 		AsInt = true,
		-- 	},
		-- 	ReportValues =
		-- 	{
		-- 		ReportedDamage = "Damage"
		-- 	},
		-- },
        PropertyChanges =
		{
			{
				UnitProperty = "Speed",
				ChangeType = "Multiply",
				ChangeValue = 2,
				SourceIsMultiplier = true,
				ReportValues = { ReportedBaseSpeed = "ChangeValue" },
			},
		},

    },

	DaggerSpecialFanTraitOld =
	{
		Name = "DaggerSpecialFanTraitOld",
		CustomTitle= "八面神锋",
		Description = "匕首专属改造，你的特技造成20%额外伤害，且你的武器额外发射16把飞刀。",

		InheritFrom = { "WeaponTrait", "DaggerHammerTrait" },
		Icon = "Hammer_Daggers_34",
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponDagger", },
			},
			{
				Path = { "CurrentRun", "Hero", "TraitDictionary", },
				HasNone = { "DaggerSpecialLineTrait", },
			},
		},
		AddOutgoingDamageModifiers =
		{
			ValidWeaponMultiplier =
			{
				BaseValue = 1.2,
				SourceIsMultiplier = true,
			},
			ValidWeapons = { "WeaponDaggerThrow" },
			ReportValues = { ReportedWeaponMultiplier = "ValidWeaponMultiplier"},
			ExcludeLinked = true,
		},
		WeaponDataOverride =
		{
			WeaponDaggerThrow =
			{
				ChargeWeaponStages =
				{
					{ ManaCost = 6, WeaponProperties = { Projectile = "ProjectileDaggerThrowCharged", FireGraphic = "Melinoe_Dagger_SpecialEx_Fire", NumProjectiles = 4}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.32, ChannelSlowEventOnEnter = true },
					{ ManaCost = 8, WeaponProperties = { NumProjectiles = 6 }, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 10, WeaponProperties = { NumProjectiles = 8}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 12, WeaponProperties = { NumProjectiles  = 10}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 14, WeaponProperties = { NumProjectiles  = 12}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 16, WeaponProperties = { NumProjectiles  = 13}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 18, WeaponProperties = { NumProjectiles  = 15}, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.1, },
					{ ManaCost = 20, WeaponProperties = { NumProjectiles  = 16, ReportValues = { ReportedAmount = "NumProjectiles" } }, ApplyEffects = { "WeaponDaggerThrowEXDisable", "WeaponDaggerThrowEXDisableCancellable", "WeaponDaggerThrowEXDisableMoveHold" }, Wait = 0.06, },
				},
			}
		},
		PropertyChanges =
		{
			{
				WeaponName = "WeaponDaggerThrow",
				WeaponProperties =
				{
					ProjectileAngleOffset = math.rad(22.5),
					ProjectileInterval = 0.015,
				},
				ProjectileProperties =
				{
					DrawDuringPause = false,
				},
				ExcludeLinked = true
			},
		},
		ExtractValues =
		{
			{
				Key = "ReportedAmount",
				ExtractAs = "Amount",
			},
			{
				Key = "ReportedWeaponMultiplier",
				ExtractAs = "DamageIncrease",
				Format = "PercentDelta",
			},
		}
	},


	AxeComboSwingTraitOld = 
	{
		Name = "AxeComboSwingTraitOld",
		CustomTitle= "斧头连击",
		Description = "斧头专属改造,攻击速度提升",

		InheritFrom = { "WeaponTrait", "AxeHammerTrait" },
		Icon = "Hammer_Axe_32",
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponAxe", },
			},
		},
		OnWeaponFiredFunctions = 
		{
			ValidWeapons = { "WeaponAxe2" },
			ExcludeLinked = true,
			FunctionName = "SpeedUpSpecial",
			FunctionArgs = 
			{
				ChargeMultiplier = 0.1,
				Window = 0.8,
			}

		},

	},


	AxeConsecutiveStrikeTraitOld = 
	{
		Name = "AxeConsecutiveStrikeTraitOld",
		CustomTitle= "执念旋风",
		Description = "斧专属改造,连续命中时伤害提升",
		InheritFrom = { "WeaponTrait", "AxeHammerTrait" },
		Icon = "Hammer_Axe_31",	
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponAxe", },
			},
			{
				Path = { "CurrentRun", "Hero", "TraitDictionary", },
				HasNone = { "AxeAttackRecoveryTrait" },
			},
		},
		PropertyChanges =
		{
			{
				WeaponName = "WeaponAxeSpin",
				ProjectileProperties = 
				{
					ConsecutiveHitWindow = 0.25,
					DamagePerConsecutiveHit = 2,
					ReportValues = { ReportedDamage = "DamagePerConsecutiveHit"},
				},
			}
		},
		
		ExtractValues =
		{
			{
				Key = "ReportedDamage",
				ExtractAs = "Damage",
			},
		}
	},

	ApolloMissStrikeBoonOld =
	{
		Name = "ApolloMissStrikeBoonOld",
		CustomTitle= "技高一筹",
		Description = "阿波洛祝福,闪避时造成致命一击",
		Icon = "Boon_Apollo_38",
		InheritFrom = { "BaseTrait", "AirBoon" },
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.5,
			},
			Epic =
			{
				Multiplier = 2.0,
			},
			Heroic =
			{
				Multiplier = 2.5,
			},
		},
		OnDodgeFunction = 
		{
			FunctionName = "ApolloBlindStrike",
			RunOnce = true,
			FunctionArgs =
			{
				ValidActiveEffectGenus = "Blind",
				ProjectileName = "ApolloPerfectDashStrike",
				DamageMultiplier = { 
					BaseValue = 1,
					MinMultiplier = 0.1,
					IdenticalMultiplier =
					{
						Value = -0.5,
						DiminishingReturnsMultiplier = 0.8,
					}, 
				},
				Cooldown = 0.2,
				ReportValues = { ReportedMultiplier = "DamageMultiplier"},
			},
		},
		
	},


	DaggerSpecialRangeTraitOld = 
	{
		Name = "DaggerSpecialRangeTraitOld",
		CustomTitle= "远射",
		Description = "匕首专属改造，你的特技距离更远，并且超出650码后造成双倍伤害。",
		InheritFrom = { "WeaponTrait", "DaggerHammerTrait" },
		Icon = "Hammer_Daggers_37",
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponDagger", },
			},
		},
		AddOutgoingDamageModifiers =
		{
			ValidWeapons = { "WeaponDaggerThrow" },
			ExcludeLinked = true,
			DistanceThreshold = 650,
			DistanceMultiplier =
			{
				BaseValue = 2,
				SourceIsMultiplier = true,
			},
			ReportValues = { ReportedWeaponMultiplier = "DistanceMultiplier"},
		},
		ChargeStageModifiers = 
		{
			ValidWeapons = { "WeaponDaggerThrow", },
			RevertProjectileProperties = 
			{
				Range = true,
			},
		},
		PropertyChanges =
		{
			{
				WeaponName = "WeaponDaggerThrow",
				ProjectileName = "ProjectileDaggerThrow",
				ProjectileProperties = 
				{
					Range = 1400,
				},
			},
		},
	},
	DaggerRepeatStrikeTraitOld = 
	{
		Name = "DaggerRepeatStrikeTraitOld",
		CustomTitle= "自动攻击",
		Description = "匕首专属改造，长安自动攻击",
		InheritFrom = { "WeaponTrait", "DaggerHammerTrait" },
		Icon = "Hammer_Daggers_37",
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "Hero", "Weapons", },
				HasAll = { "WeaponDagger", },
			},
		},
		PropertyChanges =
		{
			{
				WeaponName = "WeaponDaggerMultiStab",
				ExcludeLinked = true,
				WeaponProperties = 
				{
					FullyAutomatic = true,
					ControlWindow = 0.6,
					SwapOnFire = "WeaponDaggerMultiStab",
					AddOnFire = "null",
					LoseControlIfNotCharging = true,
					ForceReleaseOnSwap = false,
				}
			},
		},
	},

	RandomDuoBoon = 
	{
		Name = "RandomDuoBoon",
		CustomTitle= "觥筹交错",
		Description = "获得一个今夜你接受过的奥林匹斯神的随机双重祝福。",
		InheritFrom = { "BaseTrait", "WaterBoon" },
		Icon = "Boon_Dionysus_33",
		
		AcquireFunctionName = "GrantEligibleDuo",
		AcquireFunctionArgs = 
		{
			SkipRequirements = true,		-- Skip prereq traits
			Count = 1,
			BlockedTraits = 
			{
				SuperSacrificeBoonHera = true,
				SuperSacrificeBoonZeus = true,
			},
			ReportValues = { ReportedCount = "Count"}
		},
	},


	CoverRegenerationBoonOld = -- Apollo x Hestia
	{
		Name = "CoverRegenerationBoonOld",
		CustomTitle= "凤凰涅槃",
		Description = "牺牲100最大生命。如果你在一段时间内没有造成伤害，也没有受到伤害，快速恢复生命。",
		InheritFrom = {"SynergyTrait"},
		Icon = "Boon_Hestia_42",
		
		OnEnemyDamagedAction = 
		{
			ValidWeapons = WeaponSets.HeroAllWeapons,
			FunctionName = "InterruptRegen",
		},
		SetupFunction = 
		{
			Name = "OutOfCombatRegenSetup",
			Args = 
			{
				Timeout = 3, -- Time before regen kicks in
				Regen = 3, -- Per second regen
				RegenStartFx = nil,
				RegenStartSound = nil,
				ReportValues =
				{
					ReportedTimeout = "Timeout",
					ReportedRegen = "Regen",
				}
			}
		},
		PropertyChanges =
		{
			{
				LuaProperty = "MaxHealth",
				ChangeValue = -100,
				ChangeType = "Add",
				AsInt = true,
				ReportValues = { ReportedHealthPenalty = "ChangeValue"},
			},
		},
		StatLines = 
		{
			"CoverRegenStatDisplay1",
		},
		CustomStatLinesWithShrineUpgrade = 
		{
			ShrineUpgradeName = "HealingReductionShrineUpgrade",
			StatLines = 
			{
				"CoverRegenStatDisplay1",
				"HealingReductionNotice",
			},
		},
	},

	EchoRepeatKeepsakeBoonOld = 
	{
		Name = "EchoRepeatKeepsakeBoonOld",
		CustomTitle= "信物{#Echo1}信物{#Prev}{#Echo2}信物",
		Description = "在下一个{$Keywords.Biome}中，获得你当前{$Keywords.KeepsakeAlt}的全部效果{#ItalicLightFormat}（即使你之后更换了信物）。",
		InheritFrom = { "BaseEcho" },
		Icon = "Boon_Echo_07",
		TrayStatLines = 
		{
			"RepeatKeepsakeStatDisplay",
		},
		ActivatedTrayText = "EchoRepeatKeepsakeBoon_Inactive",
		RepeatedKeepsake = "",
		AcquireFunctionName = "EchoRepeatKeepsake",
	},

	ElementalDodgeBoonOld = 
	{
		Name = "ElementalDodgeBoonOld",
		CustomTitle= "轻盈如风",
		Description = "每有一个{!Icons.CurseAir}系祝福，获得{$Keywords.Dodge}概率。",
		InheritFrom = {"UnityTrait"},
		Icon = "Boon_Aphrodite_33",
		GameStateRequirements = 
		{
			{
				Path = { "CurrentRun", "Hero", "Elements", "Air" },
				Comparison = ">=",
				Value = 2,
			},
		},
		ElementalMultipliers = 
		{
			Air = true,
		},		
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1
			},
		},
		PropertyChanges = 
		{
			{
				LifeProperty = "DodgeChance",
				BaseValue = 0.03,
				ChangeType = "Add",
				MultipliedByElement = "Air",
				DataValue = false,
				ReportValues = 
				{ 
					ReportedTotalDodgeBonus = "ChangeValue",
					ReportedDodgeBonus = "BaseValue",
				},
			},
		},
		StatLines =
		{
			"ElementalDodgeStatDisplay1",
		},
		TrayStatLines = 
		{
			"TotalDodgeChanceStatDisplay1",
		},
		ExtractValues =
		{
			{
				Key = "ReportedTotalDodgeBonus",
				ExtractAs = "TooltipTotalDodgeBonus",
				Format = "Percent",
				SkipAutoExtract = true,
			},
			{
				Key = "ReportedDodgeBonus",
				ExtractAs = "TooltipDodgeBonus",
				Format = "Percent",
			},
		},
	},

	HadesLaserThresholdBoonOld = 
	{
		Name = "HadesLaserThresholdBoonOld",
		CustomTitle= "愤怒叱喝",
		Description = "每当你受到 {$TooltipData.ExtractData.Threshold} 点伤害后，进入{$Keywords.Invulnerable}状态并向四周发射光束，持续 {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} 秒{#Prev}。",
		InheritFrom = { "InPersonOlympianTrait" },
		Icon = "Boon_Hades_08",
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.5,
			},
			Epic =
			{
				Multiplier = 2.0,
			},
			Heroic =
			{
				Multiplier = 2.5,
			},
		},
		BlockInRunRarify = true,
		OnSelfDamagedFunction = 
		{
			NotDamagingRetaliate = true,
			Name = "CheckRadialLaserRetaliate",
			FunctionArgs = 
			{
				HealthThreshold = 100,
				ProjectileName = "HadesCastBeam",
				ProjectileCount = 4,
				InvulnerabilityDuration = 5,
				ReportValues = 
				{ 
					ReportedThreshold = "HealthThreshold",
					ReportedCount = "ProjectileCount",
					ReportedDuration = "InvulnerabilityDuration",
				}
			}
		},
		StatLines =
		{
			"LaserDamageStatDisplay",
		},
		ExtractValues =
		{
			{
				ExtractAs = "Damage",
				External = true,
				BaseType = "ProjectileBase",
				BaseName = "HadesCastBeam",
				BaseProperty = "Damage",
			},
			{
				ExtractAs = "Interval",
				SkipAutoExtract = true,
				External = true,
				BaseType = "ProjectileBase",
				BaseName = "HadesCastBeam",
				BaseProperty = "ImmunityDuration",
				DecimalPlaces = 2,
			},
			{
				Key = "ReportedThreshold",
				ExtractAs = "Threshold",
				SkipAutoExtract = true,
			},
			{
				Key = "ReportedCount",
				ExtractAs = "Count",
				SkipAutoExtract = true,
			},
			{
				Key = "ReportedDuration",
				ExtractAs = "Duration",
				SkipAutoExtract = true,
			},
		},
	},

	HexCooldownBuffBoonOld = 
	{
		Name = "HexCooldownBuffBoonOld",
		CustomTitle= "夜色阑珊",
		Description = "当你的{$Keywords.Spell}已就绪时，你的移动和武器速度加快。",
		InheritFrom = {"AirBoon"},
		Icon = "Boon_Hermes_32",
		HexCooldownSpeedBuff = { BaseValue = 0.85, SourceIsMultiplier = true },
		GameStateRequirements =
		{
			{
				PathTrue = { "CurrentRun", "Hero", "SlottedTraits", "Spell", },
			},
			{
				Path = { "CurrentRun", "Hero", "TraitDictionary", },
				HasNone = { "SpellPotionTrait" },
			},
		},
		
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.34,
			},
			Epic =
			{
				Multiplier = 1.67,
			},
			Heroic =
			{
				Multiplier = 2.00,
			},
		},
		
	},
})


DiyTraitData = {
	"CheatExtraRush",
	"CheatTraitSpeed",
	"DaggerSpecialFanTraitOld",
	-- "AxeComboSwingTraitOld",
	-- "AxeConsecutiveStrikeTraitOld",
	"ApolloMissStrikeBoonOld",
	-- "DaggerSpecialRangeTraitOld",
	-- "DaggerRepeatStrikeTraitOld",
	-- "RandomDuoBoon",
	"CoverRegenerationBoonOld",
	"EchoRepeatKeepsakeBoonOld",
	"ElementalDodgeBoonOld",
	-- "HadesLaserThresholdBoonOld",
	"HexCooldownBuffBoonOld",
	-- "SpeedRunBossKeepsake",
	-- "RevengeManaTrait",
	-- "ManaInsideCastTrait",
	-- "StaffSlowExTrait",
	-- "StaffReserveManaBoostTrait",
	-- "TemporaryImprovedWeaponTrait",
	-- "MinorManaDiscountTalent",
	-- "ManaDiscountTalent",
	-- "ChargeSpeedTalent",
	-- "SpellChargeBonusTalent",
	-- "TimeSlowDashTalent",
	-- "LaserPatienceTalent",
	-- "LaserSpeedTalent",
	-- "PolymorphAoETalent",
	-- "TorchSpinAttackAltTrait",
	-- "TorchHomingAttackTrait",
	-- "TorchConsecutiveStrikeTrait",
	-- "TorchOrbitDistanceTrait",	
}

