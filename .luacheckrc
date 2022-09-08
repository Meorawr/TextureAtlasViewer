max_line_length = false;

exclude_files = {
	"Data.lua",
};

ignore = {
	"11./^TAV_",  -- Ignore all global reads/writes on TAV_ prefixed globals.
	"212/self",  -- Ignore unused 'self' warnings
};

globals = {
	"SLASH_TAVSLASH1",
	"SLASH_TAVSLASH2",
};

read_globals = {
	"LibStub",
};

std = "lua51+wow";

stds.wow = {
	globals = {
		SlashCmdList = {
			fields = {
				"TAVSLASH",
			},
		},
	},

	read_globals = {
		C_Texture = {
			fields = {
				"GetAtlasInfo",
			},
		},

		"ColorPickerFrame",
		"CreateColor",
		"CreateFramePool",
		"floor",
		"GameTooltip_SetTitle",
		"GameTooltip",
		"GetBuildInfo",
		"GetCursorPosition",
		"GRAY_FONT_COLOR",
		"GREEN_FONT_COLOR",
		"HIGHLIGHT_FONT_COLOR",
		"HybridScrollFrame_CreateButtons",
		"HybridScrollFrame_GetButtons",
		"HybridScrollFrame_GetOffset",
		"HybridScrollFrame_SetDoNotHideScrollBar",
		"HybridScrollFrame_Update",
		"InCombatLockdown",
		"max",
		"min",
		"NORMAL_FONT_COLOR",
		"OpacitySliderFrame",
		"OpenColorPicker",
		"PERCENTAGE_STRING",
		"PlaySound",
		"RED_FONT_COLOR",
		"Round",
		"Saturate",
		"SOUNDKIT",
		"tinsert",
		"TOOLTIP_DEFAULT_BACKGROUND_COLOR",
		"UIParent",
		"wipe",
		"WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
		"WOW_PROJECT_CLASSIC",
		"WOW_PROJECT_ID",
		"WOW_PROJECT_MAINLINE",
		"WOW_PROJECT_WRATH_CLASSIC",
		"YELLOW_FONT_COLOR",
	},
};
