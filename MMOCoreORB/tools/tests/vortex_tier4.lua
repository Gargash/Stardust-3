-- Run from the repository root: lua MMOCoreORB/tools/tests/vortex_tier4.lua
-- Engine boundaries are stubbed; mission definitions and callbacks execute unchanged.
local root = "MMOCoreORB/bin/scripts/"
local checks = 0
local function check(value, message)
	assert(value, message)
	checks = checks + 1
end

ScreenPlay = {}
function ScreenPlay:new(value)
	self.__index = self
	return setmetatable(value or {}, self)
end
function require(name)
	if name == "utils.space_helpers" then return SpaceHelpers end
	if name == "utils.logger" then return Logger end
	return {}
end
local registered = {}
function registerScreenPlay(name) registered[name] = true end
function includeFile() end
function getHashCode(value) return value end
function isZoneEnabled() return true end
function getRandomNumber(a) return a end
function getQuestStatus(key) return status[key] or "" end
function setQuestStatus(key, value) status[key] = tostring(value) end
function removeQuestStatus(key) status[key] = nil end
function readData(key) return data[key] or 0 end
function writeData(key, value) data[key] = value end
function deleteData(key) data[key] = nil end
readStringData = readData
writeStringData = writeData
deleteStringData = deleteData
function readStringVectorSharedMemory(key) return vectors[key] or {} end
function writeStringVectorSharedMemory(key, value) vectors[key] = value end
function deleteStringVectorSharedMemory(key) vectors[key] = nil end
function createEvent(delay, class, method, object, argument)
	check(type(_G[class][method]) == "function", "Missing callback " .. class .. ":" .. method)
	table.insert(events, {class = class, method = method, object = object, argument = argument})
end
function cancelEvent(class, method, object)
	for i = #events, 1, -1 do
		local event = events[i]
		if (event.class == class and event.method == method and event.object == object) then table.remove(events, i) end
	end
end
function createObserver(event, class, method, object)
	check(type(_G[class][method]) == "function", "Missing observer " .. class .. ":" .. method)
	table.insert(observers, {event, class, method, object})
end
function dropObserver() end
function hasObserver() return false end
function getSceneObject(id) return objects[tonumber(id)] end
function SceneObject(object) assert(object, "nil scene object"); return object end
CreatureObject = SceneObject
PlayerObject = SceneObject
ShipObject = SceneObject
ShipAiAgent = SceneObject
WaypointObject = SceneObject
Logger = {log = function(_, text) table.insert(messages, text) end}
local noop = function() end
local methods = {
	getObjectID = function(self) return self.id end,
	getZoneName = function(self) return self.zone end,
	getRootParent = function() return playerShip end,
	getPlayerObject = function() return ghost end,
	getWaypointAt = function() return nil end,
	isPlayerCreature = function(self) return self.id == 1 end,
	isPlayerShip = function(self) return self.id == 2 end,
	isShipObject = function(self) return self.ship == true end,
	isShipAiAgent = function(self) return self.ship == true and self.id ~= 2 end,
	isActiveArea = function(self) return self.area == true end,
	getPilot = function() return player end,
	getMissionOwnerID = function() return 1 end,
	getWorldPositionX = function(self) return self.x or 0 end,
	getWorldPositionZ = function(self) return self.z or 0 end,
	getWorldPositionY = function(self) return self.y or 0 end,
	getDisplayedName = function() return "test ship" end,
	getObjectName = function() return "test ship" end,
	getSpawnPointInFrontOfShip = function() return {100, 200, 300} end,
	getSpawnPointBehindShip = function() return {100, 200, 300} end,
	setPosition = function(self,x,z,y) self.x=x; self.z=z; self.y=y end,
	destroyObjectFromWorld = function(self) objects[self.id] = nil end,
	getSpecies = function() return 0 end,
	assignFixedPatrolPointsTable = function(_, points) check(type(points) == "table", "Missing fixed patrol") end,
	removeSpaceFactionAlly = noop,
	sendSystemMessage = function(_, message) table.insert(messages, message) end,
}
methods.getPositionX = methods.getWorldPositionX
methods.getPositionZ = methods.getWorldPositionZ
methods.getPositionY = methods.getWorldPositionY
for _, name in ipairs({"playEffect", "playMusicMessage", "removeSpaceMissionObject", "addSpaceMissionObject", "setQuestDetails", "removeWaypoint", "setMissionOwner", "setMinimumGuardPatrol", "setMaximumGuardPatrol", "setGuardPatrol", "setFixedPatrol", "setDespawnOnNoPlayerInRange", "createSquadron", "assignToSquadron", "addPatrolPoint", "setShipFactionString", "addSpaceFactionAlly", "removeSpaceFactionEnemy", "addSpaceFactionEnemy", "engageShipTarget", "setHyperspacing", "setDefender", "setCurrentSpeed", "setMaxSpeed", "setFollowShipObject", "setEngineDisabled", "setShipAIBehavior", "setPvpStatusBitmask", "setOptionsBitmask", "addBankCredits"}) do methods[name] = noop end
local function object(values)
	objects[values.id] = setmetatable(values, {__index = methods})
	return objects[values.id]
