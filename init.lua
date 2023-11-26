storage = minetest.get_mod_storage()
MODNAME="custom_chat_prefixes"
local modpath=minetest.get_modpath(MODNAME)
source_path = modpath.."/src"
dofile(source_path .. "/privs.lua")
dofile(source_path .. "/chat_commands.lua")