function debugShowText( text )
    thread( InCombatText, CurrentRun.Hero.ObjectId, text, 0.8, { SkipShadow = true } )
end


function warningShowTest(text)
    thread( InCombatTextArgs, { TargetId = CurrentRun.Hero.ObjectId, Text = text, Duration = 1.0, ShadowScaleX = 0.7 } )
end

--ChaosGate = "混沌之门",
ModUtil.Path.Wrap("IsSecretDoorEligible", function(base, currentRun, currentRoom)
    if mod.flags["ChaosGate"] then
        if IsGameStateEligible( currentRun, currentRoom, NamedRequirementsData.ForceSecretDoorRequirements) then
            return true
        end
        return false
    else
        return base(currentRun, currentRoom)
    end
end)

--InfiniteRoll = "无限Roll",
ModUtil.Path.Wrap("AttemptReroll", function(base, run, target)
    if mod.flags["InfiniteRoll"] then
        local lastRoll = run.NumRerolls
        base(run, target)
        run.NumRerolls = lastRoll
        local trait = GetHeroTrait("MetaToRunMetaUpgrade")
        if trait and trait.MetaConversionUses then
            trait.MetaConversionUses = 99
        end
    else
        base(run, target)
    end
end)
-- Roll 门
ModUtil.Path.Wrap("AttemptPanelReroll", function(base, screen, button)
    if mod.flags["InfiniteRoll"] then
        local lastRoll = CurrentRun.NumRerolls
        base(screen, button)
        CurrentRun.NumRerolls = lastRoll
        local trait = GetHeroTrait("MetaToRunMetaUpgrade")
        if trait and trait.MetaConversionUses then
            trait.MetaConversionUses = 99
        end
    else
        base(screen, button)
    end
end)

