local _, L = ...;

local eventResponseFrame = CreateFrame("Frame", "Helper")
	--eventResponseFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	eventResponseFrame:RegisterEvent("CURSOR_UPDATE");


local function eventHandler(self, event)
    if (event == "UPDATE_MOUSEOVER_UNIT") then
        
    elseif (event == "CURSOR_UPDATE") then
        function__wait(0.1, IslandExpeditionHelper_addShrineTooltip)
        function__wait(0.1, IslandExpeditionHelper_addValueToTooltip)
    end
end
eventResponseFrame:SetScript("OnEvent", eventHandler);

local shrines = { -- [""] = {["positiv"] = "", ["negativ"] = ""},
    ["Altar of the Sea"] = {["positiv"] = "30Haste", ["negativ"] = "Periodic Frost Damage"},
    ["Cursed Offering"] = {["positiv"] = "30mastery", ["negativ"] = "50health"},
    ["Death Ward"] = {["positiv"] = "30shadowDone", ["negativ"] = "50holyTaken"},
    ["Deepwoods Totem"] = {["positiv"] = "30natureDone", ["negativ"] = "50arcanTaken"},
    ["Moon-Touched Ruins"] = {["positiv"] = "30crit", ["negativ"] = "50magicTaken"},
    ["Overgrown Relic"] = {["positiv"] = "30holyDone", ["negativ"] = "50shadowTaken"},
    ["Pillar of the Watchers"] = {["positiv"] = "30healDoneAndTaken", ["negativ"] = "nodef"},
    ["Primal Shrine"] = {["positiv"] = "30physicalDone", ["negativ"] = "50armor"},
    ["Rune-Etched Stone"] = {["positiv"] = "30arcanDone", ["negativ"] = "50natureTaken"},
    ["Slithering Shrine"] = {["positiv"] = "30move", ["negativ"] = "buffAndPurgeDoes80pDmg"},
    ["Spirit Font"] = {["positiv"] = "Retaliation Damage Procs", ["negativ"] = "none"},
    ["Wanderer's Respite"] = {["positiv"] = "30versa", ["negativ"] = "60healTaken"}
}

local azerite = {
    ["Azerite Shard"] = "75",
    ["Azerite Chunk"] = "125",
    ["Azerite Crystal"] = "175",
    ["Sack of Azerite"] = "300",
    ["Broken Azerite Shard"] = "25",    
    ["Rotting Wooden Chest"] = "150+trap",
    ["Wooden Strongbox"] = "50",
    ["Reinforced Chest"] = "150"
}

local food = {
    ["Cabbage"] = 15000
}

local misc = {
    ["Starfish"] = "stun + 10%dmg"
}

function IslandExpeditionHelper_addShrineTooltip()
    local key = GameTooltipTextLeft1:GetText()
    --print("shrine",key)
    if key ~= nil and shrines[key] ~= nil and GameTooltipTextLeft2:GetText() == nil then -- shrines only have one line
        local infoTextP = shrines[key]["positiv"]
        local infoTextN = shrines[key]["negativ"]
        if infoTextP ~= nil and infoTextN ~= nil then
            GameTooltip:AddLine(L[infoTextP], 0, 1, 0, 1, 0)
            GameTooltip:AddLine(L[infoTextN], 1, 0, 0, 1, 0)
            GameTooltip:Show()
        end
    end
end

function IslandExpeditionHelper_addValueToTooltip()
    local key = GameTooltipTextLeft1:GetText()
    if key ~= nil and azerite[key] ~= nil then
        local infoText = azerite[key]
        if infoText ~= nil then
            GameTooltip:AddLine(infoText, 0.9, 0.8, 0.5, 1, 0)
            GameTooltip:Show()
        end
    end
end



local waitTable = {};
local waitFrame = nil;

function function__wait(delay, func, ...)
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

