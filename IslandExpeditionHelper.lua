IslandExpeditionHelper = {}
local name, addon = ...;
local _, L = ...;
local TAG = "IEH"

local azeriteValuesLocal = {}

local removeAzeriteSpam

local eventResponseFrame = CreateFrame("Frame", "Helper")
    eventResponseFrame:RegisterEvent("ADDON_LOADED");
	eventResponseFrame:RegisterEvent("PLAYER_LOGIN")
	eventResponseFrame:RegisterEvent("PLAYER_LOGOUT")
	eventResponseFrame:RegisterEvent("ZONE_CHANGED")
	eventResponseFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
	eventResponseFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	--eventResponseFrame:RegisterEvent("ISLANDS_QUEUE_OPEN")
	--eventResponseFrame:RegisterEvent("ISLANDS_QUEUE_CLOSE")

local EXP_MAP_IDS = {
	[981] = "Un'gol Ruins",
	[1032] = "Skittering Hollow", --1898
	[1033] = "Rotten Mire", --1892
	[1034] = "Verdant Wilds", -- 1882
	[1035] = "Molten Clay", --1897
	[1036] = "The Dread Chain", --1893
	[1037] = "Whispering Reef", --1883
	[1336] = "Havenswood",
	[1337] = "Jorundall",
	[1501] = "Crestfall", --1709(?)
	[1502] = "Snowblossom Village",
}

local azeriteGainString = string.gsub(AZERITE_ISLANDS_XP_GAIN, "%%d", "(%%d+)", 1)
azeriteGainString = string.gsub(azeriteGainString, "%%s", "(.+)", 1)

local azeriteGainStringShort = string.gsub(AZERITE_ISLAND_POWER_GAIN_SHORT, "+%%s ", "", 1)

local function eventHandler(self, event, arg1, arg2, arg3, arg4, arg5)
    if (event == "UPDATE_MOUSEOVER_UNIT") then
        IslandExpeditionHelper.function__wait(0.1, IslandExpeditionHelper.addValueToTooltip)
    elseif (event == "CURSOR_UPDATE") then
        IslandExpeditionHelper.function__wait(0.1, IslandExpeditionHelper.addShrineTooltip)
        IslandExpeditionHelper.function__wait(0.1, IslandExpeditionHelper.addValueToTooltip)
    elseif(event == "ADDON_LOADED" and arg1 == "IslandExpeditionHelper") then
        if (GetLocale() ~= "deDE" and GetLocale() ~= "enGB" and GetLocale() ~= "enUS" and GetLocale() ~= "frFR") then
            print("IslandExpeditionHelper: Your language is currently NOT fully supported. This addon will only work partially! Please consider providing some translations via the projects website: https://wow.curseforge.com/projects/islandexpeditionhelper")
        end
	elseif(event == "PLAYER_LOGIN") then
		IslandExpeditionHelper.loadSV()
		IslandExpeditionHelper.createMenuFrame()
		IslandExpeditionHelper.toggleAddon()
	elseif(event == "PLAYER_LOGOUT") then
		IslandExpeditionHelper.saveSV()
	elseif event == "ISLAND_COMPLETED" then
		IslandExpeditionHelper.unregisterAddon()		
    end			  
	if event == "ZONE_CHANGED_NEW_AREA" then --entering/leaving expedition
		IslandExpeditionHelper.toggleAddon()
	end
end
eventResponseFrame:SetScript("OnEvent", eventHandler);

function IslandExpeditionHelper.registerAddon()
	eventResponseFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	eventResponseFrame:RegisterEvent("CURSOR_UPDATE");
	--eventResponseFrame:RegisterEvent("ISLAND_AZERITE_GAIN")
	eventResponseFrame:RegisterEvent("ISLAND_COMPLETED")
	print("IslandExpeditionHelper loaded")
end

