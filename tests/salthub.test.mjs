import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const sourcePath = new URL("../salthub.lua", import.meta.url);

test("SaltHub script exposes the expected core sections", () => {
  assert.equal(fs.existsSync(sourcePath), true, "salthub.lua should exist");
  const source = fs.readFileSync(sourcePath, "utf8");

  for (const marker of [
    "local Config =",
    "local Remote =",
    "local State =",
    "local UI =",
    "local Feature",
    "Feature =",
    "local Tabs =",
    "SaltHub",
    "CONFIG_EXPORT_BEGIN",
  ]) {
    assert.match(source, new RegExp(marker.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
  }
  assert.match(source, /keybind = Enum\.KeyCode\.LeftAlt/);
  assert.match(source, /Toggle with LeftAlt/);
});

test("SaltHub includes all approved feature tabs", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  for (const tabName of [
    "Wave",
    "Roll",
    "Merge",
    "Trait",
    "Upgrade",
    "Event",
    "Settings",
  ]) {
    assert.match(source, new RegExp(`name = "${tabName}"`));
  }
  assert.doesNotMatch(source, /name = "Units"/);
});

test("SaltHub uses safe remote helpers instead of raw scattered calls", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Remote\.fire/);
  assert.match(source, /function Remote\.invoke/);
  assert.match(source, /local args = \{ \.\.\. \}/);
  assert.match(source, /remote:FireServer\(tableUnpack\(args\)\)/);
  assert.match(source, /remote:InvokeServer\(tableUnpack\(args\)\)/);
});

test("SaltHub pulls selectable game data dynamically", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /local DataSource =/);
  assert.match(source, /function DataSource\.safeRequire/);
  assert.match(source, /function DataSource\.extractKeys/);
  assert.match(source, /function DataSource\.isRarityName/);
  assert.match(source, /function DataSource\.buildCharacterOptions/);
  assert.match(source, /function DataSource\.buildTraitOptions/);
  assert.match(source, /function DataSource\.extractEventNames/);
  assert.match(source, /pcall\(debug\.getupvalue, loaded, index\)/);
  assert.match(source, /CharactersInfo/);
  assert.match(source, /TraitInfo/);
  assert.match(source, /MutationInfo/);
  assert.match(source, /mutationEventName/);
  assert.match(source, /State\.characterOptions/);
  assert.match(source, /State\.traitOptions/);
  assert.match(source, /State\.traitRarity/);
  assert.match(source, /State\.snipeEvents/);
  assert.match(source, /not DataSource\.isRarityName\(name\)/);
  assert.match(source, /DataSource\.extractEventNames\("mutationEventName", \{/);
  assert.doesNotMatch(source, /DataSource\.extractEventNames\("mutationEventName", mutationNames\)/);
  assert.doesNotMatch(source, /State\.traits = uniqueSorted\(\{\s+"Far Sight I"/);
  assert.doesNotMatch(source, /State\.mutations = uniqueSorted\(\{\s+"None"/);
});

test("ui uses glass styling and keeps expanded unit rows visible", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /local Lighting = game:GetService\("Lighting"\)/);
  assert.match(source, /BlurEffect/);
  assert.match(source, /BackgroundTransparency = 0\.18/);
  assert.match(source, /function UI\.setGlassEnabled/);
  assert.match(source, /UI\.setGlassEnabled\(gui\.Enabled\)/);
  assert.match(source, /Name = "UnitContainerLayout"/);
  assert.match(source, /local unitColor = rarityColor\(rarity\)/);
  assert.match(source, /RarityBadge/);
  assert.match(source, /Name = "RarityHeader"/);
  assert.match(source, /Rotation = open and 180 or 0/);
});

test("target unit list filters rarity bucket names and has clear dropdown controls", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function DataSource\.isRarityName/);
  assert.match(source, /not DataSource\.isRarityName\(name\)/);
  assert.match(source, /local lastRarity = nil/);
  assert.match(source, /Name = "RarityHeader"/);
  assert.match(source, /Name = "Caret"/);
  assert.match(source, /BackgroundColor3 = Theme\.glassPanel/);
  assert.match(source, /stroke\(Theme\.line, 1\)/);
  assert.doesNotMatch(source, /\(selected and "\[x\] " or "\[ \] "\) \.\. displayName/);
  assert.doesNotMatch(source, /\(mutationSelected and "\[x\] " or "\[ \] "\) \.\. mutation/);
});

test("snipe events use real event enums and clean labels", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /DataSource\.extractEventNames\("mutationEventName", \{/);
  assert.match(source, /DataSource\.blockedSnipeEventNames/);
  assert.match(source, /function DataSource\.cleanSnipeEventNames/);
  assert.match(source, /not DataSource\.blockedSnipeEventNames\[normalizeText\(item\)\]/);
  assert.match(source, /"Dragonborn"/);
  assert.match(source, /\[normalizeText\("Buhara"\)\] = true/);
  assert.match(source, /snipeEvents = mutationEventNames/);
  assert.doesNotMatch(source, /DataSource\.extractEventNames\("specialEventName"/);
  assert.doesNotMatch(source, /local specialEventNames/);
  assert.doesNotMatch(source, /DataSource\.combineLists\(mutationEventNames, specialEventNames\)/);
  assert.doesNotMatch(source, /"Drop",\s*\n\s*"Luck",\s*\n\s*"Cash",\s*\n\s*"Speed",\s*\n\s*"Roll"/);
  assert.doesNotMatch(source, /DataSource\.extractEventNames\("mutationEventName", mutationNames\)/);
  assert.doesNotMatch(source, /\(active and "\[x\] " or "\[ \] "\) \.\. text/);
});

test("nen sniping ignores buhara setup event", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.getSelectedSnipeEvents/);
  assert.match(source, /DataSource\.cleanSnipeEventNames\(Config\.roll\.snipeEvents\)/);
  assert.match(source, /function Feature\.isSelectedEventPayloadText/);
  assert.match(source, /function Feature\.isActiveEventTextForSelection/);
  assert.match(source, /clean:find\("next event", 1, true\)/);
  assert.match(source, /Feature\.isSelectedEventPayloadText\(text, selectedEvents\)/);
  assert.match(source, /return Feature\.isEventStatusText\(text\) and textMatchesAny\(text, selectedEvents\)/);
  assert.match(source, /function Feature\.isVisibleSelectedEventBadge/);
  assert.match(source, /Feature\.isVisibleSelectedEventBadge\(descendant, selectedEvents\)/);
  assert.match(source, /local selectedEvents = Feature\.getSelectedSnipeEvents\(\)/);
  assert.match(source, /if not listHasItems\(selectedEvents\) then/);
  assert.match(source, /textMatchesAny\(State\.activeEventText, selectedEvents\)/);
  assert.match(source, /Feature\.isActiveEventTextForSelection\(State\.activeEventText\)/);
  assert.match(source, /textMatchesAny\(State\.waveStatus, selectedEvents\)/);
  assert.doesNotMatch(source, /"Buhara",\s*\n\s*"Titan"/);
});

test("snipe hold waits only on secret pity and throttles expensive event scans", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /eventScanInterval = 4\.0/);
  assert.match(source, /function Feature\.isSecretPityAtOneRoll/);
  assert.match(source, /function Feature\.getCachedSelectedSnipeEventActive/);
  assert.match(source, /State\.lastSelectedEventScanAt/);
  assert.match(source, /State\.cachedSelectedEventActive/);

  const pityBody = source.match(/function Feature\.isSecretPityAtOneRoll\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(pityBody, /secret/);
  assert.doesNotMatch(pityBody, /mythic\/secret/);
  assert.doesNotMatch(pityBody, /mythic/);

  const holdBody = source.match(/function Feature\.shouldHoldPityForEvent\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(holdBody, /Feature\.isSecretPityAtOneRoll\(\)/);
  assert.match(holdBody, /Feature\.getCachedSelectedSnipeEventActive\(\)/);
  assert.doesNotMatch(holdBody, /Feature\.isPityAtOneRoll\(\)/);

  const scanBody = source.match(/function Feature\.scanSelectedEventText\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(scanBody, /PlayerGui:FindFirstChild\("MainUI"\)/);
});

test("SaltHub includes battlepass autoclaim support", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /autoBattlepass/);
  assert.match(source, /function Feature\.toggleBattlepass/);
  assert.match(source, /BattlepassClaim/);
  assert.match(source, /BattlepassQuestClaim/);
  assert.match(source, /Auto Battlepass Claim/);
});

test("SaltHub loads passively by default", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /safety = \{/);
  assert.match(source, /parent = "PlayerGui"/);
  assert.match(source, /guiName = "DevControlPanel"/);
  assert.match(source, /function UI\.getGuiParent/);
  assert.doesNotMatch(source, /gui\.Parent = CoreGui/);
  assert.doesNotMatch(source, /function SaltHub\.Start\(\)\s+State\.refresh\(\)/);
  assert.doesNotMatch(source, /loadDataOnStart/);
  assert.doesNotMatch(source, /Load Game Data On Start/);
  assert.doesNotMatch(source, /dryRun/);
  assert.doesNotMatch(source, /Dry run/);
});

test("saved automation switches start their actions on load", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const startupBody = source.match(/function Feature\.startLoadedAutomationSettings\(\)([\s\S]*?)\nend/)?.[1] ?? "";

  const expectedStartupActions = [
    ["antiAfk", "Feature.setAntiAfkEnabled(true)"],
    ["autoStartWave", "Feature.setAutoStartWave(true)"],
    ["autoFastForward", "Feature.setAutoFastForward(true)"],
    ["autoRoll", "Feature.toggleAutoRoll(true)"],
    ["autoBuy", "Feature.toggleAutoBuy(true)"],
    ["autoMerge", "Feature.toggleAutoMerge(true)"],
    ["autoTrait", "Feature.toggleTrait(true)"],
    ["autoUpgrade", "Feature.toggleUpgrade(true)"],
    ["autoBuhara", "Feature.toggleBuhara(true)"],
    ["autoBattlepass", "Feature.toggleBattlepass(true)"],
    ["autoSpin", "Feature.setAutoSpin(true)"],
  ];

  assert.match(source, /function Feature\.setAutoSpin\(value\)/);
  assert.match(source, /UI\.toggle\(spin, "Auto Spin Wheel"[\s\S]*?end, Feature\.setAutoSpin\)/);
  assert.match(source, /Feature\.startLoadedAutomationSettings\(\)/);

  for (const [flag, action] of expectedStartupActions) {
    assert.match(startupBody, new RegExp(`if Config\\.flags\\.${flag} then\\s+${action.replace(/[().]/g, "\\$&")}`));
  }
});

test("anti afk is enabled by default and user-toggleable in settings", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /antiAfk = true/);
  assert.match(source, /antiAfkCooldown = 60/);
  assert.match(source, /lastAntiAfkAt = 0/);
  assert.match(source, /function Feature\.pulseAntiAfk/);
  assert.match(source, /function Feature\.setAntiAfkEnabled/);
  assert.match(source, /LocalPlayer\.Idled:Connect/);
  assert.match(source, /Feature\.pulseAntiAfk\(idleTime\)/);
  assert.match(source, /Maid:add\(Feature\.antiAfkConnection\)/);
  assert.match(source, /UI\.toggle\(ui, "Anti-AFK"/);
  assert.match(source, /return Config\.flags\.antiAfk/);
  assert.match(source, /Feature\.setAntiAfkEnabled/);
});

test("anti afk settings include an interval slider and test button", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function UI\.slider/);
  assert.match(source, /Name = title \.\. "Slider"/);
  assert.match(source, /math\.clamp/);
  assert.match(source, /UserInputService\.InputChanged:Connect/);
  assert.match(source, /UI\.slider\(ui, "Anti-AFK Interval"/);
  assert.match(source, /Config\.delays\.antiAfkCooldown/);
  assert.match(source, /30, 300, 15/);
  assert.match(source, /function Feature\.testAntiAfk/);
  assert.match(source, /Feature\.pulseAntiAfk\(0, true\)/);
  assert.match(source, /UI\.button\(ui, "Test Anti-AFK"/);
});

