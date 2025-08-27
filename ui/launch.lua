function TB_Launch_OnMouseEnter(control)
	InitializeTooltip(InformationTooltip, control, RIGHT, 0, 0)
	SetTooltipText(InformationTooltip, TraitBuddy.ADDON_NAME)
end

function TB_Launch_OnMouseClicked(control)
	TraitBuddy.ui:Toggle()
end

local function GetFirstKeyCode()
	local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName("TB_TOGGLE_GUI")
	for bindingIndex = 1, GetMaxBindingsPerAction() do
		local keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, bindingIndex)
		if keyCode ~= KEY_INVALID then
			return keyCode
		end
	end
end

local function IsHarvensInstalled()
	if (HarvensSkillTooltipTopLevelMorph1 or HarvensSkillTooltipTopLevelMorph2) then
		return true
	else
		return false
	end
end

TB_Launcher = ZO_Object:Subclass()

function TB_Launcher:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_Launcher:Initialize(launcherType)
	self.launcherType = launcherType
	self.launcher = {}

	skills = ZO_Skills
	if IsInGamepadPreferredMode() then
	  skills = ZO_GamepadSkillsTopLevel
	end
	--create/parent/anchors accordingly
	if launcherType == "skills" then
		self.launcher.normal = CreateControlFromVirtual("$(parent)TBLaunch", skills, "TB_Launch")
		if IsHarvensInstalled() then
			self.launcher.normal:SetAnchor(BOTTOMRIGHT, skills, TOPRIGHT, -320, 0)
		else
		  self.launcher.normal:SetAnchor(BOTTOMRIGHT, skills, TOPRIGHT, -320, 0)
		end
		
		--self.launcher.gamepad = CreateControlFromVirtual("$(parent)TBLaunchGamepad", ZO_Skills, "TB_Launch_Gamepad")
		--self.launcher.gamepad:SetAnchor(BOTTOMRIGHT, ZO_Skills, TOPRIGHT, -100, -60)
	end
	if launcherType == "smithing" then
	  if not IsInGamepadPreferredMode() then
      self.launcher.normal = CreateControlFromVirtual("$(parent)TBLaunch", ZO_SmithingTopLevel, "TB_Launch")
      self.launcher.normal:SetAnchor(BOTTOMRIGHT, ZO_SmithingTopLevelCreationPanel, TOPRIGHT, -20, -60)
		else
      self.launcher.gamepad = CreateControlFromVirtual("$(parent)TBLaunch", ZO_GamepadSmithingTopLevel, "TB_Launch_Gamepad")
      self.launcher.gamepad:SetAnchor(BOTTOMRIGHT, ZO_GamepadSmithingTopLevel, TOPRIGHT, 0, 0)
		end
	end
	if launcherType == "guildstore" then
	  if not IsInGamepadPreferredMode() then
      self.launcher.normal = CreateControlFromVirtual("$(parent)TBLaunch", ZO_TradingHouse, "TB_Launch")
      self.launcher.normal:SetAnchor(BOTTOMRIGHT, ZO_TradingHouse, TOPRIGHT, -20, -60)
    else
      self.launcher.gamepad = CreateControlFromVirtual("$(parent)TBLaunch", ZO_TradingHouse_Gamepad, "TB_Launch")
      self.launcher.gamepad:SetAnchor(BOTTOMRIGHT, ZO_TradingHouse_Gamepad, TOPRIGHT, -20, -60)
    end
	end
	--self:SetGamepadText()
end

function TB_Launcher:SetState(state)
	if self.launcher.normal then
		self.launcher.normal:SetState(state)
	end
	if self.launcher.gamepad then
		local button = self.launcher.gamepad:GetNamedChild("Button")
		if button then
		  button:SetState(state)
    end
	end
end

function TB_Launcher:GetControl()
	if IsInGamepadPreferredMode() then
		return self.launcher.gamepad
	else
		return self.launcher.normal
	end
end

function TB_Launcher:SetHidden(bHidden)
	for k,launcher in pairs(self.launcher) do
		launcher:SetHidden(true)
	end
	if self.launcher.normal then
		return self.launcher.normal:SetHidden(bHidden == true)
	end
	if self.launcher.gamepad then
		return self.launcher.gamepad:SetHidden(bHidden == true)
	end
end

function TB_Launcher:SetGamepadText()
	if self.launcher.gamepad then
		self.launcher.gamepad:GetNamedChild("Name"):SetText(TraitBuddy.ADDON_NAME)
		local keyCode = GetFirstKeyCode()
		if keyCode then
			local markup
			if ZO_Keybindings_ShouldUseIconKeyMarkup(keyCode) then
				markup = ZO_Keybindings_GenerateIconKeyMarkup(keyCode, DEFAULT_SCALE_PERCENT)
			else
				-- ZO_Keybindings_ShouldUseTextKeyMarkup
				markup = ZO_Keybindings_GenerateTextKeyMarkup(GetKeyName(keyCode))
			end
			self.launcher.gamepad:GetNamedChild("Key"):SetText(markup)
		end
	end
end
