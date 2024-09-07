local addonName, AHQF  = ...

local db_defaults = {
	state = {true, true, true}
}


AHQF.browseResults = nil
function AHQF:Filter(chached)
    local newTable = {}
	for index, entry in ipairs(AHQF.browseResults) do
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
	AHQFDB = AHQFDB or db_defaults
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

