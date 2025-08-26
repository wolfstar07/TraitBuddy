local sf = string.format
local zo_str = zo_strformat
local zo_cachedstr = ZO_CachedStrFormat

CONTEXT_CHECK_LEFT = UI_SHORTCUT_PRIMARY
CONTEXT_CHECK_RIGHT = UI_SHORTCUT_SECONDARY
if not CONTEXT_CHECK_LEFT or not CONTEXT_CHECK_RIGHT then
  CONTEXT_CHECK_LEFT = MOUSE_BUTTON_INDEX_LEFT
  CONTEXT_CHECK_RIGHT = MOUSE_BUTTON_INDEX_RIGHT
end

--General ui functions and anything related to the traits
local function GetApparelData(craftingSkillType)
	local bar = nil
	if craftingSkillType == CRAFTING_TYPE_BLACKSMITHING then
		bar = TB_Apparel1ApparelBar
	elseif craftingSkillType == CRAFTING_TYPE_CLOTHIER then
		bar = TB_Apparel2ApparelBar
	elseif craftingSkillType == CRAFTING_TYPE_WOODWORKING then
		bar = TB_Apparel6ApparelBar
	elseif craftingSkillType == CRAFTING_TYPE_JEWELRYCRAFTING then
		return {
			label = GetString(SI_TRADINGHOUSECATEGORYHEADER8),
			descriptor = 0
		}
	end
	if bar then
		local descriptor = ZO_MenuBar_GetSelectedDescriptor(bar)
		if descriptor then
			local button = ZO_MenuBar_GetButtonControl(bar, descriptor)
			return ZO_MenuBarButtonTemplate_GetData(button)
		else
			--No button was chosen yet, select the first button, which will fire off the OnApparelSelect() again
			ZO_MenuBar_SelectDescriptor(bar, 1, true, false)
		end
	end
	return nil
end

local function OnApparelSelect(data)
	local craftingSkillType = CRAFTING_TYPE_BLACKSMITHING
	if not IsInGamepadPreferredMode() then
	  craftingSkillType = ZO_MenuBar_GetSelectedDescriptor(TraitBuddy.ui.menubar)
  else
    if data then
      craftingSkillType = data.craftingSkillType
    end
	end
	if data==nil then
		data = GetApparelData(craftingSkillType)
	end
	if data then
		TB_Apparel:SetText(data.label)
		TBCrafting1Weapons:SetHidden(not (craftingSkillType == CRAFTING_TYPE_BLACKSMITHING and data.descriptor == 1))
		TBCrafting1Armour:SetHidden(not (craftingSkillType == CRAFTING_TYPE_BLACKSMITHING and data.descriptor == 2))
		TBCrafting2Light:SetHidden(not (craftingSkillType == CRAFTING_TYPE_CLOTHIER and data.descriptor == 1))
		TBCrafting2Medium:SetHidden(not (craftingSkillType == CRAFTING_TYPE_CLOTHIER and data.descriptor == 2))
		TBCrafting6Weapons:SetHidden(not (craftingSkillType == CRAFTING_TYPE_WOODWORKING and data.descriptor == 1))
		TBCrafting6Shields:SetHidden(not (craftingSkillType == CRAFTING_TYPE_WOODWORKING and data.descriptor == 2))
	end
	TBCrafting7All:SetHidden(not (craftingSkillType == CRAFTING_TYPE_JEWELRYCRAFTING))
end

local function OnCraftSelect(data)
	TraitBuddy.ui:SelectCraft(data.label, data.descriptor)
end
local function OnMotifSelect(data)
	TraitBuddy.ui:SelectMotif(data.label)
end
local function OnResearchSelect(data)
	TraitBuddy.ui:SelectResearch(data.label)
end
local function OnSetsSelect(data)
	TraitBuddy.ui:SelectSets(data.label)
end

local function GetNumResearching(c, craftingSkillType)
  if next(TraitBuddy.helpers.activeResearchCount) then
    return TraitBuddy.helpers.activeResearchCount[c.id]
  end
	--How many traits is the selected character researching
	local numResearching = 0
	for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
		local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		for traitIndex = 1, numTraits do
			if TraitBuddy.helpers:IsTraitBeingResearched(c, craftingSkillType, researchLineIndex, traitIndex) then
				numResearching = numResearching + 1
			end
		end
	end
	return numResearching
end

TB_UI = ZO_Object:Subclass()

function TB_UI:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_UI:Initialize(parent)
	self.parent = parent
	self.created = false
	self.heading = self.parent:GetNamedChild("Heading")
	self.updatelater = TB_UpdateLater:New()
	self.selector = TB_CharacterSelector:New(self.parent:GetNamedChild("Alts"))
	self.research = TB_Research:New(self.parent:GetNamedChild("Research"))
	self.motifs = TB_Motifs:New(self.parent:GetNamedChild("Motifs"))
	self.settings = TB_Settings:New()
	self.parent:GetNamedChild("Title"):GetNamedChild("H1"):SetText(TraitBuddy.ADDON_NAME)
	self.launchers = {
		skills = TB_Launcher:New("skills"),
		smithing = TB_Launcher:New("smithing"),
		guildstore = TB_Launcher:New("guildstore")
	}
	self.mail = TB_Mail:New()
	self.inventory = TB_Inventory:New()
	self.inventoryInsight = TB_InventoryInsight:New()
	self.sets = TB_Sets:New(self.parent:GetNamedChild("Sets"))
	-- self.crafting = TB_Crafting:New()
end

function TB_UI:IsCreated()
	return self.created
end

