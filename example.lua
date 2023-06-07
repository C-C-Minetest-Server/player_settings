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

_ps.register_setting("ps_example_enum_string", {
    type = "enum",
    description = S("Example of @1", "enum (string)"),
    long_description = S("Long description. \nExample of @1","enum (string)"),
    default = "1F616EMO",
    category = "ps_example",
    enum_type = "string",
    enum_choices = {
        "lorem",
        "ipsum",
        "hello",
        "world",
        "minetest",
        "1F616EMO",
    }
})

_ps.register_category("ps_example_empty",{
    title = S("Empty Examples"),
    metacategory = "ps_example_mc"
})