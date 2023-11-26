minetest.register_privilege("custom_chat_prefix", {
    description = "Allows setting a custom chat prefix",
    give_to_singleplayer = false
})

minetest.register_privilege("custom_chat_prefix_admin", {
    description = "Allows setting prefixes for others and use restricted types",
    give_to_singleplayer = false
})

local restricted_prefixes = { "Mod", "Moderator", "Admin", "Owner" }

function is_restricted_prefix(prefix)
    local lower_prefix = string.lower(prefix)
    for _, r_prefix in ipairs(restricted_prefixes) do
        if lower_prefix == string.lower(r_prefix) then
            return true
        end
    end
    return false
end
