local _ps = player_settings
local S = minetest.get_translator("player_settings")

_ps.register_metacategory("ps_example_mc",{
    title = S("Settings Examples MC"),
})

_ps.register_category("ps_example",{
    title = S("Settings Examples"),
    metacategory = "ps_example_mc"
})

_ps.register_setting("ps_example_int", {
    type = "int",
    description = S("Example of @1", "int"),
    long_description = S("Long description. \nExample of @1","int"),
    default = 1,
    category = "ps_example",
})

_ps.register_setting("ps_example_float", {
    type = "float",
    description = S("Example of @1", "float"),
    long_description = S("Long description. \nExample of @1","float"),
    default = 1.2345,
    category = "ps_example",
})

_ps.register_setting("ps_example_string", {
    type = "string",
    description = S("Example of @1", "string"),
    long_description = S("Long description. \nExample of @1","string"),
    default = "DEFAULT",
    category = "ps_example",
})

_ps.register_setting("ps_example_bool", {
    type = "bool",
    description = S("Example of @1", "bool"),
    long_description = S("Long description. \nExample of @1","bool"),
    default = true,
    category = "ps_example",
})