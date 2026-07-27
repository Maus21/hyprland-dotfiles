------------------
----MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

local home = os.getenv("HOME") or ""
local tide_qml = home .. "/.local/share/tide-island-dotfiles"
local tide_ipc = "/usr/bin/quickshell ipc --any-display -p " .. tide_qml

-- Safe on a first boot with any display. scripts/configure-displays writes a
-- machine-local hardware.lua with preferred modes and workspace assignments.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
pcall(dofile, home .. "/.config/hypr/hardware.lua")

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "kitty"
local fileManager = "kitty -e yazi"

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	hl.exec_cmd(home .. "/.local/bin/start-tide-island")
	hl.exec_cmd("sh -c 'sleep 1 && \"$HOME/.local/bin/restore-wallpaper\"'")
	hl.exec_cmd("sh -c 'sleep 2 && easyeffects --gapplication-service'")
	--   hl.exec_cmd("waybar & hyprpaper & firefox")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,

		border_size = 1,

		col = {
			active_border = {
				colors = {
					"rgba(7aa2f733)",
					"rgba(41a6b533)",
					"rgba(b48ead33)",
				},
				angle = 45,
			},
			inactive_border = "rgba(4c566a1f)",
		}, -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 0.9,
		inactive_opacity = 0.8,

		shadow = {
			enabled = true,
			range = 20,
			render_power = 3,
			color = 0xee1a1a1a,
		},

		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			vibrancy = 0.1696,
			new_optimizations = true,
			xray = true,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Animation presets
-- Change only this value to test a preset. "current" preserves the setup that
-- was active before the HyDE presets were added.
local active_animation_preset = "optimized"

