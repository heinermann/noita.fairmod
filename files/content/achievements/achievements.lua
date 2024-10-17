achievements = {
	{
		name = "Shitted",
		description = "You shitted and farted!!!",
		icon = "mods/noita.fairmod/files/content/achievements/icons/shitted.png",
		flag = "achievement_shitted",
		unlock = function()
			return GlobalsGetValue("TIMES_TOOK_SHIT", "0") ~= "0"
		end,
	},
	{
		name = "Time to take a piss!",
		description = "You emptied your bladder.",
		icon = nil,
		flag = "achievement_pissed",
		unlock = function()
			return GlobalsGetValue("TIMES_TOOK_PISS", "0") ~= "0"
		end,
	},
	{
		name = "Poop Ending",
		description = "And thus, the world was turned to shit.",
		icon = nil,
		flag = "achievement_poop_ending",
		unlock = function()
			return GameHasFlagRun("poop_ending")
		end,
	},
	{
		name = "Bankruptcy",
		description = "Collect a debt of 10k gold or more.",
		icon = nil,
		flag = "achievement_debt_collector",
		unlock = function()
			return tonumber(GlobalsGetValue("loan_shark_debt", "0")) >= 10000
		end,
	},
	{
		name = "Speedrunner",
		description = "Enter the speedrun door.",
		icon = nil,
		flag = "achievement_speedrunner",
		unlock = function()
			return GameHasFlagRun("speedrun_door_used")
		end,
	},
	{
		name = "What have you done",
		description = "What did they do to deserve this?",
		icon = "mods/noita.fairmod/files/content/achievements/icons/hamis_massacre.png",
		flag = "achievement_hamis_killed",
		unlock = function()
			return (tonumber(GlobalsGetValue("FAIRMOD_HAMIS_KILLED")) or 0) > 5
		end
	},
	{
		name = "Too much acid",
		description = "Did it bother you?",
		icon = "mods/noita.fairmod/files/content/achievements/icons/giant_shooter.png",
		flag = "achievement_giantshooter_killed",
		unlock = function()
			return GameHasFlagRun("FAIRMOD_GIANTSHOOTER_KILLED")
		end
	},
	{
		name = "The Things In Question",
		description = "Peak content unlocked! :check:",
		icon = "mods/noita.fairmod/files/content/achievements/icons/copith.png",
		flag = "achievement_copis_things",
		unlock = function()
			return ModIsEnabled("copis_things")
		end
	},
	{
		name = "Sucks to Suck",
		description = "Got giga critted!",
		icon = "mods/noita.fairmod/files/content/achievements/icons/giga_critted.png",
		flag = "achievement_giga_critted",
		unlock = function()
			return GameHasFlagRun("giga_critted_lol")
		end
	},
	{
		name = "Take to the Skies",
		description = "help how do i get down what im gonna hit the roof ow fuck",
		icon = "mods/noita.fairmod/files/content/achievements/icons/oiled_up.png",
		flag = "achievement_oiled_up",
		unlock = function()
			return GameHasFlagRun("oiled_up")
		end
	},
	{
		name = "Ow Fuck",
		description = "You had a heart attack!",
		icon = "mods/noita.fairmod/files/content/achievements/icons/heart_attacked.png",
		flag = "achievement_heart_attacked",
		unlock = function()
			return GameHasFlagRun("heart_attacked")
		end
	},
	{
		name = "Add mana: Balanced",
		description = "Game quality +500%",
		icon = "mods/noita.fairmod/files/content/achievements/icons/hahah_fuck_your_mana.png",
		flag = "achievement_hahah_fuck_your_mana",
		unlock = function()
			return GameHasFlagRun("hahah_fuck_your_mana")
		end
	},
	{
		name = "Avoided Heart Attack!",
		description = "Epic heart health win!",
		icon = "mods/noita.fairmod/files/content/achievements/icons/fake_heart_attack.png",
		flag = "achievement_fake_heart_attack",
		unlock = function()
			return Random(1, 108000) == 1
		end
	},
	{
		name = "Degraded Game Experience",
		description = "Why!?!> Disable nightmare.",
		icon = "mods/noita.fairmod/files/content/achievements/icons/nighmare_mode.png",
		flag = "nighmare_mode",
		unlock = function()
			return ModIsEnabled("nightmare")
		end
	},
	{
		name = "Just.. one.. more...",
		description = "99% gamblers quit before big win! Next roll = $5m payout",
		icon = "mods/noita.fairmod/files/content/achievements/icons/gamble_fail.png",
		flag = "gamble_fail",
		unlock = function()
			return tonumber(GlobalsGetValue("GAMBLECORE_TIMES_LOST_IN_A_ROW", "0")) > 5
		end
	},
	{
		name = "Gamble God",
		description = "Winnar is you!",
		icon = "mods/noita.fairmod/files/content/achievements/icons/gamble_win.png",
		flag = "gamble_win",
		unlock = function()
			return tonumber(GlobalsGetValue("GAMBLECORE_TIMES_WON", "0")) >= 1
		end
	}
}