-- RollChosen = "按顺序Roll门选祝福",
ModUtil.Path.Wrap("AttemptRerollDoor", function(base, run, door)
    if mod.flags["RollChosen"] then
        local room = door.Room

        local rewardsChosen = {}
        if room.OriginalChosenRewardType == nil then
            room.OriginalChosenRewardType = room.ChosenRewardType
        end
        if room.OriginalForceLootName == nil then
            room.OriginalForceLootName = room.ForceLootName
        end
        table.insert( rewardsChosen, { RewardType = room.OriginalChosenRewardType, ForceLootName = room.OriginalForceLootName } )
        for index, offeredDoor in pairs( MapState.OfferedExitDoors ) do
            if offeredDoor.Room ~= nil then
                table.insert( rewardsChosen, { RewardType = offeredDoor.Room.ChosenRewardType, ForceLootName = offeredDoor.Room.ForceLootName } )
            end
        end

        -- Remove the existing reward
        room.PrevForceLootName = room.ForceLootName
        room.ForceLootName = nil
        room.RewardOverrides = nil
        if room.Encounter ~= nil then
            if room.Encounter.LootAName ~= nil then
                local animName = LootData[room.Encounter.LootAName].DoorIcon
                Destroy({ Id = door.AdditionalIcons[animName] })
                door.AdditionalIcons[animName] = nil
                room.Encounter.LootAName = nil
            end
            if room.Encounter.LootBName ~= nil then
                local animName = LootData[room.Encounter.LootBName].DoorIcon
                Destroy({ Id = door.AdditionalIcons[animName] })
                door.AdditionalIcons[animName] = nil
                room.Encounter.LootBName = nil
            end
            room.Encounter = nil
        end

        local prevChosenRewardType = room.ChosenRewardType

        run.CurrentRoom.DeferReward = false
        room.ChosenRewardType = ChooseRoomReward( run, room, room.RewardStoreName, rewardsChosen, { IgnoreGameStateRequirements = false, } )

        --region MOD开始
        local myBoonList = {"ZeusUpgrade","HeraUpgrade", "PoseidonUpgrade", "DemeterUpgrade","ApolloUpgrade","AphroditeUpgrade","HephaestusUpgrade","HestiaUpgrade", "AresUpgrade"}
        local myChosenRewardTypeList = { "WeaponUpgrade","HermesUpgrade","SpellDrop","TalentDrop","MaxHealthDrop","MaxManaDrop","RoomMoneyDrop","StackUpgrade"}

        if(run.myRollIndex == nil) then run.myRollIndex = 0 end
        if(run.myCurrentDoor == door) then
            run.myRollIndex = run.myRollIndex +1
        else
            run.myCurrentDoor = door
        end
        local myLen = #myBoonList + # myChosenRewardTypeList;
        local idx = run.myRollIndex % myLen + 1
        if(idx <= #myBoonList) then
            room.ChosenRewardType = "Boon"
            room.ForceLootName = myBoonList[idx]
        else
            room.ChosenRewardType = myChosenRewardTypeList[idx - #myBoonList]
        end
        CurrentRun.NumRerolls = CurrentRun.NumRerolls + 1
        --endregion

        SetupRoomReward( run, room, rewardsChosen )
        run.CurrentRoom.OfferedRewards[door.ObjectId] = { Type = room.ChosenRewardType, ForceLootName = room.ForceLootName, UseOptionalOverrides = room.UseOptionalOverrides }

        if room.ChosenRewardType == "Devotion" and prevChosenRewardType ~= "Devotion" then
            SetScale({ Ids = door.RewardPreviewIconIds, Fraction = 0.0, Duration = 0.1 })
        else
            SetScale({ Ids = door.RewardPreviewIconIds, Fraction = 1.0, Duration = 0.1 })
        end

        CreateDoorRewardPreview( door, nil, nil, nil, { ReUseIds = true } )

        RefreshUseButton( door.ObjectId, door )
    else
        base(run, door)
    end
end)


-- StartWithWeaponUpgrade = "必锤子开局",
-- ModUtil.Path.Wrap("StartNewRun", function(base, prevRun, args)
--     if mod.flags["StartWithWeaponUpgrade"] then
--         local run = base(prevRun, args)
--         run.CurrentRoom.ChosenRewardType = "WeaponUpgrade"
--         return run
--     else
--         return base(screen, button)
--     end
-- end)


-- 每次进新房间之前触发
mod._AddRerolled = false
ModUtil.Path.Wrap("BeforeEachRoom", function(base)
    if mod.flags["InfiniteRoll"] then
        base()
        CurrentRun.NumRerolls = 99
        if not mod._AddRerolled then
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
            mod._AddRerolled = true
        end
    else
        base()
    end
end)
--Heroic = "必出英雄祝福",

ModUtil.Path.Wrap("SetTraitsOnLoot", function(base, lootData, args)
    base(lootData, args)
    if mod.flags["Heroic"] then
        for k, item in pairs(lootData.UpgradeOptions) do
            if item.Rarity then
                item.Rarity = 'Heroic'
            end
        end
    end
end)


ModUtil.Path.Wrap("SetTransformingTraitsOnLoot", function(base, lootData, args)
    if mod.flags["Heroic"] then
        base(lootData, args)
        for k, item in pairs( lootData.UpgradeOptions ) do
            if item.Rarity then
                item.Rarity = 'Heroic'
            end
        end
    else
        base(lootData, args)
    end
end)


--NoRewardRoom = "不出现资源房间",
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

ModUtil.Path.Wrap("ChooseRoomReward", function(base, run, room, rewardStoreName, previouslyChosenRewards, args)
    if mod.flags["NoRewardRoom"] then
        -- 父函数，照常执行,获取房间名称
        local name = base(run, room, rewardStoreName, previouslyChosenRewards, args)
        -- 替换为祝福
        if name and replaceList[name] ~= nil and (replaceList[name].chance == nil or RandomChance(replaceList[name].chance)  ) then
            debugShowText(replaceList[name].text)
            name = replaceList[name].target
        end
        return name
    else
        return base(run, room, rewardStoreName, previouslyChosenRewards, args)
    end
end)

--DropLoot = "击杀概率掉落祝福",
ModUtil.Path.Wrap("Kill", function(base, victim, triggerArgs)
    base(victim, triggerArgs)
    local debugBoons = { "ZeusUpgrade", "HeraUpgrade", "PoseidonUpgrade", "ApolloUpgrade", "DemeterUpgrade", "AphroditeUpgrade", "HephaestusUpgrade", "HestiaUpgrade", "HermesUpgrade" }
    if victim ~= CurrentRun.Hero and metaupgradeDropBoonBoost > 0 and EnemyData[victim.Name] ~= nil then
        if( RandomChance(metaupgradeDropBoonBoost) )  then
            warningShowTest("击杀掉落祝福!")
            CreateLoot({ Name = debugBoons[math.random(1,#debugBoons)], DestinationId = CurrentRun.Hero.ObjectId, OffsetX = math.random(-500,500), OffsetY = math.random(-500,500)})
        end
    end
end)

-- FreeToBuy 免费购买
ModUtil.Path.Wrap("SpendResource", function(base, name, amount, source, args)
    if mod.flags.FreeToBuy then
        -- 免费：amount 强制为 0
        return base(name, 0, source, args)
    else
        return base(name, amount, source, args)
    end
end)

ModUtil.Path.Wrap("SpendResources", function(base, resourceCosts, source, args)
    if mod.flags.FreeToBuy then
        -- 忽略 resourceCosts
        return base(nil, source, args)
    else
        return base(resourceCosts, source, args)
    end
end)

ModUtil.Path.Wrap("HasResources", function(base, resourceCost)
    if mod.flags.FreeToBuy then
        return true
    else
        return base(resourceCost)
    end
end)

ModUtil.Path.Wrap("HasResource", function(base, name, amount)
    if mod.flags.FreeToBuy then
        return true
    else
        return base(name, amount)
    end
end)

ModUtil.Path.Wrap("GetCurrentMetaUpgradeCost", function(base, upgradeName)
    if mod.flags.FreeToBuy then
        return 0
    else
        return base(upgradeName)
    end
end)
