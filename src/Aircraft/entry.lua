--- The unique identifiable descriptor of the mod.
-- This may appear in places such as your in-game module settings.
local self_ID = "Aircraft abbreviation and name by Developer" -- e.g. "TF-51D Mustang by Eagle Dynamics"
local _displayName = "Aircraft name" -- e.g. "TF-51D Mustang"
local _fileMenuName = "Aircraft abbreviation" -- e.g. "TF-51D"
local _description = "A brief and theatrical introduction to the aircraft's historical background; and usage in today's militaries."
local _binaries = {} -- Please refer to the docstring comments in the declare_plugin() method.

--- Instantiates the plugin into DCS during runtime as a mod.
--[[
	id: the ID of the plugin to identify it with. This is usually the naming convention, and ideally
		anything unique enough so that it avoids confusion internally.
	metatable {}: the metatable contents relating to the plugin. This is a tabular structure with
		numerous keywords that DCS rely on for determing aspects.
]]
-- This is dumb, but because of the way Lua compiles (DCS does not use LuaJIT) it is computationally faster
-- to read strings through '' quotation and not "" because bytes are not scalar and are read differently.
declare_plugin(self_ID, {
	--- Whether the mod can be actively used in-game or not.
	-- If set to true, it is -- "false" represents an advertising-like view where the UI presents you to buy it.
	installed = true,

	--- The current name of your directory path.
	-- Keep this as the current_mod_path constant, which reads an absolute path to the mod directory.
	dirName = current_mod_path,

	--- The name to display as for the encyclopedia and missions.
	-- This is dundered so that it has an easy rep. state.
	displayName = _(_displayName),

	--- The name to show in your "file menu," where all of the modules show inline to one another.
	-- This is your main menu name.
	fileMenuName = _(_fileMenuName),

	--- The version of the mod. By nature, this is set to a magic constant for DCS' internal version.
	-- You may additionally supply a string type for what's used here.
	version = __DCS_VERSION__,

	--- The current state of the mod. From investigation, this seems to be deprecated although still used.
	-- This is the same extent of meaning as the "installed" keyword.
	state = 'installed',

	--- Information pertaining to the mod. Represents as what you'd consider the "description." 
	-- This information is only shown when the icon is right-clicked in the main menu.
	info = _(_description),
	
	--- The binaries of the mod.
	--[[
		A binary in DCS is what represents the internal schematic of systems code and the flight model, if present.
		Binaries are in a .DLL sharable library format. It is suggested that most 3rd parties and ED themselves
		use C++ for their source to target as binary during compilation. However, you can really use any other
		language that provides LLVM compatibility to a .DLL target.

		From investigation, it seems that it is possible to establish a .NET-based platform as a binary, or any
		programming language that supports building this through a Clang-like LLVM. Such languages include Zig,
		Rust, C#, Java, Python, GHC from Haskell, Vala, Genie, Go and Ruby.

		Binaries allow developers the ability to easily hook into OS/2 system events and EDGE engine events during
		runtime, opening the possibility to develop things such as radars, guided munitions and etc.
	]]--
	binaries = _binaries,

	--- The input profiles for a mod.
	-- These are your controller maps. The metatable is a K:V relation between its dirname and relative path.
	InputProfiles =
	{
		[_fileMenuName] = current_mod_path .. '/Input/' .. _fileMenuName,
	},

	--- The representable liveries of the mod.
	-- The metatable is a nested K:V relation for the naming supplied and constituted by fileMenuName
	-- and its directory. Note that the directory is relative and does not require an absolute supplement.
	Skins	=
	{
		{
			name = _(_fileMenuName),
			dir = 'Skins/1'
		},
	},

	--- The representable missions of the mod.
	-- The metatable is a K:V relation for the naming supplied and constitued by fileMenuName
	-- and its directory. Note that the directory is relative and does not require an absolute supplement.
	Missions =
	{
		{
			name = _(_fileMenuName),
			dir = 'Missions',	
		},
	},

	--- The representable options of the mod.
	--[[
		The metatable is a K:V relation for the naming supplied and constitued by fileMenuName
		and its directory. Note that the directory is relative and does not require an absolute supplement.

		Additionally, the options are declared as a "cdata" metatable. This is an abbreviation for C-based
		data that may be inferred upon by your binaries. See "binaries" for more information. 
	]]--
	Options = 
	{
		{
			name = _(_fileMenuName),
			nameId = _fileMenuName,
			dir = 'Options',
		},
	},
	
	--- The representable log book of the mod.
	-- The metatable is a K:V relation for the naming supplied and constitued by fileMenuName
	-- and its mod. Note that the directory is relative and does not require an absolute supplement.
	LogBook =
	{
		{
			name		= _(_fileMenuName),
			type		= _fileMenuName,
		},
	},

	--- The preloaded contents of a mod.
	--[[
		The metatable is a K:V relation between what component type is responsible , and then a nested
		metatable storing string types of their type respectively.

		textures: the texture paths, usually kept separate as a "Textures" folder.
		models: the model paths, where the Eagle Dynamics Model (.EDM) file is the name without the appended suffix.
			The models can be loaded in any fashion determined by the EGDE engine. These models also use builtin
			core naming conventions to determine their purpose.

			"sled" - the name given for an LOD3+ rendered model.
		fonts: the font paths, where the liveries may use a custom font for aircraft numbering.
			The fonts path can also be used for custom fonts with the cockpit and systems, however, this is usually
			done instead in the "Cockpit" folder and kept separate. Nothing is stopping developers from using either.
		explosions: the explosion paths.
			Not much is understood on this, but it's believed that explosions are specific .lua or .fx files that help
			with rendering explosion effects. This metatable presumably takes string types for their file names in 
			the same concatonive manner as the "models" keyword.
	]]
	preload_resources = 
	{
		textures   = {},
		models     = {'sled',},
		fonts      = {},
		explosions = {},
	},
})

