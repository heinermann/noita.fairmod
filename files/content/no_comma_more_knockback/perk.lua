perk_list[#perk_list+1] = {
    id = "NO_COMMA_MORE_KNOCKBACK",
    ui_name = "$perk_no_comma_more_knockback",
    ui_description = "$perkdesc_no_comma_more_knockback",
    ui_icon = "mods/noita.fairmod/files/content/no_comma_more_knockback/ui_gfx.png",
    perk_icon = "mods/noita.fairmod/files/content/no_comma_more_knockback/perk_icon.png",
    stackable = false,
    func = function(entity_perk_item, entity_who_picked, item_name)
        local amt = tonumber(GlobalsGetValue("PERK_NO_COMMA_MORE_KNOCKBACK_AMT", "0"))
        GlobalsSetValue("PERK_NO_COMMA_MORE_KNOCKBACK_AMT", tostring(amt + 1))

        --local comp = EntityAddComponent2(entity_who_picked, "LuaComponent", {
        --    execute_every_n_frame = -1,
        --    script_damage_received = "mods/noita.fairmod/files/content/no_comma_more_knockback/recv_dmg_random_knock.lua",
        --})
        --ComponentAddTag(comp, "fairmod_dmg_knock")
    end,
    func_remove = function(entity_perk_item, entity_who_picked, item_name)
        local amt = tonumber(GlobalsGetValue("PERK_NO_COMMA_MORE_KNOCKBACK_AMT", "0"))
        if amt > 0 then
            GlobalsSetValue("PERK_NO_COMMA_MORE_KNOCKBACK_AMT", tostring(amt - 1))
        end

        --local comp = EntityGetFirstComponentIncludingDisabled(entity_who_picked, "LuaComponent", "fairmod_dmg_knock")
        --if comp ~= nil then
        --    EntityRemoveComponent(entity_who_picked, comp)
        --end
    end,
}
