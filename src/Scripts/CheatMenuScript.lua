
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

-- 强制故事房间
function mod.AlwaysEncounterStoryRooms(screen, button)
    mod.setFlagForButton(button)
    if mod.flags[button.Key] then
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMin = 4
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMax = 8

        RoomSetData.G.G_Story01.ForceAtBiomeDepthMin = 3
        RoomSetData.G.G_Story01.ForceAtBiomeDepthMax = 6

        RoomSetData.N.N_Story01.ForceAtBiomeDepthMin = 0
        RoomSetData.N.N_Story01.ForceAtBiomeDepthMax = 1

        RoomSetData.O.O_Story01.ForceAtBiomeDepthMin = 3
        RoomSetData.O.O_Story01.ForceAtBiomeDepthMax = 5

        RoomSetData.P.P_Story01.ForceAtBiomeDepthMin = 2
        RoomSetData.P.P_Story01.ForceAtBiomeDepthMax = 7
    else
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMin = nil
        RoomSetData.F.F_Story01.ForceAtBiomeDepthMax = nil

        RoomSetData.G.G_Story01.ForceAtBiomeDepthMin = nil
        RoomSetData.G.G_Story01.ForceAtBiomeDepthMax = nil

        RoomSetData.N.N_Story01.ForceAtBiomeDepthMin = nil
        RoomSetData.N.N_Story01.ForceAtBiomeDepthMax = nil

        RoomSetData.O.O_Story01.ForceAtBiomeDepthMin = nil
        RoomSetData.O.O_Story01.ForceAtBiomeDepthMax = nil

        RoomSetData.P.P_Story01.ForceAtBiomeDepthMin = nil
        RoomSetData.P.P_Story01.ForceAtBiomeDepthMax = nil
    end
end


-- 真实减速
function mod.SlowEffectsOnTimer(screen, button)
    debugShowText(button.OriText)
    PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
    ModUtil.Path.Override("UpdateTimers", function(elapsed)
        if CurrentRun == nil then
            return
        end

        GameState.TotalTime = GameState.TotalTime + elapsed
        -- MOD START
        local timeMultEnv = GetGameplayElapsedTimeMultiplier()
        local timeMultPlayer = GetPlayerGameplayElapsedTimeMultiplier()
        elapsed = elapsed * timeMultEnv
        elapsed = elapsed * timeMultPlayer
        -- MOD END
        CurrentRun.TotalTime = CurrentRun.TotalTime + elapsed

        if CurrentRun.Hero.IsDead then
            return
        end

        if not IsEmpty( CurrentRun.BlockTimerFlags ) or not IsEmpty( MapState.BlockTimerFlags ) then
            return
        end

        GameState.GameplayTime = GameState.GameplayTime + elapsed
        CurrentRun.GameplayTime = CurrentRun.GameplayTime + elapsed

        if HeroHasTrait("TimedBuffKeepsake") then
            if not IsBiomeTimerPaused() then
                local traitData = GetHeroTrait("TimedBuffKeepsake")
                traitData.CurrentTime = traitData.CurrentTime - elapsed
                if traitData.CurrentTime  <= 0 and (traitData.CurrentTime  + elapsed) > 0 then
                    traitData.CustomName = traitData.ZeroBonusTrayText
                    EndTimedBuff( traitData )
                    thread( TimedBuffExpiredPresentation, traitData )
                    ReduceTraitUses( traitData, {Force = true } )
                end
            end
        end

        if HeroHasTrait("ChaosTimeCurse") then
            if not IsBiomeTimerPaused() then
                local traitData = GetHeroTrait("ChaosTimeCurse")
                traitData.CurrentTime = traitData.CurrentTime - elapsed
                local threshold = 30
                if traitData.CurrentTime  <= threshold and (traitData.CurrentTime  + elapsed) > threshold then
                    ChaosTimerAboutToExpirePresentation(threshold )
                elseif traitData.CurrentTime  <= 0 and (traitData.CurrentTime  + elapsed) > 0 then
                    if not CurrentRun.Hero.InvulnerableFlags.BlockDeath then
                        CurrentRun.CurrentRoom.Encounter.TookChaosCurseDamage = true
                        CurrentRun.CurrentRoom.KilledByChaosCurse = true
                        thread( SacrificeHealth, { SacrificeHealthMin = traitData.Damage, SacrificeHealthMax = traitData.Damage, MinHealth = 0, AttackerName = "TrialUpgrade" } )
                    end
                    if not CurrentRun.Hero.IsDead then
                        thread( RemoveTraitData, CurrentRun.Hero, traitData )
                    end
                end
            end
        end

        if CurrentRun.ActiveBiomeTimer and not IsBiomeTimerPaused() then
            CurrentRun.BiomeTime = CurrentRun.BiomeTime - elapsed
            local threshold = 30
            if CurrentRun.BiomeTime <= threshold and (CurrentRun.BiomeTime + elapsed) > threshold then
                BiomeTimerAboutToExpirePresentation(threshold )
            elseif CurrentRun.BiomeTime <= 0 and (CurrentRun.BiomeTime + elapsed) > 0 then
                BiomeTimerExpiredPresentation()
            end
        end
    end)
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
    warningShowTest('当前概率' .. metaupgradeDropBoonBoost*1000 .. '%')
