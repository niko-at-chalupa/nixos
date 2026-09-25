hl.env("XCURSOR_SIZE",          "17")
hl.env("HYPRCURSOR_SIZE",       "20")
hl.env("QT_QPA_PLATFORMTHEME",  "qt6ct")
hl.env("XDG_CURRENT_DESKTOP",   "Hyprland")
hl.env("XDG_SESSION_TYPE",      "wayland")
hl.env("XDG_SESSION_DESKTOP",   "Hyprland")
hl.env("GDK_SCALE",    "1")
hl.env("XCURSOR_SIZE", "32")

hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("soteria")
    hl.exec_cmd("kdeconnect-indicator")
    hl.exec_cmd("copyq --start-server")
    hl.exec_cmd("npx arrpc")
    hl.exec_cmd("kded5")
    hl.exec_cmd("kbuildsycoca5")
    hl.exec_cmd("input-remapper-control --command autoload")
	hl.exec_cmd("noctalia &")
end)

hl.monitor({
    output   = "",
    mode     = "highres",
    position = "auto",
    scale    = 1.25,
})

local terminal    = "ghostty"
local fileManager = "dolphin"
local menu = "fuzzel"

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = -1.0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.device({
    name        = "elan07ba:00-04f3:3276-touchpad",
    sensitivity = 0,
})

hl.device({
    name = "pixart-usb-optical-mouse",
    sensitivity = -0.2,
    accel_profile = "flat",
})

hl.device({
    name = "elan07ba:00-04f3:3276-mouse",
    sensitivity = 0.001,
    accel_profile = "adaptive",
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + X",         hl.dsp.window.close())
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only --freeze"))
hl.bind(mainMod .. " + Z",         hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("qs -c \"noctalia-shell\" ipc call plugin:keybind-cheatsheet toggle"))


for i = 1, 10 do
    local ws  = i
    local key = ws % 10
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
end

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + CTRL + A", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + CTRL + D", hl.dsp.layout("swapcol r"))

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),                          { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                          { repeating = true })

hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"))

hl.bind(mainMod .. " + A", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + D", hl.dsp.focus({ direction = "r" }))

hl.bind(mainMod .. " + W", function()
    local id = hl.get_active_workspace().id
    if id > 1 then
        hl.dispatch(hl.dsp.focus({ workspace = id - 1 }))
    else
        hl.exec_cmd("touch /tmp/qs-workspace-zero")
        hl.exec_cmd("qs -p /home/niko/.config/hypr/workspacezero.qml")
    end
end)
hl.bind(mainMod .. " + S", function()
    local id = hl.get_active_workspace().id
    if id < 10 then hl.dispatch(hl.dsp.focus({ workspace = id + 1 })) end
end)

hl.bind(mainMod .. " + SHIFT + A", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.layout("colresize +conf"))

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 20,
        border_size = 2,
        ["col.active_border"]   = "rgba(ae84cfee)",
        ["col.inactive_border"] = "rgba(313244aa)",
    },
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size    = 8,
            passes  = 2,
        },
        glow = {
            enabled = false,
        },
    },
    dwindle = {
        preserve_split = true,
    },
    scrolling = {
        column_width           = 0.5,
        direction              = "right",
        focus_fit_method       = 1,
        explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
    xwayland = {
        force_zero_scaling = true,
    },
})

for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), layout = "scrolling" })
end

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("easeOutCubic",   { type = "bezier", points = { {0.33, 1},    {0.68, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easeInQuad",     { type = "bezier", points = { {0.11, 0},    {0.5, 0}     } })
hl.curve("easeOutQuad",    { type = "bezier", points = { {0.5, 1},     {0.89, 1}    } })
hl.curve("easeInOutQuad",  { type = "bezier", points = { {0.45, 0},    {0.55, 1}    } })
hl.curve("easeInCubic",    { type = "bezier", points = { {0.32, 0},    {0.67, 0}    } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default"        })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint"   })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint"   })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 1.49, bezier = "easeOutQuint",  style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "easeOutQuint",  style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear"   })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear"   })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick"          })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint"   })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint",   style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",         style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear"   })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear"   })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 7.5,  bezier = "easeOutQuint",   style = "slidefadevert" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 6,  bezier = "easeOutQuint",   style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 6,    bezier = "easeOutQuint",   style = "slidevert" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick"           })

-- Steam: ignore maximize requests & suppress empty-title popup
hl.window_rule({ match = { class = "^(steam)$", title = "^()$" }, stay_focused = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^()$" }, size = { 1, 1 }    })

-- Steam: force auxiliary windows to float
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Steam - News)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^([Ss]tats)$"     }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^([Cc]onsole)$"   }, float = true })

-- hyprmon: managed monitor profile include
require("hyprmon")

hl.window_rule({ match = { content = "game", fullscreen = true }, confine_pointer = true })
hl.window_rule({ match = { class = "mcpelauncher-client" }, confine_pointer = true })
