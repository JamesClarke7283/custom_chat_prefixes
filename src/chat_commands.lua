-- Handle 'get' subcommand
function handle_get_prefix(player_name)
    local prefix = storage:get_string(player_name .. "_prefix") or ""
    local color = storage:get_string(player_name .. "_color") or "#FFFFFF"

    if prefix ~= "" then
        return true, "Your prefix is " .. minetest.colorize(color, prefix)
    else
        return true, "You don't have a custom prefix."
    end
end

-- Handle 'set' and 'set_player' subcommands
function handle_set_prefix(name, args)
    if not minetest.check_player_privs(name, {custom_chat_prefix = true}) then
        return false, "You don't have the privilege to set a prefix."
    end

    local prefix, color, target_name

    if args[1] == "set_player" then
        if not minetest.check_player_privs(name, {custom_chat_prefix_admin = true}) then
            return false, "You don't have the privilege to set a prefix for others."
        end
        if #args < 4 then
            return false, "Usage: /prefix set_player <player_name> <prefix> [color]"
        end
        target_name = args[2]
        prefix = args[3]
        color = args[4] or "#FFFFFF"
    else
        if #args < 2 then
            return false, "Usage: /prefix set <prefix> [color]"
        end
        prefix = args[2]
        color = args[3] or "#FFFFFF"
        target_name = name
    end

    if is_restricted_prefix(prefix) and not minetest.check_player_privs(name, { custom_chat_prefix_admin = true }) then
        return false, "You cannot use a restricted prefix."
    end

    storage:set_string(target_name .. "_prefix", prefix)
    storage:set_string(target_name .. "_color", color)

    return true, "Prefix set successfully for " .. target_name
end

-- Handle 'clear' subcommand
function handle_clear_prefix(name, args)
    if not minetest.check_player_privs(name, {custom_chat_prefix = true}) then
        return false, "You don't have the privilege to clear a prefix."
    end

    local target_name = args[2] or name

    if target_name ~= name and not minetest.check_player_privs(name, {custom_chat_prefix_admin = true}) then
        return false, "You don't have the privilege to clear a prefix for others."
    end

    storage:set_string(target_name .. "_prefix", "")
    storage:set_string(target_name .. "_color", "#FFFFFF")

    return true, "Prefix cleared for " .. target_name
end

-- Registering the chat command
minetest.register_chatcommand("prefix", {
    params = "get | set <prefix> [color] | set_player <player_name> <prefix> [color] | clear | clear <player_name>",
    description = "Get, set, or clear chat prefixes",
    func = function(name, param)
        local args = param:split(" ")
        local subcommand = args[1]

        if subcommand == "get" then
            return handle_get_prefix(name)
        elseif subcommand == "set" or subcommand == "set_player" then
            return handle_set_prefix(name, args)
        elseif subcommand == "clear" then
            return handle_clear_prefix(name, args)
        else
            return false, "Invalid subcommand. Use 'get', 'set', 'set_player', or 'clear'."
        end
    end
})

-- Chat message handling
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
