local _ps = player_settings
_ps.util = {}

_ps.util.idx_in_table = function(tb,v)
    for i,tv in ipairs(tb) do
        if tv == v then return i end
    end
    return nil
end