end

-- 关闭击杀概率掉落祝福
function mod.setStopDropLoot(screen, button)
    PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
    metaupgradeDropBoonBoost = 0
end

-- Boss 显示血量
function mod.BossHealthLoot(screen, button)
    mod.setOnForButton(button)
    ModUtil.Path.Override("CreateBossHealthBar", function(boss)
        local encounter = CurrentRun.CurrentRoom.Encounter
        if encounter ~= nil and encounter.UseGroupHealthBar ~= nil then
            if not boss.HasHealthBar then
                local offsetY = -155
                boss.HasHealthBar = true
                if boss.Scale ~= nil then
                    offsetY = offsetY * boss.Scale
                end
                if boss.HealthBarOffsetY then
                    offsetY = boss.HealthBarOffsetY
                end
                -- Invisible health bar for effect purposes
                local screenId = SpawnObstacle({ Name = "BlankObstacle", Group = "Combat_UI_World", DestinationId = boss.ObjectId, Attach = true, OffsetY = offsetY, TriggerOnSpawn = false })
                EnemyHealthDisplayAnchors[boss.ObjectId] = screenId
            end
            if not encounter.HasHealthBar then
                CreateGroupHealthBar(encounter)
            end
            return
        end
        if boss.HasHealthBar then
            return
        end
        boss.HasHealthBar = true

        if ScreenAnchors.BossHealthTitles == nil then
            ScreenAnchors.BossHealthTitles = {}
        end
        local index = TableLength(ScreenAnchors.BossHealthTitles)
        local numBars = GetNumBossHealthBars()
        local yOffset = 0
        local xScale = 1 / numBars
        boss.BarXScale = xScale
        local totalWidth = ScreenWidth * xScale
        local xOffset = (totalWidth / (2 * numBars)) * (1 + index * 2) + (ScreenWidth - totalWidth) / 2

        if numBars == 0 then
            return
        end

        ScreenAnchors.BossHealthBack = CreateScreenObstacle({ Name = "BossHealthBarBack", Group = "Combat_UI", X = xOffset, Y = 70 + yOffset })
        ScreenAnchors.BossHealthTitles[boss.ObjectId] = ScreenAnchors.BossHealthBack

        local fallOffBar = CreateScreenObstacle({ Name = "BossHealthBarFillFalloff", Group = "Combat_UI", X = xOffset, Y = 72 + yOffset })
        SetColor({ Id = fallOffBar, Color = Color.HealthFalloff })
        SetAnimationFrameTarget({ Name = "EnemyHealthBarFillSlowBoss", Fraction = 0, DestinationId = fallOffBar, Instant = true })

        ScreenAnchors.BossHealthFill = CreateScreenObstacle({ Name = "BossHealthBarFill", Group = "Combat_UI", X = xOffset, Y = 72 + yOffset })

        CreateAnimation({ Name = "BossNameShadow", DestinationId = ScreenAnchors.BossHealthBack })

        SetScaleX({ Ids = { ScreenAnchors.BossHealthBack, ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = xScale, Duration = 0 })

        local bossName = boss.HealthBarTextId or boss.Name

        if boss.AltHealthBarTextIds ~= nil then
            local eligibleTextIds = {}
            for k, altTextIdData in pairs(boss.AltHealthBarTextIds) do
                if IsGameStateEligible(CurrentRun, altTextIdData.Requirements) then
                    table.insert(eligibleTextIds, altTextIdData.TextId)
                end
            end
            if not IsEmpty(eligibleTextIds) then
                bossName = GetRandomValue(eligibleTextIds)
            end
        end

        CreateTextBox({
            Id = ScreenAnchors.BossHealthBack,
            Text = bossName,
            Font = "CaesarDressing",
            FontSize = 22,
            ShadowRed = 0,
            ShadowBlue = 0,
            ShadowGreen = 0,
            OutlineColor = { 0, 0, 0, 1 },
            OutlineThickness = 2,
            ShadowAlpha = 1.0,
            ShadowBlur = 0,
            ShadowOffsetY = 3,
            ShadowOffsetX = 0,
            Justification = "Center",
            OffsetY = -30,
            OpacityWithOwner = false,
            AutoSetDataProperties = true,
        })
        --Mod start
        boss.NumericHealthbar = CreateScreenObstacle({ Name = "BlankObstacle", Group = "Combat_UI", X = xOffset, Y = 112 + yOffset })
        CreateTextBox({
            Id = boss.NumericHealthbar,
            Text = boss.Health .. "/" .. boss.MaxHealth,
            FontSize = 18,
            ShadowRed = 0,
            ShadowBlue = 0,
            ShadowGreen = 0,
            OutlineColor = { 0, 0, 0, 1 },
            OutlineThickness = 2,
            ShadowAlpha = 1.0,
            ShadowBlur = 0,
            ShadowOffsetY = 3,
            ShadowOffsetX = 0,
            Justification = "Center",
            OffsetY = 0,
            OpacityWithOwner = false,
            AutoSetDataProperties = true,
        })
        --Mod end

        ModifyTextBox({ Id = ScreenAnchors.BossHealthBack, FadeTarget = 0, FadeDuration = 0 })
        SetAlpha({ Id = ScreenAnchors.BossHealthBack, Fraction = 0.01, Duration = 0.0 })
        SetAlpha({ Id = ScreenAnchors.BossHealthBack, Fraction = 1.0, Duration = 2.0 })
        EnemyHealthDisplayAnchors[boss.ObjectId .. "back"] = ScreenAnchors.BossHealthBack

        boss.HealthBarFill = "EnemyHealthBarFillBoss"
        SetAnimationFrameTarget({ Name = "EnemyHealthBarFillBoss", Fraction = boss.Health / boss.MaxHealth, DestinationId = screenId })
        SetAlpha({ Ids = { ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 0.01, Duration = 0.0 })
        SetAlpha({ Ids = { ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 1, Duration = 2.0 })
        EnemyHealthDisplayAnchors[boss.ObjectId] = ScreenAnchors.BossHealthFill
        EnemyHealthDisplayAnchors[boss.ObjectId .. "falloff"] = fallOffBar
        --Mod start
        EnemyHealthDisplayAnchors[boss.ObjectId .. "numeric"] = boss.NumericHealthbar
        --Mod end
        thread(BossHealthBarPresentation, boss)
    end)

    ModUtil.Path.Override("CreateGroupHealthBar", function(encounter)
        encounter.HasHealthBar = true

        local xOffset = ScreenWidth / 2
        local yOffset = 0
        if ScreenAnchors.BossHealthTitles == nil then
            ScreenAnchors.BossHealthTitles = {}
        end

        ScreenAnchors.BossHealthBack = CreateScreenObstacle({ Name = "BossHealthBarBack", Group = "Combat_UI", X = xOffset, Y = 70 + yOffset })
        ScreenAnchors.BossHealthTitles[encounter.Name] = ScreenAnchors.BossHealthBack

        local fallOffBar = CreateScreenObstacle({ Name = "BossHealthBarFillFalloff", Group = "Combat_UI", X = xOffset, Y = 72 + yOffset })
        SetColor({ Id = fallOffBar, Color = Color.HealthFalloff })
        SetAnimationFrameTarget({ Name = "EnemyHealthBarFillSlowBoss", Fraction = 0, DestinationId = fallOffBar, Instant = true })

        ScreenAnchors.BossHealthFill = CreateScreenObstacle({ Name = "BossHealthBarFill", Group = "Combat_UI", X = xOffset, Y = 72 + yOffset })

        CreateAnimation({ Name = "BossNameShadow", DestinationId = ScreenAnchors.BossHealthBack })

        SetScaleX({ Ids = { ScreenAnchors.BossHealthBack, ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 1, Duration = 0 })

        local barName = EncounterData[encounter.Name].HealthBarTextId or encounter.Name

        CreateTextBox({
            Id = ScreenAnchors.BossHealthBack,
            Text = barName,
            Font = "CaesarDressing",
            FontSize = 22,
            ShadowRed = 0,
            ShadowBlue = 0,
            ShadowGreen = 0,
            OutlineColor = { 0, 0, 0, 1 },
            OutlineThickness = 2,
            ShadowAlpha = 1.0,
            ShadowBlur = 0,
            ShadowOffsetY = 3,
            ShadowOffsetX = 0,
            Justification = "Center",
            OffsetY = -30,
            OpacityWithOwner = false,
            AutoSetDataProperties = true,
        })
        --Mod start
        ScreenAnchors.NumericHealthbar = CreateScreenObstacle({ Name = "BlankObstacle", Group = "Combat_UI", X = xOffset, Y = 112 + yOffset })
        CreateTextBox({
            Id = ScreenAnchors.NumericHealthbar,
            Text = encounter.GroupHealth .. "/" .. encounter.GroupMaxHealth,
            FontSize = 18,
            ShadowRed = 0,
            ShadowBlue = 0,
            ShadowGreen = 0,
            OutlineColor = { 0, 0, 0, 1 },
            OutlineThickness = 2,
            ShadowAlpha = 1.0,
            ShadowBlur = 0,
            ShadowOffsetY = 3,
            ShadowOffsetX = 0,
            Justification = "Center",
            OffsetY = 0,
            OpacityWithOwner = false,
            AutoSetDataProperties = true,
        })
        --Mod end

        ModifyTextBox({ Id = ScreenAnchors.BossHealthBack, FadeTarget = 0, FadeDuration = 0 })
        SetAlpha({ Id = ScreenAnchors.BossHealthBack, Fraction = 0.01, Duration = 0.0 })
        SetAlpha({ Id = ScreenAnchors.BossHealthBack, Fraction = 1.0, Duration = 2.0 })
        EnemyHealthDisplayAnchors[encounter.Name .. "back"] = ScreenAnchors.BossHealthBack

        encounter.HealthBarFill = "EnemyHealthBarFillBoss"
        SetAnimationFrameTarget({ Name = "EnemyHealthBarFillBoss", Fraction = 1, DestinationId = ScreenAnchors.BossHealthFill })
        SetAlpha({ Ids = { ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 0.01, Duration = 0.0 })
        SetAlpha({ Ids = { ScreenAnchors.BossHealthFill, fallOffBar }, Fraction = 1, Duration = 2.0 })
        EnemyHealthDisplayAnchors[encounter.Name] = ScreenAnchors.BossHealthFill
        EnemyHealthDisplayAnchors[encounter.Name .. "falloff"] = fallOffBar
        --Mod start
        EnemyHealthDisplayAnchors[encounter.Name .. "numeric"] = ScreenAnchors.NumericHealthbar
        --Mod end
        thread(GroupHealthBarPresentation, encounter)
    end)

    ModUtil.Path.Override("UpdateHealthBarReal", function(args)
        local enemy = args[1]

        if enemy.UseGroupHealthBar then
            UpdateGroupHealthBarReal(args)
            return
        end

        local screenId = args[2]
        local scorchId = args[3]
        --Mod start
        local numericHealthBar = EnemyHealthDisplayAnchors[enemy.ObjectId .. "numeric"]
        --Mod end

        if enemy.IsDead then
            if enemy.UseBossHealthBar then
                CurrentRun.BossHealthBarRecord[enemy.Name] = 0
            end
            SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1, DestinationId = scorchId, Instant = true })
            SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1, DestinationId = screenId, Instant = true })
            --Mod start
            if numericHealthBar ~= nil then
                Destroy({ Id = numericHealthBar })
            end
            --Mod end
            return
        end


        local maxHealth = enemy.MaxHealth
        local currentHealth = enemy.Health
        if currentHealth == nil then
            currentHealth = maxHealth
        end

        UpdateHealthBarIcons(enemy)

        if enemy.UseBossHealthBar then
            local healthFraction = currentHealth / maxHealth
            CurrentRun.BossHealthBarRecord[enemy.Name] = healthFraction
            SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1 - healthFraction, DestinationId = screenId, Instant = true })
            --Mod start
            ModifyTextBox({ Id = numericHealthBar, Text = round(currentHealth) .. "/" .. maxHealth })
            --Mod end
            if enemy.HitShields > 0 then
                SetColor({ Id = screenId, Color = Color.HitShield })
            else
                SetColor({ Id = screenId, Color = Color.Red })
            end
            thread(UpdateBossHealthBarFalloff, enemy)
            return
        end

        local displayedHealthPercent = 1
        local predictedHealthPercent = 1

        if enemy.CursedHealthBarEffect then
            if enemy.HitShields ~= nil and enemy.HitShields > 0 then
                SetColor({ Id = screenId, Color = Color.CurseHitShield })
            elseif enemy.HealthBuffer ~= nil and enemy.HealthBuffer > 0 then
                SetColor({ Id = screenId, Color = Color.CurseHealthBuffer })
            else
                SetColor({ Id = screenId, Color = Color.CurseHealth })
            end
            SetColor({ Id = backingScreenId, Color = Color.CurseFalloff })
        elseif enemy.Charmed then
            SetColor({ Id = screenId, Color = Color.CharmHealth })
            SetColor({ Id = backingScreenId, Color = Color.HealthBufferFalloff })
        else
            if enemy.HitShields ~= nil and enemy.HitShields > 0 then
                SetColor({ Id = screenId, Color = Color.HitShield })
            elseif enemy.HealthBuffer ~= nil and enemy.HealthBuffer > 0 then
                SetColor({ Id = screenId, Color = Color.HealthBuffer })
                SetColor({ Id = backingScreenId, Color = Color.HealthBufferFalloff })
            else
                SetColor({ Id = screenId, Color = Color.Red })
                SetColor({ Id = backingScreenId, Color = Color.HealthFalloff })
            end
        end

        if enemy.HitShields ~= nil and enemy.HitShields > 0 then
            displayedHealthPercent = 1
            predictedHealthPercent = 1
        elseif enemy.HealthBuffer ~= nil and enemy.HealthBuffer > 0 then
            displayedHealthPercent = enemy.HealthBuffer / enemy.MaxHealthBuffer
            if enemy.ActiveEffects and enemy.ActiveEffects.BurnEffect then
                predictedHealthPercent = math.max(0, enemy.HealthBuffer - enemy.ActiveEffects.BurnEffect) / enemy.MaxHealthBuffer
            else
                predictedHealthPercent = displayedHealthPercent
            end
        else
            displayedHealthPercent = currentHealth / maxHealth
            if enemy.ActiveEffects and enemy.ActiveEffects.BurnEffect then
                predictedHealthPercent = math.max(0, currentHealth - enemy.ActiveEffects.BurnEffect) / maxHealth
            else
                predictedHealthPercent = displayedHealthPercent
            end
        end
        enemy.DisplayedHealthFraction = displayedHealthPercent
        SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1 - predictedHealthPercent, DestinationId = screenId, Instant = true })
        SetAnimationFrameTarget({ Name = enemy.HealthBarFill or "EnemyHealthBarFill", Fraction = 1 - displayedHealthPercent, DestinationId = scorchId, Instant = true })
        thread(UpdateEnemyHealthBarFalloff, enemy)
    end)

    ModUtil.Path.Override("UpdateGroupHealthBarReal", function(args)
        local enemy = args[1]
        local screenId = args[2]
        local encounter = CurrentRun.CurrentRoom.Encounter
        local backingScreenId = EnemyHealthDisplayAnchors[encounter.Name .. "falloff"]

        local maxHealth = encounter.GroupMaxHealth
        local currentHealth = 0
        --Mod start
        local numericHealthBar = ScreenAnchors.NumericHealthbar
        --Mod end

        for k, unitId in pairs(encounter.HealthBarUnitIds) do
            local unit = ActiveEnemies[unitId]
            if unit ~= nil then
                currentHealth = currentHealth + unit.Health
            end
        end
        encounter.GroupHealth = currentHealth

        local healthFraction = currentHealth / maxHealth
        CurrentRun.BossHealthBarRecord[encounter.Name] = healthFraction
        --Mod start
        ModifyTextBox({ Id = numericHealthBar, Text = round(currentHealth) .. "/" .. maxHealth })
        --Mod end

        SetAnimationFrameTarget({ Name = encounter.HealthBarFill or "EnemyHealthBarFill", Fraction = 1 - healthFraction, DestinationId = screenId, Instant = true })
        thread(UpdateGroupHealthBarFalloff, encounter)
    end)

    ModUtil.Path.Wrap("BossChillKillPresentation", function(base, unit)
        if EnemyHealthDisplayAnchors[unit.ObjectId .. "numeric"] ~= nil then
            local numericHealthBar = EnemyHealthDisplayAnchors[unit.ObjectId .. "numeric"]
            Destroy({ Id = numericHealthBar })
        end
        base(unit)
    end)