function IslandExpeditionHelper.unregisterAddon()
	eventResponseFrame:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
	eventResponseFrame:UnregisterEvent("CURSOR_UPDATE");
	--eventResponseFrame:UnregisterEvent("ISLAND_AZERITE_GAIN")
	--eventResponseFrame:UnregisterEvent("ISLAND_COMPLETED")
	--print("IslandExpeditionHelper unloaded")
end

function IslandExpeditionHelper.toggleAddon() 
	if IslandExpeditionHelper.isInExpedition() then
		IslandExpeditionHelper.registerAddon()
	else 
		IslandExpeditionHelper.unregisterAddon()
	end
end

function IslandExpeditionHelper.isInExpedition()
	local mapid = C_Map.GetBestMapForUnit("player");
	--print(EXP_MAP_IDS[mapid])
	if EXP_MAP_IDS[mapid] ~= nil then
		--print("in Expedition Zone")
		return true
	end
	--print("not in Expedition Zone")
	return false
end											   
local shrines = { -- [""] = {["positiv"] = "", ["negativ"] = ""},
    ["Altar of the Sea"] = {["positiv"] = "30Haste", ["negativ"] = "Periodic Frost Damage"}, -- 272644
    ["Cursed Offering"] = {["positiv"] = "30mastery", ["negativ"] = "50health"}, -- 277523
    ["Death Ward"] = {["positiv"] = "30shadowDone", ["negativ"] = "50holyTaken"}, -- 281844
    ["Deepwoods Totem"] = {["positiv"] = "30natureDone", ["negativ"] = "50arcanTaken"}, -- 281838
    ["Moon-Touched Ruins"] = {["positiv"] = "30crit", ["negativ"] = "50magicTaken"}, -- 277562
    ["Overgrown Relic"] = {["positiv"] = "30holyDone", ["negativ"] = "50shadowTaken"}, -- 281836
    ["Pillar of the Watchers"] = {["positiv"] = "30healDoneAndTaken", ["negativ"] = "nodef"}, -- 272643
    ["Primal Shrine"] = {["positiv"] = "30physicalDone", ["negativ"] = "50armor"}, -- 270021
    ["Rune-Etched Stone"] = {["positiv"] = "30arcanDone", ["negativ"] = "50natureTaken"}, -- 281839
    ["Slithering Shrine"] = {["positiv"] = "30move", ["negativ"] = "buffAndPurgeDoes80pDmg"}, -- 277522
    ["Spirit Font"] = {["positiv"] = "Retaliation Damage Procs", ["negativ"] = "none"}, -- 281834
    ["Wanderer's Respite"] = {["positiv"] = "30versa", ["negativ"] = "60healTaken"}, -- 277525
    ["Fireheart Idol"] = {["positiv"] = "30firedone", ["negativ"] = "50frosttaken"} -- 281843
}

function IslandExpeditionHelper.addShrineTooltip()
    local tkey = GameTooltipTextLeft1:GetText()
    local key = L[tkey]

    if key ~= nil and shrines[key] ~= nil and IslandExpeditionHelper.checkTooltipForDuplicates() then
        local infoTextP = shrines[key]["positiv"]
        local infoTextN = shrines[key]["negativ"]
        if infoTextP ~= nil and infoTextN ~= nil then
            GameTooltip:AddLine("IEH: "..L[infoTextP], 0, 1, 0, 1, 0)
            GameTooltip:AddLine("IEH: "..L[infoTextN], 1, 0, 0, 1, 0)
            GameTooltip:Show()
        end
    end
end

function IslandExpeditionHelper.addValueToTooltip()
    local key = GameTooltipTextLeft1:GetText()
	--print(key)
	if key ~= nil then
		local infoText, prefix
		local _,_,_, difficulty = GetInstanceInfo()
		if addon.values[key] ~= nil then
			infoText = addon.values[key][difficulty]
			prefix = "IEH: "
		elseif azeriteValuesLocal ~= nil and azeriteValuesLocal[key] ~= nil and azeriteValuesLocal[key][difficulty] ~= nil then
			infoText = azeriteValuesLocal[key][difficulty]
			prefix = "IEH*: "
		end
		if infoText ~= nil and IslandExpeditionHelper.checkTooltipForDuplicates() then
			GameTooltip:AddLine(prefix..infoText, 0.9, 0.8, 0.5, 1, 0)
			GameTooltip:Show()
		end
	end
