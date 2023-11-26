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

minetest.register_on_chat_message(function(name, message)
    local player = minetest.get_player_by_name(name)
    if not player then return end

    local prefix = storage:get_string(name .. "_prefix") or ""
    local color = storage:get_string(name .. "_color") or "#FFFFFF"  -- Default color

    -- Check if the prefix is not restricted or if the player has admin privilege
    if prefix ~= "" and (not is_restricted_prefix(prefix) or minetest.check_player_privs(name, { custom_chat_prefix_admin = true })) then
        local full_message = "[" .. minetest.colorize(color, prefix) .. "] " .. name .. ": " .. message
        minetest.chat_send_all(full_message)
        return true  -- Prevents the default handler
    end

    -- Default chat behavior
    return false
end)

function handle_get_prefix(player_name)
    local prefix = storage:get_string(player_name .. "_prefix") or ""
    local color = storage:get_string(player_name .. "_color") or "#FFFFFF"

    if prefix ~= "" then
        return true, "Your prefix is " .. minetest.colorize(color, prefix)
    else
        return true, "You don't have a custom prefix."
    end
end

function handle_set_prefix(name, args)
    if not minetest.check_player_privs(name, {custom_chat_prefix = true}) then
        return false, "You don't have the privilege to set a prefix."
    end

    local prefix = args[2]
    local color = args[3] or "#FFFFFF"
    local target_name = args[4] or name

    if target_name ~= name and not minetest.check_player_privs(name, {custom_chat_prefix_admin = true}) then
        return false, "You don't have the privilege to set a prefix for others."
    end

    if is_restricted_prefix(prefix) and not minetest.check_player_privs(name, { custom_chat_prefix_admin = true }) then
        return false, "You cannot use a restricted prefix."
    end

    storage:set_string(target_name .. "_prefix", prefix)
    storage:set_string(target_name .. "_color", color)

    return true, "Prefix set successfully for " .. target_name
end



minetest.register_chatcommand("prefix", {
    params = "get <player_name> | set <prefix> [color] [player]",
    description = "Get or set chat prefixes",
    func = function(name, param)
        local args = param:split(" ")
        local subcommand = args[1]

        if subcommand == "get" then
            return handle_get_prefix(name)
        elseif subcommand == "set" then
            return handle_set_prefix(name, args)
        else
            return false, "Invalid subcommand. Use 'get' or 'set'."
        end
    end
})

