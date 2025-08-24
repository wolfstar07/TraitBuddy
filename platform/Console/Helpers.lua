TB_Helpers = ZO_Object:Subclass()

function TB_Helpers:New(...)
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

local function addCharBit(key, charBitId)
  if key and not TraitBuddy.settings.traitTable[key] then
    TraitBuddy.settings.traitTable[key] = 0
  end
  if key and charBitMissing(TraitBuddy.settings.traitTable[key], charBitId) then
    TraitBuddy.settings.traitTable[key] = TraitBuddy.settings.traitTable[key] + charBitId
  end
end

local function sortTraitsByDone()
  local unsorted = {}
  local sorted = {}
  local counters = {}
  local now = GetTimeStamp()
  for id,c in pairs(TraitBuddy:GetCharacters()) do
    for k, v in pairs(c.research.indexed) do
      counters[id] = (counters[id] or 0) + 1
      table.insert(unsorted[id],{ key = k, duration = v.duration, done = v.done})
    end
  end
  for id,c in pairs(TraitBuddy:GetCharacters()) do
    sorted[id] = table.sort(unsorted[id], function(a,b)
      return a.done < b.done
    end)
  end
  return counters, sorted
end

function TB_Helpers:Initialize(parent)
	self.parent = parent
	self.bitwiseChars = GetCharacterBitwise()
	self.activeResearchCount, self.orderedResearch = sortTraitsByDone()
	self:Create()
end

local function getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
	if craftingSkillType == nil or researchLineIndex == nil or traitIndex == nil then return end
	return craftingSkillType * 10000 + researchLineIndex * 100 + traitIndex
end

local function setCharacterResearchCompleteWithKey(c, key)
	local charBitId = self.bitwiseChars[c.id]
	local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
	addCharBit(key, charBitId)
end

function TB_Helpers:CheckMarkForResearch(c, craftingSkillType, researchLineIndex, traitIndex)
  return
end

function TB_Helpers:SetCharacterResearchComplete(c, craftingSkillType, researchLineIndex, traitIndex, flag)
	local charBitId = self.bitwiseChars[c.id]
	local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
	addCharBit(key, charBitId)
end

function TB_Helpers:SetCharacterResearchActive(c, craftingSkillType, researchLineIndex, traitIndex, research)
  local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
  if not c.research.indexed then
    c.research.indexed = {}
  end
	c.research.indexed[key] = research
	return c
end

function TB_Helpers:InitializeChars()
  return
end

function TB_Helpers:IsTraitBeingResearched(character, craftingSkillType, researchLineIndex, traitIndex)
	if character and craftingSkillType and researchLineIndex and traitIndex then
		if craftingSkillType>0 and researchLineIndex>0 and traitIndex>0 then
		  local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
			return (type(character.research.indexed[key])=="table")
		end
	end
	return false
end

function TB_Helpers:IsTraitKnown(character, craftingSkillType, researchLineIndex, traitIndex)
	local charBitId = self.bitwiseChars[character.id]
	if character and craftingSkillType and researchLineIndex and traitIndex then
		if craftingSkillType>0 and researchLineIndex>0 and traitIndex>0 then
		  local key = getTraitKey(craftingSkillType, researchLineIndex, traitIndex)
			return not charBitMissing(TraitBuddy.settings.traitTable[key], charBitId)
		end
	end
	return false
end

local function setActiveResearch(c, now)
  local index, researchObj = next(self.orderedResearch[c.id])
  local traitKey, activeResearchObj = next(researchObj)
  if activeResearchObj then
    local timeRemainingSecs = GetDiffBetweenTimeStamps(activeResearchObj.done, now)
    if timeRemainingSecs <= 0 then
      setCharacterResearchCompleteWithKey(c, traitKey)
      c.research.indexed[traitKey] = nil
      table.remove(self.orderedResearch[c.id], index)
    end
    setActiveResearch(c, now, index)
  end
  return c
end

function TB_Helpers:UpdateResearching()
  local updateUI = false
	local nextTimeRemainingSecs = nil
	local researchObj
	local key
	local activeResearchObj
  local now = GetTimeStamp()
  local modified_c
	for id,c in pairs(TraitBuddy:GetCharacters()) do
	  --get the first item only in research for each character
    modified_c = setActiveResearch(c, now)
    TraitBuddy:SetCharacter(id, modified_c)
    if c ~= modified_c then
      updateUI = true
    end
	end
  if TraitBuddy.ui.updatelater:IsUpdating() then
		updateUI = false
	end
	if updateUI then
		if TraitBuddy.ui:IsCreated() then
			TraitBuddy.ui.research:UpdateUI()
		else
			TraitBuddy.ui.updatelater:UpdateResearchUI()
		end
	end
end
