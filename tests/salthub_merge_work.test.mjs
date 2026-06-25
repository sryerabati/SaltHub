import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const sourcePath = new URL("../salthub.lua", import.meta.url);

test("target merge waits for selected placement before merging duplicates onto its actual cell", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.match(source, /function Feature\.waitForPlacedUnitModel/);
  assert.match(source, /function Feature\.getPlacedModelCell/);
  assert.match(source, /function Feature\.waitForMergeCell/);
  assert.match(source, /Feature\.getPlacedModelCell\(model\)/);
  assert.match(source, /local mergeCell = Feature\.waitForMergeCell\(plan\.target, plan\.cell\)/);
  assert.match(source, /Feature\.placeUnitForMerge\(plan\.units\[index\], mergeCell\)/);
  assert.doesNotMatch(source, /Feature\.placeUnitForMerge\(plan\.units\[index\], plan\.cell\)/);
});

test("target merge cascades lower-level duplicates through the selected family plan", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const mergeSelectedTarget = source.match(/function Feature\.mergeSelectedTarget\(\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /function Feature\.unitMergeLevel/);
  assert.match(source, /function Feature\.mergeMutationKey/);
  assert.match(source, /function Feature\.getMergeFamilyUnits/);
  assert.match(source, /function Feature\.findMergeFodderAtLevel/);
  assert.match(source, /function Feature\.mergeUnitsOnCell/);
  assert.match(source, /function Feature\.mergeFodderIntoPlacedAnchor/);
  assert.match(source, /function Feature\.buildFodderForMergeLevel/);
  assert.match(source, /function Feature\.executeTargetMergeCascade/);
  assert.match(source, /Feature\.buildFodderForMergeLevel\(target, targetLevel, usedIds, depth \+ 1, seedLevel\)/);
  assert.match(source, /Feature\.mergeFodderIntoPlacedAnchor\(target, fodder, targetCell\)/);
  assert.match(mergeSelectedTarget, /local familyKey = Feature\.mergeFamilyKey\(selected\)/);
  assert.match(mergeSelectedTarget, /Feature\.getDuplicateMergePlanForFamily\(familyKey, ignoredKeys\)/);
  assert.match(mergeSelectedTarget, /Feature\.executeTargetMergeCascade\(plan\.target\)/);
  assert.doesNotMatch(mergeSelectedTarget, /Feature\.executeTargetMergeCascade\(selected\)/);
});