-- Converted from HyDE commit a51460a7b1a822ee7194318b60a38850f711b923.
-- Curve format: { name, x0, y0, x1, y1 }
-- Animation format: { leaf, enabled, speed, bezier, style }
local animation_presets = {
	current = {
		enabled = true,
		curves = {
			{ "easeOutQuint", 0.23, 1, 0.32, 1 },
			{ "easeInOutCubic", 0.65, 0.05, 0.36, 1 },
			{ "linear", 0, 0, 1, 1 },
			{ "almostLinear", 0.5, 0.5, 0.75, 1 },
			{ "quick", 0.15, 0, 0.1, 1 },
			{ "myWorkspaceCurve", 0.05, 0.9, 0.1, 1 },
			{ "snap", 0.25, 1, 0.5, 1 },
		},
		springs = {
			-- Hyprland 0.56 changed spring simulation timing. These upstream
			-- compatibility values preserve the faster pre-0.56 feel.
			{ "easy", 1, 238.1191, 24.21279333 },
		},
		animations = {
			{ "global", true, 1.5, "snap" },
			{ "workspacesIn", true, 4, "snap", "slide" },
			{ "workspacesOut", true, 4, "snap", "slidefade " },
			{ "global", true, 1, "quick" },
			{ "border", true, 2.39, "easeOutQuint" },
			{ "windows", true, 2, "quick" },
			{ "windowsIn", true, 2, "snap", "popin 87%" },
			{ "windowsOut", true, 1.49, "snap", "popin 87%" },
			{ "fadeIn", true, 1.73, "almostLinear" },
			{ "fadeOut", true, 1.46, "almostLinear" },
			{ "fade", true, 3.03, "quick" },
			{ "layers", true, 3.81, "snap" },
			{ "layersIn", true, 4, "easeOutQuint", "fade" },
			{ "layersOut", true, 1.5, "linear", "fade" },
			{ "fadeLayersIn", true, 1.79, "almostLinear" },
			{ "fadeLayersOut", true, 1.39, "almostLinear" },
			{ "workspaces", true, 1.94, "almostLinear", "fade" },
			{ "zoomFactor", true, 7, "quick" },
		},
	},

	LimeFrenzy = {
		enabled = true,
		curves = {
			{ "default", 0.12, 0.92, 0.08, 1 },
			{ "wind", 0.12, 0.92, 0.08, 1 },
			{ "overshot", 0.18, 0.95, 0.22, 1.03 },
			{ "liner", 1, 1, 1, 1 },
		},
		animations = {
			{ "windows", true, 5, "wind", "popin 60%" },
			{ "windowsIn", true, 6, "overshot", "popin 60%" },
			{ "windowsOut", true, 4, "overshot", "popin 60%" },
			{ "windowsMove", true, 4, "overshot", "slide" },
			{ "layers", true, 4, "default", "popin" },
			{ "fadeIn", true, 7, "default" },
			{ "fadeOut", true, 7, "default" },
			{ "fadeSwitch", true, 7, "default" },
			{ "fadeShadow", true, 7, "default" },
			{ "fadeDim", true, 7, "default" },
			{ "fadeLayers", true, 7, "default" },
			{ "workspaces", true, 5, "overshot", "slidevert" },
			{ "border", true, 1, "liner" },
			{ "borderangle", true, 24, "liner", "loop" },
		},
	},

	classic = {
		enabled = true,
		curves = {
			{ "myBezier", 0.05, 0.9, 0.1, 1.05 },
		},
		animations = {
			{ "windows", true, 7, "myBezier" },
			{ "windowsOut", true, 7, "default", "popin 80%" },
			{ "border", true, 10, "default" },
			{ "borderangle", true, 8, "default" },
			{ "fade", true, 7, "default" },
			{ "workspaces", true, 6, "default" },
		},
	},

	["diablo-1"] = {
		enabled = true,
		curves = {
			{ "default", 0.05, 0.9, 0.1, 1.05 },
			{ "wind", 0.05, 0.9, 0.1, 1.05 },
			{ "overshot", 0.13, 0.99, 0.29, 1.08 },
			{ "liner", 1, 1, 1, 1 },
			{ "bounce", 0.4, 0.9, 0.6, 1 },
			{ "snappyReturn", 0.4, 0.9, 0.6, 1 },
			{ "slideInFromRight", 0.5, 0, 0.5, 1 },
		},
		animations = {
			{ "windows", true, 5, "snappyReturn", "slidevert" },
			{ "windowsIn", true, 5, "snappyReturn", "slidevert right" },
			{ "windowsOut", true, 5, "snappyReturn", "slide" },
			{ "windowsMove", true, 6, "bounce", "slide" },
			{ "layersOut", true, 5, "bounce", "slidevert right" },
			{ "fadeIn", true, 10, "default" },
			{ "fadeOut", true, 10, "default" },
			{ "fadeSwitch", true, 10, "default" },
			{ "fadeShadow", true, 10, "default" },
			{ "fadeDim", true, 10, "default" },
			{ "fadeLayers", true, 10, "default" },
			{ "workspaces", true, 7, "overshot", "slidevert" },
			{ "border", true, 1, "liner" },
			{ "layers", true, 4, "bounce", "slidevert right" },
			{ "borderangle", true, 30, "liner", "loop" },
		},
	},

	["diablo-2"] = {
		enabled = true,
		curves = {
			{ "default", 0.05, 0.9, 0.1, 1.05 },
			{ "wind", 0.05, 0.9, 0.1, 1.05 },
			{ "overshot", 0.13, 0.99, 0.29, 1.08 },
			{ "liner", 1, 1, 1, 1 },
		},
		animations = {
			{ "windows", true, 7, "wind", "popin" },
			{ "windowsIn", true, 7, "overshot", "popin" },
			{ "windowsOut", true, 5, "overshot", "popin" },
			{ "windowsMove", true, 6, "overshot", "slide" },
			{ "layers", true, 5, "default", "popin" },
			{ "fadeIn", true, 10, "default" },
			{ "fadeOut", true, 10, "default" },
			{ "fadeSwitch", true, 10, "default" },
			{ "fadeShadow", true, 10, "default" },
			{ "fadeDim", true, 10, "default" },
			{ "fadeLayers", true, 10, "default" },
			{ "workspaces", true, 7, "overshot", "slidevert" },
			{ "border", true, 1, "liner" },
			{ "borderangle", true, 30, "liner", "loop" },
		},
	},

	disable = {
		enabled = false,
		animations = {},
	},

	dynamic = {
		enabled = true,
		curves = {
			{ "wind", 0.05, 0.9, 0.1, 1.05 },
			{ "winIn", 0.1, 1.1, 0.1, 1.1 },
			{ "winOut", 0.3, -0.3, 0, 1 },
			{ "liner", 1, 1, 1, 1 },
		},
		animations = {
			{ "windows", true, 6, "wind", "slide" },
			{ "windowsIn", true, 6, "winIn", "slide" },
			{ "windowsOut", true, 5, "winOut", "slide" },
			{ "windowsMove", true, 5, "wind", "slide" },
			{ "border", true, 1, "liner" },
			{ "borderangle", true, 30, "liner", "loop" },
			{ "fade", true, 10, "default" },
			{ "workspaces", true, 5, "wind" },
		},
	},

	end4 = {
		enabled = true,
		curves = {
			{ "linear", 0, 0, 1, 1 },
			{ "md3_standard", 0.2, 0, 0, 1 },
			{ "md3_decel", 0.05, 0.7, 0.1, 1 },
			{ "md3_accel", 0.3, 0, 0.8, 0.15 },
			{ "overshot", 0.05, 0.9, 0.1, 1.1 },
			{ "crazyshot", 0.1, 1.5, 0.76, 0.92 },
			{ "hyprnostretch", 0.05, 0.9, 0.1, 1 },
			{ "menu_decel", 0.1, 1, 0, 1 },
			{ "menu_accel", 0.38, 0.04, 1, 0.07 },
			{ "easeInOutCirc", 0.85, 0, 0.15, 1 },
			{ "easeOutCirc", 0, 0.55, 0.45, 1 },
			{ "easeOutExpo", 0.16, 1, 0.3, 1 },
			{ "softAcDecel", 0.26, 0.26, 0.15, 1 },
			{ "md2", 0.4, 0, 0.2, 1 },
		},
		animations = {
			{ "windows", true, 3, "md3_decel", "popin 60%" },
			{ "windowsIn", true, 3, "md3_decel", "popin 60%" },
			{ "windowsOut", true, 3, "md3_accel", "popin 60%" },
			{ "border", true, 10, "default" },
			{ "fade", true, 3, "md3_decel" },
			{ "layersIn", true, 3, "menu_decel", "slide" },
			{ "layersOut", true, 1.6, "menu_accel" },
			{ "fadeLayersIn", true, 2, "menu_decel" },
			{ "fadeLayersOut", true, 4.5, "menu_accel" },
			{ "workspaces", true, 7, "menu_decel", "slide" },
			{ "specialWorkspace", true, 3, "md3_decel", "slidevert" },
		},
	},

	fast = {
		enabled = true,
		curves = {
			{ "linear", 0, 0, 1, 1 },
			{ "md3_standard", 0.2, 0, 0, 1 },
			{ "md3_decel", 0.05, 0.7, 0.1, 1 },
			{ "md3_accel", 0.3, 0, 0.8, 0.15 },
			{ "overshot", 0.05, 0.9, 0.1, 1.1 },
			{ "crazyshot", 0.1, 1.5, 0.76, 0.92 },
			{ "hyprnostretch", 0.05, 0.9, 0.1, 1 },
			{ "fluent_decel", 0.1, 1, 0, 1 },
			{ "easeInOutCirc", 0.85, 0, 0.15, 1 },
			{ "easeOutCirc", 0, 0.55, 0.45, 1 },
			{ "easeOutExpo", 0.16, 1, 0.3, 1 },
		},
		animations = {
			{ "windows", true, 3, "md3_decel", "popin 60%" },
			{ "border", true, 10, "default" },
			{ "fade", true, 2.5, "md3_decel" },
			{ "workspaces", true, 3.5, "easeOutExpo", "slide" },
			{ "specialWorkspace", true, 3, "md3_decel", "slidevert" },
		},
	},

	high = {
		enabled = true,
		curves = {
			{ "wind", 0.05, 0.9, 0.1, 1.05 },
			{ "winIn", 0.1, 1.1, 0.1, 1.1 },
			{ "winOut", 0.3, -0.3, 0, 1 },
			{ "liner", 1, 1, 1, 1 },
		},
		animations = {
			{ "windows", true, 6, "wind", "slide" },
			{ "windowsIn", true, 6, "winIn", "slide" },
			{ "windowsOut", true, 5, "winOut", "slide" },
			{ "windowsMove", true, 5, "wind", "slide" },
			{ "border", true, 1, "liner" },
			{ "borderangle", true, 30, "liner", "loop" },
			{ "fade", true, 10, "default" },
			{ "workspaces", true, 5, "wind" },
		},
	},

	ja = {
		enabled = true,
		curves = {
			{ "wind", 0.05, 0.9, 0.1, 1.05 },
			{ "winIn", 0.1, 1.1, 0.1, 1.1 },
			{ "winOut", 0.3, -0.3, 0, 1 },
			{ "liner", 1, 1, 1, 1 },
			{ "overshot", 0.05, 0.9, 0.1, 1.05 },
			{ "smoothOut", 0.5, 0, 0.99, 0.99 },
			{ "smoothIn", 0.5, -0.5, 0.68, 1.5 },
		},
		animations = {
			{ "windows", true, 6, "wind", "slide" },
			{ "windowsIn", true, 5, "winIn", "slide" },
			{ "windowsOut", true, 3, "smoothOut", "slide" },
			{ "windowsMove", true, 5, "wind", "slide" },
			{ "border", true, 1, "liner" },
			{ "fade", true, 3, "smoothOut" },
			{ "workspaces", true, 5, "overshot" },
			{ "workspacesIn", true, 5, "winIn", "slide" },
			{ "workspacesOut", true, 5, "winOut", "slide" },
		},
	},

	["me-1"] = {
		enabled = true,
		curves = {
			{ "wind", 0.05, 0.9, 0.1, 1.05 },
			{ "winIn", 0.1, 1.1, 0.1, 1.1 },
			{ "winOut", 0.3, -0.3, 0, 1 },
			{ "liner", 1, 1, 1, 1 },
			{ "md3_standard", 0.2, 0, 0, 1 },
			{ "md3_decel", 0.05, 0.7, 0.1, 1 },
			{ "md3_accel", 0.3, 0, 0.8, 0.15 },
			{ "overshot", 0.05, 0.9, 0.1, 1.1 },
			{ "crazyshot", 0.1, 1.5, 0.76, 0.92 },
			{ "hyprnostretch", 0.05, 0.9, 0.1, 1 },
			{ "menu_decel", 0.1, 1, 0, 1 },
			{ "menu_accel", 0.38, 0.04, 1, 0.07 },
			{ "easeInOutCirc", 0.85, 0, 0.15, 1 },
			{ "easeOutCirc", 0, 0.55, 0.45, 1 },
			{ "easeOutExpo", 0.16, 1, 0.3, 1 },
			{ "softAcDecel", 0.26, 0.26, 0.15, 1 },
			{ "md2", 0.4, 0, 0.2, 1 },
		},
		animations = {
			{ "border", true, 1, "liner" },
			{ "borderangle", true, 30, "liner", "loop" },
			{ "windows", true, 6, "wind", "slide" },
			{ "windowsIn", true, 6, "winIn", "slide" },
			{ "windowsOut", true, 5, "winOut", "slide" },
			{ "windowsMove", true, 5, "wind", "slide" },
			{ "fade", true, 3, "md3_decel" },
			{ "layersIn", true, 3, "menu_decel", "slide" },
			{ "layersOut", true, 1.6, "menu_accel" },
			{ "fadeLayersIn", true, 2, "menu_decel" },
			{ "fadeLayersOut", true, 4.5, "menu_accel" },
			{ "workspaces", true, 5, "wind" },
			{ "specialWorkspace", true, 3, "md3_decel", "slidevert" },
		},
	},

	["me-2"] = {
		enabled = true,
		curves = {
			{ "wind", 0.05, 0.9, 0.1, 1.05 },
			{ "winIn", 0.1, 1.1, 0.1, 1.1 },
			{ "winOut", 0.3, -0.3, 0, 1 },
			{ "liner", 1, 1, 1, 1 },
			{ "md3_standard", 0.2, 0, 0, 1 },
			{ "md3_decel", 0.05, 0.7, 0.1, 1 },
			{ "md3_accel", 0.3, 0, 0.8, 0.15 },
			{ "overshot", 0.05, 0.9, 0.1, 1.1 },
			{ "crazyshot", 0.1, 1.5, 0.76, 0.92 },
			{ "hyprnostretch", 0.05, 0.9, 0.1, 1 },
			{ "menu_decel", 0.1, 1, 0, 1 },
			{ "menu_accel", 0.38, 0.04, 1, 0.07 },
			{ "easeInOutCirc", 0.85, 0, 0.15, 1 },
			{ "easeOutCirc", 0, 0.55, 0.45, 1 },
			{ "easeOutExpo", 0.16, 1, 0.3, 1 },
			{ "softAcDecel", 0.26, 0.26, 0.15, 1 },
			{ "md2", 0.4, 0, 0.2, 1 },
			{ "OutBack", 0.34, 1.56, 0.64, 1 },
		},
		animations = {
			{ "border", true, 1, "liner" },
			{ "borderangle", true, 30, "liner", "loop" },
			{ "windowsIn", true, 6, "winIn", "slide" },
			{ "windows", true, 5, "easeInOutCirc" },
			{ "windowsOut", true, 5, "OutBack" },
			{ "windowsMove", true, 5, "wind", "slide" },
			{ "fade", true, 3, "md3_decel" },
			{ "layersIn", true, 3, "menu_decel", "slide" },
			{ "layersOut", true, 1.6, "menu_accel" },
			{ "fadeLayersIn", true, 2, "menu_decel" },
			{ "fadeLayersOut", true, 4.5, "menu_accel" },
			{ "workspaces", true, 5, "wind" },
			{ "specialWorkspace", true, 3, "md3_decel", "slidevert" },
		},
	},

	["minimal-1"] = {
		enabled = true,
		curves = {
			{ "wind", 0.05, 0.9, 0.1, 1.05 },
			{ "winIn", 0.1, 1.1, 0.1, 1.1 },
			{ "winOut", 0.3, -0.3, 0, 1 },
			{ "liner", 1, 1, 1, 1 },
		},
		animations = {
			{ "windows", true, 6, "wind", "slide" },
			{ "windowsIn", true, 6, "winIn", "slide" },
			{ "windowsOut", true, 5, "winOut", "slide" },
			{ "windowsMove", true, 5, "wind", "slide" },
			{ "border", true, 1, "liner" },
			{ "borderangle", true, 30, "liner", "loop" },
			{ "fade", true, 10, "default" },
			{ "workspaces", true, 5, "wind" },
		},
	},

	["minimal-2"] = {
		enabled = true,
		curves = {
			{ "quart", 0.25, 1, 0.5, 1 },
		},
		animations = {
			{ "windows", true, 6, "quart", "slide" },
			{ "border", true, 6, "quart" },
			{ "borderangle", true, 6, "quart" },
			{ "fade", true, 6, "quart" },
			{ "workspaces", true, 6, "quart" },
		},
	},

	moving = {
		enabled = true,
		curves = {
			{ "overshot", 0.05, 0.9, 0.1, 1.05 },
			{ "smoothOut", 0.5, 0, 0.99, 0.99 },
			{ "smoothIn", 0.5, -0.5, 0.68, 1.5 },
		},
		animations = {
			{ "windows", true, 5, "overshot", "slide" },
			{ "windowsOut", true, 3, "smoothOut" },
			{ "windowsIn", true, 3, "smoothOut" },
			{ "windowsMove", true, 4, "smoothIn", "slide" },
			{ "border", true, 5, "default" },
			{ "fade", true, 5, "smoothIn" },
			{ "fadeDim", true, 5, "smoothIn" },
			{ "workspaces", true, 6, "default" },
		},
	},

	optimized = {
		enabled = true,
		curves = {
			{ "wind", 0.05, 0.85, 0.03, 0.97 },
			{ "winIn", 0.07, 0.88, 0.04, 0.99 },
			{ "winOut", 0.2, -0.15, 0, 1 },
			{ "liner", 1, 1, 1, 1 },
			{ "md3_standard", 0.12, 0, 0, 1 },
			{ "md3_decel", 0.05, 0.8, 0.1, 0.97 },
			{ "md3_accel", 0.2, 0, 0.8, 0.08 },
			{ "overshot", 0.05, 0.85, 0.07, 1.04 },
			{ "crazyshot", 0.1, 1.22, 0.68, 0.98 },
			{ "hyprnostretch", 0.05, 0.82, 0.03, 0.94 },
			{ "menu_decel", 0.05, 0.82, 0, 1 },
			{ "menu_accel", 0.2, 0, 0.82, 0.1 },
			{ "easeInOutCirc", 0.78, 0, 0.15, 1 },
			{ "easeOutCirc", 0, 0.48, 0.38, 1 },
			{ "easeOutExpo", 0.1, 0.94, 0.23, 0.98 },
			{ "softAcDecel", 0.2, 0.2, 0.15, 1 },
			{ "md2", 0.3, 0, 0.15, 1 },
			{ "OutBack", 0.28, 1.4, 0.58, 1 },
		},
		animations = {
			{ "border", true, 1.6, "liner" },
			{ "borderangle", true, 82, "liner", "loop" },
			{ "windowsIn", true, 3.2, "winIn", "slide" },
			{ "windowsOut", true, 2.8, "easeOutCirc" },
			{ "windowsMove", true, 3, "wind", "slide" },
			{ "fade", true, 1.8, "md3_decel" },
			{ "layersIn", true, 1.8, "menu_decel", "slide" },
			{ "layersOut", true, 1.5, "menu_accel" },
			{ "fadeLayersIn", true, 1.6, "menu_decel" },
			{ "fadeLayersOut", true, 1.8, "menu_accel" },
			{ "workspaces", true, 4, "menu_decel", "slide" },
			{ "specialWorkspace", true, 2.3, "md3_decel", "slidefadevert 15%" },
		},
	},

	standard = {
		enabled = true,
		curves = {
			{ "myBezier", 0.05, 0.9, 0.1, 1.05 },
		},
		animations = {
			{ "windows", true, 7, "myBezier" },
			{ "windowsOut", true, 7, "default", "popin 80%" },
			{ "border", true, 10, "default" },
			{ "borderangle", true, 8, "default" },
			{ "fade", true, 7, "default" },
			{ "workspaces", true, 6, "default" },
		},
	},

	theme = {
		enabled = true,
		curves = {
			{ "wind", 0.05, 0.9, 0.1, 1.05 },
			{ "winIn", 0.1, 1.1, 0.1, 1.1 },
			{ "winOut", 0.3, -0.3, 0, 1 },
			{ "liner", 1, 1, 1, 1 },
		},
		animations = {
			{ "windows", true, 6, "wind", "slide" },
			{ "windowsIn", true, 6, "winIn", "slide" },
			{ "windowsOut", true, 5, "winOut", "slide" },
			{ "windowsMove", true, 5, "wind", "slide" },
			{ "border", true, 1, "liner" },
			{ "borderangle", true, 30, "liner", "once" },
			{ "fade", true, 10, "default" },
			{ "workspaces", true, 5, "wind" },
		},
	},

	vertical = {
		enabled = true,
		curves = {
			{ "fluent_decel", 0, 0.2, 0.4, 1 },
			{ "easeOutCirc", 0, 0.55, 0.45, 1 },
			{ "easeOutCubic", 0.33, 1, 0.68, 1 },
			{ "easeinoutsine", 0.37, 0, 0.63, 1 },
		},
		animations = {
			{ "windowsIn", true, 1.5, "easeinoutsine", "popin 60%" },
			{ "windowsOut", true, 1.5, "easeOutCubic", "popin 60%" },
			{ "windowsMove", true, 1.5, "easeinoutsine", "slide" },
			{ "fade", true, 2.5, "fluent_decel" },
			{ "fadeLayersIn", false },
			{ "border", false },
			{ "layers", true, 1.5, "easeinoutsine", "popin" },
			{ "workspaces", true, 3, "fluent_decel", "slidefadevert 30%" },
			{ "specialWorkspace", true, 2, "fluent_decel", "slidefade 10%" },
		},
	},
}

