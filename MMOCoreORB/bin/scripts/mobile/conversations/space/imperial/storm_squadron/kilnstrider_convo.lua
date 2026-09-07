kilnstrider_convo = ConvoTemplate:new {
	initialScreen = "tier4_initial_briefing",
	templateType = "Lua",
	luaClassHandler = "kilnstriderConvoHandler",
	screens = {}
}

local function addKilnstriderScreen(id, dialog, stopConversation, options)
	local screen = ConvoScreen:new {
		id = id,
		leftDialog = "@conversation/tatooine_imperial_tier4:" .. dialog,
		stopConversation = stopConversation and "true" or "false",
		options = options or {}
	}

	kilnstrider_convo:addScreen(screen)
end

addKilnstriderScreen("no_jtl", "s_e542a06b", true)
addKilnstriderScreen("rebel_pilot", "s_e16137e8", true)
addKilnstriderScreen("neutral_pilot", "s_e542a06b", true)
addKilnstriderScreen("non_inquisition_pilot", "s_e542a06b", true)
addKilnstriderScreen("go_to_next", "s_d3b2272c", true)
addKilnstriderScreen("tier4_on_mission", "s_2a35d2fe", true)

addKilnstriderScreen("tier4_initial_briefing", "s_7f465235", false, {
	{"@conversation/tatooine_imperial_tier4:s_9cc5ad7c", "tier4_first_mission"}
})

addKilnstriderScreen("tier4_first_mission", "s_2a973dfa", false, {
	{"@conversation/tatooine_imperial_tier4:s_555b7ab7", "tier4_first_mission_details"},
	{"@conversation/tatooine_imperial_tier4:s_134dd45", "accept_tier4_first_mission"}
})
addKilnstriderScreen("tier4_first_mission_details", "s_8f48acff", false, {
	{"@conversation/tatooine_imperial_tier4:s_4621ec24", "accept_tier4_first_mission"}
})
addKilnstriderScreen("accept_tier4_first_mission", "s_b2a9497c", true)
addKilnstriderScreen("failed_tier4_first_mission", "s_898e32ed", true)
addKilnstriderScreen("tier4_first_mission_success", "s_4aef73fb", true)

addKilnstriderScreen("tier4_second_mission", "s_ae9853f8", false, {
	{"@conversation/tatooine_imperial_tier4:s_b7879974", "tier4_second_mission_details"},
	{"@conversation/tatooine_imperial_tier4:s_134dd45", "accept_tier4_second_mission"}
})
addKilnstriderScreen("tier4_second_mission_details", "s_c3f0115e", false, {
	{"@conversation/tatooine_imperial_tier4:s_96443422", "accept_tier4_second_mission"}
})
addKilnstriderScreen("accept_tier4_second_mission", "s_83e62040", true)
addKilnstriderScreen("failed_tier4_second_mission", "s_c9b872a1", true)
addKilnstriderScreen("tier4_second_mission_success", "s_71874e85", true)

addKilnstriderScreen("tier4_third_mission", "s_66bd8046", false, {
	{"@conversation/tatooine_imperial_tier4:s_643d24c8", "tier4_third_mission_details"},
	{"@conversation/tatooine_imperial_tier4:s_134dd45", "accept_tier4_third_mission"}
})
addKilnstriderScreen("tier4_third_mission_details", "s_958dc561", false, {
	{"@conversation/tatooine_imperial_tier4:s_9b43a7ee", "accept_tier4_third_mission"}
})
addKilnstriderScreen("accept_tier4_third_mission", "s_1c3b8136", true)
addKilnstriderScreen("failed_tier4_third_mission", "s_3e3689e0", true)
addKilnstriderScreen("tier4_third_mission_success", "s_6c642831", true)

