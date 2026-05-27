local S = core.get_translator("player_settings")
local _ps = player_settings

_ps.register_metacategory("ps_default_control", {
    title = S("Control"),
})

_ps.register_metacategory("ps_default_av", {
    title = S("Audio and Visuals"),
})

_ps.register_metacategory("ps_default_advanced", {
    title = S("Advanced"),
})