local selected_animation_preset =
	assert(animation_presets[active_animation_preset], "Unknown animation preset: " .. active_animation_preset)

hl.config({
	animations = {
		enabled = selected_animation_preset.enabled,
	},
})

for _, curve in ipairs(selected_animation_preset.curves or {}) do
	hl.curve(curve[1], {
		type = "bezier",
		points = { { curve[2], curve[3] }, { curve[4], curve[5] } },
	})
end

for _, spring in ipairs(selected_animation_preset.springs or {}) do
	hl.curve(spring[1], {
		type = "spring",
		mass = spring[2],
		stiffness = spring[3],
		dampening = spring[4],
	})
end

for _, animation in ipairs(selected_animation_preset.animations or {}) do
	local options = {
		leaf = animation[1],
		enabled = animation[2],
	}

	if animation[2] then
		options.speed = animation[3]
		options.bezier = animation[4]
		options.style = animation[5]
	end

	hl.animation(options)
end

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		new_status = "master",
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})

----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		force_default_wallpaper = 1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})
hl.config({
	input = {
		sensitivity = -0.2, -- Adjusts mouse speed (-1.0 to 1.0, where 0 is no modification)
		accel_profile = "flat", -- Disables mouse acceleration (requires quotes in Lua)
	},
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(
	mainMod .. " + DELETE",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(
	mainMod .. " + R",
	hl.dsp.exec_cmd(tide_ipc .. " call tide toggleLauncher")
)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("helium-browser"))
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd("chromium"))
hl.bind(
	mainMod .. " + SHIFT + B",
	hl.dsp.exec_cmd(tide_ipc .. " call island toggle")
)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("sh -c 'hyprshot -m region --raw | satty --filename -'"))
hl.bind(
	mainMod .. " + SHIFT + T",
	hl.dsp.exec_cmd(tide_ipc .. " call tide toggleThemeSwitcher")
)
hl.bind(
	mainMod .. " + T",
	hl.dsp.exec_cmd(tide_ipc .. " call tide toggleCalculator")
)
hl.bind(
	mainMod .. " + Y",
	hl.dsp.exec_cmd(tide_ipc .. " call tide toggleSearch")
)

