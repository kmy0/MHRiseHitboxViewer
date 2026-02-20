local config = require("HitboxViewer.config.init")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local util_imgui = require("HitboxViewer.util.imgui.init")

local this = {}

function this.draw()
    imgui.spacing()
    imgui.indent(2)
    imgui.push_item_width(gui_util.get_item_width())

    set:slider_int(
        gui_util.tr("menu.draw_settings.slider_draw_distance"),
        "mod.draw.distance",
        0,
        10000
    )
    set:checkbox(gui_util.tr("menu.draw_settings.box_outline"), "mod.draw.outline")

    imgui.begin_disabled(not config:get("mod.draw.outline"))
    set:color_edit(gui_util.tr("menu.draw_settings.color_outline"), "mod.draw.outline_color")
    imgui.end_disabled()
    set:color_edit(
        gui_util.tr("menu.draw_settings.color_highlight"),
        "mod.hurtboxes.color.highlight"
    )

    util_imgui.separator_text(config.lang:tr("menu.draw_settings.category_trail"))
    set:checkbox(gui_util.tr("menu.draw_settings.box_fade"), "mod.trailboxes.fade")
    util_imgui.tooltip(config.lang:tr("menu.draw_settings.tooltip_box_fade"), true)
    set:checkbox(gui_util.tr("menu.draw_settings.box_outline", "trail"), "mod.trailboxes.outline")

    set:slider_float(
        "##menu.draw_settings.slider_step",
        "mod.trailboxes.step",
        0.001,
        config.max_trail_dur,
        string.format(
            "%s %s",
            config.lang:tr("menu.draw_settings.slider_step"),
            gui_util.seconds_to_minutes_string(config.current.mod.trailboxes.step, "%.3f")
        )
    )
    set:slider_float(
        gui_util.tr("menu.draw_settings.slider_draw_dur", "trailboxes"),
        "mod.trailboxes.draw_dur",
        0.001,
        config.max_trail_dur,
        gui_util.seconds_to_minutes_string(config.current.mod.trailboxes.draw_dur, "%.3f")
    )

    imgui.pop_item_width()
    imgui.unindent(2)
    imgui.spacing()
end

return this