test("cascade builds higher-level fodder from the starting level instead of consuming pre-existing higher-level units", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const buildFodderForMergeLevel = source.match(/function Feature\.buildFodderForMergeLevel\(target, level, usedIds, depth, directLevelLimit\)[\s\S]*?\nend/)?.[0] ?? "";
  const executeTargetMergeCascade = source.match(/function Feature\.executeTargetMergeCascade\(selected\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(buildFodderForMergeLevel, /if level <= directLevelLimit then\s+local direct = Feature\.findMergeFodderAtLevel/);
  assert.match(buildFodderForMergeLevel, /Feature\.buildFodderForMergeLevel\(target, level - 1, usedIds, depth \+ 1, directLevelLimit\)/);
  assert.match(executeTargetMergeCascade, /local seedLevel = Feature\.unitMergeLevel\(target\)/);
});

test("placed-anchor target merge waits for place cooldown before dropping fodder", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const mergeFodderIntoPlacedAnchor = source.match(/function Feature\.mergeFodderIntoPlacedAnchor\(anchor, fodder, cell\)[\s\S]*?\nend/)?.[0] ?? "";
  const waitForUnitLevel = source.match(/function Feature\.waitForUnitLevel\(unit, expectedLevel, timeout\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(mergeFodderIntoPlacedAnchor, /task\.wait\(math\.max\(Config\.safety\.remoteCooldown, 0\.12\)\)/);
  assert.match(mergeFodderIntoPlacedAnchor, /Feature\.placeUnitForMerge\(fodder, mergeCell\)/);
  assert.match(mergeFodderIntoPlacedAnchor, /Feature\.cleanupFailedMergeAttempt\(anchor, fodder, true\)/);
  assert.match(waitForUnitLevel, /return nil/);
  assert.doesNotMatch(waitForUnitLevel, /return Feature\.refreshMergeTarget\(unit\)/);
});

test("merge family compares normalized mutation so none stays separate from gold or arrancar", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const mergeFamilyKey = source.match(/function Feature\.mergeFamilyKey\(unit\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /function Feature\.mergeMutationKey/);
  assert.match(source, /if clean == "" or clean == "none" or clean == "normal" then\s+return "none"\s+end/);
  assert.match(mergeFamilyKey, /Feature\.mergeMutationKey\(unit and unit\.mutation\)/);
});

test("placed fighter scanning keeps previous mutation when placed model has no mutation attribute", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const scanUnits = source.match(/function State\.scanUnits\(\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /local function readUnitMutation/);
  assert.match(scanUnits, /local existing = byId\[id\]/);
  assert.match(scanUnits, /mutation = readUnitMutation\(model, existing and existing\.mutation or "None"\)/);
});

test("merge placement uses the real placement shape payload and waits for server acceptance", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const placeUnitForMerge = source.match(/function Feature\.placeUnitForMerge\(unit, cell\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(placeUnitForMerge, /Feature\.getMergePlacement\(unit, cell\)/);
  assert.match(placeUnitForMerge, /remote\.OnClientEvent:Connect/);
  assert.match(placeUnitForMerge, /ShapeName = placement\.shapeName/);
  assert.match(placeUnitForMerge, /ShapeCFrame = placement\.shapeCFrame/);
  assert.doesNotMatch(placeUnitForMerge, /ShapeName = unit\.name/);
});

test("auto duplicate merge can start from inventory without a pre-placed anchor", () => {
  const source = fs.readFileSync(sourcePath, "utf8");

  assert.doesNotMatch(source, /#group >= 2 and \(selectedOnly or Feature\.groupHasPlacedAnchor\(group\)\)/);
  assert.doesNotMatch(source, /Merge needs at least one duplicate already placed on the grid/);
  assert.match(source, /cell = Feature\.findMergePlacementCell\(bestGroup\[1\], cell\)/);
});

test("auto merge skips duplicate groups that do not have a placement shape", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const getMergeCandidates = source.match(/function Feature\.getMergeCandidates\(selected\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(getMergeCandidates, /Feature\.getShapeFootprint\(unit\.name\)/);
  assert.match(getMergeCandidates, /if Feature\.getShapeFootprint\(unit\.name\) then/);
});

test("auto merge retries the next duplicate group when one group cannot be placed", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const autoMergeStep = source.match(/function Feature\.autoMergeStep\(\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /function Feature\.getDuplicateMergePlan\(selectedOnly, ignoredKeys\)/);
  assert.match(source, /function Feature\.getDuplicateMergePlanForFamily\(familyKey, ignoredKeys\)/);
  assert.match(source, /failedKeys = \{\}/);
  assert.match(autoMergeStep, /pending\.failedKeys\[plan\.key\] = failures/);
  assert.match(autoMergeStep, /if failures >= 3 then[\s\S]*pending\.ignoredKeys\[plan\.key\] = true/);
  assert.match(autoMergeStep, /pending\.ignoredKeys\[plan\.key\] = true/);
  assert.match(autoMergeStep, /Feature\.getDuplicateMergePlanForFamily\(pending\.familyKey, pending\.ignoredKeys\)/);
  assert.doesNotMatch(autoMergeStep, /Feature\.getDuplicateMergePlan\(false, ignoredKeys\)/);
});

test("auto merge keeps one character active until its mutation families are exhausted", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const autoMergeStep = source.match(/function Feature\.autoMergeStep\(\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /function Feature\.findNextAutoMergeFamily\(characterName, ignoredFamilies, ignoredCharacters\)/);
  assert.match(autoMergeStep, /pending\.characterName/);
  assert.match(autoMergeStep, /pending\.familyKey/);
  assert.match(autoMergeStep, /Feature\.findNextAutoMergeFamily\(pending\.characterName, pending\.ignoredFamilies\)/);
  assert.match(autoMergeStep, /Feature\.pickupAutoMergeBoardUnits\(pending\.characterName\)/);
});

test("auto merge stops after sweep instead of repeated heavy rescans", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const autoMergeStep = source.match(/function Feature\.autoMergeStep\(\)[\s\S]*?\nend/)?.[0] ?? "";
  const finishAutoMergeSweep = source.match(/function Feature\.finishAutoMergeSweep\(\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /mergeIdle = 2\.5/);
  assert.match(source, /autoMergeIdleUntil = 0/);
  assert.match(autoMergeStep, /State\.autoMergeIdleUntil/);
  assert.match(autoMergeStep, /Feature\.finishAutoMergeSweep\(\)/);
  assert.match(finishAutoMergeSweep, /Feature\.toggleAutoMerge\(false\)/);
  assert.doesNotMatch(autoMergeStep, /State\.autoMergeIdleUntil = now \+ \(tonumber\(Config\.delays\.mergeIdle\) or 2\.5\)/);
});

test("merge placement scans beyond the first free cell for shapes that need neighbors", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const findMergePlacementCell = source.match(/function Feature\.findMergePlacementCell\(unit, preferredCell\)[\s\S]*?\nend/)?.[0] ?? "";
  const getDuplicateMergePlan = source.match(/function Feature\.getDuplicateMergePlan\(selectedOnly, ignoredKeys\)[\s\S]*?\nend/)?.[0] ?? "";
  const buildFodderForMergeLevel = source.match(/function Feature\.buildFodderForMergeLevel\(target, level, usedIds, depth, directLevelLimit\)[\s\S]*?\nend/)?.[0] ?? "";
  const executeTargetMergeCascade = source.match(/function Feature\.executeTargetMergeCascade\(selected\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /function Feature\.findMergePlacementCell\(unit, preferredCell\)/);
  assert.match(source, /occupiedCellNames = occupiedCells/);
  assert.match(findMergePlacementCell, /Feature\.getMergePlacement\(unit, cell\)/);
  assert.match(findMergePlacementCell, /Feature\.placementCellsAvailable\(placement, occupancy\)/);
  assert.match(getDuplicateMergePlan, /cell = Feature\.findMergePlacementCell\(bestGroup\[1\], cell\)/);
  assert.match(buildFodderForMergeLevel, /local cell = Feature\.findMergePlacementCell\(first, Feature\.findFreeGridCell\(\)\)/);
  assert.match(executeTargetMergeCascade, /targetCell = Feature\.findMergePlacementCell\(target, targetCell\)/);
});

test("merge reuses the valid shape anchor when placed model cells include invalid anchors", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const getMergeAnchorCell = source.match(/function Feature\.getMergeAnchorCell\(selected, group\)[\s\S]*?\nend/)?.[0] ?? "";
  const waitForMergeCell = source.match(/function Feature\.waitForMergeCell\(unit, fallbackCell\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /function Feature\.getPlacedModelCellNames\(model\)/);
  assert.match(source, /function Feature\.sameCellNameSet\(left, right\)/);
  assert.match(source, /function Feature\.resolveMergeAnchorCell\(unit, candidateCell, requiredCellNames\)/);
  assert.match(source, /Feature\.sameCellNameSet\(placement\.occupiedCellNames, requiredCellNames\)/);
  assert.match(getMergeAnchorCell, /local placedCellNames = Feature\.getPlacedModelCellNames\(model\)/);
  assert.match(getMergeAnchorCell, /Feature\.resolveMergeAnchorCell\(unit, placedCell, placedCellNames\)/);
  assert.match(waitForMergeCell, /Feature\.resolveMergeAnchorCell\(unit, fallbackCell, placedCellNames\)/);
  assert.match(waitForMergeCell, /Feature\.resolveMergeAnchorCell\(unit, placedCell, placedCellNames\)/);
  assert.doesNotMatch(waitForMergeCell, /return cell or fallbackCell/);
});

test("selected merge target picker only lists real mergeable units", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const isMergeSelectableTarget = source.match(/function Feature\.isMergeSelectableTarget\(unit\)[\s\S]*?\nend/)?.[0] ?? "";
  const getSelectedMergeUnit = source.match(/function Feature\.getSelectedMergeUnit\(\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /function Feature\.getMergeSelectableUnits/);
  assert.match(isMergeSelectableTarget, /tostring\(unit\.level or ""\) == "\?"/);
  assert.match(isMergeSelectableTarget, /Feature\.getShapeFootprint\(unit\.name\)/);
  assert.match(getSelectedMergeUnit, /Feature\.isMergeSelectableTarget\(selected\)/);
  assert.match(source, /UI\.inventoryUnitSelector\(page, "Selected Merge Target", function\(\)\s+return Feature\.getMergeSelectableUnits\(\)/);
});

test("auto duplicate merge uses cascade instead of dumping every same-level unit onto the first anchor", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const autoMergeStep = source.match(/function Feature\.autoMergeStep\(\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(autoMergeStep, /Feature\.executeTargetMergeCascade\(plan\.target\)/);
  assert.doesNotMatch(autoMergeStep, /Feature\.executeMergePlan\(plan\)/);
});

test("auto merge stops at configured max merge level", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const isMergeSelectableTarget = source.match(/function Feature\.isMergeSelectableTarget\(unit\)[\s\S]*?\nend/)?.[0] ?? "";
  const getMergeCandidates = source.match(/function Feature\.getMergeCandidates\(selected\)[\s\S]*?\nend/)?.[0] ?? "";
  const executeTargetMergeCascade = source.match(/function Feature\.executeTargetMergeCascade\(selected\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(source, /maxLevel = 7/);
  assert.match(source, /function Feature\.maxMergeLevel/);
  assert.match(isMergeSelectableTarget, /Feature\.unitMergeLevel\(unit\) >= Feature\.maxMergeLevel\(\)/);
  assert.match(getMergeCandidates, /Feature\.unitMergeLevel\(unit\) < Feature\.maxMergeLevel\(\)/);
  assert.match(executeTargetMergeCascade, /local maxMergeLevel = Feature\.maxMergeLevel\(\)/);
  assert.match(executeTargetMergeCascade, /if targetLevel >= maxMergeLevel then/);
  assert.match(executeTargetMergeCascade, /Target merge complete: level "\s*\.\.\s*tostring\(targetLevel\)\s*\.\.\s*" is max\./);
});

test("placed model lookup does not pick up a same-name model when the unit id is known", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const findPlacedUnitModel = source.match(/function Feature\.findPlacedUnitModel\(unit\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(findPlacedUnitModel, /for _, containerName in ipairs\(\{ "Characters", "Fighters", "PlacedCharacters", "Builds" \}\) do/);
  assert.match(findPlacedUnitModel, /isPlacedUnitModel\(model, containerName\) and Feature\.unitIdMatchesInstance\(unit, model\)/);
  assert.match(findPlacedUnitModel, /if tostring\(unit\.id or ""\) ~= "" then\s+return nil\s+end/);
});

test("merge target refresh can follow upgraded placed models outside the Characters folder", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const refreshMergeTarget = source.match(/function Feature\.refreshMergeTarget\(target\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(refreshMergeTarget, /local model = Feature\.findPlacedUnitModel\(target\)/);
  assert.match(refreshMergeTarget, /level = tostring\(readAttr\(model, \{ "Level", "Lvl" \}/);
  assert.match(refreshMergeTarget, /mutation = readUnitMutation\(model, refreshed\.mutation or "None"\)/);
});

test("unit scanning includes placed fighters so auto merge can continue from board state", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const scanUnits = source.match(/function State\.scanUnits\(\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(scanUnits, /for _, containerName in ipairs\(\{ "Characters", "Fighters", "PlacedCharacters", "Builds" \}\) do/);
  assert.match(scanUnits, /isPlacedUnitModel\(model, containerName\)/);
  assert.match(scanUnits, /placed = true/);
  assert.match(scanUnits, /instance = model/);
});

test("merge fodder selection prefers inventory units before placed board units", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const getMergeFamilyUnits = source.match(/function Feature\.getMergeFamilyUnits\(target\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(getMergeFamilyUnits, /local placedA = a\.placed == true/);
  assert.match(getMergeFamilyUnits, /if placedA ~= placedB then\s+return not placedA\s+end/);
});

test("tool lookup does not equip a same-name different-mutation duplicate when the unit id is known", () => {
  const source = fs.readFileSync(sourcePath, "utf8");
  const findUnitTool = source.match(/function Feature\.findUnitTool\(unit\)[\s\S]*?\nend/)?.[0] ?? "";

  assert.match(findUnitTool, /if Feature\.unitIdMatchesInstance\(unit, child\) then\s+return child\s+end/);
  assert.match(findUnitTool, /if tostring\(unit\.id or ""\) == "" and child\.Name == unit\.name then\s+return child\s+end/);
  assert.doesNotMatch(findUnitTool, /Feature\.unitIdMatchesInstance\(unit, child\) or child\.Name == unit\.name/);
});
