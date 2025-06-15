local TeleportService = game:GetService("TeleportService")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")

-- Flattened list of supported games
local supportedGames = {
    { 
        ID = 3823781113,
        Name = "Saber Simulator",
        Scripts = {
            { Name = "Revamp OP Gui", URL = "https://rawscripts.net/raw/Saber-Simulator-REVAMP-Op-Gui-41756" },
            { Name = "NS Hub",       URL = "https://rawscripts.net/raw/Saber-Simulator-SUMMER-SUMMER-EVENT-AUTO-FARM-AUTO-BUY-AUTO-BOSS-41970" }
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

-- Utility functions
local function rejoin()
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end

local function serverhop()
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
        game.PlaceId
    )
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)
    if not ok or type(data) ~= "table" then return end
    for _, s in ipairs(data) do
        if s.playing < s.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Players.LocalPlayer)
            return
        end
    end
end

local function smallServer()
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
        game.PlaceId
    )
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)
    if not ok or type(data) ~= "table" or #data == 0 then return end
    table.sort(data, function(a, b) return a.playing < b.playing end)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, data[1].id, Players.LocalPlayer)
end

-- Load Luna Interface Suite
local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua",
    true
))()

-- Create main window (no executor whitelist)
local Window = Luna:CreateWindow({
    Name            = "Saturn Hub",
    Subtitle        = "v1.0",
    LogoID          = "7251671408",
    LoadingEnabled  = true,
    LoadingTitle    = "Saturn Hub",
    LoadingSubtitle = "by coolio",
    KeySystem       = false
})

-- Home tab (allows any executor)
Window:CreateHomeTab({
    SupportedExecutors = {},
    DiscordInvite     = "TyevewM7Jc",
    Icon              = 1
})

-- Universal fallback tools
local function runUniversalFallback()
    local ut = Window:CreateTab({
        Name        = "Universal",
        Icon        = "view_in_ar",
        ImageSource = "Material",
        ShowTitle   = true
    })

    ut:CreateSection("Admin")
    ut:CreateButton({ Name = "Infinite Yield", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))()
    end })
    ut:CreateButton({ Name = "Nameless Admin", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua", true))()
    end })
    ut:CreateButton({ Name = "AK Admin", Callback = function()
        loadstring(game:HttpGet("https://angelical.me/ak.lua", true))()
    end })

    ut:CreateDivider()
    ut:CreateSection("FE")
    ut:CreateButton({ Name = "Stalkie", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0riginalWarrior/Stalkie/refs/heads/main/roblox.lua", true))()
    end })

    ut:CreateDivider()
    ut:CreateSection("Script Hubs")
    ut:CreateButton({ Name = "Speed Hub X", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
    end })
    ut:CreateButton({ Name = "Forge Hub", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua", true))()
    end })

    ut:CreateDivider()
    ut:CreateSection("Server Utilities")
    ut:CreateButton({ Name = "Rejoin",      Callback = rejoin })
    ut:CreateButton({ Name = "Serverhop",   Callback = serverhop })
    ut:CreateButton({ Name = "Small Server", Callback = smallServer })
end

-- Build single “Scripts” tab with safe closures
local function runDetectedGame()
    local placeId = game.PlaceId
    local currentGame

    for _, g in ipairs(supportedGames) do
        if g.ID == placeId then
            currentGame = g
            break
        end
    end

    if not currentGame then
        return runUniversalFallback()
    end

    local scriptsTab = Window:CreateTab({
        Name        = "Scripts",
        Icon        = "view_in_ar",
        ImageSource = "Material",
        ShowTitle   = true
    })

    scriptsTab:CreateSection(currentGame.Name)
    for _, scriptInfo in ipairs(currentGame.Scripts) do
        -- capture each scriptInfo into its own local
        local info = scriptInfo

        scriptsTab:CreateButton({
            Name = info.Name,
            Callback = function()
                -- fetch the code
                local okFetch, res = pcall(function()
                    return game:HttpGet(info.URL, true)
                end)
                if not okFetch or type(res) ~= "string" then
                    warn(("Saturn Hub: failed HTTP fetch for %q: %s"):format(info.Name, tostring(res)))
                    return
                end

                -- compile the code
                local okCompile, fnOrErr = pcall(loadstring, res)
                if not okCompile or type(fnOrErr) ~= "function" then
                    warn(("Saturn Hub: failed to compile %q: %s"):format(info.Name, tostring(fnOrErr)))
                    return
                end

                -- run the compiled function
                local okRun, runErr = pcall(fnOrErr)
                if not okRun then
                    warn(("Saturn Hub: error running %q: %s"):format(info.Name, tostring(runErr)))
                end
            end
        })
    end

    scriptsTab:CreateDivider()
    scriptsTab:CreateSection("Server Utilities")
    scriptsTab:CreateButton({ Name = "Rejoin",      Callback = rejoin })
    scriptsTab:CreateButton({ Name = "Serverhop",   Callback = serverhop })
    scriptsTab:CreateButton({ Name = "Small Server", Callback = smallServer })
end

-- Start it up
task.defer(runDetectedGame)