end

function IslandExpeditionHelper.checkTooltipForDuplicates()
    for i=1,GameTooltip:NumLines() do
        local tooltip=_G["GameTooltipTextLeft"..i]
        local tt = tooltip:GetText()
        if tt ~= nil and string.find(tt, TAG) ~= nil then
            return false
        end
    end
    return true
end


local waitTable = {};
local waitFrame = nil;

function IslandExpeditionHelper.function__wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

function IslandExpeditionHelper.myChatFilter(self, event, msg, author, ...) 
	if event == "CHAT_MSG_SYSTEM" then
		--print(event, msg)
		return IslandExpeditionHelper.deriveAzerite(msg)
	end	
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", IslandExpeditionHelper.myChatFilter)

function IslandExpeditionHelper.deriveAzerite(msg)
	if string.find(msg, azeriteGainStringShort) ~= nil then 
		local value, unit = string.match(msg, azeriteGainString)
		--print(L["azeriteString"])
		--print(found, unit)
		--local value = IslandExpeditionHelper.adjustBackToDifficulty(foundValue)
		if azeriteValuesLocal == nil then
			azeriteValuesLocal = {}
		end
		local _,_,_, difficulty = GetInstanceInfo()
		if azeriteValuesLocal[unit] == nil then
			azeriteValuesLocal[unit] = {}
		end
		--print("azeriteValuesLocal[unit][difficulty]", unit, difficulty, azeriteValuesLocal[unit][difficulty])
		if azeriteValuesLocal[unit][difficulty] == nil then
			azeriteValuesLocal[unit][difficulty] = tonumber(value)
						
			--print(string.format("adding new value (%s) for unit (%s) to map on difficulty (%s)", value, unit, difficulty))
		--[[elseif azeriteValuesLocal[unit] ~= nil and azeriteValuesLocal[unit] ~= value then
			--print(string.format("found conflicting value (map %s, found %s) for unit (%s)", value, foundValue, unit))
			--TODO maybe override?
		else
			--print(string.format("correct value (map %s, found %s) for unit (%s)", value, foundValue, unit))]]--
		end	
		if removeAzeriteSpam then
			--print("remove spam", msg)
			return true
		end		
	end	
end

function IslandExpeditionHelper.removeValues() -- TODO translations
	--Alliance NPCs
	azeriteValuesLocal["\"Stabby\" Lottie"] = nil
	azeriteValuesLocal["Anchorite Lanna"] = nil
	azeriteValuesLocal["Archmage Tamuura"] = nil
	azeriteValuesLocal["Briona the Bloodthirsty"] = nil
	azeriteValuesLocal["Dizzy Dina"] = nil
	azeriteValuesLocal["Duskrunner Lorinas"] = nil
	azeriteValuesLocal["Fenrae the Cunning"] = nil
	azeriteValuesLocal["Frostfencer Seraphi"] = nil
	azeriteValuesLocal["Gunnolf the Ferocious"] = nil
	azeriteValuesLocal["Raul the Tenacious"] = nil
	azeriteValuesLocal["Razak Ironsides"] = nil
	azeriteValuesLocal["Riftblade Kelain"] = nil
	azeriteValuesLocal["Shadeweaver Zarra"] = nil
	azeriteValuesLocal["Squallshaper Auran"] = nil
	azeriteValuesLocal["Squallshaper Bryson"] = nil
	azeriteValuesLocal["Tally Zapnabber"] = nil
	azeriteValuesLocal["Varigg"] = nil
	azeriteValuesLocal["Vindicator Baatul"] = nil
	
	--Horde NPCs
	azeriteValuesLocal["Gazlowe"] = nil
	azeriteValuesLocal["Skaggit"] = nil
	azeriteValuesLocal["Dorp"] = nil
	azeriteValuesLocal["Astralite Visara"] = nil
	azeriteValuesLocal["Rune Scribe Lusaris"] = nil
	azeriteValuesLocal["Phoenix Mage Ryleia"] = nil
	azeriteValuesLocal["Berserker Zar'ri"] = nil
	azeriteValuesLocal["Witch Doctor Unbugu"] = nil
	azeriteValuesLocal["Spiritwalker Quura"] = nil
	azeriteValuesLocal["Lady Sena"] = nil
	azeriteValuesLocal["Captain Greenbelly "] = nil
	azeriteValuesLocal["Sneaky Pete"] = nil
	azeriteValuesLocal["Moonscythe Pelani"] = nil
	azeriteValuesLocal["Phoenix Mage Rhydras"] = nil
	azeriteValuesLocal["Sunbringer Firasi"] = nil
	azeriteValuesLocal["Shadow Hunter Ju'loa"] = nil
	azeriteValuesLocal["Mahna Flamewhisper"] = nil
	azeriteValuesLocal["Sunwalker Ordel"] = nil
