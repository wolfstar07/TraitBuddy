local sf = string.format
local zo_str = zo_strformat

TB_CharacterSelector = ZO_Object:Subclass()

function TB_CharacterSelector:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_CharacterSelector:Initialize(parent)
	--Initialized before TraitBuddy data is available
	self.parent = parent
    self.characterId = GetCurrentCharacterId()
    self.selectedId = 0
	self.built = false
	
	--Build a list of class icons
	self.classIcons = {}
	for i = 0, GetNumClasses() do
		local classId, lore, normalIcon, pressedIcon, mouseoverIcon, isSelectable, ingameIcon = GetClassInfo(i)
		self.classIcons[classId] = {
			normalIcon=normalIcon,
			pressedIcon=pressedIcon,
			mouseoverIcon=mouseoverIcon
		}
	end	
	
	self.dropdown = CreateControlFromVirtual("$(parent)Dropdown", self.parent, "TB_AltsDropdown")
	
	--Alternative alt selection. Let the original drop down deal with the selection
	self.alternative = CreateControlFromVirtual("$(parent)Alternative", self.parent, "TB_AltsAlternative")
	self.bar = self.alternative:GetNamedChild("Bar")
	local data = {
		buttonPadding = 4,
		normalSize = 30,
		downSize = 40,
		buttonTemplate = "TB_AltsMenuBarButton"
	}
	ZO_MenuBar_SetData(self.bar, data)
end

local function DynamicClassInfo(id)
	--Try to dynamically get class information
	for i = 1, GetNumCharacters() do
		local _, gender, _, classId, raceId, _, thisID, _ = GetCharacterInfo(i)
		if id == thisID then
			return {classId=classId, raceId=raceId, gender=gender}
		end
	end
	return {classId=0, raceId=0, gender=0}
end

local function OnAltSelected(comboBox, characterName, item, selectionChanged)
	--selectionChanged is true when no character was initially selected
	if selectionChanged then
		item.object.selectedId = item.selectId
		item.object.alternative:GetNamedChild("Name"):SetText(characterName)
		ZO_MenuBar_SelectDescriptor(item.object.bar, item.object.selectedId, false)
		TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
		TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
		TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
		TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_JEWELRYCRAFTING)
		if not IsInGamepadPreferredMode() then
		  TraitBuddy.ui.motifs:UpdateUI()
		end
	end
end

function TB_CharacterSelector:Build(selectId)
	self.selectedId = 0
	self.alternative:GetNamedChild("Name"):SetText("")
	--Build or re-build the character drop down
	local combobox = ZO_ComboBox_ObjectFromContainer(self.dropdown)
	combobox:ClearItems()
	local sorted = TraitBuddy:GetCharacters(true)
	local characters = TraitBuddy:GetCharacters()
	for k,id in ipairs(sorted) do
		local c = characters[id]
		if c.show.bs or c.show.cl or c.show.ww or c.show.motif or c.show.je then
			local item = ZO_ComboBox:CreateItemEntry(c.name, OnAltSelected)
			item.object = self
			item.selectId = id
			combobox:AddItem(item, ZO_COMBOBOX_SUPRESS_UPDATE)
		end
	end
	combobox:UpdateItems()
	
	--Build the alternative character menu bar
	ZO_MenuBar_ClearButtons(self.bar)
	local className
	local raceName
	local ci
	for k,id in ipairs(sorted) do
		local c = characters[id]
		if c.show.bs or c.show.cl or c.show.ww or c.show.motif or c.show.je then
			local class = DynamicClassInfo(id)
			if class.classId > 0 then
				className = zo_str(SI_CLASS_NAME, GetClassName(class.gender, class.classId))
				raceName = zo_str(SI_RACE_NAME, GetRaceName(class.gender, class.raceId))
				ci = self.classIcons[class.classId]
			else
				className = "?"
				raceName = "?"
				ci = self.classIcons[0]
			end
			local data = {
				descriptor = id,
				normal = ci.normalIcon,
				pressed = ci.pressedIcon,
				highlight = ci.mouseoverIcon,
				callback = function(tabData)
					if self.selectedId ~= tabData.descriptor then
						self:SelectCharacter(tabData.descriptor)
					end
				end,
				className = className,
				raceName = raceName
			}
			ZO_MenuBar_AddButton(self.bar, data)
		end
	end
	ZO_MenuBar_UpdateButtons(self.bar, false)
	self.built = true
	self:TrySelectCharacter(selectId)
end

function TB_CharacterSelector:IsCharacterSelected()
	return self.selectedId ~= 0
end

function TB_CharacterSelector:IsCurrentCharacterSelected()
	return self.characterId == self.selectedId
end

function TB_CharacterSelector:GetSelectedID()
	return self.selectedId
end

function TB_CharacterSelector:GetSelectedCharacter()
	return TraitBuddy:GetCharacter(self.selectedId)
end

function TB_CharacterSelector:SelectCharacter(id)
	--Select chosen character, if not hidden or deleted
	local c = TraitBuddy:GetCharacter(id)
	if c then
		if c.show.bs or c.show.cl or c.show.ww or c.show.motif or c.show.je then
			local item = ZO_ComboBox:CreateItemEntry(c.name, OnAltSelected)
			item.object = self
			item.selectId = id
			ZO_ComboBox_ObjectFromContainer(self.dropdown):SelectItem(item)
			return true
		end
	end
	return false
end

function TB_CharacterSelector:TrySelectCurrentCharacter()
	return self:TrySelectCharacter(self.characterId)
end

function TB_CharacterSelector:TrySelectCharacter(selectId)
	--Select chosen character, if not hidden or deleted, otherwise the next best character
	--Try and show the chosen character
	local found = self:SelectCharacter(selectId)
	--Try and show the first visible character
	if not found then
		for k,id in ipairs(TraitBuddy:GetCharacters(true)) do
			found = self:SelectCharacter(id)
			if found then break end
		end
	end
	--Try and show the current character
	if not found then
		found = self:SelectCharacter(self.characterId)
	end	
	--No one selected
	if not found then
		TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
		TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
		TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
		TraitBuddy.ui.motifs:UpdateUI()
	end
	return found
end

function TB_CharacterSelector:Show()
	if self.parent:IsHidden() then
		self.parent:SetHidden(false)
	end
	self:ShowBar(TraitBuddy.settings.alternativeSelection)
end

function TB_CharacterSelector:ShowDropdown(visible)
	self.dropdown:SetHidden(not visible)
	self.alternative:SetHidden(visible)
end

function TB_CharacterSelector:ShowBar(visible)
	self.dropdown:SetHidden(visible)
	self.alternative:SetHidden(not visible)
end

function TB_CharacterSelector:Hide()
	if not self.parent:IsHidden() then
		self.parent:SetHidden(true)
	end
end

function TB_CharacterSelector_Button_OnMouseEnter(btn)
	local buttonData = ZO_MenuBarButtonTemplate_GetData(btn)
	ZO_MenuBarButtonTemplate_OnMouseEnter(btn)
	InitializeTooltip(InformationTooltip, btn, TOP, 0, 5)
	local c = TraitBuddy:GetCharacter(buttonData.descriptor)
	if c then
		SetTooltipText(InformationTooltip, c.name, 1, 1, 1)
	end
	SetTooltipText(InformationTooltip, sf("%s, %s", buttonData.className, buttonData.raceName))
end
function TB_CharacterSelector_Button_OnMouseExit(btn)
	ZO_MenuBarButtonTemplate_OnMouseExit(btn)
	ZO_Tooltips_HideTextTooltip()
end
