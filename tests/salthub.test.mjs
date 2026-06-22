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
  assert.doesNotMatch(source, /"Detected Podium"/);
  assert.match(source, /unitMutationTargets = \{\}/);
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
  assert.match(toggleBody, /Feature\.stopLoop\("autoRoll"\)/);
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
  assert.match(source, /rangeWeight = 0\.08/);
  assert.match(source, /cooldownWeight = 3/);
  assert.match(source, /rarityWeight = 3/);
  assert.match(source, /rngWeight = 0\.01/);
  assert.match(source, /footprintPenalty = 0\.035/);
  assert.match(source, /beamWidth = 32/);
  assert.match(source, /candidateLimit = 64/);
  assert.match(source, /dpsCandidateLimit = 48/);
  assert.match(source, /densityCandidateLimit = 32/);
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
  assert.match(source, /function Feature\.computeUnitDerivedStats/);
  assert.match(source, /function Feature\.getCurrentGridModel/);
  assert.match(source, /Feature\.dataGet\("GridLevel"/);
  assert.match(source, /function Feature\.buildGridCells/);
  assert.match(source, /function Feature\.getShapeFootprint/);
  assert.match(source, /function Feature\.getShapeOccupiedCellNames/);
  assert.match(source, /function Feature\.refreshPlacementOccupancy/);
  assert.match(source, /function Feature\.scoreLineupUnit/);
  assert.match(source, /function Feature\.findBestLineupPlacement/);
  assert.match(source, /function Feature\.ensureBestLineupData/);
  assert.match(source, /function Feature\.buildBestLineupBeamPlan/);
  assert.match(source, /function Feature\.buildBestLineupCandidates/);
  assert.match(source, /function Feature\.prepareBestLineupCandidatePlacements/);
  assert.match(source, /function Feature\.getBestLineupPlanFromEmptyGrid/);
  assert.match(source, /function Feature\.pickupBestLineupUnits/);
  assert.match(source, /function Feature\.getBestLineupPlan/);
  assert.match(source, /function Feature\.placeBestLineup/);
  assert.match(source, /remote\.OnClientEvent:Connect/);
  assert.match(source, /Feature\.pickupBestLineupUnits\(\)/);
  assert.match(source, /Feature\.placeUnitForMerge\(item\.unit, item\.placement\.cell\)/);
  assert.match(source, /ShapeName = item\.placement\.shapeName/);
  assert.match(source, /HoveredCellName = item\.placement\.hoveredCellName/);
  assert.match(source, /ShapeCFrame = item\.placement\.shapeCFrame/);
  assert.match(source, /offsets = offsets/);
  assert.match(source, /Feature\.getCellByOffset/);
  assert.match(source, /1 \/ math\.max\(derived\.cooldown/);
  assert.doesNotMatch(source, /- derived\.cooldown \* \(tonumber\(Config\.bestLineup\.cooldownWeight\)/);
  assert.match(source, /derived\.dps > b\.derived\.dps/);
  assert.match(source, /candidate\.placementOptions/);
  const planBody = source.match(/function Feature\.getBestLineupPlan\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(planBody, /State\.loadSharedInfo\(\)/);
  assert.match(planBody, /Feature\.ensureBestLineupData\(\)/);
  assert.match(source, /"Place Best Lineup"/);
  assert.doesNotMatch(source, /function Feature\.placeBestLineup[\s\S]*?Remote\.fire\("AutoMergeToggle"/);
});

test("auto merge places the best trait unit first so its trait is preserved", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  const mergeStepBody = source.match(/function Feature\.autoMergeStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(source, /function Feature\.executeMergePlan/);
  assert.match(mergeStepBody, /Feature\.getDuplicateMergePlan\(false, ignoredKeys\)/);
  assert.match(mergeStepBody, /Feature\.executeTargetMergeCascade\(plan\.target\)/);
  assert.doesNotMatch(mergeStepBody, /Feature\.executeMergePlan\(plan\)/);
  assert.doesNotMatch(mergeStepBody, /pendingMerge/);
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

  assert.match(mergeFodderIntoPlacedAnchor, /task\.wait\(math\.max\(Config\.safety\.remoteCooldown, 0\.12\)\)/);
  assert.match(mergeFodderIntoPlacedAnchor, /Feature\.placeUnitForMerge\(fodder, mergeCell\)/);
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
  assert.match(findPlacedUnitModel, /Feature\.unitIdMatchesInstance\(unit, model\)/);
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
  assert.match(scanUnits, /placed = true/);
  assert.match(scanUnits, /instance = model/);
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
  assert.match(autoMergeStep, /local ignoredKeys = \{\}/);
  assert.match(autoMergeStep, /ignoredKeys\[plan\.key\] = true/);
  assert.match(autoMergeStep, /Feature\.getDuplicateMergePlan\(false, ignoredKeys\)/);
});

test("selected merge target is an explicit button action that preserves the best trait duplicate", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

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
  assert.match(source, /Feature\.executeTargetMergeCascade\(selected\)/);
  assert.match(source, /Config\.merge\.targetUnitId = unit\.id/);
  assert.match(source, /Config\.merge\.targetUnitName = unit\.name/);
  assert.match(source, /UI\.inventoryUnitSelector\(page, "Selected Merge Target"/);
  assert.match(source, /UI\.button\(main, "Merge Selected Target", Feature\.mergeSelectedTarget/);
});

test("settings export copies a reusable launch script with embedded preset", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /export = \{/);
  assert.match(source, /scriptUrl = "http:\/\/127\.0\.0\.1:16500\/salthub\.lua"/);
  assert.match(source, /function mergeConfig/);
  assert.match(source, /function applyPresetFromGlobal/);
  assert.match(source, /SaltHubPreset/);
  assert.match(source, /function Feature\.getSerializableConfig/);
  assert.match(source, /function Feature\.exportLaunchScript/);
  assert.match(source, /getgenv\(\)\.SaltHubPreset/);
  assert.match(source, /loadstring\(game:HttpGet\(Config\.export\.scriptUrl\)\)\(\)/);
  assert.match(source, /setclipboard\(scriptText\)/);
  assert.match(source, /"Copy Launch Script"/);
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

test("auto buhara reads wanted food and walks instead of blind dropping", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /buhara = \{/);
  assert.match(source, /foodNames = \{ "Steak", "Tomato", "Bread", "Cheese", "Lettuce" \}/);
  assert.match(source, /feedDistance = 1\.1/);
  assert.match(source, /scanInterval = 0\.65/);
  assert.match(source, /function Feature\.getBuharaData/);
  assert.match(source, /function Feature\.getBuharaWantedFoods/);
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
  assert.match(source, /Feature\.moveNearInstance\(drop\.instance, Config\.buhara\.foodCollectDistance, false\)/);
  assert.match(source, /local prompt = Feature\.getBuharaFeedPrompt\(target\)/);
  assert.match(source, /Feature\.moveToBuharaFeedPrompt\(target, prompt\)/);
  assert.match(source, /Feature\.holdPrompt\(prompt\)/);
  assert.match(source, /return not Feature\.isCarryingBuharaFood\(\)/);
  assert.match(source, /Feature\.startLoop\("autoBuhara"[\s\S]*Feature\.autoBuharaStep/);

  const buharaToggle = source.match(/function Feature\.toggleBuhara\(value\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(buharaToggle, /Remote\.fire\("BuharaDropFood"\)/);
  const feedBody = source.match(/function Feature\.feedBuhara\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.doesNotMatch(feedBody, /Remote\.fire\("BuharaDropFood"\)/);
  const buharaBody = source.match(/function Feature\.getBuharaData\(\)([\s\S]*?)function Feature\.toggleBuhara/)?.[1] ?? "";
  assert.doesNotMatch(buharaBody, /Feature\.teleportToInstance/);
  assert.doesNotMatch(buharaBody, /for _, instance in ipairs\(workspace:GetDescendants\(\)\) do[\s\S]*?local foodName = Feature\.getBuharaFoodName\(instance\)/);
});

test("buhara movement disables teleport fallback", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /local PathfindingService = game:GetService\("PathfindingService"\)/);
  assert.match(source, /function Feature\.followPathToPosition/);
  assert.match(source, /PathfindingService:CreatePath\(\{/);
  assert.match(source, /AgentCanJump = true/);
  assert.match(source, /Enum\.PathWaypointAction\.Jump/);
  assert.match(source, /humanoid\.Jump = true/);
  assert.match(source, /function Feature\.moveToCFrame\(targetCFrame, timeout, allowTeleportFallback\)/);
  assert.match(source, /Feature\.followPathToPosition\(targetPosition, maxWait\)/);
  assert.match(source, /allowTeleportFallback ~= false/);
  assert.match(source, /function Feature\.moveNearInstance\(instance, distance, allowTeleportFallback\)/);
  assert.match(source, /Feature\.moveToCFrame\(CFrame\.lookAt\(targetPosition, targetPart\.Position\), Config\.delays\.moveTimeout, allowTeleportFallback\)/);
});

test("auto start wave is gated by owned plot wave state", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.isWaveStarted/);
  assert.match(source, /function Feature\.shouldStartWave/);
  assert.match(source, /function Feature\.autoStartWaveStep/);
  assert.match(source, /plot:GetAttribute\("WaveStarted"\) == true/);
  assert.match(source, /State\.lastWaveStartAt/);
  assert.match(source, /os\.clock\(\) - \(State\.lastWaveStartAt or 0\)/);

  const stepBody = source.match(/function Feature\.autoStartWaveStep\(\)([\s\S]*?)\nend/)?.[1] ?? "";
  assert.match(stepBody, /if not Feature\.shouldStartWave\(\) then[\s\S]*?return/);
  assert.match(stepBody, /State\.lastWaveStartAt = os\.clock\(\)/);
  assert.match(stepBody, /Remote\.fire\("StartWave"\)/);

  const waveTabBody = source.match(/Feature\.startLoop\("autoStartWave"[\s\S]*?\n\s*end\)/)?.[0] ?? "";
  assert.match(waveTabBody, /Feature\.autoStartWaveStep/);
  assert.doesNotMatch(waveTabBody, /function\(\)\s*Remote\.fire\("StartWave"\)\s*end/);
});
