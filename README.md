# Player Settings

Allow every players to have their own settings screen and tweak their own settings. Type `/settings` to open the settings GUI.

## Settings in `minetest.conf`

* `player_settings_register_example` (bool): Register example settings
  * Default: `false`
  * If enabled, register setting examples.
  * This is always set to true in singleplayer mode regardless of the settings.

## API

### Register Settings

* `player_settings.register_metacategory(name, def)`: Register a settings meta category
  * `name`: The ID of the meta category
  * `def`: a [meta category definition table](#metacategories)
* `player_settings.register_category(name, def)`: Register a settings category
  * `name`: The ID of the category
  * `def`: a [category definition table](#categories)
* `player_settings.register_setting(name, def)`: Register a setting
  * `name`: The ID of the setting
  * `def`: a [setting definition table](#settings)
* `player_settings.unregister_metacategory(name)`: Unregister a metacategory by its name
* `player_settings.unregister_category(name)`: Unregister a category by its name
* `player_settings.unregister_setting(name)`: Unregister a setting by its name

### Interact with Settings

* `player_settings.register_on_settings_set(name,key,old_value,new_value)`: Register callacks on settings set
  * `name`: Name of a player
  * `key`: The ID of the setting
  * `old_value`: The value being replaced
  * `new_value`: The current setting value
  * *Not recommended.* To monitor individual settings, set `after_change` in the [setting definition table](#settings).
* `player_settings.set_setting(name,key,value)`: Set the value of a setting for a player
  * `name`: Name or [`ObjectRef`][ObjectRef] of a player
  * `key`: The ID of the setting
  * `value`: The value to be set to the setting
  * Return boolean indicating success
    * `after_change` and `player_settings.register_on_settings_set` callbacks are called
  * If failed, the second returned value may be one of the following:
    * `PLAYER_NOT_EXIST`: The player's auth data does not exist
    * `KEY_NOT_EXIST`: The setting does not exist
    * `TYPE_CONVERT_FAILED`: The given value cannot be converted to the type specified in the setting definition
    * `NUMBER_TOO_SMALL` and `NUMBER_TOO_LARGE` (number only): The given value is below or higher than the required range set in the setting definition
    * `SETTING_ENUM_TYPE_INVALID` (enum only): The type of enum values set in the settings is invalid
    * `SETTING_VALUE_NOT_IN_ENUM` (enum only): The given value is not in the list of allowed options set in the setting definition
    * `SETTING_TYPE_INVALID`: The type of the setting specified in the definition is invalid
* `player_settings.set_default(name,key)`: Set the value of a settings back to its default for a player
  * `name`: Name or [`ObjectRef`][ObjectRef] of a player
  * `key`: The ID of the setting
  * Return boolean indicating success
    * `after_change` and `player_settings.register_on_settings_set` callbacks are called
  * If failed, the second returned value may be one of the following:
    * `PLAYER_NOT_EXIST`: The player's auth data does not exist
    * `KEY_NOT_EXIST`: The setting does not exist
* `player_settings.get_setting(name,key)`: Get the value of a setting from a player
  * `name`: Name or [`ObjectRef`][ObjectRef] of a player
  * `key`: The ID of the setting
  * Return boolean indicating success
  * If success, the second returned value is the setting value
  * If failed, the second returned value may be one of the following:
    * `PLAYER_NOT_EXIST`: The player's auth data does not exist
    * `KEY_NOT_EXIST`: The setting does not exist

#### Internal

These functions are for internal uses. Avoid using them in your code.

* `player_settings.get_settings_path(name)`: Get the file path of the setting file of a player
  * `name`: Name of the player
* `player_settings.get_settings(name)`: Get the table of settings of a player
  * `name`: Name or [`ObjectRef`][ObjectRef] of a player
* `player_settings.write_settings(name,tb)`: Write a setting table to  the setting file of a player
  * `name`: Name or [`ObjectRef`][ObjectRef] of a player
  * `tb`: Key-value pair of player settings
* `player_settings.erase_settings(name)`: Erase all the settings of a player
  * **WARNING: This is irreversable!**
  * `name`: Name or [`ObjectRef`][ObjectRef] of a player
* `player_settings.save_all_settings()`: Save all in-cache changes to settings

### Constants

These are the read-only variables.

* `player_settings.registered_metacategories`: All registered metacategories
  * Key: The ID of the metacategory
  * Value: The [meta category definition table](#metacategories)
* `player_settings.registered_categories`: All registered categories
  * Key: The ID of the category
  * Value: The [category definition table](#categories)
* `player_settings.registered_settings`: All registered settings
  * Key: The ID of the setting
  * Value: The [setting definition table](#settings)
* `player_settings.gui`: A [flow](https://gitlab.com/luk3yx/minetest-flow/) GUI object
  * Refer to [the `README.md` of flow mod](https://gitlab.com/luk3yx/minetest-flow/-/blob/main/README.md) for further documentations

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

    display_type = "string" / "enum" / "bool",
    -- How the setting is displayed in the GUI.
    -- string: For all data types (default of int, float and string)
    -- enum: for enum only
    -- bool: for bool only

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

[ObjectRef]: https://github.com/minetest/minetest/blob/master/doc/lua_api.md#objectref