end

-- 混沌祝福可以重复
function mod.RepeatableChaosTrials(screen, button)
    mod.setOnForButton(button)
    ModUtil.Path.Override("BountyBoardScreenDisplayCategory", function(screen, categoryIndex)
        BountyBoardScreenDisplayCategory_override(screen, categoryIndex)
    end)

    ModUtil.Path.Wrap("MouseOverBounty", function(base, button)
        base(button)
        if GameState.BountiesCompleted[button.Data.Name] then
            SetAlpha({ Id = button.Screen.Components.SelectButton.Id, Fraction = 1.0, Duration = 0.2 })
        end
    end)
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

function mod.PermanentLocationCount(screen, button)
    mod.setOnForButton(button)
    ModUtil.Path.Wrap("ShowHealthUI", function(base)
        base()
        ShowDepthCounter()
    end)

    ModUtil.Path.Wrap("TraitTrayScreenClose", function(base, ...)
        base(...)
        ShowDepthCounter()
    end)
end

function mod.QuitAnywhere(screen, button)
    mod.setOnForButton(button)
    ModUtil.Path.Override("InvalidateCheckpoint", function()
        ValidateCheckpoint({ Value = true })
    end)
end

function ShowDepthCounter()
    local screen = { Name = "RoomCount", Components = {} }
    screen.ComponentData = {
        RoomCount = DeepCopyTable(ScreenData.TraitTrayScreen.ComponentData.RoomCount)
    }
    CreateScreenFromData(screen, screen.ComponentData)
