local _, L = ...;
local TAG = "IEH:"

local eventResponseFrame = CreateFrame("Frame", "Helper")
	eventResponseFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	eventResponseFrame:RegisterEvent("CURSOR_UPDATE");


local function eventHandler(self, event)
    if (event == "UPDATE_MOUSEOVER_UNIT") then
        function__wait(0.1, IslandExpeditionHelper_addValueToTooltip)
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
    --["Meeting Stone"] = 666,
    ["Aerin Skyhammer"] = 400,
    ["Ancient Forest-Walker"] = 150,
    ["Arwan Beastheart"] = 400,
    ["Azerite Chunk"] = 125,
    ["Azerite Crystal"] = 175,
    ["Azerite Shard"] = 75,
    ["Bag of Azerite"] = 100,
    ["Breakbeak Bonepicker"] = 150,
    ["Breakbeak Hatchling"] = 2,
    ["Breakbeak Scavenger"] = 10,
    ["Breakbeak Vulture"] = 6,
    ["Brightscale Coilfang"] = 150,
    ["Brightscale Hatchling"] = 2,
    ["Brightscale Screecher"] = 10,
    ["Brightscale Wind Serpent"] = 6,
    ["Broken Azerite Shard"] = 25,
    ["Crag Rager"] = 10,
    ["Cragburster"] = 200,
    ["Deepstone Crusher"] = 150,
    ["Dryad Grove-Tender"] = 150,
    ["Earth Elemental"] = 6,
    ["Eso the Fathom-Hunter"] = 300,
    ["Evergrove Keeper"] = 150,
    ["Garnetback Striker"] = 10,
    ["Garnetback Worm"] = 6,
    ["Grrl"] = 200,
    ["Guuru the Mountain-Breaker"] = 300,
    ["Malachite"] = 200,
    ["Mechanical Guardhound"] = 6,
    ["Mischievous Flood"] = 10,
    ["Mrogan"] = 300,
    ["Muckfin Murloc"] = 6,
    ["Muckfin Oracle"] = 10,
    ["Muckfin Puddlejumper"] = 2,
    ["Muckfin Tidehunter"] = 6,
    ["Nasira Morningfrost"] = 300,
    ["Nettlevine Sprite"] = 6,
    ["Old Chest"] = 100,
    ["Old Li"] = 400,
    ["Pouch of Azerite"] = 50,
    ["Profit-O-Matic"] = 10,
    ["Razorfin Aqualyte"] = 10,
    ["Razorfin Impaler"] = 10,
    ["Razorfin Javelineer"] = 6,
    ["Razorfin Jinyu"] = 6,
    ["Razorfin Watershaper"] = 150,
    ["Razorfin Waveguard"] = 150,
    ["Reinforced Chest"] = 150,
    ["Rotting Wooden Chest"] = 150,
    ["Rumbling Earth"] = 2,
    ["Sack of Azerite"] = 300,
    ["Safety Inspection Bot"] = 2,
    ["Senior Producer Gixi"] = 300,
    ["Tidestriker Ocho"] = 200,
    ["Trickle"] = 200,
    ["Venture Goon"] = 6,
    ["Venture Inspector"] = 6,
    ["Venture Oaf"] = 10,
    ["Venture Surveyor"] = 10,
    ["Verdant Dryad"] = 10,
    ["Verdant Flytrap"] = 6,
    ["Verdant Keeper"] = 10,
    ["Verdant Lasher"] = 2,
    ["Verdant Spitter"] = 6,
    ["Verdant Tender"] = 10,
    ["Verdant Treant"] = 10,
    ["Vicejaw Crocolisk"] = 6,
    ["Water Spirit"] = 6,
    ["Witherbranch Berserker"] = 150,
    ["Witherbranch Warrior"] = 6,
    ["Wooden Strongbox"] = 50,
    ["Zgordo the Brutalizer"] = 300
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
    if key ~= nil and shrines[key] ~= nil and checkTooltipForDuplicates() == nil then
        local infoTextP = shrines[key]["positiv"]
        local infoTextN = shrines[key]["negativ"]
        if infoTextP ~= nil and infoTextN ~= nil and checkTooltipForDuplicates() then
            GameTooltip:AddLine("IEH: "..L[infoTextP], 0, 1, 0, 1, 0)
            GameTooltip:AddLine("IEH: "..L[infoTextN], 1, 0, 0, 1, 0)
            GameTooltip:Show()
        end
    end
end

function IslandExpeditionHelper_addValueToTooltip()
    local key = GameTooltipTextLeft1:GetText()
    if key ~= nil and azerite[key] ~= nil then
        local infoText = azerite[key]
        if infoText ~= nil and checkTooltipForDuplicates() then
            GameTooltip:AddLine("IEH: "..adjustToDifficulty(infoText), 0.9, 0.8, 0.5, 1, 0)
            GameTooltip:Show()
        end
    end
end

function checkTooltipForDuplicates()
    for i=1,GameTooltip:NumLines() do
        local tooltip=_G["GameTooltipTextLeft"..i]
        local tt = tooltip:GetText()
        if string.find(tt, TAG) ~= nil then
            return false
        end
    end
    return true
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


function adjustToDifficulty(value)
    _,_,_, diff = GetInstanceInfo()
    if diff == "Normal" then
        return value
    elseif diff == "Heroic" then
        return value*1.5
    elseif diff == "Mythic" then
        return value*2
    elseif diff == "PvP" then --TODO find real value
        return value*2
    end
    
    return value;
end




