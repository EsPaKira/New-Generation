local m = _G["$Multiplayer"]
local api = require(string.format("%s:api/%s/api", m.pack_id, m.api_references.Neutron[2])).server
local gamemodes = require "server/gamemodes"

api.console.set_command("gamemode: gamemode=<string> -> Changes player gamemode", {permission={"role_managment"}}, function(args, client)
    if not gamemodes.is_exists then
        api.console.tell(string.format("%s %s gamemode is not exists! Did you mean survival or creative?", api.console.colors.red, args.gamemode), client)
        return
    end

    gamemodes.set(client, args.gamemode)
    api.console.tell(string.format("%s %s gamemode is changed!", api.console.colors.green, args.gamemode), client)
end)