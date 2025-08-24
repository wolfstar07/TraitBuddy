TB_Helpers = ZO_Object:Subclass()

function TB_Helpers:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_Helpers:Initialize(parent)
	self.parent = parent
	self:Create()
end

function TB_Helpers:CheckMarkForResearch(c, craftingSkillType, researchLineIndex, traitIndex)
  return c.markForResearch[craftingSkillType][researchLineIndex][traitIndex]
end

function TB_Helpers:SetCharacterResearchComplete(c, craftingSkillType, researchLineIndex, traitIndex, flag)
	c.research[craftingSkillType][researchLineIndex][traitIndex] = nil
  c.research[craftingSkillType][researchLineIndex][traitIndex] = flag
  return c
end

function TB_Helpers:SetCharacterResearchActive(c, craftingSkillType, researchLineIndex, traitIndex, research)
	c.research[craftingSkillType][researchLineIndex][traitIndex] = { duration = durationSecs, done = whenDoneTimeStamp }
  return c
end

function TB_Helpers:InitializeChars()
	local craftingSkillTypes = TraitBuddy:GetCraftingSkillTypes()
  for id,c in pairs(TraitBuddy.settings.characters) do
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
			for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
				c.research[craftingSkillType][researchLineIndex] = c.research[craftingSkillType][researchLineIndex] or {}
				c.markForResearch[craftingSkillType][researchLineIndex] = c.markForResearch[craftingSkillType][researchLineIndex] or {}
				local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
				c.research[craftingSkillType][researchLineIndex].Name = nil
				for traitIndex = 1, numTraits do
					c.research[craftingSkillType][researchLineIndex][traitIndex] = c.research[craftingSkillType][researchLineIndex][traitIndex] or false
					c.markForResearch[craftingSkillType][researchLineIndex][traitIndex] = (not c.research[craftingSkillType][researchLineIndex][traitIndex] and c.markForResearch[craftingSkillType][researchLineIndex][traitIndex]) or false
				end
			end
		end

		c.motifs = c.motifs or {}
		if c.motifs[38] == nil then --v4.2 Housing moved Draugr to 38
			c.motifs[38] = c.motifs[37]
		end
		if c.motifs[53.1] then --v7.4 Refabricated Motif correctly placed at 79
			c.motifs[79] = c.motifs[53.1]
			c.motifs[53.1] = nil
		end
		local numChapters = TraitBuddy.data:GetNumChapters()
		for itemStyleIndex = 1, GetNumValidItemStyles() do
			local itemStyleId = GetValidItemStyleId(itemStyleIndex)
			if itemStyleId > 0 then
				local motif = TraitBuddy.data:GetMotifByItemStyleId(itemStyleId)
				if motif then
					local order = motif:Order()
					if motif:HasChapters() then
						c.motifs[order] = c.motifs[order] or {}
						for chapter = 1, numChapters do
							c.motifs[order][chapter] = c.motifs[order][chapter] or false
						end
					else
						if type(c.motifs[order]) == "table" then
							local temp = c.motifs[order][1] --changed grim harlequin v3.6
							c.motifs[order] = nil
							c.motifs[order] = temp
						end
						c.motifs[order] = c.motifs[order] or false
					end
				end
			end
		end
	end
end

function TB_Helpers:IsTraitBeingResearched(character, craftingSkillType, researchLineIndex, traitIndex)
	if character and craftingSkillType and researchLineIndex and traitIndex then
		if craftingSkillType>0 and researchLineIndex>0 and traitIndex>0 then
			return (type(character.research[craftingSkillType][researchLineIndex][traitIndex])=="table")
		end
	end
	return false
end

function TB_Helpers:IsTraitKnown(character, craftingSkillType, researchLineIndex, traitIndex)
	if character and craftingSkillType and researchLineIndex and traitIndex then
		if craftingSkillType>0 and researchLineIndex>0 and traitIndex>0 then
			if self:IsTraitBeingResearched(character, craftingSkillType, researchLineIndex, traitIndex)==false then
				return character.research[craftingSkillType][researchLineIndex][traitIndex]
			end
		end
	end
	return false
end

function TB_Helpers:UpdateResearching()
	--Update any traits which were researching that have now finished
	local updateUI = false
	local nextTimeRemainingSecs = nil
	local craftingSkillTypes = TraitBuddy:GetCraftingSkillTypes()
	for id,c in pairs(TraitBuddy:GetCharacters()) do
		for _,craftingSkillType in pairs(craftingSkillTypes) do
			for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
				local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
				for traitIndex = 1, numTraits do
					if self:IsTraitBeingResearched(c, craftingSkillType, researchLineIndex, traitIndex) then
						local now = GetTimeStamp()
						local timeRemainingSecs = GetDiffBetweenTimeStamps(c.research[craftingSkillType][researchLineIndex][traitIndex].done, now)
						if timeRemainingSecs <= 0 then
							local key = sf("c%dr%dt%d", craftingSkillType, researchLineIndex, traitIndex)
							c.completed = c.completed or {}
							c.completed[key] = {
								craftingSkillType=craftingSkillType,
								researchLineIndex=researchLineIndex,
								traitIndex=traitIndex
							}
							self:SetCharacterResearchComplete(c, craftingSkillType, researchLineIndex, traitIndex, true)
							updateUI = true
						else
							if nextTimeRemainingSecs == nil then
								nextTimeRemainingSecs = timeRemainingSecs
							else
								if timeRemainingSecs < nextTimeRemainingSecs then
									nextTimeRemainingSecs = timeRemainingSecs
								end
							end
						end
					end
				end
			end
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

	--When to update research again
	if nextTimeRemainingSecs then
		local ms = nextTimeRemainingSecs*1000
		zo_callLater(function() self:UpdateResearching() end, ms)
	end
end