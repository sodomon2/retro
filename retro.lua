local lgi     = require 'lgi'
local Gtk     = lgi.require('Gtk', '3.0')
local Retro   = lgi.Retro

local builder = Gtk.Builder()
local ui      = builder.objects
local view    = Retro.CoreView()
builder:add_from_file('retro.ui')

local rom, core = nil, nil
local function uriname(uri)
    local t = {}
    for str in string.gmatch(uri, "([^/]+)") do
            table.insert(t, str)
    end
    return t[#t]
end

local function get_cores()
    local libretro = arg[1] or '$HOME/.config/retroarch/cores'
    for item in io.popen(('ls %s/*_libretro.so'):format(libretro)):lines() do
        ui.core_select:append(
	        item,
	        item:match("^.+/(.+)$")
        )
        print(item:match("^.+/(.+)$"))
    end
end
get_cores()

function ui.core_select:on_changed()
    core = Retro.Core.new(self:get_active_id())
    view:set_core(core)
    view:set_as_default_controller(core)
    ui.btn_load_rom.sensitive = true
    print(self:get_active_id())
end

if rom == nil then ui.btn_stop_rom.sensitive = false end
if ui.core_select:get_active_id() == nil then ui.btn_load_rom.sensitive = false end

function ui.btn_load_rom.on_clicked()
  ui.load_rom_dialog:run()
  ui.load_rom_dialog:hide()
end

function ui.btn_stop_rom.on_clicked()
  core:stop()
  ui.btn_stop_rom.sensitive = false
  ui.headerbar.subtitle = "LibRetro frontend sample"
  ui.btn_load_rom.sensitive = true
end

function ui.btn_rom_load.on_clicked()
  rom = ui.load_rom_dialog:get_filename(chooser)
  core:set_medias({"file://" .. rom})
  core:boot()
  core:run()
  ui.headerbar.subtitle = uriname(rom)
  ui.btn_stop_rom.sensitive = true
  ui.btn_load_rom.sensitive = false
  ui.load_rom_dialog:hide()
end

function ui.window.on_destroy()
  Gtk.main_quit()
end

ui.window:show_all(ui.window:add(view))
Gtk.main()
