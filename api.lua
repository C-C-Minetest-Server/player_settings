local WP = minetest.get_worldpath()
minetest.mkdir(WP .. "/player_settings/")

local _ps = player_settings
local s = {}

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
	minetest.safe_file_write(_ps.get_settings_path(name), minetest.serialize(tb))
end

_ps.set_setting = function(name,key,value)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	local setting_entry = _ps.registered_settings[key]
	if not setting_entry then
		return false, "KEY_NOT_EXIST"
	end
	if not s[name] then
		s[name] = _ps.get_settings(name)
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
	s[name][key] = value
	return true
end

_ps.set_default = function(name,key)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	local setting_entry = _ps.registered_settings[key]
	if not setting_entry then
		return false, "KEY_NOT_EXIST"
	end
	if not s[name] then
		s[name] = _ps.get_settings(name)
	end
	s[name][key] = nil
end

_ps.get_setting = function(name,key)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	local setting_entry = _ps.registered_settings[key]
	if not setting_entry then
		return false, "KEY_NOT_EXIST"
	end
	if not s[name] then
		s[name] = _ps.get_settings(name)
	end
	local value = s[name][key]
	if value == nil then
		value = setting_entry.default
	end
	return value
end

_ps.save_all_settings = function()
	for k,v in pairs(s) do
		_ps.write_settings(k, v)
	end
end

local after_loop = function()
	_ps.save_all_settings()
	minetest.after(60,_ps.save_all_settings)
end

minetest.after(5, after_loop)
minetest.register_on_shutdown(_ps.save_all_settings)
