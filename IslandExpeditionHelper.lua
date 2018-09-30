IslandExpeditionHelper = {}
local _, L = ...;
local TAG = "IEH"

local localAzeriteValues = {}

local removeAzeriteSpam

local eventResponseFrame = CreateFrame("Frame", "Helper")
	eventResponseFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	eventResponseFrame:RegisterEvent("CURSOR_UPDATE");
    eventResponseFrame:RegisterEvent("ADDON_LOADED");
	eventResponseFrame:RegisterEvent("PLAYER_LOGIN")
	eventResponseFrame:RegisterEvent("PLAYER_LOGOUT")
	--eventResponseFrame:RegisterEvent("ISLAND_AZERITE_GAIN")
	--eventResponseFrame:RegisterEvent("ISLAND_COMPLETED")
	

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
        if (GetLocale() ~= "deDE" and GetLocale() ~= "enGB" and GetLocale() ~= "enUS") then
            print "IslandExpeditionHelper: Your language is currently NOT supported. This addon will NOT work! Please consider providing some translations via the projects website: https://wow.curseforge.com/projects/islandexpeditionhelper"
        end
	elseif(event == "PLAYER_LOGIN") then
		IslandExpeditionHelper.loadSV()
		IslandExpeditionHelper.createMenuFrame()
	elseif(event == "PLAYER_LOGOUT") then
		IslandExpeditionHelper.saveSV()
	--[[elseif event == "ISLAND_AZERITE_GAIN" then
		print(event, arg1, arg2, arg3, arg4, arg5)
		-- arg1 amount -- number
		-- arg1 gainedByPlayer -- boolean -> "did i myself loot it?"
		-- arg1 factionindex -- 1 -> alliance
		-- arg1 gainedBy -- Player-580-06E6A266 
		-- arg1 gainedFrom Creature-0-3889-1893-15970-130638-000630CAA0
		
		--TODO extended azerite messages?
	elseif event == "ISLAND_COMPLETED" then
		--arg1 mapid  	-- dread chain 1893
						-- rotten mire 1892
		--arg2 winner //1: alliance
		print(event, arg1, arg2)
		--TODO Scoreboard?]]--
    end
end
eventResponseFrame:SetScript("OnEvent", eventHandler);

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

