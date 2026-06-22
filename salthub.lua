-- SaltHub
-- SaltHub automation hub for "Defend ur base with anime".
-- Single-file, configurable, and built around your game's exposed remotes/modules.

local SaltHub = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
    },
    delays = {
        wave = 1.5,
        roll = 0.12,
        buyScan = 0.12,
        rollSettle = 0.55,
        buyPause = 0.9,
        moveTimeout = 1.35,
        merge = 0.8,
        mergeIdle = 2.5,
        trait = 0.75,
        upgrade = 0.7,
        event = 1.0,
        battlepass = 10.0,
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
        autoBuhara = false,
        autoBattlepass = false,
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
        rollStationBehindDistance = 5.6,
    },
    merge = {
        targetUnitId = "",
        targetUnitName = "",
        keepMutations = true,
        blacklist = {},
    },
    bestLineup = {
        dpsWeight = 1,
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
        densityCandidateLimit = 64,
        frontCandidateLimit = 96,
        fillCandidateLimit = 512,
        replacementPasses = 10,
        minReplacementGain = 0.01,
        frontRangeWeight = 0.72,
        frontDpsWeight = 0.28,
        placementQualityWeight = 250,
        frontValueWeight = 1.25,
        searchVariants = 5,
        maxPlacements = 60,
        skipEquipped = false,
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
        foodNames = { "Steak", "Tomato", "Bread", "Cheese", "Lettuce" },
        feedTargetNames = { "Buhara", "BuharaEvent" },
        foodCollectDistance = 2.2,
        feedDistance = 1.1,
        scanInterval = 0.65,
        maxScanItems = 450,
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

local function mergeConfig(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return
    end

    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
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
    best.beamWidth = math.max(tonumber(best.beamWidth) or 0, 192)
    best.candidateLimit = math.max(tonumber(best.candidateLimit) or 0, 128)
    best.dpsCandidateLimit = math.max(tonumber(best.dpsCandidateLimit) or 0, 96)
    best.densityCandidateLimit = math.max(tonumber(best.densityCandidateLimit) or 0, 64)
    best.frontCandidateLimit = math.max(tonumber(best.frontCandidateLimit) or 0, 96)
    best.fillCandidateLimit = math.max(tonumber(best.fillCandidateLimit) or 0, 512)
    best.replacementPasses = math.max(tonumber(best.replacementPasses) or 0, 10)
    best.frontRangeWeight = math.max(tonumber(best.frontRangeWeight) or 0, 0.72)
    best.frontDpsWeight = math.min(tonumber(best.frontDpsWeight) or 0.28, 0.28)
    best.placementQualityWeight = math.max(tonumber(best.placementQualityWeight) or 0, 250)
    best.frontValueWeight = math.max(tonumber(best.frontValueWeight) or 0, 1.25)
    best.searchVariants = math.max(tonumber(best.searchVariants) or 0, 5)
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

local function ensureExecutorConfigFolder()
    local storage = Config.storage or {}
    local folder = tostring(storage.folder or "SaltHub")
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
    local path = getExecutorConfigPath()
    if type(readfile) ~= "function" then
        return nil, "readfile unavailable"
    end
    if type(isfile) == "function" then
        local ok, exists = pcall(isfile, path)
        if ok and not exists then
            return nil, nil
        end
    end
    local ok, contents = pcall(readfile, path)
    if not ok then
        return nil, contents
    end
    if type(contents) ~= "string" or contents == "" then
        return nil, nil
    end
    return contents, nil
end

local function applySavedConfigFromWorkspace()
    local contents, readErr = readExecutorConfigFile()
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
    workspaceConfigStatus = getExecutorConfigPath()
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
if not presetApplied then
    applySavedConfigFromWorkspace()
end
applyBestLineupOptimizerDefaults()

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
    return RARITY_ORDER[tostring(rarity or "")] or 999
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
        EventUI = { "ReplicatedStorage", "Remotes", "Events", "EventUI" },
        FragmentRainCollect = { "ReplicatedStorage", "Remotes", "FragmentRain", "Collect" },
        BuharaData = { "ReplicatedStorage", "Remotes", "BuharaEvent", "BuharaEventGetData" },
        BuharaDropFood = { "ReplicatedStorage", "Remotes", "BuharaEvent", "DropFood" },
        BuharaMessage = { "ReplicatedStorage", "Remotes", "BuharaEvent", "CreateBuharaMessage" },
        CharacterLock = { "ReplicatedStorage", "Remotes", "Characters", "UpdateCharacterLock" },
        PickupCharacter = { "ReplicatedStorage", "Remotes", "Characters", "PickupCharacter" },
        MoveCharacter = { "ReplicatedStorage", "Remotes", "Characters", "MoveCharacter" },
        SellCharacters = { "ReplicatedStorage", "Remotes", "NPCEvents", "SellCharacters" },
        FreeRewards = { "ReplicatedStorage", "Remotes", "FreeRewards", "FreeRewards" },
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
    battlepassStatus = "Waiting for data.",
    waveStatus = "-",
    lastWaveStartAt = 0,
    lastRollAt = 0,
    rollBusyUntil = 0,
    lastBuyAt = 0,
    buyingCharacter = false,
    pendingBuy = nil,
    lastAntiAfkAt = 0,
    lastPendingBuyLogAt = 0,
    activeEventText = "",
    lastEventUiAt = 0,
    eventUiAttached = false,
    lastPityHoldLogAt = 0,
    lastTraitLogAt = 0,
    dataClient = nil,
    buhara = nil,
    buharaFoodDrops = {},
    buharaFoodScanAt = 0,
    buharaTarget = nil,
    buharaTargetScanAt = 0,
    lastBestLineupSummary = "",
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
                    map[name] = {
                        name = name,
                        displayName = tostring(data.DisplayName or name),
                        rarity = tostring(rarity),
                        data = data,
                    }
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

function DataSource.cleanSnipeEventNames(list)
    local out = {}
    for _, item in ipairs(list or {}) do
        if type(item) == "string" and item ~= "" and not DataSource.blockedSnipeEventNames[normalizeText(item)] then
            table.insert(out, item)
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
                        locked = dataEntryValue(item, { "Locked", "IsLocked" }, false) == true,
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
                        locked = readAttr(child, { "Locked", "IsLocked" }, false) == true,
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
                            trait = traitForCharacter(traitMap, id, readAttr(model, { "Trait", "TraitName", "Passive" }, "None")),
                            locked = readAttr(model, { "Locked", "IsLocked" }, false) == true,
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
    Maid:add(RunService.Heartbeat:Connect(function()
        if button and button.Parent then
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
    Maid:add(RunService.Heartbeat:Connect(function()
        if frame and frame.Parent then
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

    local function refresh()
        for _, child in ipairs(list:GetChildren()) do
            if child ~= layout then
                child:Destroy()
            end
        end

        local selectedId = tostring(selectedIdGetter() or "")
        for index, unit in ipairs(unitsGetter() or {}) do
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
        if list and list.Parent and os.clock() - lastRefresh >= 1.25 then
            lastRefresh = os.clock()
            refresh()
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

function UI.unitMutationSelector(parent, title, unitsGetter, mutationsGetter, selectedUnitsGetter, mutationMapGetter, onChanged, height)
    local frame = UI.section(parent, title)
    local summary = UI.label(frame, "", 24)
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

    local function refresh()
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

        local lastRarity = nil
        for index, unitValue in ipairs(unitsGetter() or {}) do
            local unit = type(unitValue) == "table" and tostring(unitValue.name or unitValue.Name or "") or tostring(unitValue)
            local displayName = type(unitValue) == "table" and tostring(unitValue.displayName or unitValue.DisplayName or unit) or unit
            local rarity = type(unitValue) == "table" and tostring(unitValue.rarity or unitValue.Rarity or State.characterRarity[unit] or "Common") or tostring(State.characterRarity[unit] or "Common")
            local unitColor = rarityColor(rarity)
            local selected = unitMap[unit] == true
            local mutations = mutationTargets[unit] or {}
            local open = expanded[unit] == true

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
                Size = UDim2.new(1, -122, 1, 0),
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
                local button = inst("TextButton", {
                    Name = mutation,
                    LayoutOrder = mutationIndex,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundColor3 = mutationSelected and Theme.accent2 or Theme.panel2,
                    BackgroundTransparency = mutationSelected and 0.12 or 0.18,
                    BorderSizePixel = 0,
                    Font = Enum.Font.Gotham,
                    Text = mutation,
                    TextColor3 = Theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = true,
                }, {
                    corner(5),
                    padding(22),
                })
                button.MouseButton1Click:Connect(function()
                    setMutation(unit, mutation, not mutationSelected)
                    refresh()
                end)
                button.Parent = mutationsFrame
            end
        end
    end

    refresh()
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
}

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

    local folderOk, folderErr = ensureExecutorConfigFolder()
    if not folderOk then
        Log.push("Settings save folder failed: " .. tostring(folderErr))
        return false
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(Feature.getSerializableConfig())
    end)
    if not ok then
        Log.push("Settings save failed: " .. tostring(encoded))
        return false
    end

    local path = getExecutorConfigPath()
    local saveOk, saveErr = pcall(writefile, path, encoded)
    if saveOk then
        State.lastConfigSaveAt = os.clock()
        if not quiet then
            Log.push("Settings saved to executor workspace: " .. tostring(path))
        end
        return true
    end

    Log.push("Settings save failed: " .. tostring(saveErr))
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

function Feature.getTraitShardAmount()
    local client = Feature.getDataClient()
    if not client or not client.get then
        return 0
    end

    local ok, items = pcall(function()
        return client:get("Items")
    end)
    if not ok or type(items) ~= "table" then
        return 0
    end

    for _, item in pairs(items) do
        if type(item) == "table" and normalizeText(item.Name or item.ItemName or item.ID) == "trait shard" then
            return tonumber(item.Quantity or item.Amount or item.Count or item.Value) or 0
        end
    end
    return 0
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
        return
    end

    if Feature.isTraitUnitBusy(unit) then
        Feature.pushTraitStatus("Trait reroll paused: selected unit is busy.")
        return
    end

    if Feature.getTraitShardAmount() <= 0 then
        Feature.pushTraitStatus("Trait reroll paused: no Trait Shards.")
        return
    end

    Feature.requestTraitRoll(unit)
    task.wait(0.15)
    State.scanUnits()
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
    Config.roll.snipeEvents = uniqueSorted(Config.roll.snipeEvents)
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

function Feature.isWaveStarted()
    local plot = Feature.getOwnedPlot()
    return plot and plot:GetAttribute("WaveStarted") == true
end

function Feature.shouldStartWave()
    local plot = Feature.getOwnedPlot()
    if not plot or Feature.isWaveStarted() then
        return false
    end

    local startCooldown = math.max(tonumber(Config.delays.wave) or 0, 2.5)
    return os.clock() - (State.lastWaveStartAt or 0) >= startCooldown
end

local WAVE_CHECKPOINTS = { 0, 25, 50, 75 }

function Feature.getHighestWaveCheckpoint()
    local unlocked = tonumber(LocalPlayer:GetAttribute("Checkpoint"))
        or tonumber(Feature.dataGet("Checkpoint", nil))
        or tonumber(Feature.dataGet("HighestWave", nil))
        or 0
    local target = 0
    for _, checkpoint in ipairs(WAVE_CHECKPOINTS) do
        if unlocked >= checkpoint then
            target = checkpoint
        end
    end
    return target
end

function Feature.ensureHighestWaveCheckpoint()
    local target = Feature.getHighestWaveCheckpoint()
    if target <= 0 then
        return true
    end

    local selected = tonumber(Feature.dataGet({ "Settings", "Checkpoint" }, nil))
    if selected == nil or selected == target then
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

function Feature.autoStartWaveStep()
    if not Feature.shouldStartWave() then
        return
    end

    if Config.wave.startHighest ~= false and not Feature.ensureHighestWaveCheckpoint() then
        return
    end

    State.lastWaveStartAt = os.clock()
    Remote.fire("StartWave")
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

function Feature.returnToRollStation()
    local station = Feature.getRollStationCFrame()
    if not station then
        return false
    end
    return Feature.moveToCFrame(station, Config.delays.moveTimeout)
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

function Feature.rollOnce()
    local prompt = Feature.getRollPrompt()
    if not prompt then
        Log.push("RollPrompt was not found on your plot.")
        return false
    end

    Feature.returnToRollStation()
    task.wait(0.05)
    local ok = Feature.holdPrompt(prompt)
    if ok then
        State.lastRollAt = os.clock()
        State.rollBusyUntil = State.lastRollAt + (tonumber(Config.delays.rollSettle) or 0.55)
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

function Feature.getRolledCharacters()
    local plot = Feature.getOwnedPlot()
    local folder = plot and plot:FindFirstChild("Characters")
    local out = {}
    if not folder then
        State.rolledCharacters = out
        return out
    end

    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") then
            local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
            local prompt = root and root:FindFirstChild("ProximityPrompt") or model:FindFirstChild("ProximityPrompt", true)
            if prompt and prompt:IsA("ProximityPrompt") and normalizeText(prompt.ActionText):find("buy", 1, true) then
                table.insert(out, {
                    name = model.Name,
                    mutation = Feature.getRolledCharacterMutation(model),
                    characterId = tostring(model:GetAttribute("CharacterId") or ""),
                    price = tostring(prompt.ObjectText or ""),
                    model = model,
                    root = root,
                    prompt = prompt,
                })
            end
        end
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

function Feature.getRolledCharacterKey(entry)
    if not entry then
        return ""
    end
    if entry.characterId and entry.characterId ~= "" then
        return "id:" .. tostring(entry.characterId)
    end
    return normalizeText(tostring(entry.name) .. "|" .. tostring(entry.mutation))
end

function Feature.findPendingBuyCandidate()
    local pending = State.pendingBuy
    if not pending or not pending.key then
        return nil
    end

    for _, entry in ipairs(Feature.getRolledCharacters()) do
        if Feature.getRolledCharacterKey(entry) == pending.key and Feature.matchesRollTarget(entry) then
            return entry
        end
    end

    Feature.clearPendingBuy()
    return nil
end

function Feature.setPendingBuy(entry)
    if not entry then
        return
    end

    local price = Feature.getRolledCharacterPrice(entry)
    State.pendingBuy = {
        key = Feature.getRolledCharacterKey(entry),
        name = entry.name,
        mutation = entry.mutation,
        price = price,
    }
    State.rollBusyUntil = math.max(State.rollBusyUntil or 0, os.clock() + (tonumber(Config.delays.rollSettle) or 0.55))

    if os.clock() - (State.lastPendingBuyLogAt or 0) > 3 then
        State.lastPendingBuyLogAt = os.clock()
        Log.push("Waiting for cash to buy " .. tostring(entry.name) .. " (" .. tostring(entry.price or "?") .. ").")
    end
end

function Feature.clearPendingBuy()
    State.pendingBuy = nil
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

function Feature.buyRolledCharacter(entry)
    if not entry or not entry.prompt then
        Log.push("No matching podium character to buy.")
        return false
    end
    if State.buyingCharacter then
        return false
    end

    State.buyingCharacter = true
    State.rollBusyUntil = os.clock() + (tonumber(Config.delays.buyPause) or 0.9)
    local bought = false
    local ok, err = pcall(function()
        Feature.moveNearInstance(entry.prompt, 3.15)
        task.wait(0.05)
        bought = Feature.holdPrompt(entry.prompt)
        if bought then
            State.lastBuyAt = os.clock()
            Log.push("Held E to buy " .. tostring(entry.name) .. ".")
        end
        task.wait(0.08)
        Feature.returnToRollStation()
    end)
    if not ok then
        Log.push("Buy failed: " .. tostring(err))
    end
    State.rollBusyUntil = os.clock() + (tonumber(Config.delays.buyPause) or 0.9)
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
    return clean:find("event", 1, true) ~= nil and textMatchesAny(clean, Config.roll.snipeEvents)
end

function Feature.getSelectedSnipeEvents()
    return DataSource.cleanSnipeEventNames(Config.roll.snipeEvents)
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
        return
    end

    State.activeEventText = text
    State.lastEventUiAt = os.clock()
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

function Feature.scanSelectedEventText()
    local selectedEvents = Feature.getSelectedSnipeEvents()
    local roots = {
        PlayerGui:FindFirstChild("MainUI"),
        PlayerGui:FindFirstChild("EventUI"),
        workspace:FindFirstChild("EventAttachments"),
    }
    for _, root in ipairs(roots) do
        if root then
            if textMatchesAny(root.Name, selectedEvents) then
                return root.Name
            end
            for _, descendant in ipairs(root:GetDescendants()) do
                if Feature.isVisibleSelectedEventBadge(descendant, selectedEvents) then
                    return descendant.Name
                end
                local text = descendant.Name
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                    text = tostring(descendant.Text) .. " " .. tostring(descendant.Name)
                end
                if textMatchesAny(text, selectedEvents) and Feature.isEventStatusText(text) then
                    return text
                end
            end
        end
    end
    return ""
end

function Feature.textRootHasSelectedEvent(root)
    if not root then
        return false
    end

    local selectedEvents = Feature.getSelectedSnipeEvents()
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

function Feature.shouldHoldPityForEvent()
    if not Config.flags.holdPityForEvent then
        return false
    end
    if not Feature.isPityAtOneRoll() then
        return false
    end
    return not Feature.isSelectedSnipeEventActive()
end

function Feature.autoRollStep()
    if State.buyingCharacter then
        return
    end

    if State.pendingBuy then
        Feature.autoBuyStep()
        return
    end

    if Feature.shouldHoldPityForEvent() then
        if os.clock() - (State.lastPityHoldLogAt or 0) > 3 then
            State.lastPityHoldLogAt = os.clock()
            Log.push("Holding Mythic/Secret in 1 roll for selected event.")
        end
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
        if index > 3 then
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
        Feature.returnToRollStation()
        Feature.startLoop("autoRoll", function()
            return Config.delays.roll
        end, Feature.autoRollStep)
    else
        Feature.stopLoop("autoRoll")
    end
end

function Feature.shouldRollAgain()
    if State.buyingCharacter then
        return false
    end
    if os.clock() < (State.rollBusyUntil or 0) then
        return false
    end
    return os.clock() - (State.lastRollAt or 0) >= (tonumber(Config.delays.rollSettle) or 0.55)
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

    local match = Feature.findMatchingRolledCharacter()
    if match then
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

function Feature.getCharacterStaticInfo(unitName)
    if not State.characterInfoByName or not next(State.characterInfoByName) then
        State.loadSharedInfo()
    end
    return State.characterInfoByName[tostring(unitName or "")]
end

function Feature.getMutationInfo(mutationName)
    local name = tostring(mutationName or "")
    if name == "" or normalizeText(name) == "none" then
        return nil
    end
    if not State.mutationInfoByName or not next(State.mutationInfoByName) then
        State.loadSharedInfo()
    end
    return State.mutationInfoByName[name]
end

function Feature.getTraitInfo(traitName)
    local name = tostring(traitName or "")
    if name == "" or normalizeText(name) == "none" then
        return nil
    end
    if not State.traitInfoByName or not next(State.traitInfoByName) then
        State.loadSharedInfo()
    end
    return State.traitInfoByName[name]
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

function Feature.scoreLineupUnit(unit)
    local derived = Feature.computeUnitDerivedStats(unit)
    if not derived then
        return nil
    end

    local rarityBonus = math.max(0, 10 - rarityRank(derived.rarity)) * (tonumber(Config.bestLineup.rarityWeight) or 0)
    local rngBonus = derived.rng > 0 and (1 / math.max(derived.rng, 0.001)) * (tonumber(Config.bestLineup.rngWeight) or 0) or 0
    local areaBonus = (derived.splashRadius * 0.18) + (derived.lineWidth * 0.12)
    local cadenceBonus = derived.cooldown > 0 and (1 / math.max(derived.cooldown, 0.05)) * (tonumber(Config.bestLineup.cooldownWeight) or 0) or 0
    local score = derived.dps * (tonumber(Config.bestLineup.dpsWeight) or 1)
        + derived.damage * 0.03
        + derived.range * (tonumber(Config.bestLineup.rangeWeight) or 0)
        + cadenceBonus
        + rarityBonus
        + (tonumber(derived.level) or 1) * (tonumber(Config.bestLineup.levelWeight) or 0)
        + rngBonus
        + areaBonus

    return score, derived
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
        end
    end

    if plot then
        for _, descendant in ipairs(plot:GetDescendants()) do
            local name = normalizeText(descendant.Name)
            if name:find("enemybase", 1, true) or name:find("enemy base", 1, true)
                or name:find("spawn", 1, true) or name:find("gate", 1, true) then
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

    local maxZ = -math.huge
    local sumX = 0
    local count = 0
    local cellSize = 4
    for _, cell in ipairs(cells or {}) do
        if cell:IsA("BasePart") then
            maxZ = math.max(maxZ, cell.Position.Z)
            sumX += cell.Position.X
            count += 1
            cellSize = math.max(cellSize, cell.Size.Z)
        end
    end
    if count == 0 then
        return nil
    end

    return Vector3.new(sumX / count, 0, maxZ + cellSize * 6)
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

function Feature.getLineupPlacementValue(candidate)
    local scoreValue = (tonumber(candidate and candidate.score) or 0) * (tonumber(Config.bestLineup.frontValueWeight) or 1.25)
    local dpsValue = (tonumber(candidate and candidate.derived and candidate.derived.dps) or 0)
    return math.max(scoreValue, dpsValue)
end

function Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics)
    local frontScore = Feature.getLineupPlacementFrontScore(placement, gridMap, metrics)
    local flatValue = tonumber(Config.bestLineup.placementQualityWeight) or 0
    return frontScore * (tonumber(candidate and candidate.frontPriority) or 0) * (flatValue + Feature.getLineupPlacementValue(candidate))
end

function Feature.sortBestLineupPlacementOptions(candidate, options, gridMap, metrics)
    table.sort(options, function(a, b)
        local scoreA = Feature.getLineupPlacementScore(candidate, a, gridMap, metrics)
        local scoreB = Feature.getLineupPlacementScore(candidate, b, gridMap, metrics)
        if scoreA ~= scoreB then
            return Feature.getLineupPlacementScore(candidate, a, gridMap, metrics) > Feature.getLineupPlacementScore(candidate, b, gridMap, metrics)
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
        return Feature.sortBestLineupPlacementOptions(candidate, options, gridMap, metrics)
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
    return Feature.sortBestLineupPlacementOptions(candidate, options, gridMap, metrics)
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
        if not unit.crafting and not unit.cloning and not unit.locked and (includeEquipped or not unit.equipped) then
            local score, derived = Feature.scoreLineupUnit(unit)
            local footprint = Feature.getShapeFootprint(unit.name)
            if score and footprint then
                local spots = math.max(footprint.spots or 1, 1)
                local penalty = math.max(0, 1 - math.min(0.45, (spots - 1) * (tonumber(Config.bestLineup.footprintPenalty) or 0)))
                table.insert(allCandidates, {
                    unit = unit,
                    derived = derived,
                    footprint = footprint,
                    score = score * penalty,
                    scorePerSpot = score * penalty / spots,
                })
            end
        end
    end
    Feature.assignLineupFrontPriorities(allCandidates)

    local byDps = copyArray(allCandidates)
    table.sort(byDps, function(a, b)
        if a.derived.dps ~= b.derived.dps then
            return a.derived.dps > b.derived.dps
        end
        if a.score ~= b.score then
            return a.score > b.score
        end
        return tostring(a.unit.id) < tostring(b.unit.id)
    end)

    local byDensity = copyArray(allCandidates)
    table.sort(byDensity, function(a, b)
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
    addFrom(byFrontNeed, math.max(1, tonumber(Config.bestLineup.frontCandidateLimit) or limit))
    addFrom(byDensity, math.max(1, tonumber(Config.bestLineup.densityCandidateLimit) or limit))
    if #candidates < limit then
        addFrom(byDps, limit)
    end

    table.sort(candidates, function(a, b)
        if a.derived.dps ~= b.derived.dps then
            return a.derived.dps > b.derived.dps
        end
        if a.scorePerSpot ~= b.scorePerSpot then
            return a.scorePerSpot > b.scorePerSpot
        end
        if a.score ~= b.score then
            return a.score > b.score
        end
        return tostring(a.unit.id) < tostring(b.unit.id)
    end)
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

function Feature.makeLineupPlanItem(candidate, placement)
    return {
        unit = candidate.unit,
        derived = candidate.derived,
        score = candidate.score,
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

function Feature.scoreBestLineupPlan(plan)
    local total = 0
    local fillWeight = tonumber(Config.bestLineup.fillWeight) or 0
    for _, item in ipairs(plan or {}) do
        local cells = item and item.placement and item.placement.occupiedCells or {}
        total += (tonumber(item and item.score) or 0) + #cells * fillWeight + (tonumber(item and item.placementScore) or 0)
    end
    return total
end

function Feature.sortLineupCandidatesByScore(candidates)
    local ordered = copyArray(candidates or {})
    table.sort(ordered, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.scorePerSpot ~= b.scorePerSpot then
            return a.scorePerSpot > b.scorePerSpot
        end
        if a.derived.dps ~= b.derived.dps then
            return a.derived.dps > b.derived.dps
        end
        return tostring(a.unit.id) < tostring(b.unit.id)
    end)
    return ordered
end

function Feature.sortLineupCandidatesByFrontNeed(candidates)
    local ordered = copyArray(candidates or {})
    table.sort(ordered, function(a, b)
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
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)
    return ordered
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
            if placement then
                local item = Feature.makeLineupPlanItem(candidate, placement)
                item.placementScore = Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics)
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
    local fillWeight = tonumber(Config.bestLineup.fillWeight) or 0
    for _, item in ipairs(items or {}) do
        local cells = item and item.placement and item.placement.occupiedCells or {}
        total += (tonumber(item and item.score) or 0) + #cells * fillWeight + (tonumber(item and item.placementScore) or 0)
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
                        local candidateValue = (tonumber(candidate.score) or 0) + #(placement.occupiedCells or {}) * (tonumber(Config.bestLineup.fillWeight) or 0) + Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics)
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
        local item = Feature.makeLineupPlanItem(bestReplacement.candidate, bestReplacement.placement)
        item.placementScore = Feature.getLineupPlacementScore(bestReplacement.candidate, bestReplacement.placement, gridMap, metrics)
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
                    local placementScore = Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics)
                    table.insert(plan, {
                        unit = candidate.unit,
                        derived = candidate.derived,
                        score = candidate.score,
                        placementScore = placementScore,
                        placement = placement,
                    })
                    local cellsAdded = #placement.occupiedCells
                    table.insert(nextStates, {
                        score = state.score + candidate.score + cellsAdded * (tonumber(Config.bestLineup.fillWeight) or 0) + Feature.getLineupPlacementScore(candidate, placement, gridMap, metrics),
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
    return Feature.improveBestLineupPlan(plan, fillCandidates or candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics)
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

    addVariant(candidates)
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
        return tostring(a and a.unit and a.unit.id or "") < tostring(b and b.unit and b.unit.id or "")
    end)
    addVariant(byRange)

    local byDensity = copyArray(candidates or {})
    table.sort(byDensity, function(a, b)
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

function Feature.selectBestLineupPlan(plans, baseOccupancy)
    local bestPlan = {}
    local bestScore = -math.huge
    local bestCells = -math.huge
    for _, plan in ipairs(plans or {}) do
        local score = Feature.scoreBestLineupPlan(plan)
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
    return Feature.selectBestLineupPlan(plans, baseOccupancy)
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
    return Feature.buildBestLineupMultiVariantPlan(candidates, cells, gridMap, Feature.refreshPlacementOccupancy(gridMap), fillCandidates, metrics)
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
    return Feature.buildBestLineupMultiVariantPlan(candidates, cells, gridMap, {}, fillCandidates, metrics)
end

function Feature.placeBestLineup()
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

function Feature.shouldKeepMergeUnit(unit)
    if not unit then
        return true
    end
    if unit.locked then
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
    if tostring(unit.level or "") == "?" then
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
        refreshed.locked = readAttr(model, { "Locked", "IsLocked" }, refreshed.locked) == true
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
        local placedCell = Feature.getPlacedModelCell(model)
        if placedCell then
            return placedCell
        end
        local root = Feature.getUnitRoot(model)
        local cell = root and Feature.findNearestGridCellToPosition(root.Position)
        if cell then
            return cell
        end
    end
    return nil
end

function Feature.getPlacedModelCell(model)
    if not model then
        return nil
    end
    local cellsText = model:GetAttribute("Cells") or model:GetAttribute("GridCells")
    if type(cellsText) ~= "string" or cellsText == "" then
        return nil
    end

    local grid = Feature.getCurrentGridModel()
    local _, gridMap = Feature.buildGridCells(grid)
    for cellName in cellsText:gmatch("[^,]+") do
        local clean = tostring(cellName):gsub("^%s+", ""):gsub("%s+$", "")
        local cell = gridMap[clean]
        if cell then
            return cell
        end
    end
    return nil
end

function Feature.waitForMergeCell(unit, fallbackCell)
    local model = Feature.waitForPlacedUnitModel(unit, 2.5)
    local placedCell = Feature.getPlacedModelCell(model)
    if placedCell then
        return placedCell
    end
    local root = Feature.getUnitRoot(model)
    local cell = root and Feature.findNearestGridCellToPosition(root.Position)
    return cell or fallbackCell
end

function Feature.getMergeCandidates(selected)
    local selectedKey = selected and Feature.mergeKey(selected) or ""
    local candidates = {}

    for _, unit in ipairs(State.characters) do
        local key = Feature.mergeKey(unit)
        if selectedKey ~= "" and key ~= selectedKey then
            continue
        end
        if unit and not unit.locked and not textMatchesAny(unit.name, Config.merge.blacklist) then
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
            and not unit.locked
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
            and not unit.locked
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
            return false
        end
        if response.Success == true then
            return true
        end
    end

    Log.push("Merge place timed out waiting for " .. tostring(unit.name) .. ".")
    return false
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
    return Feature.refreshMergeTarget(unit)
end

function Feature.mergeUnitsOnCell(anchor, fodder, cell)
    if not anchor or not fodder or not cell then
        return nil
    end

    local anchorLevel = Feature.unitMergeLevel(anchor)
    Feature.pickupUnitForMerge(anchor)
    Feature.pickupUnitForMerge(fodder)
    if not Feature.placeUnitForMerge(anchor, cell) then
        Log.push("Merge stopped: could not place anchor " .. tostring(anchor.name) .. ".")
        return nil
    end

    local mergeCell = Feature.waitForMergeCell(anchor, cell)
    task.wait(math.max(Config.safety.remoteCooldown, 0.12))
    if not Feature.placeUnitForMerge(fodder, mergeCell) then
        Log.push("Merge stopped: could not place fodder " .. tostring(fodder.name) .. ".")
        return nil
    end

    task.wait(math.max(Config.delays.merge, Config.safety.remoteCooldown, 0.25))
    return Feature.waitForUnitLevel(anchor, anchorLevel + 1, 3)
end

function Feature.mergeFodderIntoPlacedAnchor(anchor, fodder, cell)
    if not anchor or not fodder or not cell then
        return nil
    end

    local anchorLevel = Feature.unitMergeLevel(anchor)
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
        return nil
    end

    task.wait(math.max(Config.delays.merge, Config.safety.remoteCooldown, 0.25))
    return Feature.waitForUnitLevel(anchor, anchorLevel + 1, 3)
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
    if tostring(target.level or "") == "?" then
        Log.push("Selected merge target needs a known level.")
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
            return false
        end
        targetCell = Feature.waitForMergeCell(target, targetCell)
        Log.push("Target merge anchor placed first: " .. tostring(target.name) .. " | " .. originalTrait .. ".")
    end

    local seedLevel = Feature.unitMergeLevel(target)
    local merged = 0
    for depth = 1, 12 do
        target = Feature.refreshMergeTarget(target)
        local targetLevel = Feature.unitMergeLevel(target)
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

function Feature.autoMergeStep()
    local now = os.clock()
    if now < (State.autoMergeIdleUntil or 0) then
        return false
    end

    local pending = State.pendingMerge
    if type(pending) ~= "table" or pending.mode ~= "auto" then
        pending = Feature.resetAutoMergePending()
    end

    if tostring(pending.characterName or "") == "" then
        local family = Feature.findNextAutoMergeFamily(nil, nil, State.autoMergeIgnoredCharacters)
        if not family then
            State.autoMergeIgnoredCharacters = {}
            State.autoMergeIdleUntil = now + (tonumber(Config.delays.mergeIdle) or 2.5)
            return false
        end
        pending.characterName = family.characterName
        pending.displayName = family.displayName
        pending.familyKey = family.familyKey
        pending.ignoredFamilies = {}
        pending.ignoredKeys = {}
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
        Log.push("Auto merge moving to " .. tostring(family.displayName) .. " mutation " .. tostring(family.mutationKey) .. ".")
    end

    local plan = Feature.getDuplicateMergePlanForFamily(pending.familyKey, pending.ignoredKeys)
    if not plan then
        pending.ignoredFamilies[pending.familyKey] = true
        pending.familyKey = ""
        pending.ignoredKeys = {}
        return false
    end

    if Feature.executeTargetMergeCascade(plan.target) then
        return true
    end

    pending.ignoredKeys[plan.key] = true
    return false
end

function Feature.mergeSelectedTarget()
    local selected = Feature.getSelectedMergeUnit()
    if not selected then
        Log.push("Select a merge target first.")
        return false
    end
    return Feature.executeTargetMergeCascade(selected)
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

function Feature.getBuharaData()
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
            table.insert(slots, {
                name = itemName.Text,
                quantity = quantity.Text,
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
            if tostring(slot.quantity or ""):match("^%s*0%s*/") then
                table.insert(wanted, slot.name)
            end
        end
    end

    return uniqueSorted(wanted)
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

function Feature.getBuharaScanRoots()
    local roots = {}
    local seen = {}
    local function add(instance)
        if instance and not seen[instance] then
            seen[instance] = true
            table.insert(roots, instance)
        end
    end

    for _, name in ipairs({ "Debris", "EventAttachments", "Map", "Food", "Foods", "Drops", "BuharaEvent" }) do
        add(workspace:FindFirstChild(name))
    end
    for _, child in ipairs(workspace:GetChildren()) do
        if textMatchesAny(child.Name, { "Food", "Ingredient", "Sandwich", "Buhara" }) then
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
        for _, instance in ipairs(scanRoot:GetDescendants()) do
            scanned += 1
            if scanned > (tonumber(Config.buhara.maxScanItems) or 450) then
                break
            end

            if instance:IsA("ProximityPrompt") or instance:IsA("BasePart") or instance:IsA("Model") or instance:IsA("Tool") then
                local foodName = Feature.getBuharaFoodName(instance)
                if foodName and wanted[foodName] then
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

function Feature.isCarryingBuharaFood()
    local character = LocalPlayer.Character
    return character and character:GetAttribute("CarryingFood") == true
end

function Feature.collectBuharaFood(drop)
    if not drop or not drop.instance then
        return false
    end

    Feature.teleportToInstance(drop.instance)
    task.wait(0.05)
    if drop.prompt then
        Feature.holdPrompt(drop.prompt)
    else
        local part = Feature.getTargetPart(drop.instance)
        if part then
            Feature.teleportToCFrame(CFrame.lookAt(part.Position, part.Position + Vector3.new(0, 0, -1)))
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
        return Feature.teleportToInstance(prompt)
    end

    local legCenter = Feature.getBuharaLegCenter(target)
    local root = Feature.getCharacterRoot()
    if not legCenter or not root then
        return false
    end
    return Feature.teleportToCFrame(CFrame.lookAt(legCenter, root.Position))
end

function Feature.feedBuhara()
    if not Feature.isCarryingBuharaFood() then
        return false
    end

    local target = Feature.findBuharaTarget()
    if not target then
        Log.push("Buhara target is not visible yet; holding food.")
        return false
    end

    local prompt = Feature.getBuharaFeedPrompt(target)
    if not prompt then
        Feature.moveToBuharaFeedPrompt(target, nil)
        Log.push("Buhara feed prompt was not found yet; holding food.")
        return false
    end

    Feature.moveToBuharaFeedPrompt(target, prompt)
    task.wait(0.05)
    Feature.holdPrompt(prompt)
    task.wait(0.2)
    return not Feature.isCarryingBuharaFood()
end

function Feature.autoBuharaStep()
    if Feature.isCarryingBuharaFood() then
        return Feature.feedBuhara()
    end

    local data = Feature.getBuharaData()
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
        Feature.startLoop("autoBuhara", function()
            return Config.delays.event
        end, Feature.autoBuharaStep)
    else
        Feature.stopLoop("autoBuhara")
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
    local serialized = Feature.serializeConfigValue(Config)
    serialized.export = serialized.export or {}
    serialized.export.scriptUrl = Feature.getLaunchScriptUrl()
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
            end, function(value)
                Config.flags.autoStartWave = value
                if value then
                    Feature.startLoop("autoStartWave", function()
                        return Config.delays.wave
                    end, Feature.autoStartWaveStep)
                else
                    Feature.stopLoop("autoStartWave")
                end
            end)
            UI.toggle(controls, "Auto Fast Forward", function()
                return Config.flags.autoFastForward
            end, function(value)
                Config.flags.autoFastForward = value
                if value then
                    Feature.startLoop("autoFastForward", function()
                        return Config.delays.wave
                    end, function()
                        Remote.fire("FastForward", Config.wave.fastForward)
                    end)
                else
                    Feature.stopLoop("autoFastForward")
                end
            end)
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
            end, 320)

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

            local spin = UI.section(page, "Spin Wheel")
            UI.toggle(spin, "Auto Spin Wheel", function()
                return Config.flags.autoSpin
            end, function(value)
                Config.flags.autoSpin = value
                if value then
                    Feature.startLoop("autoSpin", function()
                        return Config.delays.event
                    end, function()
                        Remote.fire("SpinWheel")
                    end)
                else
                    Feature.stopLoop("autoSpin")
                end
            end)

            local misc = UI.section(page, "Rewards")
            UI.toggle(misc, "Auto Battlepass Claim", function()
                return Config.flags.autoBattlepass
            end, Feature.toggleBattlepass)
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
            UI.slider(ui, "Anti-AFK Interval", function()
                return Config.delays.antiAfkCooldown
            end, function(value)
                Config.delays.antiAfkCooldown = value
                Feature.restartAntiAfkLoop()
            end, 30, 300, 15)
            UI.button(ui, "Test Anti-AFK", Feature.testAntiAfk, Theme.accent)
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
