local S = minetest.get_translator("player_settings")
local _ps = player_settings
_ps.util = {}

_ps.util.idx_in_table = function(tb,v)
    for i,tv in ipairs(tb) do
        if tv == v then return i end
    end
    return nil
end

_ps.util.errmsgs = {
    PLAYER_NOT_EXIST = S("Player does not exist"),
    KEY_NOT_EXIST = S("Key does not exist"),
    TYPE_CONVERT_FAILED = S("Value not matching the data type"),
    SETTING_ENUM_TYPE_INVALID = S("Invalid enum data type"),
    SETTING_VALUE_NOT_IN_ENUM = S("Value not in list of choices"),
    SETTING_TYPE_INVALID = S("Invalid setting data type"),
    VALIDATION_FAILED = S("Validation failed"),
    NUMBER_TOO_SMALL = S("Number too small"),
    NUMBER_TOO_LARGE = S("Number too large"),
}

-- type = "int" / "string" / "bool" / "float" / "enum"
_ps.util.types = {
    int = S("Integer"),
    string = S("String"),
    bool = S("Boolean"),
    float = S("Float"),
    enum = S("Multiple-choice")
}