addKilnstriderScreen("tier4_fourth_mission", "s_783f1d49", false, {
	{"@conversation/tatooine_imperial_tier4:s_6a85372e", "tier4_fourth_mission_details"},
	{"@conversation/tatooine_imperial_tier4:s_134dd45", "accept_tier4_fourth_mission"}
})
addKilnstriderScreen("tier4_fourth_mission_details", "s_484092bd", false, {
	{"@conversation/tatooine_imperial_tier4:s_535d53b3", "accept_tier4_fourth_mission"}
})
addKilnstriderScreen("accept_tier4_fourth_mission", "s_99e3a272", true)
addKilnstriderScreen("failed_tier4_fourth_mission", "s_175d585", true)
addKilnstriderScreen("tier4_fourth_mission_success", "s_f5ef44e1", true)

addKilnstriderScreen("ready_train_tier4", "s_d1e73984", false)
addKilnstriderScreen("tier4_train_fighters", "s_665b67d1", true)
addKilnstriderScreen("tier4_train_component", "s_665b67d1", true)
addKilnstriderScreen("tier4_train_basics", "s_665b67d1", true)
addKilnstriderScreen("tier4_train_droid", "s_665b67d1", true)

local dutyOptions = {
	{"@conversation/tatooine_imperial_tier4:s_7b2d0234", "accept_tier4_duty1"},
	{"@conversation/tatooine_imperial_tier4:s_5208f382", "accept_tier4_duty2"},
	{"@conversation/tatooine_imperial_tier4:s_d115dd42", "accept_tier4_duty3"},
	{"@conversation/tatooine_imperial_tier4:s_cec1f447", "accept_tier4_duty4"},
	{"@conversation/tatooine_imperial_tier4:s_49805f81", "tier4_duty_brief1"}
}

addKilnstriderScreen("tier4_duty_repeat", "s_67f91789", false, dutyOptions)
addKilnstriderScreen("tier4_duty_brief1", "s_3e6a4237", false, {
	{"@conversation/tatooine_imperial_tier4:s_61657d0f", "tier4_duty_brief2"}
})
addKilnstriderScreen("tier4_duty_brief2", "s_77788129", false, {
	{"@conversation/tatooine_imperial_tier4:s_61657d0f", "tier4_duty_brief3"}
})
addKilnstriderScreen("tier4_duty_brief3", "s_2d7a9ef4", false, {
	{"@conversation/tatooine_imperial_tier4:s_61657d0f", "tier4_duty_menu"}
})
addKilnstriderScreen("tier4_duty_menu", "s_7247f243", false, dutyOptions)
addKilnstriderScreen("accept_tier4_duty1", "s_86c72612", true)
addKilnstriderScreen("accept_tier4_duty2", "s_86c72612", true)
addKilnstriderScreen("accept_tier4_duty3", "s_86c72612", true)
addKilnstriderScreen("accept_tier4_duty4", "s_86c72612", true)

local declannOptions = {
	{"@conversation/tatooine_imperial_tier4:s_7177c3f2", "master_who_declann"},
	{"@conversation/tatooine_imperial_tier4:s_bf2260fb", "accept_master_mission"}
}

addKilnstriderScreen("master_mission", "s_146bc0b9", false, declannOptions)
addKilnstriderScreen("master_who_declann", "s_dc219a69", false, {
	{"@conversation/tatooine_imperial_tier4:s_613f70ae", "master_declann_warning"},
	{"@conversation/tatooine_imperial_tier4:s_bf2260fb", "accept_master_mission"}
})
addKilnstriderScreen("master_declann_warning", "s_a5827814", false, {
	{"@conversation/tatooine_imperial_tier4:s_b8173a60", "accept_master_mission"}
})
addKilnstriderScreen("accept_master_mission", "s_b78b6139", true)
addKilnstriderScreen("report_to_declann", "s_e015cb4", true)
addKilnstriderScreen("tier4_completed", "s_f5e3efbe", false, {
	{"@conversation/tatooine_imperial_tier4:s_4854758d", "tier4_duty_repeat"}
})

addConversationTemplate("kilnstrider_convo", kilnstrider_convo)
