local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local supportedGames = {
    {
        ID = 3823781113,
        Name = "Saber Simulator",
        Scripts = {
            { Name = "Revamp OP Gui", URL = "https://rawscripts.net/raw/Saber-Simulator-REVAMP-Op-Gui-41756" },
            { Name = "NS Hub", URL = "https://rawscripts.net/raw/Saber-Simulator-SUMMER-SUMMER-EVENT-AUTO-FARM-AUTO-BUY-AUTO-BOSS-41970" }
        }
    },
    {
        ID = 126884695634066,
        Name = "Grow a Garden",
        Scripts = {
            { Name = "Speed Hub X", URL = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" }
        }
    },
    {
        ID = 13127800756,
        Name = "Arm Wrestle Simulator",
        Scripts = {
            { Name = "NDS Hub", URL = "https://api.luarmor.net/files/v3/loaders/49f02b0d8c1f60207c84ae76e12abc1e.lua" }
        }
    }
}

local function rejoin()
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end

local function serverhop()
    local currentJobId = game.JobId
    local maxAttempts = 50
    local attempts = 0

    while attempts < maxAttempts do
        attempts += 1
        local success, result = pcall(function()
            local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= currentJobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Players.LocalPlayer)
                    return
                end
            end
        end

        task.wait(1)
    end

    warn("Serverhop failed: No non-full server found after multiple attempts.")
end

local function smallServer()
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)
    if ok and data and #data > 0 then
        table.sort(data, function(a, b) return a.playing < b.playing end)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, data[1].id, Players.LocalPlayer)
    end
end

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

local Window = Luna:CreateWindow({
    Name            = "Saturn Hub",
    Subtitle        = "v1.0.1",
    LogoID          = "7251671408",
    LoadingEnabled  = true,
    LoadingTitle    = "Saturn Hub",
    LoadingSubtitle = "by coolio",
    KeySystem       = false
})

Window:CreateHomeTab({
    SupportedExecutors = {"All"},
    DiscordInvite = "TyevewM7Jc",
    Icon = 1
})

local function runDetectedGame()
    local tab = Window:CreateTab({
        Name = "Scripts",
        Icon = "view_in_ar",
        ImageSource = "Material",
        ShowTitle = true
    })

    local foundGame
    for _, gameEntry in ipairs(supportedGames) do
        if game.PlaceId == gameEntry.ID then
            foundGame = gameEntry
            break
        end
    end

    local scriptOptions = {}

    if foundGame then
        for _, s in ipairs(foundGame.Scripts) do
            table.insert(scriptOptions, {
                Name = s.Name,
                Value = s.URL
            })
        end

        tab:CreateDropdown({
            Name = "Select Script",
            Options = scriptOptions,
            Callback = function(sel)
                if sel and sel.Value then
                    local success, err = pcall(function()
                        loadstring(game:HttpGet(sel.Value, true))()
                    end)
                    if not success then
                        warn("Script Load Error: " .. tostring(err))
                    end
                end
            end
        })
    else
        tab:CreateLabel("No scripts available for this game.")
    end

    tab:CreateDivider()
    tab:CreateSection("Utilities")

    tab:CreateButton({ Name = "Rejoin", Callback = rejoin })
    tab:CreateButton({ Name = "Serverhop (Smart)", Callback = serverhop })
    tab:CreateButton({ Name = "Join Smallest Server", Callback = smallServer })
end

task.defer(runDetectedGame)