end

function IslandExpeditionHelper.loadSV()
	azeriteValuesLocal = AzeriteValuesWithDifficulty
	if azeriteValuesLocal == nil then
		azeriteValuesLocal = {}
	end
	removeAzeriteSpam = AzeriteSpam
	if removeAzeriteSpam == nil then
		removeAzeriteSpam = false
	end
end

function IslandExpeditionHelper.saveSV()
	IslandExpeditionHelper.removeValues()
	table.sort(azeriteValuesLocal)
	AzeriteValuesWithDifficulty = azeriteValuesLocal;
	AzeriteSpam = removeAzeriteSpam
end


local configFrame = CreateFrame('Frame');
local configTitle = nil;
local configSpam = nil;

function IslandExpeditionHelper.refresh()
	configSpam:SetChecked(AzeriteSpam)
end

function IslandExpeditionHelper.createMenuFrame()
	IslandExpeditionHelper.createConfigFrame()
	configFrame.name = "Island Exploration Helper";
	configFrame.refresh = IslandExpeditionHelper.refresh();
	InterfaceOptions_AddCategory(configFrame)
end


function IslandExpeditionHelper.createConfigFrame()
	configTitle = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    configTitle:SetPoint("TOPLEFT", 16, -16)
    configTitle:SetText("Island Expedition Helper")
	
	configSpam = IslandExpeditionHelper.createCheckbox(
    	L["Disable Azerite Spam"],
    	L["Hide all Azerite related collection messages from the chat."],
    	function(self, value) IslandExpeditionHelper.DisplaySpam(value) end)
    configSpam:SetPoint("TOPLEFT", configTitle, "BOTTOMLEFT", 0, -8)
	
	configBottom = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    configBottom:SetPoint("BOTTOMLEFT", 16, 16)
    configBottom:SetText("If you want to help translate this addon, visit\n https://wow.curseforge.com/projects/islandexpeditionhelper/ \nor write me a PM on CurseForge. \nCurrently only German and English translations are available.")
end

function IslandExpeditionHelper.DisplaySpam(bool)
	removeAzeriteSpam = bool;
end

function IslandExpeditionHelper.createCheckbox(label, description, onClick)
	local check = CreateFrame("CheckButton", "IAConfigCheckbox" .. label, configFrame, "InterfaceOptionsCheckButtonTemplate")
	check:SetScript("OnClick", function(self)
		PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		onClick(self, self:GetChecked() and true or false)
	end)
	check.label = _G[check:GetName() .. "Text"]
	check.label:SetText(label)
	check.tooltipText = label
	check.tooltipRequirement = description
	return check
end

function IslandExpeditionHelper.mapinfo(name) -- name = "Un'gol Ruins"
	local id = -1
	for i=1,1300 do
		if C_Map.GetMapInfo(i) ~= nil then
			--print(i, C_Map.GetMapInfo(i).name)
			if C_Map.GetMapInfo(i).name == name then
				id = i
			end
		end
	end
	print(id)
end