local azerite = {
	--["Meeting Stone"] = 666,
	["Acidic Worm"] = 6,
	["Aerin Skyhammer"] = 400,
	["Ancient Forest-Walker"] = 150,
	["Apprentice Karyn"] = 400,
	["Arwan Beastheart"] = 400,
	["Autumnbreeze"] = 200,
	["Azerite Chunk"] = 125,
	["Azerite Crystal"] = 175,
	["Azerite Shard"] = 75,
	["Bag of Azerite"] = 100,
	["Banechitter"] = 300,
	["Battle-Mender Ka'vaz"] = 200,
	["Bonescale Spitter"] = 10,
	["Bonescale Worm"] = 6,
	["Bore Tunneler"] = 10,
	["Bore Worm"] = 6,
	["Bramblefur Bull"] = 150,
	["Bramblefur Grazer"] = 10,
	["Breakbeak Bonepicker"] = 150,
	["Breakbeak Hatchling"] = 2,
	["Breakbeak Scavenger"] = 10,
	["Breakbeak Vulture"] = 6,
	["Brightfire"] = 200,
	["Brightscale Coilfang"] = 150,
	["Brightscale Hatchling"] = 2,
	["Brightscale Screecher"] = 10,
	["Brightscale Wind Serpent"] = 6,
	["Brimstone Lavamaw"] = 150,
	["Brimstone Pup"] = 2,
	["Brimstone Tracker"] = 10,
	["Brineshell Crusher"] = 150,
	["Bristlemane Bramble-Weaver"] = 150,
	["Bristlemane Defender"] = 10,
	["Bristlemane Pathfinder"] = 6,
	["Bristlemane Quilboar"] = 6,
	["Bristlemane Squealer"] = 2,
	["Bristlemane Thorncaller"] = 10,
	["Bristlethorn Battleguard"] = 150,
	["Broken Azerite Shard"] = 25,
	["Broodwatcher Anub'akar"] = 300,
	["Congealed Azerite"] = 15,
	["Coralback Crab"] = 6,
	["Coralback Surfcrawler"] = 10,
	["Crag Rager"] = 10,
	["Cragburster"] = 200,
	["Craghoof Leaper"] = 10,
	["Craghoof Rockhorn"] = 150,
	["Daggertooth"] = 200,
	["Dampfur the Musky"] = 300,
	["Darktunnel Ambusher"] = 10,
	["Deathsting Broodwatcher"] = 150,
	["Deathsting Hatchling"] = 2,
	["Deathsting Lasher"] = 10,
	["Deathsting Scorpid"] = 6,
	["Deepstone Crusher"] = 150,
	["Defender Zakar"] = 200,
	["Doomtunnel"] = 450,
	["Dreadfang Slitherer"] = 2,
	["Dreadfang Viper"] = 10,
	["Driftstalker"] = 200,
	["Dryad Grove-Tender"] = 150,
	["Duke Szzull"] = 450,
	["Duskstalker Kuli"] = 200,
	["Earth Elemental"] = 6,
	["Earth Spirit"] = 6,
	["Earthliving Giant"] = 450,
	["Elder Akar'azan"] = 200,
	["Encrusted Coralback"] = 150,
	["Eso the Fathom-Hunter"] = 300,
	["Evergrove Keeper"] = 150,
	["Feral Guardian"] = 6,
	["Feral Hunter"] = 10,
	["Feral Moonkin"] = 6,
	["Feral Moonseeker"] = 10,
	["Feral Protector"] = 10,
	["Feral Stalker"] = 6,
	["Flickerwick"] = 400,
	["Forked-Tongue"] = 200,
	["Frenzied Moonkin"] = 150,
	["Frolicsome Soilkin"] = 2,
	["Frostbore Burster"] = 10,
	["Frostbore Worm"] = 6,
	["Frostscale Hydra"] = 10,
	["Frostscale Wanderer"] = 150,
	["Garnetback Striker"] = 10,
	["Garnetback Worm"] = 6,
	["Gashasz"] = 200,
	["Gemshard Colossus"] = 300,
	["Giant Dreadfang"] = 150,
	["Giggling Nettlevine"] = 2,
	["Giggling Thistlebrush"] = 2,
	["Gnashing Horror"] = 200,
	["Goldenvein"] = 300,
	["Great Mota"] = 300,
	["Greatfangs"] = 200,
	["Gritplate Basilisk"] = 6,
	["Gritplate Gazer"] = 10,
	["Grizzlefur Bear"] = 6,
	["Grizzlefur Patriarch"] = 150,
	["Grrl"] = 200,
	["Grubby Beard"] = 400,
	["Guuru the Mountain-Breaker"] = 300,
	["Head Navigator Franklin"] = 300,
	["Icecracker"] = 300,
	["Ironweb Skitterer"] = 2,
	["Ironweb Spider"] = 6,
	["Ironweb Spinner"] = 10,
	["Ironweb Weaver"] = 150,
	["Island Ettin"] = 300,
	["Jadescale Gnasher"] = 10,
	["Jadescale Worm"] = 6,
	["Jun-Ti"] = 300,
	["Kindleweb Clutchkeeper"] = 150,
	["Kindleweb Creeper"] = 10,
	["Kindleweb Skitterer"] = 2,
	["Knucklebump Gorilla"] = 6,
	["Kvaldir Cursewalker"] = 225,
	["Kvaldir Haul"] = 375,
	["Laughing Blaze"] = 2,
	["Longpaws"] = 400,
	["Lord Coilfin"] = 200,
	["Magma Giant"] = 300,
	["Malachite"] = 200,
	["Marrowbore"] = 300,
	["Mechanical Guardhound"] = 6,
	["Mirelurk Assassin"] = 10,
	["Mirelurk Bogtender"] = 6,
	["Mirelurk Guardian"] = 10,
	["Mirelurk Rivercaller"] = 10,
	["Mischievous Flood"] = 10,
	["Morningdew"] = 200,
	["Mrogan"] = 300,
	["Muckfin Murloc"] = 6,
	["Muckfin Oracle"] = 10,
	["Muckfin Puddlejumper"] = 2,
	["Muckfin Tidehunter"] = 6,
	["Mudsnout Piglet"] = 2,
	["Mudwhisker Candlekeeper"] = 150,
	["Mudwhisker Earthtosser"] = 6,
	["Mudwhisker Kobold"] = 6,
	["Mudwhisker Runt"] = 2,
	["Mudwhisker Taskmaster"] = 150,
	["Muskflank Bull"] = 150,
	["Muskflank Calf"] = 2,
	["Muskflank Charger"] = 10,
	["Muskflank Yak"] = 6,
	["Nasira Morningfrost"] = 300,
	["Nassa the Cold-Blooded"] = 200,
	["Nettlevine Sprite"] = 6,
	["Nettlevine Trickster"] = 10,
	["Nightfeather"] = 200,
	["Old Chest"] = 100,
	["Old Li"] = 400,
	["Overseer Steelsnout"] = 300,
	["Pinegraze Courser"] = 10,
	["Pinegraze Greatstag"] = 150,
	["Pirate's Plunder"] = 250,
	["Pouch of Azerite"] = 50,
	["Primal Mauler"] = 150,
	["Profit-O-Matic"] = 10,
	["Prophet Doom-Ra"] = 300,
	["Qor-Xin the Earth-Caller"] = 300,
	["Rabidmaw"] = 200,
	["Razorfin Aqualyte"] = 10,
	["Razorfin Impaler"] = 10,
	["Razorfin Javelineer"] = 6,
	["Razorfin Jinyu"] = 6,
	["Razorfin Watershaper"] = 150,
	["Razorfin Waveguard"] = 150,
	["Recently Petrified Foe"] = 2,
	["Reinforced Chest"] = 150,
	["Rotting Wooden Chest"] = 150,
	["Ruinstalker"] = 300,
	["Rumbling Earth"] = 2,
	["Runehoof Stag"] = 9,
	["Rustpelt Alpha"] = 150,
	["Rustpelt Pup"] = 2,
	["Rustpelt Snarler"] = 10,
	["Rustpelt Wolf"] = 6,
	["Sack of Azerite"] = 150,
	["Safety Inspection Bot"] = 2,
	["Saltfin"] = 200,
	["Sandscalp Axe Thrower"] = 6,
	["Sandscalp Berserker"] = 150,
	["Sandscalp Soothsayer"] = 150,
	["Sandscalp Villager"] = 2,
	["Sandscalp Warrior"] = 6,
	["Sarashas the Pillager"] = 200,
	["Savage Sharpclaw"] = 150,
	["Scalper Bazuulu"] = 200,
	["Scartalon"] = 200,
	["Senior Producer Gixi"] = 300,
	["Shredmaw the Voracious"] = 300,
	["Sigrid the Shroud-Weaver"] = 450,
	["Slitherblade Gladiator"] = 6,
	["Slitherblade Ironscale"] = 10,
	["Slitherblade Oracle"] = 10,
	["Slitherblade Phalanx"] = 150,
	["Slitherblade Prophet"] = 150,
	["Slitherblade Saurok"] = 2,
	["Slitherblade Striker"] = 6,
	["Slitherblade Wavecaller"] = 6,
	["Slow Olo"] = 200,
	["Snowfur Alpha"] = 150,
	["Snowfur Pup"] = 2,
	["Snowfur Snarler"] = 10,
	["Snowfur Wolf"] = 6,
	["Southsea Cannoneer"] = 150,
	["Southsea Third Mate"] = 150,
	["Sparkleshell Clacker"] = 10,
	["Sparkleshell Crab"] = 6,
	["Sparkleshell Deathclaw"] = 150,
	["Spitefin Behemoth"] = 225,
	["Spitefin Harpooner"] = 6,
	["Spitefin Myrmidon"] = 15,
	["Spitefin Raider"] = 6,
	["Spitefin Tempest Witch"] = 225,
	["Spitefin Tidebinder"] = 15,
	["Steelscale Volshasis"] = 200,
	["Steelshred"] = 200,
	["Swipeclaw"] = 200,
	["Thistlebrush Sprite"] = 6,
	["Thistlebrush Trickster"] = 10,
	["Thorncoat"] = 200,
	["Thornfur the Protector"] = 300,
	["Tidal Surger"] = 10,
	["Tidestriker Ocho"] = 200,
	["Tinny"] = 600,
	["Trapdoor Ambusher"] = 225,
	["Trapdoor Hatchling"] = 3,
	["Trapdoor Hunter"] = 15,
	["Trapdoor Spider"] = 9,
	["Trickle"] = 200,
	["Tweets Lightsprocket"] = 400,
	["Unbound Azerite"] = 400,
	["Unleashed Azerite"] = 40,
	["Unstable Typhoon"] = 150,
	["Valero"] = 400,
	["Venomfang Lurker"] = 10,
	["Venomfang Recluse"] = 150,
	["Venomfang Spider"] = 6,
	["Venomfang Spiderling"] = 2,
	["Venomscale Hydra"] = 10,
	["Venomscale Monitor"] = 150,
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
	["Vicejaw Chomper"] = 10,
	["Vicejaw Crocolisk"] = 6,
	["Vicejaw Sawtooth"] = 150,
	["Vicious Vicejaw"] = 200,
	["Visz the Silent Blade"] = 200,
	["Vizio the Cartographer"] = 400,
	["Voru'kar Flyer"] = 3,
	["Voru'kar Infector"] = 9,
	["Voru'kar Nerubian"] = 10,
	["Voru'kar Skitterer"] = 2,
	["Voru'kar Spitter"] = 6,
	["Voru'kar Swarmguard"] = 150,
	["Voru'kar Swarmling"] = 2,
	["Voru'kar Venomancer"] = 10,
	["Voru'kar Web Winder"] = 225,
	["Water Elemental"] = 6,
	["Water Spirit"] = 6,
	["Wildmane"] = 200,
	["Witherbranch Axe Thrower"] = 6,
	["Witherbranch Berserker"] = 150,
	["Witherbranch Headhunter"] = 10,
	["Witherbranch Venom Priest"] = 150,
	["Witherbranch Villager"] = 2,
	["Witherbranch Warrior"] = 6,
	["Witherbranch Witch Doctor"] = 10,
	["Wooden Strongbox"] = 50,
	["Youngercraw"] = 200,
	["Zara'thik Drone"] = 2,
	["Zess'ez"] = 200,
	["Zgordo the Brutalizer"] = 300
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
		if azerite[key] ~= nil then
			infoText = azerite[key]
			prefix = "IEH: "
		elseif localAzeriteValues ~= nil and localAzeriteValues[key] ~= nil then
			infoText = localAzeriteValues[key]
			prefix = "IEH*: "
		end
		if infoText ~= nil and IslandExpeditionHelper.checkTooltipForDuplicates() then
			GameTooltip:AddLine(prefix..IslandExpeditionHelper.adjustToDifficulty(infoText), 0.9, 0.8, 0.5, 1, 0)
			GameTooltip:Show()
		end
	end
end

function IslandExpeditionHelper.checkTooltipForDuplicates()
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
		local foundValue, unit = string.match(msg, azeriteGainString)
		--print(L["azeriteString"])
		print(foundValue, unit)
		local value = IslandExpeditionHelper.adjustBackToDifficulty(foundValue)
		if localAzeriteValues[unit] == nil then
			localAzeriteValues[unit] = value
						
			--print(string.format("adding new value (%s) for unit (%s) to map", value, unit))			
		--[[elseif localAzeriteValues[unit] ~= nil and localAzeriteValues[unit] ~= value then
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


function IslandExpeditionHelper.adjustToDifficulty(value)
    _,_,_, diff = GetInstanceInfo()
    if diff == "Heroic" then
        return value*1.5
    elseif diff == "Mythic" or diff == "PvP" then
        return value*2
    end    
    return value; --"Normal"
end


function IslandExpeditionHelper.removeValues() -- TODO translations
	--Alliance NPCs
	localAzeriteValues["\"Stabby\" Lottie"] = nil
	localAzeriteValues["Anchorite Lanna"] = nil
	localAzeriteValues["Archmage Tamuura"] = nil
	localAzeriteValues["Briona the Bloodthirsty"] = nil
	localAzeriteValues["Dizzy Dina"] = nil
	localAzeriteValues["Duskrunner Lorinas"] = nil
	localAzeriteValues["Fenrae the Cunning"] = nil
	localAzeriteValues["Frostfencer Seraphi"] = nil
	localAzeriteValues["Gunnolf the Ferocious"] = nil
	localAzeriteValues["Raul the Tenacious"] = nil
	localAzeriteValues["Razak Ironsides"] = nil
	localAzeriteValues["Riftblade Kelain"] = nil
	localAzeriteValues["Shadeweaver Zarra"] = nil
	localAzeriteValues["Squallshaper Auran"] = nil
	localAzeriteValues["Squallshaper Bryson"] = nil
	localAzeriteValues["Tally Zapnabber"] = nil
	localAzeriteValues["Varigg"] = nil
	localAzeriteValues["Vindicator Baatul"] = nil
	
	--Horde NPCs
	localAzeriteValues["Gazlowe"] = nil
	localAzeriteValues["Skaggit"] = nil
	localAzeriteValues["Dorp"] = nil
	localAzeriteValues["Astralite Visara"] = nil
	localAzeriteValues["Rune Scribe Lusaris"] = nil
	localAzeriteValues["Phoenix Mage Ryleia"] = nil
	localAzeriteValues["Berserker Zar'ri"] = nil
	localAzeriteValues["Witch Doctor Unbugu"] = nil
	localAzeriteValues["Spiritwalker Quura"] = nil
	localAzeriteValues["Lady Sena"] = nil
	localAzeriteValues["Captain Greenbelly "] = nil
	localAzeriteValues["Sneaky Pete"] = nil
	localAzeriteValues["Moonscythe Pelani"] = nil
	localAzeriteValues["Phoenix Mage Rhydras"] = nil
	localAzeriteValues["Sunbringer Firasi"] = nil
	localAzeriteValues["Shadow Hunter Ju'loa"] = nil
	localAzeriteValues["Mahna Flamewhisper"] = nil
	localAzeriteValues["Sunwalker Ordel"] = nil
end

function IslandExpeditionHelper.adjustBackToDifficulty(value)
    _,_,_, diff = GetInstanceInfo()
    if diff == "Heroic" then
        return value/1.5
    elseif diff == "Mythic" or diff == "PvP" then
        return value/2
    end   
    return value; -- "Normal"
end

function IslandExpeditionHelper.loadSV()
	localAzeriteValues = AzeriteValues
	removeAzeriteSpam = AzeriteSpam
	if removeAzeriteSpam == nil then
		removeAzeriteSpam = false
	end
end

function IslandExpeditionHelper.saveSV()
	IslandExpeditionHelper.removeValues()
	table.sort(localAzeriteValues)
	AzeriteValues = localAzeriteValues;
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