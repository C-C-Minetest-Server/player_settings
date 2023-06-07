local WP = minetest.get_worldpath()
minetest.mkdir(WP .. "/player_settings/")

local _ps = player_settings
local s = {}
local s_nochg = {}

local function RTN_TRUE() return true end

local function do_register()
	local tb = {}
	local function reg_func(name, def)
		if not def.allow_show then
			def.allow_show = RTN_TRUE
		end
		def.name = name
		tb[name] = def
	end
	local function unreg_func(name)
		tb[name] = nil
	end
	return tb, reg_func, unreg_func
end

_ps.registered_metacategories, _ps.register_metacategory, _ps.unregister_metacategory = do_register()
_ps.registered_categories, _ps.register_category, _ps.unregister_category = do_register()
_ps.registered_settings, _ps.register_setting, _ps.unregister_setting = do_register()

_ps.registered_on_settings_set = {}
_ps.register_on_settings_set = function(func)
	table.insert(_ps.registered_on_settings_set,func)
end

_ps.get_settings_path = function(name)
	return (WP .. "/player_settings/" .. name .. ".conf.lua")
end

_ps.get_settings = function(name)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	local fp = _ps.get_settings_path(name)
	local f = io.open(fp, "r")
	if not f then return {} end
	local contents = f:read("*a")
	return minetest.deserialize(contents,true)
end

_ps.write_settings = function(name, tb)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	if not minetest.player_exists(name) then
		return false, "PLAYER_NOT_EXIST"
	end
	minetest.safe_file_write(_ps.get_settings_path(name), minetest.serialize(tb))
	return true
end

_ps.set_setting = function(name,key,value)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	if not minetest.player_exists(name) then
		return false, "PLAYER_NOT_EXIST"
	end
	local setting_entry = _ps.registered_settings[key]
	if not setting_entry then
		return false, "KEY_NOT_EXIST"
	end
	if not s[name] then
		s[name] = _ps.get_settings(name)
		s_nochg[name] = 0
	end
	-- type = "int" / "string" / "bool" / "float" / "enum",
	if setting_entry.type == "int" or setting_entry.type == "float" then
		value = tonumber(value)
		if not value then
			return false, "TYPE_CONVERT_FAILED"
		end
		if setting_entry.type == "int" then
			value = math.floor(value + 0.5)
		end
		if setting_entry.number_min and setting_entry.number_min > value then
			return false, "NUMBER_TOO_SMALL"
		elseif setting_entry.number_max and setting_entry.number_max < value then
			return false, "NUMBER_TOO_LARGE"
		end

	elseif setting_entry.type == "string" then
		value = tostring(value)
	elseif setting_entry.type == "enum" then
		-- enum_type = "int" / "string" / "float",
		if setting_entry.enum_type == "int" or setting_entry.enum_type == "float" then
			value = tonumber(value)
			if not value then
				return false, "TYPE_CONVERT_FAILED"
			end
			if setting_entry.enum_type == "int" then
				value = math.floor(value + 0.5)
			end
		elseif setting_entry.enum_type == "string" then
			value = tostring(value)
		else
			return false, "SETTING_ENUM_TYPE_INVALID"
		end
		if not (function()
			for _,y in ipairs(setting_entry.enum_choices) do
				if value == y then return true end
			end
			return false
		end)() then
			return false, "SETTING_VALUE_NOT_IN_ENUM"
		end
	elseif setting_entry.type == "bool" then
		if value == true or value == "true" or (tonumber(value) or 0) > 0 then
			value = true
		else
			value = false
		end
	else
		return false, "SETTING_TYPE_INVALID"
	end
	-- validator = function(name, key, value)
	if setting_entry.validator then
		local status, errmsg = setting_entry.validator(name, key, value)
		if not status then
			return false, (errmsg or "VALIDATION_FAILED")
		end
	end
	minetest.log("action", string.format(
		"[player_settings] %s set setting %s to %s",
		name, key, value
	))
	local old_value = s[name][key]
	if setting_entry.default and setting_entry.default == value then
		value = nil -- to save disk space
	end
	s[name][key] = value
	s_nochg[name] = nil
	-- after_change = function(name, key, old_value, new_value) end,
	if setting_entry.after_change then
		setting_entry.after_change(name, key, old_value, value or setting_entry.default)
	end
	for _,func in ipairs(_ps.registered_on_settings_set) do
		func(name, key, old_value, value or setting_entry.default)
	end
	return true
end

_ps.set_default = function(name,key)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	if not minetest.player_exists(name) then
		return false, "PLAYER_NOT_EXIST"
	end
	local setting_entry = _ps.registered_settings[key]
	if not setting_entry then
		return false, "KEY_NOT_EXIST"
	end
	if not s[name] then
		s[name] = _ps.get_settings(name)
		s_nochg[name] = 0
	end
	local old_value = s[name][key]
	minetest.log("action", string.format(
		"[player_settings] %s set setting %s to default",
		name, key
	))
	if setting_entry.after_change then
		setting_entry.after_change(name, key, old_value, setting_entry.default)
	end
	for _,func in ipairs(_ps.registered_on_settings_set) do
		func(name, key, old_value, setting_entry.default)
	end
	s[name][key] = nil
	s_nochg[name] = nil
end

_ps.get_setting = function(name,key)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	if not minetest.player_exists(name) then
		return false, "PLAYER_NOT_EXIST"
	end
	local setting_entry = _ps.registered_settings[key]
	if not setting_entry then
		return false, "KEY_NOT_EXIST"
	end
	if not s[name] then
		s[name] = _ps.get_settings(name)
		s_nochg[name] = 0
	end
	local value = s[name][key]
	if value == nil then
		value = setting_entry.default
	end
	return true, value
end

_ps.erase_settings = function(name)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	minetest.log("action", string.format(
		"[player_settings] Erasing %s's data",
		name
	))
	s[name] = nil
	s_nochg[name] = nil
	os.remove(_ps.get_settings_path(name))
end

_ps.save_all_settings = function()
	for k,v in pairs(s) do
		if not s_nochg[k] then
			minetest.log("action", string.format(
				"[player_settings] Writing %s's data",
				k
			))
			_ps.write_settings(k, v)
			s_nochg[k] = 1
		else
			if s_nochg[k] > 2 then
				minetest.log("action", string.format(
					"[player_settings] %s's data has been idle for 120 seconds. Removing from cache.",
					k
				))
				s[k] = nil -- Free memory
				s_nochg[k] = nil
			else
				minetest.log("action", string.format(
					"[player_settings] %s's data has not been edited. Skipped.",
					k
				))
				s_nochg[k] = s_nochg[k] + 1
			end
		end
	end
end

local after_loop = function()
	_ps.save_all_settings()
	minetest.after(60,_ps.save_all_settings)
end

minetest.after(5, after_loop)
minetest.register_on_shutdown(_ps.save_all_settings)

do
	local old_remove_player = minetest.remove_player
	function minetest.remove_player(name)
		local success = old_remove_player(name)
		if success == 0 then
			_ps.erase_settings(name)
		end
		return success
	end
end
