local SpaceHelpers = require("utils.space_helpers")

alozenConvoHandler = conv_handler:new {}

function alozenConvoHandler:getInitialScreen(pPlayer, pNpc, pConvTemplate)
	if (pPlayer == nil or pNpc == nil or pConvTemplate == nil) then
		return nil
	end

	local convoTemplate = LuaConversationTemplate(pConvTemplate)

	if (not isJtlEnabled()) then
		return convoTemplate:getScreen("no_jtl")
	end

	local pGhost = CreatureObject(pPlayer):getPlayerObject()

	if (pGhost == nil) then
		return convoTemplate:getScreen("no_jtl")
	end

	local ghost = LuaPlayerObject(pGhost)

	if (not SpaceHelpers:isStormSquadron(pPlayer) or ghost:getPilotTier() < 3) then
		return convoTemplate:getScreen("go_to_next")
	end

	local playerID = CreatureObject(pPlayer):getObjectID()
	local firstActive = SpaceHelpers:isSpaceQuestActive(pPlayer, "inspect", "imperial_ss_4")
	local secondActive = SpaceHelpers:isSpaceQuestActive(pPlayer, "escort", "imperial_ss_5")
	local thirdActive = SpaceHelpers:isSpaceQuestActive(pPlayer, "recovery", "imperial_ss_6")
	local firstComplete = SpaceHelpers:isSpaceQuestComplete(pPlayer, "inspect", "imperial_ss_4")
	local secondComplete = SpaceHelpers:isSpaceQuestComplete(pPlayer, "escort", "imperial_ss_5")
	local thirdComplete = SpaceHelpers:isSpaceQuestComplete(pPlayer, "recovery", "imperial_ss_6")

	if (firstActive or secondActive or thirdActive) then
		return convoTemplate:getScreen("alozen_on_mission")
	elseif (thirdComplete) then
		if (getQuestStatus(playerID .. "imperial_ss_6:reward") == "1") then
			SpaceHelpers:addStormDennerWaypoint(pPlayer)
			return convoTemplate:getScreen("alozen_report_to_denner")
		end

		setQuestStatus(playerID .. "imperial_ss_6:reward", 1)
		recovery_imperial_ss_6:rewardPlayer(pPlayer)
		ghost:increaseFactionStanding("imperial", 50)
		SpaceHelpers:addStormDennerWaypoint(pPlayer)
		return convoTemplate:getScreen("alozen_completed")
	elseif (secondComplete) then
		if (getQuestStatus(playerID .. "imperial_ss_5:reward") ~= "1") then
			setQuestStatus(playerID .. "imperial_ss_5:reward", 1)
			escort_imperial_ss_5:rewardPlayer(pPlayer)
			ghost:increaseFactionStanding("imperial", 50)
		end

		return convoTemplate:getScreen("alozen_third_mission")
	elseif (firstComplete) then
		if (getQuestStatus(playerID .. "imperial_ss_4:reward") ~= "1") then
			setQuestStatus(playerID .. "imperial_ss_4:reward", 1)
			inspect_imperial_ss_4:rewardPlayer(pPlayer)
			ghost:increaseFactionStanding("imperial", 75)
		end

		return convoTemplate:getScreen("alozen_second_mission")
	end

	return convoTemplate:getScreen("alozen_first_mission")
end

function alozenConvoHandler:runScreenHandlers(pConvTemplate, pPlayer, pNpc, selectedOption, pConvScreen)
	if (pPlayer == nil or pNpc == nil or pConvScreen == nil) then
		return nil
	end

	local screen = LuaConversationScreen(pConvScreen)
	local screenID = screen:getScreenID()

	if (screenID == "accept_alozen_first_mission") then
		inspect_imperial_ss_4:resetQuest(pPlayer)
		SpaceHelpers:clearSpaceQuest(pPlayer, "inspect", "imperial_ss_4", false)
		inspect_imperial_ss_4:startQuest(pPlayer, pNpc)
	elseif (screenID == "accept_alozen_second_mission") then
		escort_imperial_ss_5:resetQuest(pPlayer)
		SpaceHelpers:clearSpaceQuest(pPlayer, "escort", "imperial_ss_5", false)
		escort_imperial_ss_5:startQuest(pPlayer, pNpc)
	elseif (screenID == "accept_alozen_third_mission") then
		recovery_imperial_ss_6:resetQuest(pPlayer)
		SpaceHelpers:clearSpaceQuest(pPlayer, "recovery", "imperial_ss_6", false)
		recovery_imperial_ss_6:startQuest(pPlayer, pNpc)
	end

	local pClonedScreen = screen:cloneScreen()
	LuaConversationScreen(pClonedScreen):setDialogTextTU(CreatureObject(pPlayer):getFirstName())

	return pClonedScreen
end