end

function mod.setEphyraZoomOut(screen, button)
    mod.setFlagForButton(button)
    if mod.flags[button.Key] then
        EphyraZoomOut = EphyraZoomOut_override
    else
        EphyraZoomOut = EphyraZoomOutPre
    end
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

function mod.GiveConsumableToPlayer(screen, button)
    DropMinorConsumable( button.Consumable.key )
    -- MapState.RoomRequiredObjects = {}
    -- 	if button.Consumable.UseFunctionName and button.Consumable.UseFunctionName == "OpenTalentScreen" then
    --         DropMinorConsumable( button.Consumable.key )
    -- --     	if not CurrentRun.ConsumableRecord["SpellDrop"] then
    -- --             PlaySound({ Name = "/Leftovers/SFX/OutOfAmmo" })
    -- -- 			return
    -- -- 		end
    -- -- 		mod.CloseConsumableSelector(screen)
    -- 	end
    -- 	UseConsumableItem(button.Consumable, {}, CurrentRun.Hero)
end


EphyraZoomOutPre = nil
function EphyraZoomOut_override( usee )
    warningShowTest('1')
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
            warningShowTest('PylonRooms')
            table.insert(subIcons, "GUI\\Icons\\GhostPack")
        end
        if Contains(room.LegalEncounters, "HealthRestore") then
            warningShowTest('HealthRestore')
            table.insert(subIcons, "ExtraLifeHeart")
        end
        if room.HarvestPointsAllowed > 0 then
            warningShowTest('HarvestPointsAllowed')
            table.insert(subIcons, "GatherIcon")
        end
        if room.ShovelPointSuccess and HasAccessToTool("ToolShovel") then
            warningShowTest('ToolShovel')
            table.insert(subIcons, "ShovelIcon")
        end
        if room.FishingPointSuccess and HasAccessToTool("ToolFishingRod") then
            warningShowTest('ToolFishingRod')
            table.insert(subIcons, "FishingIcon")
        end
        if room.PickaxePointSuccess and HasAccessToTool("ToolPickaxe") then
            warningShowTest('ToolPickaxe')
            table.insert(subIcons, "PickaxeIcon")
        end
        if room.ExorcismPointSuccess and HasAccessToTool("ToolExorcismBook") then
            warningShowTest('ToolExorcismBook')
            table.insert(subIcons, "ExorcismIcon")
        end

        if room.RewardPreviewIcon ~= nil and not HasHeroTraitValue("HiddenRoomReward") then
            warningShowTest('RewardPreviewIcon')
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
