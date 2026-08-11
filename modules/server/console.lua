local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2])).server
local gamemodes = require "server/gamemodes"

api.console.set_command("gamemode: gamemode=<string> -> Changes player gamemode", {permissions={"role_management"}}, function(args, client)
    if not gamemodes.is_exists(args.gamemode) then
        api.console.tell(string.format("%sThe gamemode %s does not exist! Did you mean survival or creative?", api.console.colors.red, args.gamemode), client)
        return
    end

    gamemodes.set(client, args.gamemode)
    api.console.tell(string.format("%sGamemode changed to %s.", api.console.colors.green, args.gamemode), client)
end)