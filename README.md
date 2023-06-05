# player_settings

## Definition tables

### Metacategories

Used by `player_settings.register_metacategory`.

```lua
{
    title = "",
    -- Display title of the metacategory.

    allow_show = function(player) return true end,
    -- Determine if the metacategory should be shown to the player.
    -- If returned false, all its child will be hidden.
}
```

### Categories

Used by `player_settings.register_category`.

```lua
{
    title = "",
    -- Display title of the category.

    metacategory = "general",
    -- The ID of the metacategory.

    allow_show = function(player) return true end,
    -- Determine if the category should be shown to the player.
    -- If returned false, all its child will be hidden.
}
```

### Settings

Used by `player_settings.register_setting`.

```lua
{
    description = "",
    -- Short description of the setting. It should be as short and as simple as possible.

    long_description = ""
    -- Long description of the setting.

    type = "int" / "string" / "bool" / "float" / "enum",
    -- Type of the setting.

    default = "",
    -- Default value of the setting.

    number_min = math.min,
    number_max = math.huge,
    -- Only applies when type == "int" / "float".
    -- The lowest and the highest value of the setting.

    enum_type = "int" / "string" / "float",
    -- Only applies when type == "enum".
    -- The type of the choices.

    enum_choices = ["1", "2", ...]
    -- Only applies when type == "enum".
    -- All the avaliable choices.

    validator = function(name, key, value) end,
    -- Validates the input before it is being stored.
    -- `name` is the player's name.
    -- `key` is the ID of the setting.
    -- `value` is the value of the setting to be modified.
    -- Should return either `true` or a error message.

    after_change = function(name, key, old_value, new_value) end,
    -- Function triggered after a player had successfully modified one setting.
    -- `name` is the player's name.
    -- `key` is the ID of the setting.
    -- `old_value` is the value of the setting before modifications.
    -- `new_value` is the value of the setting after modifications.

    category = "general",
    -- The ID of the category.

    allow_show = function(name) return true end,
    -- Determine if the setting should be shown to the player.
    -- If returned false, it will be hidden.
}
```
