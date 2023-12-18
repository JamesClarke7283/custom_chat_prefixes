# Custom Chat Prefixes

## Overview
Custom Chat Prefixes allows players to set personalized prefixes for their chat messages. It offers the functionality for players with specific privileges to assign prefixes to others and to utilize reserved prefixes. The tool also modifies the `/tell` and `/msg` commands to include these custom prefixes in direct messages.

## Features
- Personalized chat prefixes with color options.
- Capability to clear existing chat prefixes.
- Altered `/tell` and `/msg` commands for displaying custom prefixes in direct messages.
- Reserved prefixes for administrative roles, configurable through the `restricted_prefixes` setting.
- Functionality to assign prefixes for other players (administrative privilege required).

## Commands
1. **/prefix get**: Shows your current prefix.
2. **/prefix set \<prefix> [color]**: Assigns a new chat prefix with an optional color.
3. **/prefix set_player \<player_name> \<prefix> [color]**: Assigns a chat prefix to another player (administrative privileges required).
4. **/prefix clear**: Removes your current chat prefix.
5. **/prefix clear \<player_name>**: Removes the chat prefix of another player (administrative privileges required).

## Usage Examples
To assign a custom prefix:
```
/prefix set AwesomePrefix #FF00FF
```
To remove your prefix:
```
/prefix clear
```
To assign a prefix to another player (as an administrator):
```
/prefix set_player Player2 CoolPrefix #00FFFF
```
To send a direct message incorporating your prefix:
```
/msg Player2 Hello there!
```

## Configurable Settings
- **restricted_prefixes**: A comma-separated list of prefixes that are reserved for administrative use. These prefixes cannot be set by regular players. This setting can be modified in the `minetest.conf` file.

## Dependencies
- Version 5.0.0 or later of the game engine.
- `mcl_commands` for conditional command override (optional).

---

Enhance your chat experience with Custom Chat Prefixes!