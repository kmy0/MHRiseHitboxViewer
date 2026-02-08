local attack_log = require("HitboxViewer.gui.attack_log")
local box = require("HitboxViewer.box.init")
local char = require("HitboxViewer.character.init")
local config = require("HitboxViewer.config.init")
local config_menu = require("HitboxViewer.gui.init")
local data = require("HitboxViewer.data.init")
local draw_queue = require("HitboxViewer.draw_queue")
local hurtbox_info = require("HitboxViewer.gui.hurtbox_info")
local update = require("HitboxViewer.update")
local util_imgui = require("HitboxViewer.util.imgui.init")
local util_misc = require("HitboxViewer.util.misc.init")
local logger = util_misc.logger.g

---@class MethodUtil
local m = require("HitboxViewer.util.ref.methods")
local init = util_misc.init_chain:new(
    "MAIN",
    data.init,
    config.init,
    box.hurtbox.conditions.init,
    config_menu.init,
    data.mod.init
)
init.max_retries = 999

hb_draw.register(function()
    draw_queue:draw()
end)

m.hook("snow.CharacterBase.start()", char.hook.get_base_pre)
m.hook(
    "snow.hit.AttackWork.initialize(System.Single, System.Single, System.UInt32, System.UInt32, System.Int32, snow.hit.userdata.BaseHitAttackRSData)",
    box.hitbox.hook.get_attack_pre
)

if
    config.current.mod.enabled_hurtboxes
    or config.current.mod.enabled_pressboxes and update.is_quest()
then
    char.create_all_chars()
end

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.commit)) and init.ok then
        local gui_main = config.gui.current.gui.main
        gui_main.is_opened = not gui_main.is_opened
    end

    if not init.failed then
        local errors = logger:format_errors()
        if errors then
            imgui.same_line()
            imgui.text_colored("Error!", data.gui.colors.bad)
            util_imgui.tooltip_exclamation(errors)
        elseif not init.ok then
            imgui.same_line()
            imgui.text_colored("Initializing...", data.gui.colors.info)
        end
    else
        imgui.same_line()
        imgui.text_colored("Init failed!", data.gui.colors.bad)
    end
end)

re.on_application_entry("EndPhysics", function()
    if not init.ok then
        return
    end

    if update.is_quest() then
        update.characters()
        update.queues()
    else
        update.clear()
    end
end)

re.on_frame(function()
    if not init:init() then
        return
    end

    local config_gui = config.gui.current.gui

    if not reframework:is_drawing_ui() then
        config_gui.main.is_opened = false
        config_gui.attack_log.is_opened = false
        config_gui.hurtbox_info.is_opened = false
    end

    if config_gui.main.is_opened then
        config_menu.draw()
    end

    if config_gui.attack_log.is_opened then
        attack_log.draw()
    end

    if config_gui.hurtbox_info.is_opened then
        hurtbox_info.draw()
    end

    config.run_save()
end)

re.on_config_save(function()
    if data.mod.initialized then
        config.save_no_timer_global()
    end
end)