end
function spawnSpaceActiveArea(zone, template, x, z, y)
	check(type(x) == "number" and type(z) == "number" and type(y) == "number", "Area coordinates missing")
	return object({id = #spawns + 100, zone = zone, x = x, z = z, y = y, area = true})
end
function spawnShipAgent(template, zone, x, z, y)
	check(type(template) == "string", "Invalid ship table")
	check(type(x) == "number" and type(z) == "number" and type(y) == "number", "Ship coordinates missing")
	local file = io.open(root .. "ship_mobile/ships/" .. template .. ".lua")
	check(file ~= nil, "Missing ship template " .. template)
	file:close()
	local ship = object({id = #spawns + 1000, ship = true, zone = zone, x = x, z = z, y = y})
	table.insert(spawns, ship)
	return ship
end
function methods:addWaypoint(zone, title, desc, x, z, y)
	check(type(x) == "number" and type(z) == "number" and type(y) == "number", "Waypoint coordinates missing")
	object({id = 500, zone = zone, x = x, z = z, y = y})
	return 500
end
function LuaStringIdChatParameter(value)
	return {setDI = noop, setTO = noop, _getObject = function() return value end}
end
SpaceHelpers = setmetatable({
	isSpaceQuestActive = function(_,p,t,n) return active[t .. "/" .. n] == true end,
	isSpaceQuestComplete = function(_,p,t,n) return complete[t .. "/" .. n] == true end,
	activateSpaceQuest = function(_,p,npc,t,n) active[t .. "/" .. n] = true end,
	completeSpaceQuest = function(_,p,t,n) active[t .. "/" .. n] = nil; complete[t .. "/" .. n] = true end,
	failSpaceQuest = function(_,p,t,n) active[t .. "/" .. n] = nil; complete[t .. "/" .. n] = nil end,
	clearSpaceQuest = function(_,p,t,n) active[t .. "/" .. n] = nil; complete[t .. "/" .. n] = nil end,
	isInYacht = function() return false end,
	getPlayerSpaceFactionHash = function() return 1 end,
	getPlayerShipFactionString = function() return "rebel" end,
}, {__index = function() return noop end})
for _, name in ipairs({"ZONESWITCHED", "SHIPDESTROYED", "ENTEREDAREA", "SHIPDOCKED", "WAYPOINT_SPACE", "WAYPOINTQUESTTASK"}) do _G[name] = name end

local function reset(mission)
	data, status, vectors, events, observers, objects, messages, spawns, active, complete = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
	player = object({id=1, zone=mission.questZone})
	playerShip = object({id=2, zone=mission.questZone, ship=true})
	ghost = object({id=3})
	active[mission.questType .. "/" .. mission.questName] = true
end

for _, name in ipairs({"SpaceQuestLogic", "SpaceEscortScreenplay", "SpaceAssassinateScreenplay", "SpaceSurvivalScreenplay", "SpaceBattleScreenplay", "SpaceRescueScreenplay", "SpaceRecoveryScreenplay", "SpaceDeliveryScreenplay", "SpaceDeliveryNoPickupScreenplay", "SpaceSurpriseAttackScreenplay", "SpaceDutyDestroyScreenplay", "SpaceDutyEscortScreenplay", "SpaceDutyRescueScreenplay", "SpaceDutyRecoveryScreenplay"}) do
	dofile(root .. "screenplays/space/" .. name .. ".lua")
end
-- Older tiers are loaded only as definitions in this focused harness.
for _, name in ipairs({"SpacePatrolScreenplay", "SpaceDestroyScreenplay", "SpaceInspectScreenplay"}) do _G[name] = SpaceQuestLogic:new{} end
dofile(root .. "screenplays/space/squadrons/VortexSquadronScreenplay.lua")
local squad = VortexSquadronScreenplay

local function hasEvent(class, method)
	for _,event in ipairs(events) do if event.class == class and event.method == method then return event end end
end
local function key(m) return m.questType .. "/" .. m.questName end
local zones = {"space_endor", "space_yavin4", "space_dathomir", "space_dathomir"}
local kinds = {"survival", "assassinate", "rescue", "space_battle"}
for i, chain in ipairs(squad.TIER4_MISSION_CHAINS) do
	local head = chain[1]
	check(head.questZone == zones[i] and head.questType == kinds[i], "Wrong head mission")
	reset(head)
	head:completeQuest(player, "true")
	check(hasEvent(chain[2].className, "startQuest"), "Missing success branch " .. i)
	check(not squad:isTier4MissionComplete(player, i), "Premature reward after head " .. i)
	for _,reason in ipairs({"true", "false"}) do
		reset(head)
		head:failQuest(player, reason)
		check(not hasEvent(head.sideFailQuestType .. "_" .. head.sideFailQuestName, "startQuest"), "Abort started fallback " .. i)
	end
	reset(head)
	head:failQuest(player, "objective")
	check(hasEvent(head.sideFailQuestType .. "_" .. head.sideFailQuestName, "startQuest"), "Missing objective fallback " .. i)
	for _,event in ipairs(events) do
		if event.class == "SpaceHelpers" and event.method == "sendQuestAlert" then
			check(event.argument:match(":split_quest_alert_fail$"), "Wrong failure alert")
		end
	end
	for _,terminal in ipairs({chain[2],chain[#chain]}) do
		reset(terminal)
		terminal:completeQuest(player, "true")
		check(squad:isTier4MissionComplete(player,i), "Terminal does not advance trainer " .. terminal.className)
		reset(terminal)
		active[key(terminal)] = nil
		terminal:completeQuest(player, "true")
		check(not squad:isTier4MissionComplete(player,i), "Late terminal completion awarded a dropped mission: " .. terminal.className)
	end
	reset(head)
	active[key(head)] = nil
	head:completeQuest(player,"true")
	check(#events == 0 and not complete[key(head)], "Late success revived dropped mission")
end

-- Uvqolo's failed first interception requires the ambush and second assassination.
local ambush = destroy_surpriseattack_naboo_rebel_tier4_2_b
reset(ambush)
ambush:completeQuest(player,"true")
check(hasEvent("assassinate_naboo_rebel_tier4_2_c","startQuest"), "Missing second interception")
check(not squad:isTier4MissionComplete(player,2), "Ambush incorrectly awards completion")
reset(ambush)
ambush:failQuest(player,"false")
ambush:completeQuest(player,"true")
check(not hasEvent("assassinate_naboo_rebel_tier4_2_c","startQuest"), "Dropped ambush revived quest")

-- The named coordinate tables must produce waypoints and ship spawns.
for _,chain in ipairs(squad.TIER4_MISSION_CHAINS) do
	for _,m in ipairs(chain) do
		check(registered[m.className], "Unregistered mission")
		reset(m)
		if m.questType == "survival" then
			m:setupSurvival(player)
			check(objects[500] ~= nil, "Missing survival waypoint")
		elseif m.questType == "space_battle" then
			m:setupBattle(player)
			check(objects[500] ~= nil, "Missing battle waypoint")
			m:spawnSupportShips(player)
			check(#spawns > 0, "No allies spawned")
			m:spawnEnemyShips(player)
		elseif m.questType == "assassinate" then
			m:deployTargets(player)
			check(#spawns == #m.assassinateSpawns.escorts + 1, "Assassination spawn count")
		elseif m.questType == "delivery_no_pickup" then
			check(m:getLegLocation("delivery") ~= nil, "Missing delivery coordinates")
		end
		for _,list in ipairs({m.targetPatrols or {},m.escortPoints or {}}) do
			local file = assert(io.open(root .. "ship_mobile/patrol_points/" .. m.questZone .. ".lua"))
			local text = file:read("*a"); file:close()
			for _,point in ipairs(list) do
				local literal = 'patrolPointName = "' .. point.patrolPointName .. '", x = ' .. point.x .. ', z = ' .. point.z .. ', y = ' .. point.y
				check(text:find(literal,1,true), "Patrol coordinates mismatch " .. point.patrolPointName)
			end
		end
	end
end

local missionTypes = {
	["1"]="survival", ["1_a"]="assassinate", ["1_b"]="escort",
	["2"]="assassinate", ["2_a"]="space_battle", ["2_b"]="destroy_surpriseattack", ["2_c"]="assassinate",
	["3"]="rescue", ["3_a"]="assassinate", ["3_b"]="delivery_no_pickup",
	["4"]="space_battle", ["4_a"]="space_battle", ["4_b"]="survival",
}
for _,chain in ipairs(squad.TIER4_MISSION_CHAINS) do
	for _,mission in ipairs(chain) do
		local suffix = mission.questName:match("naboo_rebel_tier4_(.+)")
		check(mission.questType == missionTypes[suffix], "Client string type mismatch")
	end
end
check(_G.space_battle_naboo_rebel_tier4_4_c == nil, "Unsupported legacy mission still registered")
check(loadfile(root .. "screenplays/space/conversations/rebel/vortex_squadron/v3fxConvoHandler.lua"), "Trainer syntax error")

-- The rescue escort really deploys its one authored TIE; malformed wave tables spawn none.
local rescue = rescue_naboo_rebel_tier4_3
reset(rescue)
object({id=10,ship=true,zone=rescue.questZone})
writeData("1:" .. rescue.className .. ":rescueShipID",10)
rescue:spawnEscortAttackers(player)
check(#spawns == 1, "Spy escort attacker missing")
rescue:handleTargetDestroyed(objects[10],nil)
check(hasEvent("delivery_no_pickup_naboo_rebel_tier4_3_b","startQuest"), "Spy loss did not branch")

local assassination = assassinate_naboo_rebel_tier4_2
reset(assassination)
assassination:failAssassination(player)
local failure = hasEvent(assassination.className,"failQuest")
check(failure and failure.argument == "objective", "Escape timer did not mark an objective failure")
assassination:failQuest(player,failure.argument)
check(hasEvent(ambush.className,"startQuest"), "Escape did not trigger ambush")

-- Duty systems, factions, and every referenced ship template.
local duties = {escort_duty_naboo_rebel_tier4_1,rescue_duty_naboo_rebel_tier4_1,recovery_duty_naboo_rebel_tier4_1,destroy_duty_naboo_rebel_tier4_1}
local dutyZones = {"space_yavin4","space_dantooine","space_endor","space_dantooine"}
local function validateShips(value)
	if type(value) == "table" then
		for _,item in pairs(value) do validateShips(item) end
	elseif type(value) == "string" and value ~= "" then
		local file = io.open(root .. "ship_mobile/ships/" .. value .. ".lua")
		check(file ~= nil, "Missing authored ship " .. value)
		file:close()
	end
end
for i,duty in ipairs(duties) do
	check(duty.questZone == dutyZones[i], "Wrong duty system")
	for _,field in ipairs({"escortShips","rescueShip","recoverShip","bossShip","shipTypes","attackShips"}) do
		if duty[field] then validateShips(duty[field]) end
	end
end
check(duties[3].recoveryFaction == "rebel" and duties[3].recoverShip == "lambdashuttle_inquisition_data_vessel", "Wrong recovery faction/target")
check(duties[4].shipTypes[1][1] == "imp_tie_fighter_tier4", "Destroy duty still targets Black Sun")

-- Protected allies fail only missions that opt into protection.
local battle = space_battle_naboo_rebel_tier4_4
reset(battle)
local ally = object({id=10,ship=true})
battle:notifySupportShipDestroyed(ally,nil)
check(not active[key(battle)] and hasEvent("survival_naboo_rebel_tier4_4_b","startQuest"), "Lost ally did not branch")
local normalBattle = SpaceBattleScreenplay:new{className="normalBattle",questType="space_battle",questName="normal"}
reset(normalBattle)
normalBattle:notifySupportShipDestroyed(object({id=10,ship=true}),nil)
check(active[key(normalBattle)], "Changed unprotected battle behavior")

-- Holding position: two warnings, then failure; re-entry clears the warning count.
local survival = survival_naboo_rebel_tier4_1
reset(survival)
local prefix = "1:" .. survival.className
writeData(prefix .. ":survivalRunning:",1)
writeData(prefix .. ":survivalRunID:",7)
playerShip.x = 7500
survival:checkSurvivalDistance(player,"6")
check(#events == 0, "Stale range callback continued")
survival:checkSurvivalDistance(player,"7")
check(readData(prefix .. ":distanceWarnings:") == 1, "Missing range warning")
playerShip.x=survival.survivalPoint.x; playerShip.z=survival.survivalPoint.z; playerShip.y=survival.survivalPoint.y
survival:checkSurvivalDistance(player,"7")
check(readData(prefix .. ":distanceWarnings:") == 0, "Range warning not reset")
playerShip.x=7500
for i=1,3 do survival:checkSurvivalDistance(player,"7") end
check(hasEvent("escort_naboo_rebel_tier4_1_b","startQuest"), "Range failure did not start freighter fallback")

-- Retry cancels pending branch starts and completions.
reset(survival)
createEvent(1000,"escort_naboo_rebel_tier4_1_b","startQuest",player,"")
squad:prepareTier4MissionAttempt(player,1)
check(not hasEvent("escort_naboo_rebel_tier4_1_b","startQuest"), "Retry retained old branch event")

-- Preserve old terminal completion and already-paid rewards during the migration.
reset(survival)
complete["space_battle/naboo_rebel_tier4_4_c"] = true
status["1naboo_rebel_tier4_2:reward"] = "1"
squad:migrateTier4Quests(player)
check(squad:isTier4MissionComplete(player,4), "Migration lost old mission completion")
check(squad:isTier4MissionComplete(player,2), "Migration lost paid progress")
check(not complete["space_battle/naboo_rebel_tier4_4_c"], "Legacy journal entry retained")
active[key(survival)] = true
squad:migrateTier4Quests(player)
check(active[key(survival)], "Migration repeated and cleared new attempt")

print("Vortex tier 4: " .. checks .. " checks passed")
