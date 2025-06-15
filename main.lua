local supportedGames = {
    { 
        ID = 3823781113,
        Name = "Saber Simulator",
        Scripts = {
            { Name = "Script 1", URL = "https://rawscripts.net/raw/Saber-Simulator-REVAMP-Op-Gui-41756" },
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
            { Name = "LDS Hub", URL = "https://api.luarmor.net/files/v3/loaders/49f02b0d8c1f60207c84ae76e12abc1e.lua" }
        }
    }
}

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local function rejoin()
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end

local function serverhop()
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)
    if success and data then
        for _, s in ipairs(data) do
            if s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Players.LocalPlayer)
                return
            end
        end
    end
end

local function smallServer()
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)
    if success and data and #data > 0 then
        table.sort(data, function(a, b) return a.playing < b.playing end)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, data[1].id, Players.LocalPlayer)
    end
end

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/main/source.lua", true))()

local Window = Luna:CreateWindow({
    Name = "Saturn Hub",
    Subtitle = "v1.0",
    LogoID = "7251671408",
    LoadingEnabled = true,
    LoadingTitle = "Saturn Hub",
    LoadingSubtitle = "by coolio",
    KeySystem = false
})

Window:CreateHomeTab({
    SupportedExecutors = {},
    DiscordInvite = "TyevewM7Jc",
    Icon = 1
})

local function runUniversalFallback()
    local universalTab = Window:CreateTab({
        Name = "Universal",
        Icon = "view_in_ar",
        ImageSource = "Material",
        ShowTitle = true
    })

    universalTab:CreateSection("Admin")
    universalTab:CreateButton({ Name = "Infinite Yield", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end })
    universalTab:CreateButton({ Name = "Nameless Admin", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
    end })
    universalTab:CreateButton({ Name = "AK Admin", Callback = function()
        loadstring(game:HttpGet("https://angelical.me/ak.lua"))()
    end })

    universalTab:CreateDivider()
    universalTab:CreateSection("FE")
    universalTab:CreateButton({ Name = "Stalkie", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0riginalWarrior/Stalkie/refs/heads/main/roblox.lua"))()
    end })

    universalTab:CreateDivider()
    universalTab:CreateSection("Script Hubs")
    universalTab:CreateButton({ Name = "Speed Hub X", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
    end })
    universalTab:CreateButton({ Name = "Forge Hub", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua"))()
    end })

    universalTab:CreateDivider()
    universalTab:CreateSection("Server Utilities")
    universalTab:CreateButton({ Name = "Rejoin", Callback = rejoin })
    universalTab:CreateButton({ Name = "Serverhop", Callback = serverhop })
    universalTab:CreateButton({ Name = "Small Server", Callback = smallServer })
end

local function runDetectedGame()
    local gameId = game.PlaceId
    local currentGameFound = false

    local tab = Window:CreateTab({
        Name = "Games",
        Icon = "view_in_ar",
        ImageSource = "Material",
        ShowTitle = true
    })

    local gameOptions = {}
    local gameMap = {}
    for _, game in ipairs(supportedGames) do
        table.insert(gameOptions, game.Name)
        gameMap[game.Name] = game
    end

    local scriptDropdown = nil

    tab:CreateDropdown({
        Name = "Select Game",
        Options = gameOptions,
        Callback = function(gameName)
            local selectedGame = gameMap[gameName]
            if selectedGame then
                if scriptDropdown then scriptDropdown:Destroy() end
                local scriptOptions = {}
                local scriptMap = {}
                for _, script in ipairs(selectedGame.Scripts) do
                    if script.URL and script.URL ~= "" then
                        table.insert(scriptOptions, script.Name)
                        scriptMap[script.Name] = script.URL
                    end
                end
                if #scriptOptions == 0 then
                    scriptDropdown = tab:CreateLabel("No scripts available for this game.")
                else
                    scriptDropdown = tab:CreateDropdown({
                        Name = "Select Script",
                        Options = scriptOptions,
                        Callback = function(scriptName)
                            local url = scriptMap[scriptName]
                            if url then
                                loadstring(game:HttpGet(url, true))()
                            end
                        end
                    })
                end
            end
        end
    })

    for _, game in ipairs(supportedGames) do
        if game.ID == gameId then
            currentGameFound = true
        end
    end

    if not currentGameFound then
        runUniversalFallback()
    end
end

task.defer(runDetectedGame)
