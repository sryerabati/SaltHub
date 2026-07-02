-- SaltHub
-- SaltHub automation hub for "Defend ur base with anime".
-- Single-file, configurable, and built around your game's exposed remotes/modules.

local SaltHub = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Assets = ReplicatedStorage:FindFirstChild("Assets")
local tableUnpack = table.unpack or unpack
local LAUNCH_SCRIPT_URL = "https://raw.githubusercontent.com/sryerabati/SaltHub/main/salthub.lua"

local EXISTING = getgenv and getgenv().SaltHub
if EXISTING and EXISTING.Destroy then
    pcall(EXISTING.Destroy)
end

-- CONFIG_EXPORT_BEGIN
local Config = {
    ui = {
        title = "SaltHub",
        guiName = "DevControlPanel",
        parent = "PlayerGui",
        keybind = Enum.KeyCode.LeftAlt,
        scale = 0.9,
        compact = false,
        notifications = true,
    },
    export = {
        scriptUrl = LAUNCH_SCRIPT_URL,
    },
    storage = {
        autoSave = true,
        folder = "SaltHub",
        fileName = "settings.json",
        saveDelay = 0.35,
    },
    safety = {
        remoteCooldown = 0.35,
        nativeRootScanBatch = 96,
        nativePreviewBatch = 2,
        nativeVisualEffectBatch = 32,
        nativePreviewMode = "Hide",
    },
    delays = {
        wave = 1.5,
        roll = 0.12,
        buyScan = 0.12,
        rollSettle = 1.25,
        buyReservePause = 4.0,
        fastRollRollSettle = 2.75,
        buyRetryPoll = 0.35,
        buyConfirmTimeout = 2.5,
        buyAttemptWindow = 8.0,
        buyPromptRetries = 4,
        buyPromptRetryDelay = 0.18,
        pityHoldPoll = 1.0,
        eventScanInterval = 4.0,
        fastForwardPulse = 10.0,
        buyPause = 0.9,
        moveTimeout = 1.35,
        merge = 0.8,
        mergeIdle = 2.5,
        mergeRejectBackoff = 3,
        trait = 0.75,
        upgrade = 0.7,
        bestLineup = 6.0,
        event = 1.0,
        battlepass = 10.0,
        vipReward = 30.0,
        antiAfkCooldown = 60,
    },
    flags = {
        antiAfk = true,
        autoStartWave = false,
        autoFastForward = false,
        autoSkip = false,
        autoRoll = false,
        autoBuy = false,
        holdPityForEvent = false,
        autoSpin = false,
        autoMerge = false,
        autoTrait = false,
        autoUpgrade = false,
        autoBestLineup = false,
        autoBuhara = false,
        autoShenron = false,
        autoBoorus = false,
        autoBattlepass = false,
        autoVipRewards = false,
        optimizeNativeMenus = false,
    },
    wave = {
        fastForward = "x2",
        startHighest = true,
    },
    roll = {
        targetUnits = {},
        targetMutations = {},
        unitMutationTargets = {},
        snipeEvents = {},
        unitRules = {},
        maxPodiumCharacters = 6,
        rollStationBehindDistance = 5.6,
        stationReturnDelay = 12.0,
        stationReturnDistance = 12.0,
        smoothMovement = false,
        promptDistance = 3.15,
        promptApproachJitter = 0.85,
        promptMoveTimeout = 2.2,
        promptDelayMin = 0.08,
        promptDelayMax = 0.28,
        promptHoldExtraMin = 0.08,
        promptHoldExtraMax = 0.2,
        promptTeleportFallback = true,
    },
    merge = {
        targetUnitId = "",
        targetUnitName = "",
        maxLevel = 7,
        keepMutations = true,
        blacklist = {},
    },
    bestLineup = {
        dpsWeight = 1.25,
        dpsPerCellWeight = 0.85,
        damageWeight = 0.12,
        rangeWeight = 0.08,
        cooldownWeight = 3,
        rarityWeight = 3,
        levelWeight = 4,
        rngWeight = 0.01,
        footprintPenalty = 0.035,
        fillWeight = 12,
        beamWidth = 192,
        candidateLimit = 128,
        dpsCandidateLimit = 96,
        damageCandidateLimit = 48,
        densityCandidateLimit = 64,
        frontCandidateLimit = 96,
        tierCandidateLimit = 128,
        fillCandidateLimit = 512,
        replacementPasses = 10,
        minReplacementGain = 0.01,
        frontRangeWeight = 0.72,
        frontDpsWeight = 0.28,
        placementQualityWeight = 250,
        compactnessWeight = 350,
        adjacencyWeight = 35,
        gapPenaltyWeight = 18,
        rarityTierWeight = 5000,
        mutationTierWeight = 800,
        traitTierWeight = 600,
        tierSupportWeight = 0.05,
        frontValueWeight = 1.25,
        rangeOrderWeight = 120,
        rangeOrderTolerance = 1,
        rangeOrderRebuild = true,
        shortRangeBackLimit = 50,
        shortRangeBackMinFrontScore = 0.5,
        backfillRemainingSpace = true,
        searchVariants = 5,
        maxPlacements = 60,
        skipEquipped = false,
    },
    webhook = {
        enabled = false,
        url = "",
        mentionUser = false,
        minInterval = 2.5,
        dedupeWindow = 90.0,
        rareTraits = { "Omnipotent", "Corrupted", "Doombringer", "Divine Eye", "Divine" },
        rareMutations = { "God", "Divine" },
        superShenronMutationNames = { "SuperShenron", "Super Shenron" },
        superShenronMutationMinRarity = "Secret",
        rollNotifyUnits = {},
        rollNotifyMutations = {},
        rareUnits = { "Hashirama", "Hashirama (Sage)", "Hashiromo" },
        rareRarities = { "Secret" },
        rareRewards = { "Doombringer", "Omnipotent", "Divine", "Divine Eye", "God", "Hashirama", "Hashiromo" },
    },
    trait = {
        selectedUnitId = "",
        selectedUnitName = "",
        targetTraits = {
            "Omnipotent",
            "Corrupted",
            "Celestial",
            "Void Emperor",
            "Soul Reaper",
            "Divine Eye",
            "King's Fortune",
        },
        stopWhenMatched = true,
    },
    upgrade = {
        upgradePriority = { "Cash", "Luck", "Grid" },
        selected = {
            Luck = true,
            Cash = true,
            Grid = true,
        },
    },
    battlepass = {
        claimFree = true,
        claimPremium = true,
        claimQuests = true,
        claimMode = "levelTrack",
        questClaimMode = "id",
        maxLevel = 30,
    },
    buhara = {
        foodNames = { "Steak", "Tomato", "Bread", "Cheese", "Lettuce", "Trait Shard" },
        eventNames = { "Buhara", "Burah", "BuharaEvent" },
        feedTargetNames = { "Buhara", "Burah", "BURAH", "BuharaEvent" },
        foodCollectDistance = 2.2,
        feedDistance = 1.1,
        teleportOffset = 1.35,
        collectRetries = 3,
        feedRetries = 3,
        scanInterval = 0.65,
        dataPollInterval = 1.0,
        holdPoll = 4.0,
        holdLogInterval = 8.0,
        maxScanItems = 450,
    },
    shenron = {
        wishPriority = { "UniqueTrait", "ManyFragments", "MeteorRain", "LuckBoost", "SkipCraftingMachine", "SkipCloningMachine" },
        blockedWishNames = { "MillionDollars", "CashBoost" },
        doombringerSkipTraits = { "Omnipotent", "Corrupted", "Doombringer" },
        useLuckPotions = true,
        luckPotionName = "Luck Potion",
        luckPotionBoostType = "Luck",
        luckPotionEventNames = { "SuperShenron" },
        wishRequirements = {
            MillionDollars = 0,
            MeteorRain = 0,
            SkipCloningMachine = 1,
            ManyFragments = 2,
            SkipCraftingMachine = 3,
            LuckBoost = 4,
            CashBoost = 4,
            UniqueTrait = 5,
        },
        ballCollectDistance = 1.1,
        turnInDistance = 1.2,
        collectRetries = 3,
        turnInRetries = 3,
        scanInterval = 0.65,
        holdPoll = 4.0,
        holdLogInterval = 8.0,
        maxScanItems = 1800,
        claimCooldown = 3.0,
        meteorCollectDistance = 4.5,
        meteorCollectWindow = 45.0,
        meteorCollectInterval = 0.35,
    },
    boorus = {
        promptDistance = 3.0,
        startCooldown = 6.0,
        startConfirmTimeout = 4.0,
        spinBusyTime = 6.8,
        spinCompleteDelay = 0.65,
        fightSupportWindow = 600,
        fightSupportPoll = 2.0,
    },
}

local function decodeKeyCode(value, fallback)
    if typeof(value) == "EnumItem" then
        return value
    end
    local text = tostring(value or "")
    local keyName = text:match("KeyCode%.(.+)$") or text:match("Enum%.KeyCode%.(.+)$") or text
    return Enum.KeyCode[keyName] or fallback
end

local function isConfigArray(value)
    if type(value) ~= "table" then
        return false
    end

    local count = 0
    local maxIndex = 0
    for key in pairs(value) do
        if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
            return false
        end
        count += 1
        maxIndex = math.max(maxIndex, key)
    end
    return count > 0 and count == maxIndex
end

local function cloneConfigValue(value)
    if type(value) ~= "table" then
        return value
    end

    local out = {}
    for key, item in pairs(value) do
        out[key] = cloneConfigValue(item)
    end
    return out
end

local function mergeConfig(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return
    end

    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" and (isConfigArray(value) or isConfigArray(target[key])) then
            target[key] = cloneConfigValue(value)
        elseif type(value) == "table" and type(target[key]) == "table" then
            mergeConfig(target[key], value)
        elseif key == "keybind" then
            target[key] = decodeKeyCode(value, target[key])
        else
            target[key] = value
        end
    end
end

local function applyBestLineupOptimizerDefaults()
    local best = Config.bestLineup or {}
    Config.bestLineup = best
    best.dpsWeight = math.max(tonumber(best.dpsWeight) or 0, 1.25)
    best.dpsPerCellWeight = math.max(tonumber(best.dpsPerCellWeight) or 0, 0.85)
    best.damageWeight = tonumber(best.damageWeight) or 0.12
    best.damageCandidateLimit = math.max(tonumber(best.damageCandidateLimit) or 0, 48)
    best.beamWidth = math.max(tonumber(best.beamWidth) or 0, 192)
    best.candidateLimit = math.max(tonumber(best.candidateLimit) or 0, 128)
    best.dpsCandidateLimit = math.max(tonumber(best.dpsCandidateLimit) or 0, 96)
    best.densityCandidateLimit = math.max(tonumber(best.densityCandidateLimit) or 0, 64)
    best.frontCandidateLimit = math.max(tonumber(best.frontCandidateLimit) or 0, 96)
    best.tierCandidateLimit = math.max(tonumber(best.tierCandidateLimit) or 0, 128)
    best.fillCandidateLimit = math.max(tonumber(best.fillCandidateLimit) or 0, 512)
    best.replacementPasses = math.max(tonumber(best.replacementPasses) or 0, 10)
    best.frontRangeWeight = math.max(tonumber(best.frontRangeWeight) or 0, 0.72)
    best.frontDpsWeight = math.min(tonumber(best.frontDpsWeight) or 0.28, 0.28)
    best.placementQualityWeight = math.max(tonumber(best.placementQualityWeight) or 0, 250)
    best.compactnessWeight = math.max(tonumber(best.compactnessWeight) or 0, 350)
    best.adjacencyWeight = math.max(tonumber(best.adjacencyWeight) or 0, 35)
    best.gapPenaltyWeight = math.max(tonumber(best.gapPenaltyWeight) or 0, 18)
    best.rarityTierWeight = math.max(tonumber(best.rarityTierWeight) or 0, 5000)
    best.mutationTierWeight = math.max(tonumber(best.mutationTierWeight) or 0, 800)
    best.traitTierWeight = math.max(tonumber(best.traitTierWeight) or 0, 600)
    best.tierSupportWeight = math.min(math.max(tonumber(best.tierSupportWeight) or 0.05, 0), 0.2)
    best.frontValueWeight = math.max(tonumber(best.frontValueWeight) or 0, 1.25)
    best.rangeOrderWeight = math.max(tonumber(best.rangeOrderWeight) or 0, 120)
    best.rangeOrderTolerance = math.max(tonumber(best.rangeOrderTolerance) or 0, 1)
    if best.rangeOrderRebuild == nil then
        best.rangeOrderRebuild = true
    end
    best.shortRangeBackLimit = math.max(tonumber(best.shortRangeBackLimit) or 0, 50)
    best.shortRangeBackMinFrontScore = math.max(tonumber(best.shortRangeBackMinFrontScore) or 0, 0.5)
    if best.backfillRemainingSpace == nil then
        best.backfillRemainingSpace = true
    end
    best.searchVariants = math.max(tonumber(best.searchVariants) or 0, 5)
end

local function applyNativeMenuOptimizerSafetyDefaults()
    Config.flags.optimizeNativeMenus = false
    Config.safety.nativeRootScanBatch = math.min(math.max(tonumber(Config.safety.nativeRootScanBatch) or 96, 1), 96)
    Config.safety.nativePreviewBatch = math.min(math.max(tonumber(Config.safety.nativePreviewBatch) or 2, 1), 2)
    Config.safety.nativeVisualEffectBatch = math.min(math.max(tonumber(Config.safety.nativeVisualEffectBatch) or 32, 1), 32)
    local mode = tostring(Config.safety.nativePreviewMode or ""):lower():gsub("%s+", "")
    if mode == "" or mode == "static" then
        Config.safety.nativePreviewMode = "Hide"
    end
end

local function resetSessionOnlySettings()
    Config.flags.optimizeNativeMenus = false
end

local function applyAutoRollTimingSafetyDefaults()
    Config.delays.rollSettle = math.max(tonumber(Config.delays.rollSettle) or 0, 1.25)
    Config.delays.buyReservePause = math.max(tonumber(Config.delays.buyReservePause) or 0, 4.0)
    Config.delays.buyAttemptWindow = math.max(tonumber(Config.delays.buyAttemptWindow) or 0, 8.0)
    Config.delays.buyRetryPoll = math.max(tonumber(Config.delays.buyRetryPoll) or 0, 0.35)
    Config.delays.fastRollRollSettle = math.max(tonumber(Config.delays.fastRollRollSettle or Config.delays.fastRollBuyHold) or 0, 2.75)
    Config.roll.smoothMovement = false
    Config.roll.promptTeleportFallback = true
    Config.roll.promptDistance = math.max(tonumber(Config.roll.promptDistance) or 3.15, 0.75)
    Config.roll.promptApproachJitter = math.max(tonumber(Config.roll.promptApproachJitter) or 0.85, 0)
    Config.roll.promptMoveTimeout = math.max(tonumber(Config.roll.promptMoveTimeout) or 2.2, Config.delays.moveTimeout or 1.35)
    Config.roll.promptDelayMin = math.max(tonumber(Config.roll.promptDelayMin) or 0, 0)
    Config.roll.promptDelayMax = math.max(tonumber(Config.roll.promptDelayMax) or 0, Config.roll.promptDelayMin)
    Config.roll.promptHoldExtraMin = math.max(tonumber(Config.roll.promptHoldExtraMin) or 0, 0)
    Config.roll.promptHoldExtraMax = math.max(tonumber(Config.roll.promptHoldExtraMax) or 0, Config.roll.promptHoldExtraMin)
end

local function applyEventAutomationSafetyDefaults()
    Config.buhara.maxScanItems = math.max(tonumber(Config.buhara.maxScanItems) or 0, 450)
    Config.shenron.maxScanItems = math.max(tonumber(Config.shenron.maxScanItems) or 0, 1800)
    Config.shenron.meteorCollectDistance = math.max(tonumber(Config.shenron.meteorCollectDistance) or 0, 4.5)
    Config.shenron.meteorCollectWindow = math.max(tonumber(Config.shenron.meteorCollectWindow) or 0, 45.0)
    Config.shenron.meteorCollectInterval = math.max(tonumber(Config.shenron.meteorCollectInterval) or 0, 0.35)
end

local workspaceConfigLoaded = false
local workspaceConfigStatus = nil

local function getExecutorConfigPath()
    local storage = Config.storage or {}
    local folder = tostring(storage.folder or "SaltHub")
    local fileName = tostring(storage.fileName or "settings.json")
    if folder == "" then
        return fileName
    end
    return folder .. "/" .. fileName
end

local function getExecutorConfigCandidatePaths()
    local storage = Config.storage or {}
    local folder = tostring(storage.folder or "SaltHub")
    local fileName = tostring(storage.fileName or "settings.json")
    local paths = {}
    local seen = {}
    local function add(path)
        if type(path) == "string" and path ~= "" and not seen[path] then
            seen[path] = true
            table.insert(paths, path)
        end
    end

    add(getExecutorConfigPath())
    if folder ~= "" then
        local flatFolder = folder:gsub("[/\\]+", "_")
        add(flatFolder .. "_" .. fileName)
    end
    add("salthub_" .. fileName)
    return paths
end

local function getExecutorFolderFromPath(path)
    return tostring(path or ""):match("^(.*)/[^/]+$")
end

local function ensureExecutorConfigFolder(folderOverride)
    local storage = Config.storage or {}
    local folder = folderOverride or tostring(storage.folder or "SaltHub")
    if folder == "" then
        return true
    end
    if type(makefolder) ~= "function" then
        return true
    end
    if type(isfolder) == "function" then
        local ok, exists = pcall(isfolder, folder)
        if ok and exists then
            return true
        end
    end
    local ok, err = pcall(makefolder, folder)
    if ok then
        return true
    end
    if type(isfolder) == "function" then
        local existsOk, exists = pcall(isfolder, folder)
        if existsOk and exists then
            return true
        end
    end
    return false, err
end

local function readExecutorConfigFile()
    if type(readfile) ~= "function" then
        return nil, "readfile unavailable"
    end

    local lastErr = nil
    for _, path in ipairs(getExecutorConfigCandidatePaths()) do
        if type(isfile) == "function" then
            local ok, exists = pcall(isfile, path)
            if ok and not exists then
                continue
            end
        end

        local ok, contents = pcall(readfile, path)
        if ok and type(contents) == "string" and contents ~= "" then
            return contents, nil, path
        end
        if not ok then
            lastErr = contents
        end
    end
    return nil, lastErr
end

local function applySavedConfigFromWorkspace()
    local contents, readErr, path = readExecutorConfigFile()
    if not contents then
        workspaceConfigStatus = readErr
        return false
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if not ok or type(decoded) ~= "table" then
        workspaceConfigStatus = decoded or "invalid saved settings"
        warn("[SaltHub] Failed to decode saved settings.")
        return false
    end

    mergeConfig(Config, decoded.Config or decoded)
    workspaceConfigLoaded = true
    workspaceConfigStatus = path or getExecutorConfigPath()
    return true
end

local function applyPresetFromGlobal()
    local env = getgenv and getgenv()
    local preset = env and env.SaltHubPreset
    if preset == nil or preset == "" then
        return false
    end

    local decoded = preset
    if type(preset) == "string" then
        local ok, value = pcall(function()
            return HttpService:JSONDecode(preset)
        end)
        if not ok then
            warn("[SaltHub] Failed to decode preset.")
            return true
        end
        decoded = value
    end

    if type(decoded) == "table" then
        mergeConfig(Config, decoded.Config or decoded)
    end
    return true
end

local presetApplied = applyPresetFromGlobal()
local savedConfigApplied = applySavedConfigFromWorkspace()
if presetApplied and savedConfigApplied then
    workspaceConfigStatus = tostring(workspaceConfigStatus) .. " (overrode launch preset)"
end
applyBestLineupOptimizerDefaults()
resetSessionOnlySettings()
applyNativeMenuOptimizerSafetyDefaults()
applyAutoRollTimingSafetyDefaults()
applyEventAutomationSafetyDefaults()

local Maid = { items = {} }
function Maid:add(item)
    table.insert(self.items, item)
    return item
end
function Maid:clean()
    for _, item in ipairs(self.items) do
        pcall(function()
            if typeof(item) == "RBXScriptConnection" then
                item:Disconnect()
            elseif typeof(item) == "Instance" then
                item:Destroy()
            elseif type(item) == "function" then
                item()
            end
        end)
    end
    table.clear(self.items)
end

local Log = { lines = {} }
function Log.push(message)
    local text = os.date("%H:%M:%S") .. "  " .. tostring(message)
    table.insert(Log.lines, 1, text)
    while #Log.lines > 80 do
        table.remove(Log.lines)
    end
    if Config.ui.notifications then
        print("[SaltHub]", message)
    end
end

local function copyArray(list)
    local out = {}
    for _, value in ipairs(list or {}) do
        table.insert(out, value)
    end
    return out
end

local function uniqueSorted(list)
    local seen = {}
    local out = {}
    for _, value in ipairs(list or {}) do
        if value and value ~= "" and not seen[value] then
            seen[value] = true
            table.insert(out, value)
        end
    end
    table.sort(out, function(a, b)
        return tostring(a):lower() < tostring(b):lower()
    end)
    return out
end

local function normalizeUnitMutationTargets(targets)
    local out = {}
    if type(targets) ~= "table" then
        return out
    end

    for unit, mutations in pairs(targets) do
        local unitName = tostring(unit or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if unitName ~= "" and type(mutations) == "table" then
            local mutationList = {}
            for _, mutation in ipairs(mutations) do
                local mutationName = tostring(mutation or ""):gsub("^%s+", ""):gsub("%s+$", "")
                if mutationName ~= "" then
                    table.insert(mutationList, mutationName)
                end
            end

            local clean = uniqueSorted(mutationList)
            if #clean > 0 then
                out[unitName] = clean
            end
        end
    end

    return out
end

local function splitCsv(text)
    local out = {}
    for item in tostring(text or ""):gmatch("[^,]+") do
        local clean = item:gsub("^%s+", ""):gsub("%s+$", "")
        if clean ~= "" then
            table.insert(out, clean)
        end
    end
    return uniqueSorted(out)
end

local function hasValue(list, value)
    for _, item in ipairs(list or {}) do
        if item == value then
            return true
        end
    end
    return false
end

local function normalizeText(value)
    return tostring(value or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalizedLookupKey(value)
    return normalizeText(value):gsub("%s+", "")
end

local function normalizeUnitMutation(value, fallback)
    local text = tostring(value or "")
    if text == "" then
        text = tostring(fallback or "None")
    end
    local clean = normalizeText(text)
    if clean == "" or clean == "none" or clean == "normal" then
        return "None"
    end
    return text
end

local function listHasItems(list)
    return type(list) == "table" and #list > 0
end

local function textMatchesAny(value, list)
    local clean = normalizeText(value)
    if clean == "" then
        return false
    end

    for _, wanted in ipairs(list or {}) do
        local target = normalizeText(wanted)
        if target ~= "" and (clean == target or clean:find(target, 1, true)) then
            return true
        end
    end
    return false
end

local function textEqualsAny(value, list)
    local clean = normalizeText(value)
    if clean == "" then
        return false
    end

    for _, wanted in ipairs(list or {}) do
        if clean == normalizeText(wanted) then
            return true
        end
    end
    return false
end

local RARITY_ORDER = {
    God = 1,
    Godly = 1,
    Limited = 2,
    Secret = 3,
    Divine = 4,
    Mythic = 5,
    Legendary = 6,
    Epic = 7,
    Rare = 8,
    Common = 9,
}

local RARITY_COLORS = {
    God = Color3.fromRGB(255, 214, 89),
    Godly = Color3.fromRGB(255, 214, 89),
    Limited = Color3.fromRGB(255, 92, 176),
    Secret = Color3.fromRGB(189, 105, 255),
    Divine = Color3.fromRGB(97, 231, 255),
    Mythic = Color3.fromRGB(255, 77, 77),
    Legendary = Color3.fromRGB(255, 170, 66),
    Epic = Color3.fromRGB(170, 103, 255),
    Rare = Color3.fromRGB(70, 169, 255),
    Common = Color3.fromRGB(158, 169, 181),
}

local TRAIT_RARITY_FALLBACK = {
    Omnipotent = "God",
    Corrupted = "God",
    Celestial = "Mythic",
    ["Void Emperor"] = "Mythic",
    ["Soul Reaper"] = "Mythic",
    ["Divine Eye"] = "Mythic",
    ["King's Fortune"] = "Mythic",
    ["Star Bloom"] = "Legendary",
    ["Beast Fang"] = "Legendary",
    ["War Giant"] = "Legendary",
    ["Golden Aura"] = "Legendary",
    ["Sixth Eye"] = "Legendary",
    ["Battle Spirit III"] = "Epic",
    ["Quick Step III"] = "Epic",
    ["Far Sight III"] = "Epic",
    ["Battle Spirit II"] = "Rare",
    ["Quick Step II"] = "Rare",
    ["Far Sight II"] = "Rare",
    ["Battle Spirit I"] = "Common",
    ["Quick Step I"] = "Common",
    ["Far Sight I"] = "Common",
}

local function rarityRank(rarity)
    local text = tostring(rarity or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if RARITY_ORDER[text] then
        return RARITY_ORDER[text]
    end
    local clean = normalizeText(text)
    for name, rank in pairs(RARITY_ORDER) do
        if normalizeText(name) == clean then
            return rank
        end
    end
    return 999
end

local function rarityColor(rarity)
    return RARITY_COLORS[tostring(rarity or "")] or Color3.fromRGB(35, 40, 47)
end

local Remote = {
    lastSent = {},
    paths = {
        StartWave = { "ReplicatedStorage", "Remotes", "Start", "StartWave" },
        EndWave = { "ReplicatedStorage", "Remotes", "Start", "EndWave" },
        FastForward = { "ReplicatedStorage", "Remotes", "Start", "FastForward" },
        AutoSkip = { "ReplicatedStorage", "Remotes", "Start", "AutoSkip" },
        WaveUiState = { "ReplicatedStorage", "Remotes", "Start", "WaveUiState" },
        Checkpoint = { "ReplicatedStorage", "Remotes", "Checkpoint" },
        Upgrade = { "ReplicatedStorage", "Remotes", "Upgrade" },
        TraitRequest = { "ReplicatedStorage", "Remotes", "Trait", "Request" },
        CloneRequest = { "ReplicatedStorage", "Remotes", "Clone", "Request" },
        CraftRequest = { "ReplicatedStorage", "Remotes", "Craft", "Request" },
        FragmentFusionRequest = { "ReplicatedStorage", "Remotes", "FragmentFusion", "Request" },
        PlaceCharacter = { "ReplicatedStorage", "Remotes", "Characters", "PlaceCharacter" },
        SpinWheel = { "ReplicatedStorage", "Remotes", "SpinWheel", "Spin" },
        BeerusSpin = { "ReplicatedStorage", "Remotes", "SpinWheel", "BeerusSpin" },
        EventUI = { "ReplicatedStorage", "Remotes", "Events", "EventUI" },
        FragmentRainCollect = { "ReplicatedStorage", "Remotes", "FragmentRain", "Collect" },
        BuharaData = { "ReplicatedStorage", "Remotes", "BuharaEvent", "BuharaEventGetData" },
        BuharaMessage = { "ReplicatedStorage", "Remotes", "BuharaEvent", "CreateBuharaMessage" },
        SuperShenronClaimWish = { "ReplicatedStorage", "Remotes", "SuperShenronEvent", "ClaimWish" },
        UsePotion = { "ReplicatedStorage", "Remotes", "Items", "UsePotion" },
        CharacterLock = { "ReplicatedStorage", "Remotes", "Characters", "UpdateCharacterLock" },
        PickupCharacter = { "ReplicatedStorage", "Remotes", "Characters", "PickupCharacter" },
        MoveCharacter = { "ReplicatedStorage", "Remotes", "Characters", "MoveCharacter" },
        SellCharacters = { "ReplicatedStorage", "Remotes", "NPCEvents", "SellCharacters" },
        FreeRewards = { "ReplicatedStorage", "Remotes", "FreeRewards", "FreeRewards" },
        ClaimVIP = { "ReplicatedStorage", "Remotes", "ClaimVIP" },
        BattlepassClaim = { "ReplicatedStorage", "Battlepass", "Claim" },
        BattlepassQuestClaim = { "ReplicatedStorage", "BattlepassQuest", "ClaimQuest" },
        BattlepassQuestData = { "ReplicatedStorage", "BattlepassQuest", "GetQuestData" },
    },
}

function Remote.resolvePath(path)
    local current
    for index, name in ipairs(path) do
        if index == 1 then
            if name == "ReplicatedStorage" then
                current = ReplicatedStorage
            elseif name == "Players" then
                current = Players
            else
                current = game:FindFirstChild(name)
            end
        else
            current = current and current:FindFirstChild(name)
        end
        if not current then
            return nil
        end
    end
    return current
end

function Remote.get(key)
    local path = Remote.paths[key]
    if not path then
        return nil
    end
    return Remote.resolvePath(path)
end

function Remote.canSend(key)
    local cooldown = tonumber(Config.safety.remoteCooldown) or 0
    local now = os.clock()
    local last = Remote.lastSent[key] or 0
    if cooldown > 0 and now - last < cooldown then
        Log.push("Cooldown skipped: " .. tostring(key))
        return false
    end
    Remote.lastSent[key] = now
    return true
end

function Remote.fire(key, ...)
    local args = { ... }
    if not Remote.canSend(key) then
        return false
    end
    local remote = Remote.get(key)
    if not remote or not remote:IsA("RemoteEvent") then
        Log.push("Missing RemoteEvent: " .. tostring(key))
        return false
    end
    local ok, err = pcall(function()
        remote:FireServer(tableUnpack(args))
    end)
    if not ok then
        Log.push("Fire failed " .. tostring(key) .. ": " .. tostring(err))
    end
    return ok
end

function Remote.invoke(key, ...)
    local args = { ... }
    if not Remote.canSend(key) then
        return nil
    end
    local remote = Remote.get(key)
    if not remote or not remote:IsA("RemoteFunction") then
        Log.push("Missing RemoteFunction: " .. tostring(key))
        return nil
    end
    local ok, result = pcall(function()
        return remote:InvokeServer(tableUnpack(args))
    end)
    if not ok then
        Log.push("Invoke failed " .. tostring(key) .. ": " .. tostring(result))
        return nil
    end
    return result
end

local Feature
local State = {
    characters = {},
    characterNames = {},
    characterOptions = {},
    characterRarity = {},
    characterInfoByName = {},
    traits = {},
    traitOptions = {},
    traitRarity = {},
    traitInfoByName = {},
    mutations = {},
    mutationInfoByName = {},
    snipeEvents = {},
    levelInfo = nil,
    characterLevelHelper = nil,
    characterStatsUiHelper = nil,
    placementHelper = nil,
    placementConfig = nil,
    shapeFootprints = {},
    battlepass = {
        maxLevel = Config.battlepass.maxLevel,
        questIds = {},
    },
    upgrades = { Luck = "?", Cash = "?", Grid = "?" },
    upgradeStatus = "Waiting for data.",
    currentRoll = "-",
    pityText = "-",
    rolledCharacters = {},
    pendingMerge = nil,
    autoMergeIgnoredCharacters = {},
    autoMergeIdleUntil = 0,
    mergeRejectedUntil = 0,
    lastNativeMenuPauseLogAt = 0,
    spinStatus = "Waiting for data.",
    spinBusyUntil = 0,
    spinWheelCompleteAttached = false,
    webhookStatus = "Webhook disabled.",
    webhookQueue = {},
    webhookSeenKeys = {},
    lastWebhookSentAt = 0,
    webhookBackoffUntil = 0,
    webhookLastFailureRetry = false,
    boorusStatus = "Waiting for data.",
    boorusSpinBusyUntil = 0,
    boorusSpinCompleteAttached = false,
    lastBoorusChallengeStartAt = 0,
    boorusFightUntil = 0,
    shenronStatus = "Waiting for data.",
    shenronDragonBalls = {},
    shenronDragonBallScanAt = 0,
    shenronTurnInTarget = nil,
    shenronTurnInTargetScanAt = 0,
    shenronCollectedSinceTurnIn = 0,
    shenronMeteorDrops = {},
    shenronMeteorScanAt = 0,
    shenronMeteorCollectUntil = 0,
    lastShenronWishName = "",
    lastShenronDoombringerTarget = nil,
    shenronHoldUntil = 0,
    lastShenronHoldLogAt = 0,
    lastShenronClaimAt = 0,
    lastShenronLuckPotionAt = 0,
    lastShenronLuckPotionLogAt = 0,
    lastShenronWaveStopAt = 0,
    battlepassStatus = "Waiting for data.",
    vipRewardStatus = "Waiting for data.",
    waveStatus = "-",
    lastWaveStartAt = 0,
    lastFastForwardAt = 0,
    lastFastForwardValue = "",
    lastRollAt = 0,
    rollBusyUntil = 0,
    rollAwaySince = 0,
    pityHoldUntil = 0,
    lastBuyAt = 0,
    fastRollOwned = false,
    fastRollOwnedCachedAt = 0,
    buyingCharacter = false,
    pendingBuy = nil,
    lastAntiAfkAt = 0,
    lastPendingBuyLogAt = 0,
    activeEventText = "",
    lastEventUiAt = 0,
    eventUiAttached = false,
    cachedSelectedEventActive = false,
    lastSelectedEventScanAt = 0,
    lastPityHoldLogAt = 0,
    lastTraitLogAt = 0,
    dataClient = nil,
    buhara = nil,
    buharaDataScanAt = 0,
    buharaFoodDrops = {},
    buharaFoodScanAt = 0,
    buharaTarget = nil,
    buharaTargetScanAt = 0,
    buharaHoldUntil = 0,
    lastBuharaHoldLogAt = 0,
    lastBestLineupSummary = "",
    bestLineupRunId = 0,
    bestLineupWaveBlockLogAt = 0,
    lockedUnitIds = {},
    lockedUnitIdsReady = false,
    configSaveQueued = false,
    configSaveReason = nil,
    lastConfigSaveAt = 0,
}

local DataSource = {}

function DataSource.safeRequire(moduleScript, timeoutSeconds)
    if not moduleScript or not moduleScript:IsA("ModuleScript") then
        return nil
    end

    local done = false
    local ok = false
    local result = nil
    task.spawn(function()
        ok, result = pcall(require, moduleScript)
        done = true
    end)

    local started = os.clock()
    while not done and os.clock() - started < (timeoutSeconds or 1) do
        task.wait()
    end

    if done and ok and type(result) == "table" then
        return result
    end
    return nil
end

function DataSource.getPath(root, path)
    local current = root
    for _, key in ipairs(path) do
        if type(current) ~= "table" then
            return nil
        end
        current = current[key]
    end
    return current
end

function DataSource.extractKeys(data, candidatePaths)
    local values = {}
    local function add(value)
        if type(value) == "string" and value ~= "" then
            table.insert(values, value)
        end
    end

    local function collect(tableValue)
        if type(tableValue) ~= "table" then
            return
        end
        for key, value in pairs(tableValue) do
            if type(key) == "string" then
                add(key)
            end
            if type(value) == "table" then
                add(value.Name or value.DisplayName or value.ID or value.Id)
            elseif type(value) == "string" then
                add(value)
            end
        end
    end

    for _, path in ipairs(candidatePaths or {}) do
        collect(DataSource.getPath(data, path))
    end
    if #values == 0 then
        collect(data)
    end

    return uniqueSorted(values)
end

function DataSource.combineLists(...)
    local combined = {}
    for _, list in ipairs({ ... }) do
        for _, value in ipairs(list or {}) do
            table.insert(combined, value)
        end
    end
    return uniqueSorted(combined)
end

function DataSource.namesFromFolder(folder, exclude)
    local values = {}
    local skipped = {}
    for _, name in ipairs(exclude or {}) do
        skipped[name] = true
    end
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if not skipped[child.Name] and (child:IsA("ModuleScript") or child:IsA("Folder") or child:IsA("Model")) then
                table.insert(values, child.Name)
            end
        end
    end
    return uniqueSorted(values)
end

function DataSource.isRarityName(name)
    return RARITY_ORDER[tostring(name or "")] ~= nil
end

function DataSource.buildCharacterOptions(charactersInfo, fallbackNames)
    local options = {}
    local seen = {}
    local characters = charactersInfo and charactersInfo.Characters

    if type(characters) == "table" then
        for rarity, units in pairs(characters) do
            if type(units) == "table" then
                for name, data in pairs(units) do
                    if type(name) == "string" and name ~= "" and not seen[name] then
                        seen[name] = true
                        table.insert(options, {
                            name = name,
                            displayName = type(data) == "table" and data.DisplayName or name,
                            rarity = tostring(rarity),
                        })
                    end
                end
            end
        end
    end

    for _, name in ipairs(fallbackNames or {}) do
        if type(name) == "string" and name ~= "" and not seen[name] and not DataSource.isRarityName(name) then
            seen[name] = true
            table.insert(options, {
                name = name,
                displayName = name,
                rarity = "Common",
            })
        end
    end

    table.sort(options, function(a, b)
        local rankA = rarityRank(a.rarity)
        local rankB = rarityRank(b.rarity)
        if rankA ~= rankB then
            return rankA < rankB
        end
        return tostring(a.name):lower() < tostring(b.name):lower()
    end)
    return options
end

function DataSource.buildCharacterInfoMap(charactersInfo)
    local map = {}
    local characters = charactersInfo and charactersInfo.Characters
    if type(characters) ~= "table" then
        return map
    end

    for rarity, units in pairs(characters) do
        if type(units) == "table" then
            for name, data in pairs(units) do
                if type(name) == "string" and name ~= "" and type(data) == "table" then
                    local info = {
                        name = name,
                        displayName = tostring(data.DisplayName or name),
                        rarity = tostring(rarity),
                        data = data,
                    }
                    map[name] = info
                    map[normalizedLookupKey(name)] = info
                    map[normalizedLookupKey(data.DisplayName or name)] = info
                end
            end
        end
    end
    return map
end

function DataSource.buildNamedInfoMap(info, rootKey)
    local map = {}
    local source = type(info) == "table" and info[rootKey] or nil
    if type(source) ~= "table" then
        return map
    end
    for name, data in pairs(source) do
        if type(name) == "string" and name ~= "" and type(data) == "table" then
            map[name] = data
            map[normalizedLookupKey(name)] = data
            map[normalizedLookupKey(data.DisplayName or data.Name or name)] = data
        end
    end
    return map
end

function DataSource.buildTraitOptions(traitInfo, fallbackNames)
    local options = {}
    local seen = {}
    local traits = traitInfo and traitInfo.Traits

    if type(traits) == "table" then
        for name, data in pairs(traits) do
            if type(name) == "string" and name ~= "" and not seen[name] then
                seen[name] = true
                table.insert(options, {
                    name = name,
                    displayName = name,
                    rarity = type(data) == "table" and tostring(data.Rarity or TRAIT_RARITY_FALLBACK[name] or "Common") or tostring(TRAIT_RARITY_FALLBACK[name] or "Common"),
                    order = type(data) == "table" and tonumber(data.Order) or nil,
                    chance = type(data) == "table" and tonumber(data.Chance) or nil,
                })
            end
        end
    end

    for index, name in ipairs(fallbackNames or {}) do
        if type(name) == "string" and name ~= "" and not seen[name] then
            seen[name] = true
            table.insert(options, {
                name = name,
                displayName = name,
                rarity = TRAIT_RARITY_FALLBACK[name] or "Common",
                order = index,
            })
        end
    end

    table.sort(options, function(a, b)
        local rankA = rarityRank(a.rarity)
        local rankB = rarityRank(b.rarity)
        if rankA ~= rankB then
            return rankA < rankB
        end
        local orderA = tonumber(a.order) or 999
        local orderB = tonumber(b.order) or 999
        if orderA ~= orderB then
            return orderA > orderB
        end
        return tostring(a.name):lower() < tostring(b.name):lower()
    end)
    return options
end

function DataSource.namesFromOptions(options)
    local names = {}
    for _, option in ipairs(options or {}) do
        table.insert(names, option.name)
    end
    return names
end

function DataSource.rarityMapFromOptions(options)
    local map = {}
    for _, option in ipairs(options or {}) do
        map[option.name] = option.rarity
        map[normalizedLookupKey(option.name)] = option.rarity
    end
    return map
end

function DataSource.extractEventNames(typeModuleName, fallback)
    local values = {}
    local types = ReplicatedStorage:FindFirstChild("CmdrClient")
        and ReplicatedStorage.CmdrClient:FindFirstChild("Types")
    local moduleScript = types and types:FindFirstChild(typeModuleName)
    local loaded = nil

    if moduleScript and moduleScript:IsA("ModuleScript") then
        local ok, result = pcall(require, moduleScript)
        if ok then
            loaded = result
        end
    end

    if type(loaded) == "function" and debug and debug.getupvalue then
        local index = 1
        while true do
            local ok, upvalueName, value = pcall(debug.getupvalue, loaded, index)
            if not ok or not upvalueName then
                break
            end
            if type(value) == "table" then
                for _, item in ipairs(value) do
                    if type(item) == "string" and item ~= "" then
                        table.insert(values, item)
                    end
                end
            end
            index += 1
        end
    end

    if #values == 0 then
        for _, item in ipairs(fallback or {}) do
            table.insert(values, item)
        end
    end

    return uniqueSorted(values)
end

DataSource.blockedSnipeEventNames = {
    [normalizeText("getem")] = true,
    [normalizeText("Get 'em")] = true,
    [normalizeText("Buhara")] = true,
    [normalizeText("Drop")] = true,
    [normalizeText("Luck")] = true,
    [normalizeText("Cash")] = true,
    [normalizeText("Speed")] = true,
    [normalizeText("Roll")] = true,
}

DataSource.snipeEventAliases = {
    [normalizeText("SuperShenron")] = { "Super Shenron", "Shenron" },
    [normalizeText("Super Shenron")] = { "SuperShenron", "Shenron" },
}

function DataSource.cleanSnipeEventNames(list)
    local out = {}
    for _, item in ipairs(list or {}) do
        if type(item) == "string" and item ~= "" and not DataSource.blockedSnipeEventNames[normalizeText(item)] then
            table.insert(out, item)
        end
    end
    return uniqueSorted(out)
end

function DataSource.expandSnipeEventNames(list)
    local out = {}
    for _, item in ipairs(DataSource.cleanSnipeEventNames(list)) do
        table.insert(out, item)
        for _, alias in ipairs(DataSource.snipeEventAliases[normalizeText(item)] or {}) do
            if not DataSource.blockedSnipeEventNames[normalizeText(alias)] then
                table.insert(out, alias)
            end
        end
    end
    return uniqueSorted(out)
end

function DataSource.load()
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    local shared = modules and modules:FindFirstChild("Shared")
    local attackModules = modules and modules:FindFirstChild("AttackModules")
    local traitFolder = shared and shared:FindFirstChild("Trait")
    local battlepassFolder = ReplicatedStorage:FindFirstChild("Battlepass")
    local battlepassQuestFolder = ReplicatedStorage:FindFirstChild("BattlepassQuest")

    local charactersInfo = DataSource.safeRequire(shared and shared:FindFirstChild("CharactersInfo"), 1)
    local mutationInfo = DataSource.safeRequire(shared and shared:FindFirstChild("MutationInfo"), 1)
    local traitInfo = DataSource.safeRequire(traitFolder and traitFolder:FindFirstChild("TraitInfo"), 1)
    local levelInfo = DataSource.safeRequire(shared and shared:FindFirstChild("CharacterLevelInfo"), 1)
    local characterLevelHelper = DataSource.safeRequire(shared and shared:FindFirstChild("CharacterLevelHelper"), 1)
    local characterStatsUiHelper = DataSource.safeRequire(shared and shared:FindFirstChild("CharacterStatsUiHelper"), 1)
    local placementHelper = DataSource.safeRequire(shared and shared:FindFirstChild("PlacementHelper"), 1)
    local placementConfig = DataSource.safeRequire(shared and shared:FindFirstChild("PlacementConfig"), 1)
    local battlepassInfo = DataSource.safeRequire(battlepassFolder and battlepassFolder:FindFirstChild("BattlepassReward"), 1)
    local questInfo = DataSource.safeRequire(battlepassQuestFolder and battlepassQuestFolder:FindFirstChild("Quest"), 1)

    local fallbackCharacterNames = DataSource.combineLists(
        DataSource.extractKeys(charactersInfo, {
            { "Characters" },
            { "Units" },
            { "Animes" },
        }),
        DataSource.namesFromFolder(attackModules, { "Loader" })
    )
    local characterOptions = DataSource.buildCharacterOptions(charactersInfo, fallbackCharacterNames)
    local characterNames = DataSource.namesFromOptions(characterOptions)
    local characterRarity = DataSource.rarityMapFromOptions(characterOptions)
    local characterInfoByName = DataSource.buildCharacterInfoMap(charactersInfo)

    local mutationNames = DataSource.extractKeys(mutationInfo, {
        { "Mutations" },
        { "Mutation" },
        { "Events" },
        { "SpecialEvents" },
    })
    local mutationInfoByName = DataSource.buildNamedInfoMap(mutationInfo, "Mutations")
    local mutationEventNames = DataSource.extractEventNames("mutationEventName", {
        "Dragonborn",
        "Beast",
        "Arrancar",
        "Admin",
        "Nen",
        "Titan",
        "Quincy",
        "SuperShenron",
    })
    mutationEventNames = DataSource.cleanSnipeEventNames(mutationEventNames)

    local extractedTraitNames = DataSource.extractKeys(traitInfo, {
        { "Traits" },
    })
    local traitOptions = DataSource.buildTraitOptions(traitInfo, DataSource.combineLists(extractedTraitNames, Config.trait.targetTraits))
    local traitNames = DataSource.namesFromOptions(traitOptions)
    local traitRarity = DataSource.rarityMapFromOptions(traitOptions)
    local traitInfoByName = DataSource.buildNamedInfoMap(traitInfo, "Traits")

    local questIds = {}
    local quests = questInfo and questInfo.Quests
    if type(quests) == "table" then
        for _, quest in pairs(quests) do
            if type(quest) == "table" and quest.ID then
                table.insert(questIds, quest.ID)
            end
        end
    end

    local maxLevel = Config.battlepass.maxLevel
    if type(battlepassInfo) == "table" then
        if battlepassInfo.Config and tonumber(battlepassInfo.Config.MaxLevel) then
            maxLevel = tonumber(battlepassInfo.Config.MaxLevel)
        elseif type(battlepassInfo.Rewards) == "table" then
            maxLevel = #battlepassInfo.Rewards
        end
    end

    return {
        characterNames = characterNames,
        characterOptions = characterOptions,
        characterRarity = characterRarity,
        characterInfoByName = characterInfoByName,
        mutations = mutationNames,
        mutationInfoByName = mutationInfoByName,
        snipeEvents = mutationEventNames,
        traits = traitNames,
        traitOptions = traitOptions,
        traitRarity = traitRarity,
        traitInfoByName = traitInfoByName,
        levelInfo = levelInfo,
        characterLevelHelper = characterLevelHelper,
        characterStatsUiHelper = characterStatsUiHelper,
        placementHelper = placementHelper,
        placementConfig = placementConfig,
        battlepass = {
            maxLevel = maxLevel,
            questIds = uniqueSorted(questIds),
        },
    }
end

function State.loadSharedInfo()
    local data = DataSource.load()
    State.characterNames = data.characterNames
    State.characterOptions = data.characterOptions
    State.characterRarity = data.characterRarity
    State.characterInfoByName = data.characterInfoByName or {}
    State.mutations = data.mutations
    State.mutationInfoByName = data.mutationInfoByName or {}
    State.snipeEvents = data.snipeEvents
    State.traits = data.traits
    State.traitOptions = data.traitOptions
    State.traitRarity = data.traitRarity
    State.traitInfoByName = data.traitInfoByName or {}
    State.levelInfo = data.levelInfo
    State.characterLevelHelper = data.characterLevelHelper
    State.characterStatsUiHelper = data.characterStatsUiHelper
    State.placementHelper = data.placementHelper
    State.placementConfig = data.placementConfig
    State.shapeFootprints = {}
    State.battlepass = data.battlepass

    if #State.traits == 0 then
        State.traitOptions = DataSource.buildTraitOptions(nil, Config.trait.targetTraits)
        State.traits = DataSource.namesFromOptions(State.traitOptions)
        State.traitRarity = DataSource.rarityMapFromOptions(State.traitOptions)
    end
    if #State.mutations == 0 then
        State.mutations = copyArray(Config.roll.targetMutations)
    end
    if #State.characterNames == 0 then
        State.characterNames = copyArray(Config.roll.targetUnits)
        State.characterOptions = DataSource.buildCharacterOptions(nil, State.characterNames)
        State.characterRarity = DataSource.rarityMapFromOptions(State.characterOptions)
    end
    if #State.snipeEvents == 0 then
        State.snipeEvents = copyArray(Config.roll.snipeEvents)
    end
end

local function readAttr(instance, names, fallback)
    for _, name in ipairs(names) do
        local ok, value = pcall(function()
            return instance:GetAttribute(name)
        end)
        if ok and value ~= nil then
            return value
        end
        local child = instance:FindFirstChild(name)
        if child and child:IsA("ValueBase") then
            return child.Value
        end
    end
    return fallback
end

local function readUnitMutation(instance, fallback)
    return normalizeUnitMutation(readAttr(instance, { "Mutation", "MutationName", "MutationType" }, fallback), fallback)
end

local function isUnitContainer(instance)
    if instance:IsA("Tool") then
        return true
    end
    if instance:IsA("Model") and (instance:FindFirstChild("Animations") or instance:FindFirstChild("AnimSaves")) then
        return true
    end
    return false
end

function State.getDataClient()
    if State.dataClient then
        return State.dataClient
    end

    local data = ReplicatedStorage:FindFirstChild("Data")
    local service = data and data:FindFirstChild("DataService")
    local clientModule = data and data:FindFirstChild("DataServiceClient")
    local loaded = DataSource.safeRequire(service, 1) or DataSource.safeRequire(clientModule, 1)
    local client = loaded and loaded.client or loaded
    if client and client.waitForData then
        pcall(function()
            client:waitForData()
        end)
    end
    State.dataClient = client
    return client
end

function State.dataGet(path, fallback)
    local client = State.getDataClient()
    if not client or not client.get then
        return fallback
    end
    local ok, value = pcall(function()
        return client:get(path)
    end)
    if ok and value ~= nil then
        return value
    end
    return fallback
end

local function dataEntryValue(entry, names, fallback)
    if type(entry) ~= "table" then
        return fallback
    end
    for _, name in ipairs(names) do
        local value = entry[name]
        if value ~= nil then
            return value
        end
    end
    return fallback
end

local function dataEntryCharacterName(entry, fallback)
    local name = dataEntryValue(entry, { "Name", "CharacterName", "UnitName", "DisplayName" }, nil)
    if name ~= nil and tostring(name) ~= "" then
        return tostring(name)
    end

    local entryId = dataEntryValue(entry, { "EntryId", "EntryID" }, nil)
    if type(entryId) == "string" then
        local parsed = entryId:match("^([^|]+)")
        if parsed and parsed ~= "" then
            return parsed
        end
    end

    return tostring(fallback or "")
end

local UNIT_LOCK_VALUE_NAMES = { "Locked", "IsLocked", "Lock", "IsLock", "CharacterLocked", "UnitLocked", "Protected", "IsProtected" }
local UNIT_LOCK_ID_NAMES = { "CharacterId", "CharacterID", "UID", "Uuid", "UUID", "Id", "ID" }
local UNIT_LOCK_DATA_SOURCES = { "LockedCharacters", "LockedUnits", "CharacterLocks", "InventoryLocks", "ProtectedCharacters", "ProtectedUnits" }

local function isTruthyLockValue(value)
    if value == true then
        return true
    end
    if value == false or value == nil then
        return false
    end
    if type(value) == "number" then
        return value ~= 0
    end
    if type(value) == "string" then
        local clean = normalizeText(value)
        return clean == "true" or clean == "1" or clean == "yes" or clean == "on" or clean == "locked"
    end
    return false
end

local function addLockedUnitId(lockedUnitIds, id)
    local clean = tostring(id or "")
    if clean ~= "" then
        lockedUnitIds[clean] = true
    end
end

local function readDataEntryLocked(entry, id, lockedUnitIds)
    if lockedUnitIds and id ~= nil and lockedUnitIds[tostring(id)] == true then
        return true
    end
    return isTruthyLockValue(dataEntryValue(entry, UNIT_LOCK_VALUE_NAMES, false))
end

local function addLockDataEntry(lockedUnitIds, key, entry)
    if type(entry) == "table" then
        local id = dataEntryValue(entry, UNIT_LOCK_ID_NAMES, key)
        if readDataEntryLocked(entry, id, nil) then
            addLockedUnitId(lockedUnitIds, id)
        end
    elseif isTruthyLockValue(entry) then
        addLockedUnitId(lockedUnitIds, key)
    end
end

local function buildLockedUnitIdMap()
    local lockedUnitIds = {}
    for _, sourceName in ipairs(UNIT_LOCK_DATA_SOURCES) do
        local source = State.dataGet(sourceName, nil)
        if type(source) == "table" then
            for key, entry in pairs(source) do
                addLockDataEntry(lockedUnitIds, key, entry)
            end
        end
    end
    return lockedUnitIds
end

local function readUnitLocked(instance, fallback)
    if fallback == true then
        return true
    end
    return isTruthyLockValue(readAttr(instance, UNIT_LOCK_VALUE_NAMES, nil))
end

local function traitForCharacter(traitMap, id, fallback)
    local trait = type(traitMap) == "table" and traitMap[tostring(id)] or nil
    if trait == nil or trait == "" then
        trait = fallback
    end
    if trait == nil or trait == "" then
        return "None"
    end
    return tostring(trait)
end

local function upsertUnit(units, byId, unit)
    if not unit or not unit.id or unit.id == "" then
        return
    end

    local id = tostring(unit.id)
    unit.id = id
    local existing = byId[id]
    if existing then
        for key, value in pairs(unit) do
            if value ~= nil and value ~= "" and value ~= "?" then
                existing[key] = value
            end
        end
        return
    end

    byId[id] = unit
    table.insert(units, unit)
end

local function isPlacedUnitModel(model, containerName)
    if not model or not model:IsA("Model") then
        return false
    end
    if containerName == "Fighters" or containerName == "PlacedCharacters" then
        return true
    end
    if readAttr(model, { "IsPlacedCharacter" }, false) == true then
        return true
    end
    if tostring(readAttr(model, { "Cells" }, "")) ~= "" then
        return true
    end
    return false
end

function State.scanUnits()
    local units = {}
    local byId = {}
    local traitMap = State.dataGet("Traits", {})
    local inventory = State.dataGet("Inventory", {})
    local lockedUnitIds = buildLockedUnitIdMap()
    State.lockedUnitIds = lockedUnitIds
    State.lockedUnitIdsReady = true

    if type(inventory) == "table" then
        for _, item in pairs(inventory) do
            if type(item) == "table" then
                local id = dataEntryValue(item, { "CharacterId", "CharacterID", "UID", "Uuid", "UUID", "Id", "ID" }, nil)
                local name = dataEntryValue(item, { "Name", "CharacterName", "UnitName", "DisplayName" }, nil)
                if id and name then
                    upsertUnit(units, byId, {
                        instance = nil,
                        id = tostring(id),
                        name = tostring(name),
                        level = tostring(dataEntryValue(item, { "Level", "Lvl" }, "?")),
                        mutation = normalizeUnitMutation(dataEntryValue(item, { "Mutation", "MutationName", "MutationType" }, "None")),
                        trait = traitForCharacter(traitMap, id, dataEntryValue(item, { "Trait", "TraitName", "Passive" }, "None")),
                        locked = readDataEntryLocked(item, id, lockedUnitIds),
                        equipped = dataEntryValue(item, { "Equipped", "Placed", "IsEquipped" }, false) == true,
                        crafting = dataEntryValue(item, { "Crafting", "IsCrafting" }, false) == true,
                        cloning = dataEntryValue(item, { "Cloning", "IsCloning" }, false) == true,
                    })
                end
            end
        end
    end

    local roots = {
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer.Character,
    }
    for _, root in ipairs(roots) do
        if root then
            for _, child in ipairs(root:GetChildren()) do
                if isUnitContainer(child) then
                    local debugOk, debugId = pcall(function()
                        return child:GetDebugId(0)
                    end)
                    local id = tostring(readAttr(child, { "CharacterId", "CharacterID", "UID", "Uuid", "UUID", "Id", "ID" }, debugOk and debugId or child.Name))
                    upsertUnit(units, byId, {
                        instance = child,
                        id = id,
                        name = child.Name,
                        level = tostring(readAttr(child, { "Level", "Lvl" }, "?")),
                        mutation = readUnitMutation(child, "None"),
                        trait = traitForCharacter(traitMap, id, readAttr(child, { "Trait", "TraitName", "Passive" }, "None")),
                        locked = readUnitLocked(child, lockedUnitIds[id] == true),
                    })
                end
            end
        end
    end
    local plot = Feature and Feature.getOwnedPlot and Feature.getOwnedPlot()
    if plot then
        for _, containerName in ipairs({ "Characters", "Fighters", "PlacedCharacters", "Builds" }) do
            local folder = plot:FindFirstChild(containerName)
            if folder then
                for _, model in ipairs(folder:GetChildren()) do
                    local id = tostring(readAttr(model, { "CharacterId", "CharacterID", "UID", "Uuid", "UUID", "Id", "ID" }, ""))
                    if id ~= "" and model.Name ~= "" and isPlacedUnitModel(model, containerName) then
                        local existing = byId[id]
                        upsertUnit(units, byId, {
                            instance = model,
                            id = id,
                            name = tostring(readAttr(model, { "CharacterName", "Name" }, model.Name)),
                            level = tostring(readAttr(model, { "Level", "Lvl" }, "?")),
                            mutation = readUnitMutation(model, existing and existing.mutation or "None"),
                            trait = traitForCharacter(traitMap, id, readAttr(model, { "Trait", "TraitName", "Passive" }, existing and existing.trait or "None")),
                            locked = readUnitLocked(model, (existing and existing.locked) or lockedUnitIds[id] == true),
                            equipped = true,
                            placed = true,
                        })
                    end
                end
            end
        end
    end
    table.sort(units, function(a, b)
        return a.name < b.name
    end)
    State.characters = units
    return units
end

function State.getUnitById(id)
    for _, unit in ipairs(State.characters) do
        if tostring(unit.id) == tostring(id) then
            return unit
        end
    end
    return nil
end

function State.findUnitByName(name)
    for _, unit in ipairs(State.characters) do
        if unit.name == name then
            return unit
        end
    end
    return nil
end

function State.scanGuiText()
    local main = PlayerGui:FindFirstChild("MainUI")
    if not main then
        return
    end
    local texts = {}
    for _, d in ipairs(main:GetDescendants()) do
        if d:IsA("TextLabel") and d.Visible and d.Text and d.Text ~= "" then
            table.insert(texts, d.Text)
        end
    end
    for _, text in ipairs(texts) do
        if text:lower():find("wave") or text:lower():find("base") then
            State.waveStatus = text
        end
        if text:lower():find("current roll") then
            State.currentRoll = text
        end
        if text:lower():find("mythic") and text:lower():find("secret") and text:lower():find("roll") then
            State.pityText = text
        elseif text:lower():find("mythic") and text:lower():find("in") and text:lower():find("roll") then
            State.pityText = text
        elseif text:lower():find("secret") and text:lower():find("in") and text:lower():find("roll") then
            State.pityText = text
        end
    end
end

function State.refresh()
    State.loadSharedInfo()
    State.scanUnits()
    State.scanGuiText()
    return State
end

local UI = {
    tabs = {},
    controls = {},
    toggleRedraws = {},
    activeTab = nil,
}

local Theme = {
    bg = Color3.fromRGB(13, 16, 21),
    panel = Color3.fromRGB(21, 26, 34),
    panel2 = Color3.fromRGB(30, 36, 46),
    line = Color3.fromRGB(51, 62, 78),
    glass = Color3.fromRGB(15, 19, 26),
    glassPanel = Color3.fromRGB(27, 34, 44),
    accent = Color3.fromRGB(55, 141, 255),
    accent2 = Color3.fromRGB(89, 214, 165),
    text = Color3.fromRGB(235, 239, 245),
    muted = Color3.fromRGB(150, 162, 178),
    danger = Color3.fromRGB(255, 96, 111),
}

local function inst(className, props, children)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    for _, child in ipairs(children or {}) do
        child.Parent = object
    end
    return object
end

local function corner(radius)
    return inst("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

local function stroke(color, thickness)
    return inst("UIStroke", {
        Color = color or Theme.line,
        Thickness = thickness or 1,
        Transparency = 0.15,
    })
end

local function padding(px)
    return inst("UIPadding", {
        PaddingTop = UDim.new(0, px),
        PaddingBottom = UDim.new(0, px),
        PaddingLeft = UDim.new(0, px),
        PaddingRight = UDim.new(0, px),
    })
end

local function makeText(text, size, color, bold)
    return inst("TextLabel", {
        BackgroundTransparency = 1,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        Text = text,
        TextColor3 = color or Theme.text,
        TextSize = size or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    })
end

function UI.getGuiParent()
    if Config.ui.parent == "PlayerGui" then
        return PlayerGui
    end

    local ok, service = pcall(function()
        return game:GetService(Config.ui.parent)
    end)
    if ok and service then
        return service
    end
    return PlayerGui
end

function UI.setGlassEnabled(enabled)
    if UI.blurEffect then
        UI.blurEffect.Enabled = enabled == true
    end
end

function UI.isVisible(instance)
    local current = instance
    while current do
        if current:IsA("GuiObject") and current.Visible == false then
            return false
        end
        if current == UI.root then
            return true
        end
        current = current.Parent
    end
    return false
end

function UI.build()
    local gui = inst("ScreenGui", {
        Name = Config.ui.guiName,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    gui.Parent = UI.getGuiParent()
    Maid:add(gui)

    local blur = inst("BlurEffect", {
        Name = Config.ui.guiName .. "Blur",
        Size = 10,
        Enabled = true,
    })
    blur.Parent = Lighting
    UI.blurEffect = blur
    Maid:add(blur)

    local scale = inst("UIScale", { Scale = Config.ui.scale })
    local root = inst("Frame", {
        Name = "Root",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(820, 540),
        BackgroundColor3 = Theme.glass,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
    }, {
        corner(8),
        stroke(Theme.line, 1),
        scale,
    })
    root.Parent = gui
    UI.root = root
    UI.scale = scale

    local titlebar = inst("Frame", {
        Name = "Titlebar",
        BackgroundColor3 = Theme.glassPanel,
        BackgroundTransparency = 0.16,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
    }, {
        padding(10),
    })
    titlebar.Parent = root

    local title = makeText(Config.ui.title, 16, Theme.text, true)
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Parent = titlebar

    local close = inst("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(72, 26),
        BackgroundColor3 = Theme.panel2,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "Destroy",
        TextColor3 = Theme.danger,
        TextSize = 12,
    }, {
        corner(6),
    })
    close.Parent = titlebar
    close.MouseButton1Click:Connect(function()
        SaltHub.Destroy()
    end)

    local body = inst("Frame", {
        Name = "Body",
        Position = UDim2.fromOffset(0, 42),
        Size = UDim2.new(1, 0, 1, -42),
        BackgroundTransparency = 1,
    })
    body.Parent = root

    local sidebar = inst("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 132, 1, 0),
        BackgroundColor3 = Theme.glassPanel,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
    }, {
        padding(8),
    })
    sidebar.Parent = body
    UI.sidebar = sidebar

    local tabList = inst("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    tabList.Parent = sidebar

    local content = inst("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(132, 0),
        Size = UDim2.new(1, -132, 1, 0),
        BackgroundColor3 = Theme.glass,
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0,
    }, {
        padding(10),
    })
    content.Parent = body
    UI.content = content

    local dragging = false
    local dragStart
    local startPos
    titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
        end
    end)
    titlebar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    Maid:add(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    Maid:add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Config.ui.keybind then
            gui.Enabled = not gui.Enabled
            UI.setGlassEnabled(gui.Enabled)
        end
    end))
    UI.setGlassEnabled(gui.Enabled)
end

function UI.clearContent()
    for _, child in ipairs(UI.content:GetChildren()) do
        if not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

function UI.section(parent, title)
    local frame = inst("Frame", {
        Name = title,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.glassPanel,
        BackgroundTransparency = 0.16,
        BorderSizePixel = 0,
    }, {
        corner(7),
        stroke(Theme.line, 1),
        padding(10),
    })
    frame.Parent = parent

    local layout = inst("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = frame

    local header = makeText(title, 14, Theme.text, true)
    header.Size = UDim2.new(1, 0, 0, 20)
    header.Parent = frame
    return frame
end

function UI.button(parent, text, callback, color)
    local button = inst("TextButton", {
        Name = text,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = color or Theme.panel2,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = Theme.text,
        TextSize = 12,
        AutoButtonColor = true,
    }, {
        corner(6),
    })
    button.Parent = parent
    button.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then
            Log.push(err)
        end
    end)
    return button
end

function UI.label(parent, text, height)
    local label = makeText(text, 12, Theme.muted, false)
    label.Size = UDim2.new(1, 0, 0, height or 24)
    label.Parent = parent
    return label
end

function UI.toggle(parent, text, getter, setter)
    local button = inst("TextButton", {
        Name = text,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.panel2,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "",
        AutoButtonColor = true,
    }, {
        corner(6),
    })
    button.Parent = parent

    local mark = inst("Frame", {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.line,
        BorderSizePixel = 0,
    }, {
        corner(4),
    })
    mark.Parent = button

    local label = makeText(text, 12, Theme.text, false)
    label.Position = UDim2.fromOffset(32, 0)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Parent = button

    local function redraw()
        mark.BackgroundColor3 = getter() and Theme.accent2 or Theme.line
    end
    UI.toggleRedraws[text] = redraw
    button.MouseButton1Click:Connect(function()
        setter(not getter())
        if Feature and Feature.scheduleConfigSave then
            Feature.scheduleConfigSave("ui:" .. tostring(text))
        end
        redraw()
    end)
    redraw()
    return button
end

function UI.refreshToggle(text)
    local redraw = UI.toggleRedraws[text]
    if redraw then
        redraw()
    end
end

function UI.textBox(parent, title, initial, callback)
    local box = inst("TextBox", {
        Name = title,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.panel2,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderText = title,
        Text = initial or "",
        TextColor3 = Theme.text,
        PlaceholderColor3 = Theme.muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, {
        corner(6),
        padding(8),
    })
    box.Parent = parent
    box.FocusLost:Connect(function()
        callback(box.Text)
        if Feature and Feature.scheduleConfigSave then
            Feature.scheduleConfigSave("ui:" .. tostring(title))
        end
    end)
    return box
end

function UI.searchBox(parent, placeholder, onChanged)
    local box = inst("TextBox", {
        Name = "Search",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.panel2,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderText = placeholder or "Search",
        Text = "",
        TextColor3 = Theme.text,
        PlaceholderColor3 = Theme.muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, {
        corner(6),
        padding(8),
    })
    box.Parent = parent
    box:GetPropertyChangedSignal("Text"):Connect(function()
        onChanged(tostring(box.Text or ""))
    end)
    return box
end

function UI.matchesSearch(value, searchText)
    local query = normalizeText(searchText)
    if query == "" then
        return true
    end

    local haystack = normalizeText(value)
    if haystack == "" then
        return false
    end

    for token in query:gmatch("%S+") do
        if not haystack:find(token, 1, true) then
            return false
        end
    end
    return true
end

function UI.unitSearchText(unit)
    if type(unit) ~= "table" then
        return tostring(unit or "")
    end
    return table.concat({
        tostring(unit.id or ""),
        tostring(unit.name or unit.Name or ""),
        tostring(unit.displayName or unit.DisplayName or ""),
        tostring(unit.mutation or unit.Mutation or ""),
        tostring(unit.level or unit.Level or ""),
        tostring(unit.trait or unit.Trait or ""),
        tostring(unit.rarity or unit.Rarity or ""),
    }, " ")
end

function UI.unitOptionSearchText(unitValue, mutationText)
    if type(unitValue) ~= "table" then
        return tostring(unitValue or "") .. " " .. tostring(mutationText or "")
    end
    return table.concat({
        tostring(unitValue.name or unitValue.Name or ""),
        tostring(unitValue.displayName or unitValue.DisplayName or ""),
        tostring(unitValue.rarity or unitValue.Rarity or ""),
        tostring(mutationText or ""),
    }, " ")
end

function UI.cycle(parent, title, options, getter, setter)
    local button = UI.button(parent, title, function()
        local list = options()
        if #list == 0 then
            return
        end
        local current = getter()
        local index = table.find(list, current) or 0
        index = index + 1
        if index > #list then
            index = 1
        end
        setter(list[index])
        if Feature and Feature.scheduleConfigSave then
            Feature.scheduleConfigSave("ui:" .. tostring(title))
        end
    end)
    local lastUpdate = 0
    Maid:add(RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if button and button.Parent and UI.isVisible(button) and now - lastUpdate >= 0.25 then
            lastUpdate = now
            button.Text = title .. ": " .. tostring(getter() or "-")
        end
    end))
    return button
end

function UI.slider(parent, title, getter, setter, minValue, maxValue, stepValue)
    local frame = inst("Frame", {
        Name = title .. "Slider",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.panel2,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
    }, {
        corner(6),
        padding(8),
    })
    frame.Parent = parent

    local label = makeText("", 12, Theme.text, false)
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Parent = frame

    local track = inst("Frame", {
        Name = "Track",
        Position = UDim2.fromOffset(0, 28),
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = Theme.line,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
    }, {
        corner(4),
    })
    track.Parent = frame

    local fill = inst("Frame", {
        Name = "Fill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.accent2,
        BorderSizePixel = 0,
    }, {
        corner(4),
    })
    fill.Parent = track

    local dragging = false
    local min = tonumber(minValue) or 0
    local max = tonumber(maxValue) or 100
    local step = tonumber(stepValue) or 1

    local function normalize(value)
        local clamped = math.clamp(tonumber(value) or min, min, max)
        return math.floor(((clamped - min) / step) + 0.5) * step + min
    end

    local function redraw()
        local value = normalize(getter())
        local alpha = 0
        if max > min then
            alpha = math.clamp((value - min) / (max - min), 0, 1)
        end
        label.Text = title .. ": " .. tostring(value) .. "s"
        fill.Size = UDim2.new(alpha, 0, 1, 0)
    end

    local function setFromPosition(x)
        local width = math.max(track.AbsoluteSize.X, 1)
        local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        setter(normalize(min + (max - min) * alpha))
        if Feature and Feature.scheduleConfigSave then
            Feature.scheduleConfigSave("ui:" .. tostring(title))
        end
        redraw()
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromPosition(input.Position.X)
        end
    end)
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    Maid:add(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromPosition(input.Position.X)
        end
    end))
    local lastRedraw = 0
    Maid:add(RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if frame and frame.Parent and UI.isVisible(frame) and now - lastRedraw >= 0.25 then
            lastRedraw = now
            redraw()
        end
    end))
    redraw()
    return frame
end

function UI.multiSelectList(parent, title, optionsGetter, selectedGetter, setter, height)
    local frame = UI.section(parent, title)
    local summary = UI.label(frame, "", 24)
    local list = inst("ScrollingFrame", {
        Name = title .. "List",
        Size = UDim2.new(1, 0, 0, height or 150),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    local layout = inst("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = list
    list.Parent = frame

    local function selectedMap()
        local map = {}
        for _, value in ipairs(selectedGetter() or {}) do
            map[tostring(value)] = true
        end
        return map
    end

    local function setSelected(value, enabled)
        local map = selectedMap()
        map[tostring(value)] = enabled == true or nil
        local out = {}
        for key, selected in pairs(map) do
            if selected then
                table.insert(out, key)
            end
        end
        setter(uniqueSorted(out))
        if Feature and Feature.scheduleConfigSave then
            Feature.scheduleConfigSave("ui:" .. tostring(title))
        end
    end

    local function refresh()
        for _, child in ipairs(list:GetChildren()) do
            if child ~= layout then
                child:Destroy()
            end
        end

        local options = optionsGetter() or {}
        local selected = selectedMap()
        local selectedCount = 0
        for _, value in ipairs(selectedGetter() or {}) do
            if tostring(value) ~= "" then
                selectedCount += 1
            end
        end
        summary.Text = selectedCount == 0 and "None selected" or (tostring(selectedCount) .. " selected")

        for index, option in ipairs(options) do
            local text = tostring(option)
            local active = selected[text] == true
            local button = inst("TextButton", {
                Name = text,
                LayoutOrder = index,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = active and Theme.accent or Theme.panel2,
                BorderSizePixel = 0,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = true,
            }, {
                corner(6),
                padding(8),
            })
            button.MouseButton1Click:Connect(function()
                setSelected(text, not active)
                refresh()
            end)
            button.Parent = list
        end
    end

    refresh()
    return {
        frame = frame,
        refresh = refresh,
    }
end

function UI.inventoryUnitSelector(parent, title, unitsGetter, selectedIdGetter, setter, height)
    local frame = UI.section(parent, title)
    local searchText = ""
    local refresh
    UI.searchBox(frame, "Search units, mutations, traits", function(text)
        searchText = text
        if refresh then
            refresh()
        end
    end)
    local list = inst("ScrollingFrame", {
        Name = "TraitUnitTable",
        Size = UDim2.new(1, 0, 0, height or 190),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    local layout = inst("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = list
    list.Parent = frame

    local lastSignature = nil
    local function getSignature(units)
        local parts = { tostring(selectedIdGetter() or ""), tostring(#(units or {})) }
        for _, unit in ipairs(units or {}) do
            table.insert(parts, table.concat({
                tostring(unit and unit.id or ""),
                tostring(unit and unit.name or ""),
                tostring(unit and unit.mutation or ""),
                tostring(unit and unit.level or ""),
                tostring(unit and unit.trait or ""),
            }, "|"))
        end
        return table.concat(parts, "\n")
    end

    refresh = function(units)
        units = units or unitsGetter() or {}
        lastSignature = getSignature(units)
        for _, child in ipairs(list:GetChildren()) do
            if child ~= layout then
                child:Destroy()
            end
        end

        local selectedId = tostring(selectedIdGetter() or "")
        for index, unit in ipairs(units) do
            if not UI.matchesSearch(UI.unitSearchText(unit), searchText) then
                continue
            end
            local rarity = State.traitRarity[unit.trait] or TRAIT_RARITY_FALLBACK[unit.trait] or "Common"
            local traitColor = rarityColor(rarity)
            local selected = tostring(unit.id) == selectedId
            local text = unit.name .. " - " .. unit.mutation .. " - Lvl " .. tostring(unit.level) .. " - " .. unit.trait
            local row = inst("TextButton", {
                Name = "Unit_" .. tostring(index),
                LayoutOrder = index,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = selected and traitColor or Theme.panel2,
                BackgroundTransparency = selected and 0.08 or 0.16,
                BorderSizePixel = 0,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = true,
            }, {
                corner(6),
                stroke(traitColor, selected and 2 or 1),
                padding(10),
            })
            row.MouseButton1Click:Connect(function()
                setter(unit)
                if Feature and Feature.scheduleConfigSave then
                    Feature.scheduleConfigSave("ui:" .. tostring(title))
                end
                refresh()
            end)
            row.Parent = list
        end
    end

    refresh()
    local lastRefresh = 0
    Maid:add(RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if list and list.Parent and UI.isVisible(list) and now - lastRefresh >= 1.25 then
            lastRefresh = now
            local units = unitsGetter() or {}
            local signature = getSignature(units)
            if signature ~= lastSignature then
                refresh(units)
            end
        end
    end))
    return {
        frame = frame,
        refresh = refresh,
    }
end

function UI.traitSelector(parent, title, optionsGetter, selectedGetter, setter, height)
    local frame = UI.section(parent, title)
    local list = inst("ScrollingFrame", {
        Name = "TraitTargetTraits",
        Size = UDim2.new(1, 0, 0, height or 190),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    local layout = inst("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = list
    list.Parent = frame

    local function selectedMap()
        local map = {}
        for _, value in ipairs(selectedGetter() or {}) do
            map[tostring(value)] = true
        end
        return map
    end

    local function optionName(option)
        return type(option) == "table" and tostring(option.name or option.Name or option.displayName or "") or tostring(option)
    end

    local function commit(map)
        local out = {}
        for _, option in ipairs(optionsGetter() or {}) do
            local name = optionName(option)
            if map[name] then
                table.insert(out, name)
                map[name] = nil
            end
        end
        for name, selected in pairs(map) do
            if selected then
                table.insert(out, name)
            end
        end
        setter(out)
        if Feature and Feature.scheduleConfigSave then
            Feature.scheduleConfigSave("ui:" .. tostring(title))
        end
    end

    local function refresh()
        for _, child in ipairs(list:GetChildren()) do
            if child ~= layout then
                child:Destroy()
            end
        end

        local selected = selectedMap()
        for index, option in ipairs(optionsGetter() or {}) do
            local trait = optionName(option)
            local rarity = type(option) == "table" and tostring(option.rarity or option.Rarity or State.traitRarity[trait] or "Common") or tostring(State.traitRarity[trait] or "Common")
            local traitColor = rarityColor(rarity)
            local active = selected[trait] == true
            local row = inst("TextButton", {
                Name = trait,
                LayoutOrder = index,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = active and traitColor or Theme.panel2,
                BackgroundTransparency = active and 0.08 or 0.16,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                Text = (active and "[x] " or "[ ] ") .. trait .. "  -  " .. rarity,
                TextColor3 = Theme.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = true,
            }, {
                corner(6),
                stroke(traitColor, active and 2 or 1),
                padding(10),
            })
            row.MouseButton1Click:Connect(function()
                local map = selectedMap()
                map[trait] = not active or nil
                commit(map)
                refresh()
            end)
            row.Parent = list
        end
    end

    refresh()
    return {
        frame = frame,
        refresh = refresh,
    }
end

function UI.unitMutationSelector(parent, title, unitsGetter, mutationsGetter, selectedUnitsGetter, mutationMapGetter, onChanged, height, webhookOptions)
    local frame = UI.section(parent, title)
    local summary = UI.label(frame, "", 24)
    local searchText = ""
    local refresh
    UI.searchBox(frame, "Search units or mutations", function(text)
        searchText = text
        if refresh then
            refresh()
        end
    end)
    local list = inst("ScrollingFrame", {
        Name = title .. "Tree",
        Size = UDim2.new(1, 0, 0, height or 260),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    local layout = inst("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = list
    list.Parent = frame

    local expanded = {}

    local function makeMap(values)
        local map = {}
        for _, value in ipairs(values or {}) do
            map[tostring(value)] = true
        end
        return map
    end

    local function currentTargets()
        local targets = {}
        local source = mutationMapGetter() or {}
        for unit, mutations in pairs(source) do
            targets[tostring(unit)] = copyArray(mutations)
        end
        return targets
    end

    local function commit(unitMap, mutationTargets)
        local units = {}
        for unit, selected in pairs(unitMap) do
            if selected then
                table.insert(units, unit)
            else
                mutationTargets[unit] = nil
            end
        end
        onChanged(uniqueSorted(units), mutationTargets)
        if Feature and Feature.scheduleConfigSave then
            Feature.scheduleConfigSave("ui:" .. tostring(title))
        end
    end

    local function setUnit(unit, enabled)
        local unitMap = makeMap(selectedUnitsGetter())
        local mutationTargets = currentTargets()
        unitMap[unit] = enabled == true or nil
        if not enabled then
            mutationTargets[unit] = nil
        end
        commit(unitMap, mutationTargets)
    end

    local function setMutation(unit, mutation, enabled)
        local unitMap = makeMap(selectedUnitsGetter())
        local mutationTargets = currentTargets()
        unitMap[unit] = true
        local listForUnit = makeMap(mutationTargets[unit])
        listForUnit[mutation] = enabled == true or nil
        local out = {}
        for name, selected in pairs(listForUnit) do
            if selected then
                table.insert(out, name)
            end
        end
        mutationTargets[unit] = uniqueSorted(out)
        commit(unitMap, mutationTargets)
    end

    local lastWebhookVisible = nil
    local lastWebhookRefresh = 0
    local function webhookBellsVisible()
        return webhookOptions and webhookOptions.enabled and webhookOptions.enabled() == true
    end

    refresh = function()
        for _, child in ipairs(list:GetChildren()) do
            if child ~= layout then
                child:Destroy()
            end
        end

        local unitMap = makeMap(selectedUnitsGetter())
        local mutationTargets = currentTargets()
        local selectedCount = 0
        for _, selected in pairs(unitMap) do
            if selected then
                selectedCount += 1
            end
        end
        summary.Text = selectedCount == 0 and "No unit targets selected" or (tostring(selectedCount) .. " unit targets selected")

        local showWebhookBells = webhookOptions and webhookOptions.enabled and webhookOptions.enabled() == true
        lastWebhookVisible = showWebhookBells
        local lastRarity = nil
        local mutationSearchText = table.concat(mutationsGetter() or {}, " ")
        for index, unitValue in ipairs(unitsGetter() or {}) do
            if not UI.matchesSearch(UI.unitOptionSearchText(unitValue, mutationSearchText), searchText) then
                continue
            end
            local unit = type(unitValue) == "table" and tostring(unitValue.name or unitValue.Name or "") or tostring(unitValue)
            local displayName = type(unitValue) == "table" and tostring(unitValue.displayName or unitValue.DisplayName or unit) or unit
            local rarity = type(unitValue) == "table" and tostring(unitValue.rarity or unitValue.Rarity or State.characterRarity[unit] or "Common") or tostring(State.characterRarity[unit] or "Common")
            local unitColor = rarityColor(rarity)
            local selected = unitMap[unit] == true
            local mutations = mutationTargets[unit] or {}
            local open = expanded[unit] == true
            local unitBellActive = showWebhookBells and webhookOptions.isUnitActive and webhookOptions.isUnitActive(unit) == true

            if rarity ~= lastRarity then
                lastRarity = rarity
                local header = inst("TextLabel", {
                    Name = "RarityHeader",
                    LayoutOrder = index * 2 - 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundColor3 = unitColor,
                    BackgroundTransparency = 0.7,
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    Text = rarity,
                    TextColor3 = Theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, {
                    corner(6),
                    padding(9),
                })
                header.Parent = list
            end

            local container = inst("Frame", {
                Name = unit,
                LayoutOrder = index * 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            })
            local containerLayout = inst("UIListLayout", {
                Name = "UnitContainerLayout",
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            containerLayout.Parent = container
            container.Parent = list

            local row = inst("Frame", {
                Name = "UnitRow",
                LayoutOrder = 1,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = unitColor,
                BackgroundTransparency = selected and 0.12 or 0.72,
                BorderSizePixel = 0,
            }, {
                corner(6),
                stroke(unitColor, selected and 2 or 1),
            })
            row.Parent = container

            local rarityBadge = inst("TextLabel", {
                Name = "RarityBadge",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 9, 0.5, 0),
                Size = UDim2.fromOffset(70, 18),
                BackgroundColor3 = unitColor,
                BackgroundTransparency = 0.08,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                Text = rarity,
                TextColor3 = Theme.text,
                TextSize = 10,
            }, {
                corner(5),
            })
            rarityBadge.Parent = row

            local unitButton = inst("TextButton", {
                Name = "UnitButton",
                Position = UDim2.fromOffset(84, 0),
                Size = UDim2.new(1, showWebhookBells and -154 or -122, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = displayName .. (#mutations == 0 and " - any mutation" or (" - " .. tostring(#mutations) .. " mutations")),
                TextColor3 = Theme.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = true,
            }, {
                padding(10),
            })
            unitButton.Parent = row

            if showWebhookBells then
                local unitBell = inst("TextButton", {
                    Name = "UnitWebhookBell",
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -36, 0.5, 0),
                    Size = UDim2.fromOffset(22, 22),
                    BackgroundColor3 = unitBellActive and Theme.accent or Theme.glassPanel,
                    BackgroundTransparency = unitBellActive and 0.05 or 0.18,
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    Text = unitBellActive and "🔔" or "🔕",
                    TextColor3 = Theme.text,
                    TextSize = 12,
                    AutoButtonColor = true,
                }, {
                    corner(5),
                    stroke(unitBellActive and Theme.accent or Theme.line, 1),
                })
                unitBell.MouseButton1Click:Connect(function()
                    webhookOptions.setUnit(unit, not unitBellActive)
                    refresh()
                end)
                unitBell.Parent = row
            end

            local caret = inst("TextButton", {
                Name = "Caret",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                BackgroundColor3 = Theme.glassPanel,
                BackgroundTransparency = 0.05,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                Text = "v",
                TextColor3 = Theme.text,
                TextSize = 12,
                Rotation = open and 180 or 0,
                AutoButtonColor = true,
            }, {
                corner(5),
                stroke(Theme.line, 1),
            })
            caret.Parent = row

            local mutationsFrame = inst("Frame", {
                Name = "Mutations",
                LayoutOrder = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.glassPanel,
                BackgroundTransparency = open and 0.18 or 1,
                BorderSizePixel = 0,
                Visible = open,
            }, {
                corner(6),
                padding(8),
            })
            local mutationLayout = inst("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            mutationLayout.Parent = mutationsFrame
            mutationsFrame.Parent = container

            unitButton.MouseButton1Click:Connect(function()
                setUnit(unit, not selected)
                refresh()
            end)
            caret.MouseButton1Click:Connect(function()
                expanded[unit] = not open
                mutationsFrame.Visible = true
                TweenService:Create(caret, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Rotation = expanded[unit] and 180 or 0,
                }):Play()
                TweenService:Create(mutationsFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = expanded[unit] and 0.18 or 1,
                }):Play()
                task.delay(0.18, refresh)
            end)

            for mutationIndex, mutationValue in ipairs(mutationsGetter() or {}) do
                local mutation = tostring(mutationValue)
                local mutationSelected = makeMap(mutations)[mutation] == true
                local mutationBellActive = showWebhookBells and webhookOptions.isMutationActive and webhookOptions.isMutationActive(mutation) == true
                local mutationRow = inst("Frame", {
                    Name = mutation,
                    LayoutOrder = mutationIndex,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundColor3 = mutationSelected and Theme.accent2 or Theme.panel2,
                    BackgroundTransparency = mutationSelected and 0.12 or 0.18,
                    BorderSizePixel = 0,
                }, {
                    corner(5),
                })
                local button = inst("TextButton", {
                    Name = "MutationButton",
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.new(1, showWebhookBells and -32 or 0, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = mutation,
                    TextColor3 = Theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = true,
                }, {
                    padding(22),
                })
                button.MouseButton1Click:Connect(function()
                    setMutation(unit, mutation, not mutationSelected)
                    refresh()
                end)
                button.Parent = mutationRow
                if showWebhookBells then
                    local mutationBell = inst("TextButton", {
                        Name = "MutationWebhookBell",
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -5, 0.5, 0),
                        Size = UDim2.fromOffset(22, 20),
                        BackgroundColor3 = mutationBellActive and Theme.accent or Theme.glassPanel,
                        BackgroundTransparency = mutationBellActive and 0.05 or 0.18,
                        BorderSizePixel = 0,
                        Font = Enum.Font.GothamBold,
                        Text = mutationBellActive and "🔔" or "🔕",
                        TextColor3 = Theme.text,
                        TextSize = 11,
                        AutoButtonColor = true,
                    }, {
                        corner(5),
                        stroke(mutationBellActive and Theme.accent or Theme.line, 1),
                    })
                    mutationBell.MouseButton1Click:Connect(function()
                        webhookOptions.setMutation(mutation, not mutationBellActive)
                        refresh()
                    end)
                    mutationBell.Parent = mutationRow
                end
                mutationRow.Parent = mutationsFrame
            end
        end
    end

    refresh()
    if webhookOptions then
        Maid:add(RunService.Heartbeat:Connect(function()
            local now = os.clock()
            if list and list.Parent and UI.isVisible(list) and now - lastWebhookRefresh >= 0.5 then
                lastWebhookRefresh = now
                if webhookBellsVisible() ~= lastWebhookVisible then
                    refresh()
                end
            end
        end))
    end
    return {
        frame = frame,
        refresh = refresh,
    }
end

function UI.statusList(parent, title, getter, height, interval)
    local frame = UI.section(parent, title)
    local label = UI.label(frame, "Scanning...", height or 120)
    local lastRefresh = 0
    Maid:add(RunService.Heartbeat:Connect(function()
        if label and label.Parent and os.clock() - lastRefresh >= (interval or 1) then
            lastRefresh = os.clock()
            label.Text = getter()
        end
    end))
    return label
end

function UI.logBox(parent)
    local label = makeText("", 11, Theme.muted, false)
    label.Size = UDim2.new(1, 0, 0, 110)
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Parent = parent
    Maid:add(RunService.Heartbeat:Connect(function()
        if label and label.Parent then
            label.Text = table.concat(Log.lines, "\n")
        end
    end))
    return label
end

function UI.makeTab(tab)
    local button = inst("TextButton", {
        Name = tab.name,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.panel2,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = tab.name,
        TextColor3 = Theme.text,
        TextSize = 12,
    }, {
        corner(6),
    })
    button.Parent = UI.sidebar

    local page = inst("ScrollingFrame", {
        Name = tab.name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    })
    local layout = inst("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = page

    UI.tabs[tab.name] = { button = button, page = page, tab = tab }
    button.MouseButton1Click:Connect(function()
        UI.showTab(tab.name)
    end)
end

function UI.showTab(name)
    for tabName, info in pairs(UI.tabs) do
        info.page.Visible = tabName == name
        info.button.BackgroundColor3 = tabName == name and Theme.accent or Theme.panel2
    end
    UI.activeTab = name
end

Feature = {
    loops = {},
    dataClient = nil,
    dataClientChecked = false,
    upgradeInfo = nil,
    battlepassReward = nil,
    antiAfkConnection = nil,
    nativeMenuOptimizerConnection = nil,
    nativeMenuRootConnections = {},
    nativeVisualEffectRootConnections = {},
    nativeMenuOpenGuardConnections = {},
    nativeMenuQueuedRootScans = {},
    nativeMenuQueuedViewports = {},
    nativeMenuQueuedVisualEffects = {},
    nativeMenuUiSuspended = false,
    nativeMenuUiWasVisible = nil,
}

function Feature.resetSessionOnlySettings()
    resetSessionOnlySettings()
end

function Feature.getConfigStoragePath()
    return getExecutorConfigPath()
end

function Feature.saveConfigToWorkspace(reason, quiet)
    if Config.storage and Config.storage.autoSave == false then
        if not quiet then
            Log.push("Settings auto-save is disabled.")
        end
        return false
    end
    if type(writefile) ~= "function" then
        if not quiet then
            Log.push("Settings save skipped: executor writefile unavailable.")
        end
        return false
    end

    Config.roll.unitMutationTargets = normalizeUnitMutationTargets(Config.roll.unitMutationTargets)
    if Feature.normalizeWebhookConfig then
        Feature.normalizeWebhookConfig()
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(Feature.getSerializableConfig())
    end)
    if not ok then
        Log.push("Settings save failed: " .. tostring(encoded))
        return false
    end

    local lastErr = nil
    local savedPaths = {}
    for _, path in ipairs(getExecutorConfigCandidatePaths()) do
        local shouldTry = #savedPaths == 0
        if not shouldTry and type(isfile) == "function" then
            local okExists, exists = pcall(isfile, path)
            shouldTry = okExists and exists == true
        end

        if shouldTry then
            local folder = getExecutorFolderFromPath(path)
            local folderOk, folderErr = ensureExecutorConfigFolder(folder)
            if folderOk then
                local saveOk, saveErr = pcall(writefile, path, encoded)
                if saveOk then
                    table.insert(savedPaths, path)
                else
                    lastErr = saveErr
                end
            else
                lastErr = folderErr
            end
        end
    end

    if #savedPaths > 0 then
        State.lastConfigSaveAt = os.clock()
        State.lastConfigSavePath = savedPaths[1]
        State.lastConfigSavePaths = savedPaths
        State.lastConfigSaveError = nil
        if not quiet then
            Log.push("Settings saved to executor workspace: " .. table.concat(savedPaths, ", "))
        end
        return true
    end

    State.lastConfigSaveError = tostring(lastErr or "unknown writefile failure")
    Log.push("Settings save failed: " .. State.lastConfigSaveError)
    return false
end

function Feature.scheduleConfigSave(reason)
    if Config.storage and Config.storage.autoSave == false then
        return false
    end
    State.configSaveReason = reason or "changed"
    if State.configSaveQueued then
        return true
    end

    State.configSaveQueued = true
    local delaySeconds = tonumber(Config.storage and Config.storage.saveDelay) or 0.35
    task.delay(delaySeconds, function()
        State.configSaveQueued = false
        Feature.saveConfigToWorkspace(State.configSaveReason, true)
    end)
    return true
end

function Feature.stopLoop(key)
    Feature.loops[key] = nil
end

function Feature.startLoop(key, delayGetter, callback)
    Feature.loops[key] = true
    task.spawn(function()
        while Feature.loops[key] do
            local ok, err = pcall(callback)
            if not ok then
                Log.push(key .. " loop error: " .. tostring(err))
            end
            task.wait(type(delayGetter) == "function" and delayGetter() or delayGetter)
        end
    end)
end

function Feature.setFlag(flag, value)
    Config.flags[flag] = value == true
    if not value then
        Feature.stopLoop(flag)
    end
end

function Feature.pulseAntiAfk(idleTime, force)
    if not Config.flags.antiAfk then
        return false
    end

    local now = os.clock()
    if not force and now - (State.lastAntiAfkAt or 0) < Config.delays.antiAfkCooldown then
        return false
    end

    State.lastAntiAfkAt = now
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Jump = true
    end

    local keyOk, keyErr = pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)

    local ok = keyOk
    local err = keyErr
    if not keyOk then
        ok, err = pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end

    if ok then
        Log.push("Anti-AFK pulse" .. (idleTime and (" after " .. tostring(math.floor(idleTime)) .. "s idle") or "."))
        return true
    end

    Log.push("Anti-AFK failed: " .. tostring(err))
    return false
end

function Feature.testAntiAfk()
    return Feature.pulseAntiAfk(0, true)
end

function Feature.stopAntiAfkLoop()
    Feature.loops.antiAfk = nil
end

function Feature.startAntiAfkLoop()
    if Feature.loops.antiAfk or not Config.flags.antiAfk then
        return
    end

    Feature.loops.antiAfk = true
    task.spawn(function()
        while Feature.loops.antiAfk do
            task.wait(Config.delays.antiAfkCooldown)
            if Feature.loops.antiAfk then
                Feature.pulseAntiAfk(nil, true)
            end
        end
    end)
end

function Feature.restartAntiAfkLoop()
    Feature.stopAntiAfkLoop()
    Feature.startAntiAfkLoop()
end

function Feature.setAntiAfkEnabled(value)
    Config.flags.antiAfk = value == true
    if Config.flags.antiAfk then
        State.lastAntiAfkAt = 0
        Feature.startAntiAfkLoop()
        Log.push("Anti-AFK enabled.")
    else
        Feature.stopAntiAfkLoop()
        Log.push("Anti-AFK disabled.")
    end
end

function Feature.attachAntiAfk()
    if Feature.antiAfkConnection then
        return
    end
    Feature.antiAfkConnection = LocalPlayer.Idled:Connect(function(idleTime)
        Feature.pulseAntiAfk(idleTime)
    end)
    Maid:add(Feature.antiAfkConnection)
end

function Feature.getNativeMenuRootNames()
    return {
        "Inventory",
        "Inventory_Old",
        "Clone",
        "Selection",
        "Shop",
        "Index",
        "RandomAnime",
        "ExclusiveEgg",
        "Craft",
        "Battlepass",
        "Rewards",
        "Quests",
        "Trading",
        "Trade",
    }
end

function Feature.getNativeMenuFrameRoot()
    local mainUi = PlayerGui:FindFirstChild("MainUI")
    return mainUi and mainUi:FindFirstChild("Frames") or nil
end

function Feature.getNativeMenuRoots()
    local roots = {}
    local seen = {}
    local function add(root)
        if root and not seen[root] then
            seen[root] = true
            table.insert(roots, root)
        end
    end
    local frames = Feature.getNativeMenuFrameRoot()
    if not frames then
        return roots
    end

    for _, name in ipairs(Feature.getNativeMenuRootNames()) do
        add(frames:FindFirstChild(name))
    end
    for _, root in ipairs(frames:GetChildren()) do
        add(root)
    end
    return roots
end

function Feature.getNativeVisualEffectRoots()
    local seen = {}
    local roots = {}

    local mainUi = PlayerGui:FindFirstChild("MainUI")
    if mainUi then
        for _, name in ipairs({ "Hotbar", "Lootbox" }) do
            local root = mainUi:FindFirstChild(name)
            if root and not seen[root] then
                seen[root] = true
                table.insert(roots, root)
            end
        end
    end
    return roots
end

function Feature.findAncestorViewport(instance)
    local current = instance
    while current and current ~= PlayerGui do
        if current:IsA("ViewportFrame") then
            return current
        end
        current = current.Parent
    end
    return nil
end

function Feature.stopNativePreviewTracks(animationOwner)
    if not animationOwner or not animationOwner.GetPlayingAnimationTracks then
        return
    end

    local ok, tracks = pcall(function()
        return animationOwner:GetPlayingAnimationTracks()
    end)
    if not ok or type(tracks) ~= "table" then
        return
    end

    for _, track in ipairs(tracks) do
        pcall(function()
            track:Stop(0)
        end)
    end
end

function Feature.isNativeVisualEffect(instance)
    return instance
        and (instance:IsA("UIGradient")
            or instance:IsA("ParticleEmitter")
            or instance:IsA("Beam")
            or instance:IsA("Trail")
            or instance:IsA("Highlight")
            or instance:IsA("Fire")
            or instance:IsA("Smoke")
            or instance:IsA("Sparkles"))
end

function Feature.freezeNativeVisualEffect(effect)
    if not Feature.isNativeVisualEffect(effect) then
        return false
    end

    if effect:GetAttribute("SaltHubHadOriginalEffectEnabled") ~= true then
        effect:SetAttribute("SaltHubHadOriginalEffectEnabled", true)
        local enabledOk, enabled = pcall(function()
            return effect.Enabled
        end)
        if enabledOk then
            effect:SetAttribute("SaltHubOriginalEffectEnabled", enabled == true)
        end
    end
    if effect:IsA("UIGradient") and effect:GetAttribute("SaltHubHadOriginalGradientState") ~= true then
        effect:SetAttribute("SaltHubHadOriginalGradientState", true)
        pcall(function()
            effect:SetAttribute("SaltHubOriginalGradientOffset", effect.Offset)
        end)
        pcall(function()
            effect:SetAttribute("SaltHubOriginalGradientRotation", effect.Rotation)
        end)
    end

    effect:SetAttribute("SaltHubFrozenVisualEffect", true)
    if effect:IsA("UIGradient") then
        pcall(function()
            effect.Enabled = true
        end)
        pcall(function()
            effect.Offset = Vector2.new(0, 0)
        end)
        pcall(function()
            effect.Rotation = 0
        end)
    else
        pcall(function()
            effect.Enabled = false
        end)
    end
    return true
end

function Feature.restoreNativeVisualEffect(effect)
    if not Feature.isNativeVisualEffect(effect) then
        return false
    end

    if effect:GetAttribute("SaltHubHadOriginalEffectEnabled") == true then
        local originalEnabled = effect:GetAttribute("SaltHubOriginalEffectEnabled")
        if originalEnabled ~= nil then
            pcall(function()
                effect.Enabled = originalEnabled == true
            end)
        end
    end
    if effect:IsA("UIGradient") and effect:GetAttribute("SaltHubHadOriginalGradientState") == true then
        local originalOffset = effect:GetAttribute("SaltHubOriginalGradientOffset")
        local originalRotation = effect:GetAttribute("SaltHubOriginalGradientRotation")
        if originalOffset ~= nil then
            pcall(function()
                effect.Offset = originalOffset
            end)
        end
        if originalRotation ~= nil then
            pcall(function()
                effect.Rotation = originalRotation
            end)
        end
    end
    effect:SetAttribute("SaltHubFrozenVisualEffect", false)
    return true
end

function Feature.getNativePreviewMode()
    local mode = tostring(Config.safety.nativePreviewMode or "Static")
    local normalized = normalizeText(mode)
    if normalized == "hide" or normalized == "hidden" or normalized == "ultra low" or normalized == "ultralow" then
        return "Hide"
    end
    return "Static"
end

function Feature.setNativePreviewMode(mode)
    local normalized = normalizeText(mode)
    Config.safety.nativePreviewMode = (normalized == "hide" or normalized == "hidden" or normalized == "ultra low" or normalized == "ultralow") and "Hide" or "Static"
    Feature.optimizeNativeMenuPreviews(Config.safety.nativePreviewBatch)
    Log.push("Native preview mode: " .. Config.safety.nativePreviewMode)
end

function Feature.restoreNativePreviewVisibility(viewport)
    if not viewport or not viewport:IsA("ViewportFrame") then
        return
    end

    if viewport:GetAttribute("SaltHubHadOriginalVisible") == true then
        local originalVisible = viewport:GetAttribute("SaltHubOriginalVisible")
        if originalVisible ~= nil then
            pcall(function()
                viewport.Visible = originalVisible == true
            end)
        end
    end
end

function Feature.hideNativePreviewViewport(viewport)
    if not viewport or not viewport:IsA("ViewportFrame") then
        return false
    end

    if viewport:GetAttribute("SaltHubHadOriginalVisible") ~= true then
        viewport:SetAttribute("SaltHubHadOriginalVisible", true)
        viewport:SetAttribute("SaltHubOriginalVisible", viewport.Visible == true)
    end

    viewport:SetAttribute("SaltHubStaticPreview", true)
    viewport:SetAttribute("SaltHubHiddenPreview", true)
    pcall(function()
        viewport.Visible = false
    end)

    return true
end

function Feature.freezeNativePreviewViewport(viewport)
    if not Config.flags.optimizeNativeMenus or not viewport or not viewport:IsA("ViewportFrame") then
        return false
    end

    if Feature.getNativePreviewMode() == "Hide" then
        return Feature.hideNativePreviewViewport(viewport)
    end

    Feature.restoreNativePreviewVisibility(viewport)
    viewport:SetAttribute("SaltHubHiddenPreview", false)

    local worldModel = viewport:FindFirstChild("WorldModel")
    if not worldModel then
        return false
    end

    viewport:SetAttribute("SaltHubStaticPreview", true)
    for _, descendant in ipairs(worldModel:GetDescendants()) do
        if descendant:IsA("LocalScript") then
            if descendant:GetAttribute("SaltHubHadOriginalScriptDisabled") ~= true then
                descendant:SetAttribute("SaltHubHadOriginalScriptDisabled", true)
                descendant:SetAttribute("SaltHubOriginalScriptDisabled", descendant.Disabled == true)
            end
            pcall(function()
                descendant.Disabled = true
            end)
        elseif descendant:IsA("BasePart") then
            if descendant:GetAttribute("SaltHubHadOriginalPartAnchored") ~= true then
                descendant:SetAttribute("SaltHubHadOriginalPartAnchored", true)
                descendant:SetAttribute("SaltHubOriginalPartAnchored", descendant.Anchored == true)
            end
            pcall(function()
                descendant.Anchored = true
            end)
        elseif Feature.isNativeVisualEffect(descendant) then
            Feature.freezeNativeVisualEffect(descendant)
        elseif descendant:IsA("Humanoid") or descendant:IsA("Animator") or descendant:IsA("AnimationController") then
            Feature.stopNativePreviewTracks(descendant)
        end
    end

    return true
end

function Feature.queueNativePreviewViewport(viewport)
    if viewport and viewport:IsA("ViewportFrame") then
        Feature.nativeMenuQueuedViewports[viewport] = true
    end
end

function Feature.queueNativeVisualEffect(effect)
    if not Feature.isNativeVisualEffect(effect) then
        return
    end

    if effect:IsA("UIGradient") then
        local enabledOk, enabled = pcall(function()
            return effect.Enabled
        end)
        if effect:GetAttribute("SaltHubFrozenVisualEffect") ~= true or (enabledOk and enabled == false) then
            Feature.nativeMenuQueuedVisualEffects[effect] = true
        end
        return
    end

    if effect:GetAttribute("SaltHubFrozenVisualEffect") ~= true then
        Feature.nativeMenuQueuedVisualEffects[effect] = true
    end
end

function Feature.inspectNativeMenuDescendant(descendant)
    if not descendant then
        return
    end

    if descendant:IsA("ViewportFrame") then
        Feature.queueNativePreviewViewport(descendant)
    elseif descendant:IsA("WorldModel") and descendant.Parent and descendant.Parent:IsA("ViewportFrame") then
        Feature.queueNativePreviewViewport(descendant.Parent)
    end

    if Feature.isNativeVisualEffect(descendant) then
        Feature.queueNativeVisualEffect(descendant)
    end
end

function Feature.queueNativeRootScan(Root)
    if not Root then
        return
    end

    local pending = Feature.nativeMenuQueuedRootScans[Root]
    if pending and pending.root == Root then
        return
    end

    Feature.nativeMenuQueuedRootScans[Root] = {
        root = Root,
        stack = { Root },
    }
end

function Feature.queueNativeMenuRoot(Root)
    if not Root then
        return
    end

    Feature.queueNativeRootScan(Root)
end

function Feature.queueNativeVisualEffectRoot(Root)
    if not Root then
        return
    end

    for _, descendant in ipairs(Root:GetDescendants()) do
        if Feature.isNativeVisualEffect(descendant) then
            Feature.queueNativeVisualEffect(descendant)
        end
    end
end

function Feature.attachNativeMenuRoot(Root)
    if not Root or Feature.nativeMenuRootConnections[Root] then
        return
    end

    Feature.queueNativeRootScan(Root)
    Feature.nativeMenuRootConnections[Root] = true
end

function Feature.attachNativeVisualEffectRoot(Root)
    if not Root or Feature.nativeVisualEffectRootConnections[Root] then
        return
    end

    Feature.queueNativeRootScan(Root)
    Feature.nativeVisualEffectRootConnections[Root] = true
end

function Feature.refreshNativeMenuOptimizerRoots()
    for _, root in ipairs(Feature.getNativeMenuRoots()) do
        Feature.attachNativeMenuRoot(root)
    end
    for _, root in ipairs(Feature.getNativeVisualEffectRoots()) do
        Feature.attachNativeVisualEffectRoot(root)
    end
end

function Feature.isNativeMenuOpen()
    local frames = Feature.getNativeMenuFrameRoot()
    if not frames then
        return false
    end

    for _, name in ipairs(Feature.getNativeMenuRootNames()) do
        local root = frames:FindFirstChild(name)
        if root and root:IsA("GuiObject") and root.Visible == true then
            return true
        end
    end
    return false
end

function Feature.setSaltHubUiSuspendedForNativeMenu(suspended)
    if not UI.root or not UI.root.Parent then
        return false
    end

    if suspended == true then
        if Feature.nativeMenuUiSuspended then
            return true
        end
        Feature.nativeMenuUiSuspended = true
        Feature.nativeMenuUiWasVisible = UI.root.Visible == true
        UI.root.Visible = false
        UI.setGlassEnabled(false)
        return true
    end

    if not Feature.nativeMenuUiSuspended then
        return false
    end
    Feature.nativeMenuUiSuspended = false
    UI.root.Visible = Feature.nativeMenuUiWasVisible ~= false
    Feature.nativeMenuUiWasVisible = nil
    UI.setGlassEnabled(UI.root.Visible == true)
    return true
end

function Feature.attachNativeMenuOpenGuard()
    if Feature.nativeMenuOpenGuardConnection then
        return
    end

    local lastRefresh = 0
    local function attachButton(button)
        if not button or Feature.nativeMenuOpenGuardConnections[button] then
            return
        end

        local connection = button.MouseButton1Down:Connect(function()
            Feature.setSaltHubUiSuspendedForNativeMenu(true)
        end)
        Feature.nativeMenuOpenGuardConnections[button] = connection
        Maid:add(connection)
    end

    local function refreshButtons()
        local frames = Feature.getNativeMenuFrameRoot()
        if not frames then
            return
        end

        for _, group in ipairs({
            frames:FindFirstChild("UILeft"),
            frames:FindFirstChild("UIRight"),
        }) do
            if group then
                for _, descendant in ipairs(group:GetDescendants()) do
                    if descendant:IsA("ImageButton") or descendant:IsA("TextButton") then
                        attachButton(descendant)
                    end
                end
            end
        end
    end

    Feature.nativeMenuOpenGuardConnection = RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - lastRefresh >= 2 then
            lastRefresh = now
            refreshButtons()
        end

        if Feature.nativeMenuUiSuspended and not Feature.isNativeMenuOpen() then
            Feature.setSaltHubUiSuspendedForNativeMenu(false)
        end
    end)
    Maid:add(Feature.nativeMenuOpenGuardConnection)
    refreshButtons()
end

function Feature.pauseMergeForNativeMenu(now)
    if not Feature.isNativeMenuOpen() then
        return false
    end

    now = tonumber(now) or os.clock()
    State.autoMergeIdleUntil = math.max(State.autoMergeIdleUntil or 0, now + 1)
    if now - (State.lastNativeMenuPauseLogAt or 0) >= 5 then
        State.lastNativeMenuPauseLogAt = now
        Log.push("Auto merge paused while a native menu is open.")
    end
    return true
end

function Feature.processNativeRootScanQueue(limit)
    local budget = math.max(tonumber(limit) or Config.safety.nativeRootScanBatch or 96, 1)
    local processed = 0

    for root, scan in pairs(Feature.nativeMenuQueuedRootScans) do
        if not root or not root.Parent or type(scan) ~= "table" or scan.root ~= root or type(scan.stack) ~= "table" then
            Feature.nativeMenuQueuedRootScans[root] = nil
            continue
        end

        while processed < budget do
            local node = table.remove(scan.stack)
            if not node then
                Feature.nativeMenuQueuedRootScans[root] = nil
                break
            end

            if node ~= root then
                Feature.inspectNativeMenuDescendant(node)
            end

            local ok, children = pcall(function()
                return node:GetChildren()
            end)
            if ok and type(children) == "table" then
                for index = #children, 1, -1 do
                    table.insert(scan.stack, children[index])
                end
            end

            processed += 1
        end

        if processed >= budget then
            break
        end
    end

    return processed
end

function Feature.processNativePreviewQueue(limit)
    local budget = math.max(tonumber(limit) or Config.safety.nativePreviewBatch or 12, 1)
    local processed = 0

    for viewport in pairs(Feature.nativeMenuQueuedViewports) do
        Feature.nativeMenuQueuedViewports[viewport] = nil
        if viewport and viewport.Parent then
            Feature.freezeNativePreviewViewport(viewport)
        end
        processed += 1
        if processed >= budget then
            break
        end
    end

    return processed
end

function Feature.processNativeVisualEffectQueue(limit)
    local budget = math.max(tonumber(limit) or Config.safety.nativeVisualEffectBatch or 256, 1)
    local processed = 0

    for effect in pairs(Feature.nativeMenuQueuedVisualEffects) do
        Feature.nativeMenuQueuedVisualEffects[effect] = nil
        if effect and effect.Parent then
            Feature.freezeNativeVisualEffect(effect)
        end
        processed += 1
        if processed >= budget then
            break
        end
    end

    return processed
end

function Feature.optimizeNativeMenuPreviews(limit)
    if not Config.flags.optimizeNativeMenus then
        return 0
    end

    Feature.refreshNativeMenuOptimizerRoots()
    return Feature.processNativeRootScanQueue(Config.safety.nativeRootScanBatch)
        + Feature.processNativePreviewQueue(limit)
        + Feature.processNativeVisualEffectQueue(Config.safety.nativeVisualEffectBatch)
end

function Feature.attachNativeMenuOptimizer()
    if Feature.nativeMenuOptimizerConnection then
        return
    end

    local lastRootRefresh = 0
    Feature.nativeMenuOptimizerConnection = RunService.Heartbeat:Connect(function()
        if not Config.flags.optimizeNativeMenus then
            return
        end

        local now = os.clock()
        if now - lastRootRefresh >= 5 then
            lastRootRefresh = now
            Feature.refreshNativeMenuOptimizerRoots()
        end

        Feature.processNativeRootScanQueue(Config.safety.nativeRootScanBatch)
        Feature.processNativePreviewQueue(Config.safety.nativePreviewBatch)
        Feature.processNativeVisualEffectQueue(Config.safety.nativeVisualEffectBatch)
    end)
    Maid:add(Feature.nativeMenuOptimizerConnection)
    Feature.optimizeNativeMenuPreviews(Config.safety.nativePreviewBatch)
end

function Feature.restoreNativeMenuOptimizerMutations()
    Feature.nativeMenuQueuedRootScans = {}
    Feature.nativeMenuQueuedViewports = {}
    Feature.nativeMenuQueuedVisualEffects = {}
    Feature.setSaltHubUiSuspendedForNativeMenu(false)

    for _, root in ipairs(Feature.getNativeMenuRoots()) do
        if root and root.Parent then
            for _, descendant in ipairs(root:GetDescendants()) do
                if descendant:IsA("ViewportFrame") then
                    Feature.restoreNativePreviewVisibility(descendant)
                    descendant:SetAttribute("SaltHubStaticPreview", false)
                    descendant:SetAttribute("SaltHubHiddenPreview", false)
                elseif descendant:IsA("LocalScript") and descendant:GetAttribute("SaltHubHadOriginalScriptDisabled") == true then
                    local originalDisabled = descendant:GetAttribute("SaltHubOriginalScriptDisabled")
                    if originalDisabled ~= nil then
                        pcall(function()
                            descendant.Disabled = originalDisabled == true
                        end)
                    end
                elseif descendant:IsA("BasePart") and descendant:GetAttribute("SaltHubHadOriginalPartAnchored") == true then
                    local originalAnchored = descendant:GetAttribute("SaltHubOriginalPartAnchored")
                    if originalAnchored ~= nil then
                        pcall(function()
                            descendant.Anchored = originalAnchored == true
                        end)
                    end
                elseif Feature.isNativeVisualEffect(descendant) then
                    Feature.restoreNativeVisualEffect(descendant)
                end
            end
        end
    end

    for _, root in ipairs(Feature.getNativeVisualEffectRoots()) do
        if root and root.Parent then
            for _, descendant in ipairs(root:GetDescendants()) do
                if Feature.isNativeVisualEffect(descendant) then
                    Feature.restoreNativeVisualEffect(descendant)
                end
            end
        end
    end
end

function Feature.setNativeMenuOptimizerEnabled(value)
    Config.flags.optimizeNativeMenus = value == true
    if Config.flags.optimizeNativeMenus then
        Feature.attachNativeMenuOptimizer()
        Feature.optimizeNativeMenuPreviews(Config.safety.nativePreviewBatch)
        Log.push("Native menu optimizer enabled.")
    else
        Feature.restoreNativeMenuOptimizerMutations()
        Log.push("Native menu optimizer disabled.")
    end
end

function Feature.getDataClient()
    Feature.dataClient = State.getDataClient()
    return Feature.dataClient
end

function Feature.dataGet(path, fallback)
    local client = Feature.getDataClient()
    if not client or not client.get then
        return fallback
    end
    local ok, value = pcall(function()
        return client:get(path)
    end)
    if ok and value ~= nil then
        return value
    end
    return fallback
end

function Feature.getTraitMap()
    local client = Feature.getDataClient()
    if not client or not client.get then
        return {}
    end

    local ok, traits = pcall(function()
        return client:get("Traits")
    end)
    if ok and type(traits) == "table" then
        return traits
    end
    return {}
end

function Feature.getItemQuantityByName(itemName)
    local target = normalizeText(itemName)
    if target == "" then
        return 0
    end

    local items = Feature.dataGet("Items", {})
    if type(items) ~= "table" then
        return 0
    end
    for _, item in pairs(items) do
        if type(item) == "table" and normalizeText(item.Name or item.ItemName or item.ID) == target then
            return tonumber(item.Quantity or item.Quanity or item.Amount or item.Count or item.Value) or 0
        end
    end
    return 0
end

function Feature.getTraitShardAmount()
    return Feature.getItemQuantityByName("Trait Shard")
end

function Feature.getSelectedTraitUnit()
    State.scanUnits()
    local traitMap = Feature.getTraitMap()
    local unit = State.getUnitById(Config.trait.selectedUnitId) or State.findUnitByName(Config.trait.selectedUnitName)
    if not unit then
        return nil
    end
    unit.trait = traitForCharacter(traitMap, unit.id, unit.trait)
    return unit
end

function Feature.isTraitUnitBusy(unit)
    if not unit or not unit.id or unit.id == "" then
        return true
    end

    local client = Feature.getDataClient()
    if not client or not client.get then
        return false
    end

    local ok, cloning = pcall(function()
        return client:get("Cloning")
    end)
    if not ok or type(cloning) ~= "table" then
        return false
    end

    for _, entry in pairs(cloning) do
        if type(entry) == "table" and tostring(entry.CharacterId or entry.CharacterID or "") == tostring(unit.id) then
            return true
        end
    end
    return false
end

function Feature.shouldUseConfirmedTraitRoll(unit)
    local trait = normalizeText(unit and unit.trait)
    if trait == "" or trait == "none" or trait == "no trait" then
        return false
    end
    return not textEqualsAny(unit.trait, Config.trait.targetTraits)
end

function Feature.requestTraitRoll(unit)
    if not unit or not unit.id or unit.id == "" then
        return false
    end

    local action = Feature.shouldUseConfirmedTraitRoll(unit) and "ConfirmedRoll" or "Roll"
    return Remote.fire("TraitRequest", action, { CharacterId = unit.id })
end

function Feature.pushTraitStatus(message)
    if os.clock() - (State.lastTraitLogAt or 0) < 3 then
        return
    end
    State.lastTraitLogAt = os.clock()
    Log.push(message)
end

function Feature.stopAutoTraitNoShards()
    Config.flags.autoTrait = false
    Feature.stopLoop("autoTrait")
    Log.push("Auto Trait Reroll stopped: no Trait Shards.")
end

function Feature.autoTraitStep()
    if not listHasItems(Config.trait.targetTraits) then
        Feature.pushTraitStatus("Select at least one stop trait first.")
        return
    end

    local unit = Feature.getSelectedTraitUnit()
    if not unit then
        Feature.pushTraitStatus("Select a unit for trait rerolling.")
        return
    end

    if Config.trait.stopWhenMatched and textEqualsAny(unit.trait, Config.trait.targetTraits) then
        Config.flags.autoTrait = false
        Feature.stopLoop("autoTrait")
        Log.push("Trait matched: " .. unit.name .. " -> " .. unit.trait)
        Feature.notifyRareWebhook({
            kind = "Rare Trait Rolled",
            source = "Trait Reroll",
            name = unit.name,
            mutation = unit.mutation,
            trait = unit.trait,
            rarity = Feature.getWebhookCharacterRarity(unit.name),
            id = unit.id,
        })
        return
    end

    if Feature.isTraitUnitBusy(unit) then
        Feature.pushTraitStatus("Trait reroll paused: selected unit is busy.")
        return
    end

    if Feature.getTraitShardAmount() <= 0 then
        Feature.stopAutoTraitNoShards()
        return
    end

    Feature.requestTraitRoll(unit)
    task.wait(0.15)
    State.scanUnits()
    if Feature.getTraitShardAmount() <= 0 then
        Feature.stopAutoTraitNoShards()
    end
end

function Feature.getPlayerCash()
    return tonumber(Feature.dataGet("Cash", 0)) or 0
end

function Feature.getUpgradeInfo()
    if Feature.upgradeInfo then
        return Feature.upgradeInfo
    end
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    local shared = modules and modules:FindFirstChild("Shared")
    Feature.upgradeInfo = DataSource.safeRequire(shared and shared:FindFirstChild("UpgradesInfo"), 1)
    return Feature.upgradeInfo
end

function Feature.getUpgradeLevel(name)
    local level = tonumber(Feature.dataGet({ "Upgrades", name }, nil)) or 1
    State.upgrades[name] = level
    return level
end

function Feature.getUpgradeCost(name)
    local info = Feature.getUpgradeInfo()
    if not info or not info.GetPrice then
        return nil
    end
    local ok, cost = pcall(function()
        return info.GetPrice(name, Feature.getUpgradeLevel(name))
    end)
    if ok then
        return tonumber(cost)
    end
    return nil
end

function Feature.isUpgradeMaxed(name)
    local info = Feature.getUpgradeInfo()
    local maxTable = info and info.Upgrades and info.Upgrades.MaxUpgrades
    local max = maxTable and tonumber(maxTable[name])
    if not max then
        return false
    end
    if name == "Grid" then
        max += 1
    end
    return Feature.getUpgradeLevel(name) >= max
end

function Feature.getNextAffordableUpgrade()
    local cash = Feature.getPlayerCash()
    for _, name in ipairs(Config.upgrade.upgradePriority) do
        if Config.upgrade.selected[name] and not Feature.isUpgradeMaxed(name) then
            local cost = Feature.getUpgradeCost(name)
            if cost and cash >= cost then
                return {
                    name = name,
                    cost = cost,
                    cash = cash,
                    level = Feature.getUpgradeLevel(name),
                }
            end
        end
    end
    return nil
end

function Feature.buyUpgrade(name)
    if not name then
        return false
    end
    return Remote.fire("Upgrade", "Cash", name)
end

function Feature.autoUpgradeStep()
    local nextUpgrade = Feature.getNextAffordableUpgrade()
    if nextUpgrade then
        State.upgradeStatus = "Buying " .. nextUpgrade.name .. " L" .. tostring(nextUpgrade.level) .. " for $" .. tostring(nextUpgrade.cost)
        Feature.buyUpgrade(nextUpgrade.name)
        return true
    end

    local cash = Feature.getPlayerCash()
    local lines = { "Cash: $" .. tostring(cash), "Next: waiting for affordable selected upgrade" }
    for _, name in ipairs(Config.upgrade.upgradePriority) do
        local cost = Feature.getUpgradeCost(name)
        local level = Feature.getUpgradeLevel(name)
        local state = Feature.isUpgradeMaxed(name) and "MAX" or ("$" .. tostring(cost or "?"))
        table.insert(lines, name .. ": L" .. tostring(level) .. " | " .. state)
    end
    State.upgradeStatus = table.concat(lines, "\n")
    return false
end

function Feature.refreshUpgradeStatus()
    local cash = Feature.getPlayerCash()
    local nextUpgrade = Feature.getNextAffordableUpgrade()
    local lines = { "Cash: $" .. tostring(cash) }
    if nextUpgrade then
        table.insert(lines, "Next: " .. nextUpgrade.name .. " for $" .. tostring(nextUpgrade.cost))
    else
        table.insert(lines, "Next: waiting for affordable selected upgrade")
    end
    for _, name in ipairs(Config.upgrade.upgradePriority) do
        local cost = Feature.getUpgradeCost(name)
        local level = Feature.getUpgradeLevel(name)
        local state = Feature.isUpgradeMaxed(name) and "MAX" or ("$" .. tostring(cost or "?"))
        table.insert(lines, name .. ": L" .. tostring(level) .. " | " .. state)
    end
    State.upgradeStatus = table.concat(lines, "\n")
    return State.upgradeStatus
end

function Feature.describeUpgradeStatus()
    return Feature.refreshUpgradeStatus()
end

function Feature.applyAutoRollSettingsLocal()
    Config.roll.targetUnits = uniqueSorted(Config.roll.targetUnits)
    Config.roll.targetMutations = uniqueSorted(Config.roll.targetMutations)
    Config.roll.unitMutationTargets = normalizeUnitMutationTargets(Config.roll.unitMutationTargets)
    Config.roll.snipeEvents = uniqueSorted(Config.roll.snipeEvents)
    State.cachedSelectedEventActive = false
    State.lastSelectedEventScanAt = 0
    Log.push("Auto Roll filters saved locally.")
end

function Feature.pushAutoRollSettings()
    Feature.applyAutoRollSettingsLocal()
    return true
end

function Feature.getCharacterRoot()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
end

function Feature.getOwnedPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        return nil
    end

    for _, plot in ipairs(plots:GetChildren()) do
        local owner = plot:GetAttribute("Owner")
        if tostring(owner) == LocalPlayer.Name then
            return plot
        end
    end

    local root = Feature.getCharacterRoot()
    local closestPlot = nil
    local closestDistance = math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        local rollPrompt = plot:FindFirstChild("RollPrompt", true)
        local promptPart = rollPrompt and rollPrompt.Parent
        if root and promptPart and promptPart:IsA("BasePart") then
            local distance = (root.Position - promptPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlot = plot
            end
        end
    end
    return closestPlot
end

function Feature.getWaveUiStartRoot()
    local mainUi = PlayerGui and PlayerGui:FindFirstChild("MainUI")
    local uiTop = mainUi and mainUi:FindFirstChild("UITop")
    return uiTop and uiTop:FindFirstChild("Start")
end

function Feature.isWaveUiStarted()
    local startRoot = Feature.getWaveUiStartRoot()
    if not startRoot then
        return false
    end

    local startButton = startRoot:FindFirstChild("Start")
    local label = startButton and startButton:FindFirstChild("TextLabel", true)
    if label and label:IsA("TextLabel") and textMatchesAny(label.Text, { "Stop" }) then
        return true
    end

    local waveFrame = startRoot:FindFirstChild("Wave")
    if waveFrame and waveFrame:IsA("GuiObject") and waveFrame.Visible then
        return true
    end

    return false
end

function Feature.isWaveStarted()
    local plot = Feature.getOwnedPlot()
    if plot and plot:GetAttribute("WaveStarted") == true then
        return true
    end

    return Feature.isWaveUiStarted()
end

function Feature.shouldPauseWaveStartForAutoBuy()
    if Config.flags.autoBuy ~= true then
        return false
    end
    if State.buyingCharacter or State.pendingBuy then
        return true
    end
    return Feature.findMatchingRolledCharacter() ~= nil
end

function Feature.shouldStartWave()
    local plot = Feature.getOwnedPlot()
    if not plot or Feature.isWaveStarted() then
        return false
    end
    if Feature.shouldPauseWaveStartForAutoBuy() then
        return false
    end

    local startCooldown = math.max(tonumber(Config.delays.wave) or 0, 2.5)
    return os.clock() - (State.lastWaveStartAt or 0) >= startCooldown
end

local WAVE_CHECKPOINTS = { 0, 25, 50, 75, 100, 125, 150, 175, 200 }

function Feature.getWaveCheckpointFromWave(wave)
    local highestWave = tonumber(wave) or 0
    local target = 0
    for _, checkpoint in ipairs(WAVE_CHECKPOINTS) do
        if highestWave >= checkpoint then
            target = checkpoint
        end
    end
    return target
end

function Feature.getHighestWaveCheckpoint()
    local highestWave = tonumber(Feature.dataGet("HighestWave", nil))
        or tonumber(LocalPlayer:GetAttribute("HighestWave"))
        or tonumber(Feature.dataGet("MaxWave", nil))
        or 0
    return Feature.getWaveCheckpointFromWave(highestWave)
end

function Feature.getSelectedWaveCheckpoint()
    local selected = tonumber(Feature.dataGet({ "Settings", "Checkpoint" }, nil))
    if selected ~= nil then
        return selected
    end

    selected = tonumber(LocalPlayer:GetAttribute("Checkpoint"))
    if selected ~= nil then
        return selected
    end

    local main = PlayerGui:FindFirstChild("MainUI")
    local top = main and main:FindFirstChild("UITop")
    local checkpointFrame = top and top:FindFirstChild("Checkpoint")
    local checkpoint = checkpointFrame and checkpointFrame:FindFirstChild("Checkpoint")
    local status = checkpoint and checkpoint:FindFirstChild("Status")
    if status and (status:IsA("TextLabel") or status:IsA("TextButton")) then
        return tonumber(status.Text)
    end
    return nil
end

function Feature.ensureHighestWaveCheckpoint()
    local target = Feature.getHighestWaveCheckpoint()
    local selected = Feature.getSelectedWaveCheckpoint()
    if selected == target then
        return true
    end
    if selected == nil and target <= 0 then
        return true
    end

    if os.clock() - (State.lastCheckpointSelectAt or 0) < math.max(Config.safety.remoteCooldown, 0.35) then
        return false
    end

    State.lastCheckpointSelectAt = os.clock()
    Log.push("Selecting wave checkpoint " .. tostring(target) .. " (current " .. tostring(selected) .. ").")
    Remote.fire("Checkpoint")
    return false
end

function Feature.shouldPauseWaveStartForShenron()
    if Config.flags.autoShenron ~= true then
        return false
    end
    if not Feature.isSuperShenronEventActive() then
        return false
    end

    local wishName = Feature.getBestShenronWish()
    if not Feature.isShenronDoombringerWish(wishName) then
        return false
    end

    State.shenronStatus = "Auto Start Wave paused for Doombringer wish prep."
    return true
end

function Feature.autoStartWaveStep()
    if Feature.shouldPauseWaveStartForBoorus() then
        return
    end
    if Feature.shouldPauseWaveStartForShenron() then
        return
    end

    if not Feature.shouldStartWave() then
        return
    end

    if Config.wave.startHighest ~= false and not Feature.ensureHighestWaveCheckpoint() then
        return
    end

    State.lastWaveStartAt = os.clock()
    Remote.fire("StartWave")
end

function Feature.setAutoStartWave(value)
    Config.flags.autoStartWave = value
    if value then
        Feature.startLoop("autoStartWave", function()
            return Config.delays.wave
        end, Feature.autoStartWaveStep)
    else
        Feature.stopLoop("autoStartWave")
    end
end

function Feature.fireFastForward(source)
    if not Feature.isWaveStarted() then
        return false
    end
    if Feature.shouldPauseWaveStartForShenron() then
        return false
    end

    local value = tostring(Config.wave.fastForward or "x2")
    local now = os.clock()
    local interval = math.max(tonumber(Config.delays.fastForwardPulse) or 10.0, 3.0)
    if State.lastFastForwardValue == value and now - (State.lastFastForwardAt or 0) < interval then
        return false
    end

    State.lastFastForwardAt = now
    State.lastFastForwardValue = value
    return Remote.fire("FastForward", value)
end

function Feature.setAutoFastForward(value)
    Config.flags.autoFastForward = value
    if value then
        Feature.startLoop("autoFastForward", function()
            return math.max(tonumber(Config.delays.fastForwardPulse) or 10.0, 3.0)
        end, function()
            Feature.fireFastForward("auto")
        end)
    else
        Feature.stopLoop("autoFastForward")
    end
end

function Feature.isWebhookUrlValid(url)
    local text = tostring(url or "")
    return text:match("^https://") ~= nil and text:find("/api/webhooks/", 1, true) ~= nil
end

function Feature.getWebhookRequestFunction()
    if type(request) == "function" then
        return request, "request"
    end

    local synTable = syn
    if type(synTable) == "table" and type(synTable.request) == "function" then
        return synTable.request, "syn.request"
    end

    if type(http_request) == "function" then
        return http_request, "http_request"
    end

    local httpTable = http
    if type(httpTable) == "table" and type(httpTable.request) == "function" then
        return httpTable.request, "http.request"
    end

    return nil, "unavailable"
end

function Feature.getWebhookExecuteUrl()
    local url = tostring(Config.webhook.url or "")
    if not Feature.isWebhookUrlValid(url) then
        return nil
    end
    if url:find("wait=", 1, true) then
        return url
    end
    return url .. (url:find("?", 1, true) and "&wait=true" or "?wait=true")
end

function Feature.readWebhookRetryAfter(response)
    if type(response) ~= "table" then
        return nil
    end

    local headers = response.Headers or response.headers
    if type(headers) == "table" then
        local value = headers["Retry-After"] or headers["retry-after"] or headers["retry_after"]
        if tonumber(value) then
            return tonumber(value)
        end
    end

    local body = response.Body or response.body
    if type(body) == "string" and body ~= "" then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(body)
        end)
        if ok and type(decoded) == "table" and tonumber(decoded.retry_after) then
            return tonumber(decoded.retry_after)
        end
    end
    return nil
end

function Feature.sendWebhookPayload(payload)
    State.webhookLastFailureRetry = false
    local url = Feature.getWebhookExecuteUrl()
    if not url then
        State.webhookStatus = "Webhook URL missing or invalid."
        Log.push(State.webhookStatus)
        return false
    end

    local requestFunction, requestName = Feature.getWebhookRequestFunction()
    if not requestFunction then
        State.webhookStatus = "No executor HTTP request function available."
        Log.push(State.webhookStatus)
        return false
    end

    local requestPayload = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
        },
        Body = HttpService:JSONEncode(payload),
    }
    local ok, response = pcall(requestFunction, requestPayload)
    if not ok then
        State.webhookStatus = "Webhook send failed through " .. tostring(requestName) .. "."
        Log.push(State.webhookStatus)
        return false
    end

    local statusCode = 204
    if type(response) == "table" then
        statusCode = tonumber(response.StatusCode or response.status_code or response.Status or response.status) or statusCode
    end
    if statusCode == 429 then
        local retryAfter = math.max(tonumber(Feature.readWebhookRetryAfter(response)) or 5, 1)
        State.webhookBackoffUntil = os.clock() + retryAfter
        State.webhookLastFailureRetry = true
        State.webhookStatus = "Discord rate limited webhook; retrying after " .. tostring(math.ceil(retryAfter)) .. "s."
        Log.push(State.webhookStatus)
        return false
    end
    if statusCode < 200 or statusCode >= 300 then
        State.webhookStatus = "Webhook rejected with HTTP " .. tostring(statusCode) .. "."
        Log.push(State.webhookStatus)
        return false
    end

    State.webhookStatus = "Webhook sent through " .. tostring(requestName) .. "."
    return true
end

function Feature.webhookTextMatchesAny(text, values)
    local valueText = tostring(text or "")
    if valueText == "" then
        return false
    end
    return textMatchesAny(valueText, values or {})
end

function Feature.webhookTextEqualsAny(text, values)
    local clean = normalizedLookupKey(text)
    if clean == "" then
        return false
    end
    for _, value in ipairs(values or {}) do
        if clean == normalizedLookupKey(value) then
            return true
        end
    end
    return false
end

function Feature.getWebhookCharacterRarity(name)
    local static = Feature.getCharacterStaticInfo(name)
    return tostring((static and static.rarity) or State.characterRarity[tostring(name or "")] or "")
end

function Feature.normalizeWebhookConfig()
    Config.webhook = Config.webhook or {}
    Config.webhook.superShenronMutationNames = uniqueSorted(Config.webhook.superShenronMutationNames or { "SuperShenron", "Super Shenron" })
    Config.webhook.superShenronMutationMinRarity = tostring(Config.webhook.superShenronMutationMinRarity or "Secret")
    if Config.webhook.superShenronMutationMinRarity == "" then
        Config.webhook.superShenronMutationMinRarity = "Secret"
    end

    local rareMutations = {}
    for _, mutation in ipairs(Config.webhook.rareMutations or {}) do
        if not Feature.webhookTextEqualsAny(mutation, Config.webhook.superShenronMutationNames) then
            table.insert(rareMutations, tostring(mutation))
        end
    end
    Config.webhook.rareMutations = uniqueSorted(rareMutations)
    local rareRewards = {}
    for _, reward in ipairs(Config.webhook.rareRewards or {}) do
        if not Feature.webhookTextEqualsAny(reward, Config.webhook.superShenronMutationNames) then
            table.insert(rareRewards, tostring(reward))
        end
    end
    Config.webhook.rareRewards = uniqueSorted(rareRewards)
    Config.webhook.rollNotifyUnits = uniqueSorted(Config.webhook.rollNotifyUnits or {})
    Config.webhook.rollNotifyMutations = uniqueSorted(Config.webhook.rollNotifyMutations or {})
end

function Feature.isWebhookConfiguredForUi()
    return Config.webhook.enabled == true and Feature.isWebhookUrlValid(Config.webhook.url)
end

function Feature.webhookListContains(listName, value)
    Feature.normalizeWebhookConfig()
    return Feature.webhookTextEqualsAny(value, Config.webhook[listName] or {})
end

function Feature.setWebhookListValue(listName, value, enabled)
    Feature.normalizeWebhookConfig()
    local text = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then
        return false
    end

    local key = normalizedLookupKey(text)
    local out = {}
    for _, item in ipairs(Config.webhook[listName] or {}) do
        local itemText = tostring(item or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if itemText ~= "" and normalizedLookupKey(itemText) ~= key then
            table.insert(out, itemText)
        end
    end
    if enabled == true then
        table.insert(out, text)
    end

    Config.webhook[listName] = uniqueSorted(out)
    Feature.scheduleConfigSave("webhook:" .. tostring(listName))
    return true
end

function Feature.isWebhookRollUnitNotified(unit)
    return Feature.webhookListContains("rollNotifyUnits", unit)
end

function Feature.setWebhookRollUnitNotification(unit, enabled)
    return Feature.setWebhookListValue("rollNotifyUnits", unit, enabled)
end

function Feature.isWebhookRollMutationNotified(mutation)
    return Feature.webhookListContains("rollNotifyMutations", mutation)
end

function Feature.setWebhookRollMutationNotification(mutation, enabled)
    return Feature.setWebhookListValue("rollNotifyMutations", mutation, enabled)
end

function Feature.isWebhookRarityAtLeast(rarity, minimum)
    local rank = rarityRank(rarity)
    local minimumRank = rarityRank(minimum or "Secret")
    if rank >= 999 or minimumRank >= 999 then
        return false
    end
    return rank <= minimumRank
end

function Feature.isSuperShenronWebhookMutation(mutation)
    Feature.normalizeWebhookConfig()
    return Feature.webhookTextEqualsAny(mutation, Config.webhook.superShenronMutationNames)
end

function Feature.getSuperShenronWebhookReason(mutation, rarity)
    if not Feature.isSuperShenronWebhookMutation(mutation) then
        return nil
    end
    if Feature.isWebhookRarityAtLeast(rarity, Config.webhook.superShenronMutationMinRarity) then
        return "rare mutation: " .. tostring(mutation) .. " (" .. tostring(rarity) .. "+)"
    end
    return nil
end

function Feature.isRollWebhookEvent(event)
    local source = normalizeText(event and event.source)
    local kind = normalizeText(event and event.kind)
    return source == "roll"
        or source == "auto buy"
        or kind == "rare roll"
        or kind == "rare roll bought"
end

function Feature.isBoughtRollWebhookEvent(event)
    local source = normalizeText(event and event.source)
    local kind = normalizeText(event and event.kind)
    return source == "auto buy" or kind == "rare roll bought"
end

function Feature.getRollWatchWebhookReason(event)
    event = type(event) == "table" and event or {}
    if not Feature.isRollWebhookEvent(event) then
        return nil
    end

    local name = tostring(event.name or event.unit or "")
    if Feature.isWebhookRollUnitNotified(name) then
        return "watched roll unit: " .. name
    end

    local mutation = tostring(event.mutation or "")
    if Feature.isSuperShenronWebhookMutation(mutation) then
        local rarity = tostring(event.rarity or Feature.getWebhookCharacterRarity(name))
        if Feature.isWebhookRarityAtLeast(rarity, Config.webhook.superShenronMutationMinRarity) and Feature.isWebhookRollMutationNotified(mutation) then
            return "watched roll mutation: " .. mutation .. " (" .. tostring(rarity) .. "+)"
        end
        return nil
    end

    if Feature.isWebhookRollMutationNotified(mutation) then
        return "watched roll mutation: " .. mutation
    end
    return nil
end

function Feature.describeWebhookPayloadValue(value)
    if type(value) == "table" then
        local preferred = value.NotifyText or value.Reward or value.RewardName or value.Name or value.ItemName
            or value.Trait or value.Mutation or value.Unit or value.Character
        if preferred ~= nil and tostring(preferred) ~= "" then
            return tostring(preferred)
        end
        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(value)
        end)
        if ok then
            return tostring(encoded):sub(1, 240)
        end
        return "table reward"
    end
    return tostring(value or "")
end

function Feature.getWebhookEventKey(event)
    event = type(event) == "table" and event or {}
    return table.concat({
        tostring(event.kind or ""),
        tostring(event.name or ""),
        tostring(event.mutation or ""),
        tostring(event.trait or ""),
        tostring(event.reward or ""),
        tostring(event.slotKey or event.id or ""),
    }, "|")
end

function Feature.getRareWebhookReason(event)
    event = type(event) == "table" and event or {}
    if event.force == true then
        return tostring(event.reason or "test")
    end
    Feature.normalizeWebhookConfig()

    if tostring(event.kind or "") == "Doombringer Granted" then
        local grantedName = tostring(event.name or event.unit or "selected unit")
        if grantedName == "" then
            grantedName = "selected unit"
        end
        return "Doombringer granted to " .. grantedName
    end

    local mutation = tostring(event.mutation or "")
    local name = tostring(event.name or event.unit or "")
    local rarity = tostring(event.rarity or Feature.getWebhookCharacterRarity(name))
    if Feature.isRollWebhookEvent(event) then
        if not Feature.isBoughtRollWebhookEvent(event) then
            return nil
        end

        local rollWatchReason = Feature.getRollWatchWebhookReason(event)
        if rollWatchReason then
            local rollName = name ~= "" and name or "selected roll"
            return "bought roll: " .. rollName
        end
        return nil
    end

    local trait = tostring(event.trait or event.newTrait or "")
    if Feature.webhookTextMatchesAny(trait, Config.webhook.rareTraits) then
        return "rare trait: " .. trait
    end

    local superShenronReason = Feature.getSuperShenronWebhookReason(mutation, rarity)
    if superShenronReason then
        return superShenronReason
    end

    if Feature.webhookTextMatchesAny(mutation, Config.webhook.rareMutations) then
        return "rare mutation: " .. mutation
    end

    if Feature.webhookTextMatchesAny(name, Config.webhook.rareUnits) then
        return "rare unit: " .. name
    end

    if Feature.webhookTextMatchesAny(rarity, Config.webhook.rareRarities) then
        return "rare rarity: " .. rarity
    end

    local reward = Feature.describeWebhookPayloadValue(event.reward or event.details or event.payload)
    if Feature.webhookTextMatchesAny(reward, Config.webhook.rareRewards) then
        return "rare reward: " .. reward
    end

    return nil
end

function Feature.shouldNotifyWebhookEvent(event)
    if type(event) ~= "table" then
        return false
    end
    if not Feature.isWebhookConfiguredForUi() and event.force ~= true then
        return false
    end
    if event.force == true then
        return true
    end
    return Feature.getRareWebhookReason(event) ~= nil
end

function Feature.getRollWebhookTitle(event)
    event = type(event) == "table" and event or {}
    local action = Feature.isBoughtRollWebhookEvent(event) and "Bought" or "Rolled"
    local name = tostring(event.name or event.unit or "")
    if name == "" then
        name = "Unknown"
    end
    return action .. " " .. name
end

function Feature.getRollWebhookDescription(event)
    event = type(event) == "table" and event or {}
    local parts = {}
    local rarity = tostring(event.rarity or Feature.getWebhookCharacterRarity(event.name) or "")
    if rarity ~= "" then
        table.insert(parts, rarity)
    end

    local mutation = tostring(event.mutation or "")
    if mutation ~= "" and normalizeText(mutation) ~= "none" then
        table.insert(parts, mutation)
    end

    local price = Feature.describeWebhookPayloadValue(event.price or event.details or event.reward)
    if price ~= "" then
        table.insert(parts, price)
    end

    if #parts == 0 then
        return nil
    end
    return table.concat(parts, " | ")
end

function Feature.buildWebhookEmbed(event)
    event = type(event) == "table" and event or {}
    local reason = event.reason or Feature.getRareWebhookReason(event) or "rare event"
    local title = tostring(event.kind or "Rare Event")
    local description = tostring(event.description or reason)
    local fields = {}

    local function addField(name, value, inline)
        if value ~= nil and tostring(value) ~= "" then
            table.insert(fields, {
                name = tostring(name),
                value = tostring(value):sub(1, 1024),
                inline = inline == true,
            })
        end
    end

    if Feature.isRollWebhookEvent(event) then
        title = Feature.getRollWebhookTitle(event)
        description = Feature.getRollWebhookDescription(event) or description
    elseif tostring(event.kind or "") == "Doombringer Granted" then
        addField("Unit", event.name or event.unit, true)
        addField("DPS After Trait", event.grantedDps or event.afterTraitDps or event.dps, true)
    else
        addField("Unit", event.name or event.unit, true)
        addField("Mutation", event.mutation, true)
        addField("Trait", event.trait or event.newTrait, true)
        addField("Previous Trait", event.previousTrait, true)
        addField("Rarity", event.rarity or Feature.getWebhookCharacterRarity(event.name), true)
        addField("Reward", Feature.describeWebhookPayloadValue(event.reward), false)
        addField("Source", event.source, true)
        addField("Details", event.details, false)
    end

    local embed = {
        title = title:sub(1, 256),
        description = description:sub(1, 2048),
        color = tonumber(event.color) or 16753920,
        fields = fields,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        footer = {
            text = "SaltHub",
        },
    }

    local payload = {
        username = "SaltHub",
        embeds = { embed },
        allowed_mentions = {
            parse = {},
        },
    }
    if Config.webhook.mentionUser == true then
        payload.content = "Rare SaltHub event for " .. tostring(LocalPlayer.Name)
    end
    return payload
end

function Feature.sendWebhookEventNow(event)
    return Feature.sendWebhookPayload(Feature.buildWebhookEmbed(event))
end

function Feature.queueWebhookEvent(event)
    if not Feature.shouldNotifyWebhookEvent(event) then
        return false
    end

    event.reason = event.reason or Feature.getRareWebhookReason(event)
    local now = os.clock()
    local key = Feature.getWebhookEventKey(event)
    local seenAt = tonumber(State.webhookSeenKeys[key]) or 0
    if seenAt > 0 and now - seenAt < math.max(tonumber(Config.webhook.dedupeWindow) or 90, 5) then
        return false
    end

    State.webhookSeenKeys[key] = now
    table.insert(State.webhookQueue, event)
    State.webhookStatus = "Queued webhook: " .. tostring(event.kind or "Rare Event") .. "."
    return true
end

function Feature.flushWebhookQueue()
    if #State.webhookQueue == 0 then
        return false
    end
    local now = os.clock()
    if now < (tonumber(State.webhookBackoffUntil) or 0) then
        return false
    end
    if now - (tonumber(State.lastWebhookSentAt) or 0) < math.max(tonumber(Config.webhook.minInterval) or 2.5, 0.75) then
        return false
    end

    local event = table.remove(State.webhookQueue, 1)
    if Feature.sendWebhookEventNow(event) then
        State.lastWebhookSentAt = os.clock()
        return true
    end
    if State.webhookLastFailureRetry == true then
        table.insert(State.webhookQueue, 1, event)
    end
    return false
end

function Feature.startWebhookLoop()
    Feature.startLoop("webhook", function()
        return 0.5
    end, Feature.flushWebhookQueue)
end

function Feature.notifyRareWebhook(event)
    local ok, queued = pcall(function()
        return Feature.queueWebhookEvent(event)
    end)
    if not ok then
        State.webhookStatus = "Webhook queue failed."
        Log.push(State.webhookStatus)
        return false
    end
    return queued
end

function Feature.sendTestWebhook()
    local ok = Feature.sendWebhookEventNow({
        kind = "Webhook Test",
        force = true,
        reason = "manual test",
        source = "Webhook tab",
        details = "SaltHub webhook test from " .. tostring(LocalPlayer.Name) .. ".",
        color = 5793266,
    })
    if ok then
        State.webhookStatus = "Test webhook sent."
        Log.push(State.webhookStatus)
    end
    return ok
end

function Feature.describeWebhookStatus()
    local queueCount = #(State.webhookQueue or {})
    local enabled = Config.webhook.enabled == true and "Enabled" or "Disabled"
    local urlStatus = Feature.isWebhookUrlValid(Config.webhook.url) and "URL set" or "URL missing"
    local backoff = math.max(0, math.ceil((tonumber(State.webhookBackoffUntil) or 0) - os.clock()))
    local lines = {
        "State: " .. enabled,
        "URL: " .. urlStatus,
        "Queued: " .. tostring(queueCount),
        "Status: " .. tostring(State.webhookStatus or "-"),
    }
    if backoff > 0 then
        table.insert(lines, "Rate-limit backoff: " .. tostring(backoff) .. "s")
    end
    return table.concat(lines, "\n")
end

function Feature.attachSpinWheelComplete()
    if State.spinWheelCompleteAttached then
        return true
    end

    local remote = Remote.get("SpinWheel")
    if not remote or not remote:IsA("RemoteEvent") then
        return false
    end

    State.spinWheelCompleteAttached = true
    Maid:add(remote.OnClientEvent:Connect(function(payload)
        if type(payload) == "table" and payload.Action == "Result" then
            Feature.notifyRareWebhook({
                kind = "Rare Spin Reward",
                source = "Spin Wheel",
                reward = Feature.describeWebhookPayloadValue(payload),
                payload = payload,
            })
        end
    end))
    return true
end

function Feature.getSpinCount()
    local count = tonumber(Feature.dataGet("Spin", 0)) or 0
    return math.max(0, math.floor(count))
end

function Feature.spinWheelOnce()
    local now = os.clock()
    local busyUntil = tonumber(State.spinBusyUntil) or 0
    if now < busyUntil then
        return false
    end

    local spins = Feature.getSpinCount()
    if spins <= 0 then
        State.spinStatus = "Spin Wheel: 0 spins available."
        return false
    end

    local ok = Remote.fire("SpinWheel", "Spin")
    if ok then
        State.spinBusyUntil = now + 6.5
        State.spinStatus = "Spin Wheel: used 1 spin (" .. tostring(spins) .. " before spin)."
        Log.push(State.spinStatus)
    end
    return ok
end

function Feature.setAutoSpin(value)
    Config.flags.autoSpin = value
    if value then
        Feature.startLoop("autoSpin", function()
            return Config.delays.event
        end, Feature.spinWheelOnce)
    else
        Feature.stopLoop("autoSpin")
    end
end

function Feature.getVipRewardData()
    local data = Feature.dataGet("VIPReward", nil)
    if type(data) == "table" then
        return data
    end
    return {}
end

function Feature.getVipRewardGuiStatus()
    local status = {
        claimVisible = false,
        claimActive = false,
        buttonText = "",
        infoText = "",
        timerText = "",
    }
    local main = PlayerGui:FindFirstChild("MainUI")
    local frames = main and main:FindFirstChild("Frames")
    local vipRewards = frames and frames:FindFirstChild("VIPRewards")
    local vipFrame = vipRewards and vipRewards:FindFirstChild("VIPFrame")
    local buttons = vipFrame and vipFrame:FindFirstChild("Buttons")
    local claim = buttons and buttons:FindFirstChild("Claim")
    local button = claim and claim:FindFirstChild("Button")
    local buttonText = button and button:FindFirstChild("TextLabel")
    local infoText = buttons and buttons:FindFirstChild("TextLabel")
    local monetizations = workspace:FindFirstChild("Monetizations")
    local vipChest = monetizations and monetizations:FindFirstChild("VIP chest")
    local restockGui = vipChest and vipChest:FindFirstChild("RestockGUI")
    local timerLabel = restockGui and restockGui:FindFirstChild("TimerLabel")

    if claim then
        status.claimVisible = claim.Visible == true
        status.claimActive = claim.Active == true
    end
    if buttonText and buttonText:IsA("TextLabel") then
        status.buttonText = tostring(buttonText.Text or "")
    end
    if infoText and infoText:IsA("TextLabel") then
        status.infoText = tostring(infoText.Text or "")
    end
    if timerLabel and timerLabel:IsA("TextLabel") then
        status.timerText = tostring(timerLabel.Text or "")
    end
    return status
end

function Feature.isVipRewardClaimable(data, guiStatus)
    if LocalPlayer:GetAttribute("VIP") ~= true then
        return false
    end
    if type(data) == "table" and data.CanClaim == true then
        return true
    end
    if type(data) == "table" and data.CanClaim ~= false and data.Claimed == false then
        return true
    end

    local status = guiStatus or Feature.getVipRewardGuiStatus()
    if status.claimVisible and status.claimActive and normalizeText(status.buttonText) == "claim" then
        return true
    end
    return normalizeText(status.timerText):find("claim your reward", 1, true) ~= nil
end

function Feature.claimVipRewardOnce()
    if LocalPlayer:GetAttribute("VIP") ~= true then
        State.vipRewardStatus = "VIP rewards require VIP."
        return false
    end

    Remote.fire("ClaimVIP", "Sync")
    task.wait(math.max(tonumber(Config.safety.remoteCooldown) or 0.35, 0.15))

    local data = Feature.getVipRewardData()
    local guiStatus = Feature.getVipRewardGuiStatus()
    if not Feature.isVipRewardClaimable(data, guiStatus) then
        local statusText = guiStatus.infoText ~= "" and guiStatus.infoText or guiStatus.timerText
        State.vipRewardStatus = statusText ~= "" and statusText or "VIP reward not claimable yet."
        return false
    end

    local ok = Remote.fire("ClaimVIP", "Claim")
    if ok then
        State.vipRewardStatus = "VIP reward claim sent."
        Log.push(State.vipRewardStatus)
        task.wait(math.max(tonumber(Config.safety.remoteCooldown) or 0.35, 0.15))
        Remote.fire("ClaimVIP", "Sync")
    end
    return ok
end

function Feature.toggleVipRewards(value)
    Config.flags.autoVipRewards = value
    if value then
        Feature.startLoop("autoVipRewards", function()
            return Config.delays.vipReward or Config.delays.battlepass
        end, Feature.claimVipRewardOnce)
    else
        Feature.stopLoop("autoVipRewards")
    end
end

function Feature.getRollPrompt()
    local plot = Feature.getOwnedPlot()
    local roll = plot and plot:FindFirstChild("Roll")
    local rollButton = roll and roll:FindFirstChild("RollButton")
    local button = rollButton and rollButton:FindFirstChild("Button")
    local prompt = button and button:FindFirstChild("RollPrompt")
    if prompt and prompt:IsA("ProximityPrompt") then
        return prompt
    end
    prompt = plot and plot:FindFirstChild("RollPrompt", true)
    if prompt and prompt:IsA("ProximityPrompt") then
        return prompt
    end
    return nil
end

function Feature.getRollStationLookTarget(buttonPart)
    local plot = Feature.getOwnedPlot()
    local folder = plot and plot:FindFirstChild("Characters")
    local roots = {}
    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            if model:IsA("Model") then
                local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
                if root then
                    table.insert(roots, root.Position)
                end
            end
        end
    end

    if #roots > 0 then
        local sum = Vector3.zero
        for _, position in ipairs(roots) do
            sum += position
        end
        return sum / #roots
    end

    return buttonPart.Position + buttonPart.CFrame.LookVector
end

function Feature.getRollButtonRearDirection(buttonPart, lookAt)
    local direction = Vector3.new(lookAt.X - buttonPart.Position.X, 0, lookAt.Z - buttonPart.Position.Z)
    if direction.Magnitude >= 0.1 then
        return direction.Unit
    end

    local fallback = Vector3.new(-buttonPart.CFrame.LookVector.X, 0, -buttonPart.CFrame.LookVector.Z)
    if fallback.Magnitude >= 0.1 then
        return fallback.Unit
    end
    return Vector3.new(0, 0, -1)
end

function Feature.getRollStationCFrame()
    local prompt = Feature.getRollPrompt()
    local buttonPart = prompt and Feature.getTargetPart(prompt)
    if not buttonPart then
        return nil
    end

    local lookAt = Feature.getRollStationLookTarget(buttonPart)
    local rearDirection = Feature.getRollButtonRearDirection(buttonPart, lookAt)
    local station = buttonPart.Position + rearDirection * Config.roll.rollStationBehindDistance
    station = Vector3.new(station.X, buttonPart.Position.Y + 2.2, station.Z)
    return CFrame.lookAt(station, Vector3.new(lookAt.X, station.Y, lookAt.Z))
end

function Feature.getTargetPart(instance)
    if not instance then
        return nil
    end
    if instance:IsA("BasePart") then
        return instance
    end
    if instance:IsA("ProximityPrompt") and instance.Parent and instance.Parent:IsA("BasePart") then
        return instance.Parent
    end
    if instance:IsA("Model") then
        return instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
    end
    if instance.Parent then
        return Feature.getTargetPart(instance.Parent)
    end
    return nil
end

function Feature.followPathToPosition(targetPosition, timeout)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = Feature.getCharacterRoot()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or not targetPosition then
        return false
    end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 3,
    })
    local ok = pcall(function()
        path:ComputeAsync(root.Position, targetPosition)
    end)
    if not ok or path.Status ~= Enum.PathStatus.Success then
        return false
    end

    local started = os.clock()
    local maxWait = tonumber(timeout) or Config.delays.moveTimeout or 1.35
    for _, waypoint in ipairs(path:GetWaypoints()) do
        if os.clock() - started > maxWait then
            return false
        end
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end

        local done = false
        local reached = false
        humanoid:MoveTo(waypoint.Position)
        task.spawn(function()
            local waitOk, result = pcall(function()
                return humanoid.MoveToFinished:Wait()
            end)
            reached = waitOk and result == true
            done = true
        end)

        while not done and os.clock() - started < maxWait do
            task.wait(0.03)
        end
        if not reached and (root.Position - waypoint.Position).Magnitude > 4 then
            return false
        end
    end

    return (root.Position - targetPosition).Magnitude <= 5
end

function Feature.moveToCFrame(targetCFrame, timeout, allowTeleportFallback)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = Feature.getCharacterRoot()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not targetCFrame then
        return false
    end

    local targetPosition = targetCFrame.Position
    local distance = (root.Position - targetPosition).Magnitude
    if humanoid and distance > 1.25 then
        local maxWait = tonumber(timeout) or Config.delays.moveTimeout or 1.35
        local pathReached = Feature.followPathToPosition(targetPosition, maxWait)
        if pathReached then
            root.CFrame = CFrame.new(root.Position, root.Position + targetCFrame.LookVector)
            return true
        end

        local done = false
        local reached = false
        humanoid:MoveTo(targetPosition)
        task.spawn(function()
            local ok, result = pcall(function()
                return humanoid.MoveToFinished:Wait()
            end)
            reached = ok and result == true
            done = true
        end)

        local started = os.clock()
        while not done and os.clock() - started < maxWait do
            task.wait(0.03)
        end
        if allowTeleportFallback ~= false and not reached and (root.Position - targetPosition).Magnitude > 7 then
            root.CFrame = targetCFrame
        end
    else
        root.CFrame = CFrame.new(root.Position, root.Position + targetCFrame.LookVector)
    end

    root.CFrame = CFrame.new(root.Position, root.Position + targetCFrame.LookVector)
    return true
end

function Feature.moveNearInstance(instance, distance, allowTeleportFallback)
    local root = Feature.getCharacterRoot()
    local targetPart = Feature.getTargetPart(instance)
    if not root or not targetPart then
        Log.push("Movement target was not found.")
        return false
    end

    local direction = root.Position - targetPart.Position
    if direction.Magnitude < 0.1 then
        direction = -targetPart.CFrame.LookVector
    else
        direction = direction.Unit
    end

    local targetPosition = targetPart.Position + direction * (tonumber(distance) or 3.2)
    targetPosition = Vector3.new(targetPosition.X, targetPart.Position.Y, targetPosition.Z)
    return Feature.moveToCFrame(CFrame.lookAt(targetPosition, targetPart.Position), Config.delays.moveTimeout, allowTeleportFallback)
end

function Feature.teleportToPrompt(prompt, distance)
    local root = Feature.getCharacterRoot()
    local targetPart = Feature.getTargetPart(prompt)
    if not root or not targetPart then
        Log.push("Buy prompt target was not found.")
        return false
    end

    local direction = root.Position - targetPart.Position
    if direction.Magnitude < 0.1 then
        direction = -targetPart.CFrame.LookVector
    else
        direction = direction.Unit
    end

    local offset = math.max(tonumber(distance) or 3.15, 0.75)
    local targetPosition = targetPart.Position + direction * offset
    targetPosition = Vector3.new(targetPosition.X, targetPart.Position.Y, targetPosition.Z)
    return Feature.teleportToCFrame(CFrame.lookAt(targetPosition, targetPart.Position))
end

function Feature.randomBetween(min, max)
    local low = tonumber(min) or 0
    local high = tonumber(max) or low
    if high < low then
        low, high = high, low
    end
    if high == low then
        return low
    end
    return low + (math.random() * (high - low))
end

function Feature.getPromptDistance(prompt)
    local root = Feature.getCharacterRoot()
    local targetPart = Feature.getTargetPart(prompt)
    if not root or not targetPart then
        return nil
    end
    return (root.Position - targetPart.Position).Magnitude
end

function Feature.isPromptWithinActivationRange(prompt, margin)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end
    local distance = Feature.getPromptDistance(prompt)
    if not distance then
        return false
    end
    local maxDistance = tonumber(prompt.MaxActivationDistance) or 10
    return distance <= math.max(maxDistance - (tonumber(margin) or 0), 0)
end

function Feature.getPromptApproachCFrame(prompt, distance)
    local root = Feature.getCharacterRoot()
    local targetPart = Feature.getTargetPart(prompt)
    if not root or not targetPart then
        return nil
    end

    local direction = root.Position - targetPart.Position
    direction = Vector3.new(direction.X, 0, direction.Z)
    if direction.Magnitude < 0.1 then
        direction = -Vector3.new(targetPart.CFrame.LookVector.X, 0, targetPart.CFrame.LookVector.Z)
    end
    if direction.Magnitude < 0.1 then
        direction = Vector3.new(0, 0, -1)
    else
        direction = direction.Unit
    end

    local jitter = tonumber(Config.roll.promptApproachJitter) or 0
    local sideOffset = Feature.randomBetween(-jitter, jitter)
    local tangent = Vector3.new(-direction.Z, 0, direction.X)
    local offset = math.max(tonumber(distance) or Config.roll.promptDistance or 3.15, 0.75)
    local targetPosition = targetPart.Position + direction * offset + tangent * sideOffset
    targetPosition = Vector3.new(targetPosition.X, targetPart.Position.Y, targetPosition.Z)
    return CFrame.lookAt(targetPosition, targetPart.Position)
end

function Feature.waitNaturalPromptDelay()
    local delay = Feature.randomBetween(Config.roll.promptDelayMin, Config.roll.promptDelayMax)
    if delay > 0 then
        task.wait(delay)
    end
end

function Feature.moveToPromptNaturally(prompt, distance)
    if not Config.roll.smoothMovement then
        return Feature.teleportToPrompt(prompt, distance)
    end

    local targetCFrame = Feature.getPromptApproachCFrame(prompt, distance)
    if not targetCFrame then
        return false
    end

    Feature.moveToCFrame(targetCFrame, Config.roll.promptMoveTimeout, false)
    if not Feature.isPromptWithinActivationRange(prompt, 0.35) then
        if Config.roll.promptTeleportFallback then
            return Feature.teleportToPrompt(prompt, distance)
        end
        Log.push("Prompt was not reached naturally; retrying next loop.")
        return false
    end

    Feature.waitNaturalPromptDelay()
    return true
end

function Feature.returnToRollStation()
    local station = Feature.getRollStationCFrame()
    if not station then
        return false
    end
    return Feature.teleportToCFrame(station)
end

function Feature.teleportToInstance(instance)
    local root = Feature.getCharacterRoot()
    local targetPart = Feature.getTargetPart(instance)
    if not root or not targetPart then
        Log.push("Teleport target was not found.")
        return false
    end

    local ok, err = pcall(function()
        root.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3.5)
    end)
    if not ok then
        Log.push("Teleport failed: " .. tostring(err))
    end
    return ok
end

function Feature.teleportToCFrame(targetCFrame)
    local root = Feature.getCharacterRoot()
    if not root or not targetCFrame then
        Log.push("Teleport target was not found.")
        return false
    end

    local ok, err = pcall(function()
        root.CFrame = targetCFrame
    end)
    if not ok then
        Log.push("Teleport failed: " .. tostring(err))
    end
    return ok
end

function Feature.touchInstance(instance)
    local root = Feature.getCharacterRoot()
    local targetPart = Feature.getTargetPart(instance)
    if not root or not targetPart then
        return false
    end

    if type(firetouchinterest) == "function" then
        local ok = pcall(function()
            firetouchinterest(root, targetPart, 0)
            task.wait(0.04)
            firetouchinterest(root, targetPart, 1)
        end)
        if ok then
            return true
        end
    end

    return (root.Position - targetPart.Position).Magnitude <= math.max(targetPart.Size.Magnitude, 4)
end

function Feature.holdKey(keyCode, duration)
    local key = keyCode or Enum.KeyCode.E
    local seconds = math.max(tonumber(duration) or 0.15, 0.15)
    local ok, err = pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(seconds)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
    if not ok then
        Log.push("Key hold failed: " .. tostring(err))
    end
    return ok
end

function Feature.triggerPromptExact(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or type(fireproximityprompt) ~= "function" then
        return false
    end

    local holdDuration = (tonumber(prompt.HoldDuration) or 0) + 0.15
    local ok = pcall(fireproximityprompt, prompt, holdDuration)
    if ok then
        return true
    end

    ok = pcall(fireproximityprompt, prompt)
    return ok
end

function Feature.getNearbyPromptConflicts(targetPrompt)
    local root = Feature.getCharacterRoot()
    local conflicts = {}
    if not root or not targetPrompt then
        return conflicts
    end

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt ~= targetPrompt then
            local targetPart = Feature.getTargetPart(prompt)
            if targetPart then
                local distance = (root.Position - targetPart.Position).Magnitude
                local maxDistance = (tonumber(prompt.MaxActivationDistance) or 10) + 0.75
                if distance <= maxDistance then
                    table.insert(conflicts, prompt)
                end
            end
        end
    end
    return conflicts
end

function Feature.canSafelyUseKeyForPrompt(prompt)
    return #Feature.getNearbyPromptConflicts(prompt) == 0
end

function Feature.holdPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end

    if Feature.triggerPromptExact(prompt) then
        return true
    end

    if not Feature.canSafelyUseKeyForPrompt(prompt) then
        Log.push("Skipped E hold: another prompt is close enough to steal input.")
        return false
    end

    local key = prompt.KeyboardKeyCode
    if key == Enum.KeyCode.Unknown then
        key = Enum.KeyCode.E
    end
    return Feature.holdKey(key, (tonumber(prompt.HoldDuration) or 0) + 0.15)
end

function Feature.holdPromptNaturally(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end

    if Config.roll.smoothMovement
        and Feature.canSafelyUseKeyForPrompt(prompt)
        and Feature.isPromptWithinActivationRange(prompt, 0.15) then
        local key = prompt.KeyboardKeyCode
        if key == Enum.KeyCode.Unknown then
            key = Enum.KeyCode.E
        end
        local holdDuration = (tonumber(prompt.HoldDuration) or 0)
            + 0.15
            + Feature.randomBetween(Config.roll.promptHoldExtraMin, Config.roll.promptHoldExtraMax)
        return Feature.holdKey(key, holdDuration)
    end

    return Feature.holdPrompt(prompt)
end

function Feature.getRollStationDistance()
    local root = Feature.getCharacterRoot()
    local station = Feature.getRollStationCFrame()
    if not root or not station then
        return nil
    end
    return (root.Position - station.Position).Magnitude
end

function Feature.returnToRollStationIfAway()
    if Config.flags.autoRoll ~= true then
        State.rollAwaySince = 0
        return false
    end
    if State.buyingCharacter or State.pendingBuy then
        State.rollAwaySince = 0
        return false
    end
    if Feature.shouldPauseRollForBoorus() then
        State.rollAwaySince = 0
        return false
    end

    local distance = Feature.getRollStationDistance()
    if not distance or distance <= (tonumber(Config.roll.stationReturnDistance) or 12.0) then
        State.rollAwaySince = 0
        return false
    end

    local now = os.clock()
    if (State.rollAwaySince or 0) <= 0 then
        State.rollAwaySince = now
        return false
    end
    if now - (State.rollAwaySince or 0) < (tonumber(Config.roll.stationReturnDelay) or 12.0) then
        return false
    end

    State.rollAwaySince = now
    if Feature.returnToRollStation() then
        State.rollAwaySince = 0
        State.rollBusyUntil = math.max(State.rollBusyUntil or 0, os.clock() + 0.25)
        Log.push("Returned to Roll station.")
        return true
    end
    return false
end

function Feature.rollOnceWithoutMovement()
    local prompt = Feature.getRollPrompt()
    if not prompt then
        Log.push("RollPrompt was not found on your plot.")
        return false
    end

    if not Feature.isPromptWithinActivationRange(prompt, 0.35) then
        return false
    end

    local ok = Feature.holdPrompt(prompt)
    if ok then
        State.lastRollAt = os.clock()
        State.rollBusyUntil = State.lastRollAt + Feature.getRollSettleDelay()
        Log.push("Held E on Roll.")
    end
    return ok
end

function Feature.rollOnce()
    local prompt = Feature.getRollPrompt()
    if not prompt then
        Log.push("RollPrompt was not found on your plot.")
        return false
    end

    if not Feature.moveToPromptNaturally(prompt, Config.roll.promptDistance) then
        return false
    end
    local ok = Feature.holdPromptNaturally(prompt)
    if ok then
        State.lastRollAt = os.clock()
        State.rollBusyUntil = State.lastRollAt + Feature.getRollSettleDelay()
        Log.push("Held E on Roll.")
    end
    return ok
end

function Feature.getRolledCharacterMutation(model)
    local value = readAttr(model, { "Mutation", "MutationName", "MutationType", "TraitMutation" }, "")
    if value and tostring(value) ~= "" then
        return tostring(value)
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("StringValue") and normalizeText(descendant.Name):find("mutation", 1, true) then
            return tostring(descendant.Value)
        end
    end
    return "None"
end

function Feature.getRolledCharacterModelFromPrompt(prompt, folder)
    local current = prompt
    local best = nil
    while current and current ~= folder do
        if current:IsA("Model") then
            local root = current:FindFirstChild("HumanoidRootPart") or current.PrimaryPart or current:FindFirstChildWhichIsA("BasePart", true)
            if root then
                best = current
            end
        end
        current = current.Parent
    end
    return best
end

function Feature.getRolledCharacterModels()
    local plot = Feature.getOwnedPlot()
    local folder = plot and plot:FindFirstChild("Characters")
    local out = {}
    if not folder then
        return out
    end

    local maxCharacters = tonumber(Config.roll.maxPodiumCharacters) or 6
    local seen = {}
    local function addModel(model, prompt)
        if #out >= (tonumber(Config.roll.maxPodiumCharacters) or 6) then
            return
        end
        if not model or not model:IsA("Model") or seen[model] then
            return
        end
        local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        prompt = prompt or (root and root:FindFirstChild("ProximityPrompt")) or model:FindFirstChild("ProximityPrompt", true)
        if prompt and prompt:IsA("ProximityPrompt") and normalizeText(prompt.ActionText):find("buy", 1, true) then
            seen[model] = true
            table.insert(out, {
                model = model,
                root = root,
                prompt = prompt,
            })
        end
    end

    for _, model in ipairs(folder:GetChildren()) do
        if #out >= maxCharacters then
            break
        end
        if model:IsA("Model") then
            addModel(model)
        end
    end

    for _, descendant in ipairs(folder:GetDescendants()) do
        if #out >= (tonumber(Config.roll.maxPodiumCharacters) or 6) then
            break
        end
        if descendant:IsA("ProximityPrompt") and normalizeText(descendant.ActionText):find("buy", 1, true) then
            addModel(Feature.getRolledCharacterModelFromPrompt(descendant, folder), descendant)
        end
    end

    local root = Feature.getCharacterRoot()
    table.sort(out, function(a, b)
        local partA = a.root or Feature.getTargetPart(a.prompt)
        local partB = b.root or Feature.getTargetPart(b.prompt)
        local distanceA = root and partA and (root.Position - partA.Position).Magnitude or math.huge
        local distanceB = root and partB and (root.Position - partB.Position).Magnitude or math.huge
        if distanceA ~= distanceB then
            return distanceA < distanceB
        end
        return tostring(a.model and a.model.Name or "") < tostring(b.model and b.model.Name or "")
    end)
    return out
end

function Feature.getRolledCharacters()
    local out = {}
    for _, rolled in ipairs(Feature.getRolledCharacterModels()) do
        local model = rolled.model
        local prompt = rolled.prompt
        local root = rolled.root
        local mutation = Feature.getRolledCharacterMutation(model)
        local entry = {
            name = model.Name,
            mutation = mutation,
            characterId = tostring(model:GetAttribute("CharacterId") or ""),
            slotKey = Feature.getRolledCharacterSlotKey(model, prompt, root, mutation),
            price = tostring(prompt.ObjectText or ""),
            model = model,
            root = root,
            prompt = prompt,
        }
        table.insert(out, entry)
    end
    State.rolledCharacters = out
    return out
end

function Feature.matchesRollTarget(entry)
    if not entry then
        return false
    end

    local wantsUnit = listHasItems(Config.roll.targetUnits)
    local wantsMutation = listHasItems(Config.roll.targetMutations)
    local matchedUnit = nil
    for _, unit in ipairs(Config.roll.targetUnits or {}) do
        if textMatchesAny(entry.name, { unit }) then
            matchedUnit = unit
            break
        end
    end

    if wantsUnit then
        if not matchedUnit then
            return false
        end
        local mutationTargets = Config.roll.unitMutationTargets[matchedUnit] or {}
        if #mutationTargets == 0 then
            return true
        end
        return textMatchesAny(entry.mutation, mutationTargets)
    end

    if not wantsUnit and not wantsMutation then
        return false
    end

    return textMatchesAny(entry.mutation, Config.roll.targetMutations)
end

function Feature.findMatchingRolledCharacter()
    for _, entry in ipairs(Feature.getRolledCharacters()) do
        if Feature.matchesRollTarget(entry) then
            return entry
        end
    end
    return nil
end

function Feature.parseCashText(text)
    local clean = tostring(text or ""):gsub(",", ""):gsub("%$", ""):gsub("%s+", "")
    local amountText, suffix = clean:match("([%d%.]+)([kKmMbBtT]?)")
    local amount = tonumber(amountText)
    if not amount then
        return nil
    end

    local multiplier = 1
    suffix = tostring(suffix or ""):lower()
    if suffix == "k" then
        multiplier = 1000
    elseif suffix == "m" then
        multiplier = 1000000
    elseif suffix == "b" then
        multiplier = 1000000000
    elseif suffix == "t" then
        multiplier = 1000000000000
    end
    return amount * multiplier
end

function Feature.getRolledCharacterPrice(entry)
    if not entry then
        return nil
    end
    return Feature.parseCashText(entry.price or (entry.prompt and entry.prompt.ObjectText))
end

function Feature.getRolledCharacterSlotKey(model, prompt, root, mutation)
    if model then
        local ok, debugId = pcall(function()
            return model:GetDebugId()
        end)
        if ok and debugId and tostring(debugId) ~= "" then
            return tostring(debugId)
        end
    end

    local targetPart = root or Feature.getTargetPart(prompt) or Feature.getTargetPart(model)
    local positionKey = "unknown"
    if targetPart then
        local position = targetPart.Position
        positionKey = string.format("%.1f,%.1f,%.1f", position.X, position.Y, position.Z)
    elseif model then
        positionKey = model:GetFullName()
    end
    return normalizedLookupKey(model and model.Name or "") .. "|" .. normalizedLookupKey(mutation or "None") .. "|" .. positionKey
end

function Feature.getRolledCharacterKey(entry)
    if not entry then
        return ""
    end
    if entry.characterId and entry.characterId ~= "" then
        return "id:" .. tostring(entry.characterId)
    end
    if entry.slotKey and entry.slotKey ~= "" then
        return "slot:" .. tostring(entry.slotKey)
    end
    return normalizeText(tostring(entry.name) .. "|" .. tostring(entry.mutation))
end

function Feature.findRolledCharacterByKey(key)
    if not key or key == "" then
        return nil
    end

    for _, entry in ipairs(Feature.getRolledCharacters()) do
        if Feature.getRolledCharacterKey(entry) == key and Feature.matchesRollTarget(entry) then
            return entry
        end
    end
    return nil
end

function Feature.hasFastRollOwned()
    local now = os.clock()
    if now - (State.fastRollOwnedCachedAt or 0) < 10 then
        return State.fastRollOwned == true
    end

    local owned = false
    pcall(function()
        for _, inst in ipairs(PlayerGui:GetDescendants()) do
            if inst.Name == "FastRoll" and inst:IsA("Frame") then
                local ownedFrame = inst:FindFirstChild("Owned")
                if ownedFrame and ownedFrame:IsA("GuiObject") and ownedFrame.Visible then
                    for _, descendant in ipairs(inst:GetDescendants()) do
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                            if normalizeText(descendant.Text) == "fast roll" then
                                owned = true
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
    State.fastRollOwned = owned
    State.fastRollOwnedCachedAt = now
    return owned
end

function Feature.getRollSettleDelay()
    local settle = tonumber(Config.delays.rollSettle) or 1.25
    if Feature.hasFastRollOwned() then
        settle = math.max(settle, tonumber(Config.delays.fastRollRollSettle) or 2.75)
    end
    return settle
end

function Feature.extendPendingBuyHold()
    if not State.pendingBuy then
        return
    end
    State.rollBusyUntil = math.max(State.rollBusyUntil or 0, os.clock() + (tonumber(Config.delays.buyReservePause) or 4.0))
end

function Feature.findPendingBuyCandidate()
    local pending = State.pendingBuy
    if not pending or not pending.key then
        return nil
    end

    local entry = Feature.findRolledCharacterByKey(pending.key)
    if entry then
        Feature.extendPendingBuyHold()
        return entry
    end

    Feature.clearStalePendingBuy()
    return nil
end

function Feature.setPendingBuy(entry)
    if not entry then
        return
    end

    local now = os.clock()
    local price = Feature.getRolledCharacterPrice(entry)
    State.pendingBuy = {
        key = Feature.getRolledCharacterKey(entry),
        name = entry.name,
        mutation = entry.mutation,
        price = price,
        createdAt = now,
        expiresAt = now + (tonumber(Config.delays.buyAttemptWindow) or 8.0),
    }
    Feature.extendPendingBuyHold()

    if price and Feature.getPlayerCash() < price and now - (State.lastPendingBuyLogAt or 0) > 3 then
        State.lastPendingBuyLogAt = now
        Log.push("Waiting for cash to buy " .. tostring(entry.name) .. " (" .. tostring(entry.price or "?") .. ").")
    end
end

function Feature.clearPendingBuy()
    State.pendingBuy = nil
end

function Feature.clearStalePendingBuy()
    State.pendingBuy = nil
    local settle = Feature.getRollSettleDelay()
    State.rollBusyUntil = math.min(State.rollBusyUntil or 0, os.clock() + settle)
end

function Feature.shouldWaitForCashToBuy(entry)
    local price = Feature.getRolledCharacterPrice(entry)
    if not price then
        return false
    end
    if Feature.getPlayerCash() < price then
        Feature.setPendingBuy(entry)
        return true
    end
    return false
end

function Feature.tryBuyRolledCharacter(entry)
    if Feature.shouldWaitForCashToBuy(entry) then
        return false
    end

    local bought = Feature.buyRolledCharacter(entry)
    if bought then
        Feature.clearPendingBuy()
    end
    return bought
end

function Feature.reserveBuyBeforeRolling()
    if not Config.flags.autoBuy then
        return nil
    end

    local pending = Feature.findPendingBuyCandidate()
    if pending then
        Feature.extendPendingBuyHold()
        return pending
    end

    local match = Feature.findMatchingRolledCharacter()
    if match then
        Feature.setPendingBuy(match)
        return match
    end
    return nil
end

function Feature.waitForRolledCharacterGone(key, timeout)
    if not key or key == "" then
        return false
    end

    local deadline = os.clock() + (tonumber(timeout) or (tonumber(Config.delays.buyConfirmTimeout) or 2.5))
    repeat
        if not Feature.findRolledCharacterByKey(key) then
            return true
        end
        task.wait(0.08)
    until os.clock() >= deadline

    return not Feature.findRolledCharacterByKey(key)
end

function Feature.buyRolledCharacter(entry)
    if not entry or not entry.prompt then
        Log.push("No matching podium character to buy.")
        return false
    end
    if State.buyingCharacter then
        return false
    end

    State.buyingCharacter = true
    Feature.extendPendingBuyHold()
    local bought = false
    local ok, err = pcall(function()
        local key = Feature.getRolledCharacterKey(entry)
        local maxAttempts = math.max(tonumber(Config.delays.buyPromptRetries) or 4, 1)
        for attempt = 1, maxAttempts do
            local current = Feature.findRolledCharacterByKey(key) or entry
            if not current or not current.prompt then
                break
            end

            Feature.extendPendingBuyHold()
            local moved = Feature.moveToPromptNaturally(current.prompt, Config.roll.promptDistance)
            local prompted = moved and Feature.holdPromptNaturally(current.prompt)
            Feature.extendPendingBuyHold()
            if prompted and Feature.waitForRolledCharacterGone(key, tonumber(Config.delays.buyConfirmTimeout) or 2.5) then
                bought = true
                State.lastBuyAt = os.clock()
                Log.push("Bought " .. tostring(current.name) .. ".")
                Feature.notifyRareWebhook({
                    kind = "Rare Roll Bought",
                    source = "Auto Buy",
                    name = current.name,
                    mutation = current.mutation,
                    rarity = Feature.getWebhookCharacterRarity(current.name),
                    slotKey = key,
                    details = current.price,
                })
                break
            end
            task.wait(tonumber(Config.delays.buyPromptRetryDelay) or 0.18)
        end
    end)
    if not ok then
        Log.push("Buy failed: " .. tostring(err))
    end
    State.rollBusyUntil = math.max(State.rollBusyUntil or 0, os.clock() + (tonumber(Config.delays.buyPause) or 0.9))
    State.buyingCharacter = false
    return bought
end

function Feature.getRollPityEntries()
    local plot = Feature.getOwnedPlot()
    local roll = plot and plot:FindFirstChild("Roll")
    local guaranteed = roll and roll:FindFirstChild("Guaranteed") -- Roll.Guaranteed
    local entries = {}
    if not guaranteed then
        return entries
    end

    for _, rarityName in ipairs({ "Mythic", "Secret" }) do
        local row = guaranteed:FindFirstChild(rarityName, true)
        if row then
            local rarityLabel = row:FindFirstChild("Rarity")
            local timerLabel = row:FindFirstChild("Timer")
            local rarity = rarityLabel and rarityLabel:IsA("TextLabel") and rarityLabel.Text or rarityName
            local timer = timerLabel and timerLabel:IsA("TextLabel") and timerLabel.Text or ""
            if timer ~= "" then
                table.insert(entries, {
                    rarity = tostring(rarity),
                    timer = tostring(timer),
                    text = tostring(rarity) .. " " .. tostring(timer),
                })
            end
        end
    end
    return entries
end

function Feature.getPityText()
    local entries = Feature.getRollPityEntries()
    if #entries > 0 then
        local parts = {}
        for _, entry in ipairs(entries) do
            table.insert(parts, entry.text)
        end
        State.pityText = table.concat(parts, " | ")
        return State.pityText
    end

    State.scanGuiText()
    return tostring(State.pityText or "")
end

function Feature.isPityAtOneRoll()
    local text = normalizeText(Feature.getPityText())
    if text == "" then
        return false
    end
    if text:find("mythic/secret in 1 roll", 1, true) then
        return true
    end
    local hasTarget = text:find("mythic", 1, true) or text:find("secret", 1, true)
    return hasTarget and text:find("in 1 roll", 1, true) ~= nil
end

function Feature.isSecretPityAtOneRoll()
    for _, entry in ipairs(Feature.getRollPityEntries()) do
        local rarity = normalizeText(entry.rarity)
        local timer = normalizeText(entry.timer)
        if rarity:find("secret", 1, true) and timer:find("in 1 roll", 1, true) then
            return true
        end
    end

    local text = normalizeText(Feature.getPityText())
    return text:find("secret in 1 roll", 1, true) ~= nil or text:find("secret: in 1 roll", 1, true) ~= nil
end

function Feature.isEventStatusText(text)
    local clean = normalizeText(text)
    if clean == "" or clean:find("next event", 1, true) then
        return false
    end
    if clean:find("active", 1, true)
        or clean:find("current event", 1, true)
        or clean:find("ends in", 1, true)
        or clean:find("ending in", 1, true)
        or clean:find("remaining", 1, true)
        or clean:find("boost", 1, true)
        or clean:match("^x%d+") then
        return true
    end
    return clean:find("event", 1, true) ~= nil and textMatchesAny(clean, DataSource.expandSnipeEventNames(Config.roll.snipeEvents))
end

function Feature.getSelectedSnipeEvents()
    return DataSource.expandSnipeEventNames(Config.roll.snipeEvents)
end

function Feature.isSelectedEventPayloadText(text, selectedEvents)
    local clean = normalizeText(text)
    if clean == "" or clean:find("next event", 1, true) then
        return false
    end

    for _, eventName in ipairs(selectedEvents or Feature.getSelectedSnipeEvents()) do
        local eventClean = normalizeText(eventName)
        if eventClean ~= "" and (
            clean == eventClean
            or clean:sub(1, #eventClean + 1) == eventClean .. " "
            or clean:sub(1, #eventClean + 1) == eventClean .. ":"
            or clean:find(eventClean .. " mutation event", 1, true)
        ) then
            return true
        end
    end
    return false
end

function Feature.isActiveEventTextForSelection(text)
    local clean = normalizeText(text)
    local selectedEvents = Feature.getSelectedSnipeEvents()
    if clean == "" or clean:find("next event", 1, true) then
        return false
    end
    if Feature.isSelectedEventPayloadText(text, selectedEvents) then
        return true
    end
    return Feature.isEventStatusText(text) and textMatchesAny(text, selectedEvents)
end

function Feature.eventPayloadToText(...)
    local parts = {}
    local function visit(value, depth)
        if depth > 3 then
            return
        end
        if type(value) == "table" then
            for key, item in pairs(value) do
                visit(key, depth + 1)
                visit(item, depth + 1)
            end
        elseif typeof(value) == "Instance" then
            table.insert(parts, value.Name)
        else
            table.insert(parts, tostring(value))
        end
    end

    for index = 1, select("#", ...) do
        visit(select(index, ...), 0)
    end
    return table.concat(parts, " ")
end

function Feature.isVisibleSelectedEventBadge(instance, selectedEvents)
    if not instance or not instance:IsA("GuiObject") or not instance.Visible then
        return false
    end
    if not textMatchesAny(instance.Name, selectedEvents or Feature.getSelectedSnipeEvents()) then
        return false
    end
    return instance.Parent and instance.Parent.Name == "Events" or instance:FindFirstChild("Timer", true) ~= nil
end

function Feature.trackEventUi(...)
    local text = Feature.eventPayloadToText(...)
    local clean = normalizeText(text)
    if clean:find("end", 1, true) or clean:find("stop", 1, true) or clean:find("over", 1, true) then
        State.activeEventText = ""
        State.lastEventUiAt = 0
        State.cachedSelectedEventActive = false
        State.lastSelectedEventScanAt = os.clock()
        return
    end

    State.activeEventText = text
    State.lastEventUiAt = os.clock()
    if Feature.isActiveEventTextForSelection(text) then
        State.cachedSelectedEventActive = true
        State.lastSelectedEventScanAt = os.clock()
        State.pityHoldUntil = 0
    end
end

function Feature.attachEventUiTracker()
    if State.eventUiAttached then
        return
    end

    local remote = Remote.get("EventUI")
    if remote and remote:IsA("RemoteEvent") then
        State.eventUiAttached = true
        Maid:add(remote.OnClientEvent:Connect(function(...)
            Feature.trackEventUi(...)
        end))
    end
end

function Feature.scanEventTextForNames(eventNames)
    eventNames = DataSource.expandSnipeEventNames(eventNames or {})
    if not listHasItems(eventNames) then
        return ""
    end

    local roots = {
        PlayerGui:FindFirstChild("EventUI"),
        workspace:FindFirstChild("EventAttachments"),
    }
    for _, root in ipairs(roots) do
        if root then
            if textMatchesAny(root.Name, eventNames) then
                return root.Name
            end
            for _, descendant in ipairs(root:GetDescendants()) do
                if Feature.isVisibleSelectedEventBadge(descendant, eventNames) then
                    return descendant.Name
                end
                local text = descendant.Name
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                    text = tostring(descendant.Text) .. " " .. tostring(descendant.Name)
                end
                if textMatchesAny(text, eventNames) and Feature.isEventStatusText(text) then
                    return text
                end
            end
        end
    end
    return ""
end

function Feature.scanSelectedEventText()
    return Feature.scanEventTextForNames(Feature.getSelectedSnipeEvents())
end

function Feature.textRootHasSelectedEvent(root, selectedEvents)
    if not root then
        return false
    end

    selectedEvents = selectedEvents or Feature.getSelectedSnipeEvents()
    local sawSelectedName = textMatchesAny(root.Name, selectedEvents)
    local sawStatus = false
    for _, descendant in ipairs(root:GetDescendants()) do
        if Feature.isVisibleSelectedEventBadge(descendant, selectedEvents) then
            return true
        end
        if (descendant:IsA("TextLabel") or descendant:IsA("TextButton")) and descendant.Visible then
            if textMatchesAny(descendant.Text, selectedEvents) or textMatchesAny(descendant.Name, selectedEvents) then
                sawSelectedName = true
            end
            if Feature.isEventStatusText(descendant.Text) then
                sawStatus = true
            end
            if textMatchesAny(descendant.Text, selectedEvents) and Feature.isEventStatusText(descendant.Text) then
                return true
            end
        end
    end
    return sawSelectedName and sawStatus
end

function Feature.isSelectedSnipeEventActive()
    local selectedEvents = Feature.getSelectedSnipeEvents()
    if not listHasItems(selectedEvents) then
        return false
    end

    if State.activeEventText ~= ""
        and os.clock() - (State.lastEventUiAt or 0) < 180
        and textMatchesAny(State.activeEventText, selectedEvents)
        and Feature.isActiveEventTextForSelection(State.activeEventText) then
        return true
    end

    local selectedEventText = Feature.scanSelectedEventText()
    if selectedEventText ~= "" then
        State.activeEventText = selectedEventText
        State.lastEventUiAt = os.clock()
        return true
    end

    State.scanGuiText()
    if Feature.isEventStatusText(State.waveStatus) and textMatchesAny(State.waveStatus, selectedEvents) then
        return true
    end

    local main = PlayerGui:FindFirstChild("MainUI")
    local frames = main and main:FindFirstChild("Frames")
    if Feature.textRootHasSelectedEvent(frames and frames:FindFirstChild("Events")) then
        return true
    end

    local plot = Feature.getOwnedPlot()
    local roll = plot and plot:FindFirstChild("Roll")
    local rollButton = roll and roll:FindFirstChild("RollButton")
    if Feature.textRootHasSelectedEvent(rollButton and rollButton:FindFirstChild("Luck")) then
        return true
    end

    return false
end

function Feature.getCachedSelectedSnipeEventActive()
    local now = os.clock()
    local interval = math.max(tonumber(Config.delays.eventScanInterval) or 4.0, 1.0)
    if now - (State.lastSelectedEventScanAt or 0) < interval then
        return State.cachedSelectedEventActive == true
    end

    State.lastSelectedEventScanAt = now
    State.cachedSelectedEventActive = Feature.isSelectedSnipeEventActive()
    return State.cachedSelectedEventActive == true
end

function Feature.shouldHoldPityForEvent()
    if not Config.flags.holdPityForEvent then
        return false
    end
    if not Feature.isSecretPityAtOneRoll() then
        return false
    end
    return not Feature.getCachedSelectedSnipeEventActive()
end

function Feature.setPityHoldBackoff()
    State.pityHoldUntil = os.clock() + (tonumber(Config.delays.pityHoldPoll) or 1.0)
end

function Feature.getAutoRollLoopDelay()
    local baseDelay = tonumber(Config.delays.roll) or 0.12
    if State.buyingCharacter or State.pendingBuy then
        return tonumber(Config.delays.buyRetryPoll) or 0.35
    end
    if Feature.shouldPauseRollForBoorus() then
        return math.max(tonumber(Config.delays.event) or 1, tonumber(Config.boorus.fightSupportPoll) or 2)
    end
    local holdRemaining = (tonumber(State.pityHoldUntil) or 0) - os.clock()
    if holdRemaining > baseDelay then
        return math.max(baseDelay, holdRemaining)
    end
    return baseDelay
end

function Feature.shouldPauseRollForBoorus()
    if Config.flags.autoBoorus ~= true then
        return false
    end

    local now = os.clock()
    if now < (tonumber(State.boorusSpinBusyUntil) or 0) then
        return true
    end
    if now <= (tonumber(State.boorusFightUntil) or 0) then
        return true
    end
    if Feature.getBoorusSpinCount() > 0 then
        return true
    end
    if Feature.isBoorusChallengeActive() then
        return true
    end
    return Feature.isBoorusChallengeReady()
end

function Feature.autoRollStep()
    if os.clock() < (State.pityHoldUntil or 0) then
        return
    end

    if State.buyingCharacter then
        return
    end

    if State.pendingBuy then
        Feature.autoBuyStep()
        return
    end

    if Feature.returnToRollStationIfAway() then
        return
    end

    if Feature.shouldHoldPityForEvent() then
        Feature.setPityHoldBackoff()
        if os.clock() - (State.lastPityHoldLogAt or 0) > 3 then
            State.lastPityHoldLogAt = os.clock()
            Log.push("Holding Secret in 1 roll for selected event.")
        end
        return
    end

    State.pityHoldUntil = 0

    if Feature.isWaveStarted() then
        if Feature.shouldRollAgain(true) then
            Feature.rollOnceWithoutMovement()
        end
        return
    end

    if Feature.shouldPauseRollForBoorus() then
        State.rollBusyUntil = math.max(State.rollBusyUntil or 0, os.clock() + math.max(tonumber(Config.delays.event) or 1, 1))
        return
    end

    local reserved = Feature.reserveBuyBeforeRolling()
    if reserved then
        Feature.autoBuyStep()
        return
    end

    local bought = Feature.autoBuyStep()
    if bought then
        return
    end

    local match = Feature.findMatchingRolledCharacter()
    if match then
        return
    end

    if not Feature.shouldRollAgain() then
        return
    end

    Feature.rollOnce()
end

function Feature.describeRolledCharacters()
    local lines = {}
    for index, entry in ipairs(Feature.getRolledCharacters()) do
        if index > (tonumber(Config.roll.maxPodiumCharacters) or 6) then
            break
        end
        local marker = Feature.matchesRollTarget(entry) and "MATCH" or "scan"
        local mutation = entry.mutation ~= "" and entry.mutation or "None"
        local price = entry.price ~= "" and (" | " .. entry.price) or ""
        table.insert(lines, marker .. " | " .. entry.name .. " | " .. mutation .. price)
    end
    if #lines == 0 then
        return "No buyable podium characters detected."
    end
    return table.concat(lines, "\n")
end

function Feature.toggleAutoRoll(value)
    Config.flags.autoRoll = value
    Feature.applyAutoRollSettingsLocal()
    if value then
        Feature.startLoop("autoRoll", function()
            return Feature.getAutoRollLoopDelay()
        end, Feature.autoRollStep)
    else
        Feature.stopLoop("autoRoll")
    end
end

function Feature.shouldRollAgain(allowDuringWave)
    if Feature.isWaveStarted() and allowDuringWave ~= true then
        return false
    end
    if State.buyingCharacter then
        return false
    end
    if os.clock() < (State.rollBusyUntil or 0) then
        return false
    end
    return os.clock() - (State.lastRollAt or 0) >= Feature.getRollSettleDelay()
end

function Feature.autoBuyStep()
    if not Config.flags.autoBuy or State.buyingCharacter then
        return false
    end
    if os.clock() - (State.lastBuyAt or 0) < math.max(Config.safety.remoteCooldown, 0.18) then
        return false
    end

    local pending = Feature.findPendingBuyCandidate()
    if pending then
        return Feature.tryBuyRolledCharacter(pending)
    end
    if State.pendingBuy then
        Feature.extendPendingBuyHold()
        return false
    end

    if Feature.shouldPauseRollForBoorus() then
        return false
    end

    local match = Feature.findMatchingRolledCharacter()
    if match then
        Feature.setPendingBuy(match)
        return Feature.tryBuyRolledCharacter(match)
    end
    return false
end

function Feature.toggleAutoBuy(value)
    Config.flags.autoBuy = value
    Feature.applyAutoRollSettingsLocal()
    if value then
        Feature.startLoop("autoBuy", function()
            return Config.delays.buyScan
        end, Feature.autoBuyStep)
    else
        Feature.clearPendingBuy()
        Feature.stopLoop("autoBuy")
    end
end

function Feature.startLoadedAutomationSettings()
    if Config.flags.antiAfk then
        Feature.setAntiAfkEnabled(true)
    end
    if Config.flags.autoStartWave then
        Feature.setAutoStartWave(true)
    end
    if Config.flags.autoFastForward then
        Feature.setAutoFastForward(true)
    end
    if Config.flags.autoRoll then
        Feature.toggleAutoRoll(true)
    end
    if Config.flags.autoBuy then
        Feature.toggleAutoBuy(true)
    end
    if Config.flags.autoMerge then
        Feature.toggleAutoMerge(true)
    end
    if Config.flags.autoTrait then
        Feature.toggleTrait(true)
    end
    if Config.flags.autoUpgrade then
        Feature.toggleUpgrade(true)
    end
    if Config.flags.autoBestLineup then
        Feature.setAutoBestLineup(true)
    end
    if Config.flags.autoBuhara then
        Feature.toggleBuhara(true)
    end
    if Config.flags.autoShenron then
        Feature.toggleShenron(true)
    end
    if Config.flags.autoBoorus then
        Feature.toggleBoorus(true)
    end
    if Config.flags.autoBattlepass then
        Feature.toggleBattlepass(true)
    end
    if Config.flags.autoSpin then
        Feature.setAutoSpin(true)
    end
    if Config.flags.autoVipRewards then
        Feature.toggleVipRewards(true)
    end
end

function Feature.getCharacterStaticInfo(unitName)
    if not State.characterInfoByName or not next(State.characterInfoByName) then
        State.loadSharedInfo()
    end
    local name = tostring(unitName or "")
    return State.characterInfoByName[name] or State.characterInfoByName[normalizedLookupKey(name)]
end

function Feature.getMutationInfo(mutationName)
    local name = tostring(mutationName or "")
    if name == "" or normalizeText(name) == "none" then
        return nil
    end
    if not State.mutationInfoByName or not next(State.mutationInfoByName) then
        State.loadSharedInfo()
    end
    return State.mutationInfoByName[name] or State.mutationInfoByName[normalizedLookupKey(name)]
end

function Feature.getTraitInfo(traitName)
    local name = tostring(traitName or "")
    if name == "" or normalizeText(name) == "none" then
        return nil
    end
    if not State.traitInfoByName or not next(State.traitInfoByName) then
        State.loadSharedInfo()
    end
    return State.traitInfoByName[name] or State.traitInfoByName[normalizedLookupKey(name)]
end

function Feature.getLevelDamage(baseDamage, level)
    local damage = tonumber(baseDamage) or 0
    local unitLevel = math.max(tonumber(level) or 1, 1)
    local helper = State.characterLevelHelper
    if helper and type(helper.GetDamage) == "function" then
        local ok, value = pcall(helper.GetDamage, damage, unitLevel)
        if ok and tonumber(value) then
            return tonumber(value)
        end
    end

    local config = State.levelInfo and State.levelInfo.Config
    local buff = tonumber(config and config.DamageBuffPerLevel) or 1.25
    return damage * buff ^ (unitLevel - 1)
end

function Feature.makeUnitStatModel(unit, info)
    local attributes = {
        Damage = info and info.Damage,
        Cooldown = info and info.Cooldown,
        AttackType = info and info.AttackType,
        Duration = info and info.Duration,
        TickRate = info and info.TickRate,
        Burn = info and info.Burn,
        BurnDuration = info and info.BurnDuration,
        BurnDamage = info and info.BurnDamage,
        BurnTick = info and info.BurnTick,
        Range = info and info.Range,
        Level = math.max(tonumber(unit and unit.level) or 1, 1),
        Mutation = unit and unit.mutation,
        Trait = unit and unit.trait,
        TraitName = unit and unit.trait,
    }

    return {
        GetAttribute = function(_, name)
            return attributes[name]
        end,
    }
end

function Feature.computeUnitDerivedStats(unit)
    local static = Feature.getCharacterStaticInfo(unit and unit.name)
    local info = static and static.data
    if type(info) ~= "table" then
        return nil
    end

    local mutationInfo = Feature.getMutationInfo(unit.mutation)
    local traitInfo = Feature.getTraitInfo(unit.trait)
    local level = tonumber(unit.level) or 1
    local mutationDamage = tonumber(mutationInfo and mutationInfo.DamageMultiplier) or 1
    local traitDamage = tonumber(traitInfo and traitInfo.Damage) or 1
    local traitCooldown = math.max(tonumber(traitInfo and traitInfo.Cooldown) or 1, 0.05)
    local traitRange = tonumber(traitInfo and traitInfo.Range) or 1
    local critChance = math.max(tonumber(traitInfo and traitInfo.CritChance) or 0, 0)
    local critDamage = math.max(tonumber(traitInfo and traitInfo.CritDamage) or 1, 1)

    local baseDamage = Feature.getLevelDamage(info.Damage, level)
    local critMultiplier = critChance / 100 * (critDamage - 1) + 1
    local hitDamage = baseDamage * mutationDamage * traitDamage * critMultiplier
    local attackType = tostring(info.AttackType or "")
    local totalDamage = hitDamage

    if attackType == "Barrage" or attackType == "Continuous" then
        local duration = tonumber(info.Duration) or 0
        local tickRate = tonumber(info.TickRate) or 0
        if duration > 0 and tickRate > 0 then
            totalDamage = hitDamage * math.max(1, math.floor(duration / tickRate + 0.0001))
        end
    end

    if info.Burn then
        local burnDuration = tonumber(info.BurnDuration) or 0
        local burnDamage = tonumber(info.BurnDamage) or 0
        local burnTick = tonumber(info.BurnTick) or 0
        if burnDuration > 0 and burnDamage > 0 and burnTick > 0 then
            totalDamage += burnDamage * math.max(1, math.floor(burnDuration / burnTick + 0.0001))
        end
    end

    local cooldown = (tonumber(info.Cooldown) or 0) * traitCooldown
    local dps = cooldown > 0 and (math.floor(totalDamage / cooldown * 10 + 0.5) / 10) or 0
    local helper = State.characterStatsUiHelper
    if helper and type(helper.GetDps) == "function" then
        local statModel = Feature.makeUnitStatModel(unit, info)
        local ok, helperDps = pcall(function()
            return helper.GetDps(unit.name, statModel, info, unit.mutation, traitInfo)
        end)
        if ok and tonumber(helperDps) then
            dps = tonumber(helperDps)
        end
    end
    local range = (tonumber(info.Range) or 0) * traitRange
    local chance = tonumber(info.Chance) or 0

    return {
        damage = totalDamage,
        dps = dps,
        range = range,
        cooldown = cooldown,
        rng = chance,
        rarity = static.rarity or State.characterRarity[unit.name] or "Common",
        displayName = static.displayName or unit.name,
        attackType = attackType,
        splashRadius = tonumber(info.SplashRadius) or 0,
        lineWidth = tonumber(info.LineWidth) or 0,
        level = level,
        mutationDamage = mutationDamage,
        traitDamage = traitDamage,
        critChance = critChance,
        critDamage = critDamage,
    }
end

function Feature.getCurrentGridModel()
    local plot = Feature.getOwnedPlot()
    local grid = plot and plot:FindFirstChild("Grid")
    if not grid then
        return nil
    end

    local gridLevel = Feature.dataGet("GridLevel", nil)
    if gridLevel then
        local levelGrid = grid:FindFirstChild("Level" .. tostring(gridLevel))
        if levelGrid then
            return levelGrid
        end
    end

    local bestLevel = nil
    local bestNumber = -math.huge
    for _, child in ipairs(grid:GetChildren()) do
        local levelNumber = tonumber(tostring(child.Name):match("Level(%d+)"))
        if levelNumber and levelNumber > bestNumber then
            bestLevel = child
            bestNumber = levelNumber
        end
    end
    return bestLevel
end

function Feature.buildGridCells(gridModel)
    local cells = {}
    local map = {}
    if not gridModel then
        return cells, map
    end

    for _, child in ipairs(gridModel:GetChildren()) do
        if child:IsA("BasePart") then
            map[child.Name] = child
            table.insert(cells, child)
        end
    end

    table.sort(cells, function(a, b)
        local az = math.floor(a.Position.Z * 100 + 0.5)
        local bz = math.floor(b.Position.Z * 100 + 0.5)
        if az ~= bz then
            return az < bz
        end
        local ax = math.floor(a.Position.X * 100 + 0.5)
        local bx = math.floor(b.Position.X * 100 + 0.5)
        if ax ~= bx then
            return ax < bx
        end
        return a.Name < b.Name
    end)
    return cells, map
end

function Feature.getShapeModel(unitName)
    local shapes = Assets and Assets:FindFirstChild("Shapes")
    if not shapes then
        return nil, nil
    end

    local helper = State.placementHelper
    local shapeName = nil
    if helper and type(helper.GetShapeName) == "function" then
        local ok, result = pcall(helper.GetShapeName, shapes, unitName)
        if ok then
            shapeName = result
        end
    end
    shapeName = shapeName or tostring(unitName or "")

    local shapeModel = nil
    if helper and type(helper.GetShapeModel) == "function" then
        local ok, result = pcall(helper.GetShapeModel, shapes, unitName, shapeName)
        if ok and result and result:IsA("Model") then
            shapeModel = result
        end
    end
    if not shapeModel then
        local direct = shapes:FindFirstChild(tostring(unitName or ""))
        if direct and direct:IsA("Model") then
            shapeModel = direct
            shapeName = direct.Name
        elseif direct then
            local named = direct:FindFirstChild(shapeName)
            if named and named:IsA("Model") then
                shapeModel = named
                shapeName = named.Name
            else
                for _, child in ipairs(direct:GetChildren()) do
                    if child:IsA("Model") then
                        shapeModel = child
                        shapeName = child.Name
                        break
                    end
                end
            end
        end
    end
    if not shapeModel then
        local wanted = normalizeText(shapeName)
        for _, child in ipairs(shapes:GetChildren()) do
            if child:IsA("Model") and normalizeText(child.Name) == wanted then
                shapeModel = child
                shapeName = child.Name
                break
            end
        end
    end

    return shapeModel, shapeName
end

function Feature.getShapeParts(shapeModel)
    local helper = State.placementHelper
    if helper and type(helper.GetShapeParts) == "function" then
        local ok, parts = pcall(helper.GetShapeParts, shapeModel)
        if ok and type(parts) == "table" then
            return parts
        end
    end

    local parts = {}
    if shapeModel then
        local grid = shapeModel:FindFirstChild("Grid") or shapeModel
        for _, descendant in ipairs(grid:GetDescendants()) do
            if descendant:IsA("BasePart") then
                table.insert(parts, descendant)
            end
        end
    end
    return parts
end

function Feature.getShapeFootprint(unitName)
    State.shapeFootprints = State.shapeFootprints or {}
    local cacheKey = tostring(unitName or "")
    if State.shapeFootprints[cacheKey] then
        return State.shapeFootprints[cacheKey]
    end

    local shapeModel, shapeName = Feature.getShapeModel(unitName)
    if not shapeModel then
        return nil
    end

    local parts = Feature.getShapeParts(shapeModel)
    local helper = State.placementHelper
    local main = nil
    if helper and type(helper.GetShapeMain) == "function" then
        local ok, result = pcall(helper.GetShapeMain, shapeModel)
        if ok then
            main = result
        end
    end
    main = main or parts[1]
    if not main then
        return nil
    end

    local cellSizeX = math.max(main.Size.X, 1)
    local cellSizeZ = math.max(main.Size.Z, 1)
    local offsets = {}
    local partOffsets = {}
    local seen = {}
    local shapePivot = shapeModel:GetPivot()
    for _, part in ipairs(parts) do
        table.insert(partOffsets, shapePivot:ToObjectSpace(part.CFrame))
        local dx = math.floor((part.Position.X - main.Position.X) / cellSizeX + 0.5)
        local dz = math.floor((part.Position.Z - main.Position.Z) / cellSizeZ + 0.5)
        local key = tostring(dx) .. ":" .. tostring(dz)
        if not seen[key] then
            seen[key] = true
            table.insert(offsets, { dx = dx, dz = dz })
        end
    end
    if #offsets == 0 then
        table.insert(offsets, { dx = 0, dz = 0 })
    end

    local footprint = {
        shapeName = shapeName or unitName,
        shapeModel = shapeModel,
        spots = math.max(#offsets, 1),
        offsets = offsets,
        partOffsets = partOffsets,
        pivotOffset = main.CFrame:ToObjectSpace(shapeModel:GetPivot()),
        cellSizeX = cellSizeX,
        cellSizeZ = cellSizeZ,
    }
    State.shapeFootprints[cacheKey] = footprint
    return footprint
end

function Feature.getCellByOffset(anchorCell, offset, cells)
    if not anchorCell or not offset then
        return nil
    end

    local cellSizeX = math.max(anchorCell.Size.X, 1)
    local cellSizeZ = math.max(anchorCell.Size.Z, 1)
    local target = anchorCell.Position + Vector3.new((offset.dx or 0) * cellSizeX, 0, (offset.dz or 0) * cellSizeZ)
    local bestCell = nil
    local bestDistance = math.huge
    for _, cell in ipairs(cells or {}) do
        local distance = (Vector3.new(cell.Position.X, 0, cell.Position.Z) - Vector3.new(target.X, 0, target.Z)).Magnitude
        if distance < bestDistance then
            bestDistance = distance
            bestCell = cell
        end
    end
    if bestCell and bestDistance <= math.max(cellSizeX, cellSizeZ) * 0.35 then
        return bestCell
    end
    return nil
end

function Feature.getContainingGridCell(part, gridMap)
    local helper = State.placementHelper
    if helper and type(helper.GetContainingCellForPart) == "function" then
        local ok, cell = pcall(helper.GetContainingCellForPart, part, gridMap)
        if ok and cell then
            return cell
        end
    end

    for _, cell in pairs(gridMap or {}) do
        if cell:IsA("BasePart") then
            local dx = math.abs(part.Position.X - cell.Position.X)
            local dz = math.abs(part.Position.Z - cell.Position.Z)
            if dx <= cell.Size.X * 0.5 + 0.1 and dz <= cell.Size.Z * 0.5 + 0.1 then
                return cell
            end
        end
    end
    return nil
end

function Feature.getContainingGridCellForPosition(position, gridMap)
    if not position then
        return nil
    end
    for _, cell in pairs(gridMap or {}) do
        if cell:IsA("BasePart") then
            local dx = math.abs(position.X - cell.Position.X)
            local dz = math.abs(position.Z - cell.Position.Z)
            if dx <= cell.Size.X * 0.5 + 0.1 and dz <= cell.Size.Z * 0.5 + 0.1 then
                return cell
            end
        end
    end
    return nil
end

function Feature.getShapeOccupiedCellNames(footprint, anchorCell, gridMap, cells)
    if not footprint or not footprint.shapeModel or not anchorCell then
        return nil
    end

    local placementConfig = State.placementConfig or {}
    local yOffset = tonumber(placementConfig.YOffset) or 0
    local shapeCFrame = (anchorCell.CFrame + Vector3.new(0, yOffset, 0)) * (footprint.pivotOffset or CFrame.new())
    local occupied = {}
    local seen = {}
    local partOffsets = footprint.partOffsets
    if type(partOffsets) ~= "table" or #partOffsets == 0 then
        return nil
    end
    for _, partOffset in ipairs(partOffsets) do
        local partCFrame = shapeCFrame * partOffset
        local cell = Feature.getContainingGridCellForPosition(partCFrame.Position, gridMap)
        if not cell or seen[cell.Name] then
            return nil
        end
        seen[cell.Name] = true
        table.insert(occupied, cell.Name)
    end

    if #occupied == 0 then
        return nil
    end
    return occupied, shapeCFrame
end

function Feature.refreshPlacementOccupancy(gridMap)
    local plot = Feature.getOwnedPlot()
    local occupancy = {}
    for name, cell in pairs(gridMap or {}) do
        if cell:GetAttribute("Occupied") == true or cell:GetAttribute("Taken") == true then
            occupancy[name] = true
        end
    end
    if not plot then
        return occupancy
    end

    for _, containerName in ipairs({ "Fighters", "PlacedCharacters", "Builds", "Characters" }) do
        local container = plot:FindFirstChild(containerName)
        if container then
            for _, model in ipairs(container:GetChildren()) do
                local cellsText = model:GetAttribute("Cells") or model:GetAttribute("GridCells")
                if type(cellsText) == "string" then
                    for cellName in cellsText:gmatch("[^,]+") do
                        occupancy[cellName] = model
                    end
                end

                local shape = model:FindFirstChild("Shape")
                if shape then
                    for _, part in ipairs(Feature.getShapeParts(shape)) do
                        local cell = Feature.getContainingGridCell(part, gridMap)
                        if cell then
                            occupancy[cell.Name] = model
                        end
                    end
                end
            end
        end
    end
    return occupancy
end

function Feature.getLineupRarityValue(rarity)
    local rank = rarityRank(rarity)
    if rank >= 999 then
        return 0
    end
    return math.max(0, 10 - rank)
end

function Feature.getLineupMutationTierValue(mutationName)
    local info = Feature.getMutationInfo(mutationName)
    local rarity = info and (info.Rarity or info.rarity or info.Tier or info.tier)
    local rarityValue = Feature.getLineupRarityValue(rarity)
    local multiplier = math.max(tonumber(info and (info.DamageMultiplier or info.Multiplier or info.Damage)) or 1, 1)
    return rarityValue + math.max(0, multiplier - 1)
end

function Feature.getLineupTraitTierValue(traitName)
    local info = Feature.getTraitInfo(traitName)
    local rarity = (info and (info.Rarity or info.rarity or info.Tier or info.tier))
        or State.traitRarity and State.traitRarity[tostring(traitName or "")]
        or State.traitRarity and State.traitRarity[normalizedLookupKey(traitName)]
        or TRAIT_RARITY_FALLBACK[tostring(traitName or "")]
    local rarityValue = Feature.getLineupRarityValue(rarity)
    local damage = math.max(tonumber(info and info.Damage) or 1, 1)
    local cooldown = math.max(tonumber(info and info.Cooldown) or 1, 0.05)
    local range = math.max(tonumber(info and info.Range) or 1, 1)
    local critChance = math.max(tonumber(info and info.CritChance) or 0, 0)
    local critDamage = math.max(tonumber(info and info.CritDamage) or 1, 1)
    local statValue = math.max(0, damage - 1) + math.max(0, 1 - cooldown) + math.max(0, range - 1) * 0.25
        + (critChance / 100) * math.max(0, critDamage - 1)
    return rarityValue + statValue
end

function Feature.getLineupUnitTierScore(unit, derived)
    return Feature.getLineupRarityValue(derived and derived.rarity) * (tonumber(Config.bestLineup.rarityTierWeight) or 0)
        + Feature.getLineupMutationTierValue(unit and unit.mutation) * (tonumber(Config.bestLineup.mutationTierWeight) or 0)
        + Feature.getLineupTraitTierValue(unit and unit.trait) * (tonumber(Config.bestLineup.traitTierWeight) or 0)
end

function Feature.scoreLineupUnit(unit)
    local derived = Feature.computeUnitDerivedStats(unit)
    if not derived then
        return nil
    end

    local rarityBonus = math.max(0, 10 - rarityRank(derived.rarity)) * (tonumber(Config.bestLineup.rarityWeight) or 0)
    local rngBonus = derived.rng > 0 and (1 / math.max(derived.rng, 0.001)) * (tonumber(Config.bestLineup.rngWeight) or 0) or 0
    local areaBonus = (derived.splashRadius * 0.18) + (derived.lineWidth * 0.12)
    local cadenceBonus = derived.cooldown > 0 and (1 / math.max(derived.cooldown, 0.05)) * (tonumber(Config.bestLineup.cooldownWeight) or 0) or 0
    local statScore = derived.dps * (tonumber(Config.bestLineup.dpsWeight) or 1.25)
        + derived.damage * (tonumber(Config.bestLineup.damageWeight) or 0.12)
        + derived.range * (tonumber(Config.bestLineup.rangeWeight) or 0)
        + cadenceBonus
        + rarityBonus
        + (tonumber(derived.level) or 1) * (tonumber(Config.bestLineup.levelWeight) or 0)
        + rngBonus
        + areaBonus
    local tierScore = Feature.getLineupUnitTierScore(unit, derived)

    return statScore + tierScore * (tonumber(Config.bestLineup.tierSupportWeight) or 0.05), derived, tierScore, statScore
end

function Feature.getLineupDpsDensityScore(derived, spots)
    local cells = math.max(tonumber(spots) or 1, 1)
    local dps = math.max(tonumber(derived and derived.dps) or 0, 0)
    local dpsPerCell = dps / cells
    return dpsPerCell * (tonumber(Config.bestLineup.dpsPerCellWeight) or 0.85), dpsPerCell
end

function Feature.getLineupFrontReferencePosition(cells)
    local plot = Feature.getOwnedPlot()
    local references = {}

    local function addReference(instance)
        if not instance then
            return
        end
        if instance:IsA("BasePart") then
            table.insert(references, instance.Position)
            return
        end
        if instance:IsA("Model") then
            local part = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
            if part then
                table.insert(references, part.Position)
            end
            return
        end
        if instance:IsA("Instance") then
            local part = instance:FindFirstChildWhichIsA("BasePart", true)
            if part then
                table.insert(references, part.Position)
            end
        end
    end

    if plot then
        for _, descendant in ipairs(plot:GetDescendants()) do
            local name = normalizeText(descendant.Name)
            local fullName = normalizeText(descendant:GetFullName())
            if name:find("enemybase", 1, true) or name:find("enemy base", 1, true)
                or name:find("spawn", 1, true) or name:find("gate", 1, true)
                or fullName:find("enemyspawn", 1, true) or fullName:find("enemy spawn", 1, true) then
                addReference(descendant)
            end
        end
    end

    if #references > 0 then
        local sum = Vector3.zero
        for _, position in ipairs(references) do
            sum += position
        end
        return sum / #references
    end

    local minZ = math.huge
    local sumX = 0
    local count = 0
    local cellSize = 4
    for _, cell in ipairs(cells or {}) do
        if cell:IsA("BasePart") then
            minZ = math.min(minZ, cell.Position.Z)
            sumX += cell.Position.X
            count += 1
            cellSize = math.max(cellSize, cell.Size.Z)
        end
    end
    if count == 0 then
        return nil
    end

    return Vector3.new(sumX / count, 0, minZ - cellSize * 6)
end

function Feature.getLineupCellMetrics(cells)
    local reference = Feature.getLineupFrontReferencePosition(cells)
    local metrics = {
        frontReference = reference,
        minFrontDistance = math.huge,
        maxFrontDistance = -math.huge,
    }
    if not reference then
        metrics.minFrontDistance = 0
        metrics.maxFrontDistance = 1
        return metrics
    end

    for _, cell in ipairs(cells or {}) do
        if cell:IsA("BasePart") then
            local distance = (Vector3.new(cell.Position.X, 0, cell.Position.Z) - Vector3.new(reference.X, 0, reference.Z)).Magnitude
            metrics.minFrontDistance = math.min(metrics.minFrontDistance, distance)
            metrics.maxFrontDistance = math.max(metrics.maxFrontDistance, distance)
        end
    end
    if metrics.minFrontDistance == math.huge then
        metrics.minFrontDistance = 0
        metrics.maxFrontDistance = 1
    end
    return metrics
end

function Feature.assignLineupFrontPriorities(candidates)
    local minRange = math.huge
    local maxRange = -math.huge
    local maxDps = 0
    for _, candidate in ipairs(candidates or {}) do
        local range = tonumber(candidate.derived and candidate.derived.range) or 0
        local dps = tonumber(candidate.derived and candidate.derived.dps) or 0
        minRange = math.min(minRange, range)
        maxRange = math.max(maxRange, range)
        maxDps = math.max(maxDps, dps)
    end
    if minRange == math.huge then
        return candidates
    end

    local rangeSpan = maxRange - minRange
    for _, candidate in ipairs(candidates or {}) do
        local range = tonumber(candidate.derived and candidate.derived.range) or 0
        local dps = tonumber(candidate.derived and candidate.derived.dps) or 0
        local lowRange = rangeSpan > 0 and (maxRange - range) / rangeSpan or 0
        local highDps = maxDps > 0 and dps / maxDps or 0
        candidate.frontPriority = lowRange * (tonumber(Config.bestLineup.frontRangeWeight) or 0.72)
            + highDps * (tonumber(Config.bestLineup.frontDpsWeight) or 0.28)
    end
    return candidates
end

function Feature.getLineupPlacementFrontScore(placement, gridMap, metrics)
    if not (placement and metrics and metrics.frontReference) then
        return 0
    end

    local total = 0
    local count = 0
    for _, cellName in ipairs(placement.occupiedCells or {}) do
        local cell = gridMap and gridMap[cellName]
        if cell and cell:IsA("BasePart") then
            local distance = (Vector3.new(cell.Position.X, 0, cell.Position.Z) - Vector3.new(metrics.frontReference.X, 0, metrics.frontReference.Z)).Magnitude
            total += distance
            count += 1
        end
    end
    if count == 0 then
        return 0
    end

    local span = math.max((metrics.maxFrontDistance or 1) - (metrics.minFrontDistance or 0), 0.001)
    local averageDistance = total / count
    return math.clamp(1 - ((averageDistance - (metrics.minFrontDistance or 0)) / span), 0, 1)
end

function Feature.getLineupPlacementMinFrontScore(placement, gridMap, metrics)
    if not (placement and metrics and metrics.frontReference) then
        return 0
    end

    local lowest = math.huge
    local found = false
    for _, cellName in ipairs(placement.occupiedCells or {}) do
        local score = Feature.getLineupPlacementFrontScore({ occupiedCells = { cellName } }, gridMap, metrics)
        if score < lowest then
            lowest = score
        end
        found = true
    end

    return found and lowest or 0
end

function Feature.areLineupCellsAdjacent(a, b)
    if not (a and b and a:IsA("BasePart") and b:IsA("BasePart")) then
        return false
    end

    local dx = math.abs(a.Position.X - b.Position.X)
    local dz = math.abs(a.Position.Z - b.Position.Z)
    local xTouch = dx <= ((a.Size.X + b.Size.X) * 0.55 + 0.2)
    local zTouch = dz <= ((a.Size.Z + b.Size.Z) * 0.55 + 0.2)
    local sameColumn = dx <= (math.min(a.Size.X, b.Size.X) * 0.35 + 0.2)
    local sameRow = dz <= (math.min(a.Size.Z, b.Size.Z) * 0.35 + 0.2)
    return (xTouch and sameRow) or (zTouch and sameColumn)
end

function Feature.getLineupPlacementCompactnessScore(placement, occupancy, gridMap)
    local placementCells = {}
    local placementSet = {}
    for _, cellName in ipairs(placement and placement.occupiedCells or {}) do
        local cell = gridMap and gridMap[cellName]
        if cell and cell:IsA("BasePart") then
            placementSet[cellName] = true
            table.insert(placementCells, cell)
        end
    end
    if #placementCells == 0 then
        return 0
    end

    local adjacentEdges = 0
    local existingCells = 0
    for cellName in pairs(occupancy or {}) do
        if not placementSet[cellName] then
            local existingCell = gridMap and gridMap[cellName]
            if existingCell and existingCell:IsA("BasePart") then
                existingCells += 1
                for _, placementCell in ipairs(placementCells) do
                    if Feature.areLineupCellsAdjacent(placementCell, existingCell) then
                        adjacentEdges += 1
                    end
                end
            end
        end
    end

    local internalEdges = 0
    for i = 1, #placementCells do
        for j = i + 1, #placementCells do
            if Feature.areLineupCellsAdjacent(placementCells[i], placementCells[j]) then
                internalEdges += 1
            end
        end
    end

    local score = (adjacentEdges + internalEdges * 0.25) / math.max(#placementCells, 1)
    if existingCells > 0 and adjacentEdges == 0 then
        score -= #placementCells * 0.5
    end
    return score
end

function Feature.getLineupPlanSpaceScore(plan, gridMap, baseOccupancy)
    local used = {}
    for cellName in pairs(baseOccupancy or {}) do
        if gridMap and gridMap[cellName] then
            used[cellName] = true
        end
    end

    local hasPlanCells = false
    for _, item in ipairs(plan or {}) do
        for _, cellName in ipairs(item and item.placement and item.placement.occupiedCells or {}) do
            if gridMap and gridMap[cellName] then
                used[cellName] = true
                hasPlanCells = true
            end
        end
    end
    if not hasPlanCells then
        return 0
    end

    local minX, maxX = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    local stepX, stepZ = math.huge, math.huge
    local usedCount = 0
    local cells = {}
    for cellName in pairs(used) do
        local cell = gridMap and gridMap[cellName]
        if cell and cell:IsA("BasePart") then
            usedCount += 1
            table.insert(cells, cell)
            minX = math.min(minX, cell.Position.X)
            maxX = math.max(maxX, cell.Position.X)
            minZ = math.min(minZ, cell.Position.Z)
            maxZ = math.max(maxZ, cell.Position.Z)
            stepX = math.min(stepX, math.max(cell.Size.X, 0.001))
            stepZ = math.min(stepZ, math.max(cell.Size.Z, 0.001))
        end
    end
    if usedCount == 0 or minX == math.huge then
        return 0
    end

    local columns = math.max(1, math.floor((maxX - minX) / math.max(stepX, 0.001) + 0.5) + 1)
    local rows = math.max(1, math.floor((maxZ - minZ) / math.max(stepZ, 0.001) + 0.5) + 1)
    local boundingArea = math.max(usedCount, columns * rows)
    local gapCount = math.max(0, boundingArea - usedCount)
    local density = usedCount / math.max(boundingArea, 1)

    local adjacencyEdges = 0
    for i = 1, #cells do
        for j = i + 1, #cells do
            if Feature.areLineupCellsAdjacent(cells[i], cells[j]) then
                adjacencyEdges += 1
            end
        end
    end

    return density * (tonumber(Config.bestLineup.compactnessWeight) or 0)
        + (adjacencyEdges / math.max(usedCount, 1)) * (tonumber(Config.bestLineup.adjacencyWeight) or 0)
        - gapCount * (tonumber(Config.bestLineup.gapPenaltyWeight) or 0)
end

function Feature.getLineupPlacementValue(candidate)
    local scoreValue = (tonumber(candidate and candidate.score) or 0) * (tonumber(Config.bestLineup.frontValueWeight) or 1.25)
    local dpsValue = (tonumber(candidate and candidate.derived and candidate.derived.dps) or 0)
    return math.max(scoreValue, dpsValue)
end

function Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics, occupancy)
    local frontScore = Feature.getLineupPlacementFrontScore(placement, gridMap, metrics)
    local flatValue = tonumber(Config.bestLineup.placementQualityWeight) or 0
    return frontScore * (tonumber(candidate and candidate.frontPriority) or 0) * (flatValue + Feature.getLineupPlacementValue(candidate))
end

function Feature.sortBestLineupPlacementOptions(candidate, options, gridMap, metrics, occupancy)
    table.sort(options, function(a, b)
        local scoreA = Feature.getLineupPlacementScore(candidate, a, gridMap, metrics, occupancy)
        local scoreB = Feature.getLineupPlacementScore(candidate, b, gridMap, metrics, occupancy)
        if scoreA ~= scoreB then
            return scoreA > scoreB
        end
        local compactA = Feature.getLineupPlacementCompactnessScore(a, occupancy, gridMap)
        local compactB = Feature.getLineupPlacementCompactnessScore(b, occupancy, gridMap)
        if compactA ~= compactB then
            return compactA > compactB
        end
        local countA = #(a.occupiedCells or {})
        local countB = #(b.occupiedCells or {})
        if countA ~= countB then
            return countA > countB
        end
        return tostring(a.hoveredCellName) < tostring(b.hoveredCellName)
    end)
    return options
end

function Feature.findBestLineupPlacement(candidate, cells, gridMap, occupancy)
    for _, cell in ipairs(cells or {}) do
        local occupiedCells, shapeCFrame = Feature.getShapeOccupiedCellNames(candidate.footprint, cell, gridMap, cells)
        if occupiedCells then
            local blocked = false
            for _, cellName in ipairs(occupiedCells) do
                if occupancy[cellName] then
                    blocked = true
                    break
                end
            end
            if not blocked then
                for _, cellName in ipairs(occupiedCells) do
                    occupancy[cellName] = candidate.unit
                end
                return {
                    shapeName = candidate.footprint.shapeName,
                    hoveredCellName = cell.Name,
                    shapeCFrame = shapeCFrame,
                    occupiedCells = occupiedCells,
                }
            end
        end
    end
    return nil
end

function Feature.equipUnitForPlacement(unit)
    if not unit then
        return false
    end

    local finder = Feature.findUnitTool
    local tool = type(finder) == "function" and finder(unit) or nil
    if not tool then
        State.scanUnits()
        tool = type(finder) == "function" and finder(unit) or nil
    end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not tool or not humanoid then
        Log.push("Best lineup skipped: could not find tool for " .. tostring(unit.name) .. ".")
        return false
    end

    if tool.Parent ~= character then
        humanoid:EquipTool(tool)
        task.wait(0.22)
    end
    return tool.Parent == character
end

function Feature.placeCharacterAndWait(item)
    local remote = Remote.get("PlaceCharacter")
    if not remote or not remote:IsA("RemoteEvent") then
        Log.push("Missing RemoteEvent: PlaceCharacter")
        return false
    end
    if not Remote.canSend("PlaceCharacter") then
        return false
    end

    local response = nil
    local connection = remote.OnClientEvent:Connect(function(payload)
        response = payload
    end)
    local ok, err = pcall(function()
        remote:FireServer({
            CharacterName = item.unit.name,
            ShapeName = item.placement.shapeName,
            HoveredCellName = item.placement.hoveredCellName,
            ShapeCFrame = item.placement.shapeCFrame,
        })
    end)
    if not ok then
        connection:Disconnect()
        Log.push("Place failed " .. tostring(item.unit.name) .. ": " .. tostring(err))
        return false
    end

    local started = os.clock()
    while response == nil and os.clock() - started < 2 do
        task.wait()
    end
    connection:Disconnect()

    if type(response) == "table" then
        if response.Success == false then
            Log.push("Place rejected " .. tostring(item.unit.name) .. ": " .. tostring(response.Message or "server rejected"))
            return false
        end
        if response.Success == true then
            return true
        end
    end

    Log.push("Place timed out waiting for " .. tostring(item.unit.name) .. ".")
    return false
end

function Feature.pickupBestLineupUnits()
    if Feature.isWaveStarted() then
        return 0
    end

    State.scanUnits()
    local picked = 0
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:UnequipTools()
        task.wait(0.08)
    end

    for _, unit in ipairs(State.characters) do
        if unit.placed then
            if Feature.pickupUnitForMerge(unit) then
                picked += 1
            end
        end
    end
    if picked > 0 then
        task.wait(math.max(Config.safety.remoteCooldown, 0.12))
    end
    State.scanUnits()
    return picked
end

function Feature.ensureBestLineupData()
    local missingSharedData = not State.characterInfoByName or not next(State.characterInfoByName)
        or not State.mutationInfoByName or not next(State.mutationInfoByName)
        or not State.traitInfoByName or not next(State.traitInfoByName)
        or not State.placementHelper
        or not State.placementConfig

    if missingSharedData then
        State.loadSharedInfo()
    end

    State.shapeFootprints = State.shapeFootprints or {}
end

function Feature.copyLineupOccupancy(occupancy)
    local copy = {}
    for key, value in pairs(occupancy or {}) do
        copy[key] = value
    end
    return copy
end

function Feature.lineupOccupancyKey(occupancy)
    local names = {}
    for key in pairs(occupancy or {}) do
        table.insert(names, tostring(key))
    end
    table.sort(names)
    return table.concat(names, ",")
end

function Feature.getBestLineupPlacementOptions(candidate, cells, gridMap, occupancy, metrics)
    local options = {}
    local source = candidate and candidate.placementOptions
    if source then
        for _, placement in ipairs(source) do
            local blocked = false
            for _, cellName in ipairs(placement.occupiedCells or {}) do
                if occupancy and occupancy[cellName] then
                    blocked = true
                    break
                end
            end
            if not blocked then
                table.insert(options, placement)
            end
        end
        return Feature.sortBestLineupPlacementOptions(candidate, options, gridMap, metrics, occupancy)
    end

    for _, cell in ipairs(cells or {}) do
        local occupiedCells, shapeCFrame = Feature.getShapeOccupiedCellNames(candidate.footprint, cell, gridMap, cells)
        if occupiedCells then
            local blocked = false
            for _, cellName in ipairs(occupiedCells) do
                if occupancy[cellName] then
                    blocked = true
                    break
                end
            end
            if not blocked then
                table.insert(options, {
                    shapeName = candidate.footprint.shapeName,
                    hoveredCellName = cell.Name,
                    cell = cell,
                    shapeCFrame = shapeCFrame,
                    occupiedCells = occupiedCells,
                })
            end
        end
    end
    return Feature.sortBestLineupPlacementOptions(candidate, options, gridMap, metrics, occupancy)
end

function Feature.prepareBestLineupCandidatePlacements(candidates, cells, gridMap, metrics)
    for _, candidate in ipairs(candidates or {}) do
        candidate.placementOptions = Feature.getBestLineupPlacementOptions(candidate, cells, gridMap, {}, metrics)
    end
    return candidates
end

function Feature.buildBestLineupCandidates(includeEquipped)
    State.scanUnits()
    local allCandidates = {}
    for _, unit in ipairs(State.characters) do
        if not unit.crafting and not unit.cloning and (includeEquipped or not unit.equipped) then
            local score, derived, tierScore, statScore = Feature.scoreLineupUnit(unit)
            local footprint = Feature.getShapeFootprint(unit.name)
            if score and footprint then
                local spots = math.max(footprint.spots or 1, 1)
                local penalty = math.max(0, 1 - math.min(0.45, (spots - 1) * (tonumber(Config.bestLineup.footprintPenalty) or 0)))
                local tierSupport = tonumber(Config.bestLineup.tierSupportWeight) or 0.05
                local dpsDensityScore, dpsPerCell = Feature.getLineupDpsDensityScore(derived, spots)
                local adjustedStatScore = statScore * penalty
                local baseScore = adjustedStatScore + dpsDensityScore + tierScore * tierSupport
                table.insert(allCandidates, {
                    unit = unit,
                    derived = derived,
                    footprint = footprint,
                    tierScore = tierScore,
                    statScore = adjustedStatScore,
                    dpsPerCell = dpsPerCell,
                    dpsDensityScore = dpsDensityScore,
                    score = baseScore,
                    scorePerSpot = baseScore / math.max(spots, 1),
                })
            end
        end
    end
    Feature.assignLineupFrontPriorities(allCandidates)

    local byTier = Feature.sortLineupCandidatesByTier(allCandidates)

    local byDps = copyArray(allCandidates)
    table.sort(byDps, function(a, b)
        if a.derived.dps ~= b.derived.dps then
            return a.derived.dps > b.derived.dps
        end
        if a.dpsPerCell ~= b.dpsPerCell then
            return a.dpsPerCell > b.dpsPerCell
        end
        if a.score ~= b.score then
            return a.score > b.score
        end
        return tostring(a.unit.id) < tostring(b.unit.id)
    end)

    local byDamage = copyArray(allCandidates)
    table.sort(byDamage, function(a, b)
        if a.derived.damage ~= b.derived.damage then
            return a.derived.damage > b.derived.damage
        end
        if a.derived.dps ~= b.derived.dps then
            return a.derived.dps > b.derived.dps
        end
        if a.dpsPerCell ~= b.dpsPerCell then
            return a.dpsPerCell > b.dpsPerCell
        end
        if a.score ~= b.score then
            return a.score > b.score
        end
        return tostring(a.unit.id) < tostring(b.unit.id)
    end)

    local byDensity = copyArray(allCandidates)
    table.sort(byDensity, function(a, b)
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        if a.scorePerSpot ~= b.scorePerSpot then
            return a.scorePerSpot > b.scorePerSpot
        end
        if a.derived.dps ~= b.derived.dps then
            return a.derived.dps > b.derived.dps
        end
        return tostring(a.unit.id) < tostring(b.unit.id)
    end)

    local byFrontNeed = Feature.sortLineupCandidatesByFrontNeed(allCandidates)

    local selected = {}
    local candidates = {}
    local limit = math.max(1, tonumber(Config.bestLineup.candidateLimit) or #allCandidates)
    local function addFrom(list, count)
        local added = 0
        for _, candidate in ipairs(list) do
            if #candidates >= limit or added >= count then
                break
            end
            local id = tostring(candidate.unit and candidate.unit.id or "")
            if id ~= "" and not selected[id] then
                selected[id] = true
                table.insert(candidates, candidate)
                added += 1
            end
        end
    end

    addFrom(byDps, math.max(1, tonumber(Config.bestLineup.dpsCandidateLimit) or limit))
    addFrom(byDamage, math.max(1, tonumber(Config.bestLineup.damageCandidateLimit) or limit))
    addFrom(byTier, math.max(1, tonumber(Config.bestLineup.tierCandidateLimit) or limit))
    addFrom(byFrontNeed, math.max(1, tonumber(Config.bestLineup.frontCandidateLimit) or limit))
    addFrom(byDensity, math.max(1, tonumber(Config.bestLineup.densityCandidateLimit) or limit))
    if #candidates < limit then
        addFrom(byDps, limit)
    end

    candidates = Feature.sortLineupCandidatesByCombat(candidates)
    return candidates, allCandidates
end

function Feature.getBestLineupFillCandidates(primaryCandidates, allCandidates)
    local limit = math.max(1, tonumber(Config.bestLineup.fillCandidateLimit) or #(allCandidates or {}))
    local selected = {}
    local fillCandidates = {}

    local function add(candidate)
        local id = tostring(candidate and candidate.unit and candidate.unit.id or "")
        if id == "" or selected[id] then
            return
        end
        selected[id] = true
        table.insert(fillCandidates, candidate)
    end

    for _, candidate in ipairs(primaryCandidates or {}) do
        add(candidate)
    end

    local byScore = copyArray(allCandidates or {})
    table.sort(byScore, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        if a.scorePerSpot ~= b.scorePerSpot then
            return a.scorePerSpot > b.scorePerSpot
        end
        if a.derived.dps ~= b.derived.dps then
            return a.derived.dps > b.derived.dps
        end
        return tostring(a.unit.id) < tostring(b.unit.id)
    end)

    for _, candidate in ipairs(byScore) do
        if #fillCandidates >= limit then
            break
        end
        add(candidate)
    end

    return fillCandidates
end

function Feature.rankBestLineupStates(states, limit)
    table.sort(states, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.cellsUsed ~= b.cellsUsed then
            return a.cellsUsed > b.cellsUsed
        end
        return #a.plan > #b.plan
    end)

    local deduped = {}
    local seen = {}
    for _, state in ipairs(states) do
        local key = Feature.lineupOccupancyKey(state.occupancy)
        if not seen[key] then
            seen[key] = true
            table.insert(deduped, state)
            if #deduped >= limit then
                break
            end
        end
    end
    return deduped
end

function Feature.getLineupCandidateKey(candidate)
    return tostring(candidate and candidate.unit and candidate.unit.id or "")
end

function Feature.makeLineupPlanItem(candidate, placement, gridMap, metrics)
    return {
        unit = candidate.unit,
        derived = candidate.derived,
        score = candidate.score,
        statScore = candidate.statScore,
        tierScore = candidate.tierScore,
        dpsPerCell = candidate.dpsPerCell,
        dpsDensityScore = candidate.dpsDensityScore,
        scorePerSpot = candidate.scorePerSpot,
        frontPriority = candidate.frontPriority,
        frontScore = gridMap and metrics and Feature.getLineupPlacementFrontScore(placement, gridMap, metrics) or nil,
        placement = placement,
    }
end

function Feature.getLineupPlanStats(plan, baseOccupancy)
    local occupancy = Feature.copyLineupOccupancy(baseOccupancy)
    local selected = {}
    local itemSet = {}
    for _, item in ipairs(plan or {}) do
        itemSet[item] = true
        local id = tostring(item and item.unit and item.unit.id or "")
        if id ~= "" then
            selected[id] = true
        end
        for _, cellName in ipairs(item and item.placement and item.placement.occupiedCells or {}) do
            occupancy[cellName] = item
        end
    end
    return occupancy, selected, itemSet
end

function Feature.getLineupPlanItemValue(candidate, placement, gridMap, metrics, occupancy)
    local cells = placement and placement.occupiedCells or {}
    return (tonumber(candidate and candidate.score) or 0)
        + #cells * (tonumber(Config.bestLineup.fillWeight) or 0)
        + Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics, occupancy)
end

function Feature.getLineupPlacedItemValue(item)
    local cells = item and item.placement and item.placement.occupiedCells or {}
    return (tonumber(item and item.score) or 0)
        + #cells * (tonumber(Config.bestLineup.fillWeight) or 0)
        + (tonumber(item and item.placementScore) or 0)
end

function Feature.scoreBestLineupPlan(plan, gridMap, baseOccupancy)
    local total = 0
    for _, item in ipairs(plan or {}) do
        total += Feature.getLineupPlacedItemValue(item)
    end
    total += Feature.getLineupRangeOrderScore(plan) * (tonumber(Config.bestLineup.rangeOrderWeight) or 0)
    local planSpaceScore = Feature.getLineupPlanSpaceScore(plan, gridMap, baseOccupancy)
    total += planSpaceScore
    return total
end

function Feature.getLineupRangeOrderScore(plan)
    local penalty = 0
    local tolerance = tonumber(Config.bestLineup.rangeOrderTolerance) or 0
    local items = plan or {}

    for i = 1, #items do
        local a = items[i]
        local rangeA = tonumber(a and a.derived and a.derived.range) or 0
        local frontA = tonumber(a and a.frontScore) or 0
        for j = i + 1, #items do
            local b = items[j]
            local rangeB = tonumber(b and b.derived and b.derived.range) or 0
            local frontB = tonumber(b and b.frontScore) or 0
            local shortRange, shortFront, longRange, longFront = rangeA, frontA, rangeB, frontB
            if rangeB < rangeA then
                shortRange, shortFront, longRange, longFront = rangeB, frontB, rangeA, frontA
            end

            local rangeDiff = longRange - shortRange
            local frontDiff = longFront - shortFront
            if rangeDiff > tolerance and frontDiff > 0 then
                penalty += rangeDiff * frontDiff
            end
        end
    end

    return -penalty
end

function Feature.sortLineupCandidatesByCombat(candidates)
    local ordered = copyArray(candidates or {})
    table.sort(ordered, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        local dpsA = tonumber(a and a.derived and a.derived.dps) or 0
        local dpsB = tonumber(b and b.derived and b.derived.dps) or 0
        if dpsA ~= dpsB then
            return dpsA > dpsB
        end
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        local damageA = tonumber(a and a.derived and a.derived.damage) or 0
        local damageB = tonumber(b and b.derived and b.derived.damage) or 0
        if damageA ~= damageB then
            return damageA > damageB
        end
        if a.tierScore ~= b.tierScore then
            return a.tierScore > b.tierScore
        end
        if a.scorePerSpot ~= b.scorePerSpot then
            return a.scorePerSpot > b.scorePerSpot
        end
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)
    return ordered
end

function Feature.orderBestLineupPlanForPlacement(plan)
    local ordered = copyArray(plan or {})
    table.sort(ordered, function(a, b)
        local scoreA = tonumber(a and a.score) or 0
        local scoreB = tonumber(b and b.score) or 0
        if scoreA ~= scoreB then
            return scoreA > scoreB
        end
        local dpsA = tonumber(a and a.derived and a.derived.dps) or 0
        local dpsB = tonumber(b and b.derived and b.derived.dps) or 0
        if dpsA ~= dpsB then
            return dpsA > dpsB
        end
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        local damageA = tonumber(a and a.derived and a.derived.damage) or 0
        local damageB = tonumber(b and b.derived and b.derived.damage) or 0
        if damageA ~= damageB then
            return damageA > damageB
        end
        local rangeA = tonumber(a and a.derived and a.derived.range) or 0
        local rangeB = tonumber(b and b.derived and b.derived.range) or 0
        if rangeA ~= rangeB then
            return rangeA < rangeB
        end
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)
    return ordered
end

function Feature.sortLineupCandidatesByTier(candidates)
    local ordered = copyArray(candidates or {})
    table.sort(ordered, function(a, b)
        if a.tierScore ~= b.tierScore then
            return a.tierScore > b.tierScore
        end
        if a.score ~= b.score then
            return a.score > b.score
        end
        local dpsA = tonumber(a and a.derived and a.derived.dps) or 0
        local dpsB = tonumber(b and b.derived and b.derived.dps) or 0
        if dpsA ~= dpsB then
            return dpsA > dpsB
        end
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)
    return ordered
end

function Feature.sortLineupCandidatesByScore(candidates)
    local ordered = copyArray(candidates or {})
    table.sort(ordered, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.derived.dps ~= b.derived.dps then
            return a.derived.dps > b.derived.dps
        end
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        local damageA = tonumber(a and a.derived and a.derived.damage) or 0
        local damageB = tonumber(b and b.derived and b.derived.damage) or 0
        if damageA ~= damageB then
            return damageA > damageB
        end
        if a.tierScore ~= b.tierScore then
            return a.tierScore > b.tierScore
        end
        if a.scorePerSpot ~= b.scorePerSpot then
            return a.scorePerSpot > b.scorePerSpot
        end
        return tostring(a.unit.id) < tostring(b.unit.id)
    end)
    return ordered
end

function Feature.sortLineupCandidatesByFrontNeed(candidates)
    local ordered = copyArray(candidates or {})
    table.sort(ordered, function(a, b)
        if a.tierScore ~= b.tierScore then
            return a.tierScore > b.tierScore
        end
        local frontA = (tonumber(a and a.frontPriority) or 0) * (tonumber(a and a.score) or 0)
        local frontB = (tonumber(b and b.frontPriority) or 0) * (tonumber(b and b.score) or 0)
        if frontA ~= frontB then
            return frontA > frontB
        end
        local rangeA = tonumber(a and a.derived and a.derived.range) or math.huge
        local rangeB = tonumber(b and b.derived and b.derived.range) or math.huge
        if rangeA ~= rangeB then
            return rangeA < rangeB
        end
        local dpsA = tonumber(a and a.derived and a.derived.dps) or 0
        local dpsB = tonumber(b and b.derived and b.derived.dps) or 0
        if dpsA ~= dpsB then
            return dpsA > dpsB
        end
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)
    return ordered
end

function Feature.rebuildBestLineupPlanByRange(plan, candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics)
    if Config.bestLineup.rangeOrderRebuild == false then
        return plan or {}
    end

    local byId = {}
    for _, candidate in ipairs(candidates or {}) do
        local id = Feature.getLineupCandidateKey(candidate)
        if id ~= "" then
            byId[id] = candidate
        end
    end

    local selected = {}
    for _, item in ipairs(plan or {}) do
        local id = tostring(item and item.unit and item.unit.id or "")
        local candidate = byId[id]
        if candidate then
            table.insert(selected, candidate)
        end
    end
    if #selected == 0 then
        return plan or {}
    end

    local tolerance = tonumber(Config.bestLineup.rangeOrderTolerance) or 0
    table.sort(selected, function(a, b)
        local rangeA = tonumber(a and a.derived and a.derived.range) or math.huge
        local rangeB = tonumber(b and b.derived and b.derived.range) or math.huge
        if math.abs(rangeA - rangeB) > tolerance then
            return rangeA < rangeB
        end
        local frontA = tonumber(a and a.frontPriority) or 0
        local frontB = tonumber(b and b.frontPriority) or 0
        if frontA ~= frontB then
            return frontA > frontB
        end
        local dpsA = tonumber(a and a.derived and a.derived.dps) or 0
        local dpsB = tonumber(b and b.derived and b.derived.dps) or 0
        if dpsA ~= dpsB then
            return dpsA > dpsB
        end
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)

    local occupancy = Feature.copyLineupOccupancy(baseOccupancy)
    local rebuilt = {}
    local placementLimit = tonumber(maxPlacements) or math.huge
    for _, candidate in ipairs(selected) do
        if #rebuilt >= placementLimit then
            break
        end
        local options = Feature.getBestLineupPlacementOptions(candidate, cells, gridMap, occupancy, metrics)
        local placement = options[1]
        if placement then
            local item = Feature.makeLineupPlanItem(candidate, placement, gridMap, metrics)
            item.placementScore = Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics, occupancy)
            table.insert(rebuilt, item)
            for _, cellName in ipairs(placement.occupiedCells or {}) do
                occupancy[cellName] = item
            end
        end
    end

    rebuilt = Feature.fillBestLineupPlan(rebuilt, candidates, cells, gridMap, placementLimit, baseOccupancy, metrics)
    if Feature.scoreBestLineupPlan(rebuilt, gridMap, baseOccupancy) > Feature.scoreBestLineupPlan(plan, gridMap, baseOccupancy) then
        return rebuilt
    end
    return plan or {}
end

function Feature.shouldSkipLineupFillerPlacement(candidate, placement, gridMap, metrics)
    local range = tonumber(candidate and candidate.derived and candidate.derived.range) or math.huge
    local shortRangeLimit = tonumber(Config.bestLineup.shortRangeBackLimit) or 0
    if range > shortRangeLimit then
        return false
    end

    local frontScore = Feature.getLineupPlacementMinFrontScore(placement, gridMap, metrics)
    local minFrontScore = tonumber(Config.bestLineup.shortRangeBackMinFrontScore) or 0
    return frontScore < minFrontScore
end

function Feature.fillBestLineupPlan(plan, candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics)
    local filled = copyArray(plan or {})
    local occupancy, selected = Feature.getLineupPlanStats(filled, baseOccupancy)
    local placementLimit = tonumber(maxPlacements) or math.huge

    for _, candidate in ipairs(Feature.sortLineupCandidatesByScore(candidates)) do
        if #filled >= placementLimit then
            break
        end
        local id = Feature.getLineupCandidateKey(candidate)
        if id ~= "" and not selected[id] then
            local options = Feature.getBestLineupPlacementOptions(candidate, cells, gridMap, occupancy, metrics)
            local placement = options[1]
            if placement and not Feature.shouldSkipLineupFillerPlacement(candidate, placement, gridMap, metrics) then
                local item = Feature.makeLineupPlanItem(candidate, placement, gridMap, metrics)
                item.placementScore = Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics, occupancy)
                table.insert(filled, item)
                selected[id] = true
                for _, cellName in ipairs(placement.occupiedCells or {}) do
                    occupancy[cellName] = item
                end
            end
        end
    end

    return filled
end

function Feature.sortLineupBackfillCandidates(candidates)
    local ordered = copyArray(candidates or {})
    table.sort(ordered, function(a, b)
        local scoreA = tonumber(a and a.score) or 0
        local scoreB = tonumber(b and b.score) or 0
        if scoreA ~= scoreB then
            return scoreA > scoreB
        end
        local dpsA = tonumber(a and a.derived and a.derived.dps) or 0
        local dpsB = tonumber(b and b.derived and b.derived.dps) or 0
        if dpsA ~= dpsB then
            return dpsA > dpsB
        end
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        local rangeA = tonumber(a and a.derived and a.derived.range) or 0
        local rangeB = tonumber(b and b.derived and b.derived.range) or 0
        if rangeA ~= rangeB then
            return rangeA > rangeB
        end
        if a.tierScore ~= b.tierScore then
            return a.tierScore > b.tierScore
        end
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)
    return ordered
end

function Feature.fillBestLineupBackfillPlan(plan, candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics)
    if Config.bestLineup.backfillRemainingSpace == false then
        return plan or {}
    end

    local filled = copyArray(plan or {})
    local occupancy, selected = Feature.getLineupPlanStats(filled, baseOccupancy)
    local placementLimit = tonumber(maxPlacements) or math.huge

    for _, candidate in ipairs(Feature.sortLineupBackfillCandidates(candidates)) do
        if #filled >= placementLimit then
            break
        end
        local id = Feature.getLineupCandidateKey(candidate)
        if id ~= "" and not selected[id] then
            local options = Feature.getBestLineupPlacementOptions(candidate, cells, gridMap, occupancy, metrics)
            local placement = options[1]
            if placement then
                local item = Feature.makeLineupPlanItem(candidate, placement, gridMap, metrics)
                item.placementScore = Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics, occupancy)
                item.backfill = true
                table.insert(filled, item)
                selected[id] = true
                for _, cellName in ipairs(placement.occupiedCells or {}) do
                    occupancy[cellName] = item
                end
            end
        end
    end

    return filled
end

function Feature.getLineupPlacementBlockers(placement, occupancy, itemSet)
    local blockers = {}
    local seen = {}
    for _, cellName in ipairs(placement and placement.occupiedCells or {}) do
        local existing = occupancy[cellName]
        if existing then
            if not itemSet[existing] then
                return nil, true
            end
            if not seen[existing] then
                seen[existing] = true
                table.insert(blockers, existing)
            end
        end
    end
    return blockers, false
end

function Feature.copyLineupPlanWithout(plan, blockers)
    local blocked = {}
    for _, item in ipairs(blockers or {}) do
        blocked[item] = true
    end

    local copy = {}
    for _, item in ipairs(plan or {}) do
        if not blocked[item] then
            table.insert(copy, item)
        end
    end
    return copy
end

function Feature.scoreLineupPlanItems(items)
    local total = 0
    for _, item in ipairs(items or {}) do
        total += Feature.getLineupPlacedItemValue(item)
    end
    return total
end

function Feature.improveBestLineupPlan(plan, candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics)
    local placementLimit = tonumber(maxPlacements) or math.huge
    local improved = Feature.fillBestLineupPlan(plan, candidates, cells, gridMap, placementLimit, baseOccupancy, metrics)
    local passes = math.max(0, tonumber(Config.bestLineup.replacementPasses) or 0)
    local minGain = tonumber(Config.bestLineup.minReplacementGain) or 0

    for _ = 1, passes do
        local occupancy, selected, itemSet = Feature.getLineupPlanStats(improved, baseOccupancy)
        local bestReplacement = nil
        local bestGain = minGain

        for _, candidate in ipairs(Feature.sortLineupCandidatesByScore(candidates)) do
            local id = Feature.getLineupCandidateKey(candidate)
            if id ~= "" and not selected[id] then
                local options = candidate.placementOptions
                if not options then
                    options = Feature.getBestLineupPlacementOptions(candidate, cells, gridMap, {}, metrics)
                end
                for _, placement in ipairs(options or {}) do
                    local blockers, hardBlocked = Feature.getLineupPlacementBlockers(placement, occupancy, itemSet)
                    if not hardBlocked and blockers and #blockers > 0 and #improved - #blockers + 1 <= placementLimit then
                        local candidateValue = Feature.getLineupPlanItemValue(candidate, placement, gridMap, metrics, occupancy)
                        local removedValue = Feature.scoreLineupPlanItems(blockers)
                        local gain = candidateValue - removedValue
                        if gain > bestGain then
                            bestGain = gain
                            bestReplacement = {
                                candidate = candidate,
                                placement = placement,
                                blockers = blockers,
                            }
                        end
                    end
                end
            end
        end

        if not bestReplacement then
            break
        end

        improved = Feature.copyLineupPlanWithout(improved, bestReplacement.blockers)
        local item = Feature.makeLineupPlanItem(bestReplacement.candidate, bestReplacement.placement, gridMap, metrics)
        item.placementScore = Feature.getLineupPlacementScore(bestReplacement.candidate, bestReplacement.placement, gridMap, metrics, Feature.getLineupPlanStats(improved, baseOccupancy))
        table.insert(improved, item)
        improved = Feature.fillBestLineupPlan(improved, candidates, cells, gridMap, placementLimit, baseOccupancy, metrics)
    end

    return improved
end

function Feature.buildBestLineupBeamPlan(candidates, cells, gridMap, baseOccupancy, fillCandidates, metrics)
    local beamWidth = math.max(1, tonumber(Config.bestLineup.beamWidth) or 32)
    local maxPlacements = tonumber(Config.bestLineup.maxPlacements) or math.huge
    local states = {
        {
            score = 0,
            cellsUsed = 0,
            plan = {},
            occupancy = Feature.copyLineupOccupancy(baseOccupancy),
        },
    }

    for _, candidate in ipairs(candidates) do
        local nextStates = {}
        for _, state in ipairs(states) do
            table.insert(nextStates, state)
            if #state.plan < maxPlacements then
                local options = Feature.getBestLineupPlacementOptions(candidate, cells, gridMap, state.occupancy, metrics)
                for _, placement in ipairs(options) do
                    local occupancy = Feature.copyLineupOccupancy(state.occupancy)
                    for _, cellName in ipairs(placement.occupiedCells) do
                        occupancy[cellName] = candidate.unit
                    end
                    local plan = copyArray(state.plan)
                    local placementScore = Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics, state.occupancy)
                    local item = Feature.makeLineupPlanItem(candidate, placement, gridMap, metrics)
                    item.placementScore = placementScore
                    table.insert(plan, item)
                    local cellsAdded = #placement.occupiedCells
                    table.insert(nextStates, {
                        score = state.score + Feature.getLineupPlanItemValue(candidate, placement, gridMap, metrics, state.occupancy),
                        cellsUsed = state.cellsUsed + cellsAdded,
                        plan = plan,
                        occupancy = occupancy,
                    })
                end
            end
        end
        states = Feature.rankBestLineupStates(nextStates, beamWidth)
    end

    local best = Feature.rankBestLineupStates(states, 1)[1]
    local plan = best and best.plan or {}
    local improved = Feature.improveBestLineupPlan(plan, fillCandidates or candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics)
    local ranged = Feature.rebuildBestLineupPlanByRange(improved, fillCandidates or candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics)
    return Feature.fillBestLineupBackfillPlan(ranged, fillCandidates or candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics)
end

function Feature.getBestLineupCandidateOrderVariants(candidates)
    local variants = {}
    local limit = math.max(1, tonumber(Config.bestLineup.searchVariants) or 5)

    local function addVariant(ordered)
        if #variants >= limit or not ordered or #ordered == 0 then
            return
        end
        table.insert(variants, ordered)
    end

    addVariant(Feature.sortLineupCandidatesByCombat(candidates))
    addVariant(Feature.sortLineupCandidatesByTier(candidates))
    addVariant(Feature.sortLineupCandidatesByFrontNeed(candidates))
    addVariant(Feature.sortLineupCandidatesByScore(candidates))

    local byRange = copyArray(candidates or {})
    table.sort(byRange, function(a, b)
        local rangeA = tonumber(a and a.derived and a.derived.range) or math.huge
        local rangeB = tonumber(b and b.derived and b.derived.range) or math.huge
        if rangeA ~= rangeB then
            return rangeA < rangeB
        end
        local frontA = (tonumber(a and a.frontPriority) or 0) * (tonumber(a and a.score) or 0)
        local frontB = (tonumber(b and b.frontPriority) or 0) * (tonumber(b and b.score) or 0)
        if frontA ~= frontB then
            return frontA > frontB
        end
        local dpsA = tonumber(a and a.derived and a.derived.dps) or 0
        local dpsB = tonumber(b and b.derived and b.derived.dps) or 0
        if dpsA ~= dpsB then
            return dpsA > dpsB
        end
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)
    addVariant(byRange)

    local byDensity = copyArray(candidates or {})
    table.sort(byDensity, function(a, b)
        local dpsPerCellA = tonumber(a and a.dpsPerCell) or 0
        local dpsPerCellB = tonumber(b and b.dpsPerCell) or 0
        if dpsPerCellA ~= dpsPerCellB then
            return dpsPerCellA > dpsPerCellB
        end
        if a.scorePerSpot ~= b.scorePerSpot then
            return a.scorePerSpot > b.scorePerSpot
        end
        local frontA = (tonumber(a and a.frontPriority) or 0) * (tonumber(a and a.score) or 0)
        local frontB = (tonumber(b and b.frontPriority) or 0) * (tonumber(b and b.score) or 0)
        if frontA ~= frontB then
            return frontA > frontB
        end
        local dpsA = tonumber(a and a.derived and a.derived.dps) or 0
        local dpsB = tonumber(b and b.derived and b.derived.dps) or 0
        if dpsA ~= dpsB then
            return dpsA > dpsB
        end
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)
    addVariant(byDensity)

    return variants
end

function Feature.selectBestLineupPlan(plans, baseOccupancy, gridMap)
    local bestPlan = {}
    local bestScore = -math.huge
    local bestCells = -math.huge
    for _, plan in ipairs(plans or {}) do
        local score = Feature.scoreBestLineupPlan(plan, gridMap, baseOccupancy)
        local occupancy = Feature.getLineupPlanStats(plan, baseOccupancy)
        local cells = 0
        for _ in pairs(occupancy or {}) do
            cells += 1
        end
        if score > bestScore or (score == bestScore and cells > bestCells) then
            bestScore = score
            bestCells = cells
            bestPlan = plan
        end
    end
    return bestPlan or {}
end

function Feature.buildBestLineupMultiVariantPlan(candidates, cells, gridMap, baseOccupancy, fillCandidates, metrics)
    local plans = {}
    for _, ordered in ipairs(Feature.getBestLineupCandidateOrderVariants(candidates)) do
        table.insert(plans, Feature.buildBestLineupBeamPlan(ordered, cells, gridMap, baseOccupancy, fillCandidates, metrics))
    end
    return Feature.selectBestLineupPlan(plans, baseOccupancy, gridMap)
end

function Feature.getBestLineupPlan()
    Feature.ensureBestLineupData()
    local gridModel = Feature.getCurrentGridModel()
    local cells, gridMap = Feature.buildGridCells(gridModel)
    if #cells == 0 then
        return {}
    end

    local metrics = Feature.getLineupCellMetrics(cells)
    local candidates, allCandidates = Feature.buildBestLineupCandidates(not Config.bestLineup.skipEquipped)
    local fillCandidates = Feature.prepareBestLineupCandidatePlacements(
        Feature.getBestLineupFillCandidates(candidates, allCandidates),
        cells,
        gridMap,
        metrics
    )
    candidates = Feature.prepareBestLineupCandidatePlacements(candidates, cells, gridMap, metrics)
    return Feature.orderBestLineupPlanForPlacement(Feature.buildBestLineupMultiVariantPlan(candidates, cells, gridMap, Feature.refreshPlacementOccupancy(gridMap), fillCandidates, metrics))
end

function Feature.getBestLineupPlanFromEmptyGrid()
    Feature.ensureBestLineupData()
    local gridModel = Feature.getCurrentGridModel()
    local cells, gridMap = Feature.buildGridCells(gridModel)
    if #cells == 0 then
        return {}
    end

    local metrics = Feature.getLineupCellMetrics(cells)
    local candidates, allCandidates = Feature.buildBestLineupCandidates(true)
    local fillCandidates = Feature.prepareBestLineupCandidatePlacements(
        Feature.getBestLineupFillCandidates(candidates, allCandidates),
        cells,
        gridMap,
        metrics
    )
    candidates = Feature.prepareBestLineupCandidatePlacements(candidates, cells, gridMap, metrics)
    return Feature.orderBestLineupPlanForPlacement(Feature.buildBestLineupMultiVariantPlan(candidates, cells, gridMap, {}, fillCandidates, metrics))
end

function Feature.placeBestLineup(runId)
    local function shouldContinue()
        return runId == nil or (Config.flags.autoBestLineup == true and State.bestLineupRunId == runId)
    end

    if not shouldContinue() then
        State.lastBestLineupSummary = "Best lineup stopped."
        Log.push(State.lastBestLineupSummary)
        return false
    end

    if Feature.isWaveStarted() then
        State.lastBestLineupSummary = "Best lineup waiting for wave to end before picking up units."
        local now = os.clock()
        if State.bestLineupWaveBlockLogAt == 0 or now - (State.bestLineupWaveBlockLogAt or 0) >= 10 then
            State.bestLineupWaveBlockLogAt = now
            Log.push(State.lastBestLineupSummary)
        end
        return false
    end

    Log.push("Planning best lineup...")
    local picked = Feature.pickupBestLineupUnits()
    if picked > 0 then
        Log.push("Picked up " .. tostring(picked) .. " placed units for best lineup.")
    end
    local plan = Feature.getBestLineupPlanFromEmptyGrid()
    if #plan == 0 then
        State.lastBestLineupSummary = "No placeable lineup found."
        Log.push(State.lastBestLineupSummary)
        return false
    end

    local placed = 0
    for _, item in ipairs(plan) do
        if not shouldContinue() then
            State.lastBestLineupSummary = "Best lineup stopped."
            Log.push(State.lastBestLineupSummary)
            return false
        end
        local ok = Feature.equipUnitForPlacement(item.unit) and Feature.placeCharacterAndWait(item)
        if ok then
            placed += 1
        end
        task.wait(math.max(Config.safety.remoteCooldown, 0.12))
    end

    State.lastBestLineupSummary = "Placed " .. tostring(placed) .. "/" .. tostring(#plan) .. " best lineup units."
    Log.push(State.lastBestLineupSummary)
    return placed > 0
end

function Feature.setAutoBestLineup(value)
    Config.flags.autoBestLineup = value == true
    if Config.flags.autoBestLineup then
        if Feature.loops.autoBestLineup then
            Log.push("Auto Best Lineup is already running.")
            return true
        end
        State.bestLineupRunId = (State.bestLineupRunId or 0) + 1
        local runId = State.bestLineupRunId
        Feature.startLoop("autoBestLineup", function()
            return Config.delays.bestLineup
        end, function()
            return Feature.placeBestLineup(runId)
        end)
        Log.push("Auto Best Lineup started.")
    else
        State.bestLineupRunId = (State.bestLineupRunId or 0) + 1
        Feature.stopLoop("autoBestLineup")
        Log.push("Auto Best Lineup stopped.")
    end
end

function Feature.waitForRemoteCooldown(key)
    local cooldown = tonumber(Config.safety.remoteCooldown) or 0
    if cooldown <= 0 then
        return
    end

    local elapsed = os.clock() - (Remote.lastSent[key] or 0)
    local remaining = cooldown - elapsed
    if remaining > 0 then
        task.wait(remaining + 0.02)
    end
end

function Feature.getInventoryDataByCharacterId()
    local byId = {}
    local inventory = State.dataGet("Inventory", {})
    if type(inventory) ~= "table" then
        return byId
    end

    for _, entry in pairs(inventory) do
        if type(entry) == "table" then
            local id = dataEntryValue(entry, UNIT_LOCK_ID_NAMES, nil)
            id = id and tostring(id) or ""
            if id ~= "" then
                byId[id] = entry
            end
        end
    end
    return byId
end

function Feature.getNativeInventoryLockedUnits()
    local lockedUnits = {}
    local inventoryById = Feature.getInventoryDataByCharacterId()
    local mainUi = PlayerGui:FindFirstChild("MainUI")
    local frames = mainUi and mainUi:FindFirstChild("Frames")
    local inventory = frames and frames:FindFirstChild("Inventory")
    local inventoryFrame = inventory and inventory:FindFirstChild("InventoryFrame")
    local scrolling = inventoryFrame and inventoryFrame:FindFirstChild("ScrollingFrame")
    if not scrolling then
        return lockedUnits
    end

    local seen = {}
    for _, row in ipairs(scrolling:GetChildren()) do
        if row:IsA("GuiObject") then
            local id = row:GetAttribute("EntryKey")
            id = id and tostring(id) or ""
            if id ~= "" and not seen[id] then
                local entry = inventoryById[id]
                local unlockedFrame = row:FindFirstChild("UnlockedFrame", true)
                local lockButton = unlockedFrame and unlockedFrame:FindFirstChild("LockButton", true)
                local lockedIcon = lockButton and lockButton:FindFirstChild("Locked")
                local unlockedIcon = lockButton and lockButton:FindFirstChild("Unlocked")
                local lockedByIcon = lockedIcon and lockedIcon:IsA("GuiObject") and lockedIcon.Visible == true
                local lockedByData = readDataEntryLocked(entry, id, nil)

                if lockedByIcon or lockedByData then
                    seen[id] = true
                    table.insert(lockedUnits, {
                        id = id,
                        characterId = id,
                        name = dataEntryCharacterName(entry, row.Name),
                        level = tostring(dataEntryValue(entry, { "Level", "Lvl" }, "?")),
                        mutation = normalizeUnitMutation(dataEntryValue(entry, { "Mutation", "MutationName", "MutationType" }, "None")),
                        trait = traitForCharacter(State.dataGet("Traits", {}), id, dataEntryValue(entry, { "Trait", "TraitName", "Passive" }, "None")),
                        locked = true,
                        dataEntry = entry,
                        nativeInventoryRow = row,
                        nativeLockButton = lockButton,
                        nativeLockedIcon = lockedIcon,
                        nativeUnlockedIcon = unlockedIcon,
                    })
                end
            end
        end
    end
    return lockedUnits
end

function Feature.getLockedUnits()
    local lockedUnits = {}
    local seen = {}
    State.scanUnits()
    for _, unit in ipairs(State.characters) do
        local id = tostring(unit and unit.id or "")
        if id ~= "" and not seen[id] and Feature.isUnitLocked(unit) then
            seen[id] = true
            table.insert(lockedUnits, unit)
        end
    end
    for _, unit in ipairs(Feature.getNativeInventoryLockedUnits()) do
        local id = tostring(unit and unit.id or "")
        if id ~= "" and not seen[id] then
            seen[id] = true
            table.insert(lockedUnits, unit)
        end
    end
    return lockedUnits
end

function Feature.getCharacterLockPayload(unit, locked)
    if not unit then
        return nil
    end

    local entry = unit.dataEntry
    local id = unit.characterId or dataEntryValue(entry, UNIT_LOCK_ID_NAMES, unit.id)
    id = id and tostring(id) or ""
    if id == "" then
        return nil
    end

    return {
        CharacterId = id,
        Name = dataEntryCharacterName(entry, unit.name),
        Locked = locked == true,
    }
end

function Feature.unlockUnit(unit)
    if not unit or tostring(unit.id or "") == "" then
        return false
    end

    local payload = Feature.getCharacterLockPayload(unit, false)
    if not payload then
        return false
    end

    Feature.waitForRemoteCooldown("CharacterLock")
    local ok = Remote.fire("CharacterLock", payload)
    if ok then
        unit.locked = false
        State.lockedUnitIds[tostring(payload.CharacterId)] = nil
        State.lockedUnitIdsReady = true
        if type(unit.dataEntry) == "table" then
            unit.dataEntry.Locked = false
        end
        if unit.nativeLockedIcon and unit.nativeLockedIcon:IsA("GuiObject") then
            unit.nativeLockedIcon.Visible = false
        end
        if unit.nativeUnlockedIcon and unit.nativeUnlockedIcon:IsA("GuiObject") then
            unit.nativeUnlockedIcon.Visible = true
        end
        if unit.instance then
            for _, attrName in ipairs(UNIT_LOCK_VALUE_NAMES) do
                pcall(function()
                    unit.instance:SetAttribute(attrName, false)
                end)
            end
        end
    end
    return ok
end

function Feature.unlockAllUnits()
    local lockedUnits = Feature.getLockedUnits()
    if #lockedUnits == 0 then
        Log.push("Unlock All: no locked units found.")
        return true
    end

    local unlocked = 0
    for _, unit in ipairs(lockedUnits) do
        if Feature.unlockUnit(unit) then
            unlocked += 1
        end
    end
    State.lockedUnitIdsReady = false
    State.scanUnits()
    Log.push("Unlock All sent for " .. tostring(unlocked) .. "/" .. tostring(#lockedUnits) .. " locked units.")
    return unlocked > 0
end

function Feature.traitScore(unit)
    local score = tonumber(unit and unit.level) or 0
    local trait = normalizeText(unit and unit.trait)
    for index, wanted in ipairs(Config.trait.targetTraits or {}) do
        if trait ~= "" and trait == normalizeText(wanted) then
            score += 1000 - index
            break
        end
    end
    return score
end

function Feature.isUnitLocked(unit)
    if not unit then
        return false
    end
    if unit.locked == true then
        return true
    end

    local id = tostring(unit.id or "")
    if id ~= "" then
        local lockedUnitIds = State.lockedUnitIds
        if type(lockedUnitIds) ~= "table" or State.lockedUnitIdsReady ~= true then
            lockedUnitIds = buildLockedUnitIdMap()
            State.lockedUnitIds = lockedUnitIds
            State.lockedUnitIdsReady = true
        end
        if lockedUnitIds[id] == true then
            unit.locked = true
            return true
        end
    end

    if unit.instance and readUnitLocked(unit.instance, false) then
        unit.locked = true
        return true
    end

    return false
end

function Feature.shouldKeepMergeUnit(unit)
    if not unit then
        return true
    end
    if Feature.isUnitLocked(unit) then
        return true
    end
    if textMatchesAny(unit.name, Config.merge.blacklist) then
        return true
    end
    if Config.merge.keepMutations then
        if textMatchesAny(unit.mutation, Config.roll.targetMutations) then
            return true
        end
        local mutationTargets = Config.roll.unitMutationTargets[unit.name]
        if listHasItems(mutationTargets) and textMatchesAny(unit.mutation, mutationTargets) then
            return true
        end
    end
    return false
end

function Feature.mergeKey(unit)
    if not unit then
        return ""
    end
    return table.concat({
        normalizeText(unit.name),
        tostring(tonumber(unit.level) or unit.level or "?"),
        normalizeText(unit.mutation),
    }, "|")
end

function Feature.unitMergeLevel(unit)
    return math.max(tonumber(unit and unit.level) or 1, 1)
end

function Feature.maxMergeLevel()
    return math.max(tonumber(Config.merge and Config.merge.maxLevel) or 7, 1)
end

function Feature.mergeMutationKey(mutation)
    local clean = normalizeText(mutation)
    if clean == "" or clean == "none" or clean == "normal" then
        return "none"
    end
    return clean
end

function Feature.mergeFamilyKey(unit)
    if not unit then
        return ""
    end
    return table.concat({
        normalizeText(unit.name),
        Feature.mergeMutationKey(unit and unit.mutation),
    }, "|")
end

function Feature.sameMergeFamily(left, right)
    return Feature.mergeFamilyKey(left) ~= "" and Feature.mergeFamilyKey(left) == Feature.mergeFamilyKey(right)
end

function Feature.isMergeSelectableTarget(unit)
    if not unit or tostring(unit.id or "") == "" then
        return false
    end
    if Feature.isUnitLocked(unit) then
        return false
    end
    if tostring(unit.level or "") == "?" then
        return false
    end
    if Feature.unitMergeLevel(unit) >= Feature.maxMergeLevel() then
        return false
    end
    if textMatchesAny(unit.name, Config.merge.blacklist) then
        return false
    end
    return Feature.getShapeFootprint(unit.name) ~= nil
end

function Feature.getMergeSelectableUnits()
    State.scanUnits()
    local units = {}
    for _, unit in ipairs(State.characters) do
        if Feature.isMergeSelectableTarget(unit) then
            table.insert(units, unit)
        end
    end
    return units
end

function Feature.getSelectedMergeUnit()
    State.scanUnits()
    local selected = State.getUnitById(Config.merge.targetUnitId)
    if Feature.isMergeSelectableTarget(selected) then
        return selected
    end

    local targetName = tostring(Config.merge.targetUnitName or "")
    local best = nil
    if targetName ~= "" then
        for _, unit in ipairs(State.characters) do
            if unit.name == targetName and Feature.isMergeSelectableTarget(unit) then
                if not best or Feature.traitScore(unit) > Feature.traitScore(best) then
                    best = unit
                end
            end
        end
    end
    return best
end

function Feature.refreshMergeTarget(target)
    if not target then
        return nil
    end
    local model = Feature.findPlacedUnitModel(target)
    if model then
        local refreshed = {}
        for key, value in pairs(target) do
            refreshed[key] = value
        end
        refreshed.name = model.Name
        refreshed.level = tostring(readAttr(model, { "Level", "Lvl" }, refreshed.level or "?"))
        refreshed.mutation = readUnitMutation(model, refreshed.mutation or "None")
        refreshed.trait = tostring(readAttr(model, { "Trait", "TraitName", "Passive" }, refreshed.trait or "None"))
        refreshed.locked = readUnitLocked(model, refreshed.locked)
        return refreshed
    end
    State.scanUnits()
    return State.getUnitById(target and target.id) or target
end

function Feature.unitIdMatchesInstance(unit, instance)
    if not unit or not instance then
        return false
    end
    local id = tostring(unit.id or "")
    if id == "" then
        return false
    end
    local instanceId = tostring(readAttr(instance, { "CharacterId", "CharacterID", "UID", "Uuid", "UUID", "Id", "ID" }, ""))
    return instanceId ~= "" and instanceId == id
end

function Feature.getUnitRoot(instance)
    if not instance then
        return nil
    end
    if instance:IsA("BasePart") then
        return instance
    end
    if instance:IsA("Model") then
        return instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
    end
    return instance:FindFirstChildWhichIsA("BasePart", true)
end

function Feature.findPlacedUnitModel(unit)
    local plot = Feature.getOwnedPlot()
    if not plot or not unit then
        return nil
    end

    for _, containerName in ipairs({ "Characters", "Fighters", "PlacedCharacters", "Builds" }) do
        local folder = plot:FindFirstChild(containerName)
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                if isPlacedUnitModel(model, containerName) and Feature.unitIdMatchesInstance(unit, model) then
                    return model
                end
            end
        end
    end
    if tostring(unit.id or "") ~= "" then
        return nil
    end

    for _, containerName in ipairs({ "Characters", "Fighters", "PlacedCharacters", "Builds" }) do
        local folder = plot:FindFirstChild(containerName)
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                if isPlacedUnitModel(model, containerName) and model.Name == unit.name then
                    return model
                end
            end
        end
    end
    return nil
end

function Feature.waitForPlacedUnitModel(unit, timeout)
    local deadline = os.clock() + (tonumber(timeout) or 2.5)
    repeat
        local model = Feature.findPlacedUnitModel(unit)
        if model then
            return model
        end
        task.wait(0.05)
    until os.clock() >= deadline
    return Feature.findPlacedUnitModel(unit)
end

function Feature.findUnitTool(unit)
    local roots = {
        LocalPlayer.Character,
        LocalPlayer:FindFirstChild("Backpack"),
    }
    for _, root in ipairs(roots) do
        if root then
            for _, child in ipairs(root:GetChildren()) do
                if child:IsA("Tool") then
                    if Feature.unitIdMatchesInstance(unit, child) then
                        return child
                    end
                    if tostring(unit.id or "") == "" and child.Name == unit.name then
                        return child
                    end
                end
            end
        end
    end
    return nil
end

function Feature.waitForUnitTool(unit, timeout)
    local deadline = os.clock() + (tonumber(timeout) or 1.5)
    repeat
        local tool = Feature.findUnitTool(unit)
        if tool then
            return tool
        end
        task.wait(0.05)
    until os.clock() >= deadline
    return Feature.findUnitTool(unit)
end

function Feature.equipUnitForMerge(unit)
    local tool = Feature.waitForUnitTool(unit, 1.5)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not tool or not humanoid then
        return false
    end
    if tool.Parent ~= character then
        humanoid:EquipTool(tool)
        task.wait(0.08)
    end
    return tool.Parent == character
end

function Feature.pickupUnitForMerge(unit)
    if Feature.isUnitLocked(unit) then
        Log.push("Merge skipped locked unit: " .. tostring(unit.name) .. ".")
        return false
    end
    local model = Feature.findPlacedUnitModel(unit)
    if not model then
        return true
    end
    if Remote.fire("PickupCharacter", model) then
        task.wait(math.max(Config.safety.remoteCooldown, 0.12))
        return Feature.waitForUnitTool(unit, 1.5) ~= nil
    end
    return false
end

function Feature.pickupMergeGroup(units)
    for _, unit in ipairs(units or {}) do
        Feature.pickupUnitForMerge(unit)
    end
    State.scanUnits()
end

function Feature.findNearestGridCellToPosition(position)
    local plot = Feature.getOwnedPlot()
    local grid = plot and plot:FindFirstChild("Grid")
    if not grid or not position then
        return nil
    end

    local bestCell = nil
    local bestDistance = math.huge
    for _, descendant in ipairs(grid:GetDescendants()) do
        if descendant:IsA("BasePart") then
            local distance = (descendant.Position - position).Magnitude
            if distance < bestDistance then
                bestDistance = distance
                bestCell = descendant
            end
        end
    end
    return bestCell
end

function Feature.getMergeAnchorCell(selected, group)
    local anchors = {}
    if selected then
        table.insert(anchors, selected)
    end
    for _, unit in ipairs(group or {}) do
        table.insert(anchors, unit)
    end

    for _, unit in ipairs(anchors) do
        local model = Feature.findPlacedUnitModel(unit)
        local placedCellNames = Feature.getPlacedModelCellNames(model)
        local placedCell = Feature.getPlacedModelCell(model)
        local resolvedCell = Feature.resolveMergeAnchorCell(unit, placedCell, placedCellNames)
        if resolvedCell then
            return resolvedCell
        end
        local root = Feature.getUnitRoot(model)
        local cell = root and Feature.findNearestGridCellToPosition(root.Position)
        resolvedCell = Feature.resolveMergeAnchorCell(unit, cell, placedCellNames)
        if resolvedCell then
            return resolvedCell
        end
    end
    return nil
end

function Feature.getPlacedModelCellNames(model)
    if not model then
        return {}
    end
    local cellsText = model:GetAttribute("Cells") or model:GetAttribute("GridCells")
    if type(cellsText) ~= "string" or cellsText == "" then
        return {}
    end

    local names = {}
    local seen = {}
    for cellName in cellsText:gmatch("[^,]+") do
        local clean = tostring(cellName):gsub("^%s+", ""):gsub("%s+$", "")
        if clean ~= "" and not seen[clean] then
            seen[clean] = true
            table.insert(names, clean)
        end
    end
    return names
end

function Feature.sameCellNameSet(left, right)
    if type(left) ~= "table" or type(right) ~= "table" or #left ~= #right then
        return false
    end

    local counts = {}
    for _, cellName in ipairs(left) do
        local clean = tostring(cellName or ""):gsub("^%s+", ""):gsub("%s+$", "")
        counts[clean] = (counts[clean] or 0) + 1
    end
    for _, cellName in ipairs(right) do
        local clean = tostring(cellName or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if not counts[clean] then
            return false
        end
        counts[clean] -= 1
        if counts[clean] <= 0 then
            counts[clean] = nil
        end
    end
    return next(counts) == nil
end

function Feature.resolveMergeAnchorCell(unit, candidateCell, requiredCellNames)
    if not unit then
        return nil
    end

    local hasRequiredCells = type(requiredCellNames) == "table" and #requiredCellNames > 0
    local function valid(cell)
        if not cell then
            return nil
        end
        local placement = Feature.getMergePlacement(unit, cell)
        if not placement then
            return nil
        end
        if hasRequiredCells and not Feature.sameCellNameSet(placement.occupiedCellNames, requiredCellNames) then
            return nil
        end
        return cell
    end

    local resolved = valid(candidateCell)
    if resolved then
        return resolved
    end

    if hasRequiredCells then
        local grid = Feature.getCurrentGridModel()
        local _, gridMap = Feature.buildGridCells(grid)
        for _, cellName in ipairs(requiredCellNames) do
            resolved = valid(gridMap[tostring(cellName)])
            if resolved then
                return resolved
            end
        end
    end
    return nil
end

function Feature.getPlacedModelCell(model)
    local cellNames = Feature.getPlacedModelCellNames(model)
    if #cellNames == 0 then
        return nil
    end

    local grid = Feature.getCurrentGridModel()
    local _, gridMap = Feature.buildGridCells(grid)
    for _, cellName in ipairs(cellNames) do
        local cell = gridMap[cellName]
        if cell then
            return cell
        end
    end
    return nil
end

function Feature.waitForMergeCell(unit, fallbackCell)
    local model = Feature.waitForPlacedUnitModel(unit, 2.5)
    local placedCellNames = Feature.getPlacedModelCellNames(model)
    local resolved = Feature.resolveMergeAnchorCell(unit, fallbackCell, placedCellNames)
    if resolved then
        return resolved
    end
    local placedCell = Feature.getPlacedModelCell(model)
    resolved = Feature.resolveMergeAnchorCell(unit, placedCell, placedCellNames)
    if resolved then
        return resolved
    end
    local root = Feature.getUnitRoot(model)
    local cell = root and Feature.findNearestGridCellToPosition(root.Position)
    resolved = Feature.resolveMergeAnchorCell(unit, cell, placedCellNames)
    return resolved or fallbackCell
end

function Feature.getMergeCandidates(selected)
    local selectedKey = selected and Feature.mergeKey(selected) or ""
    local candidates = {}

    for _, unit in ipairs(State.characters) do
        local key = Feature.mergeKey(unit)
        if selectedKey ~= "" and key ~= selectedKey then
            continue
        end
        if unit
            and not Feature.isUnitLocked(unit)
            and not textMatchesAny(unit.name, Config.merge.blacklist)
            and Feature.unitMergeLevel(unit) < Feature.maxMergeLevel()
        then
            if Feature.getShapeFootprint(unit.name) then
                table.insert(candidates, unit)
            end
        end
    end

    return candidates
end

function Feature.getMergeFamilyUnits(target)
    State.scanUnits()
    local family = {}
    for _, unit in ipairs(State.characters) do
        if unit
            and Feature.sameMergeFamily(unit, target)
            and not Feature.isUnitLocked(unit)
            and not textMatchesAny(unit.name, Config.merge.blacklist)
        then
            table.insert(family, unit)
        end
    end
    table.sort(family, function(a, b)
        local placedA = a.placed == true
        local placedB = b.placed == true
        if placedA ~= placedB then
            return not placedA
        end
        local levelA = Feature.unitMergeLevel(a)
        local levelB = Feature.unitMergeLevel(b)
        if levelA ~= levelB then
            return levelA < levelB
        end
        local scoreA = Feature.traitScore(a)
        local scoreB = Feature.traitScore(b)
        if scoreA ~= scoreB then
            return scoreA < scoreB
        end
        return tostring(a.id) < tostring(b.id)
    end)
    return family
end

function Feature.findMergeFodderAtLevel(target, level, usedIds)
    local targetId = tostring(target and target.id or "")
    for _, unit in ipairs(Feature.getMergeFamilyUnits(target)) do
        local id = tostring(unit.id or "")
        if id ~= ""
            and id ~= targetId
            and not usedIds[id]
            and Feature.unitMergeLevel(unit) == level
        then
            usedIds[id] = true
            return unit
        end
    end
    return nil
end

function Feature.groupHasPlacedAnchor(group)
    for _, unit in ipairs(group or {}) do
        if Feature.findPlacedUnitModel(unit) then
            return true
        end
    end
    return false
end

function Feature.orderMergeUnits(group, selected)
    local ordered = {}
    local selectedId = selected and tostring(selected.id or "") or ""
    if selected then
        table.insert(ordered, selected)
    end
    for _, unit in ipairs(group or {}) do
        if tostring(unit.id or "") ~= selectedId then
            table.insert(ordered, unit)
        end
    end
    return ordered
end

function Feature.getDuplicateMergePlan(selectedOnly, ignoredKeys)
    State.scanUnits()
    local selected = selectedOnly and Feature.getSelectedMergeUnit() or nil
    if selectedOnly and not selected then
        Log.push("Select a merge target first.")
        return nil
    end

    local groups = {}
    for _, unit in ipairs(Feature.getMergeCandidates(selected)) do
        local key = Feature.mergeKey(unit)
        groups[key] = groups[key] or {}
        table.insert(groups[key], unit)
    end

    local candidateGroups = {}
    for key, group in pairs(groups) do
        if not (ignoredKeys and ignoredKeys[key]) and #group >= 2 then
            table.insert(candidateGroups, group)
        end
    end
    table.sort(candidateGroups, function(a, b)
        return #a > #b
    end)

    for _, bestGroup in ipairs(candidateGroups) do
        table.sort(bestGroup, function(a, b)
            local scoreA = Feature.traitScore(a)
            local scoreB = Feature.traitScore(b)
            if scoreA ~= scoreB then
                return scoreA > scoreB
            end
            return tostring(a.id) < tostring(b.id)
        end)

        local cell = Feature.getMergeAnchorCell(selected, bestGroup)
        cell = Feature.findMergePlacementCell(bestGroup[1], cell)
        if cell then
            return {
                target = selectedOnly and selected or bestGroup[1],
                units = Feature.orderMergeUnits(bestGroup, selected),
                cell = cell,
                key = Feature.mergeKey(bestGroup[1]),
            }
        end
    end

    if #candidateGroups == 0 then
        return nil
    end
    return nil
end

function Feature.getDuplicateMergePlanForFamily(familyKey, ignoredKeys)
    local targetFamilyKey = tostring(familyKey or "")
    if targetFamilyKey == "" then
        return nil
    end

    State.scanUnits()
    local groups = {}
    for _, unit in ipairs(Feature.getMergeCandidates(nil)) do
        if Feature.mergeFamilyKey(unit) == targetFamilyKey then
            local key = Feature.mergeKey(unit)
            groups[key] = groups[key] or {}
            table.insert(groups[key], unit)
        end
    end

    local candidateGroups = {}
    for key, group in pairs(groups) do
        if not (ignoredKeys and ignoredKeys[key]) and #group >= 2 then
            table.insert(candidateGroups, group)
        end
    end
    table.sort(candidateGroups, function(a, b)
        local levelA = Feature.unitMergeLevel(a[1])
        local levelB = Feature.unitMergeLevel(b[1])
        if levelA ~= levelB then
            return levelA < levelB
        end
        if #a ~= #b then
            return #a > #b
        end
        return Feature.traitScore(a[1]) > Feature.traitScore(b[1])
    end)

    for _, bestGroup in ipairs(candidateGroups) do
        table.sort(bestGroup, function(a, b)
            local scoreA = Feature.traitScore(a)
            local scoreB = Feature.traitScore(b)
            if scoreA ~= scoreB then
                return scoreA > scoreB
            end
            return tostring(a.id) < tostring(b.id)
        end)

        local cell = Feature.getMergeAnchorCell(bestGroup[1], bestGroup)
        cell = Feature.findMergePlacementCell(bestGroup[1], cell)
        if cell then
            return {
                target = bestGroup[1],
                units = Feature.orderMergeUnits(bestGroup, bestGroup[1]),
                cell = cell,
                key = Feature.mergeKey(bestGroup[1]),
                familyKey = targetFamilyKey,
            }
        end
    end

    return nil
end

function Feature.findNextAutoMergeFamily(characterName, ignoredFamilies, ignoredCharacters)
    State.scanUnits()
    local targetCharacter = normalizeText(characterName)
    local families = {}
    local order = {}

    for _, unit in ipairs(Feature.getMergeCandidates(nil)) do
        local unitCharacter = normalizeText(unit.name)
        if (targetCharacter == "" or unitCharacter == targetCharacter)
            and not (targetCharacter == "" and ignoredCharacters and ignoredCharacters[unitCharacter])
        then
            local familyKey = Feature.mergeFamilyKey(unit)
            if familyKey ~= "" and not (ignoredFamilies and ignoredFamilies[familyKey]) then
                local family = families[familyKey]
                if not family then
                    family = {
                        familyKey = familyKey,
                        characterName = unitCharacter,
                        displayName = tostring(unit.name or ""),
                        mutationKey = Feature.mergeMutationKey(unit.mutation),
                        count = 0,
                        mergeKeys = {},
                    }
                    families[familyKey] = family
                    table.insert(order, family)
                end
                family.count += 1
                local mergeKey = Feature.mergeKey(unit)
                family.mergeKeys[mergeKey] = (family.mergeKeys[mergeKey] or 0) + 1
            end
        end
    end

    local mergeable = {}
    for _, family in ipairs(order) do
        for _, count in pairs(family.mergeKeys) do
            if count >= 2 then
                table.insert(mergeable, family)
                break
            end
        end
    end

    table.sort(mergeable, function(a, b)
        if a.characterName ~= b.characterName then
            return a.characterName < b.characterName
        end
        if a.mutationKey ~= b.mutationKey then
            return a.mutationKey < b.mutationKey
        end
        return a.familyKey < b.familyKey
    end)

    return mergeable[1]
end

function Feature.resetAutoMergePending()
    State.pendingMerge = {
        mode = "auto",
        characterName = "",
        displayName = "",
        familyKey = "",
        ignoredFamilies = {},
        ignoredKeys = {},
        failedKeys = {},
    }
    return State.pendingMerge
end

function Feature.pickupAutoMergeBoardUnits(characterName)
    State.scanUnits()
    local targetCharacter = normalizeText(characterName)
    local picked = 0
    for _, unit in ipairs(State.characters) do
        if unit
            and unit.placed == true
            and normalizeText(unit.name) == targetCharacter
            and not Feature.isUnitLocked(unit)
            and not textMatchesAny(unit.name, Config.merge.blacklist)
            and Feature.getShapeFootprint(unit.name)
        then
            if Feature.pickupUnitForMerge(unit) then
                picked += 1
            end
        end
    end
    if picked > 0 then
        State.scanUnits()
        Log.push("Auto merge picked up " .. tostring(picked) .. " placed " .. tostring(characterName) .. " unit(s).")
    end
    return picked
end

function Feature.findFreeGridCell()
    Feature.ensureBestLineupData()
    local grid = Feature.getCurrentGridModel()
    local cells, gridMap = Feature.buildGridCells(grid)
    if #cells == 0 then
        return nil
    end

    local occupancy = Feature.refreshPlacementOccupancy(gridMap)
    for _, cell in ipairs(cells) do
        if not occupancy[cell.Name] then
            return cell
        end
    end
    return nil
end

function Feature.getMergePlacement(unit, cell)
    if not unit or not cell then
        return nil
    end
    Feature.ensureBestLineupData()
    local grid = Feature.getCurrentGridModel()
    local cells, gridMap = Feature.buildGridCells(grid)
    local footprint = Feature.getShapeFootprint(unit.name)
    local occupiedCells, shapeCFrame = Feature.getShapeOccupiedCellNames(footprint, cell, gridMap, cells)
    if not occupiedCells or not shapeCFrame then
        return nil
    end
    return {
        shapeName = footprint.shapeName,
        hoveredCellName = cell.Name,
        shapeCFrame = shapeCFrame,
        occupiedCellNames = occupiedCells,
    }
end

function Feature.placementCellsAvailable(placement, occupancy)
    if not placement or not placement.occupiedCellNames then
        return false
    end
    for _, cellName in ipairs(placement.occupiedCellNames) do
        if occupancy and occupancy[cellName] then
            return false
        end
    end
    return true
end

function Feature.findMergePlacementCell(unit, preferredCell)
    if not unit then
        return nil
    end
    Feature.ensureBestLineupData()
    local grid = Feature.getCurrentGridModel()
    local cells, gridMap = Feature.buildGridCells(grid)
    if #cells == 0 then
        return nil
    end

    local occupancy = Feature.refreshPlacementOccupancy(gridMap)
    local function usable(cell)
        if not cell then
            return nil
        end
        local placement = Feature.getMergePlacement(unit, cell)
        if placement and Feature.placementCellsAvailable(placement, occupancy) then
            return cell
        end
        return nil
    end

    local preferred = usable(preferredCell)
    if preferred then
        return preferred
    end
    for _, cell in ipairs(cells) do
        local candidate = usable(cell)
        if candidate then
            return candidate
        end
    end
    return nil
end

function Feature.placeUnitForMerge(unit, cell)
    if not unit or not cell then
        return false
    end
    if Feature.isUnitLocked(unit) then
        Log.push("Merge skipped locked unit: " .. tostring(unit.name) .. ".")
        return false
    end
    local placement = Feature.getMergePlacement(unit, cell)
    if not placement then
        Log.push("Merge skipped: could not build placement for " .. tostring(unit.name) .. ".")
        return false
    end
    if not Feature.equipUnitForMerge(unit) then
        Log.push("Merge skipped: could not equip " .. tostring(unit.name) .. ".")
        return false
    end

    local remote = Remote.get("PlaceCharacter")
    if not remote or not remote:IsA("RemoteEvent") then
        Log.push("Missing RemoteEvent: PlaceCharacter")
        return false
    end
    if not Remote.canSend("PlaceCharacter") then
        return false
    end

    local response = nil
    local connection = remote.OnClientEvent:Connect(function(payload)
        response = payload
    end)
    local ok, err = pcall(function()
        remote:FireServer({
            CharacterName = unit.name,
            ShapeName = placement.shapeName,
            HoveredCellName = placement.hoveredCellName,
            ShapeCFrame = placement.shapeCFrame,
        })
    end)
    Remote.lastSent.PlaceCharacter = os.clock()
    if not ok then
        connection:Disconnect()
        Log.push("Merge place failed " .. tostring(unit.name) .. ": " .. tostring(err))
        return false
    end

    local started = os.clock()
    while response == nil and os.clock() - started < 2 do
        task.wait()
    end
    connection:Disconnect()

    if type(response) == "table" then
        if response.Success == false then
            Log.push("Merge place rejected " .. tostring(unit.name) .. ": " .. tostring(response.Message or "server rejected"))
            Feature.backoffMerge("rejected placement")
            return false
        end
        if response.Success == true then
            return true
        end
    end

    Log.push("Merge place timed out waiting for " .. tostring(unit.name) .. ".")
    Feature.backoffMerge("placement timeout")
    return false
end

function Feature.backoffMerge(reason)
    State.mergeRejectedUntil = os.clock() + (tonumber(Config.delays.mergeRejectBackoff) or 3)
    if reason and tostring(reason) ~= "" then
        Log.push("Merge cooling down after " .. tostring(reason) .. ".")
    end
end

function Feature.cleanupFailedMergeAttempt(anchor, fodder, keepAnchorPlaced)
    if not keepAnchorPlaced then
        Feature.pickupUnitForMerge(anchor)
    end
    Feature.pickupUnitForMerge(fodder)

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            humanoid:UnequipTools()
        end)
    end

    task.wait(0.08)
    State.scanUnits()
end

function Feature.waitForUnitLevel(unit, expectedLevel, timeout)
    local deadline = os.clock() + (tonumber(timeout) or 3)
    repeat
        local refreshed = Feature.refreshMergeTarget(unit)
        if refreshed and Feature.unitMergeLevel(refreshed) >= expectedLevel then
            return refreshed
        end
        task.wait(0.1)
    until os.clock() >= deadline
    local refreshed = Feature.refreshMergeTarget(unit)
    if refreshed and Feature.unitMergeLevel(refreshed) >= expectedLevel then
        return refreshed
    end
    return nil
end

function Feature.mergeUnitsOnCell(anchor, fodder, cell)
    if not anchor or not fodder or not cell then
        return nil
    end
    if Feature.isUnitLocked(anchor) or Feature.isUnitLocked(fodder) then
        Log.push("Merge stopped: locked unit is protected.")
        return nil
    end

    local anchorLevel = Feature.unitMergeLevel(anchor)
    if anchorLevel >= Feature.maxMergeLevel() then
        Log.push("Merge stopped: level " .. tostring(anchorLevel) .. " is max.")
        return nil
    end
    Feature.pickupUnitForMerge(anchor)
    Feature.pickupUnitForMerge(fodder)
    if not Feature.placeUnitForMerge(anchor, cell) then
        Log.push("Merge stopped: could not place anchor " .. tostring(anchor.name) .. ".")
        Feature.cleanupFailedMergeAttempt(anchor, fodder, false)
        return nil
    end

    local mergeCell = Feature.waitForMergeCell(anchor, cell)
    task.wait(math.max(Config.safety.remoteCooldown, 0.12))
    if not Feature.placeUnitForMerge(fodder, mergeCell) then
        Log.push("Merge stopped: could not place fodder " .. tostring(fodder.name) .. ".")
        Feature.cleanupFailedMergeAttempt(anchor, fodder, false)
        return nil
    end

    task.wait(math.max(Config.delays.merge, Config.safety.remoteCooldown, 0.25))
    local updated = Feature.waitForUnitLevel(anchor, anchorLevel + 1, 3)
    if not updated then
        Log.push("Merge stopped: level did not update for " .. tostring(anchor.name) .. ".")
        Feature.cleanupFailedMergeAttempt(anchor, fodder, false)
        Feature.backoffMerge("merge level check timeout")
        return nil
    end
    return updated
end

function Feature.mergeFodderIntoPlacedAnchor(anchor, fodder, cell)
    if not anchor or not fodder or not cell then
        return nil
    end
    if Feature.isUnitLocked(anchor) or Feature.isUnitLocked(fodder) then
        Log.push("Merge stopped: locked unit is protected.")
        return nil
    end

    local anchorLevel = Feature.unitMergeLevel(anchor)
    if anchorLevel >= Feature.maxMergeLevel() then
        Log.push("Merge stopped: level " .. tostring(anchorLevel) .. " is max.")
        return nil
    end
    local mergeCell = Feature.waitForMergeCell(anchor, cell)
    if not mergeCell then
        Log.push("Merge stopped: selected anchor is not placed.")
        return nil
    end

    task.wait(math.max(Config.safety.remoteCooldown, 0.12))
    Feature.pickupUnitForMerge(fodder)
    task.wait(math.max(Config.safety.remoteCooldown, 0.12))
    if not Feature.placeUnitForMerge(fodder, mergeCell) then
        Log.push("Merge stopped: could not place fodder " .. tostring(fodder.name) .. ".")
        Feature.cleanupFailedMergeAttempt(anchor, fodder, true)
        return nil
    end

    task.wait(math.max(Config.delays.merge, Config.safety.remoteCooldown, 0.25))
    local updated = Feature.waitForUnitLevel(anchor, anchorLevel + 1, 3)
    if not updated then
        Log.push("Merge stopped: level did not update for " .. tostring(anchor.name) .. ".")
        Feature.cleanupFailedMergeAttempt(anchor, fodder, true)
        Feature.backoffMerge("merge level check timeout")
        return nil
    end
    return updated
end

function Feature.buildFodderForMergeLevel(target, level, usedIds, depth, directLevelLimit)
    depth = tonumber(depth) or 0
    directLevelLimit = math.max(tonumber(directLevelLimit) or level, 1)
    if depth > 6 then
        return nil
    end

    if level <= directLevelLimit then
        local direct = Feature.findMergeFodderAtLevel(target, level, usedIds)
        if direct then
            return direct
        end
    end
    if level <= 1 then
        return nil
    end

    local first = Feature.buildFodderForMergeLevel(target, level - 1, usedIds, depth + 1, directLevelLimit)
    local second = Feature.buildFodderForMergeLevel(target, level - 1, usedIds, depth + 1, directLevelLimit)
    if not first or not second then
        return nil
    end

    local cell = Feature.findMergePlacementCell(first, Feature.findFreeGridCell())
    if not cell then
        Log.push("Merge stopped: no free cell to build level " .. tostring(level) .. " fodder.")
        return nil
    end

    Log.push("Building level " .. tostring(level) .. " fodder from two level " .. tostring(level - 1) .. " duplicates.")
    return Feature.mergeUnitsOnCell(first, second, cell)
end

function Feature.executeTargetMergeCascade(selected)
    local target = Feature.refreshMergeTarget(selected)
    if not target then
        Log.push("Select a merge target first.")
        return false
    end
    if Feature.isUnitLocked(target) then
        Log.push("Selected merge target is locked.")
        return false
    end
    if tostring(target.level or "") == "?" then
        Log.push("Selected merge target needs a known level.")
        return false
    end
    local maxMergeLevel = Feature.maxMergeLevel()
    local startingLevel = Feature.unitMergeLevel(target)
    if startingLevel >= maxMergeLevel then
        Log.push("Target merge complete: level " .. tostring(startingLevel) .. " is max.")
        return false
    end

    local originalTrait = tostring(target.trait or "None")
    local targetCell = Feature.getMergeAnchorCell(target, { target })
    local alreadyPlaced = Feature.findPlacedUnitModel(target) ~= nil and targetCell ~= nil
    if not alreadyPlaced then
        targetCell = Feature.findMergePlacementCell(target, targetCell)
    end
    if not targetCell then
        Log.push("Target merge needs a free grid cell.")
        return false
    end

    if alreadyPlaced then
        Log.push("Target merge anchor already placed first: " .. tostring(target.name) .. " | " .. originalTrait .. ".")
    else
        Feature.pickupUnitForMerge(target)
        if not Feature.placeUnitForMerge(target, targetCell) then
            Log.push("Target merge stopped: could not place selected target.")
            Feature.cleanupFailedMergeAttempt(target, nil, false)
            return false
        end
        targetCell = Feature.waitForMergeCell(target, targetCell)
        Log.push("Target merge anchor placed first: " .. tostring(target.name) .. " | " .. originalTrait .. ".")
    end

    local seedLevel = Feature.unitMergeLevel(target)
    local merged = 0
    for depth = 1, 12 do
        target = Feature.refreshMergeTarget(target)
        if Feature.isUnitLocked(target) then
            Log.push("Target merge stopped: selected target is locked.")
            return merged > 0
        end
        local targetLevel = Feature.unitMergeLevel(target)
        if targetLevel >= maxMergeLevel then
            Log.push("Target merge complete: level " .. tostring(targetLevel) .. " is max.")
            break
        end
        local usedIds = {
            [tostring(target.id or "")] = true,
        }
        local fodder = Feature.buildFodderForMergeLevel(target, targetLevel, usedIds, depth + 1, seedLevel)
        if not fodder then
            Log.push("Target merge complete: no level " .. tostring(targetLevel) .. " duplicate/fodder remains.")
            break
        end

        Log.push("Merging level " .. tostring(targetLevel) .. " fodder into selected target.")
        local updated = Feature.mergeFodderIntoPlacedAnchor(target, fodder, targetCell)
        if not updated then
            return merged > 0
        end

        target = updated
        targetCell = Feature.waitForMergeCell(target, targetCell)
        merged += 1
    end

    target = Feature.refreshMergeTarget(target)
    if target then
        if normalizeText(originalTrait) ~= "" and normalizeText(originalTrait) ~= "none" and normalizeText(target.trait) ~= normalizeText(originalTrait) then
            Log.push("Warning: target trait changed from " .. originalTrait .. " to " .. tostring(target.trait) .. ".")
        else
            Log.push("Target preserved trait: " .. tostring(target.trait) .. " at level " .. tostring(target.level) .. ".")
        end
    end
    return merged > 0
end

function Feature.executeMergePlan(plan)
    if not plan then
        return false
    end
    if Feature.isUnitLocked(plan.target) then
        Log.push("Merge skipped: target is locked.")
        return false
    end
    for _, unit in ipairs(plan.units or {}) do
        if Feature.isUnitLocked(unit) then
            Log.push("Merge skipped: group contains a locked unit.")
            return false
        end
    end
    Feature.pickupMergeGroup(plan.units)
    local placed = Feature.placeUnitForMerge(plan.target, plan.cell)
    if not placed then
        return false
    end
    Log.push("Placed best trait duplicate first: " .. tostring(plan.target.name) .. ".")
    local mergeCell = Feature.waitForMergeCell(plan.target, plan.cell)
    task.wait(math.max(Config.safety.remoteCooldown, 0.12))
    for index = 2, #plan.units do
        if Feature.placeUnitForMerge(plan.units[index], mergeCell) then
            task.wait(math.max(Config.safety.remoteCooldown, 0.12))
        end
    end
    return true
end

function Feature.finishAutoMergeSweep()
    Log.push("Auto merge finished every anime.")
    Feature.toggleAutoMerge(false)
end

function Feature.autoMergeStep()
    local now = os.clock()
    if now < (State.mergeRejectedUntil or 0) then
        return false
    end
    if now < (State.autoMergeIdleUntil or 0) then
        return false
    end
    if Feature.pauseMergeForNativeMenu(now) then
        return false
    end

    local pending = State.pendingMerge
    if type(pending) ~= "table" or pending.mode ~= "auto" then
        pending = Feature.resetAutoMergePending()
    end

    if tostring(pending.characterName or "") == "" then
        local family = Feature.findNextAutoMergeFamily(nil, nil, State.autoMergeIgnoredCharacters)
        if not family then
            Feature.finishAutoMergeSweep()
            return false
        end
        pending.characterName = family.characterName
        pending.displayName = family.displayName
        pending.familyKey = family.familyKey
        pending.ignoredFamilies = {}
        pending.ignoredKeys = {}
        pending.failedKeys = {}
        Log.push("Auto merge focusing " .. tostring(family.displayName) .. ".")
    end

    if tostring(pending.familyKey or "") == "" then
        local family = Feature.findNextAutoMergeFamily(pending.characterName, pending.ignoredFamilies)
        if not family then
            Feature.pickupAutoMergeBoardUnits(pending.characterName)
            Log.push("Auto merge finished " .. tostring(pending.displayName ~= "" and pending.displayName or pending.characterName) .. ".")
            State.autoMergeIgnoredCharacters[pending.characterName] = true
            State.pendingMerge = nil
            return false
        end
        pending.displayName = family.displayName
        pending.familyKey = family.familyKey
        pending.ignoredKeys = {}
        pending.failedKeys = {}
        Log.push("Auto merge moving to " .. tostring(family.displayName) .. " mutation " .. tostring(family.mutationKey) .. ".")
    end

    local plan = Feature.getDuplicateMergePlanForFamily(pending.familyKey, pending.ignoredKeys)
    if not plan then
        pending.ignoredFamilies[pending.familyKey] = true
        pending.familyKey = ""
        pending.ignoredKeys = {}
        pending.failedKeys = {}
        return false
    end

    if Feature.executeTargetMergeCascade(plan.target) then
        pending.failedKeys = pending.failedKeys or {}
        pending.failedKeys[plan.key] = nil
        return true
    end

    pending.failedKeys = pending.failedKeys or {}
    local failures = (pending.failedKeys[plan.key] or 0) + 1
    pending.failedKeys[plan.key] = failures
    if failures >= 3 then
        pending.ignoredKeys[plan.key] = true
        pending.failedKeys[plan.key] = nil
        Log.push("Auto merge skipped repeated failing duplicate group.")
    else
        Log.push("Auto merge will retry duplicate group after cleanup.")
    end
    return false
end

function Feature.mergeSelectedTarget()
    local selected = Feature.getSelectedMergeUnit()
    if not selected then
        Log.push("Select a merge target first.")
        return false
    end
    local now = os.clock()
    if now < (State.mergeRejectedUntil or 0) then
        Log.push("Merge is cooling down after a rejected placement.")
        return false
    end
    if Feature.pauseMergeForNativeMenu(now) then
        return false
    end

    local familyKey = Feature.mergeFamilyKey(selected)
    if familyKey == "" then
        Log.push("Selected merge target has no merge family.")
        return false
    end

    local ignoredKeys = {}
    local failedKeys = {}
    local merged = false
    for _ = 1, 12 do
        if os.clock() < (State.mergeRejectedUntil or 0) then
            break
        end

        local plan = Feature.getDuplicateMergePlanForFamily(familyKey, ignoredKeys)
        if not plan then
            if not merged then
                Log.push("Selected merge found no duplicate group for " .. tostring(selected.name) .. ".")
            end
            return merged
        end

        if Feature.executeTargetMergeCascade(plan.target) then
            failedKeys[plan.key] = nil
            merged = true
        else
            local failures = (failedKeys[plan.key] or 0) + 1
            failedKeys[plan.key] = failures
            if failures >= 3 then
                ignoredKeys[plan.key] = true
                failedKeys[plan.key] = nil
                Log.push("Selected merge skipped repeated failing duplicate group.")
            else
                Log.push("Selected merge will retry duplicate group after cleanup.")
            end
        end
        task.wait(math.max(Config.delays.merge, Config.safety.remoteCooldown, 0.25))
    end
    return merged
end

function Feature.toggleAutoMerge(value)
    Config.flags.autoMerge = value
    if value then
        State.pendingMerge = nil
        State.autoMergeIgnoredCharacters = {}
        State.autoMergeIdleUntil = 0
        Feature.startLoop("autoMerge", function()
            local idleUntil = State.autoMergeIdleUntil or 0
            if idleUntil > os.clock() then
                return math.max(idleUntil - os.clock(), Config.delays.merge)
            end
            return Config.delays.merge
        end, Feature.autoMergeStep)
    else
        Feature.stopLoop("autoMerge")
        State.pendingMerge = nil
        State.autoMergeIgnoredCharacters = {}
        State.autoMergeIdleUntil = 0
    end
    UI.refreshToggle("Auto Merge Duplicates")
end

function Feature.toggleTrait(value)
    Config.flags.autoTrait = value
    if value then
        Feature.startLoop("autoTrait", function()
            return Config.delays.trait
        end, Feature.autoTraitStep)
    else
        Feature.stopLoop("autoTrait")
    end
end

function Feature.toggleUpgrade(value)
    Config.flags.autoUpgrade = value
    if value then
        Feature.startLoop("autoUpgrade", function()
            return Config.delays.upgrade
        end, Feature.autoUpgradeStep)
    else
        Feature.stopLoop("autoUpgrade")
    end
end

function Feature.getBoorusSpinCount()
    local count = tonumber(Feature.dataGet("BeerusSpin", 0)) or 0
    return math.max(0, math.floor(count))
end

function Feature.getBoorusChallengeDoor()
    local machines = workspace:FindFirstChild("Machines")
    local door = machines and machines:FindFirstChild("Door")
    if door then
        return door
    end
    return machines and machines:FindFirstChild("BeerusDoor", true) or nil
end

function Feature.getBoorusChallengePrompt()
    local door = Feature.getBoorusChallengeDoor()
    local prompt = door and door:FindFirstChild("Door") and door.Door:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and prompt:IsA("ProximityPrompt") and textMatchesAny(prompt.ActionText, { "Challenge Boss" }) then
        return prompt
    end
    if door then
        for _, descendant in ipairs(door:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and textMatchesAny(descendant.ActionText, { "Challenge Boss", "Boss" }) then
                return descendant
            end
        end
    end
    return nil
end

function Feature.getBoorusChallengeText()
    local door = Feature.getBoorusChallengeDoor()
    local gui = door and door:FindFirstChild("RestockGUI")
    local timer = gui and gui:FindFirstChild("TimerLabel")
    if timer and timer:IsA("TextLabel") then
        return tostring(timer.Text or "")
    end
    return ""
end

function Feature.getCurrentBoorusChallengePeriod()
    return os.time() // 43200
end

function Feature.getBoorusLastChallengePeriod()
    local lastChallenge = tonumber(Feature.dataGet("LastBeerusBossChallenge", 0)) or 0
    if lastChallenge <= 0 then
        return 0
    end
    if lastChallenge >= 100000000000 then
        return math.floor(lastChallenge / 43200000)
    end
    if lastChallenge >= 1000000000 then
        return math.floor(lastChallenge / 43200)
    end
    return math.floor(lastChallenge)
end

function Feature.getBoorusLastChallengeDay()
    return Feature.getBoorusLastChallengePeriod()
end

function Feature.isBoorusChallengeStatusReady()
    local statusText = normalizeText(Feature.getBoorusChallengeText())
    return statusText:find("challenge now", 1, true) ~= nil
        or statusText:find("ready", 1, true) ~= nil
end

function Feature.isBoorusChallengeReady()
    local statusReady = Feature.isBoorusChallengeStatusReady()
    if statusReady then
        return true
    end

    local lastChallengePeriod = Feature.getBoorusLastChallengePeriod()
    local currentPeriod = Feature.getCurrentBoorusChallengePeriod()
    return lastChallengePeriod <= 0 or lastChallengePeriod < currentPeriod
end

function Feature.shouldPauseWaveStartForBoorus()
    return Config.flags.autoBoorus == true and Feature.isBoorusChallengeReady()
end

function Feature.isBoorusChallengeActive()
    local mutationContainer = workspace:FindFirstChild("MutationStuffs")
    return mutationContainer and mutationContainer:FindFirstChild("BeerusMap") ~= nil
end

function Feature.waitForBoorusChallengeActive(timeout)
    local deadline = os.clock() + math.max(tonumber(timeout) or 4, 1)
    repeat
        if Feature.isBoorusChallengeActive() then
            return true
        end
        task.wait(0.15)
    until os.clock() >= deadline
    return Feature.isBoorusChallengeActive()
end

function Feature.getBoorusChallengeStartSnapshot()
    return {
        statusReady = Feature.isBoorusChallengeStatusReady(),
        lastPeriod = Feature.getBoorusLastChallengePeriod(),
        currentPeriod = Feature.getCurrentBoorusChallengePeriod(),
        spins = Feature.getBoorusSpinCount(),
    }
end

function Feature.getBoorusChallengeAcceptance(snapshot)
    snapshot = type(snapshot) == "table" and snapshot or {}
    if Feature.isBoorusChallengeActive() then
        return true, "active"
    end

    local lastPeriod = Feature.getBoorusLastChallengePeriod()
    local currentPeriod = Feature.getCurrentBoorusChallengePeriod()
    local previousPeriod = tonumber(snapshot.lastPeriod) or 0
    if lastPeriod > previousPeriod and lastPeriod >= currentPeriod then
        return true, "period"
    end

    if snapshot.statusReady and not Feature.isBoorusChallengeStatusReady() then
        local statusText = Feature.getBoorusChallengeText()
        if statusText ~= "" then
            return true, "timer"
        end
    end

    local previousSpins = tonumber(snapshot.spins) or 0
    if Feature.getBoorusSpinCount() > previousSpins then
        return true, "spin"
    end

    return false, "waiting"
end

function Feature.waitForBoorusChallengeAccepted(timeout, snapshot)
    local deadline = os.clock() + math.max(tonumber(timeout) or 4, 1)
    repeat
        local accepted, reason = Feature.getBoorusChallengeAcceptance(snapshot)
        if accepted then
            return accepted, reason
        end
        task.wait(0.15)
    until os.clock() >= deadline
    return Feature.getBoorusChallengeAcceptance(snapshot)
end

function Feature.disableAutoSkipForBoorus()
    if Feature.dataGet("AutoSkip", false) ~= true then
        return false
    end

    State.boorusStatus = "Disabling auto skip before Boorus challenge."
    Log.push(State.boorusStatus)
    return Remote.fire("AutoSkip")
end

function Feature.startBoorusChallengeIfReady()
    if Feature.isBoorusChallengeActive() then
        State.boorusFightUntil = math.max(
            tonumber(State.boorusFightUntil) or 0,
            os.clock() + math.max(tonumber(Config.boorus.fightSupportWindow) or 600, 60)
        )
        State.boorusStatus = "Boorus challenge active."
        return true
    end

    if not Feature.isBoorusChallengeReady() then
        local statusText = Feature.getBoorusChallengeText()
        State.boorusStatus = statusText ~= "" and statusText or "Boorus challenge is not ready yet."
        return false
    end

    Feature.disableAutoSkipForBoorus()

    if Feature.isWaveStarted() then
        State.boorusStatus = "Stopping wave before Boorus challenge."
        Log.push(State.boorusStatus)
        Remote.fire("EndWave")
        task.wait(math.max(tonumber(Config.safety.remoteCooldown) or 0.35, 0.2))
        return false
    end

    local prompt = Feature.getBoorusChallengePrompt()
    if not prompt or not prompt.Enabled then
        State.boorusStatus = "Boorus challenge prompt was not found."
        return false
    end

    local now = os.clock()
    if now - (State.lastBoorusChallengeStartAt or 0) < math.max(tonumber(Config.boorus.startCooldown) or 6, 1) then
        return false
    end

    State.lastBoorusChallengeStartAt = now
    local startSnapshot = Feature.getBoorusChallengeStartSnapshot()
    local moved = Feature.moveToPromptNaturally(prompt, Config.boorus.promptDistance)
    local prompted = moved and Feature.holdPromptNaturally(prompt)
    local accepted, acceptedReason = false, "waiting"
    if prompted then
        accepted, acceptedReason = Feature.waitForBoorusChallengeAccepted(Config.boorus.startConfirmTimeout, startSnapshot)
    end
    if prompted and accepted then
        if acceptedReason == "active" then
            State.boorusFightUntil = os.clock() + math.max(tonumber(Config.boorus.fightSupportWindow) or 600, 60)
            State.boorusStatus = "Boorus challenge started."
        else
            State.boorusStatus = "Boorus challenge accepted; waiting for spin reward."
        end
        Log.push(State.boorusStatus)
        task.wait(math.max(tonumber(Config.safety.remoteCooldown) or 0.35, 0.2))
        return true
    elseif prompted then
        State.boorusStatus = "Boorus challenge did not activate."
    else
        State.boorusStatus = "Boorus challenge prompt failed."
    end
    return false
end

function Feature.attachBoorusSpinComplete()
    if State.boorusSpinCompleteAttached then
        return true
    end

    local remote = Remote.get("BeerusSpin")
    if not remote or not remote:IsA("RemoteEvent") then
        State.boorusStatus = "Missing RemoteEvent: BeerusSpin"
        return false
    end

    State.boorusSpinCompleteAttached = true
    Maid:add(remote.OnClientEvent:Connect(function(payload)
        if type(payload) == "table" and payload.Action == "Result" then
            task.delay(math.max(tonumber(Config.boorus.spinCompleteDelay) or 0.65, 0.35), function()
                Feature.notifyRareWebhook({
                    kind = "Rare Boorus Reward",
                    source = "Boorus",
                    reward = Feature.describeWebhookPayloadValue(payload.NotifyText or payload),
                    payload = payload,
                })
                Remote.fire("BeerusSpin", "Complete", { NotifyText = payload.NotifyText })
                State.boorusStatus = "Boorus spin reward collected."
                Log.push(State.boorusStatus)
            end)
        end
    end))
    return true
end

function Feature.boorusSpinOnce()
    local now = os.clock()
    if now < (tonumber(State.boorusSpinBusyUntil) or 0) then
        return false
    end

    local spins = Feature.getBoorusSpinCount()
    if spins <= 0 then
        State.boorusStatus = "Boorus: 0 spins available."
        return false
    end

    if not Feature.attachBoorusSpinComplete() then
        return false
    end

    local ok = Remote.fire("BeerusSpin", "Spin")
    if ok then
        State.boorusSpinBusyUntil = now + math.max(tonumber(Config.boorus.spinBusyTime) or 6.8, 1)
        State.boorusStatus = "Boorus spin sent (" .. tostring(spins) .. " before spin)."
        Log.push(State.boorusStatus)
    end
    return ok
end

function Feature.runBoorusFightSupport()
    if os.clock() > (tonumber(State.boorusFightUntil) or 0) then
        return false
    end

    if not Feature.isWaveStarted() then
        Feature.autoStartWaveStep()
    end
    if Config.flags.autoFastForward or Config.boorus.autoFastForward ~= false then
        Feature.fireFastForward("boorus")
    end
    return true
end

function Feature.describeBoorusAvailability()
    local spins = Feature.getBoorusSpinCount()
    if spins > 0 then
        return "Boorus: " .. tostring(spins) .. " spin(s) available."
    end
    if Feature.isBoorusChallengeActive() then
        return "Boorus challenge active."
    end
    if Feature.isBoorusChallengeReady() then
        return "Boorus challenge ready."
    end

    local statusText = Feature.getBoorusChallengeText()
    if statusText ~= "" then
        return "Boorus: " .. statusText
    end

    local lastChallengePeriod = Feature.getBoorusLastChallengePeriod()
    local currentPeriod = Feature.getCurrentBoorusChallengePeriod()
    if lastChallengePeriod >= currentPeriod then
        return "Boorus challenge already completed this reset; waiting for reset."
    end
    return "Boorus waiting for challenge reset or spins."
end

function Feature.autoBoorusStep()
    if Feature.boorusSpinOnce() then
        return true
    end
    if Feature.runBoorusFightSupport() then
        return true
    end
    if Feature.startBoorusChallengeIfReady() then
        if not Feature.runBoorusFightSupport() then
            Feature.boorusSpinOnce()
        end
        return true
    end
    State.boorusStatus = Feature.describeBoorusAvailability()
    return false
end

function Feature.toggleBoorus(value)
    Config.flags.autoBoorus = value
    if value then
        State.boorusStatus = Feature.describeBoorusAvailability()
        Log.push(State.boorusStatus)
        Feature.attachBoorusSpinComplete()
        Feature.startLoop("autoBoorus", function()
            if os.clock() < (tonumber(State.boorusSpinBusyUntil) or 0) then
                return math.max((tonumber(State.boorusSpinBusyUntil) or 0) - os.clock(), tonumber(Config.delays.event) or 1)
            end
            if os.clock() <= (tonumber(State.boorusFightUntil) or 0) then
                return math.max(tonumber(Config.boorus.fightSupportPoll) or 2, tonumber(Config.delays.event) or 1)
            end
            return Config.delays.event
        end, Feature.autoBoorusStep)
    else
        Feature.stopLoop("autoBoorus")
        State.boorusFightUntil = 0
    end
end

function Feature.getBuharaData()
    local now = os.clock()
    local interval = math.max(tonumber(Config.buhara.dataPollInterval) or 1.0, tonumber(Config.safety.remoteCooldown) or 0.35)
    if now - (State.buharaDataScanAt or 0) < interval then
        return State.buhara
    end

    State.buharaDataScanAt = now
    local data = Remote.invoke("BuharaData")
    if type(data) == "table" then
        State.buhara = data
        return data
    end
    return State.buhara
end

function Feature.getBuharaGuiSlots()
    local gui = PlayerGui:FindFirstChild("BuharaEvent")
    local progress = gui and gui:FindFirstChild("Progress")
    local frame = progress and progress:FindFirstChild("Frame")
    local slots = {}
    if not frame then
        return slots
    end

    for _, slot in ipairs(frame:GetChildren()) do
        local itemName = slot:FindFirstChild("ItemName", true)
        local quantity = slot:FindFirstChild("Quantity", true)
        if itemName and quantity and itemName:IsA("TextLabel") and quantity:IsA("TextLabel") then
            local current, required = tostring(quantity.Text or ""):match("(%d+)%s*/%s*(%d+)")
            current = tonumber(current)
            required = tonumber(required)
            table.insert(slots, {
                name = itemName.Text,
                quantity = quantity.Text,
                current = current,
                required = required,
                complete = current ~= nil and required ~= nil and required > 0 and current >= required,
            })
        end
    end
    return slots
end

function Feature.getBuharaWantedFoods(data)
    local wanted = {}
    local foodNeeded = type(data) == "table" and data.FoodNeeded or nil
    if type(foodNeeded) == "table" then
        for foodName, missing in pairs(foodNeeded) do
            if missing == true then
                table.insert(wanted, tostring(foodName))
            end
        end
    end

    if #wanted == 0 then
        for _, slot in ipairs(Feature.getBuharaGuiSlots()) do
            if slot.complete ~= true then
                table.insert(wanted, slot.name)
            end
        end
    end

    return uniqueSorted(wanted)
end

function Feature.areBuharaRequirementsReady(data)
    local foodNeeded = type(data) == "table" and data.FoodNeeded or nil
    if type(foodNeeded) == "table" then
        local sawRequirement = false
        for _, missing in pairs(foodNeeded) do
            sawRequirement = true
            if missing == true then
                return false
            end
        end
        if sawRequirement then
            return true
        end
    end

    local slots = Feature.getBuharaGuiSlots()
    if #slots == 0 then
        return false
    end

    for _, slot in ipairs(slots) do
        if slot.complete ~= true then
            return false
        end
    end
    return true
end

function Feature.getBuharaCanonicalFoodName(value)
    for _, foodName in ipairs(Config.buhara.foodNames) do
        if textMatchesAny(value, { foodName }) then
            return foodName
        end
    end
    return nil
end

function Feature.getBuharaFoodName(instance)
    if not instance then
        return nil
    end

    for _, attrName in ipairs({ "FoodName", "ItemName", "Food", "Ingredient", "BuharaFood", "DisplayName" }) do
        local attrValue = instance:GetAttribute(attrName)
        local foodName = Feature.getBuharaCanonicalFoodName(attrValue)
        if foodName then
            return foodName
        end
    end

    local current = instance
    while current and current ~= workspace do
        local foodName = Feature.getBuharaCanonicalFoodName(current.Name)
        if foodName then
            return foodName
        end
        current = current.Parent
    end

    for _, child in ipairs(instance:GetDescendants()) do
        if child:IsA("StringValue") then
            local foodName = Feature.getBuharaCanonicalFoodName(child.Value)
            if foodName then
                return foodName
            end
        elseif child:IsA("TextLabel") or child:IsA("TextButton") then
            local foodName = Feature.getBuharaCanonicalFoodName(child.Text)
            if foodName then
                return foodName
            end
        end
    end

    return nil
end

function Feature.isBuharaFoodHeldByOtherPlayer(instance)
    if not instance then
        return false
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and (instance == player.Character or instance:IsDescendantOf(player.Character)) then
            return true
        end
    end

    local current = instance
    while current and current ~= workspace do
        for _, attrName in ipairs({ "Owner", "OwnerName", "Player", "PlayerName", "UserId", "OwnerId" }) do
            local owner = current:GetAttribute(attrName)
            if owner ~= nil then
                local ownerText = tostring(owner)
                if ownerText ~= tostring(LocalPlayer.Name) and ownerText ~= tostring(LocalPlayer.UserId) then
                    return true
                end
            end
        end
        current = current.Parent
    end
    return false
end

function Feature.getBuharaScanRoots()
    local roots = {}
    local seen = {}
    local function add(instance)
        if instance and not seen[instance] then
            seen[instance] = true
            table.insert(roots, instance)
        end
    end

    local mutationContainer = workspace:FindFirstChild("MutationStuffs")
    if mutationContainer then
        for _, container in ipairs(mutationContainer:GetChildren()) do
            if container:GetAttribute("FoodName")
                or textMatchesAny(container.Name, { "Food", "FoodPickupItem", "Ingredient", "Sandwich", "Buhara", "Burah", "Trait", "Shard" })
            then
                add(container)
            end
        end
        add(mutationContainer)
    end

    for _, name in ipairs({ "Debris", "EventAttachments", "Map", "Food", "Foods", "Drops", "BuharaEvent" }) do
        add(workspace:FindFirstChild(name))
    end
    for _, child in ipairs(workspace:GetChildren()) do
        if textMatchesAny(child.Name, { "Food", "Ingredient", "Sandwich", "Buhara", "Burah", "Trait", "Shard" }) then
            add(child)
        end
    end
    return roots
end

function Feature.refreshBuharaFoodDropCache(wantedFoods)
    local wanted = {}
    for _, foodName in ipairs(wantedFoods or {}) do
        local canonical = Feature.getBuharaCanonicalFoodName(foodName)
        if canonical then
            wanted[canonical] = true
        end
    end
    local root = Feature.getCharacterRoot()
    local drops = {}
    local seen = {}
    local scanned = 0
    for _, scanRoot in ipairs(Feature.getBuharaScanRoots()) do
        local scanItems = { scanRoot }
        for _, descendant in ipairs(scanRoot:GetDescendants()) do
            table.insert(scanItems, descendant)
        end

        for _, instance in ipairs(scanItems) do
            scanned += 1
            if scanned > (tonumber(Config.buhara.maxScanItems) or 450) then
                break
            end

            if instance:IsA("ProximityPrompt") or instance:IsA("BasePart") or instance:IsA("Model") or instance:IsA("Tool") then
                local foodName = Feature.getBuharaFoodName(instance)
                if foodName and wanted[foodName] and not Feature.isBuharaFoodHeldByOtherPlayer(instance) then
                    local prompt = instance:IsA("ProximityPrompt") and instance or instance:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local target = prompt or instance
                    local part = Feature.getTargetPart(target)
                    if part and not seen[part] then
                        seen[part] = true
                        table.insert(drops, {
                            name = foodName,
                            instance = target,
                            prompt = prompt,
                            distance = root and (root.Position - part.Position).Magnitude or 0,
                        })
                    end
                end
            end
        end
        if scanned > (tonumber(Config.buhara.maxScanItems) or 450) then
            break
        end
    end

    table.sort(drops, function(a, b)
        return (a.distance or 0) < (b.distance or 0)
    end)
    State.buharaFoodDrops = drops
    State.buharaFoodScanAt = os.clock()
    return drops
end

function Feature.getBuharaFoodDrops(wantedFoods)
    local wanted = {}
    for _, foodName in ipairs(wantedFoods or {}) do
        local canonical = Feature.getBuharaCanonicalFoodName(foodName)
        if canonical then
            wanted[canonical] = true
        end
    end
    if next(wanted) == nil then
        State.buharaFoodDrops = {}
        return {}
    end

    if os.clock() - (State.buharaFoodScanAt or 0) < (tonumber(Config.buhara.scanInterval) or 0.65) then
        return State.buharaFoodDrops or {}
    end
    return Feature.refreshBuharaFoodDropCache(wantedFoods)
end

function Feature.findWantedBuharaFood(wantedFoods)
    return Feature.getBuharaFoodDrops(wantedFoods)[1]
end

function Feature.detectCarriedBuharaFood()
    local character = LocalPlayer.Character
    if not character then
        return false
    end
    if character:GetAttribute("CarryingFood") == true then
        return true
    end

    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("Tool") or descendant:IsA("Model") or descendant:IsA("BasePart") then
            if Feature.getBuharaFoodName(descendant) then
                return true
            end
        end
    end
    return false
end

function Feature.isCarryingBuharaFood()
    return Feature.detectCarriedBuharaFood()
end

function Feature.teleportToBuharaObject(instance, distance)
    local root = Feature.getCharacterRoot()
    local targetPart = Feature.getTargetPart(instance)
    if not root or not targetPart then
        Log.push("Buhara teleport target was not found.")
        return false
    end

    local offset = math.max(tonumber(distance) or Config.buhara.teleportOffset or 1.35, 0.5)
    local direction = root.Position - targetPart.Position
    if direction.Magnitude < 0.1 then
        direction = -targetPart.CFrame.LookVector
    else
        direction = direction.Unit
    end

    local targetPosition = targetPart.Position + direction * offset + Vector3.new(0, 2.15, 0)
    return Feature.teleportToCFrame(CFrame.lookAt(targetPosition, targetPart.Position))
end

function Feature.tryBuharaPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end
    return Feature.holdPrompt(prompt)
end

function Feature.collectBuharaFood(drop)
    if not drop or not drop.instance then
        return false
    end
    if Feature.isBuharaFoodHeldByOtherPlayer(drop.instance) then
        return false
    end

    for attempt = 1, math.max(tonumber(Config.buhara.collectRetries) or 1, 1) do
        if Feature.isBuharaFoodHeldByOtherPlayer(drop.instance) then
            return false
        end
        Feature.teleportToBuharaObject(drop.instance, Config.buhara.foodCollectDistance)
        task.wait(0.06)
        if drop.prompt then
            Feature.tryBuharaPrompt(drop.prompt)
        else
            local prompt = drop.instance:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                Feature.tryBuharaPrompt(prompt)
            end
        end
        task.wait(0.18)
        if Feature.detectCarriedBuharaFood() then
            return true
        end
    end
    return Feature.isCarryingBuharaFood()
end

function Feature.findBuharaTarget()
    if State.buharaTarget and State.buharaTarget.Parent and os.clock() - (State.buharaTargetScanAt or 0) < (tonumber(Config.buhara.scanInterval) or 0.65) then
        return State.buharaTarget
    end

    local scanned = 0
    for _, scanRoot in ipairs(Feature.getBuharaScanRoots()) do
        if textMatchesAny(scanRoot.Name, Config.buhara.feedTargetNames) and Feature.getTargetPart(scanRoot) then
            State.buharaTarget = scanRoot
            State.buharaTargetScanAt = os.clock()
            return scanRoot
        end
        for _, instance in ipairs(scanRoot:GetDescendants()) do
            scanned += 1
            if scanned > (tonumber(Config.buhara.maxScanItems) or 450) then
                break
            end
            if textMatchesAny(instance.Name, Config.buhara.feedTargetNames) then
                local part = Feature.getTargetPart(instance)
                if part then
                    State.buharaTarget = instance
                    State.buharaTargetScanAt = os.clock()
                    return instance
                end
            end
        end
        if scanned > (tonumber(Config.buhara.maxScanItems) or 450) then
            break
        end
    end
    State.buharaTarget = nil
    State.buharaTargetScanAt = os.clock()
    return nil
end

function Feature.isBuharaFeedPrompt(prompt, target)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then
        return false
    end

    local text = normalizeText(tostring(prompt.ActionText or "") .. " " .. tostring(prompt.ObjectText or "") .. " " .. prompt.Name)
    if textMatchesAny(text, { "buy", "roll", "gift", "sell", "spin", "clone", "craft", "fuse", "claim" }) then
        return false
    end
    if textMatchesAny(text, { "give", "feed", "food", "sandwich", "buhara" }) then
        return true
    end
    return target and prompt:IsDescendantOf(target)
end

function Feature.getBuharaFeedPrompt(target)
    if target then
        for _, descendant in ipairs(target:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and Feature.isBuharaFeedPrompt(descendant, target) then
                return descendant
            end
        end
    end

    local scanned = 0
    for _, scanRoot in ipairs(Feature.getBuharaScanRoots()) do
        for _, instance in ipairs(scanRoot:GetDescendants()) do
            scanned += 1
            if scanned > (tonumber(Config.buhara.maxScanItems) or 450) then
                break
            end
            if instance:IsA("ProximityPrompt") and Feature.isBuharaFeedPrompt(instance, target) then
                return instance
            end
        end
        if scanned > (tonumber(Config.buhara.maxScanItems) or 450) then
            break
        end
    end
    return nil
end

function Feature.getBuharaLegCenter(target)
    if not target then
        return nil
    end

    local left = target:FindFirstChild("LeftFoot", true) or target:FindFirstChild("LeftLowerLeg", true) or target:FindFirstChild("Left Leg", true)
    local right = target:FindFirstChild("RightFoot", true) or target:FindFirstChild("RightLowerLeg", true) or target:FindFirstChild("Right Leg", true)
    if left and right and left:IsA("BasePart") and right:IsA("BasePart") then
        return (left.Position + right.Position) * 0.5
    end

    local root = Feature.getTargetPart(target)
    return root and root.Position or nil
end

function Feature.moveToBuharaFeedPrompt(target, prompt)
    if prompt then
        return Feature.teleportToBuharaObject(prompt, Config.buhara.feedDistance)
    end

    return Feature.teleportToBuharaObject(target, Config.buhara.feedDistance)
end

function Feature.setBuharaHoldBackoff(message)
    local now = os.clock()
    State.buharaHoldUntil = now + math.max(tonumber(Config.buhara.holdPoll) or 4, 1)
    local logInterval = math.max(tonumber(Config.buhara.holdLogInterval) or 8, 1)
    if State.lastBuharaHoldLogAt == 0 or now - (State.lastBuharaHoldLogAt or 0) >= logInterval then
        State.lastBuharaHoldLogAt = now
        Log.push(message)
    end
end

function Feature.clearBuharaHoldBackoff()
    State.buharaHoldUntil = 0
end

function Feature.shouldPauseBuharaForAutoMerge()
    return Config.flags.autoMerge == true
end

function Feature.getBuharaEventNames()
    local names = {}
    for _, item in ipairs(Config.buhara.eventNames or { "Buhara", "Burah", "BuharaEvent" }) do
        if type(item) == "string" and item ~= "" then
            table.insert(names, item)
        end
    end
    return uniqueSorted(names)
end

function Feature.isBuharaEventActive()
    local eventNames = Feature.getBuharaEventNames()
    if not listHasItems(eventNames) then
        return false
    end

    if State.activeEventText ~= ""
        and os.clock() - (State.lastEventUiAt or 0) < 180
        and textMatchesAny(State.activeEventText, eventNames)
        and Feature.isSelectedEventPayloadText(State.activeEventText, eventNames) then
        return true
    end

    local eventText = Feature.scanEventTextForNames(eventNames)
    if eventText ~= "" then
        State.activeEventText = eventText
        State.lastEventUiAt = os.clock()
        return true
    end

    State.scanGuiText()
    if Feature.isEventStatusText(State.waveStatus) and textMatchesAny(State.waveStatus, eventNames) then
        return true
    end

    local main = PlayerGui:FindFirstChild("MainUI")
    local frames = main and main:FindFirstChild("Frames")
    if Feature.textRootHasSelectedEvent(frames and frames:FindFirstChild("Events"), eventNames) then
        return true
    end

    return Feature.hasActiveBuharaProgress()
end

function Feature.hasActiveBuharaProgress(data)
    local foodNeeded = type(data) == "table" and data.FoodNeeded or nil
    if type(foodNeeded) == "table" then
        for _ in pairs(foodNeeded) do
            return true
        end
    end

    local slots = Feature.getBuharaGuiSlots()
    if #slots > 0 then
        return true
    end

    local gui = PlayerGui:FindFirstChild("BuharaEvent")
    if not gui or gui.Enabled == false then
        return false
    end

    local progress = gui:FindFirstChild("Progress")
    if progress and progress:IsA("GuiObject") and progress.Visible == false then
        return false
    end

    if Feature.areBuharaRequirementsReady(data) then
        return true
    end
    if #Feature.getBuharaWantedFoods(data) > 0 then
        return true
    end
    return false
end

function Feature.shouldRunAutoBuhara()
    if Feature.isBuharaEventActive() then
        return true
    end
    if Feature.isCarryingBuharaFood() then
        return true
    end
    local data = Feature.getBuharaData()
    if Feature.hasActiveBuharaProgress(data) then
        return true
    end

    State.buharaFoodDrops = {}
    State.buharaFoodScanAt = os.clock()
    State.buharaTarget = nil
    State.buharaTargetScanAt = os.clock()
    return false
end

function Feature.getAutoBuharaLoopDelay()
    if Feature.shouldPauseBuharaForAutoMerge() then
        return math.max(tonumber(Config.delays.mergeIdle) or 2.5, tonumber(Config.delays.event) or 1)
    end
    if not Feature.shouldRunAutoBuhara() then
        return math.max(tonumber(Config.buhara.holdPoll) or 4.0, tonumber(Config.delays.event) or 1)
    end

    local now = os.clock()
    local holdUntil = tonumber(State.buharaHoldUntil) or 0
    if holdUntil > now then
        return math.max(holdUntil - now, tonumber(Config.delays.event) or 1)
    end
    return Config.delays.event
end

function Feature.giveCarriedBuharaFood(target, prompt)
    if not Feature.isCarryingBuharaFood() then
        return false
    end
    if not target or not prompt then
        return false
    end
    if not Feature.moveToBuharaFeedPrompt(target, prompt) then
        return false
    end

    task.wait(0.08)
    Feature.tryBuharaPrompt(prompt)
    task.wait(0.2)
    return not Feature.isCarryingBuharaFood()
end

function Feature.feedBuhara(forceAttempt)
    if not forceAttempt and not Feature.isCarryingBuharaFood() then
        return false
    end
    if not Feature.isCarryingBuharaFood() then
        return false
    end

    local target = Feature.findBuharaTarget()
    if not target then
        Feature.setBuharaHoldBackoff("Buhara target is not visible yet; holding food.")
        return false
    end

    local prompt = Feature.getBuharaFeedPrompt(target)
    if not prompt then
        Feature.moveToBuharaFeedPrompt(target, nil)
        Feature.setBuharaHoldBackoff("Buhara feed prompt was not found yet; holding food.")
        return false
    end

    Feature.clearBuharaHoldBackoff()
    for attempt = 1, math.max(tonumber(Config.buhara.feedRetries) or 1, 1) do
        if Feature.giveCarriedBuharaFood(target, prompt) then
            Feature.clearBuharaHoldBackoff()
            return true
        end
    end
    return not Feature.isCarryingBuharaFood()
end

function Feature.autoBuharaStep()
    if Feature.shouldPauseBuharaForAutoMerge() then
        return false
    end
    if not Feature.shouldRunAutoBuhara() then
        return false
    end

    if Feature.isCarryingBuharaFood() then
        return Feature.feedBuhara()
    end

    Feature.clearBuharaHoldBackoff()
    local data = Feature.getBuharaData()
    if Feature.areBuharaRequirementsReady(data) and Feature.feedBuhara(true) then
        return true
    end

    local wantedFoods = Feature.getBuharaWantedFoods(data)
    if #wantedFoods == 0 then
        return false
    end

    local drop = Feature.findWantedBuharaFood(wantedFoods)
    if not drop then
        return false
    end
    return Feature.collectBuharaFood(drop)
end

function Feature.toggleBuhara(value)
    Config.flags.autoBuhara = value
    if value then
        Feature.clearBuharaHoldBackoff()
        Feature.startLoop("autoBuhara", Feature.getAutoBuharaLoopDelay, Feature.autoBuharaStep)
    else
        Feature.stopLoop("autoBuhara")
        Feature.clearBuharaHoldBackoff()
    end
end

function Feature.isShenronDecorationDragonBall(instance)
    local current = instance
    while current and current ~= workspace do
        if textMatchesAny(current.Name, { "Design", "Decoration", "Decor", "Visual", "VFX", "Effect" }) then
            return true
        end
        current = current.Parent
    end
    return false
end

function Feature.getMutationStuffsShenronRoot(instance)
    local mutationStuffs = workspace:FindFirstChild("MutationStuffs")
    if not mutationStuffs or not instance or not instance:IsDescendantOf(mutationStuffs) then
        return nil
    end

    local current = instance
    local candidate = nil
    while current and current ~= mutationStuffs do
        local currentName = tostring(current.Name or "")
        if not candidate
            and (currentName:match("^Ball%d$")
                or textMatchesAny(currentName, { "DragonBall", "Dragon Ball", "Shenron", "Super Dragon balls" })) then
            candidate = current
        end
        current = current.Parent
    end
    return candidate
end

function Feature.isMutationStuffsShenronDragonBallRoot(instance)
    local root = Feature.getMutationStuffsShenronRoot(instance)
    if not root or Feature.isShenronDecorationDragonBall(root) then
        return false
    end

    local rootName = tostring(root.Name or "")
    local hasBallName = rootName:match("^Ball%d$")
        or textMatchesAny(rootName, { "DragonBall", "Dragon Ball", "Shenron", "Super Dragon balls" })
    if not hasBallName then
        return false
    end

    return Feature.getShenronCollectPrompt(root) ~= nil
end

function Feature.getShenronScanRoots()
    local roots = {}
    local seen = {}
    local function add(instance)
        if instance and not seen[instance] then
            seen[instance] = true
            table.insert(roots, instance)
        end
    end

    add(workspace:FindFirstChild("EventAttachments"))
    add(workspace:FindFirstChild("ShenronDragonBalls"))
    local mutationStuffs = workspace:FindFirstChild("MutationStuffs")
    if mutationStuffs then
        for _, child in ipairs(mutationStuffs:GetChildren()) do
            if Feature.isMutationStuffsShenronDragonBallRoot(child) then
                add(child)
            end
        end
        for _, descendant in ipairs(mutationStuffs:GetDescendants()) do
            if Feature.isMutationStuffsShenronDragonBallRoot(descendant) then
                add(descendant)
            end
        end
    end
    add(workspace:FindFirstChild("Debris"))
    add(workspace:FindFirstChild("Map"))
    for _, child in ipairs(workspace:GetChildren()) do
        if textMatchesAny(child.Name, { "DragonBall", "Dragon Ball", "Shenron", "SuperShenron", "Event" }) then
            add(child)
        end
    end
    return roots
end

function Feature.getShenronDragonBallName(instance)
    if not instance then
        return nil
    end

    local mutationStuffs = workspace:FindFirstChild("MutationStuffs")
    if mutationStuffs and instance:IsDescendantOf(mutationStuffs)
        and not Feature.isMutationStuffsShenronDragonBallRoot(instance) then
        return nil
    end

    local function parse(value)
        local text = tostring(value or "")
        local direct = text:match("DragonBall%d")
        if direct then
            return direct
        end
        local number = normalizeText(text):match("dragon%s*ball%s*(%d)")
        if number then
            return "DragonBall" .. tostring(number)
        end
        return nil
    end

    for _, attrName in ipairs({ "DragonBallName", "BallName", "ItemName", "DisplayName" }) do
        local ballName = parse(instance:GetAttribute(attrName))
        if ballName then
            return ballName
        end
    end

    local current = instance
    while current and current ~= workspace do
        local ballName = parse(current.Name)
        if ballName then
            return ballName
        end
        local ballNumber = tostring(current.Name or ""):match("^Ball(%d)$")
        if ballNumber then
            local shenronDragonBalls = workspace:FindFirstChild("ShenronDragonBalls")
            local character = LocalPlayer.Character
            if (mutationStuffs and Feature.isMutationStuffsShenronDragonBallRoot(current))
                or (shenronDragonBalls and current:IsDescendantOf(shenronDragonBalls))
                or (character and current:IsDescendantOf(character)) then
                return "DragonBall" .. tostring(ballNumber)
            end
        end
        current = current.Parent
    end
    return nil
end

function Feature.isShenronCollectPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or prompt.Enabled == false then
        return false
    end
    return textMatchesAny(prompt.ActionText, { "Collect", "Dragon" }) or textMatchesAny(prompt.Name, { "Collect", "Dragon", "Ball" })
end

function Feature.isShenronPromptScanBoundary(instance)
    if not instance or instance == workspace then
        return true
    end
    return instance == workspace:FindFirstChild("MutationStuffs")
        or instance == workspace:FindFirstChild("EventAttachments")
        or instance == workspace:FindFirstChild("ShenronDragonBalls")
        or instance == workspace:FindFirstChild("Debris")
        or instance == workspace:FindFirstChild("Map")
end

function Feature.getShenronCollectPrompt(instance)
    local current = instance
    while current and current ~= workspace do
        if Feature.isShenronPromptScanBoundary(current) then
            break
        end

        if Feature.isShenronCollectPrompt(current) then
            return current
        end

        local prompt = current:FindFirstChildWhichIsA("ProximityPrompt", true)
        if Feature.isShenronCollectPrompt(prompt) then
            return prompt
        end

        if Feature.isShenronPromptScanBoundary(current.Parent) then
            break
        end
        current = current.Parent
    end
    return nil
end

function Feature.refreshShenronDragonBallCache()
    local root = Feature.getCharacterRoot()
    local balls = {}
    local seen = {}
    local scanned = 0

    for _, scanRoot in ipairs(Feature.getShenronScanRoots()) do
        local scanItems = { scanRoot }
        for _, descendant in ipairs(scanRoot:GetDescendants()) do
            table.insert(scanItems, descendant)
        end

        for _, instance in ipairs(scanItems) do
            scanned += 1
            if scanned > (tonumber(Config.shenron.maxScanItems) or 650) then
                break
            end

            if instance:IsA("BasePart") or instance:IsA("Model") or instance:IsA("Tool") then
                local ballName = Feature.getShenronDragonBallName(instance)
                local targetPart = ballName and Feature.getTargetPart(instance) or nil
                if ballName and targetPart and targetPart:IsDescendantOf(workspace) and not seen[targetPart] then
                    seen[targetPart] = true
                    table.insert(balls, {
                        name = ballName,
                        instance = instance,
                        part = targetPart,
                        prompt = Feature.getShenronCollectPrompt(instance),
                        distance = root and (root.Position - targetPart.Position).Magnitude or 0,
                    })
                end
            end
        end
        if scanned > (tonumber(Config.shenron.maxScanItems) or 650) then
            break
        end
    end

    table.sort(balls, function(a, b)
        return (a.distance or 0) < (b.distance or 0)
    end)
    State.shenronDragonBalls = balls
    State.shenronDragonBallScanAt = os.clock()
    return balls
end

function Feature.getShenronDragonBalls()
    if not Feature.isSuperShenronEventActive() then
        State.shenronDragonBalls = {}
        State.shenronDragonBallScanAt = os.clock()
        return {}
    end

    if os.clock() - (State.shenronDragonBallScanAt or 0) < (tonumber(Config.shenron.scanInterval) or 0.65) then
        return State.shenronDragonBalls or {}
    end
    return Feature.refreshShenronDragonBallCache()
end

function Feature.detectCarriedShenronDragonBall()
    local character = LocalPlayer.Character
    if not character then
        return false
    end

    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("Tool") or descendant:IsA("Model") or descendant:IsA("BasePart") then
            if Feature.getShenronDragonBallName(descendant) then
                return true
            end
        end
    end
    return false
end

function Feature.collectShenronDragonBall(ball)
    if not ball or not ball.instance then
        return false
    end

    for attempt = 1, math.max(tonumber(Config.shenron.collectRetries) or 1, 1) do
        Feature.teleportToBuharaObject(ball.instance, Config.shenron.ballCollectDistance)
        task.wait(0.06)
        local prompt = ball.prompt or Feature.getShenronCollectPrompt(ball.instance)
        if prompt then
            Feature.tryBuharaPrompt(prompt)
            task.wait(0.08)
        end
        Feature.touchInstance(ball.instance)
        task.wait(0.18)
        if Feature.detectCarriedShenronDragonBall() or not ball.part or not ball.part:IsDescendantOf(workspace) then
            State.shenronCollectedSinceTurnIn = (tonumber(State.shenronCollectedSinceTurnIn) or 0) + 1
            State.shenronDragonBallScanAt = 0
            State.shenronStatus = "Collected " .. tostring(ball.name) .. "."
            return true
        end
    end
    return Feature.detectCarriedShenronDragonBall()
end

function Feature.getShenronTurnInTarget()
    if State.shenronTurnInTarget
        and State.shenronTurnInTarget.Parent
        and os.clock() - (State.shenronTurnInTargetScanAt or 0) < (tonumber(Config.shenron.scanInterval) or 0.65) then
        return State.shenronTurnInTarget
    end

    local attachments = workspace:FindFirstChild("EventAttachments")
    local spawn = attachments and attachments:FindFirstChild("ShenronSpawn")
    local balls = spawn and spawn:FindFirstChild("Balls")
    local transform = balls and balls:FindFirstChild("Transform")
    if transform and transform:IsA("BasePart") then
        State.shenronTurnInTarget = transform
        State.shenronTurnInTargetScanAt = os.clock()
        return transform
    end

    if attachments then
        for _, instance in ipairs(attachments:GetDescendants()) do
            if instance:IsA("BasePart") and textMatchesAny(instance:GetFullName(), { "ShenronSpawn", "Balls", "Transform" }) then
                State.shenronTurnInTarget = instance
                State.shenronTurnInTargetScanAt = os.clock()
                return instance
            end
        end
    end

    State.shenronTurnInTarget = nil
    State.shenronTurnInTargetScanAt = os.clock()
    return nil
end

function Feature.setShenronHoldBackoff(message)
    local now = os.clock()
    State.shenronHoldUntil = now + math.max(tonumber(Config.shenron.holdPoll) or 4, 1)
    local logInterval = math.max(tonumber(Config.shenron.holdLogInterval) or 8, 1)
    if State.lastShenronHoldLogAt == 0 or now - (State.lastShenronHoldLogAt or 0) >= logInterval then
        State.lastShenronHoldLogAt = now
        Log.push(message)
    end
end

function Feature.clearShenronHoldBackoff()
    State.shenronHoldUntil = 0
end

function Feature.hasActionableShenronWork()
    if not Feature.isSuperShenronEventActive() and not Feature.isShenronMeteorCollectionActive() then
        return false
    end
    if Feature.detectCarriedShenronDragonBall() then
        return true
    end
    if (tonumber(State.shenronCollectedSinceTurnIn) or 0) > 0 then
        return true
    end
    if Feature.isShenronMeteorCollectionActive and Feature.isShenronMeteorCollectionActive() then
        return true
    end
    local balls = Feature.getShenronDragonBalls()
    return #balls > 0
end

function Feature.shouldPauseShenronForAutoMerge()
    if Config.flags.autoMerge ~= true then
        return false
    end
    return not Feature.hasActionableShenronWork()
end

function Feature.getShenronWishRequirement(wishName)
    local requirements = Config.shenron.wishRequirements or {}
    return tonumber(requirements[tostring(wishName or "")]) or 0
end

function Feature.isBlockedShenronWish(wishName)
    local clean = normalizeText(wishName)
    if clean == "" then
        return true
    end
    for _, blockedName in ipairs(Config.shenron.blockedWishNames or {}) do
        if normalizeText(blockedName) == clean then
            return true
        end
    end
    return false
end

function Feature.isShenronWishUnlocked(wishName, wishesUsed)
    return (tonumber(wishesUsed) or 0) >= Feature.getShenronWishRequirement(wishName)
end

function Feature.getShenronWishPriorityRank(wishName)
    local clean = normalizeText(wishName)
    if clean == "" then
        return math.huge
    end

    for index, priorityName in ipairs(Config.shenron.wishPriority or {}) do
        if normalizeText(priorityName) == clean then
            return index
        end
    end
    return math.huge
end

function Feature.getBestShenronWish()
    local wishesUsed = tonumber(Feature.dataGet("SuperShenronWishes", 0)) or 0
    local candidates = {}
    for wishName in pairs(Config.shenron.wishRequirements or {}) do
        candidates[tostring(wishName)] = true
    end
    for _, wishName in ipairs(Config.shenron.wishPriority or {}) do
        if type(wishName) == "string" and wishName ~= "" then
            candidates[wishName] = true
        end
    end

    local bestWish = nil
    local bestRequirement = -math.huge
    local bestRank = math.huge
    for wishName in pairs(candidates) do
        if type(wishName) == "string"
            and wishName ~= ""
            and not Feature.isBlockedShenronWish(wishName)
            and Feature.isShenronWishUnlocked(wishName, wishesUsed) then
            local requirement = Feature.getShenronWishRequirement(wishName)
            local rank = Feature.getShenronWishPriorityRank(wishName)
            if requirement > bestRequirement or (requirement == bestRequirement and rank < bestRank) then
                bestWish = wishName
                bestRequirement = requirement
                bestRank = rank
            end
        end
    end
    return bestWish
end

function Feature.getShenronLuckPotionEventNames()
    return Config.shenron.luckPotionEventNames or { "SuperShenron" }
end

function Feature.isSuperShenronEventActive()
    local eventNames = DataSource.expandSnipeEventNames(Feature.getShenronLuckPotionEventNames())
    if not listHasItems(eventNames) then
        return false
    end

    if State.activeEventText ~= ""
        and os.clock() - (State.lastEventUiAt or 0) < 180
        and textMatchesAny(State.activeEventText, eventNames)
        and Feature.isSelectedEventPayloadText(State.activeEventText, eventNames) then
        return true
    end

    local eventText = Feature.scanEventTextForNames(eventNames)
    if eventText ~= "" then
        State.activeEventText = eventText
        State.lastEventUiAt = os.clock()
        return true
    end

    State.scanGuiText()
    if Feature.isEventStatusText(State.waveStatus) and textMatchesAny(State.waveStatus, eventNames) then
        return true
    end

    local main = PlayerGui:FindFirstChild("MainUI")
    local frames = main and main:FindFirstChild("Frames")
    if Feature.textRootHasSelectedEvent(frames and frames:FindFirstChild("Events"), eventNames) then
        return true
    end

    local plot = Feature.getOwnedPlot()
    local roll = plot and plot:FindFirstChild("Roll")
    local rollButton = roll and roll:FindFirstChild("RollButton")
    if Feature.textRootHasSelectedEvent(rollButton and rollButton:FindFirstChild("Luck"), eventNames) then
        return true
    end

    return false
end

function Feature.getPotionInfoByName(potionName)
    local name = tostring(potionName or "")
    if name == "" then
        return nil
    end

    if Feature.potionInfo == nil then
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local shared = modules and modules:FindFirstChild("Shared")
        Feature.potionInfo = DataSource.safeRequire(shared and shared:FindFirstChild("PotionInfo"), 1)
            or DataSource.safeRequire(modules and modules:FindFirstChild("PotionInfo"), 1)
            or false
    end

    local loaded = Feature.potionInfo
    if type(loaded) ~= "table" then
        return nil
    end

    local potions = loaded.Potions or loaded.potions or loaded
    if type(potions) ~= "table" then
        return nil
    end

    local exact = potions[name]
    if type(exact) == "table" then
        return exact
    end

    local clean = normalizeText(name)
    local lookup = normalizedLookupKey(name)
    for potionNameKey, info in pairs(potions) do
        if type(info) == "table"
            and (normalizeText(potionNameKey) == clean or normalizedLookupKey(potionNameKey) == lookup) then
            return info
        end
    end
    return nil
end

function Feature.getPotionDuration(potionName)
    local info = Feature.getPotionInfoByName(potionName)
    return math.max(tonumber(info and info.Duration) or 300, 5)
end

function Feature.valueHasActivePotionBoost(value, boostType, potionName, depth)
    if type(value) ~= "table" then
        return false
    end
    depth = tonumber(depth) or 0
    if depth > 4 then
        return false
    end

    local targetBoost = normalizeText(boostType)
    local targetPotion = normalizeText(potionName)
    local targetPotionLookup = normalizedLookupKey(potionName)
    local nowClock = os.clock()
    local nowUnix = os.time()

    local function matchesText(text)
        local clean = normalizeText(text)
        if clean == "" then
            return false
        end
        if targetBoost ~= "" and (clean == targetBoost or clean:find(targetBoost, 1, true)) then
            return true
        end
        if targetPotion ~= "" and (clean == targetPotion or clean:find(targetPotion, 1, true)) then
            return true
        end
        return targetPotionLookup ~= "" and normalizedLookupKey(text) == targetPotionLookup
    end

    local function isTimedEntryActive(entry)
        if type(entry) ~= "table" then
            return entry == true or (type(entry) == "number" and entry > 0) or (type(entry) == "string" and entry ~= "")
        end

        if entry.Active == false or entry.Enabled == false or entry.Disabled == true then
            return false
        end

        local remaining = tonumber(entry.TimeLeft or entry.Remaining or entry.DurationLeft or entry.SecondsLeft or entry.Value)
        if remaining ~= nil and remaining <= 0 then
            return false
        end

        local expiresAt = tonumber(entry.ExpiresAt or entry.ExpireAt or entry.EndTime or entry.Until or entry.EndsAt)
        if expiresAt ~= nil then
            if expiresAt > 1000000 then
                return expiresAt > nowUnix
            end
            return expiresAt > nowClock
        end

        return true
    end

    for key, item in pairs(value) do
        local matched = matchesText(key)
        if type(item) == "table" then
            local entryText = tostring(item.Name or item.PotionName or item.ID or item.Id or item.BoostType or item.Type or item.Boost or "")
            matched = matched or matchesText(entryText)
            if matched and isTimedEntryActive(item) then
                return true
            end
            if Feature.valueHasActivePotionBoost(item, boostType, potionName, depth + 1) then
                return true
            end
        elseif matched and isTimedEntryActive(item) then
            return true
        end
    end
    return false
end

function Feature.isLuckPotionActive()
    local potionName = tostring(Config.shenron.luckPotionName or "Luck Potion")
    local duration = Feature.getPotionDuration(potionName)
    if (tonumber(State.lastShenronLuckPotionAt) or 0) > 0
        and os.clock() - State.lastShenronLuckPotionAt < duration then
        return true
    end

    local boosts = Feature.dataGet("PotionBoosts", {})
    return Feature.valueHasActivePotionBoost(boosts, Config.shenron.luckPotionBoostType or "Luck", potionName, 0)
end

function Feature.useLuckPotionForSuperShenronIfReady()
    if Config.shenron.useLuckPotions ~= true then
        return false
    end
    if not Feature.isSuperShenronEventActive() then
        return false
    end
    if Feature.isLuckPotionActive() then
        return false
    end

    local potionName = tostring(Config.shenron.luckPotionName or "Luck Potion")
    if Feature.getItemQuantityByName(potionName) <= 0 then
        local now = os.clock()
        if now - (State.lastShenronLuckPotionLogAt or 0) >= 20 then
            State.lastShenronLuckPotionLogAt = now
            State.shenronStatus = "No Luck Potion available for Super Shenron."
            Log.push(State.shenronStatus)
        end
        return false
    end

    local ok = Remote.fire("UsePotion", potionName)
    if ok then
        State.lastShenronLuckPotionAt = os.clock()
        State.shenronStatus = "Used Luck Potion for Super Shenron event."
        Log.push(State.shenronStatus)
    else
        State.shenronStatus = "Luck Potion use remote was not available."
    end
    return ok
end

function Feature.isShenronDoombringerWish(wishName)
    local clean = normalizeText(wishName)
    return clean == normalizeText("UniqueTrait")
        or clean == normalizeText("Doombringer")
        or clean == normalizeText("DoombringerTrait")
end

function Feature.computeUnitDoombringerTargetStats(unit)
    local static = Feature.getCharacterStaticInfo(unit and unit.name)
    local info = static and static.data
    if type(info) ~= "table" then
        return nil
    end

    local mutationInfo = Feature.getMutationInfo(unit.mutation)
    local level = 1
    local mutationDamage = tonumber(mutationInfo and mutationInfo.DamageMultiplier) or 1
    local baseDamage = Feature.getLevelDamage(info.Damage, level)
    local hitDamage = baseDamage * mutationDamage
    local totalDamage = hitDamage
    local attackType = tostring(info.AttackType or "")

    if attackType == "Barrage" or attackType == "Continuous" then
        local duration = tonumber(info.Duration) or 0
        local tickRate = tonumber(info.TickRate) or 0
        if duration > 0 and tickRate > 0 then
            totalDamage = hitDamage * math.max(1, math.floor(duration / tickRate + 0.0001))
        end
    end

    if info.Burn then
        local burnDuration = tonumber(info.BurnDuration) or 0
        local burnDamage = tonumber(info.BurnDamage) or 0
        local burnTick = tonumber(info.BurnTick) or 0
        if burnDuration > 0 and burnDamage > 0 and burnTick > 0 then
            totalDamage += burnDamage * math.max(1, math.floor(burnDuration / burnTick + 0.0001))
        end
    end

    local cooldown = tonumber(info.Cooldown) or 0
    local dps = cooldown > 0 and (math.floor(totalDamage / cooldown * 10 + 0.5) / 10) or 0
    return {
        damage = totalDamage,
        dps = dps,
        cooldown = cooldown,
        level = level,
        mutationDamage = mutationDamage,
        displayName = static.displayName or unit.name,
    }
end

function Feature.getUnitDoombringerTargetDps(unit)
    local stats = Feature.computeUnitDoombringerTargetStats(unit)
    return tonumber(stats and stats.dps) or 0
end

function Feature.formatWebhookDps(value)
    local number = tonumber(value)
    if not number then
        return tostring(value or "")
    end

    local suffixes = {
        { limit = 1000000000000, suffix = "T" },
        { limit = 1000000000, suffix = "B" },
        { limit = 1000000, suffix = "M" },
        { limit = 1000, suffix = "K" },
    }
    for _, item in ipairs(suffixes) do
        if math.abs(number) >= item.limit then
            local text = string.format("%.1f", number / item.limit):gsub("%.0$", "")
            return text .. item.suffix
        end
    end
    return tostring(math.floor(number * 10 + 0.5) / 10)
end

function Feature.computeUnitDoombringerGrantedStats(unit, fallbackStats)
    if not unit then
        return nil
    end

    local previewUnit = {}
    for key, value in pairs(unit) do
        previewUnit[key] = value
    end
    previewUnit.level = 1
    previewUnit.trait = "Doombringer"

    local derived = Feature.computeUnitDerivedStats(previewUnit)
    local dps = tonumber(derived and derived.dps)
    if not dps or dps <= 0 then
        local baseDps = tonumber(fallbackStats and fallbackStats.dps) or Feature.getUnitDoombringerTargetDps(unit)
        local traitInfo = Feature.getTraitInfo("Doombringer")
        local traitDamage = tonumber(traitInfo and traitInfo.Damage) or 1
        local traitCooldown = math.max(tonumber(traitInfo and traitInfo.Cooldown) or 1, 0.05)
        local critChance = math.max(tonumber(traitInfo and traitInfo.CritChance) or 0, 0)
        local critDamage = math.max(tonumber(traitInfo and traitInfo.CritDamage) or 1, 1)
        local critMultiplier = critChance / 100 * (critDamage - 1) + 1
        dps = baseDps * traitDamage * critMultiplier / traitCooldown
    end

    return {
        dps = dps,
        dpsText = Feature.formatWebhookDps(dps),
    }
end

function Feature.isShenronDoombringerTargetTrait(traitName)
    local clean = normalizeText(traitName)
    for _, skipTrait in ipairs(Config.shenron.doombringerSkipTraits or {}) do
        if normalizeText(skipTrait) == clean then
            return false
        end
    end
    return true
end

function Feature.getShenronDoombringerCandidates()
    State.scanUnits()
    local candidates = {}
    for _, unit in ipairs(State.characters or {}) do
        if unit
            and not unit.crafting
            and not unit.cloning
            and Feature.isShenronDoombringerTargetTrait(unit.trait) then
            local targetStats = Feature.computeUnitDoombringerTargetStats(unit)
            if targetStats and (tonumber(targetStats.dps) or 0) > 0 then
                table.insert(candidates, {
                    unit = unit,
                    targetStats = targetStats,
                    targetDps = targetStats.dps,
                })
            end
        end
    end

    table.sort(candidates, function(left, right)
        local leftDps = tonumber(left and left.targetDps) or 0
        local rightDps = tonumber(right and right.targetDps) or 0
        if leftDps ~= rightDps then
            return leftDps > rightDps
        end

        local leftDamage = tonumber(left and left.targetStats and left.targetStats.damage) or 0
        local rightDamage = tonumber(right and right.targetStats and right.targetStats.damage) or 0
        if leftDamage ~= rightDamage then
            return leftDamage > rightDamage
        end

        local leftLevel = tonumber(left and left.unit and left.unit.level) or 0
        local rightLevel = tonumber(right and right.unit and right.unit.level) or 0
        if leftLevel ~= rightLevel then
            return leftLevel > rightLevel
        end

        return tostring(left and left.unit and left.unit.name or "") < tostring(right and right.unit and right.unit.name or "")
    end)
    return candidates
end

function Feature.pickupShenronDoombringerPlacedUnit(unit)
    if not unit or not unit.placed then
        return true
    end
    return Feature.pickupUnitForMerge(unit)
end

function Feature.stopWaveForShenronDoombringerPrep()
    if not Feature.isWaveStarted() then
        return false
    end

    local now = os.clock()
    local cooldown = math.max(tonumber(Config.delays.wave) or 1.5, 1.0)
    if now - (State.lastShenronWaveStopAt or 0) < cooldown then
        State.shenronStatus = "Doombringer target prep is waiting for the wave to end."
        return true
    end

    State.lastShenronWaveStopAt = now
    State.shenronStatus = "Stopping wave for Doombringer wish prep."
    Log.push(State.shenronStatus)
    Remote.fire("EndWave")
    task.wait(math.max(tonumber(Config.safety.remoteCooldown) or 0.35, 0.2))
    return true
end

function Feature.pickupShenronDoombringerUnits()
    if Feature.isWaveStarted() then
        State.shenronStatus = "Doombringer target prep is waiting for the wave to end."
        Log.push(State.shenronStatus)
        return false
    end

    State.scanUnits()
    local picked = 0
    for _, unit in ipairs(State.characters or {}) do
        if unit and unit.placed then
            if Feature.pickupShenronDoombringerPlacedUnit(unit) then
                picked += 1
            end
        end
    end
    if picked > 0 then
        task.wait(math.max(Config.safety.remoteCooldown, 0.12))
    end
    State.scanUnits()
    return true
end

function Feature.prepareShenronDoombringerWishTarget()
    if Feature.stopWaveForShenronDoombringerPrep() then
        return false
    end

    if not Feature.pickupShenronDoombringerUnits() then
        return false
    end

    local candidates = Feature.getShenronDoombringerCandidates()
    local candidate = candidates[1]
    if not candidate or not candidate.unit then
        State.shenronStatus = "No eligible Doombringer target unit found."
        Log.push(State.shenronStatus)
        return false
    end

    local unit = State.getUnitById(candidate.unit.id)
    if not unit then
        State.scanUnits()
        unit = State.getUnitById(candidate.unit.id)
    end
    unit = unit or candidate.unit

    if Feature.equipUnitForMerge(unit) then
        local dpsText = tostring(math.floor((tonumber(candidate.targetDps) or 0) * 10 + 0.5) / 10)
        local grantedStats = Feature.computeUnitDoombringerGrantedStats(unit, candidate.targetStats)
        local grantedDpsText = grantedStats and grantedStats.dpsText or dpsText
        State.lastShenronDoombringerTarget = {
            id = unit.id,
            name = unit.name,
            mutation = unit.mutation,
            previousTrait = unit.trait,
            rarity = Feature.getWebhookCharacterRarity(unit.name),
            dps = dpsText,
            grantedDps = grantedDpsText,
        }
        State.shenronStatus = "Holding " .. tostring(unit.name) .. " for Doombringer (" .. tostring(grantedDpsText) .. " DPS after trait)."
        Log.push(State.shenronStatus)
        return true
    end

    State.shenronStatus = "Could not hold Doombringer target: " .. tostring(unit.name) .. "."
    Log.push(State.shenronStatus)
    return false
end

function Feature.restoreBestLineupAfterShenronDoombringer()
    if Feature.isWaveStarted() then
        State.shenronStatus = "Doombringer wish claimed; best lineup restore is waiting for the wave to end."
        Log.push(State.shenronStatus)
        return false
    end

    State.autoMergeIdleUntil = math.max(
        tonumber(State.autoMergeIdleUntil) or 0,
        os.clock() + math.max(tonumber(Config.delays.bestLineup) or 6.0, 3.0)
    )
    State.shenronStatus = "Restoring best lineup after Doombringer wish."
    Log.push(State.shenronStatus)

    task.wait(math.max(tonumber(Config.safety.remoteCooldown) or 0.35, 0.35))
    local ok = Feature.placeBestLineup()
    State.autoMergeIdleUntil = math.max(
        tonumber(State.autoMergeIdleUntil) or 0,
        os.clock() + math.max(tonumber(Config.delays.mergeIdle) or 2.5, 1.0)
    )

    if ok then
        State.shenronStatus = "Restored best lineup after Doombringer wish."
    else
        State.shenronStatus = "Doombringer wish claimed; best lineup restore did not place units."
    end
    Log.push(State.shenronStatus)
    return ok
end

function Feature.isShenronMeteorWish(wishName)
    return normalizeText(wishName) == normalizeText("MeteorRain")
end

function Feature.startShenronMeteorCollectionWindow()
    State.shenronMeteorCollectUntil = os.clock() + math.max(tonumber(Config.shenron.meteorCollectWindow) or 45.0, 5.0)
    State.shenronMeteorScanAt = 0
    State.shenronMeteorDrops = {}
end

function Feature.isShenronMeteorCollectionActive()
    local untilTime = tonumber(State.shenronMeteorCollectUntil) or 0
    if untilTime <= 0 then
        return false
    end
    if untilTime <= os.clock() then
        State.shenronMeteorCollectUntil = 0
        State.shenronMeteorDrops = {}
        return false
    end
    return true
end

function Feature.refreshShenronMeteorDropCache()
    local root = Feature.getCharacterRoot()
    local drops = {}
    for _, instance in ipairs(CollectionService:GetTagged("FragmentPickup")) do
        if instance
            and instance.Parent
            and instance:GetAttribute("Collected") ~= true then
            local part = Feature.getTargetPart(instance)
            if part and part:IsDescendantOf(workspace) then
                local distance = root and (root.Position - part.Position).Magnitude or math.huge
                table.insert(drops, {
                    instance = instance,
                    part = part,
                    distance = distance,
                })
            end
        end
    end

    table.sort(drops, function(left, right)
        return (left.distance or math.huge) < (right.distance or math.huge)
    end)
    State.shenronMeteorDrops = drops
    State.shenronMeteorScanAt = os.clock()
    return drops
end

function Feature.getShenronMeteorDrops()
    local now = os.clock()
    local scanInterval = math.max(tonumber(Config.shenron.meteorCollectInterval) or 0.35, 0.1)
    if type(State.shenronMeteorDrops) == "table" and now - (State.shenronMeteorScanAt or 0) < scanInterval then
        return State.shenronMeteorDrops
    end
    return Feature.refreshShenronMeteorDropCache()
end

function Feature.collectShenronMeteorDrop(drop)
    if not drop or not drop.instance or not drop.instance.Parent then
        return false
    end

    Feature.teleportToBuharaObject(drop.instance, Config.shenron.meteorCollectDistance)
    task.wait(0.06)
    local ok = Remote.fire("FragmentRainCollect", drop.instance)
    Feature.touchInstance(drop.instance)
    task.wait(0.08)
    State.shenronMeteorScanAt = 0
    if ok then
        State.shenronStatus = "Collected meteor drop."
    else
        State.shenronStatus = "Meteor collect remote was not available."
    end
    return ok
end

function Feature.collectShenronMeteorDrops()
    if not Feature.isShenronMeteorCollectionActive() then
        return false
    end

    local drops = Feature.getShenronMeteorDrops()
    if #drops == 0 then
        State.shenronStatus = "Waiting for meteor drops."
        return false
    end

    State.shenronStatus = "Collecting meteor drop."
    return Feature.collectShenronMeteorDrop(drops[1])
end

function Feature.turnInShenronDragonBalls()
    if not Feature.isSuperShenronEventActive() then
        State.shenronDragonBalls = {}
        State.shenronDragonBallScanAt = os.clock()
        State.shenronCollectedSinceTurnIn = 0
        State.shenronStatus = "Waiting for Super Shenron event."
        return false
    end

    local wishName = Feature.getBestShenronWish()
    if not wishName then
        State.shenronStatus = "No unlocked non-cash Shenron wish is available."
        Log.push(State.shenronStatus)
        return false
    end

    local now = os.clock()
    if now - (State.lastShenronClaimAt or 0) < math.max(tonumber(Config.shenron.claimCooldown) or 3, 1) then
        return false
    end

    local doombringerWish = Feature.isShenronDoombringerWish(wishName)
    if doombringerWish and not Feature.prepareShenronDoombringerWishTarget() then
        return false
    end

    local target = Feature.getShenronTurnInTarget()
    if not target then
        Feature.setShenronHoldBackoff("Shenron turn-in target is not visible yet.")
        State.shenronStatus = "Waiting for Shenron turn-in target."
        return false
    end

    Feature.clearShenronHoldBackoff()
    for attempt = 1, math.max(tonumber(Config.shenron.turnInRetries) or 1, 1) do
        Feature.teleportToBuharaObject(target, Config.shenron.turnInDistance)
        task.wait(0.06)
        Feature.touchInstance(target)
        task.wait(0.12)
    end

    State.lastShenronClaimAt = os.clock()
    local ok = Remote.fire("SuperShenronClaimWish", wishName)
    if ok then
        State.shenronCollectedSinceTurnIn = 0
        State.lastShenronWishName = wishName
        if Feature.isShenronMeteorWish(wishName) then
            Feature.startShenronMeteorCollectionWindow()
            State.shenronStatus = "Meteor wish claimed; collecting meteor drops."
        else
            State.shenronMeteorCollectUntil = 0
            State.shenronMeteorDrops = {}
            State.shenronStatus = "Shenron wish claimed: " .. tostring(wishName) .. "."
        end
        Log.push(State.shenronStatus)
        if doombringerWish then
            local targetEvent = State.lastShenronDoombringerTarget or {}
            Feature.notifyRareWebhook({
                kind = "Doombringer Granted",
                description = tostring(targetEvent.name or "selected unit") .. " got Doombringer.",
                name = targetEvent.name,
                mutation = targetEvent.mutation,
                trait = "Doombringer",
                previousTrait = targetEvent.previousTrait,
                rarity = targetEvent.rarity,
                id = targetEvent.id,
                grantedDps = targetEvent.grantedDps,
            })
            State.lastShenronDoombringerTarget = nil
            Feature.restoreBestLineupAfterShenronDoombringer()
        end
    else
        State.shenronStatus = "Shenron wish claim remote was not available."
    end
    return ok
end

function Feature.getAutoShenronLoopDelay()
    if Feature.shouldPauseShenronForAutoMerge() then
        return math.max(tonumber(Config.delays.mergeIdle) or 2.5, tonumber(Config.delays.event) or 1)
    end

    local now = os.clock()
    local holdUntil = tonumber(State.shenronHoldUntil) or 0
    if holdUntil > now then
        return math.max(holdUntil - now, tonumber(Config.delays.event) or 1)
    end
    if Feature.isShenronMeteorCollectionActive() then
        return math.max(tonumber(Config.shenron.meteorCollectInterval) or 0.35, 0.1)
    end
    return tonumber(Config.delays.event) or 1
end

function Feature.shouldRunAutoShenron()
    if Feature.isShenronMeteorCollectionActive() then
        return true
    end
    if Feature.isSuperShenronEventActive() then
        return true
    end

    State.shenronDragonBalls = {}
    State.shenronDragonBallScanAt = os.clock()
    State.shenronCollectedSinceTurnIn = 0
    State.shenronStatus = "Waiting for Super Shenron event."
    return false
end

function Feature.autoShenronStep()
    if Feature.useLuckPotionForSuperShenronIfReady() then
        return true
    end

    if not Feature.shouldRunAutoShenron() then
        return false
    end

    if Feature.shouldPauseShenronForAutoMerge() then
        State.shenronStatus = "Paused while auto merge is active."
        return false
    end

    if Feature.detectCarriedShenronDragonBall() then
        return Feature.turnInShenronDragonBalls()
    end

    if Feature.isShenronMeteorCollectionActive() then
        return Feature.collectShenronMeteorDrops()
    end

    local balls = Feature.getShenronDragonBalls()
    if #balls > 0 then
        Feature.clearShenronHoldBackoff()
        return Feature.collectShenronDragonBall(balls[1])
    end

    if (tonumber(State.shenronCollectedSinceTurnIn) or 0) > 0 then
        return Feature.turnInShenronDragonBalls()
    end

    State.shenronStatus = "Waiting for dragon balls."
    return false
end

function Feature.toggleShenron(value)
    Config.flags.autoShenron = value
    if value then
        Feature.clearShenronHoldBackoff()
        Feature.startLoop("autoShenron", Feature.getAutoShenronLoopDelay, Feature.autoShenronStep)
    else
        Feature.stopLoop("autoShenron")
        Feature.clearShenronHoldBackoff()
    end
end

function Feature.getBattlepassRewardModule()
    if Feature.battlepassReward then
        return Feature.battlepassReward
    end
    local folder = ReplicatedStorage:FindFirstChild("Battlepass")
    Feature.battlepassReward = DataSource.safeRequire(folder and folder:FindFirstChild("BattlepassReward"), 1)
    return Feature.battlepassReward
end

function Feature.getBattlepassData()
    local reward = Feature.getBattlepassRewardModule()
    local season = tonumber(reward and reward.Config and reward.Config.Season) or 1
    local data = Feature.dataGet("Battlepass", nil)
    local out = {
        Exp = 0,
        Season = season,
        Premium = { Owned = false, Season = 0 },
        Claimed = { Free = {}, Premium = {} },
    }
    if type(data) ~= "table" or tonumber(data.Season) ~= season then
        return out
    end

    out.Exp = math.max(0, math.floor(tonumber(data.Exp) or 0))
    if type(data.Premium) == "table" then
        out.Premium.Owned = data.Premium.Owned == true
        out.Premium.Season = tonumber(data.Premium.Season) or 0
    end
    if type(data.Claimed) == "table" then
        for _, track in ipairs({ "Free", "Premium" }) do
            local claimedTrack = data.Claimed[track]
            if type(claimedTrack) == "table" then
                for level, claimed in pairs(claimedTrack) do
                    if claimed == true then
                        out.Claimed[track][tostring(level)] = true
                    end
                end
            end
        end
    end
    return out
end

function Feature.getBattlepassLevelInfo(exp)
    local reward = Feature.getBattlepassRewardModule()
    local config = reward and reward.Config or {}
    local maxLevel = tonumber(config.MaxLevel) or Config.battlepass.maxLevel
    local baseExp = tonumber(config.BaseEXP) or 100
    local expIncrease = tonumber(config.EXPIncrease) or 1.1
    local remaining = math.max(0, math.floor(tonumber(exp) or 0))

    for level = 1, maxLevel do
        local required = math.max(1, math.floor(baseExp * expIncrease ^ (level - 1) + 0.5))
        if remaining < required then
            return {
                level = level - 1,
                currentExp = remaining,
                requiredExp = required,
                maxLevel = maxLevel,
            }
        end
        remaining -= required
    end

    return {
        level = maxLevel,
        currentExp = 0,
        requiredExp = 0,
        maxLevel = maxLevel,
    }
end

function Feature.hasBattlepassPremium(data)
    local reward = Feature.getBattlepassRewardModule()
    local season = tonumber(reward and reward.Config and reward.Config.Season) or 1
    return data and data.Premium and data.Premium.Owned == true and tonumber(data.Premium.Season) == season
end

function Feature.getClaimableBattlepassRewards()
    local data = Feature.getBattlepassData()
    local levelInfo = Feature.getBattlepassLevelInfo(data.Exp)
    local claimable = {}
    for level = 1, levelInfo.level do
        if Config.battlepass.claimFree and data.Claimed.Free[tostring(level)] ~= true then
            table.insert(claimable, { level = level, track = "Free" })
        end
        if Config.battlepass.claimPremium and Feature.hasBattlepassPremium(data) and data.Claimed.Premium[tostring(level)] ~= true then
            table.insert(claimable, { level = level, track = "Premium" })
        end
    end
    return claimable, levelInfo, data
end

function Feature.getBattlepassQuestData()
    local data = Remote.invoke("BattlepassQuestData")
    if type(data) == "table" then
        return data
    end
    return { Quests = {} }
end

function Feature.getClaimableBattlepassQuests()
    local data = Feature.getBattlepassQuestData()
    local claimable = {}
    for _, quest in ipairs(data.Quests or {}) do
        if quest.Completed == true and quest.Claimed ~= true and quest.ID then
            table.insert(claimable, quest)
        end
    end
    return claimable, data
end

function Feature.claimBattlepassReward(level, track)
    if Config.battlepass.claimMode == "table" then
        Remote.fire("BattlepassClaim", { level = level, track = track })
    elseif Config.battlepass.claimMode == "levelOnly" then
        Remote.fire("BattlepassClaim", level)
    else
        Remote.fire("BattlepassClaim", level, track)
    end
end

function Feature.claimBattlepassQuest(questId)
    if Config.battlepass.questClaimMode ~= "id" then
        Log.push("Quest claim mode forced to id for safer testing.")
    end
    Remote.fire("BattlepassQuestClaim", questId)
end

function Feature.claimBattlepassOnce()
    local rewards, levelInfo = Feature.getClaimableBattlepassRewards()
    local claimedRewards = 0
    for _, reward in ipairs(rewards) do
        Feature.claimBattlepassReward(reward.level, reward.track)
        claimedRewards += 1
        task.wait(math.max(Config.safety.remoteCooldown, 0.1))
    end

    local claimedQuests = 0
    if Config.battlepass.claimQuests then
        local quests = Feature.getClaimableBattlepassQuests()
        for _, quest in ipairs(quests) do
            Feature.claimBattlepassQuest(quest.ID)
            claimedQuests += 1
            task.wait(math.max(Config.safety.remoteCooldown, 0.1))
        end
    end

    State.battlepassStatus = "Pass L" .. tostring(levelInfo.level) .. "/" .. tostring(levelInfo.maxLevel)
        .. " | claimed rewards: " .. tostring(claimedRewards)
        .. " | claimed quests: " .. tostring(claimedQuests)
    if claimedRewards > 0 or claimedQuests > 0 then
        Log.push(State.battlepassStatus)
    end
end

function Feature.toggleBattlepass(value)
    Config.flags.autoBattlepass = value
    if value then
        Feature.startLoop("autoBattlepass", function()
            return Config.delays.battlepass
        end, Feature.claimBattlepassOnce)
    else
        Feature.stopLoop("autoBattlepass")
    end
end

function Feature.describeBattlepassStatus()
    local rewards, levelInfo, data = Feature.getClaimableBattlepassRewards()
    local quests, questData = {}, { Gold = "?" }
    if Config.battlepass.claimQuests then
        quests, questData = Feature.getClaimableBattlepassQuests()
    end
    State.battlepassStatus = "Pass L" .. tostring(levelInfo.level) .. "/" .. tostring(levelInfo.maxLevel)
        .. " | XP " .. tostring(levelInfo.currentExp) .. "/" .. tostring(levelInfo.requiredExp)
        .. "\nPremium: " .. tostring(Feature.hasBattlepassPremium(data))
        .. "\nClaimable rewards: " .. tostring(#rewards)
        .. "\nCompleted quests: " .. tostring(#quests)
        .. "\nQuest gold: " .. tostring(questData.Gold or "?")
    return State.battlepassStatus
end

function Feature.serializeConfigValue(value)
    if type(value) == "table" then
        local out = {}
        for key, item in pairs(value) do
            out[key] = Feature.serializeConfigValue(item)
        end
        return out
    end
    if typeof(value) == "EnumItem" then
        return tostring(value)
    end
    return value
end

function Feature.getLaunchScriptUrl()
    return LAUNCH_SCRIPT_URL
end

function Feature.getSerializableConfig()
    if Feature.normalizeWebhookConfig then
        Feature.normalizeWebhookConfig()
    end
    local serialized = Feature.serializeConfigValue(Config)
    serialized.export = serialized.export or {}
    serialized.export.scriptUrl = Feature.getLaunchScriptUrl()
    if type(serialized.flags) == "table" then
        serialized.flags.optimizeNativeMenus = nil
    end
    return serialized
end

function Feature.exportLaunchScript()
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(Feature.getSerializableConfig())
    end)
    if not ok then
        Log.push("Export failed: " .. tostring(encoded))
        return nil
    end

    local scriptText = "getgenv().SaltHubPreset = [===[" .. encoded .. "]===]\n"
        .. "local Config = { export = { scriptUrl = \"" .. tostring(Feature.getLaunchScriptUrl()) .. "\" } }\n"
        .. "loadstring(game:HttpGet(Config.export.scriptUrl))()"

    Log.push(scriptText)
    if setclipboard then
        setclipboard(scriptText)
        Log.push("Launch script copied to clipboard.")
    end
    return scriptText
end

function Feature.exportConfig()
    return Feature.exportLaunchScript()
end

function Feature.importConfig(text)
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(text)
    end)
    if ok and type(decoded) == "table" then
        mergeConfig(Config, decoded.Config or decoded)
        applyBestLineupOptimizerDefaults()
        Feature.resetSessionOnlySettings()
        applyNativeMenuOptimizerSafetyDefaults()
        applyAutoRollTimingSafetyDefaults()
        applyEventAutomationSafetyDefaults()
        if UI.scale then
            UI.scale.Scale = Config.ui.scale
        end
        Feature.scheduleConfigSave("import")
        Log.push("Imported config.")
    else
        Log.push("Invalid JSON config.")
    end
end

local function selectableCharacterNames()
    if #State.characterOptions == 0 then
        State.loadSharedInfo()
    end
    return State.characterOptions
end

local function selectableMutations()
    if #State.mutations == 0 then
        State.loadSharedInfo()
    end
    return State.mutations
end

local function selectableSnipeEvents()
    if #State.snipeEvents == 0 then
        State.loadSharedInfo()
    end
    return State.snipeEvents
end

local function selectableTraitOptions()
    if #State.traitOptions == 0 then
        State.loadSharedInfo()
    end
    return State.traitOptions
end

local Tabs = {
    {
        name = "Wave",
        render = function(page)
            local controls = UI.section(page, "Wave Control")
            UI.toggle(controls, "Auto Start Wave", function()
                return Config.flags.autoStartWave
            end, Feature.setAutoStartWave)
            UI.toggle(controls, "Auto Fast Forward", function()
                return Config.flags.autoFastForward
            end, Feature.setAutoFastForward)
            UI.toggle(controls, "Start Highest Wave", function()
                return Config.wave.startHighest ~= false
            end, function(value)
                Config.wave.startHighest = value == true
            end)
            UI.cycle(controls, "Fast Forward", function()
                return { "x1", "x2", "x3" }
            end, function()
                return Config.wave.fastForward
            end, function(value)
                Config.wave.fastForward = value
                Remote.fire("FastForward", value)
            end)
        end,
    },
    {
        name = "Roll",
        render = function(page)
            local main = UI.section(page, "Auto Roll and Buy")
            UI.toggle(main, "Auto Roll", function()
                return Config.flags.autoRoll
            end, Feature.toggleAutoRoll)
            UI.toggle(main, "Auto Buy", function()
                return Config.flags.autoBuy
            end, Feature.toggleAutoBuy)
            UI.toggle(main, "Hold Pity For Event", function()
                return Config.flags.holdPityForEvent
            end, function(value)
                Config.flags.holdPityForEvent = value
                Feature.applyAutoRollSettingsLocal()
            end)
            UI.multiSelectList(page, "Snipe Events", selectableSnipeEvents, function()
                return Config.roll.snipeEvents
            end, function(events)
                Config.roll.snipeEvents = events
                Feature.applyAutoRollSettingsLocal()
            end, 150)

            UI.unitMutationSelector(page, "Target Units", selectableCharacterNames, selectableMutations, function()
                return Config.roll.targetUnits
            end, function()
                return Config.roll.unitMutationTargets
            end, function(units, mutationTargets)
                Config.roll.targetUnits = units
                Config.roll.unitMutationTargets = mutationTargets
                Feature.applyAutoRollSettingsLocal()
            end, 320, {
                enabled = Feature.isWebhookConfiguredForUi,
                isUnitActive = function(unit)
                    return Feature.isWebhookRollUnitNotified(unit)
                end,
                setUnit = function(unit, enabled)
                    Feature.setWebhookRollUnitNotification(unit, enabled)
                end,
                isMutationActive = function(mutation)
                    return Feature.isWebhookRollMutationNotified(mutation)
                end,
                setMutation = function(mutation, enabled)
                    Feature.setWebhookRollMutationNotification(mutation, enabled)
                end,
            })

        end,
    },
    {
        name = "Merge",
        render = function(page)
            local main = UI.section(page, "Auto Merge")
            UI.toggle(main, "Auto Merge Duplicates", function()
                return Config.flags.autoMerge
            end, Feature.toggleAutoMerge)
            UI.toggle(main, "Keep Mutation Targets", function()
                return Config.merge.keepMutations
            end, function(value)
                Config.merge.keepMutations = value
            end)
            UI.textBox(main, "Merge blacklist names, comma separated", table.concat(Config.merge.blacklist, ", "), function(text)
                Config.merge.blacklist = splitCsv(text)
            end)
            UI.button(main, "Merge Selected Target", Feature.mergeSelectedTarget, Theme.accent)
            local placement = UI.section(page, "Best Placement")
            UI.button(placement, "Start Best Lineup", function()
                Feature.setAutoBestLineup(true)
            end, Theme.accent)
            UI.button(placement, "Stop Best Lineup", function()
                Feature.setAutoBestLineup(false)
            end, Theme.danger)
            UI.button(placement, "Place Best Lineup", Feature.placeBestLineup, Theme.accent)
                UI.inventoryUnitSelector(page, "Selected Merge Target", function()
                    return Feature.getMergeSelectableUnits()
                end, function()
                    return Config.merge.targetUnitId
                end, function(unit)
                Config.merge.targetUnitId = unit.id
                Config.merge.targetUnitName = unit.name
            end, 190)
        end,
    },
    {
        name = "Trait",
        render = function(page)
            local main = UI.section(page, "Trait Reroll")
            UI.toggle(main, "Stop When Matched", function()
                return Config.trait.stopWhenMatched
            end, function(value)
                Config.trait.stopWhenMatched = value
            end)
            UI.toggle(main, "Auto Trait Reroll", function()
                return Config.flags.autoTrait
            end, Feature.toggleTrait)
            UI.inventoryUnitSelector(page, "Selected Unit", function()
                State.scanUnits()
                return State.characters
            end, function()
                return Config.trait.selectedUnitId
            end, function(unit)
                Config.trait.selectedUnitId = unit.id
                Config.trait.selectedUnitName = unit.name
            end, 190)
            UI.traitSelector(page, "Stop Traits", selectableTraitOptions, function()
                return Config.trait.targetTraits
            end, function(traits)
                Config.trait.targetTraits = traits
            end, 210)
        end,
    },
    {
        name = "Upgrade",
        render = function(page)
            local main = UI.section(page, "Auto Upgrade")
            UI.toggle(main, "Cash", function()
                return Config.upgrade.selected.Cash
            end, function(value)
                Config.upgrade.selected.Cash = value
            end)
            UI.toggle(main, "Luck", function()
                return Config.upgrade.selected.Luck
            end, function(value)
                Config.upgrade.selected.Luck = value
            end)
            UI.toggle(main, "Grid", function()
                return Config.upgrade.selected.Grid
            end, function(value)
                Config.upgrade.selected.Grid = value
            end)
            UI.toggle(main, "Auto Buy Selected", function()
                return Config.flags.autoUpgrade
            end, Feature.toggleUpgrade)
        end,
    },
    {
        name = "Event",
        render = function(page)
            local buhara = UI.section(page, "Buhara Event")
            UI.toggle(buhara, "Auto Buhara Collect and Feed", function()
                return Config.flags.autoBuhara
            end, Feature.toggleBuhara)

            local shenron = UI.section(page, "Shenron Event")
            UI.toggle(shenron, "Auto Shenron Collect and Wish", function()
                return Config.flags.autoShenron
            end, Feature.toggleShenron)

            local boorus = UI.section(page, "Boorus Event")
            UI.toggle(boorus, "Auto Boorus", function()
                return Config.flags.autoBoorus
            end, Feature.toggleBoorus)

            local spin = UI.section(page, "Spin Wheel")
            UI.toggle(spin, "Auto Spin Wheel", function()
                return Config.flags.autoSpin
            end, Feature.setAutoSpin)

            local misc = UI.section(page, "Rewards")
            UI.toggle(misc, "Auto Battlepass Claim", function()
                return Config.flags.autoBattlepass
            end, Feature.toggleBattlepass)
            UI.toggle(misc, "Auto VIP Rewards", function()
                return Config.flags.autoVipRewards
            end, Feature.toggleVipRewards)
            UI.toggle(misc, "Claim Free Track", function()
                return Config.battlepass.claimFree
            end, function(value)
                Config.battlepass.claimFree = value
            end)
            UI.toggle(misc, "Claim Premium Track", function()
                return Config.battlepass.claimPremium
            end, function(value)
                Config.battlepass.claimPremium = value
            end)
            UI.toggle(misc, "Claim Battlepass Quests", function()
                return Config.battlepass.claimQuests
            end, function(value)
                Config.battlepass.claimQuests = value
            end)
        end,
    },
    {
        name = "Webhook",
        render = function(page)
            local main = UI.section(page, "Discord Webhook")
            UI.toggle(main, "Enable Webhook", function()
                return Config.webhook.enabled == true
            end, function(value)
                Config.webhook.enabled = value == true
                State.webhookStatus = Config.webhook.enabled and "Webhook enabled." or "Webhook disabled."
            end)
            UI.toggle(main, "Mention User", function()
                return Config.webhook.mentionUser == true
            end, function(value)
                Config.webhook.mentionUser = value == true
            end)
            UI.textBox(main, "Webhook URL", Config.webhook.url, function(text)
                Config.webhook.url = tostring(text or "")
                State.webhookStatus = Feature.isWebhookUrlValid(Config.webhook.url) and "Webhook URL set." or "Webhook URL missing or invalid."
            end)
            UI.button(main, "Send Test Webhook", Feature.sendTestWebhook, Theme.accent)
            UI.statusList(main, "Webhook Status", Feature.describeWebhookStatus, 92, 0.75)
        end,
    },
    {
        name = "Settings",
        render = function(page)
            local ui = UI.section(page, "UI Settings")
            UI.cycle(ui, "UI Scale", function()
                return { 0.75, 0.85, 0.9, 1, 1.1 }
            end, function()
                return Config.ui.scale
            end, function(value)
                Config.ui.scale = value
                UI.scale.Scale = value
            end)
            UI.toggle(ui, "Notifications", function()
                return Config.ui.notifications
            end, function(value)
                Config.ui.notifications = value
            end)
            UI.toggle(ui, "Anti-AFK", function()
                return Config.flags.antiAfk
            end, Feature.setAntiAfkEnabled)
            UI.toggle(ui, "Optimize Native Menus", function()
                return Config.flags.optimizeNativeMenus
            end, Feature.setNativeMenuOptimizerEnabled)
            UI.cycle(ui, "Native Preview Mode", function()
                return { "Static", "Hide" }
            end, Feature.getNativePreviewMode, Feature.setNativePreviewMode)
            UI.slider(ui, "Anti-AFK Interval", function()
                return Config.delays.antiAfkCooldown
            end, function(value)
                Config.delays.antiAfkCooldown = value
                Feature.restartAntiAfkLoop()
            end, 30, 300, 15)
            UI.button(ui, "Test Anti-AFK", Feature.testAntiAfk, Theme.accent)
            UI.button(ui, "Unlock All", Feature.unlockAllUnits, Theme.accent2)
            UI.button(ui, "Save Settings Now", Feature.saveConfigToWorkspace, Theme.accent2)
            UI.button(ui, "Copy Launch Script", Feature.exportLaunchScript, Theme.accent)
            UI.textBox(ui, "Paste JSON config then press Enter", "", Feature.importConfig)
            UI.button(ui, "Destroy GUI", function()
                SaltHub.Destroy()
            end, Theme.danger)
        end,
    },
}

function SaltHub.Start()
    Feature.attachAntiAfk()
    Feature.startAntiAfkLoop()
    Feature.attachNativeMenuOpenGuard()
    Feature.restoreNativeMenuOptimizerMutations()
    Feature.startWebhookLoop()
    Feature.attachSpinWheelComplete()
    Feature.attachBoorusSpinComplete()
    if Config.flags.optimizeNativeMenus then
        Feature.attachNativeMenuOptimizer()
    end
    Feature.attachEventUiTracker()
    State.loadSharedInfo()
    State.scanUnits()
    State.scanGuiText()
    UI.build()
    for _, tab in ipairs(Tabs) do
        UI.makeTab(tab)
        tab.render(UI.tabs[tab.name].page)
        UI.tabs[tab.name].page.Parent = UI.content
    end
    Feature.startLoadedAutomationSettings()
    UI.showTab("Wave")
    if workspaceConfigLoaded then
        Log.push("Loaded settings from executor workspace: " .. tostring(workspaceConfigStatus or getExecutorConfigPath()))
    elseif workspaceConfigStatus and workspaceConfigStatus ~= "readfile unavailable" then
        Log.push("Settings auto-load skipped: " .. tostring(workspaceConfigStatus))
    end
    Log.push("Loaded SaltHub. Toggle with LeftAlt.")
end

function SaltHub.Destroy()
    if State.configSaveQueued then
        Feature.saveConfigToWorkspace("destroy", true)
    end
    Feature.restoreNativeMenuOptimizerMutations()
    for key in pairs(Feature.loops) do
        Feature.stopLoop(key)
    end
    Maid:clean()
    if getgenv then
        getgenv().SaltHub = nil
    end
end

SaltHub.Config = Config
SaltHub.Remote = Remote
SaltHub.State = State
SaltHub.UI = UI
SaltHub.Feature = Feature
SaltHub.Tabs = Tabs

if getgenv then
    getgenv().SaltHub = SaltHub
end

SaltHub.Start()

return SaltHub