test("anti afk interval starts a periodic pulse loop before Roblox idled fires", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.startAntiAfkLoop/);
  assert.match(source, /function Feature\.stopAntiAfkLoop/);
  assert.match(source, /Feature\.loops\.antiAfk = true/);
  assert.match(source, /task\.wait\(Config\.delays\.antiAfkCooldown\)/);
  assert.match(source, /Feature\.pulseAntiAfk\(nil, true\)/);
  assert.match(source, /function Feature\.restartAntiAfkLoop/);
  assert.match(source, /Feature\.startAntiAfkLoop\(\)/);
  assert.match(source, /Feature\.restartAntiAfkLoop\(\)/);

  const toggleBody = source.match(/function Feature\.setAntiAfkEnabled\(value\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(toggleBody, /Feature\.startAntiAfkLoop\(\)/);
  assert.match(toggleBody, /Feature\.stopAntiAfkLoop\(\)/);

  const startBody = source.match(/function SaltHub\.Start\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(startBody, /Feature\.attachAntiAfk\(\)/);
  assert.match(startBody, /Feature\.startAntiAfkLoop\(\)/);
});

test("native menu optimizer freezes or hides preview viewports across game menus", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /optimizeNativeMenus = true/);
  assert.match(source, /nativePreviewBatch = 2/);
  assert.match(source, /nativeVisualEffectBatch = 32/);
  assert.match(source, /nativePreviewMode = "Hide"/);
  assert.match(source, /function Feature\.freezeNativePreviewViewport/);
  assert.match(source, /function Feature\.freezeNativeVisualEffect/);
  assert.match(source, /function Feature\.queueNativeVisualEffect/);
  assert.match(source, /effect:GetAttribute\("SaltHubFrozenVisualEffect"\) ~= true/);
  assert.match(source, /function Feature\.processNativeVisualEffectQueue/);
  assert.match(source, /nativeVisualEffectRootConnections = \{\}/);
  assert.match(source, /function Feature\.attachNativeVisualEffectRoot/);
  assert.match(source, /function Feature\.hideNativePreviewViewport/);
  assert.match(source, /function Feature\.getNativePreviewMode/);
  assert.match(source, /function Feature\.setNativePreviewMode/);
  assert.match(source, /function Feature\.setSaltHubUiSuspendedForNativeMenu/);
  assert.match(source, /function Feature\.attachNativeMenuOpenGuard/);
  assert.match(source, /function Feature\.optimizeNativeMenuPreviews/);
  assert.match(source, /function Feature\.attachNativeMenuOptimizer/);
  assert.match(source, /function Feature\.setNativeMenuOptimizerEnabled/);
  assert.match(source, /function applyNativeMenuOptimizerSafetyDefaults/);
  assert.match(source, /Config\.flags\.optimizeNativeMenus = true/);
  assert.match(source, /Config\.safety\.nativePreviewBatch = math\.min\(math\.max\(tonumber\(Config\.safety\.nativePreviewBatch\) or 2, 1\), 2\)/);
  assert.match(source, /Config\.safety\.nativeVisualEffectBatch = math\.min\(math\.max\(tonumber\(Config\.safety\.nativeVisualEffectBatch\) or 32, 1\), 32\)/);
  assert.match(source, /Config\.safety\.nativePreviewMode = "Hide"/);
  assert.match(source, /"Inventory",[\s\S]*"Inventory_Old",[\s\S]*"Clone",[\s\S]*"Selection",[\s\S]*"Shop",[\s\S]*"Index"/);
  assert.match(source, /descendant:IsA\("ViewportFrame"\)/);
  assert.match(source, /worldModel = viewport:FindFirstChild\("WorldModel"\)/);
  assert.match(source, /descendant:IsA\("LocalScript"\)/);
  assert.match(source, /descendant\.Disabled = true/);
  assert.match(source, /descendant:IsA\("BasePart"\)/);
  assert.match(source, /descendant\.Anchored = true/);
  assert.match(source, /instance:IsA\("UIGradient"\)/);
  assert.match(source, /effect\.Enabled = false/);
  assert.match(source, /effect\.Enabled = true/);
  assert.match(source, /effect\.Offset = Vector2\.new\(0, 0\)/);
  assert.match(source, /effect\.Rotation = 0/);
  const gradientBranch = source.match(/if effect:IsA\("UIGradient"\) then([\s\S]*?)else/)?.[1] ?? "";
  assert.match(gradientBranch, /effect\.Enabled = true/);
  assert.doesNotMatch(gradientBranch, /effect\.Enabled = false/);
  const queueBody = source.match(/function Feature\.queueNativeVisualEffect\(effect\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(queueBody, /effect:IsA\("UIGradient"\)/);
  assert.match(queueBody, /enabled == false/);
  assert.match(source, /instance:IsA\("ParticleEmitter"\)/);
  assert.match(source, /instance:IsA\("Beam"\)/);
  assert.match(source, /instance:IsA\("Trail"\)/);
  assert.match(source, /instance:IsA\("Highlight"\)/);
  assert.match(source, /SaltHubFrozenVisualEffect/);
  assert.match(source, /GetPlayingAnimationTracks\(\)/);
  assert.match(source, /track:Stop\(0\)/);
  assert.match(source, /viewport\.Visible = false/);
  const hideBody = source.match(/function Feature\.hideNativePreviewViewport\(viewport\)([\s\S]*?)\nfunction Feature\.freezeNativePreviewViewport/)?.[1] ?? "";
  assert.doesNotMatch(hideBody, /ClearAllChildren/);
  assert.match(source, /SaltHubHiddenPreview/);
  const menuAttachBody = source.match(/function Feature\.attachNativeMenuRoot\(Root\)([\s\S]*?)\nfunction Feature\.attachNativeVisualEffectRoot/)?.[1] ?? "";
  assert.doesNotMatch(menuAttachBody, /Root\.DescendantAdded:Connect/);
  const guardBody = source.match(/function Feature\.attachNativeMenuOpenGuard\(\)([\s\S]*?)\nfunction Feature\.optimizeNativeMenuPreviews/)?.[1] ?? "";
  assert.match(guardBody, /MouseButton1Down:Connect/);
  assert.match(guardBody, /frames:FindFirstChild\("UILeft"\)/);
  assert.match(guardBody, /frames:FindFirstChild\("UIRight"\)/);
  assert.match(guardBody, /Feature\.setSaltHubUiSuspendedForNativeMenu\(true\)/);
  assert.match(guardBody, /Feature\.isNativeMenuOpen\(\)/);
  assert.match(guardBody, /Feature\.setSaltHubUiSuspendedForNativeMenu\(false\)/);
  assert.match(source, /now - lastRootRefresh >= 5/);
  assert.match(source, /UI\.toggle\(ui, "Optimize Native Menus"/);
  assert.match(source, /UI\.cycle\(ui, "Native Preview Mode"/);
  assert.match(source, /return \{ "Static", "Hide" \}/);

  const startBody = source.match(/function SaltHub\.Start\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(startBody, /if Config\.flags\.optimizeNativeMenus then[\s\S]*Feature\.attachNativeMenuOptimizer\(\)/);
});

test("SaltHub GUI avoids hidden selector rebuild churn", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const selectorBody = source.match(/function UI\.inventoryUnitSelector\(parent, title, unitsGetter, selectedIdGetter, setter, height\)([\s\S]*?)\nfunction UI\.traitSelector/)?.[1] ?? "";
  const cycleBody = source.match(/function UI\.cycle\(parent, title, options, getter, setter\)([\s\S]*?)\nfunction UI\.slider/)?.[1] ?? "";
  const sliderBody = source.match(/function UI\.slider\(parent, title, getter, setter, minValue, maxValue, stepValue\)([\s\S]*?)\nfunction UI\.multiSelectList/)?.[1] ?? "";

  assert.match(source, /function UI\.isVisible\(instance\)/);
  assert.match(source, /current:IsA\("GuiObject"\) and current\.Visible == false/);
  assert.match(selectorBody, /local function getSignature\(units\)/);
  assert.match(selectorBody, /lastSignature = getSignature\(units\)/);
  assert.match(selectorBody, /UI\.isVisible\(list\)/);
  assert.match(selectorBody, /if signature ~= lastSignature then\s+refresh\(units\)/);
  assert.match(cycleBody, /UI\.isVisible\(button\)/);
  assert.match(cycleBody, /now - lastUpdate >= 0\.25/);
  assert.match(sliderBody, /UI\.isVisible\(frame\)/);
  assert.match(sliderBody, /now - lastRedraw >= 0\.25/);
});

test("native menu optimizer avoids descendant task storms when native menus build models", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const inspectBody = source.match(/function Feature\.inspectNativeMenuDescendant\(descendant\)([\s\S]*?)\nend/)?.[1] ?? "";
  const attachBody = source.match(/function Feature\.attachNativeMenuRoot\(Root\)([\s\S]*?)\nend/)?.[1] ?? "";
  const refreshBody = source.match(/function Feature\.refreshNativeMenuOptimizerRoots\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  const heartbeatBody = source.match(/Feature\.nativeMenuOptimizerConnection = RunService\.Heartbeat:Connect\(function\(\)([\s\S]*?)\n    end\)/)?.[1] ?? "";

  assert.match(source, /nativeRootScanBatch = 96/);
  assert.match(source, /nativeMenuQueuedRootScans = \{\}/);
  assert.match(source, /function Feature\.queueNativeRootScan/);
  assert.match(source, /function Feature\.processNativeRootScanQueue/);
  assert.match(source, /Feature\.queueNativeRootScan\(Root\)/);
  assert.match(heartbeatBody, /Feature\.processNativeRootScanQueue\(Config\.safety\.nativeRootScanBatch\)/);
  assert.match(inspectBody, /descendant:IsA\("ViewportFrame"\)/);
  assert.match(inspectBody, /descendant:IsA\("WorldModel"\)/);
  assert.match(inspectBody, /descendant\.Parent:IsA\("ViewportFrame"\)/);
  assert.match(inspectBody, /Feature\.isNativeVisualEffect\(descendant\)/);
  assert.match(inspectBody, /Feature\.queueNativeVisualEffect\(descendant\)/);
  assert.doesNotMatch(attachBody, /Root\.DescendantAdded:Connect/);
  assert.doesNotMatch(attachBody, /Feature\.inspectNativeMenuDescendant\(descendant\)/);
  assert.doesNotMatch(attachBody, /Feature\.queueNativeMenuRoot\(Root\)/);
  assert.doesNotMatch(attachBody, /Feature\.findAncestorViewport\(descendant\)/);
  assert.doesNotMatch(attachBody, /task\.defer/);
  assert.doesNotMatch(attachBody, /task\.delay/);
  const visualAttachBody = source.match(/function Feature\.attachNativeVisualEffectRoot\(Root\)([\s\S]*?)\nfunction Feature\.refreshNativeMenuOptimizerRoots/)?.[1] ?? "";
  assert.doesNotMatch(visualAttachBody, /DescendantAdded:Connect/);
  assert.doesNotMatch(visualAttachBody, /GetDescendants\(\)/);
  assert.match(refreshBody, /Feature\.attachNativeVisualEffectRoot\(root\)/);
  assert.doesNotMatch(refreshBody, /Feature\.queueNativeVisualEffectRoot\(root\)/);
});

test("anti afk responds to idle with throttled virtual input", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  const pulseBody = source.match(/function Feature\.pulseAntiAfk\(idleTime, force\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(pulseBody, /if not Config\.flags\.antiAfk then[\s\S]*?return false/);
  assert.match(pulseBody, /local now = os\.clock\(\)/);
  assert.match(pulseBody, /if not force and now - \(State\.lastAntiAfkAt or 0\)/);
  assert.match(pulseBody, /Config\.delays\.antiAfkCooldown/);
  assert.match(pulseBody, /State\.lastAntiAfkAt = now/);
  assert.match(pulseBody, /VirtualInputManager:SendKeyEvent\(true, Enum\.KeyCode\.Space, false, game\)/);
  assert.match(pulseBody, /VirtualInputManager:SendKeyEvent\(false, Enum\.KeyCode\.Space, false, game\)/);
  assert.match(pulseBody, /VirtualUser:CaptureController\(\)/);
  assert.match(pulseBody, /VirtualUser:ClickButton2\(Vector2\.new\(\)\)/);
  assert.match(pulseBody, /local humanoid = character and character:FindFirstChildOfClass\("Humanoid"\)/);
  assert.match(pulseBody, /humanoid\.Jump = true/);
  assert.match(pulseBody, /Anti-AFK pulse/);
});

test("SaltHub sends real throttled remote calls by default", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Remote\.canSend/);
  assert.match(source, /Config\.safety\.remoteCooldown/);
  assert.match(source, /remote:FireServer\(tableUnpack\(args\)\)/);
  assert.match(source, /remote:InvokeServer\(tableUnpack\(args\)\)/);
  assert.doesNotMatch(source, /Config\.safety\.dryRun/);
});

test("auto roll scans owned podium characters and uses E-hold prompts", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.applyAutoRollSettingsLocal/);
  assert.match(source, /function Feature\.startLoadedAutomationSettings/);
  assert.match(source, /if Config\.flags\.autoRoll then\s+Feature\.toggleAutoRoll\(true\)/);
  assert.match(source, /if Config\.flags\.autoBuy then\s+Feature\.toggleAutoBuy\(true\)/);
  assert.match(source, /function Feature\.getOwnedPlot/);
  assert.match(source, /function Feature\.getRollPrompt/);
  assert.match(source, /function Feature\.getRollStationCFrame/);
  assert.match(source, /function Feature\.getRolledCharacters/);
  assert.match(source, /function Feature\.matchesRollTarget/);
  assert.match(source, /function Feature\.shouldHoldPityForEvent/);
  assert.match(source, /function Feature\.isSelectedSnipeEventActive/);
  assert.match(source, /function Feature\.trackEventUi/);
  assert.match(source, /function Feature\.attachEventUiTracker/);
  assert.match(source, /function Feature\.isEventStatusText/);
  assert.match(source, /function Feature\.getRollPityEntries/);
  assert.match(source, /function Feature\.getPityText/);
  assert.match(source, /function Feature\.findMatchingRolledCharacter/);
  assert.match(source, /function Feature\.holdKey/);
  assert.match(source, /function Feature\.holdPrompt/);
  assert.match(source, /function Feature\.triggerPromptExact/);
  assert.match(source, /function Feature\.getNearbyPromptConflicts/);
  assert.match(source, /function Feature\.canSafelyUseKeyForPrompt/);
  assert.match(source, /function Feature\.teleportToInstance/);
  assert.match(source, /function Feature\.moveToCFrame/);
  assert.match(source, /function Feature\.moveNearInstance/);
  assert.match(source, /function Feature\.returnToRollStation/);
  assert.match(source, /function Feature\.rollOnce/);
  assert.match(source, /function Feature\.shouldRollAgain/);
  assert.match(source, /function Feature\.autoBuyStep/);
  assert.match(source, /function Feature\.toggleAutoBuy/);
  assert.match(source, /function Feature\.buyRolledCharacter/);
  assert.match(source, /function Feature\.autoRollStep/);
  assert.match(source, /workspace:FindFirstChild\("Plots"\)/);
  assert.match(source, /plot:FindFirstChild\("Characters"\)/);
  assert.match(source, /"RollPrompt"/);
  assert.match(source, /EventUI = \{ "ReplicatedStorage", "Remotes", "Events", "EventUI" \}/);
  assert.match(source, /Roll\.Guaranteed/);
  assert.match(source, /"ProximityPrompt"/);
  assert.match(source, /KeyboardKeyCode/);
  assert.match(source, /Enum\.KeyCode\.E/);
  assert.match(source, /VirtualInputManager:SendKeyEvent/);
  assert.match(source, /Humanoid:MoveTo|humanoid:MoveTo/);
  assert.match(source, /MoveToFinished:Wait/);
  assert.match(source, /State\.activeEventText/);
  assert.match(source, /State\.lastRollAt/);
  assert.match(source, /State\.rollBusyUntil/);
  assert.match(source, /State\.pityHoldUntil/);
  assert.doesNotMatch(source, /"Detected Podium"/);
  assert.match(source, /unitMutationTargets = \{\}/);
  assert.match(source, /local function normalizeUnitMutationTargets\(targets\)/);
  assert.match(source, /local clean = uniqueSorted\(mutationList\)/);
  assert.match(source, /Config\.roll\.unitMutationTargets = normalizeUnitMutationTargets\(Config\.roll\.unitMutationTargets\)/);
  assert.match(source, /function UI\.unitMutationSelector/);
  assert.match(source, /UI\.unitMutationSelector\(.*"Target Units"/s);
  assert.match(source, /UI\.multiSelectList\(page, "Snipe Events"/);
  assert.match(source, /TweenService:Create/);
  assert.match(source, /Name = "UnitRow"/);
  assert.match(source, /Name = "Caret"/);
  assert.match(source, /AnchorPoint = Vector2\.new\(1, 0\.5\)/);
  assert.match(source, /Position = UDim2\.new\(1, -8, 0\.5, 0\)/);
  assert.match(source, /TextSize = 11/);
  assert.match(source, /local mutationTargets = Config\.roll\.unitMutationTargets/);
  assert.match(source, /Mythic\/Secret in 1 roll/i);
  assert.match(source, /Config\.roll\.snipeEvents/);
  assert.match(source, /Feature\.attachEventUiTracker\(\)/);
  assert.match(source, /Feature\.isEventStatusText\(descendant\.Text\)/);
  assert.match(source, /pityHoldPoll = 1\.0/);
  assert.match(source, /function Feature\.setPityHoldBackoff/);
  assert.match(source, /function Feature\.getAutoRollLoopDelay/);
  assert.doesNotMatch(source, /UI\.textBox\(main, "Target units, comma separated"/);
  assert.doesNotMatch(source, /UI\.textBox\(main, "Target mutations, comma separated"/);
  assert.doesNotMatch(source, /UI\.multiSelectList\(page, "Target Mutations"/);
  assert.doesNotMatch(source, /UI\.button\(main, "Apply Local Filters"/);
  assert.doesNotMatch(source, /UI\.button\(main, "Roll Once \(Hold E\)"/);
  assert.doesNotMatch(source, /UI\.button\(main, "Buy Matching Now"/);
  assert.doesNotMatch(source, /AutoRollToggle/);
  assert.doesNotMatch(source, /AutoRollSetSetting/);
  assert.doesNotMatch(source, /Remote\.setAutoRollSetting\("WantedCharacters"/);
  assert.doesNotMatch(source, /Remote\.setAutoRollSetting\("WantedMutations"/);
  const toggleBody = source.match(/function Feature\.toggleAutoRoll\(value\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(toggleBody, /Remote\.fire/);
  assert.match(toggleBody, /Feature\.startLoop\("autoRoll"/);
  assert.match(toggleBody, /return Feature\.getAutoRollLoopDelay\(\)/);
  assert.match(toggleBody, /Feature\.stopLoop\("autoRoll"\)/);

  const autoRollBody = source.match(/function Feature\.autoRollStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(autoRollBody, /if os\.clock\(\) < \(State\.pityHoldUntil or 0\) then[\s\S]*?return/);
  assert.match(autoRollBody, /Feature\.setPityHoldBackoff\(\)/);
  assert.match(source, /State\.pityHoldUntil = os\.clock\(\) \+ \(tonumber\(Config\.delays\.pityHoldPoll\) or 1\.0\)/);
  assert.match(source, /State\.pityHoldUntil = 0/);
});

test("prompt activation is exact so rolling cannot accidentally buy podium units", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.triggerPromptExact/);
  assert.match(source, /fireproximityprompt/);
  assert.match(source, /pcall\(fireproximityprompt, prompt, holdDuration\)/);
  assert.match(source, /function Feature\.getNearbyPromptConflicts/);
  assert.match(source, /prompt ~= targetPrompt/);
  assert.match(source, /root\.Position - targetPart\.Position/);
  assert.match(source, /function Feature\.canSafelyUseKeyForPrompt/);
  assert.match(source, /return #Feature\.getNearbyPromptConflicts\(prompt\) == 0/);

  const holdBody = source.match(/function Feature\.holdPrompt\(prompt\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(holdBody, /if Feature\.triggerPromptExact\(prompt\) then[\s\S]*?return true/);
  assert.match(holdBody, /if not Feature\.canSafelyUseKeyForPrompt\(prompt\) then[\s\S]*?return false/);
  assert.match(holdBody, /return Feature\.holdKey/);

  const rollBody = source.match(/function Feature\.rollOnce\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(rollBody, /Feature\.returnToRollStation\(\)/);
  assert.match(rollBody, /local ok = Feature\.holdPrompt\(prompt\)/);
  assert.doesNotMatch(rollBody, /Feature\.holdKey/);
});

test("auto roll parks behind the roll button for natural walking", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /rollStationBehindDistance = 5\.6/);
  assert.match(source, /function Feature\.getRollButtonRearDirection/);
  assert.match(source, /function Feature\.getRollStationLookTarget/);
  assert.match(source, /local rearDirection = Feature\.getRollButtonRearDirection\(buttonPart, lookAt\)/);
  assert.match(source, /local station = buttonPart\.Position \+ rearDirection \* Config\.roll\.rollStationBehindDistance/);
  assert.match(source, /return CFrame\.lookAt\(station, Vector3\.new\(lookAt\.X, station\.Y, lookAt\.Z\)\)/);

  const stationBody = source.match(/function Feature\.getRollStationCFrame\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(stationBody, /buttonPart\.Position - direction \* 4\.2/);
});

test("auto roll settles between rolls and auto buy can run independently", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /buyScan = 0\.12/);
  assert.match(source, /rollSettle = 0\.55/);
  assert.match(source, /buyPause = 0\.9/);

  const rollBody = source.match(/function Feature\.autoRollStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(rollBody, /if State\.buyingCharacter then[\s\S]*?return/);
  assert.match(rollBody, /local bought = Feature\.autoBuyStep\(\)/);
  assert.match(rollBody, /if bought then[\s\S]*?return/);
  assert.match(rollBody, /local match = Feature\.findMatchingRolledCharacter\(\)/);
  assert.match(rollBody, /if match then[\s\S]*?return/);
  assert.match(rollBody, /if not Feature\.shouldRollAgain\(\) then[\s\S]*?return/);
  assert.match(rollBody, /Feature\.rollOnce\(\)/);

  const buyToggleBody = source.match(/function Feature\.toggleAutoBuy\(value\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(buyToggleBody, /Config\.flags\.autoBuy = value/);
  assert.match(buyToggleBody, /Feature\.startLoop\("autoBuy"[\s\S]*Config\.delays\.buyScan[\s\S]*Feature\.autoBuyStep/);
  assert.match(buyToggleBody, /Feature\.stopLoop\("autoBuy"\)/);

  const uiRollBody = source.match(/name = "Roll"[\s\S]*?UI\.unitMutationSelector/)?.[0] ?? "";
  assert.match(uiRollBody, /end, Feature\.toggleAutoBuy\)/);
  assert.doesNotMatch(uiRollBody, /Config\.flags\.autoBuy = value\s+Feature\.applyAutoRollSettingsLocal/);
});

test("auto buy waits for cash before rolling past a wanted character", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /pendingBuy = nil/);
  assert.match(source, /lastPendingBuyLogAt = 0/);
  assert.match(source, /function Feature\.parseCashText/);
  assert.match(source, /function Feature\.getRolledCharacterPrice/);
  assert.match(source, /function Feature\.getRolledCharacterKey/);
  assert.match(source, /function Feature\.findPendingBuyCandidate/);
  assert.match(source, /function Feature\.setPendingBuy/);
  assert.match(source, /function Feature\.clearPendingBuy/);
  assert.match(source, /function Feature\.shouldWaitForCashToBuy/);
  assert.match(source, /Feature\.getPlayerCash\(\) < price/);
  assert.match(source, /State\.pendingBuy = \{/);
  assert.match(source, /State\.rollBusyUntil = math\.max\(State\.rollBusyUntil or 0, os\.clock\(\) \+ \(tonumber\(Config\.delays\.rollSettle\) or 0\.55\)\)/);

  const buyBody = source.match(/function Feature\.autoBuyStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(buyBody, /local pending = Feature\.findPendingBuyCandidate\(\)/);
  assert.match(buyBody, /if pending then[\s\S]*?return Feature\.tryBuyRolledCharacter\(pending\)/);
  assert.match(buyBody, /local match = Feature\.findMatchingRolledCharacter\(\)/);
  assert.match(buyBody, /return Feature\.tryBuyRolledCharacter\(match\)/);

  const rollBody = source.match(/function Feature\.autoRollStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(rollBody, /if State\.pendingBuy then[\s\S]*?Feature\.autoBuyStep\(\)[\s\S]*?return/);
});

test("one-time buttons are removed from primary pages", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  for (const label of [
    "Start Wave Once",
    "End Wave Once",
    "Claim Free Rewards",
    "Drop Food Once",
    "Spin Once",
    "Merge Once",
    "Reroll Once",
    "Buy Next Affordable",
    "Refresh Buhara Data",
    "Refresh Units",
    "Lock Selected",
    "Unlock Selected",
  ]) {
    assert.doesNotMatch(source, new RegExp(`UI\\.button\\([^\\n]*"${label.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}"`));
  }
});

test("trait reroll uses selectable inventory and trait rarity tables", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function UI\.inventoryUnitSelector/);
  assert.match(source, /Name = "TraitUnitTable"/);
  assert.match(source, /unit\.name \.\. " - " \.\. unit\.mutation \.\. " - Lvl " \.\. tostring\(unit\.level\) \.\. " - " \.\. unit\.trait/);
  assert.match(source, /Config\.trait\.selectedUnitId = unit\.id/);
  assert.match(source, /Config\.trait\.selectedUnitName = unit\.name/);
  assert.match(source, /function UI\.traitSelector/);
  assert.match(source, /Name = "TraitTargetTraits"/);
  assert.match(source, /local traitColor = rarityColor\(rarity\)/);
  assert.match(source, /State\.traitOptions/);
  assert.match(source, /Config\.trait\.targetTraits/);
  assert.doesNotMatch(source, /UI\.cycle\(main, "Selected Unit"/);
  assert.doesNotMatch(source, /UI\.textBox\(main, "Target traits, comma separated"/);
  assert.doesNotMatch(source, /"Known Traits"/);
});

test("trait reroll uses game trait data and the native roll contract", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.getTraitMap/);
  assert.match(source, /function Feature\.getTraitShardAmount/);
  assert.match(source, /function Feature\.getSelectedTraitUnit/);
  assert.match(source, /function Feature\.isTraitUnitBusy/);
  assert.match(source, /function Feature\.shouldUseConfirmedTraitRoll/);
  assert.match(source, /function Feature\.requestTraitRoll/);
  assert.match(source, /function Feature\.autoTraitStep/);
  assert.match(source, /function textEqualsAny/);
  assert.match(source, /client:get\("Traits"\)/);
  assert.match(source, /client:get\("Items"\)/);
  assert.match(source, /client:get\("Cloning"\)/);
  assert.match(source, /Remote\.fire\("TraitRequest", action, \{ CharacterId = unit\.id \}\)/);
  assert.match(source, /local action = Feature\.shouldUseConfirmedTraitRoll\(unit\) and "ConfirmedRoll" or "Roll"/);
  assert.match(source, /Feature\.shouldUseConfirmedTraitRoll[\s\S]*textEqualsAny\(unit\.trait, Config\.trait\.targetTraits\)/);
  assert.match(source, /Config\.trait\.stopWhenMatched[\s\S]*textEqualsAny\(unit\.trait, Config\.trait\.targetTraits\)/);
  assert.match(source, /Feature\.startLoop\("autoTrait"[\s\S]*Feature\.autoTraitStep/);
  assert.match(source, /State\.scanUnits\(\)[\s\S]*Feature\.getTraitMap\(\)/);
  assert.doesNotMatch(source, /textMatchesAny\(unit\.trait, Config\.trait\.targetTraits\)/);
  assert.doesNotMatch(source, /Remote\.fire\("TraitRequest", \{\s*unit = unit\.instance,\s*id = unit\.id,\s*targets = Config\.trait\.targetTraits,\s*\}\)/);
});

test("data and log status boxes are removed from the UI", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  for (const label of [
    "Inventory Scanner",
    "Visible Units",
    "Known Traits",
    "Upgrade Status",
    "Battlepass Status",
    "Current Roll",
    "Detected Podium",
    "Log",
  ]) {
    assert.doesNotMatch(source, new RegExp(`"${label.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}"`));
  }
  assert.doesNotMatch(source, /UI\.statusList\(page/);
  assert.doesNotMatch(source, /UI\.logBox\(logs\)/);
  assert.doesNotMatch(source, /State\.buhara or \{\}/);
});

test("auto merge uses placement merge flow instead of gamepass auto merge remote", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /PlaceCharacter = \{ "ReplicatedStorage", "Remotes", "Characters", "PlaceCharacter" \}/);
  assert.match(source, /PickupCharacter = \{ "ReplicatedStorage", "Remotes", "Characters", "PickupCharacter" \}/);
  assert.match(source, /function Feature\.getDuplicateMergePlan/);
  assert.match(source, /function Feature\.getSelectedMergeUnit/);
  assert.match(source, /function Feature\.getMergeCandidates/);
  assert.match(source, /function Feature\.findUnitTool/);
  assert.match(source, /function Feature\.equipUnitForMerge/);
  assert.match(source, /function Feature\.pickupUnitForMerge/);
  assert.match(source, /function Feature\.getMergeAnchorCell/);
  assert.match(source, /function Feature\.traitScore/);
  assert.match(source, /function Feature\.findFreeGridCell/);
  assert.match(source, /function Feature\.placeUnitForMerge/);
  assert.match(source, /function Feature\.autoMergeStep/);
  assert.match(source, /Remote\.fire\("PickupCharacter"/);
  assert.match(source, /function Feature\.getMergePlacement/);
  assert.match(source, /remote:FireServer\(\{/);
  assert.match(source, /HoveredCellName = placement\.hoveredCellName/);
  assert.match(source, /ShapeCFrame = placement\.shapeCFrame/);
  assert.doesNotMatch(source, /MergeTargetId =/);
  assert.doesNotMatch(source, /Remote\.fire\("AutoMergeToggle"/);
  assert.doesNotMatch(source, /AutoMergeToggle =/);
  assert.doesNotMatch(source, /RequestGamepass/);
});

test("best lineup placement scores combat stats and packs current grid footprints", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /bestLineup = \{/);
  assert.match(source, /dpsWeight = 1/);
  assert.match(source, /damageWeight = 0\.12/);
  assert.match(source, /rangeWeight = 0\.08/);
  assert.match(source, /cooldownWeight = 3/);
  assert.match(source, /rarityWeight = 3/);
  assert.match(source, /rngWeight = 0\.01/);
  assert.match(source, /footprintPenalty = 0\.035/);
  assert.match(source, /beamWidth = 192/);
  assert.match(source, /candidateLimit = 128/);
  assert.match(source, /dpsCandidateLimit = 96/);
  assert.match(source, /damageCandidateLimit = 48/);
  assert.match(source, /densityCandidateLimit = 64/);
  assert.match(source, /frontCandidateLimit = 96/);
  assert.match(source, /fillCandidateLimit = 512/);
  assert.match(source, /replacementPasses = 10/);
  assert.match(source, /minReplacementGain = 0\.01/);
  assert.match(source, /frontRangeWeight = 0\.72/);
  assert.match(source, /frontDpsWeight = 0\.28/);
  assert.match(source, /placementQualityWeight = 250/);
  assert.match(source, /compactnessWeight = 350/);
  assert.match(source, /adjacencyWeight = 35/);
  assert.match(source, /gapPenaltyWeight = 18/);
  assert.match(source, /frontValueWeight = 1\.25/);
  assert.match(source, /rangeOrderWeight = 120/);
  assert.match(source, /rangeOrderTolerance = 1/);
  assert.match(source, /rangeOrderRebuild = true/);
  assert.match(source, /shortRangeBackLimit = 50/);
  assert.match(source, /shortRangeBackMinFrontScore = 0\.5/);
  assert.match(source, /backfillRemainingSpace = true/);
  assert.match(source, /searchVariants = 5/);
  assert.match(source, /CharacterLevelInfo/);
  assert.match(source, /CharacterLevelHelper/);
  assert.match(source, /CharacterStatsUiHelper/);
  assert.match(source, /PlacementHelper/);
  assert.match(source, /PlacementConfig/);
  assert.match(source, /Assets:FindFirstChild\("Shapes"\)/);
  assert.match(source, /function DataSource\.buildCharacterInfoMap/);
  assert.match(source, /function Feature\.getCharacterStaticInfo/);
  assert.match(source, /function Feature\.getMutationInfo/);
  assert.match(source, /function Feature\.getTraitInfo/);
  assert.match(source, /function Feature\.makeUnitStatModel/);
  assert.match(source, /function Feature\.computeUnitDerivedStats/);
  assert.match(source, /function Feature\.getCurrentGridModel/);
  assert.match(source, /Feature\.dataGet\("GridLevel"/);
  assert.match(source, /function Feature\.buildGridCells/);
  assert.match(source, /function Feature\.getShapeFootprint/);
  assert.match(source, /function Feature\.getShapeOccupiedCellNames/);
  assert.match(source, /function Feature\.refreshPlacementOccupancy/);
  assert.match(source, /function Feature\.scoreLineupUnit/);
  assert.match(source, /function Feature\.getLineupFrontReferencePosition/);
  assert.match(source, /local fullName = normalizeText\(descendant:GetFullName\(\)\)/);
  assert.match(source, /fullName:find\("enemyspawn", 1, true\)/);
  assert.match(source, /local minZ = math\.huge/);
  assert.match(source, /minZ = math\.min\(minZ, cell\.Position\.Z\)/);
  assert.match(source, /return Vector3\.new\(sumX \/ count, 0, minZ - cellSize \* 6\)/);
  assert.match(source, /function Feature\.getLineupCellMetrics/);
  assert.match(source, /function Feature\.assignLineupFrontPriorities/);
  assert.match(source, /function Feature\.getLineupPlacementFrontScore/);
  assert.match(source, /function Feature\.getLineupPlacementMinFrontScore/);
  assert.match(source, /function Feature\.getLineupRangeOrderScore/);
  assert.match(source, /function Feature\.getLineupPlacementScore/);
  assert.match(source, /function Feature\.sortBestLineupPlacementOptions/);
  assert.match(source, /function Feature\.findBestLineupPlacement/);
  assert.match(source, /function Feature\.ensureBestLineupData/);
  assert.match(source, /function Feature\.getBestLineupFillCandidates/);
  assert.match(source, /function Feature\.scoreBestLineupPlan/);
  assert.match(source, /function Feature\.rebuildBestLineupPlanByRange/);
  assert.match(source, /function Feature\.shouldSkipLineupFillerPlacement/);
  assert.match(source, /function Feature\.fillBestLineupPlan/);
  assert.match(source, /function Feature\.fillBestLineupBackfillPlan/);
  assert.match(source, /function Feature\.improveBestLineupPlan/);
  assert.match(source, /function Feature\.buildBestLineupBeamPlan/);
  assert.match(source, /function Feature\.buildBestLineupCandidates/);
  assert.match(source, /function Feature\.prepareBestLineupCandidatePlacements/);
  assert.match(source, /function Feature\.getBestLineupPlanFromEmptyGrid/);
  assert.match(source, /function Feature\.pickupBestLineupUnits/);
  assert.match(source, /function Feature\.getBestLineupPlan/);
  assert.match(source, /function Feature\.placeBestLineup/);
  assert.match(source, /remote\.OnClientEvent:Connect/);
  assert.match(source, /Feature\.pickupBestLineupUnits\(\)/);
  assert.match(source, /Feature\.equipUnitForPlacement\(item\.unit\)/);
  assert.match(source, /Feature\.placeCharacterAndWait\(item\)/);
  const placeBestBody = source.match(/function Feature\.placeBestLineup\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(placeBestBody, /Feature\.placeUnitForMerge/);
  assert.match(source, /ShapeName = item\.placement\.shapeName/);
  assert.match(source, /HoveredCellName = item\.placement\.hoveredCellName/);
  assert.match(source, /ShapeCFrame = item\.placement\.shapeCFrame/);
  assert.match(source, /offsets = offsets/);
  assert.match(source, /Feature\.getCellByOffset/);
  assert.match(source, /1 \/ math\.max\(derived\.cooldown/);
  assert.match(source, /derived\.damage \* \(tonumber\(Config\.bestLineup\.damageWeight\) or 0\.12\)/);
  assert.match(source, /local byDamage = copyArray\(allCandidates\)/);
  assert.match(source, /addFrom\(byDamage, math\.max\(1, tonumber\(Config\.bestLineup\.damageCandidateLimit\) or limit\)\)/);
  assert.match(source, /State\.characterStatsUiHelper[\s\S]*GetDps/);
  assert.match(source, /helper\.GetDps\(unit\.name, statModel, info, unit\.mutation, traitInfo\)/);
  assert.match(source, /local lowRange = rangeSpan > 0 and \(maxRange - range\) \/ rangeSpan or 0/);
  assert.match(source, /candidate\.frontPriority = lowRange \* \(tonumber\(Config\.bestLineup\.frontRangeWeight\) or 0\.72\)/);
  assert.match(source, /return scoreA > scoreB/);
  assert.match(source, /state\.score \+ candidate\.score \+ cellsAdded \* \(tonumber\(Config\.bestLineup\.fillWeight\) or 0\) \+ Feature\.getLineupPlacementScore\(candidate, placement, gridMap, metrics, state\.occupancy\)/);
  assert.doesNotMatch(source, /- derived\.cooldown \* \(tonumber\(Config\.bestLineup\.cooldownWeight\)/);
  assert.match(source, /derived\.dps > b\.derived\.dps/);
  assert.match(source, /candidate\.placementOptions/);
  assert.match(source, /rangeDiff \* frontDiff/);
  assert.match(source, /Feature\.getLineupRangeOrderScore\(plan\) \* \(tonumber\(Config\.bestLineup\.rangeOrderWeight\) or 0\)/);
  assert.match(source, /Feature\.rebuildBestLineupPlanByRange\(improved, fillCandidates or candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics\)/);
  assert.match(source, /Feature\.shouldSkipLineupFillerPlacement\(candidate, placement, gridMap, metrics\)/);
  assert.match(source, /Feature\.getLineupPlacementMinFrontScore\(placement, gridMap, metrics\)/);
  assert.match(source, /Feature\.fillBestLineupBackfillPlan\(ranged, fillCandidates or candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics\)/);
  assert.match(source, /item\.backfill = true/);
  const planBody = source.match(/function Feature\.getBestLineupPlan\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(planBody, /State\.loadSharedInfo\(\)/);
  assert.match(planBody, /Feature\.ensureBestLineupData\(\)/);
  assert.match(source, /local metrics = Feature\.getLineupCellMetrics\(cells\)/);
  assert.match(source, /Feature\.buildBestLineupMultiVariantPlan\(candidates, cells, gridMap, Feature\.refreshPlacementOccupancy\(gridMap\), fillCandidates, metrics\)/);
  assert.match(source, /Feature\.buildBestLineupMultiVariantPlan\(candidates, cells, gridMap, \{\}, fillCandidates, metrics\)/);
  assert.match(source, /Feature\.improveBestLineupPlan\(plan, fillCandidates or candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics\)/);
  assert.match(source, /"Place Best Lineup"/);
  assert.doesNotMatch(source, /function Feature\.placeBestLineup[\s\S]*?Remote\.fire\("AutoMergeToggle"/);
});

test("best lineup treats locked units as placeable high-damage candidates", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const buildCandidates = source.match(/function Feature\.buildBestLineupCandidates\(includeEquipped\)([\s\S]*?)\nfunction Feature\.getBestLineupFillCandidates/)?.[1] ?? "";

  assert.match(buildCandidates, /not unit\.crafting and not unit\.cloning/);
  assert.doesNotMatch(buildCandidates, /not unit\.locked/);
  assert.match(buildCandidates, /local byDamage = copyArray\(allCandidates\)/);
  assert.match(buildCandidates, /a\.derived\.damage > b\.derived\.damage/);
});

test("best lineup optimizer defaults preserve damage tuning after imports", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /best\.damageWeight = tonumber\(best\.damageWeight\) or 0\.12/);
  assert.match(source, /best\.damageCandidateLimit = math\.max\(tonumber\(best\.damageCandidateLimit\) or 0, 48\)/);
  assert.match(source, /mergeConfig\(Config, decoded\.Config or decoded\)\s+applyBestLineupOptimizerDefaults\(\)/);
});

test("best lineup optimizer explores front-heavy variants before accepting a plan", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /beamWidth = 192/);
  assert.match(source, /candidateLimit = 128/);
  assert.match(source, /frontCandidateLimit = 96/);
  assert.match(source, /fillCandidateLimit = 512/);
  assert.match(source, /replacementPasses = 10/);
  assert.match(source, /frontValueWeight = 1\.25/);
  assert.match(source, /searchVariants = 5/);
  assert.match(source, /function Feature\.getLineupPlacementValue/);
  assert.match(source, /function applyBestLineupOptimizerDefaults/);
  assert.match(source, /best\.beamWidth = math\.max\(tonumber\(best\.beamWidth\) or 0, 192\)/);
  assert.match(source, /best\.frontRangeWeight = math\.max\(tonumber\(best\.frontRangeWeight\) or 0, 0\.72\)/);
  assert.match(source, /best\.frontDpsWeight = math\.min\(tonumber\(best\.frontDpsWeight\) or 0\.28, 0\.28\)/);
  assert.match(source, /applyBestLineupOptimizerDefaults\(\)/);
  assert.match(source, /\(tonumber\(candidate and candidate\.score\) or 0\) \* \(tonumber\(Config\.bestLineup\.frontValueWeight\) or 1\.25\)/);
  assert.match(source, /function Feature\.sortLineupCandidatesByFrontNeed/);
  assert.match(source, /function Feature\.getBestLineupCandidateOrderVariants/);
  assert.match(source, /function Feature\.selectBestLineupPlan/);
  assert.match(source, /function Feature\.buildBestLineupMultiVariantPlan/);
  assert.match(source, /Feature\.buildBestLineupBeamPlan\(ordered, cells, gridMap, baseOccupancy, fillCandidates, metrics\)/);
  assert.match(source, /Feature\.selectBestLineupPlan\(plans, baseOccupancy, gridMap\)/);
  assert.match(source, /addFrom\(byFrontNeed, math\.max\(1, tonumber\(Config\.bestLineup\.frontCandidateLimit\) or limit\)\)/);
  assert.match(source, /Feature\.buildBestLineupMultiVariantPlan\(candidates, cells, gridMap, Feature\.refreshPlacementOccupancy\(gridMap\), fillCandidates, metrics\)/);
  assert.match(source, /Feature\.buildBestLineupMultiVariantPlan\(candidates, cells, gridMap, \{\}, fillCandidates, metrics\)/);
});

test("best lineup optimizer penalizes sparse plans and favors compact placement options", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /compactnessWeight = 350/);
  assert.match(source, /adjacencyWeight = 35/);
  assert.match(source, /gapPenaltyWeight = 18/);
  assert.match(source, /function Feature\.getLineupPlacementCompactnessScore/);
  assert.match(source, /function Feature\.getLineupPlanSpaceScore/);
  assert.match(source, /Feature\.getLineupPlacementCompactnessScore\(a, occupancy, gridMap\)/);
  assert.match(source, /Feature\.getLineupPlanSpaceScore\(plan, gridMap, baseOccupancy\)/);
  assert.match(source, /local compactA = Feature\.getLineupPlacementCompactnessScore\(a, occupancy, gridMap\)/);
  assert.match(source, /local planSpaceScore = Feature\.getLineupPlanSpaceScore\(plan, gridMap, baseOccupancy\)/);
});

test("best lineup optimizer makes unit tier dominate filler and compactness math", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /rarityTierWeight = 5000/);
  assert.match(source, /mutationTierWeight = 800/);
  assert.match(source, /traitTierWeight = 600/);
  assert.match(source, /function Feature\.getLineupRarityValue/);
  assert.match(source, /function Feature\.getLineupMutationTierValue/);
  assert.match(source, /function Feature\.getLineupTraitTierValue/);
  assert.match(source, /function Feature\.getLineupUnitTierScore/);
  assert.match(source, /local tierScore = Feature\.getLineupUnitTierScore\(unit, derived\)/);
  assert.match(source, /return statScore \+ tierScore, derived, tierScore, statScore/);
  assert.match(source, /tierScore = tierScore/);
  assert.match(source, /statScore = statScore \* penalty/);
  assert.match(source, /score = tierScore \+ statScore \* penalty/);
  assert.match(source, /function Feature\.sortLineupCandidatesByTier/);
  assert.match(source, /addFrom\(byTier, math\.max\(1, tonumber\(Config\.bestLineup\.tierCandidateLimit\) or limit\)\)/);
  assert.match(source, /if a\.tierScore ~= b\.tierScore then/);
  assert.match(source, /return a\.tierScore > b\.tierScore/);
});

test("best lineup places best combat units before range and filler heuristics", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const buildCandidates = source.match(/function Feature\.buildBestLineupCandidates\(includeEquipped\)([\s\S]*?)\nfunction Feature\.getBestLineupFillCandidates/)?.[1] ?? "";
  const combatSort = source.match(/function Feature\.sortLineupCandidatesByCombat\(candidates\)([\s\S]*?)\nend/)?.[1] ?? "";
  const variantsBody = source.match(/function Feature\.getBestLineupCandidateOrderVariants\(candidates\)([\s\S]*?)\nfunction Feature\.selectBestLineupPlan/)?.[1] ?? "";

  assert.match(source, /function Feature\.sortLineupCandidatesByCombat/);
  assert.match(source, /function Feature\.orderBestLineupPlanForPlacement/);
  assert.match(buildCandidates, /Feature\.sortLineupCandidatesByCombat\(candidates\)/);
  assert.match(combatSort, /if a\.score ~= b\.score then\s+return a\.score > b\.score/);
  assert.match(combatSort, /if a\.tierScore ~= b\.tierScore then\s+return a\.tierScore > b\.tierScore/);
  assert.match(variantsBody, /addVariant\(Feature\.sortLineupCandidatesByCombat\(candidates\)\)/);
  assert.match(variantsBody, /addVariant\(Feature\.sortLineupCandidatesByTier\(candidates\)\)/);
  assert.match(source, /return Feature\.orderBestLineupPlanForPlacement\(Feature\.buildBestLineupMultiVariantPlan\(candidates, cells, gridMap, Feature\.refreshPlacementOccupancy\(gridMap\), fillCandidates, metrics\)\)/);
  assert.match(source, /return Feature\.orderBestLineupPlanForPlacement\(Feature\.buildBestLineupMultiVariantPlan\(candidates, cells, gridMap, \{\}, fillCandidates, metrics\)\)/);
  assert.match(source, /Feature\.rebuildBestLineupPlanByRange\(improved, fillCandidates or candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics\)/);
  assert.match(source, /Feature\.fillBestLineupBackfillPlan\(ranged, fillCandidates or candidates, cells, gridMap, maxPlacements, baseOccupancy, metrics\)/);
});

test("best lineup resolves character mutation and trait data through normalized aliases", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /local function normalizedLookupKey/);
  assert.match(source, /map\[normalizedLookupKey\(name\)\] = info/);
  assert.match(source, /map\[normalizedLookupKey\(data\.DisplayName or name\)\] = info/);
  assert.match(source, /map\[normalizedLookupKey\(data\.DisplayName or data\.Name or name\)\] = data/);
  assert.match(source, /State\.characterInfoByName\[name\] or State\.characterInfoByName\[normalizedLookupKey\(name\)\]/);
  assert.match(source, /State\.mutationInfoByName\[name\] or State\.mutationInfoByName\[normalizedLookupKey\(name\)\]/);
  assert.match(source, /State\.traitInfoByName\[name\] or State\.traitInfoByName\[normalizedLookupKey\(name\)\]/);
  assert.match(source, /map\[normalizedLookupKey\(option\.name\)\] = option\.rarity/);
  assert.match(source, /for name, rank in pairs\(RARITY_ORDER\) do[\s\S]*normalizeText\(name\) == clean/);
});

test("placed fighter scanning preserves known trait when the model omits it", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const scanUnits = source.match(/function State\.scanUnits\(\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(scanUnits, /local existing = byId\[id\]/);
  assert.match(scanUnits, /mutation = readUnitMutation\(model, existing and existing\.mutation or "None"\)/);
  assert.match(scanUnits, /trait = traitForCharacter\(traitMap, id, readAttr\(model, \{ "Trait", "TraitName", "Passive" \}, existing and existing\.trait or "None"\)\)/);
});

test("auto merge places the best trait unit first so its trait is preserved", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  const mergeStepBody = source.match(/function Feature\.autoMergeStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(source, /function Feature\.executeMergePlan/);
  assert.match(mergeStepBody, /Feature\.getDuplicateMergePlanForFamily\(pending\.familyKey, pending\.ignoredKeys\)/);
  assert.match(mergeStepBody, /Feature\.executeTargetMergeCascade\(plan\.target\)/);
  assert.doesNotMatch(mergeStepBody, /Feature\.executeMergePlan\(plan\)/);
  assert.match(mergeStepBody, /State\.pendingMerge/);
  const executeBody = source.match(/function Feature\.executeMergePlan\(plan\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(executeBody, /Feature\.pickupMergeGroup\(plan\.units\)/);
  assert.match(executeBody, /Feature\.placeUnitForMerge\(plan\.target, plan\.cell\)/);
  assert.match(executeBody, /local mergeCell = Feature\.waitForMergeCell\(plan\.target, plan\.cell\)/);
  assert.match(executeBody, /for index = 2, #plan\.units do/);
  assert.match(executeBody, /Feature\.placeUnitForMerge\(plan\.units\[index\], mergeCell\)/);
  assert.doesNotMatch(executeBody, /plan\.source/);
});

test("merge cell lookup prefers placed model Cells attributes over character root position", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const getPlacedModelCell = source.match(/function Feature\.getPlacedModelCell\(model\)([\s\S]*?)\nend/)?.[1] ?? "";
  const waitForMergeCell = source.match(/function Feature\.waitForMergeCell\(unit, fallbackCell\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /function Feature\.getPlacedModelCell/);
  assert.match(getPlacedModelCell, /model:GetAttribute\("Cells"\) or model:GetAttribute\("GridCells"\)/);
  assert.match(waitForMergeCell, /Feature\.getPlacedModelCell\(model\)/);
});

test("placed-anchor merge waits for remote cooldown before placing fodder", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const mergeFodderIntoPlacedAnchor = source.match(/function Feature\.mergeFodderIntoPlacedAnchor\(anchor, fodder, cell\)([\s\S]*?)\nend/)?.[1] ?? "";
  const waitForUnitLevel = source.match(/function Feature\.waitForUnitLevel\(unit, expectedLevel, timeout\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(mergeFodderIntoPlacedAnchor, /task\.wait\(math\.max\(Config\.safety\.remoteCooldown, 0\.12\)\)/);
  assert.match(mergeFodderIntoPlacedAnchor, /Feature\.placeUnitForMerge\(fodder, mergeCell\)/);
  assert.match(waitForUnitLevel, /return nil/);
  assert.doesNotMatch(waitForUnitLevel, /return Feature\.refreshMergeTarget\(unit\)/);
});

test("merge placement uses real shape placement data and waits for server acceptance", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const placeUnitForMerge = source.match(/function Feature\.placeUnitForMerge\(unit, cell\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /function Feature\.getMergePlacement/);
  assert.match(placeUnitForMerge, /Feature\.getMergePlacement\(unit, cell\)/);
  assert.match(placeUnitForMerge, /remote\.OnClientEvent:Connect/);
  assert.match(placeUnitForMerge, /ShapeName = placement\.shapeName/);
  assert.match(placeUnitForMerge, /ShapeCFrame = placement\.shapeCFrame/);
  assert.doesNotMatch(placeUnitForMerge, /ShapeName = unit\.name/);
});

test("merge only falls back to same-name placed models when no unit id is known", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const findPlacedUnitModel = source.match(/function Feature\.findPlacedUnitModel\(unit\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(findPlacedUnitModel, /for _, containerName in ipairs\(\{ "Characters", "Fighters", "PlacedCharacters", "Builds" \}\) do/);
  assert.match(findPlacedUnitModel, /isPlacedUnitModel\(model, containerName\) and Feature\.unitIdMatchesInstance\(unit, model\)/);
  assert.match(findPlacedUnitModel, /isPlacedUnitModel\(model, containerName\) and model\.Name == unit\.name/);
  assert.match(findPlacedUnitModel, /if tostring\(unit\.id or ""\) ~= "" then\s+return nil\s+end/);
});

test("merge target refresh reads upgraded level and mutation from placed models", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const refreshMergeTarget = source.match(/function Feature\.refreshMergeTarget\(target\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(refreshMergeTarget, /local model = Feature\.findPlacedUnitModel\(target\)/);
  assert.match(refreshMergeTarget, /level = tostring\(readAttr\(model, \{ "Level", "Lvl" \}/);
  assert.match(refreshMergeTarget, /mutation = readUnitMutation\(model, refreshed\.mutation or "None"\)/);
});

test("unit scanning includes placed fighters for merge planning", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const scanUnits = source.match(/function State\.scanUnits\(\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(scanUnits, /for _, containerName in ipairs\(\{ "Characters", "Fighters", "PlacedCharacters", "Builds" \}\) do/);
  assert.match(scanUnits, /isPlacedUnitModel\(model, containerName\)/);
  assert.match(scanUnits, /placed = true/);
  assert.match(scanUnits, /instance = model/);
});

test("unit scanning ignores roll display characters that are not placed fighters", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /local function isPlacedUnitModel\(model, containerName\)/);
  assert.match(source, /containerName == "Fighters" or containerName == "PlacedCharacters"/);
  assert.match(source, /readAttr\(model, \{ "IsPlacedCharacter" \}, false\) == true/);
  assert.match(source, /tostring\(readAttr\(model, \{ "Cells" \}, ""\)\) ~= ""/);
  assert.match(source, /id ~= "" and model\.Name ~= "" and isPlacedUnitModel\(model, containerName\)/);
});

test("placed fighter scanning preserves known mutation when the model omits it", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const scanUnits = source.match(/function State\.scanUnits\(\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /local function readUnitMutation/);
  assert.match(scanUnits, /local existing = byId\[id\]/);
  assert.match(scanUnits, /mutation = readUnitMutation\(model, existing and existing\.mutation or "None"\)/);
});

test("merge fodder selection prefers inventory units before placed board units", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const getMergeFamilyUnits = source.match(/function Feature\.getMergeFamilyUnits\(target\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(getMergeFamilyUnits, /local placedA = a\.placed == true/);
  assert.match(getMergeFamilyUnits, /if placedA ~= placedB then\s+return not placedA\s+end/);
});

test("merge only falls back to same-name tools when no unit id is known", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const findUnitTool = source.match(/function Feature\.findUnitTool\(unit\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(findUnitTool, /if Feature\.unitIdMatchesInstance\(unit, child\) then\s+return child\s+end/);
  assert.match(findUnitTool, /if tostring\(unit\.id or ""\) == "" and child\.Name == unit\.name then\s+return child\s+end/);
  assert.doesNotMatch(findUnitTool, /Feature\.unitIdMatchesInstance\(unit, child\) or child\.Name == unit\.name/);
});

test("merge family normalizes none mutation while keeping named mutations separate", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const mergeFamilyKey = source.match(/function Feature\.mergeFamilyKey\(unit\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /function Feature\.mergeMutationKey/);
  assert.match(source, /if clean == "" or clean == "none" or clean == "normal" then\s+return "none"\s+end/);
  assert.match(mergeFamilyKey, /Feature\.mergeMutationKey\(unit and unit\.mutation\)/);
});

test("auto merge can start from inventory without already placed duplicate anchors", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.groupHasPlacedAnchor/);
  assert.doesNotMatch(source, /if not selectedOnly and not Feature\.groupHasPlacedAnchor\(bestGroup\) then[\s\S]*?return nil/);
  assert.doesNotMatch(source, /Merge needs at least one duplicate already placed on the grid/);
  assert.match(source, /local cell = Feature\.getMergeAnchorCell\(selected, bestGroup\)/);
  assert.match(source, /cell = Feature\.findMergePlacementCell\(bestGroup\[1\], cell\)/);
});

test("auto merge skips duplicate groups without placement shapes", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const getMergeCandidates = source.match(/function Feature\.getMergeCandidates\(selected\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(getMergeCandidates, /Feature\.getShapeFootprint\(unit\.name\)/);
  assert.match(getMergeCandidates, /if Feature\.getShapeFootprint\(unit\.name\) then/);
});

test("auto merge includes duplicate target mutations instead of preserving every rolled target", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const getMergeCandidates = source.match(/function Feature\.getMergeCandidates\(selected\)([\s\S]*?)\nend/)?.[1] ?? "";
  const mergeFamilyKey = source.match(/function Feature\.mergeFamilyKey\(unit\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(mergeFamilyKey, /Feature\.mergeMutationKey\(unit and unit\.mutation\)/);
  assert.doesNotMatch(getMergeCandidates, /Feature\.shouldKeepMergeUnit\(unit\)/);
  assert.doesNotMatch(getMergeCandidates, /Config\.roll\.unitMutationTargets/);
  assert.doesNotMatch(getMergeCandidates, /Config\.roll\.targetMutations/);
});

test("merge placement scans for a cell where the selected shape actually fits", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const findMergePlacementCell = source.match(/function Feature\.findMergePlacementCell\(unit, preferredCell\)([\s\S]*?)\nend/)?.[1] ?? "";
  const getDuplicateMergePlan = source.match(/function Feature\.getDuplicateMergePlan\(selectedOnly, ignoredKeys\)([\s\S]*?)\nend/)?.[1] ?? "";
  const buildFodderForMergeLevel = source.match(/function Feature\.buildFodderForMergeLevel\(target, level, usedIds, depth, directLevelLimit\)([\s\S]*?)\nend/)?.[1] ?? "";
  const executeTargetMergeCascade = source.match(/function Feature\.executeTargetMergeCascade\(selected\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /function Feature\.findMergePlacementCell\(unit, preferredCell\)/);
  assert.match(source, /occupiedCellNames = occupiedCells/);
  assert.match(findMergePlacementCell, /Feature\.getMergePlacement\(unit, cell\)/);
  assert.match(findMergePlacementCell, /Feature\.placementCellsAvailable\(placement, occupancy\)/);
  assert.match(getDuplicateMergePlan, /cell = Feature\.findMergePlacementCell\(bestGroup\[1\], cell\)/);
  assert.match(buildFodderForMergeLevel, /local cell = Feature\.findMergePlacementCell\(first, Feature\.findFreeGridCell\(\)\)/);
  assert.match(executeTargetMergeCascade, /targetCell = Feature\.findMergePlacementCell\(target, targetCell\)/);
});

test("merge placement validates snapped shape parts against real grid cells", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const getShapeFootprint = source.match(/function Feature\.getShapeFootprint\(unitName\)([\s\S]*?)\nend/)?.[1] ?? "";
  const getShapeOccupiedCellNames = source.match(/function Feature\.getShapeOccupiedCellNames\(footprint, anchorCell, gridMap, cells\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /function Feature\.getContainingGridCellForPosition\(position, gridMap\)/);
  assert.match(getShapeFootprint, /partOffsets = partOffsets/);
  assert.match(getShapeFootprint, /shapePivot:ToObjectSpace\(part\.CFrame\)/);
  assert.match(getShapeOccupiedCellNames, /shapeCFrame \* partOffset/);
  assert.match(getShapeOccupiedCellNames, /Feature\.getContainingGridCellForPosition\(partCFrame\.Position, gridMap\)/);
  assert.doesNotMatch(getShapeOccupiedCellNames, /Feature\.getCellByOffset\(anchorCell, offset, cells\)/);
});

test("selected merge target picker excludes unknown-level placed ghosts", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const isMergeSelectableTarget = source.match(/function Feature\.isMergeSelectableTarget\(unit\)([\s\S]*?)\nend/)?.[1] ?? "";
  const getSelectedMergeUnit = source.match(/function Feature\.getSelectedMergeUnit\(\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /function Feature\.getMergeSelectableUnits/);
  assert.match(isMergeSelectableTarget, /tostring\(unit\.level or ""\) == "\?"/);
  assert.match(isMergeSelectableTarget, /Feature\.getShapeFootprint\(unit\.name\)/);
  assert.match(getSelectedMergeUnit, /Feature\.isMergeSelectableTarget\(selected\)/);
  assert.match(source, /UI\.inventoryUnitSelector\(page, "Selected Merge Target", function\(\)\s+return Feature\.getMergeSelectableUnits\(\)/);
});

test("auto merge retries another duplicate group after an unplaceable group fails", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const autoMergeStep = source.match(/function Feature\.autoMergeStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /function Feature\.getDuplicateMergePlan\(selectedOnly, ignoredKeys\)/);
  assert.match(source, /function Feature\.getDuplicateMergePlanForFamily\(familyKey, ignoredKeys\)/);
  assert.match(source, /failedKeys = \{\}/);
  assert.match(autoMergeStep, /pending\.failedKeys\[plan\.key\] = failures/);
  assert.match(autoMergeStep, /if failures >= 3 then[\s\S]*pending\.ignoredKeys\[plan\.key\] = true/);
  assert.match(autoMergeStep, /pending\.ignoredKeys\[plan\.key\] = true/);
  assert.match(autoMergeStep, /Feature\.getDuplicateMergePlanForFamily\(pending\.familyKey, pending\.ignoredKeys\)/);
  assert.doesNotMatch(autoMergeStep, /Feature\.getDuplicateMergePlan\(false, ignoredKeys\)/);
});

test("auto merge pauses during native menus, backs off, and cleans dirty merge attempts", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const autoMergeStep = source.match(/function Feature\.autoMergeStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  const placeUnitForMerge = source.match(/function Feature\.placeUnitForMerge\(unit, cell\)([\s\S]*?)\nend/)?.[1] ?? "";
  const mergeUnitsOnCell = source.match(/function Feature\.mergeUnitsOnCell\(anchor, fodder, cell\)([\s\S]*?)\nfunction Feature\.mergeFodderIntoPlacedAnchor/)?.[1] ?? "";
  const mergeFodderIntoPlacedAnchor = source.match(/function Feature\.mergeFodderIntoPlacedAnchor\(anchor, fodder, cell\)([\s\S]*?)\nfunction Feature\.buildFodderForMergeLevel/)?.[1] ?? "";

  assert.match(source, /mergeRejectBackoff = 3/);
  assert.match(source, /mergeRejectedUntil = 0/);
  assert.match(source, /lastNativeMenuPauseLogAt = 0/);
  assert.match(source, /function Feature\.isNativeMenuOpen/);
  assert.match(source, /function Feature\.pauseMergeForNativeMenu/);
  assert.match(source, /function Feature\.backoffMerge/);
  assert.match(source, /function Feature\.cleanupFailedMergeAttempt/);
  assert.match(source, /humanoid:UnequipTools\(\)/);
  assert.match(autoMergeStep, /if now < \(State\.mergeRejectedUntil or 0\) then/);
  assert.match(autoMergeStep, /Feature\.pauseMergeForNativeMenu\(now\)/);
  assert.match(placeUnitForMerge, /Feature\.backoffMerge\("rejected placement"\)/);
  assert.match(mergeUnitsOnCell, /Feature\.cleanupFailedMergeAttempt\(anchor, fodder, false\)/);
  assert.match(mergeFodderIntoPlacedAnchor, /Feature\.cleanupFailedMergeAttempt\(anchor, fodder, true\)/);
  assert.match(mergeFodderIntoPlacedAnchor, /local updated = Feature\.waitForUnitLevel\(anchor, anchorLevel \+ 1, 3\)/);
  assert.match(mergeFodderIntoPlacedAnchor, /if not updated then/);
});

test("auto merge finishes a character family sweep before choosing another character", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const autoMergeStep = source.match(/function Feature\.autoMergeStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /function Feature\.findNextAutoMergeFamily\(characterName, ignoredFamilies, ignoredCharacters\)/);
  assert.match(source, /function Feature\.resetAutoMergePending\(\)/);
  assert.match(autoMergeStep, /pending\.characterName/);
  assert.match(autoMergeStep, /pending\.familyKey/);
  assert.match(autoMergeStep, /Feature\.findNextAutoMergeFamily\(pending\.characterName, pending\.ignoredFamilies\)/);
  assert.match(autoMergeStep, /pending\.ignoredFamilies\[pending\.familyKey\] = true/);
  assert.match(autoMergeStep, /Feature\.pickupAutoMergeBoardUnits\(pending\.characterName\)/);
});

test("auto merge does not immediately reselect a completed character in the same sweep", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const autoMergeStep = source.match(/function Feature\.autoMergeStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  const toggleAutoMerge = source.match(/function Feature\.toggleAutoMerge\(value\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /autoMergeIgnoredCharacters = \{\}/);
  assert.match(source, /function Feature\.findNextAutoMergeFamily\(characterName, ignoredFamilies, ignoredCharacters\)/);
  assert.match(autoMergeStep, /Feature\.findNextAutoMergeFamily\(nil, nil, State\.autoMergeIgnoredCharacters\)/);
  assert.match(autoMergeStep, /State\.autoMergeIgnoredCharacters\[pending\.characterName\] = true/);
  assert.match(autoMergeStep, /State\.autoMergeIgnoredCharacters = \{\}/);
  assert.match(toggleAutoMerge, /State\.autoMergeIgnoredCharacters = \{\}/);
});

test("auto merge backs off when idle instead of rescanning every merge tick", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const autoMergeStep = source.match(/function Feature\.autoMergeStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  const toggleAutoMerge = source.match(/function Feature\.toggleAutoMerge\(value\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /mergeIdle = 2\.5/);
  assert.match(source, /autoMergeIdleUntil = 0/);
  assert.match(autoMergeStep, /if now < \(State\.autoMergeIdleUntil or 0\) then/);
  assert.match(autoMergeStep, /State\.autoMergeIdleUntil = now \+ \(tonumber\(Config\.delays\.mergeIdle\) or 2\.5\)/);
  assert.match(toggleAutoMerge, /State\.autoMergeIdleUntil = 0/);
});

test("selected merge target is an explicit button action that preserves the best trait duplicate", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const mergeSelectedTarget = source.match(/function Feature\.mergeSelectedTarget\(\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /targetUnitId = ""/);
  assert.match(source, /targetUnitName = ""/);
  assert.match(source, /function Feature\.getSelectedMergeUnit/);
  assert.match(source, /function Feature\.mergeSelectedTarget/);
  assert.match(source, /local selected = selectedOnly and Feature\.getSelectedMergeUnit\(\) or nil/);
  assert.doesNotMatch(source, /Selected merge target must already be placed on the grid/);
  assert.match(source, /local selectedKey = selected and Feature\.mergeKey\(selected\) or ""/);
  assert.match(source, /if selectedKey ~= "" and key ~= selectedKey then/);
  assert.match(source, /function Feature\.orderMergeUnits/);
  assert.match(source, /function Feature\.executeTargetMergeCascade/);
  assert.match(source, /function Feature\.buildFodderForMergeLevel/);
  assert.match(source, /local seedLevel = Feature\.unitMergeLevel\(target\)/);
  assert.match(source, /function Feature\.mergeFodderIntoPlacedAnchor/);
  assert.match(source, /Feature\.mergeFodderIntoPlacedAnchor\(target, fodder, targetCell\)/);
  assert.match(source, /target = selectedOnly and selected or bestGroup\[1\]/);
  assert.match(source, /units = Feature\.orderMergeUnits\(bestGroup, selected\)/);
  assert.match(source, /targetCell = Feature\.findMergePlacementCell\(target, targetCell\)/);
  assert.doesNotMatch(source, /Feature\.getDuplicateMergePlan\(true\)/);
  assert.match(mergeSelectedTarget, /local familyKey = Feature\.mergeFamilyKey\(selected\)/);
  assert.match(mergeSelectedTarget, /local failedKeys = \{\}/);
  assert.match(mergeSelectedTarget, /Feature\.getDuplicateMergePlanForFamily\(familyKey, ignoredKeys\)/);
  assert.match(mergeSelectedTarget, /Feature\.executeTargetMergeCascade\(plan\.target\)/);
  assert.match(mergeSelectedTarget, /failedKeys\[plan\.key\] = failures/);
  assert.match(mergeSelectedTarget, /if failures >= 3 then[\s\S]*ignoredKeys\[plan\.key\] = true/);
  assert.doesNotMatch(mergeSelectedTarget, /Feature\.executeTargetMergeCascade\(selected\)/);
  assert.match(source, /Config\.merge\.targetUnitId = unit\.id/);
  assert.match(source, /Config\.merge\.targetUnitName = unit\.name/);
  assert.match(source, /UI\.inventoryUnitSelector\(page, "Selected Merge Target"/);
  assert.match(source, /UI\.button\(main, "Merge Selected Target", Feature\.mergeSelectedTarget/);
});

test("settings export copies a reusable launch script with embedded preset", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const getSerializableConfig = source.match(/function Feature\.getSerializableConfig\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  const exportLaunchScript = source.match(/function Feature\.exportLaunchScript\(\)([\s\S]*?)\nend/)?.[1] ?? "";

  assert.match(source, /local LAUNCH_SCRIPT_URL = "https:\/\/raw\.githubusercontent\.com\/sryerabati\/SaltHub\/main\/salthub\.lua"/);
  assert.match(source, /export = \{/);
  assert.match(source, /scriptUrl = LAUNCH_SCRIPT_URL/);
  assert.match(source, /function mergeConfig/);
  assert.match(source, /function applyPresetFromGlobal/);
  assert.match(source, /SaltHubPreset/);
  assert.match(source, /function Feature\.getLaunchScriptUrl/);
  assert.match(source, /function Feature\.getSerializableConfig/);
  assert.match(getSerializableConfig, /serialized\.export\.scriptUrl = Feature\.getLaunchScriptUrl\(\)/);
  assert.match(source, /function Feature\.exportLaunchScript/);
  assert.match(source, /getgenv\(\)\.SaltHubPreset/);
  assert.match(exportLaunchScript, /Feature\.getLaunchScriptUrl\(\)/);
  assert.doesNotMatch(exportLaunchScript, /tostring\(Config\.export\.scriptUrl\)/);
  assert.match(source, /loadstring\(game:HttpGet\(Config\.export\.scriptUrl\)\)\(\)/);
  assert.match(source, /setclipboard\(scriptText\)/);
  assert.match(source, /"Copy Launch Script"/);
});

test("settings auto save to executor workspace and override launch presets", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /storage = \{/);
  assert.match(source, /folder = "SaltHub"/);
  assert.match(source, /fileName = "settings\.json"/);
  assert.match(source, /function getExecutorConfigPath/);
  assert.match(source, /function getExecutorConfigCandidatePaths/);
  assert.match(source, /flatFolder \.\. "_" \.\. fileName/);
  assert.match(source, /add\("salthub_" \.\. fileName\)/);
  assert.match(source, /function applySavedConfigFromWorkspace/);
  assert.match(source, /readfile/);
  assert.match(source, /writefile/);
  assert.match(source, /makefolder/);
  assert.match(source, /for _, path in ipairs\(getExecutorConfigCandidatePaths\(\)\) do/);
  assert.match(source, /local savedPaths = \{\}/);
  assert.match(source, /local shouldTry = #savedPaths == 0/);
  assert.match(source, /State\.lastConfigSavePath = savedPaths\[1\]/);
  assert.match(source, /State\.lastConfigSavePaths = savedPaths/);
  assert.match(source, /table\.concat\(savedPaths, ", "\)/);
  assert.match(source, /State\.lastConfigSaveError = tostring\(lastErr or "unknown writefile failure"\)/);
  assert.match(source, /local presetApplied = applyPresetFromGlobal\(\)/);
  assert.match(source, /local savedConfigApplied = applySavedConfigFromWorkspace\(\)/);
  assert.match(source, /if presetApplied and savedConfigApplied then\s+workspaceConfigStatus = tostring\(workspaceConfigStatus\) \.\. " \(overrode launch preset\)"/);
  assert.doesNotMatch(source, /if not presetApplied then\s+applySavedConfigFromWorkspace\(\)/);
  assert.match(source, /function Feature\.saveConfigToWorkspace/);
  assert.match(source, /function Feature\.scheduleConfigSave/);
  assert.match(source, /Feature\.scheduleConfigSave\("ui:" \.\. tostring\(text\)\)/);
  assert.match(source, /Feature\.scheduleConfigSave\("import"\)/);
  assert.match(source, /UI\.button\(ui, "Save Settings Now", Feature\.saveConfigToWorkspace/);
});

test("auto upgrade is cash gated and prioritized", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.getDataClient/);
  assert.match(source, /function Feature\.getPlayerCash/);
  assert.match(source, /function Feature\.getUpgradeInfo/);
  assert.match(source, /function Feature\.getUpgradeLevel/);
  assert.match(source, /function Feature\.getUpgradeCost/);
  assert.match(source, /function Feature\.isUpgradeMaxed/);
  assert.match(source, /function Feature\.getNextAffordableUpgrade/);
  assert.match(source, /function Feature\.buyUpgrade/);
  assert.match(source, /function Feature\.autoUpgradeStep/);
  assert.match(source, /upgradePriority = \{ "Cash", "Luck", "Grid" \}/);
  assert.match(source, /Remote\.fire\("Upgrade", "Cash", name\)/);
  assert.match(source, /cash >= cost/);
  assert.doesNotMatch(source, /"Upgrade Status"/);
  assert.doesNotMatch(source, /for name, enabled in pairs\(Config\.upgrade\.selected\)[\s\S]*?Remote\.fire\("Upgrade", name\)/);
});

test("battlepass claim uses claimable data instead of brute force loops", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /claimMode = "levelTrack"/);
  assert.match(source, /questClaimMode = "id"/);
  assert.match(source, /function Feature\.claimBattlepassReward/);
  assert.match(source, /function Feature\.claimBattlepassQuest/);
  assert.match(source, /function Feature\.getBattlepassRewardModule/);
  assert.match(source, /function Feature\.getBattlepassData/);
  assert.match(source, /function Feature\.getBattlepassLevelInfo/);
  assert.match(source, /function Feature\.getClaimableBattlepassRewards/);
  assert.match(source, /function Feature\.getBattlepassQuestData/);
  assert.match(source, /function Feature\.getClaimableBattlepassQuests/);
  assert.match(source, /Completed == true/);
  assert.match(source, /Claimed ~= true/);
  assert.doesNotMatch(source, /"Battlepass Status"/);
  assert.doesNotMatch(source, /Remote\.fire\("BattlepassClaim", \{ level = level, track = "Free" \}\)/);
  assert.doesNotMatch(source, /Remote\.fire\("BattlepassQuestClaim", \{ id = questId \}\)/);
  const claimBody = source.match(/function Feature\.claimBattlepassOnce\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(claimBody, /for level = 1, maxLevel do/);
  assert.doesNotMatch(claimBody, /State\.battlepass\.questIds/);
});

test("auto buhara reads wanted food and teleports instead of blind dropping", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /buhara = \{/);
  assert.match(source, /foodNames = \{ "Steak", "Tomato", "Bread", "Cheese", "Lettuce", "Trait Shard" \}/);
  assert.match(source, /feedTargetNames = \{ "Buhara", "Burah", "BURAH", "BuharaEvent" \}/);
  assert.match(source, /feedDistance = 1\.1/);
  assert.match(source, /scanInterval = 0\.65/);
  assert.match(source, /dropInterval = 1\.5/);
  assert.match(source, /function Feature\.getBuharaData/);
  assert.match(source, /function Feature\.getBuharaWantedFoods/);
  assert.match(source, /function Feature\.areBuharaRequirementsReady/);
  assert.match(source, /function Feature\.dropBuharaFoodIfReady/);
  assert.match(source, /function Feature\.getBuharaFoodName/);
  assert.match(source, /function Feature\.getBuharaScanRoots/);
  assert.match(source, /function Feature\.refreshBuharaFoodDropCache/);
  assert.match(source, /function Feature\.getBuharaFoodDrops/);
  assert.match(source, /function Feature\.findWantedBuharaFood/);
  assert.match(source, /function Feature\.isCarryingBuharaFood/);
  assert.match(source, /function Feature\.collectBuharaFood/);
  assert.match(source, /function Feature\.isBuharaFeedPrompt/);
  assert.match(source, /function Feature\.getBuharaFeedPrompt/);
  assert.match(source, /function Feature\.getBuharaLegCenter/);
  assert.match(source, /function Feature\.moveToBuharaFeedPrompt/);
  assert.match(source, /function Feature\.feedBuhara/);
  assert.match(source, /function Feature\.autoBuharaStep/);
  assert.match(source, /FoodNeeded/);
  assert.match(source, /CarryingFood/);
  assert.match(source, /quantity\.Text/);
  assert.match(source, /slot\.complete ~= true/);
  assert.match(source, /Remote\.fire\("BuharaDropFood"\)/);
  assert.match(source, /Feature\.dropBuharaFoodIfReady\(data\)/);
  assert.match(source, /Feature\.feedBuhara\(true\)/);
  assert.match(source, /textMatchesAny\(child\.Name, \{ "Food", "Ingredient", "Sandwich", "Buhara", "Burah", "Trait", "Shard" \}\)/);
  assert.match(source, /Feature\.teleportToBuharaObject\(drop\.instance, Config\.buhara\.foodCollectDistance\)/);
  assert.match(source, /local prompt = Feature\.getBuharaFeedPrompt\(target\)/);
  assert.match(source, /Feature\.moveToBuharaFeedPrompt\(target, prompt\)/);
  assert.match(source, /Feature\.tryBuharaPrompt\(prompt\)/);
  assert.match(source, /return not Feature\.isCarryingBuharaFood\(\)/);
  assert.match(source, /Feature\.startLoop\("autoBuhara"[\s\S]*Feature\.autoBuharaStep/);

  const buharaToggle = source.match(/function Feature\.toggleBuhara\(value\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(buharaToggle, /Remote\.fire\("BuharaDropFood"\)/);
  const feedBody = source.match(/function Feature\.feedBuhara\(forceAttempt\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(feedBody, /Remote\.fire\("BuharaDropFood"\)/);
  assert.match(feedBody, /not forceAttempt and not Feature\.isCarryingBuharaFood\(\)/);
  const dropBody = source.match(/function Feature\.dropBuharaFoodIfReady\(data\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(dropBody, /Feature\.isCarryingBuharaFood\(\)/);
  assert.match(dropBody, /Feature\.areBuharaRequirementsReady\(data\)/);
  assert.match(dropBody, /State\.buharaDropAt/);
  const buharaBody = source.match(/function Feature\.getBuharaData\(\)([\s\S]*?)function Feature\.toggleBuhara/)?.[1] ?? "";
  assert.match(buharaBody, /Feature\.teleportToBuharaObject\(drop\.instance, Config\.buhara\.foodCollectDistance\)/);
  assert.doesNotMatch(buharaBody, /for _, instance in ipairs\(workspace:GetDescendants\(\)\) do[\s\S]*?local foodName = Feature\.getBuharaFoodName\(instance\)/);
});

test("buhara collection and feeding use direct teleport positioning", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  const collectBody = source.match(/function Feature\.collectBuharaFood\(drop\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(source, /teleportOffset = 1\.35/);
  assert.match(source, /collectRetries = 3/);
  assert.match(source, /feedRetries = 3/);
  assert.match(source, /function Feature\.teleportToBuharaObject/);
  assert.match(source, /function Feature\.detectCarriedBuharaFood/);
  assert.match(source, /function Feature\.tryBuharaPrompt/);
  assert.match(collectBody, /Feature\.teleportToBuharaObject\(drop\.instance, Config\.buhara\.foodCollectDistance\)/);
  assert.match(collectBody, /for attempt = 1, math\.max\(tonumber\(Config\.buhara\.collectRetries\) or 1, 1\) do/);
  assert.match(collectBody, /Feature\.detectCarriedBuharaFood\(\)/);
  assert.doesNotMatch(collectBody, /Feature\.teleportToInstance\(drop\.instance\)/);
  assert.doesNotMatch(collectBody, /Feature\.moveNearInstance\(drop\.instance, Config\.buhara\.foodCollectDistance, false\)/);
  assert.doesNotMatch(collectBody, /Feature\.moveToCFrame\([^)]*Config\.delays\.moveTimeout,\s*false\)/);

  const feedMoveBody = source.match(/function Feature\.moveToBuharaFeedPrompt\(target, prompt\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(feedMoveBody, /Feature\.teleportToBuharaObject\(prompt, Config\.buhara\.feedDistance\)/);
  assert.match(feedMoveBody, /Feature\.teleportToBuharaObject\(target, Config\.buhara\.feedDistance\)/);
  assert.doesNotMatch(feedMoveBody, /Feature\.teleportToInstance\(prompt\)/);
  assert.doesNotMatch(feedMoveBody, /Feature\.teleportToCFrame\(CFrame\.lookAt\(legCenter, root\.Position\)\)/);
  assert.doesNotMatch(feedMoveBody, /Feature\.moveNearInstance\(prompt, Config\.buhara\.feedDistance, false\)/);
  assert.doesNotMatch(feedMoveBody, /Feature\.moveToCFrame\([^)]*Config\.delays\.moveTimeout,\s*false\)/);

  const feedBody = source.match(/function Feature\.feedBuhara\(forceAttempt\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(feedBody, /for attempt = 1, math\.max\(tonumber\(Config\.buhara\.feedRetries\) or 1, 1\) do/);
  assert.match(feedBody, /Feature\.tryBuharaPrompt\(prompt\)/);
});

test("auto start wave is gated by owned plot wave state", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.setAutoStartWave\(value\)/);
  assert.match(source, /function Feature\.setAutoFastForward\(value\)/);
  assert.match(source, /if Config\.flags\.autoStartWave then\s+Feature\.setAutoStartWave\(true\)/);
  assert.match(source, /if Config\.flags\.autoFastForward then\s+Feature\.setAutoFastForward\(true\)/);
  assert.match(source, /Feature\.startLoadedAutomationSettings\(\)/);
  assert.match(source, /function Feature\.isWaveStarted/);
  assert.match(source, /function Feature\.shouldStartWave/);
  assert.match(source, /function Feature\.getHighestWaveCheckpoint/);
  assert.match(source, /function Feature\.ensureHighestWaveCheckpoint/);
  assert.match(source, /function Feature\.autoStartWaveStep/);
  assert.match(source, /Checkpoint = \{ "ReplicatedStorage", "Remotes", "Checkpoint" \}/);
  assert.match(source, /plot:GetAttribute\("WaveStarted"\) == true/);
  assert.match(source, /State\.lastWaveStartAt/);
  assert.match(source, /os\.clock\(\) - \(State\.lastWaveStartAt or 0\)/);

  const stepBody = source.match(/function Feature\.autoStartWaveStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(stepBody, /if not Feature\.shouldStartWave\(\) then[\s\S]*?return/);
  assert.match(stepBody, /if Config\.wave\.startHighest ~= false and not Feature\.ensureHighestWaveCheckpoint\(\) then[\s\S]*?return/);
  assert.match(stepBody, /State\.lastWaveStartAt = os\.clock\(\)/);
  assert.match(stepBody, /Remote\.fire\("StartWave"\)/);

  const checkpointBody = source.match(/function Feature\.ensureHighestWaveCheckpoint\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(checkpointBody, /Feature\.getHighestWaveCheckpoint\(\)/);
  assert.match(checkpointBody, /Feature\.dataGet\(\{ "Settings", "Checkpoint" \}, nil\)/);
  assert.match(checkpointBody, /Remote\.fire\("Checkpoint"\)/);

  const waveTabBody = source.match(/Feature\.startLoop\("autoStartWave"[\s\S]*?\n\s*end\)/)?.[0] ?? "";
  assert.match(waveTabBody, /Feature\.autoStartWaveStep/);
  assert.doesNotMatch(waveTabBody, /function\(\)\s*Remote\.fire\("StartWave"\)\s*end/);
  assert.match(source, /UI\.toggle\(controls, "Start Highest Wave"/);
  assert.doesNotMatch(source, /UI\.toggle\(controls, "Auto Skip"/);
});