function TB_UI:AddLinkToChat(tt, s)
	if s and s>0 then
		tt:AddVerticalPadding(s)
	end
	tt:AddLine(zo_iconTextFormat("esoui/art/icons/icon_rmb.dds", 26, 26, GetString(SI_ITEM_ACTION_LINK_TO_CHAT)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function TB_UI:RowHeading_OnMouseEnter(control)
	local o = control:GetParent()
	local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
	local traitDescription, traitResearchSourceDescription, traitMaterialSourceDescription = GetSmithingResearchLineTraitDescriptions(o.craftingSkillType, o.researchLineIndex, o.traitIndex)
	InitializeTooltip(InformationTooltip, control, RIGHT, -10)
	InformationTooltip:AddLine(GetString("SI_ITEMTRAITTYPE", o.traitType), "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(traitDescription, "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	InformationTooltip:AddVerticalPadding(15)
	InformationTooltip:AddLine(zo_str(SI_SMITHING_TRAIT_RESEARCH_SOURCE_DESCRIPTION, traitResearchSourceDescription), "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	InformationTooltip:AddVerticalPadding(15)
	InformationTooltip:AddLine(zo_str(SI_SMITHING_TRAIT_MATERIAL_SOURCE_DESCRIPTION, traitMaterialSourceDescription), "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function TB_UI:TraitMaterial_OnMouseEnter(control)
	local o = control:GetParent()
	local r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
	InitializeTooltip(ItemTooltip, control, LEFT, 5, 0)
	ItemTooltip:SetLink(ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,o.materialItemID,30,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
	local _, _, traitMaterialSourceDescription = GetSmithingResearchLineTraitDescriptions(o.craftingSkillType, o.researchLineIndex, o.traitIndex)
	ItemTooltip:AddVerticalPadding(20)
	ItemTooltip:AddLine(zo_str(SI_SMITHING_TRAIT_MATERIAL_SOURCE_DESCRIPTION, traitMaterialSourceDescription), "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	self:AddLinkToChat(ItemTooltip, 20)
end

function TB_UI:TraitMaterial_OnMouseUp(control, button, upInside)
	if button == CONTEXT_CHECK_RIGHT and upInside then
		local link = GetSmithingTraitItemLink(control:GetParent().traitItemIndex, LINK_STYLE_BRACKETS)
		ZO_LinkHandler_InsertLink(link)
	end
end

function TB_UI:Trait_OnMouseEnter(control)
	local craftingSkillType = control.craftingSkillType
	local researchLineIndex = control.researchLineIndex
	local traitIndex = control.traitIndex

	local name, _, _, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
	local traitType, _, _ = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	local _, traitResearchSourceDescription = GetSmithingResearchLineTraitDescriptions(craftingSkillType, researchLineIndex, traitIndex)

	InitializeTooltip(InformationTooltip, control, LEFT, 5, 0)
	TraitBuddy:BuildTooltipTitle(InformationTooltip, sf("%s - %s", name, GetString("SI_ITEMTRAITTYPE", traitType)))

	if self.selector:IsCharacterSelected() then
		ZO_Tooltip_AddDivider(InformationTooltip)
		InformationTooltip:AddVerticalPadding(5)
		local rr, gg, bb = ZO_NORMAL_TEXT:UnpackRGB()
		InformationTooltip:AddLine(zo_str(SI_SMITHING_TRAIT_RESEARCH_SOURCE_DESCRIPTION, traitResearchSourceDescription), "", rr, gg, bb, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)

		InformationTooltip:AddVerticalPadding(5)
		ZO_Tooltip_AddDivider(InformationTooltip)
		local k, r, can = TraitBuddy:GetWhoKnows(craftingSkillType, researchLineIndex, traitIndex, true)
		TraitBuddy:BuildTooltip(InformationTooltip, k, r, can)

		local c = self.selector:GetSelectedCharacter()
		for i=1,#r do
			if r[i] == c.name then
				local timeRemainingSecs = GetDiffBetweenTimeStamps(c.research[craftingSkillType][researchLineIndex][traitIndex].done, GetTimeStamp())
				InformationTooltip:AddLine(tostring(ZO_FormatTime(timeRemainingSecs, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			end
		end
	end
	InformationTooltip:AddVerticalPadding(5)
	InformationTooltip:AddLine(zo_iconTextFormat("esoui/art/icons/icon_rmb.dds", 26, 26, GetString(SI_BINDING_NAME_GAMEPAD_TOGGLE_GAME_CAMERA_UI_MODE)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function TB_UI:MarkForResearch(c, craftingSkillType, researchLineIndex, traitIndex)
--	local c = TraitBuddy:GetCharacter(TraitBuddy.characterId)
	c.markForResearch[craftingSkillType][researchLineIndex][traitIndex] = true
TraitBuddy.ui:Refresh(self)
end

function TB_UI:UnmarkForResearch(c, craftingSkillType, researchLineIndex, traitIndex)
--	local c = TraitBuddy:GetCharacter(TraitBuddy.characterId)
	c.markForResearch[craftingSkillType][researchLineIndex][traitIndex] = false
TraitBuddy.ui:Refresh(self)
end

function TB_UI:Trait_OnMouseUp(control, button, upInside)
	if (button == CONTEXT_CHECK_RIGHT and IsChatSystemAvailableForCurrentPlatform() and upInside) then
		local id = 0
		if control.craftingSkillType == CRAFTING_TYPE_JEWELRYCRAFTING then
			id = TraitBuddy.data:GetJewelryTraitLinkID(control.researchLineIndex, control.traitIndex)
		else
			id = TraitBuddy.data:GetTraitLinkID(control.craftingSkillType, control.researchLineIndex, control.traitIndex)
		end
		--Build the link quality:30 level:1 durability:10000
        ClearMenu()
		AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,id,30,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,10000,0)) end)
		-- if self.crafting:Available(true) then
		-- 	local name = GetSmithingResearchLineInfo(control.craftingSkillType, control.researchLineIndex)
		-- 	local traitType, _, _ = GetSmithingResearchLineTraitInfo(control.craftingSkillType, control.researchLineIndex, control.traitIndex)
		-- 	local reference = sf("%s - %s - %s", self.selector:GetSelectedCharacter().name, name, GetString("SI_ITEMTRAITTYPE", traitType))
		-- 	AddMenuItem(GetString(SI_CRAFTING_PERFORM_FREE_CRAFT), function() self.crafting:Craft(control.craftingSkillType, control.researchLineIndex, control.traitIndex, reference) end)
		-- end
	local c = self.selector:GetSelectedCharacter()

		if not c.research[control.craftingSkillType][control.researchLineIndex][control.traitIndex] then
		  if not IsConsoleUI() then
        if c.markForResearch[control.craftingSkillType][control.researchLineIndex][control.traitIndex] then
          AddMenuItem(GetString(TB_UNMARK_TRAIT), function() self:UnmarkForResearch(c, control.craftingSkillType, control.researchLineIndex, control.traitIndex) end)
        else
          AddMenuItem(GetString(TB_MARK_TRAIT), function() self:MarkForResearch(c, control.craftingSkillType, control.researchLineIndex, control.traitIndex) end)
        end
			end
--			d(c.markForResearch[control.craftingSkillType][control.researchLineIndex][control.traitIndex])
			self:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
			self:UpdateUI(CRAFTING_TYPE_CLOTHIER)
			self:UpdateUI(CRAFTING_TYPE_WOODWORKING)
			self:UpdateUI(CRAFTING_TYPE_JEWELRYCRAFTING)
			self:UpdateUI()

		end
		ShowMenu(entry)
		CALLBACK_MANAGER:FireCallbacks("TB-OnTraitMouseUp", control.craftingSkillType, control.researchLineIndex, control.traitIndex)
    end
end

function TB_UI:ColumnHeading_OnMouseEnter(control)
	ZO_Tooltips_ShowTextTooltip(control, RIGHT, control.displayName)
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(GetString(SI_ITEM_ACTION_MAIL_ATTACH), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	local name = GetSmithingResearchLineInfo(control.craftingSkillType, control.researchLineIndex)
	InformationTooltip:AddLine(zo_iconTextFormat("esoui/art/icons/icon_rmb.dds", 26, 26, sf(GetString(TB_MAIL_UNKNOWN), name)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	InformationTooltip:AddLine(zo_iconTextFormat("esoui/art/icons/icon_lmb.dds", 26, 26, sf(GetString(TB_MAIL_KNOWN), name)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function TB_UI:ColumnHeading_OnMouseUp(control, button, upInside)
	if upInside then
		if button == CONTEXT_CHECK_LEFT then
			self.mail:Compose(control.craftingSkillType, control.researchLineIndex, true)
		elseif button == CONTEXT_CHECK_RIGHT then
			self.mail:Compose(control.craftingSkillType, control.researchLineIndex, false)
		end
	end
end

function TB_UI:Toggle()
	SCENE_MANAGER:ToggleTopLevel(self.parent)
	if not self.selector:IsCurrentCharacterSelected() then --Always select the current character when re-opening
		self.selector:TrySelectCurrentCharacter()
	end
end

function TB_UI:OnShow(hidden)
	local state = hidden and BSTATE_NORMAL or BSTATE_PRESSED
	for launcherType,launcher in pairs(self.launchers) do
		launcher:SetState(state)
	end
end

function TB_UI:ToggleOptions()
	SCENE_MANAGER:HideTopLevel(self.parent)
	DoCommand("/traitbuddyoptions")
end

function TB_UI:SetLocked(control)
	ZO_ToggleButton_Toggle(control)
	TraitBuddy.settings.locked = not ZO_ToggleButton_GetState(control)
end

function TB_UI:Refresh(control)
	if self.created then
		TraitBuddy:UpdateResearch()
		TraitBuddy.helpers:UpdateResearching()
		TraitBuddy:UpdateMotifs()
		self.research:UpdateUI()
		for key,craftingSkillType in pairs(TraitBuddy:GetCraftingSkillTypes()) do
			self:UpdateUI(craftingSkillType)
		end
	end
end

function TB_UI:MoveStart(control)
	if TraitBuddy.settings.locked then
		control:StopMovingOrResizing()
	end
end

function TB_UI:MoveStop(control)
	if not TraitBuddy.settings.locked then
		TraitBuddy.settings.x = control:GetLeft()
		TraitBuddy.settings.y = control:GetTop()
	end
end

function TB_UI:SetWindowPosition(x, y)
	TraitBuddy.settings.x = x
	TraitBuddy.settings.y = y
	self.parent:ClearAnchors()
	self.parent:SetAnchor(TOPLEFT, nil, TOPLEFT, x, y)
end

function TB_UI:SelectCraft(text, descriptor)
	local crafting = self.parent:GetNamedChild("Crafting")
	crafting:SetHidden(false)
	self.selector:Show()
	self.motifs:Hide()
	self.research:Hide()
	self.sets:Hide()
	self.heading:GetNamedChild("Prof"):SetText(text)
	crafting:GetNamedChild(CRAFTING_TYPE_BLACKSMITHING):SetHidden(descriptor ~= CRAFTING_TYPE_BLACKSMITHING)
	crafting:GetNamedChild(CRAFTING_TYPE_CLOTHIER):SetHidden(descriptor ~= CRAFTING_TYPE_CLOTHIER)
	crafting:GetNamedChild(CRAFTING_TYPE_WOODWORKING):SetHidden(descriptor ~= CRAFTING_TYPE_WOODWORKING)
	crafting:GetNamedChild(CRAFTING_TYPE_JEWELRYCRAFTING):SetHidden(descriptor ~= CRAFTING_TYPE_JEWELRYCRAFTING)
	
	self:UpdateNumResearching()
	
	TB_Apparel1:SetHidden(descriptor ~= CRAFTING_TYPE_BLACKSMITHING)
	TB_Apparel2:SetHidden(descriptor ~= CRAFTING_TYPE_CLOTHIER)
	TB_Apparel6:SetHidden(descriptor ~= CRAFTING_TYPE_WOODWORKING)
	crafting:GetNamedChild("Headings"):GetNamedChild("Div"):SetHidden(descriptor == CRAFTING_TYPE_JEWELRYCRAFTING)
	
	--Ensure when switching crafting types the selected weapons or armour update as well
	OnApparelSelect()
end

function TB_UI:SelectResearch(text)
	self.parent:GetNamedChild("Crafting"):SetHidden(true)
	self.selector:Hide()
	self.motifs:Hide()
	self.research:Show()
	self.sets:Hide()
	self.heading:GetNamedChild("Prof"):SetText(text)
end

function TB_UI:SelectMotif(text)
	self.parent:GetNamedChild("Crafting"):SetHidden(true)
	self.selector:Show()
	self.motifs:Show()
	self.research:Hide()
	self.sets:Hide()
	self.heading:GetNamedChild("Prof"):SetText(text)
end

function TB_UI:SelectSets(text)
	self.parent:GetNamedChild("Crafting"):SetHidden(true)
	self.selector:Hide()
	self.motifs:Hide()
	self.research:Hide()
	self.sets:Show()
	self.heading:GetNamedChild("Prof"):SetText(text)
end

function TB_UI:GetResearchSplit()
	--Calculate the columns for the weapons and armours
	return {
		[CRAFTING_TYPE_BLACKSMITHING] = TraitBuddy:ItemToResearchLineIndex(ITEMTYPE_ARMOR, ARMORTYPE_HEAVY, 0, EQUIP_TYPE_CHEST),
		[CRAFTING_TYPE_CLOTHIER] = TraitBuddy:ItemToResearchLineIndex(ITEMTYPE_ARMOR, ARMORTYPE_MEDIUM, 0, EQUIP_TYPE_CHEST),
		[CRAFTING_TYPE_WOODWORKING] = TraitBuddy:ItemToResearchLineIndex(ITEMTYPE_WEAPON, 0, WEAPONTYPE_SHIELD, 0),
		[CRAFTING_TYPE_JEWELRYCRAFTING] = 2
	}
end

function TB_UI:GetSectionSplitName(craftingSkillType,researchLineIndex)
	local first = {
		[CRAFTING_TYPE_BLACKSMITHING] = "Weapons",
		[CRAFTING_TYPE_CLOTHIER] = "Light",
		[CRAFTING_TYPE_WOODWORKING] = "Weapons",
		[CRAFTING_TYPE_JEWELRYCRAFTING] = "All"
	}
	local second = {
		[CRAFTING_TYPE_BLACKSMITHING] = "Armour",
		[CRAFTING_TYPE_CLOTHIER] = "Medium",
		[CRAFTING_TYPE_WOODWORKING] = "Shields",
		[CRAFTING_TYPE_JEWELRYCRAFTING] = "All"
	}
	local researchLineSplit = self:GetResearchSplit()
	if researchLineIndex > 0 and researchLineIndex < researchLineSplit[craftingSkillType] then
		return first[craftingSkillType]
	else
		return second[craftingSkillType]
	end
end

function TB_UI:CreateTraits()
	--Calculate the columns for the weapons and armours
	local researchLineSplit = self:GetResearchSplit()
	--Build a list of trait icons
	local allTraits = ZO_CraftingUtils_GetSmithingTraitItemInfo()
	local function findTraitByType(type)
		for _,trait in pairs(allTraits) do
			if trait.type == type then
				return trait
			end
		end
	end

	local traitIcons = {}
	local traitMaterialIds = TraitBuddy.data:GetResearchableTraitMaterials()
	-- This could be ZO_CraftingUtils_GetSmithingTraitItemInfo()
	for traitIndex = 1, GetNumSmithingTraitItems() do
		local traitType, name, icon, _, _, _, _ = GetSmithingTraitItemInfo(traitIndex) --itemStyle is zero
		if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
			traitIcons[traitType] = {icon=icon, traitItemIndex=traitIndex, name=name}
		end
	end

	-- loop traitIcons comparing the icon to findTratitByType
	for traitType,traitIcon in pairs(traitIcons) do
		local trait = findTraitByType(traitType)
		if traitIcon.icon ~= trait.icon then
			d(sf("TraitBuddy DEBUG: %s icons %s vs %s", traitIcon.name, traitIcon.icon, trait.icon))
		end
		if traitIcon.traitItemIndex ~= trait.index then
			d(sf("TraitBuddy DEBUG: %s index %d vs %d", traitIcon.name, traitIcon.traitItemIndex, trait.index))
		end
	end
	-- local newFound = 0
	-- for idx,trait in pairs(allTraits) do
	-- 	if trait.type ~= ITEM_TRAIT_TYPE_NONE then
	-- 		newFound = newFound + 1
	-- 	end
	-- end
	-- d(sf("TraitBuddy DEBUG: traitIcons %s new traits %s", #traitIcons, #allTraits))
	
	-- compare icon in traitIcons to icon in allTraits show a message if they are different
	-- for idx_trait,trait in pairs(traitIcons) do
	-- 	local foundTrait = false
	-- 	local foundAt
	-- 	for idx_allTraits,allTrait in pairs(allTraits) do
	-- 		foundAt = idx_allTraits
	-- 		if trait.name == allTrait.name then
	-- 			foundTrait = true
	-- 			break
	-- 		end
	-- 	end
	-- 	if foundTrait then
	-- 		d(sf("%d %s found at position %d", idx_trait, trait.name, foundAt))
	-- 	else
	-- 		d(sf("%d %s NOT found", idx_trait, trait.name))
	-- 	end
	-- end
	

	--Create trait ui
	local crafting = self.parent:GetNamedChild("Crafting")
	local craftings = TraitBuddy:GetCraftingSkillTypes()
	for key,craftingSkillType in pairs(craftings) do
		local section, headings
		--Create the headings
		for _,researchLineIndex in pairs({1, researchLineSplit[craftingSkillType]}) do
			local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)

			section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(self:GetSectionSplitName(craftingSkillType,researchLineIndex))
			local headings = GetControl(sf("%sHeadings", section:GetName()))
			if not headings then
				headings = CreateControlFromVirtual("$(parent)Headings", section, "TB_TraitColumn_Headings")
				local lastHeading
				for traitIndex = 1, numTraits do
					local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
					
					local heading = CreateControlFromVirtual("$(parent)Heading", headings.container, "TB_TraitColumn_Heading", traitIndex)
					if lastHeading then
						heading:SetAnchor(TOP, lastHeading, BOTTOM, 0, 0)
					end
					heading.traitType = traitType
					heading.traitItemIndex = traitIcons[traitType].traitItemIndex
					heading.materialItemID = traitMaterialIds[traitType]
					heading.craftingSkillType = craftingSkillType
					heading.researchLineIndex = researchLineIndex
					heading.traitIndex = traitIndex
					heading:GetNamedChild("Name"):SetText(GetString("SI_ITEMTRAITTYPE", traitType))
					heading:GetNamedChild("Material"):SetTexture(traitIcons[traitType].icon)
					lastHeading = heading
				end
				headings.container:SetHeight(lastHeading:GetHeight()*numTraits)
			end
		end
		
		--Create the traits
		local lastColumn
		for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
			local name, icon, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
			
			if researchLineIndex == 1 or (researchLineIndex == researchLineSplit[craftingSkillType] and craftingSkillType ~= CRAFTING_TYPE_JEWELRYCRAFTING) then
				section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(self:GetSectionSplitName(craftingSkillType,researchLineIndex))
				lastColumn = section:GetNamedChild("Headings")
			end
			
			--Create the next column
			local column = CreateControlFromVirtual("$(parent)Column", section, "TB_TraitColumn_Traits", researchLineIndex)
			column:SetAnchor(TOPLEFT, lastColumn, TOPRIGHT, 0, 0)
			--Column heading picture
			column.heading.displayName = name
			column.heading:SetTexture(icon)
			column.heading.craftingSkillType = craftingSkillType
			column.heading.researchLineIndex = researchLineIndex

			local lastTrait
			for traitIndex = 1, numTraits do
				local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
				local trait = CreateControlFromVirtual("$(parent)Trait", column.container, "TB_Trait", traitIndex)
				if lastTrait then
					trait:SetAnchor(TOP, lastTrait, BOTTOM, 0, 0)
				end
				trait.craftingSkillType = craftingSkillType
				trait.researchLineIndex = researchLineIndex
				trait.traitIndex = traitIndex
				trait.traitItemIndex = traitIcons[traitType].traitItemIndex
				lastTrait = trait
			end
			column.container:SetHeight(lastTrait:GetHeight()*numTraits)
			lastColumn = column
		end
	end
end

local function CreateIcon(control, data, sideFloat, offsetY)
  if not offsetY then
    offsetY = 0
  end
  if not GetControl(data.label) then
	  icon = WINDOW_MANAGER:CreateControl(data.label, control, CT_BUTTON)
    icon:SetDimensions(64, 64)
    icon:SetAnchor(BOTTOM, control, BOTTOM, sideFloat, offsetY)
    icon:SetNormalTexture(data.normal)
    icon:SetHandler("OnClicked", function(control)
      data.callback(data)
    end)
    icon:SetText(data.label)
    icon:SetHidden(false)
    return icon
  end
  return GetControl(data.label)
end

function TB_UI:CreateMenus()
	--Create menu bar and buttons for crafting professions
	local controlType
	local list
	local scene
	if not IsInGamepadPreferredMode() then
    self.menubar = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)CraftMenuBar", self.heading, "ZO_MenuBarTemplate")
	  self.menubar.control:SetAnchor(RIGHT, self.heading, RIGHT, -20, 0)
	end

	local data = {
		buttonPadding = 15,
		normalSize = 64,
		downSize = 74
	}
	if not IsInGamepadPreferredMode() then
-- 	  local entryData = ZO_GamepadEntryData:New("", data.icon, nil, nil, data.isNewCallback)
--     list:AddEntry("ZO_GamepadMenuEntryTemplate", data)
-- 	else
	  ZO_MenuBar_SetData(self.menubar, data)
	end
	data = {
		descriptor = CRAFTING_TYPE_BLACKSMITHING,
		craftingSkillType = CRAFTING_TYPE_BLACKSMITHING,
		normal = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
		pressed = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_down.dds",
		disabled = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
		highlight = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_over.dds",
		callback = OnCraftSelect,
		label = zo_cachedstr(SI_ABILITY_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_BLACKSMITHING))
	}
	if IsInGamepadPreferredMode() then
    CreateIcon(self.heading, data, -180)
	else
	  ZO_MenuBar_AddButton(self.menubar, data)
	end

	data = {
		descriptor = CRAFTING_TYPE_CLOTHIER,
		craftingSkillType = CRAFTING_TYPE_CLOTHIER,
		normal = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
		pressed = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_down.dds",
		disabled = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
		highlight = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_over.dds",
		callback = OnCraftSelect,
		label = zo_cachedstr(SI_ABILITY_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_CLOTHIER))
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(self.heading, data, -110)
	else
	  ZO_MenuBar_AddButton(self.menubar, data)
	end
	data = {
		descriptor = CRAFTING_TYPE_WOODWORKING,
		craftingSkillType = CRAFTING_TYPE_WOODWORKING,
		normal = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
		pressed = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_down.dds",
		disabled = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
		highlight = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_over.dds",
		callback = OnCraftSelect,
		label = zo_cachedstr(SI_ABILITY_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_WOODWORKING))
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(self.heading, data, -60)
	else
	  ZO_MenuBar_AddButton(self.menubar, data)
	end
	data = {
		descriptor = CRAFTING_TYPE_JEWELRYCRAFTING,
		craftingSkillType = CRAFTING_TYPE_JEWELRYCRAFTING,
		normal = "esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds",
		pressed = "esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_down.dds",
		disabled = "esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds",
		highlight = "esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_icon_over.dds",
		callback = OnCraftSelect,
		label = zo_cachedstr(SI_ABILITY_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_JEWELRYCRAFTING))
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(self.heading, data, 10)
	else
	  ZO_MenuBar_AddButton(self.menubar, data)
	end
	data = {
		descriptor = "motifs",
		normal = "esoui/art/mainmenu/menubar_journal_up.dds",
		pressed = "esoui/art/mainmenu/menubar_journal_down.dds",
		disabled = "esoui/art/mainmenu/menubar_journal_disabled.dds",
		highlight = "esoui/art/mainmenu/menubar_journal_over.dds",
		callback = OnMotifSelect,
		label = GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF)
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(self.heading, data, 80)
	else
	  ZO_MenuBar_AddButton(self.menubar, data)
	end
	data = {
		descriptor = "sets",
		normal = "esoui/art/collections/collections_tabicon_itemsets_up.dds",
		pressed = "esoui/art/collections/collections_tabicon_itemsets_down.dds",
		disabled = "esoui/art/collections/collections_tabicon_itemsets_disabled.dds",
		highlight = "esoui/art/collections/collections_tabicon_itemsets_over.dds",
		callback = OnSetsSelect,
		label = GetString(TB_SETS)
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(self.heading, data, 150)
	else
	  ZO_MenuBar_AddButton(self.menubar, data)
	end
	data = {
		descriptor = "research",
		normal = "esoui/art/crafting/smithing_tabicon_research_up.dds",
		pressed = "esoui/art/crafting/smithing_tabicon_research_down.dds",
		disabled = "esoui/art/crafting/smithing_tabicon_research_disabled.dds",
		highlight = "esoui/art/crafting/smithing_tabicon_research_over.dds",
		callback = OnResearchSelect,
		label = GetString(SI_SMITHING_TAB_RESEARCH)
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(self.heading, data, 220)
	else
	  ZO_MenuBar_AddButton(self.menubar, data)
	end
	
	--Create menu bar and buttons for blacksmith weapons and armour
	local bsApparel
	local bsApparelList
	if not IsInGamepadPreferredMode() then
	  bsApparel = CreateControlFromVirtual("$(parent)ApparelBar", TB_Apparel1, "ZO_MenuBarTemplate")
	  bsApparel:SetAnchor(RIGHT, TB_Apparel1, RIGHT, 0, 0)
	end

	data = {
		buttonPadding = 15,
		normalSize = 54,
		downSize = 64
	}
	if not IsInGamepadPreferredMode() then
--     bsApparelList:AddEntry("ZO_GamepadMenuEntryTemplate", data)
-- 	else
	  ZO_MenuBar_SetData(bsApparel, data)
	end

	data = {
		descriptor = 1,
		craftingSkillType = CRAFTING_TYPE_BLACKSMITHING,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_disabled.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_over.dds",
		callback = OnApparelSelect,
		label = GetString(SI_TRADINGHOUSECATEGORYHEADER1)
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(TB_Apparel1, data, -40, 20)
	else
	  ZO_MenuBar_AddButton(bsApparel, data)
	end
	data = {
		descriptor = 2,
		craftingSkillType = CRAFTING_TYPE_BLACKSMITHING,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_armor_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_armor_disabled.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_armor_over.dds",
		callback = OnApparelSelect,
		label = GetString(SI_ARMORTYPE_TRADINGHOUSECATEGORY3)
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(TB_Apparel1, data, 30, 20)
	else
	  ZO_MenuBar_AddButton(bsApparel, data)
	end
	
	--Create menu bar and buttons for clothing armours
	local clApparel
	local clApparelList
	if not IsInGamepadPreferredMode() then
	  clApparel = CreateControlFromVirtual("$(parent)ApparelBar", TB_Apparel2, "ZO_MenuBarTemplate")
	  clApparel:SetAnchor(RIGHT, TB_Apparel2, RIGHT, 0, 0)
	end

	data = {
		buttonPadding = 15,
		normalSize = 54,
		downSize = 64
	}
	if not IsInGamepadPreferredMode() then
--     clApparelList:AddEntry("ZO_GamepadMenuEntryTemplate", data)
-- 	else
	  ZO_MenuBar_SetData(clApparel, data)
	end

	data = {
		descriptor = 1,
		craftingSkillType = CRAFTING_TYPE_CLOTHIER,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_armorLight_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_armorLight_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_armorLight_up.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_armorLight_over.dds",
		callback = OnApparelSelect,
		label = GetString(SI_EQUIPMENTFILTERTYPE1)
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(TB_Apparel2, data, -40, 20)
	else
	  ZO_MenuBar_AddButton(clApparel, data)
	end
	data = {
		descriptor = 2,
		craftingSkillType = CRAFTING_TYPE_CLOTHIER,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_armorMedium_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_armorMedium_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_armorMedium_up.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_armorMedium_over.dds",
		callback = OnApparelSelect,
		label = GetString(SI_EQUIPMENTFILTERTYPE2)
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(TB_Apparel2, data, 30, 20)
	else
	  ZO_MenuBar_AddButton(clApparel, data)
	end
	
	--Create menu bar and buttons for woodworking weapons and shields
	local wwApparel

	local wwApparel
	local wwApparelList
	if not IsInGamepadPreferredMode() then
	  wwApparel = CreateControlFromVirtual("$(parent)ApparelBar", TB_Apparel6, "ZO_MenuBarTemplate")
	  wwApparel:SetAnchor(RIGHT, TB_Apparel6, RIGHT, 0, 0)
	end

	data = {
		buttonPadding = 15,
		normalSize = 54,
		downSize = 64
	}
	if not IsInGamepadPreferredMode() then
--     wwApparelList:AddEntry("ZO_GamepadMenuEntryTemplate", data)
-- 	else
	  ZO_MenuBar_SetData(wwApparel, data)
	end

	data = {
		descriptor = 1,
		craftingSkillType = CRAFTING_TYPE_WOODWORKING,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_disabled.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_over.dds",
		callback = OnApparelSelect,
		label = GetString(SI_TRADINGHOUSECATEGORYHEADER1)
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(TB_Apparel6, data, -40, 20)
	else
	  ZO_MenuBar_AddButton(wwApparel, data)
	end
	data = {
		descriptor = 2,
		craftingSkillType = CRAFTING_TYPE_WOODWORKING,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_armor_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_armor_disabled.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_armor_over.dds",
		callback = OnApparelSelect,
		label = GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_SHIELD)
	}
	if IsInGamepadPreferredMode() then
	  CreateIcon(TB_Apparel6, data, 30, 20)
	else
	  ZO_MenuBar_AddButton(wwApparel, data)
	end
end

function TB_UI:Create()
	self:CreateTraits()
	self:CreateMenus()
	self.motifs:SelectFirstFilter()
	self.selector:Build(TraitBuddy.characterId)
	self.selector:Show()
	--ZO_MenuBar_SelectDescriptor(TB_Apparel6ApparelBar, 1, true, false)
	--ZO_MenuBar_SelectDescriptor(TB_Apparel2ApparelBar, 1, true, false)
	--ZO_MenuBar_SelectDescriptor(TB_Apparel1ApparelBar, 1, true, false)
	if not IsInGamepadPreferredMode() then
	  ZO_MenuBar_SelectDescriptor(self.menubar, CRAFTING_TYPE_BLACKSMITHING, true, true)
	end
	self.research:AddCharacters()
	self.launchers.smithing:SetHidden(not TraitBuddy.settings.showLaunch1)
	self.launchers.skills:SetHidden(not TraitBuddy.settings.showLaunch2)
	if not IsInGamepadPreferredMode() then
	  self.launchers.guildstore:SetHidden(not TraitBuddy.settings.showLaunch3)
	end
	self.created = true
end

function TB_UI:UpdateTotals(c, craftingSkillType)
	--Setup the totals for a single crafting skill
	local runningTotal = 0
	local section
	local control
	local crafting = self.parent:GetNamedChild("Crafting")
	local researchLineSplit = self:GetResearchSplit()
	for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
		if researchLineIndex == 1 then
			section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(self:GetSectionSplitName(craftingSkillType,researchLineIndex))
		elseif researchLineIndex == researchLineSplit[craftingSkillType] then
			--First screens grand total
			control = section:GetNamedChild("Headings"):GetNamedChild("Total")
			control:SetText(sf("%s (%d)", GetString(SI_CRAFTING_COMPONENT_TOOLTIP_TRAITS), runningTotal))
			runningTotal = 0
			section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(self:GetSectionSplitName(craftingSkillType,researchLineIndex))
		end

		local numKnown = 0
		if c then
			local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
			for traitIndex = 1, numTraits do
				if TraitBuddy.helpers:IsTraitKnown(c, craftingSkillType, researchLineIndex, traitIndex, TraitBuddy.settings.traitTable) then
					numKnown = numKnown + 1
				end
			end
		end

		--Traits known total
		control = section:GetNamedChild(sf("Column%d", researchLineIndex)):GetNamedChild("Total")
		control:SetText(numKnown)
		runningTotal = runningTotal + numKnown
	end
	
	--Seconds screens grand total
	if section then
		control = section:GetNamedChild("Headings"):GetNamedChild("Total")
		control:SetText(sf("%s (%d)", GetString(SI_CRAFTING_COMPONENT_TOOLTIP_TRAITS), runningTotal))
	end
end

local function IsTraitKnownUI(c, craftingSkillType, researchLineIndex, traitIndex)
	--Known by anyone, returns someoneKnows, selectedKnows, someoneResearching, selectedResearching
	--Only used in UpdateUI
	local know, researching, _ = TraitBuddy:GetWhoKnows(craftingSkillType, researchLineIndex, traitIndex, false)
	local selectedKnows = false
	local selectedResearching = false
	if c then
		selectedKnows = ZO_IsElementInNumericallyIndexedTable(know, c.name)
		selectedResearching = ZO_IsElementInNumericallyIndexedTable(researching, c.name)
	end
	return (#know > 0), selectedKnows, (#researching > 0), selectedResearching
end

function TB_UI:UpdateUI(craftingSkillType)
	--Update the known traits, traits being researched and traits known by alts
	if not self.created then
		self.updatelater:UpdateUI(craftingSkillType)
		return
	end
	
	local section
	local crafting = self.parent:GetNamedChild("Crafting")
	local researchLineSplit = self:GetResearchSplit()
	local c = self.selector:GetSelectedCharacter()
	for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
		if researchLineIndex == 1 or researchLineIndex == researchLineSplit[craftingSkillType] then
			section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(self:GetSectionSplitName(craftingSkillType,researchLineIndex))
		end
		local column = section:GetNamedChild(sf("Column%d", researchLineIndex))
		
		local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		for traitIndex = 1, numTraits do
			local someoneKnows, selectedKnows, someoneResearching, selectedResearching = IsTraitKnownUI(c, craftingSkillType, researchLineIndex, traitIndex)
			local trait = column.container:GetNamedChild(sf("Trait%d", traitIndex))
			--trait.yes:SetHidden(not someoneKnows or someoneResearching)
			--trait.research:SetHidden(not someoneKnows or someoneResearching)
			--trait.no:SetHidden(not someoneKnows or someoneResearching)

			if selectedKnows then
				trait.yes:SetColor(TraitBuddy.settings.colours.know.r, TraitBuddy.settings.colours.know.g, TraitBuddy.settings.colours.know.b)
			else
				trait.yes:SetColor(TraitBuddy.settings.colours.others_know.r, TraitBuddy.settings.colours.others_know.g, TraitBuddy.settings.colours.others_know.b)
			end
			if selectedResearching then
				trait.research:SetColor(TraitBuddy.settings.colours.researching.r, TraitBuddy.settings.colours.researching.g, TraitBuddy.settings.colours.researching.b)
			else
				trait.research:SetColor(TraitBuddy.settings.colours.others_researching.r, TraitBuddy.settings.colours.others_researching.g, TraitBuddy.settings.colours.others_researching.b)
			end
			trait.no:SetColor(TraitBuddy.settings.colours.not_known.r, TraitBuddy.settings.colours.not_known.g, TraitBuddy.settings.colours.not_known.b)

			if TraitBuddy.helpers:CheckMarkForResearch(c, craftingSkillType, researchLineIndex, traitIndex) then
				trait.yes:SetColor(TraitBuddy.settings.colours.mark.r, TraitBuddy.settings.colours.mark.g, TraitBuddy.settings.colours.mark.b)
				trait.no:SetColor(TraitBuddy.settings.colours.mark.r, TraitBuddy.settings.colours.mark.g, TraitBuddy.settings.colours.mark.b)
			end

			--Longer version for now, get it working
			if selectedKnows then
				trait.yes:SetHidden(false)
				trait.no:SetHidden(true)
				trait.research:SetHidden(true)
			elseif selectedResearching then
				trait.yes:SetHidden(true)
				trait.no:SetHidden(true)
				trait.research:SetHidden(false)
			else
				if someoneKnows then
					trait.yes:SetHidden(false)
					trait.no:SetHidden(true)
					trait.research:SetHidden(true)
				elseif someoneResearching then
					trait.yes:SetHidden(true)
					trait.no:SetHidden(true)
					trait.research:SetHidden(false)
				else
					trait.yes:SetHidden(true)
					trait.no:SetHidden(false)
					trait.research:SetHidden(true)
				end
			end
		end
	end
	self:UpdateNumResearching(c)
	self:UpdateTotals(c, craftingSkillType)
end

function TB_UI:UpdateCurrentMaxSimultaneousResearch(craftingSkillType)
	local c = TraitBuddy:GetCharacter(TraitBuddy.characterId)
	if c then
		c.research[craftingSkillType].MaxSimultaneousResearch = GetMaxSimultaneousSmithingResearch(craftingSkillType)
	end
end

function TB_UI:UpdateNumResearching(c)
	--Update the number of items being researched
	TBMaxResearchIcon:SetColor(TraitBuddy.settings.colours.researching.r, TraitBuddy.settings.colours.researching.g, TraitBuddy.settings.colours.researching.b)
	local craftingSkillType
	if not IsInGamepadPreferredMode() then
	  craftingSkillType = ZO_MenuBar_GetSelectedDescriptor(self.menubar)
	end
	if craftingSkillType == CRAFTING_TYPE_BLACKSMITHING or craftingSkillType == CRAFTING_TYPE_CLOTHIER or craftingSkillType == CRAFTING_TYPE_WOODWORKING or craftingSkillType == CRAFTING_TYPE_JEWELRYCRAFTING then
		local maxResearch = 0
		local numResearching = 0
		if not c then
			c = self.selector:GetSelectedCharacter()
		end
		if c then
			numResearching = GetNumResearching(c, craftingSkillType)
			maxResearch = c.research[craftingSkillType].MaxSimultaneousResearch
		end
		local maxResearchText = sf("%s: %d/%d", GetString(SI_GAMEPAD_SMITHING_CURRENT_RESEARCH_HEADER), numResearching, maxResearch)
		TBMaxResearch:SetText(maxResearchText)
	end
end