-- Tide Island
hl.bind(
	"SUPER + TAB",
	hl.dsp.exec_cmd(tide_ipc .. " call overview toggle")
)

hl.bind(
	"SUPER +  left",
	hl.dsp.exec_cmd(tide_ipc .. " call tide showCustom")
)
hl.bind(
	"SUPER + down",
	hl.dsp.exec_cmd(tide_ipc .. " call tide showClock")
)

hl.bind(
	"SUPER + page_down",
	hl.dsp.exec_cmd(tide_ipc .. " call tide toggleWallpaperPicker")
)

-- Swaps windows left to right
hl.bind(mainMod .. " + SHIFT + left", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "left" }))
end)
hl.bind(mainMod .. " + SHIFT + right", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "right" }))
end)
-- Swap windows up and down
hl.bind(mainMod .. " + SHIFT + up", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "up" }))
end)
hl.bind(mainMod .. " + SHIFT + down", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "down" }))
end)

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
--  Special Workspace for minimizing window

hl.bind("SUPER + X", function()
	if hl.get_workspace("special:minimized") then
		hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace(), window = "tag:minimized" }))
		hl.dispatch(hl.dsp.window.clear_tags({ window = "tag:minimized" }))
	else
		hl.dispatch(hl.dsp.window.tag({ tag = "minimized", window = hl.get_active_window() }))
		hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
	end
