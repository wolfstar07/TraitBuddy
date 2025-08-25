TB_HelpersObject = ZO_Object:Subclass()

function TB_HelpersObject:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

local function GetCharacterBitwise()
  local characterList = {}
  for i = 1, GetNumCharacters() do
      local name, _, _, _, _, backupId, id = GetCharacterInfo(i)
      characterList[id or backupId] = 2^(i-1)
  end
  return characterList
end

local function charBitMissing(trait, mask)
  -- Indicates that character bit needs to be set or is missing (as in the case of not researched)
  -- trait is the integer bitmask
  -- mask is the power-of-two flag for the character (e.g., 1, 2, 4, 8, ...)
  return (trait % (mask*2)) < mask
end

local function addCharBit(traitTable, key, charBitId)
  if key and not traitTable[key] then
    traitTable[key] = 0
  end
  if key and charBitMissing(traitTable[key], charBitId) then
    traitTable[key] = traitTable[key] + charBitId
  end
end

function TB_HelpersObject:sortTraitsByDone(characters)
  local unsorted = {}
  local sorted = {}
  local counters = {}
  local now = GetTimeStamp()
  for id,c in pairs(characters) do
    if c.research.indexed then
      for k, v in pairs(c.research.indexed) do
        counters[id] = (counters[id] or 0) + 1
        table.insert(unsorted[id],{ key = k, duration = v.duration, done = v.done})
      end
    end
  end
  if #unsorted > 0 then
    for id,c in pairs(characters) do
      sorted[id] = table.sort(unsorted[id], function(a,b)
        return a.done < b.done
      end)
    end
  end
  self.activeResearchCount, self.orderedResearch = counters, sorted
end

function TB_HelpersObject:Initialize(parent)
	self.parent = parent
	self.bitwiseChars = GetCharacterBitwise()
end

local function getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
	if craftingSkillType == nil or researchLineIndex == nil or traitIndex == nil then return end
	return craftingSkillType * 10000 + researchLineIndex * 100 + traitIndex
end

local function setCharacterResearchCompleteWithKey(traitTable, c, key)
	local charBitId = self.bitwiseChars[c.id]
	local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
	addCharBit(traitTable, key, charBitId)
end

function TB_HelpersObject:CheckMarkForResearch(c, craftingSkillType, researchLineIndex, traitIndex)
  return
end

function TB_HelpersObject:SetCharacterResearchComplete(c, craftingSkillType, researchLineIndex, traitIndex, flag, traitTable)
	if flag then
    local charBitId = self.bitwiseChars[c.id]
    local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
    addCharBit(traitTable, key, charBitId)
	end
end

function TB_HelpersObject:SetCharacterResearchActive(c, craftingSkillType, researchLineIndex, traitIndex, research)
  local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
  if not c.research.indexed then
    c.research.indexed = {}
  end
	c.research.indexed[key] = research
	return c
end

function TB_HelpersObject:StopCharActiveResearch(c, craftingSkillType, researchLineIndex, traitIndex)
  local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
  if not c.research.indexed then
    c.research.indexed = {}
  end
	c.research.indexed[key] = nil
	return c
end

function TB_HelpersObject:InitializeChars(characters)
  local craftingSkillTypes = TraitBuddy:GetCraftingSkillTypes()
  for id,c in pairs(characters) do
		c.markForResearch = c.markForResearch or {}
		if type(c.show) == "boolean" then --show changed v4.0
			local oldShow = c.show
			c.show = {
				bs = oldShow,
				cl = oldShow,
				ww = oldShow,
				motif = oldShow
			}
		end
		if c.show.je == nil then --added v5.9 Summerset
			c.show.je = true
		end
		for _,craftingSkillType in pairs(craftingSkillTypes) do
			c.research[craftingSkillType] = c.research[craftingSkillType] or {}
			c.research[craftingSkillType].MaxSimultaneousResearch = c.research[craftingSkillType].MaxSimultaneousResearch or 1
			c.markForResearch[craftingSkillType] = c.markForResearch[craftingSkillType] or {}
    end
  end
end

function TB_HelpersObject:IsTraitBeingResearched(character, craftingSkillType, researchLineIndex, traitIndex)
	if character and craftingSkillType and researchLineIndex and traitIndex then
		if craftingSkillType>0 and researchLineIndex>0 and traitIndex>0 then
		  local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
		  if character.research.indexed then
			  return (type(character.research.indexed[key])=="table")
			end
		end
	end
	return false
end

function TB_HelpersObject:IsTraitKnown(character, craftingSkillType, researchLineIndex, traitIndex, traitTable)
	local charBitId = self.bitwiseChars[character.id]
	if character and craftingSkillType and researchLineIndex and traitIndex then
		if craftingSkillType>0 and researchLineIndex>0 and traitIndex>0 then
		  local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
		  if traitTable and traitTable[key] then
			  return not charBitMissing(traitTable[key], charBitId)
			end
		end
	end
	return false
end

function TB_HelpersObject:setActiveResearch(c, now, traitTable)
  if next(self.orderedResearch) then
    local index, researchObj = next(self.orderedResearch[c.id])
    local traitKey, activeResearchObj = next(researchObj)
    if activeResearchObj then
      local timeRemainingSecs = GetDiffBetweenTimeStamps(activeResearchObj.done, now)
      if timeRemainingSecs <= 0 then
        setCharacterResearchCompleteWithKey(c, traitKey, traitTable)
        c.research.indexed[traitKey] = nil
        table.remove(self.orderedResearch[c.id], index)
      end
      self:setActiveResearch(c, now, index)
    end
  end
  return c
end

function TB_HelpersObject:UpdateResearching(characters, traitTable)
  local updateUI = false
	local nextTimeRemainingSecs = nil
	local researchObj
	local key
	local activeResearchObj
  local now = GetTimeStamp()
  local modified_c
  if characters and next(characters) then
    self:sortTraitsByDone(characters)
    for id,c in pairs(characters) do
      --get the first item only in research for each character
      modified_c = self:setActiveResearch(c, now, traitTable)
      if c ~= modified_c then
        updateUI = true
      end
    end
	end
  return updateUI
end