--- "Mounts" the liveries and hooks the directory to its representable liveries path.
mount_vfs_liveries_path(current_mod_path .. '/Liveries')

--- "Mounts" the model shapes and hooks the directory to its representable shapes path.
mount_vfs_model_path   (current_mod_path .. '/Shapes')

--- "Mounts" the textures of the mod and hooks the directory to its representable skins path.
--[[
	This is used for two purposes:

	1.	To connect the "ME" or Mission Editor imagery to the mod instance during runtime to
		show up for the main menu, as well as any artwork.
	2.	To show any additional imagery files when using parts like Rearm & Refuel in-game.
]]--
mount_vfs_texture_path (current_mod_path .. '/Skins/1/ME')

--- Please note for make_flyable() that the inner metatable payload has the ID related to the "primary" binary.
-- Lua treates index references of a table as n + 1 and onwards..
-- Keep your primary binary as the first one in your metatable.
-- make_flyable(_fileMenuName, current_mod_path .. '/Cockpit/Scripts/', {self_ID, _binaries[1],}, current_mod_path .. '/comm.lua')

-- If we're not working with a binary, we can supply a nullable or "nil" value.
make_flyable(_fileMenuName, current_mod_path .. '/Cockpit/Scripts/', {self_ID, nil,}, current_mod_path .. '/comm.lua')

--- Sets the path of the given mod to any documentation pertaining to it. This is what we'd consider as the "flight manual."
set_manual_path(_fileMenuName, current_mod_path .. '/Doc/manual')

--- "dofile()" is essentially our Lua runner call. This always takes an absolute path and helps us declare the mod.
dofile(current_mod_path .. '/' .. _fileMenuName .. '.lua')

-- Lua has no proper object orientation pattern for how we're using metatables. Because of this, "plugin_done()"
-- becomes now our stopper method to finish any declarative calls.
plugin_done()
