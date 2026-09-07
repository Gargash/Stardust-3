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
	local tier3SkillCount = SpaceHelpers:getPilotTierSkillCount(pPlayer, "imperial_navy", 3)

	if (firstActive or secondActive or thirdActive) then
		return convoTemplate:getScreen("alozen_on_mission")
	elseif (thirdComplete) then
		if (getQuestStatus(playerID .. "imperial_ss_6:reward") ~= "1") then
			setQuestStatus(playerID .. "imperial_ss_6:reward", 1)
			recovery_imperial_ss_6:rewardPlayer(pPlayer)
			ghost:increaseFactionStanding("imperial", 50)
		end

		if (getQuestStatus(playerID .. "imperial_ss_4:trained") ~= "1" and tier3SkillCount < 2) then
			return convoTemplate:getScreen("alozen_first_training")
		elseif (getQuestStatus(playerID .. "imperial_ss_6:trained") ~= "1" and tier3SkillCount < 2) then
			return convoTemplate:getScreen("alozen_second_training")
		end

		setQuestStatus(playerID .. "imperial_ss_4:trained", 1)
		setQuestStatus(playerID .. "imperial_ss_6:trained", 1)

		if (getQuestStatus(playerID .. "StormSquadronScreenplay:alozen_finished") == "1") then
			SpaceHelpers:addStormDennerWaypoint(pPlayer)
			return convoTemplate:getScreen("alozen_report_to_denner")
		end

		setQuestStatus(playerID .. "StormSquadronScreenplay:alozen_finished", 1)
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

		if (getQuestStatus(playerID .. "imperial_ss_4:trained") ~= "1" and tier3SkillCount < 1) then
			return convoTemplate:getScreen("alozen_first_training")
		end

		setQuestStatus(playerID .. "imperial_ss_4:trained", 1)

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
	local pGhost = CreatureObject(pPlayer):getPlayerObject()

	if (pGhost == nil) then
		return nil
	end

	local playerID = CreatureObject(pPlayer):getObjectID()

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
	elseif (string.find(screenID, "alozen_train_first_") == 1 or string.find(screenID, "alozen_train_second_") == 1) then
		local skillName = nil

		if (string.find(screenID, "_fighters") ~= nil) then
			skillName = "pilot_imperial_navy_starships_03"
		elseif (string.find(screenID, "_component") ~= nil) then
			skillName = "pilot_imperial_navy_weapons_03"
		elseif (string.find(screenID, "_procedures") ~= nil) then
			skillName = "pilot_imperial_navy_procedures_03"
		elseif (string.find(screenID, "_droid") ~= nil) then
			skillName = "pilot_imperial_navy_droid_03"
		end

		if (skillName ~= nil and not CreatureObject(pPlayer):hasSkill(skillName)) then
			SpaceHelpers:grantSpaceSkill(pPlayer, skillName, false)
		end

		if (string.find(screenID, "alozen_train_first_") == 1) then
			setQuestStatus(playerID .. "imperial_ss_4:trained", 1)
		else
			setQuestStatus(playerID .. "imperial_ss_6:trained", 1)
		end
	end

	local pClonedScreen = screen:cloneScreen()
	local clonedConversation = LuaConversationScreen(pClonedScreen)

	clonedConversation:setDialogTextTU(CreatureObject(pPlayer):getFirstName())

	if (screenID == "alozen_first_training" or screenID == "alozen_second_training") then
		local trainingPrefix = screenID == "alozen_first_training" and "alozen_train_first_" or "alozen_train_second_"

		if (not CreatureObject(pPlayer):hasSkill("pilot_imperial_navy_starships_03")) then
			clonedConversation:addOption("@conversation/tatooine_imperial_trainer_2b:s_594a07fa", trainingPrefix .. "fighters")
		end
		if (not CreatureObject(pPlayer):hasSkill("pilot_imperial_navy_weapons_03")) then
			clonedConversation:addOption("@conversation/tatooine_imperial_trainer_2b:s_dbb5bf46", trainingPrefix .. "component")
		end
		if (not CreatureObject(pPlayer):hasSkill("pilot_imperial_navy_procedures_03")) then
			clonedConversation:addOption("@conversation/tatooine_imperial_trainer_2b:s_e73e5d21", trainingPrefix .. "procedures")
		end
		if (not CreatureObject(pPlayer):hasSkill("pilot_imperial_navy_droid_03")) then
			clonedConversation:addOption("@conversation/tatooine_imperial_trainer_2b:s_c76594d7", trainingPrefix .. "droid")
		end
	end

	return pClonedScreen
end
