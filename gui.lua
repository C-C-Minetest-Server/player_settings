local gui = flow.widgets
local _ps = player_settings
local S = minetest.get_translator("player_settings")

_ps.gui = flow.make_gui(function(player,ctx)
    ctx.name = player:get_player_name()
    if not ctx.showinfo then ctx.showinfo = {} end
    if not ctx.navbarData then
        local settings_by_category = {}
        for k,v in pairs(_ps.registered_settings) do
            if v.allow_show(ctx.name) then
                if not settings_by_category[v.category] then
                    settings_by_category[v.category] = {}
                end
                settings_by_category[v.category][k] = v
            end
        end
        local categories_by_metacat = {}
        for k,v in pairs(settings_by_category) do
            if not (_ps.registered_categories[k] and _ps.registered_categories[k].allow_show(ctx.name)) then
                settings_by_category[k] = nil
            end
            if not categories_by_metacat[_ps.registered_categories[k].metacategory] then
                categories_by_metacat[_ps.registered_categories[k].metacategory] = {}
            end
            categories_by_metacat[_ps.registered_categories[k].metacategory][k] = v
        end
        for k,v in pairs(categories_by_metacat) do
            if not (_ps.registered_metacategories[k] and _ps.registered_metacategories[k].allow_show(ctx.name)) then
                categories_by_metacat[k] = nil
            end
        end
        ctx.navbarData = categories_by_metacat
    end
    local navbar = {}
    for k,v in pairs(ctx.navbarData) do
        table.insert(navbar,gui.Label{ label = _ps.registered_metacategories[k].title })
        for k2,v2 in pairs(v) do
            table.insert(navbar,gui.Button {
                label = _ps.registered_categories[k2].title, 
                w = 1, expand = true,
                ---@diagnostic disable-next-line: redefined-local, unused-local
                on_event = function(player,ctx)
                    if ctx.current_category == k2 then return end
                    ctx.current_metacat = k
                    ctx.current_category = k2
                    return true
                end,
            })
        end
    end
    navbar.w = 4; navbar.h = 10;
    navbar.name = "shbox"

    local settings_screen
    if not ctx.current_category then
        settings_screen = gui.Label {
            w = 10, h = 10,
            label = S("Select a category on the left."),
            expand = true, align_h = "centre", align_w = "centre",
        }
    else
        local list_settings = ctx.navbarData[ctx.current_metacat][ctx.current_category]
        local svbox = {}
        for k,v in pairs(list_settings) do
            local desc = S("@1 (@2)",v.description,_ps.util.types[v.type] or v.type)
            if v.type == "enum" then
                desc = S("@1 (Multiple-choice of @2)",
                    v.description,
                    _ps.util.types[v.enum_type] or v.enum_type)
            end

            local display_type = v.display_type
            if display_type == "enum" and v.type ~= "enum" or 
                display_type == "bool" and v.type ~= "bool" then
                display_type = nil
            end

            -- TODO: Add support to scrollbar for numbers (waiting for flow mod support)
            if not display_type then
                if v.type == "bool" then
                    display_type = "bool"
                elseif v.type == "enum" then
                    display_type = "enum"
                else
                    display_type = "string"
                end
            end
            

            local s_status, selected = _ps.get_setting(ctx.name,k)
            if not s_status then
                ctx.errmsg = {k, S("Failed to get setting of @1: @2",
                    k, _ps.util.errmsgs[selected] or selected
                )}
            elseif display_type == "bool" then
                table.insert(svbox, gui.HBox {
                    gui.Checkbox {
                        w = 5,h=1,
                        name = "settings_" .. k,
                        label = desc,
                        selected = selected,
                        on_event = function(player,ctx)
                            ctx.errmsg = nil
                            local form = ctx.form
                            if type(form["settings_" .. k]) == "boolean" then
                                local status, errmsg =_ps.set_setting(ctx.name,k,form["settings_" .. k])
                                if not status then
                                    ctx.errmsg = {k,errmsg}
                                    form["settings_" .. k] = _ps.get_setting(ctx.name,k)
                                end
                                return true
                            end
                        end,
                        expand = true, align_h = "left",
                    },
                    gui.ImageButton {
                        w = 1, h = 1,
                        texture_name = "settings_reset.png",
                        name = "settingsReset_" .. k,
                        ---@diagnostic disable-next-line: redefined-local, unused-local
                        on_event = function(player,ctx)
                            ctx.errmsg = nil
                            local form = ctx.form
                            _ps.set_default(ctx.name,k)
                            form["settings_" .. k] = v.default
                            return true
                        end,
                        drawborder = false,
                    },
                    gui.ImageButton {
                        w = 1, h = 1,
                        texture_name = "settings_info.png",
                        name = "settingsInfo_" .. k,
                        ---@diagnostic disable-next-line: redefined-local, unused-local
                        on_event = function(player,ctx)
                            ctx.showinfo[k] = not ctx.showinfo[k]
                            return true
                        end,
                        drawborder = false,
                    }
                })
            elseif display_type == "enum" then
                table.insert(svbox, gui.Label {
                    label = desc
                })
                table.insert(svbox, gui.HBox {
                    gui.Dropdown {
                        w = 3,h=1,
                        name = "settings_" .. k,
                        items = v.enum_choices,
                        selected_idx = _ps.util.idx_in_table(v.enum_choices,selected),
                    },
                    gui.Button {
                        w = 2, h = 1,
                        name = "settingsSubmit_" .. k,
                        label = S("Set"),
                        ---@diagnostic disable-next-line: redefined-local, unused-local
                        on_event = function(player,ctx)
                            ctx.errmsg = nil
                            local form = ctx.form
                            print(form["settings_" .. k])
                            local status, errmsg =_ps.set_setting(ctx.name,k,form["settings_" .. k])
                            if not status then
                                ctx.errmsg = {k,errmsg}
                                form["settings_" .. k] = _ps.get_setting(ctx.name,k)
                            end
                            return true
                        end,
                        expand = true, align_h = "left",
                    },
                    gui.ImageButton {
                        w = 1, h = 1,
                        texture_name = "settings_reset.png",
                        name = "settingsReset_" .. k,
                        ---@diagnostic disable-next-line: redefined-local, unused-local
                        on_event = function(player,ctx)
                            ctx.errmsg = nil
                            local form = ctx.form
                            _ps.set_default(ctx.name,k)
                            form["settings_" .. k] = v.default
                            return true
                        end,
                        drawborder = false,
                    },
                    gui.ImageButton {
                        w = 1, h = 1,
                        texture_name = "settings_info.png",
                        name = "settingsInfo_" .. k,
                        ---@diagnostic disable-next-line: redefined-local, unused-local
                        on_event = function(player,ctx)
                            ctx.showinfo[k] = not ctx.showinfo[k]
                            return true
                        end,
                        drawborder = false,
                    }
                })
            elseif display_type == "string" then -- String-like
                table.insert(svbox, gui.Label {
                    label = desc
                })
                table.insert(svbox, gui.HBox {
                    gui.Field {
                        w = 3,h=1,
                        name = "settings_" .. k,
                        default = selected,
                    },
                    gui.Button {
                        w = 2,h=1,
                        name = "settingsSubmit_" .. k,
                        label = S("Set"),
                        ---@diagnostic disable-next-line: redefined-local, unused-local
                        on_event = function(player,ctx)
                            ctx.errmsg = nil
                            local form = ctx.form
                            local status, errmsg =_ps.set_setting(ctx.name,k,form["settings_" .. k])
                            if not status then
                                ctx.errmsg = {k,errmsg}
                                form["settings_" .. k] = _ps.get_setting(ctx.name,k)
                            end
                            return true
                        end,
                        expand = true, align_h = "left",
                    },
                    gui.ImageButton {
                        w = 1, h = 1,
                        texture_name = "settings_reset.png",
                        name = "settingsReset_" .. k,
                        ---@diagnostic disable-next-line: redefined-local, unused-local
                        on_event = function(player,ctx)
                            ctx.errmsg = nil
                            local form = ctx.form
                            _ps.set_default(ctx.name,k)
                            form["settings_" .. k] = v.default
                            return true
                        end,
                        drawborder = false,
                    },
                    gui.ImageButton {
                        w = 1, h = 1,
                        texture_name = "settings_info.png",
                        name = "settingsInfo_" .. k,
                        ---@diagnostic disable-next-line: redefined-local, unused-local
                        on_event = function(player,ctx)
                            ctx.showinfo[k] = not ctx.showinfo[k]
                            return true
                        end,
                        drawborder = false,
                    }
                })
            else
                error("[player_settings] Attempt to display setting with unknown display type " .. display_type)
            end
            if ctx.errmsg and ctx.errmsg[1] == k then
                local user_errmsg = _ps.util.errmsgs[ctx.errmsg[2]] or ctx.errmsg[2]
                table.insert(svbox, gui.Label {
                    label = minetest.colorize("#FF0000", S("Error: @1", user_errmsg)),
                    -- label = ctx.errmsg[2],
                })
            end
            if ctx.showinfo[k] and v.long_description then
                table.insert(svbox, gui.Label {
                    label = minetest.get_color_escape_sequence("#00FF00") .. v.long_description,
                })
            end
        end
        svbox.w = 10; svbox.h = 10;
        svbox.name = "svbox"
        settings_screen = gui.ScrollableVBox(svbox)
    end
    local rtn_gui = gui.VBox {
        gui.HBox {
            gui.Label { label = S("Settings"), expand = true, align_h = "left" },
            gui.ButtonExit { w = 0.7, h = 0.7, label = "x" }
        },
        gui.Box{w = 1, h = 0.05, color = "grey", padding = 0},
        gui.HBox {
            gui.ScrollableVBox(navbar),
            settings_screen
        }
    }
    return rtn_gui
end)

minetest.register_chatcommand("settings", {
    description = S("Open settings menu"),
    func = function(name,param)
        _ps.gui:show(minetest.get_player_by_name(name))
    end
})