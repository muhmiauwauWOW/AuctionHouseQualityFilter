local addonName, AHQF  = ...

local db_defaults = {
	showButtons = true,
	state = {true, true, true}
}

AHQF.initializated = false
function AHQF:Init()
	if AHQF.initializated then return end 
	AHQFDB = AHQFDB or db_defaults

	AHQF:InitOptions()
	AHQF.initializated = true

	AuctionHouseFrame:HookScript("OnShow", function()
		AHQFQualitySelectFrame:SetShown(AHQFDB.showButtons)
	end)

	AHQFQualitySelectFrame:SetShown(AHQFDB.showButtons)
	
	local function IsSelected(filter)
		return AHQFDB.state[filter];
	end

	local function SetSelected(filter)
		AHQFQualitySelectFrame[string.format("Quality%s", filter)]:SetTierState(not AHQFDB.state[filter])
	end

	Menu.ModifyMenu("MENU_AUCTION_HOUSE_SEARCH_FILTER", function(ownerRegion, rootDescription, contextData)
		rootDescription:CreateTitle(addonName)
		for i = 1, 3, 1 do
			local icon = CreateAtlasMarkupWithAtlasSize(string.format("Professions-Icon-Quality-Tier%s-Small", i), 0, 0, nil,nil, nil, 0.6)
			rootDescription:CreateCheckbox(icon, IsSelected, SetSelected, i);
		end
	end)

end


AHQF.browseResults = nil
function AHQF:Filter(chached)
    local newTable = {}
	for _, entry in ipairs(AHQF.browseResults) do
		if not entry then return end
		local keep = true

		local quality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(entry.itemKey.itemID)
		if quality then 
			keep = AHQFDB.state[quality]
		end
		if keep then
			table.insert(newTable, entry)
		end
	end

    AuctionHouseFrame.BrowseResultsFrame.browseResults = newTable
    AuctionHouseFrame.BrowseResultsFrame.ItemList.scrollFrameDirty = true;
end


AHQF.loaded = CreateFrame("Frame")
AHQF.loaded:RegisterEvent("ADDON_LOADED")
AHQF.loaded:SetScript("OnEvent", function()
	AHQF:Init()
end)


AHQF.eventFrame = CreateFrame("Frame")
AHQF.eventFrame:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_ADDED")
AHQF.eventFrame:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
AHQF.eventFrame:SetScript("OnEvent", function()
	AHQF.browseResults = CopyTable(AuctionHouseFrame.BrowseResultsFrame.browseResults)
	AHQF:Filter()
end)





AHQFQualitySelectMixin = {}
function AHQFQualitySelectMixin:OnLoad()
    self:SetParent(AuctionHouseFrame.SearchBar.FilterButton)
end

AHQFQualitySelectButtonMixin = {}
function AHQFQualitySelectButtonMixin:OnLoad()
    self:SetAtlas(self.iconAtlas, 0.6);
    SquareIconButtonMixin.OnLoad(self)
    self.normalTexture = self:GetNormalTexture()
    self.disabledTexture = self:GetDisabledTexture()
end

function AHQFQualitySelectButtonMixin:OnShow()
    self:SetTierState(AHQFDB.state[self.tier])
end

function AHQFQualitySelectButtonMixin:OnClick()
	local state = not AHQFDB.state[self.tier]
    self:SetTierState(state)
	self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
    AHQF:Filter(true)
end

function AHQFQualitySelectButtonMixin:SetTierState(state)
    local newTexture = state and self.normalTexture or self.disabledTexture        
	self:SetNormalTexture(newTexture)
	self.Icon:SetDesaturated(not state);
	AHQFDB.state[self.tier] = state
end


function  AHQF.InitOptions()
	local AddOnInfo = {C_AddOns.GetAddOnInfo(addonName)}
    local category, layout = Settings.RegisterVerticalLayoutCategory(AddOnInfo[2])
    AHQF.OptionsID = category:GetID()
	local setting = Settings.RegisterAddOnSetting(category, "showButtons", "showButtons", AHQFDB, "boolean", "Show Buttons", AHQFDB.showButtons)
	Settings.CreateCheckbox(category, setting, nil)
    Settings.RegisterAddOnCategory(category)

	--
	AddonCompartmentFrame:RegisterAddon({
		text = AddOnInfo[2],
		notCheckable = true,
		func = function()
			Settings.OpenToCategory(AHQF.OptionsID)
		end,
	})
end