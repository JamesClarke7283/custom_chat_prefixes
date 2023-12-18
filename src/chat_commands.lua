-- Function to handle 'get' subcommand
function handle_get_prefix(name, args)
    local target_name = args[2] or name
    local prefix = storage:get_string(target_name .. "_prefix") or ""
    local color = storage:get_string(target_name .. "_color") or "#FFFFFF"

    if prefix ~= "" then
        return true, "Prefix for " .. target_name .. " is " .. minetest.colorize(color, prefix)
    else
        return true, "No custom prefix for " .. target_name
    end
end

-- Additional utility function for checking color code validity
local function is_valid_color(color)
    return color:match("^#%x%x%x%x%x%x$")
end

-- Function to handle 'set' and 'set_player' subcommands
function handle_set_prefix(name, args)
    if not minetest.check_player_privs(name, {custom_chat_prefix = true}) then
        return false, "You don't have the privilege to set a prefix."
    end

    local prefix, color, target_name

    if args[1] == "set_player" then
        if not minetest.check_player_privs(name, {custom_chat_prefix_admin = true}) then
            return false, "You don't have the privilege to set a prefix for others."
        end
        if #args < 4 or #args > 4 then
            return false, "Usage: /prefix set_player <player_name> <prefix> [color]"
        end
        target_name = args[2]
        prefix = args[3]
        color = args[4] or "#FFFFFF"
    else
        if #args < 2 or #args > 3 then
            return false, "Usage: /prefix set <prefix> [color]"
        end
        prefix = args[2]
        color = args[3] or "#FFFFFF"
        target_name = name
    end

    if color and not is_valid_color(color) then
        return false, "Invalid color code. Use hex format: #RRGGBB"
    end

    storage:set_string(target_name .. "_prefix", prefix)
    storage:set_string(target_name .. "_color", color)

    return true, "Prefix set successfully for " .. target_name
end

-- Function to handle 'clear' subcommand
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
    params = "get [<player_name>] | set <prefix> [color] | set_player <player_name> <prefix> [color] | clear | clear <player_name>",
    description = "Get, set, or clear chat prefixes",
    func = function(name, param)
        local args = param:split(" ")
        local subcommand = args[1]

        if subcommand == "get" then
            return handle_get_prefix(name, args)
        elseif subcommand == "set" or subcommand == "set_player" then
            return handle_set_prefix(name, args)
        elseif subcommand == "clear" then
            return handle_clear_prefix(name, args)
        else
            return false, "Invalid subcommand. Use 'get', 'set', 'set_player', or 'clear'."
        end
    end
})

-- Function to get formatted prefix for a player
local function get_formatted_prefix(player_name)
    local prefix = storage:get_string(player_name .. "_prefix") or ""
    local color = storage:get_string(player_name .. "_color") or "#FFFFFF"

    if prefix ~= "" and (not is_restricted_prefix(prefix) or minetest.check_player_privs(player_name, { custom_chat_prefix_admin = true })) then
        return "[" .. minetest.colorize(color, prefix) .. "] "
    else
        return ""
    end
end

-- Check if mcl_commands mod is present
if minetest.get_modpath("mcl_commands") then
    -- Override the default /tell command
    minetest.override_chatcommand("tell", {
        func = function(name, param)
            local target, message = string.match(param, "^(%S+)%s(.+)$")
            if not target or not message then
                return false, "Invalid usage, see /help tell."
            end

            local target_player = minetest.get_player_by_name(target)
            if not target_player then
                return false, "Player " .. target .. " is not online."
            end

            local sender_prefix = get_formatted_prefix(name)
            local full_message = "DM from " .. sender_prefix .. name .. ": " .. message

            minetest.chat_send_player(target, full_message)
            return true, "Message sent."
        end
    })
end

-- Override the default /msg command
minetest.override_chatcommand("msg", {
    func = function(name, param)
        local target, message = string.match(param, "^(%S+)%s(.+)$")
        if not target or not message then
            return false, "Invalid usage, see /help msg."
        end

        local target_player = minetest.get_player_by_name(target)
        if not target_player then
            return false, "Player " .. target .. " is not online."
        end

        local sender_prefix = get_formatted_prefix(name)
        local full_message = "DM from " .. sender_prefix .. name .. ": " .. message

        minetest.chat_send_player(target, full_message)
        return true, "Message sent."
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
