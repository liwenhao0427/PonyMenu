---@meta _
-- grabbing our dependencies,
-- these funky (---@) comments are just there
--	 to help VS Code find the definitions of things

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'SGG_Modding-ENVY-auto'
mods['SGG_Modding-ENVY'].auto()
-- ^ this gives us `public` and `import`, among others
--	and makes all globals we define private to this plugin.
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

-- get definitions for the game's globals
---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
config = chalk.auto 'config.lua'
-- ^ this updates our `.cfg` file in the config folder!
public.config = config -- so other mods can access our config

---@module 'game.import'
import_as_fallback(rom.game)

local function on_ready()
	-- what to do when we are ready, but not re-do on reload.
	if config.Enabled == false then return end
	PonyMenu_do_imports()
	import 'ready.lua'
	import 'Text/en.lua'
	import 'Text/fr.lua'
	import 'Text/zhCN.lua'
	import 'Text/zhTW.lua'
	import 'Text/ptBR.lua'
	import 'Data/ResourceData.lua'
	import 'Data/ScreenData.lua'
	import 'Scripts/MenuScripts.lua'
end

local function on_reload()
	-- what to do when we are ready, but also again on every reload.
	-- only do things that are safe to run over and over.
	if config.Enabled == false then return end
	import 'reload.lua'
end

-- this allows us to limit certain functions to not be reloaded.
local loader = reload.auto_single()

-- this runs only when modutil and the game's lua is ready
modutil.once_loaded.game(function()
	loader.load(on_ready, on_reload)
end)

function PonyMenu_do_imports()
	if config.enabled == false then return end
	local GUIFile = rom.path.combine(rom.paths.Content, 'Game/Obstacles/GUI.sjson')

	local gui_order = {
		"Name", "InheritFrom", "DisplayInEditor", "Thing"
	}

	local gui_order_2 = {
		"EditorOutlineDrawBounds", "Graphic"
	}

	local newSubItem = sjson.to_object({
		EditorOutlineDrawBounds = false,
		Graphic = "PonyWarrior-PonyMenu\\Box_FullScreen"
	}, gui_order_2)

	local newItem = sjson.to_object({
		Name = "Box_FullScreen",
		InheritFrom = "1_BaseGUIObstacle",
		DisplayInEditor = false,
		Thing = newSubItem,
	}, gui_order)

	sjson.hook(GUIFile, function(data)
		table.insert(data.Obstacles, newItem)
	end)
end
