local sf = string.format

local function TreeHeaderSetup(node, control, data, open)
	local ctrl = control:GetNamedChild("SetName")
	ctrl:SetText(data.name)
	local ctrl = control:GetNamedChild("Traits")
	ctrl:SetText(data.traits)

	control.key = data.key
end
local function TreeEntrySetup(node, control, data, open)
	local ctrl = control:GetNamedChild("Location")
	ctrl:SetText(data.name)
end
local function TreeHeaderEquality(left, right)
	return left.data.name == right.data.name
end
local function TreeEntryEquality(left, right)
	return left.data.name == right.data.name
end
local function SortByName(left, right)
    return left.name < right.name
end
local function SortByTrait(left, right)
	if left.traits == right.traits then
		return left.name < right.name
	else
		return left.traits < right.traits
	end
end

TB_Sets = ZO_Object:Subclass()

function TB_Sets:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_Sets:Initialize(parent)
	self.parent = parent
	self.scrollContainer = self.parent:GetNamedChild("ScrollChild")
	self.tree = ZO_Tree:New(self.scrollContainer, 0, 0, 500)
	self.tree:SetOpenAnimation("ZO_TreeOpenAnimation")
	self.tree:AddTemplate("TB_SetsHeader", TreeHeaderSetup, nil, TreeHeaderEquality, 0, 0)
	self.sortByName = 1
	self.sortByTrait = 2
	self.qualityColor = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_LEGENDARY)
	self:Create()
end

function TB_Sets:Show()
	if self.parent:IsHidden() then
		self.parent:SetHidden(false)
	end
end

function TB_Sets:Hide()
	if not self.parent:IsHidden() then
		self.parent:SetHidden(true)
	end
end

function TB_Sets:Create()
	--Populate tree with all sets
	local tree = self.tree
	tree:Reset()
	local sets = TraitBuddy.data:GetSets()
	table.sort(sets, SortByName)
	for i,set in pairs(sets) do
		local header = tree:AddNode("TB_SetsHeader", {key=i, id=set.id, name=set.name, traits=set.traits}, nil, nil)
	end
end

function TB_Sets:Header_OnMouseEnter(header)
	local set = TraitBuddy.data:GetSet(header.key)
	local itemLink = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,set.id,370,50,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,10000,0)

	InitializeTooltip(InformationTooltip, header, LEFT, 5, 0)
	InformationTooltip:AddLine(set.name, "ZoFontHeader3", self.qualityColor.r,self.qualityColor.g,self.qualityColor.b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	InformationTooltip:AddLine(sf("%d %s", set.traits, GetString(SI_CRAFTING_COMPONENT_TOOLTIP_TRAITS)), "ZoFontHeader2", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	ZO_Tooltip_AddDivider(InformationTooltip)
	local _, setName, numBonuses, _, _, _ = GetItemLinkSetInfo(itemLink, false)
	for i=1, numBonuses do
		local numRequired, bonusDescription = GetItemLinkSetBonusInfo(itemLink, false, i)
		InformationTooltip:AddLine(bonusDescription, "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	end
	InformationTooltip:AddVerticalPadding(5)
	InformationTooltip:AddLine(GetString(SI_MAP_INFO_MODE_LOCATIONS), "ZoFontHeader2", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	ZO_Tooltip_AddDivider(InformationTooltip)
	for i,location in pairs(set.locations) do
		local zone = location.zone
		InformationTooltip:AddLine(zone:GetFormattedText(), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	end
end

function TB_Sets:Header_OnMouseExit(header)
	ZO_Tooltips_HideTextTooltip()
end
