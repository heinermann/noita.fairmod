dofile_once( "data/scripts/lib/coroutines.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )
local limbs = dofile_once("mods/noita.fairmod/files/content/kolmi_arena_statues/entities/limb_controller.lua")

-- TODO

-- 1. Lock legs into position
-- 2. Kick anything back when it comes near

-- Sentry
async_loop(function()

	-- Logic to trigger activation and reactions to teleport bolt and player that comes near
	-- Kick those things back into the collapsing mountain

	wait(0)
end)
