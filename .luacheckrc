max_line_length = false

exclude_files = {
	"Data_Forever.lua",
	"Data_Mists.lua",
	"Data_Standard.lua",
	"Data_TBC.lua",
	"Data_Vanilla.lua",
	"Data_Wrath.lua",
}

ignore = {
	"11./^TAV_", -- Ignore all global reads/writes on TAV_ prefixed globals.
	"212/self", -- Ignore unused 'self' warnings
}

globals = {
	"SLASH_TAVSLASH1",
	"SLASH_TAVSLASH2",
}

read_globals = {
	"LibStub",
}

std = "lua51+wow"

stds.wow = {
	globals = {
		SlashCmdList = {
			fields = {
				"TAVSLASH",
			},
		},
	},

	read_globals = {
		C_Intl = {
			fields = {
				"GetSortKey",
			},
		},

		C_Texture = {
			fields = {
				"GetAtlasElements",
				"GetAtlasInfo",
			},
		},

		Enum = {
			fields = {
				CollationStrength = {
					fields = {
						"Primary",
					},
				},

				UITextureSliceMode = {
					fields = {
						"Stretched",
						"Tiled"
					}
				}
			}
		},

		SOUNDKIT = {
			fields = {
				"IG_ABILITY_PAGE_TURN",
				"IG_CHARACTER_INFO_CLOSE",
				"IG_CHARACTER_INFO_OPEN",
				"IG_MAINMENU_OPTION_CHECKBOX_OFF",
				"IG_MAINMENU_OPTION_CHECKBOX_ON",
			},
		},

		"ButtonFrameTemplate_HidePortrait",
		"Clamp",
		"ClearOverrideBindings",
		"ColorPickerFrame",
		"CreateColor",
		"CreateDataProvider",
		"CreateFramePool",
		"CreateScrollBoxListLinearView",
		"ExecuteFrameScript",
		"FindInTableIf",
		"floor",
		"GameTooltip_SetTitle",
		"GameTooltip",
		"GenerateClosure",
		"GetBuildInfo",
		"GetCursorPosition",
		"GRAY_FONT_COLOR",
		"GREEN_FONT_COLOR",
		"HIGHLIGHT_FONT_COLOR",
		"InCombatLockdown",
		"IsControlKeyDown",
		"LE_EXPANSION_BURNING_CRUSADE",
		"LE_EXPANSION_CATACLYSM",
		"LE_EXPANSION_CLASSIC",
		"LE_EXPANSION_DRAGONFLIGHT",
		"LE_EXPANSION_LEVEL_CURRENT",
		"LE_EXPANSION_LEVEL_CURRENT",
		"LE_EXPANSION_MISTS_OF_PANDARIA",
		"LE_EXPANSION_THE_WAR_WITHIN",
		"LE_EXPANSION_WRATH_OF_THE_LICH_KING",
		"max",
		"min",
		"NORMAL_FONT_COLOR",
		"PERCENTAGE_STRING",
		"PlaySound",
		"RED_FONT_COLOR",
		"Round",
		"Saturate",
		"ScrollBoxConstants",
		"ScrollUtil",
		"SetOverrideBindingClick",
		"tinsert",
		"TOOLTIP_DEFAULT_BACKGROUND_COLOR",
		"UIParent",
		"UISpecialFrames",
		"UNKNOWN",
		"wipe",
		"YELLOW_FONT_COLOR",
	},
}
