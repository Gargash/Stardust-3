alozen_convo = ConvoTemplate:new {
	initialScreen = "alozen_first_mission",
	templateType = "Lua",
	luaClassHandler = "alozenConvoHandler",
	screens = {}
}

local function addAlozenScreen(id, dialog, stopConversation, options)
	local screen = ConvoScreen:new {
		id = id,
		leftDialog = "@conversation/tatooine_imperial_trainer_2b:" .. dialog,
		stopConversation = stopConversation and "true" or "false",
		options = options or {}
	}

	alozen_convo:addScreen(screen)
end

addAlozenScreen("no_jtl", "s_128d62a", true)
addAlozenScreen("rebel_pilot", "s_21772e5a", true)
addAlozenScreen("neutral_pilot", "s_ed5d85e3", true)
addAlozenScreen("go_to_next", "s_ed5d85e3", true)
addAlozenScreen("alozen_on_mission", "s_4b074298", true)

-- Recover a Rebel activity log for the Imperial search operation.
addAlozenScreen("alozen_first_mission", "s_55289b72", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_2eaae5bc", "alozen_first_briefing"}
})
addAlozenScreen("alozen_first_briefing", "s_f1639d7c", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_f14c78f8", "alozen_first_mission_details"}
})
addAlozenScreen("alozen_first_mission_details", "s_e617e5c8", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_1ff4247a", "accept_alozen_first_mission"}
})
addAlozenScreen("accept_alozen_first_mission", "s_598456ed", true)

-- Escort the scanning team sent to investigate the recovered activity log.
addAlozenScreen("alozen_second_mission", "s_847e12c5", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_b84b366c", "alozen_second_mission_details"}
})
addAlozenScreen("alozen_second_mission_details", "s_bf7cf7b8", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_1ff4247a", "accept_alozen_second_mission"}
})
addAlozenScreen("accept_alozen_second_mission", "s_a30c1a53", true)

-- Disable the Rebel gunboat and recover the Death Star firing core.
addAlozenScreen("alozen_third_mission", "s_395c2680", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_16de6424", "alozen_third_mission_details"}
})
addAlozenScreen("alozen_third_mission_details", "s_62e2ea4c", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_57c8489e", "alozen_capture_instructions"}
})
addAlozenScreen("alozen_capture_instructions", "s_9506a2bd", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_1ff4247a", "accept_alozen_third_mission"}
})
addAlozenScreen("accept_alozen_third_mission", "s_4fc85d67", true)

addAlozenScreen("alozen_completed", "s_b0d3b474", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_71bf4315", "alozen_transfer"}
})
addAlozenScreen("alozen_transfer", "s_54c421ec", false, {
	{"@conversation/tatooine_imperial_trainer_2b:s_bf7bc308", "alozen_denner_location"}
})
addAlozenScreen("alozen_denner_location", "s_2f3bf1d8", true)
addAlozenScreen("alozen_report_to_denner", "s_10ee338d", true)

addConversationTemplate("alozen_convo", alozen_convo)
