local MP = minetest.get_modpath("player_settings")

player_settings = {}

dofile(MP .. "/util.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/gui.lua")

if minetest.is_singleplayer() or minetest.settings:get_bool("player_settings_register_example", false) then
    dofile(MP .. "/example.lua")
end