end)

-- TEST zoom
local MAX_ZOOM = 3
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

---@param offset number
---@return nil
local function zoom(offset)
	local current = hl.get_config("cursor.zoom_factor")
	if offset ~= nil then
		current = current + offset
	elseif current ~= MIN_ZOOM then
		current = MIN_ZOOM
	else
		current = ZOOM_TOGGLE_FACTOR
	end
	current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
	hl.config({ cursor = { zoom_factor = current } })
end

hl.bind("SUPER + SHIFT + Z", zoom)
hl.bind("SUPER + equal", function()
	zoom(0.5)
end)
hl.bind("SUPER + minus", function()
	zoom(-0.5)
end)
-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + N", hl.dsp.workspace.toggle_special("magic"))
--hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- scripts/configure-displays writes the machine-local persistent workspace
-- assignments to hardware.lua.

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	name = "float-satty",
	match = { class = ".*satty.*" },
	float = true, -- Makes the window hover
	center = true, -- Optional: snaps it to the middle of your screen
})

-- Float screenshot window for satty

hl.windowrulev2 = {

	"float, class:^com.gabm.satty$",
	"size 80% 80%, class:^com.gabm.satty$",
	"center, class:^com.gabm.satty$",
}
-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)
hl.layer_rule({
	name = "no-anim-screenshot-selection",
	match = { namespace = "^selection$" },
	no_anim = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- Kitty window rule
hl.window_rule({
	name = "move-kitty",
	match = { class = "kitty" },
	move = { 300, 400 },
	float = false,
	center = true,
})

-- Keep the installed browsers fully opaque and outside Hyprglass/Hyprland blur.
hl.window_rule({
	name = "opaque-browsers",
	match = { class = "^(helium-browser|chromium)$" },
	opacity = "1.0 override 1.0 override 1.0 override",
	no_blur = true,
	tag = "+hyprglass_disabled",
})
