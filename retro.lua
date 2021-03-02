local lgi     = require 'lgi'
local Gtk     = lgi.require('Gtk', '3.0')
local Retro   = lgi.Retro

local builder = Gtk.Builder()
local ui      = builder.objects
builder:add_from_file('retro.ui')

local rom, core = nil, nil

local function uriname(uri)
    local t = {}
    for str in string.gmatch(uri, "([^/]+)") do
            table.insert(t, str)
    end
    return t[#t]
end

local function sensitive(boolean)
  ui.btn_start_rom.sensitive = boolean
  ui.btn_stop_rom.sensitive = boolean
end

local function get_cores()
    local libretro = arg[1] or '$HOME/.config/retroarch/cores'
    ui.core_select:remove_all()
    for item in io.popen(('ls %s/*_libretro.so'):format(libretro)):lines() do
        ui.core_select:append(
	        item,
	        item:match("^.+/(.+)$")
        )
        print(item:match("^.+/(.+)$"))
    end
end
get_cores()

local view = Retro.CoreView()
function ui.core_select:on_changed()
    core = Retro.Core.new(self:get_active_id())
    view:set_core(core)
    view:set_as_default_controller(core)
    ui.btn_load_rom.sensitive = true
    print(self:get_active_id())
end
view:show(ui.window)

if rom == nil then sensitive(false) end
if ui.core_select:get_active_id() == nil then ui.btn_load_rom.sensitive = false end

function ui.btn_load_rom.on_clicked()
  ui.load_rom_dialog:run()
  ui.load_rom_dialog:hide()
end

function ui.btn_stop_rom.on_clicked()
  sensitive(false)
  core:stop(core)
  ui.headerbar.subtitle = "LibRetro frontend sample"
  ui.btn_load_rom.sensitive = true
end

function ui.btn_rom_load.on_clicked()
  rom = ui.load_rom_dialog:get_filename(chooser)
  core:set_medias({"file://" .. rom})
  sensitive(true)
  ui.load_rom_dialog:hide()
end

function ui.btn_start_rom.on_clicked()
  core:boot(core)
  core:run(core)
  ui.btn_load_rom.sensitive = false
  ui.headerbar.subtitle = uriname(rom)
end

function ui.window.on_destroy()
  Gtk.main_quit()
end

ui.window:show_all(ui.window:add(view))
Gtk.main()
