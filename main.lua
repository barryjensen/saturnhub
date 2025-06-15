local TeleportService = game:GetService("TeleportService")
local Players        = game:GetService("Players")
local HttpService    = game:GetService("HttpService")

local supportedGameGroups = {
    Simulators = {
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
}

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
    if ok and data then
        for _, s in ipairs(data) do
            if s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Players.LocalPlayer)
                return
            end
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
    if ok and data and #data > 0 then
        table.sort(data, function(a, b) return a.playing < b.playing end)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, data[1].id, Players.LocalPlayer)
    end
end

local function checkFriends(userIds)
    for _, id in ipairs(userIds) do
        -- your HttpGet/JSONDecode logic here…
        task.wait(0.5)
    end
end

-- Boot Luna
local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua",
    true
))()

-- Create main window (per docs)
local Window = Luna:CreateWindow({
    Name            = "Saturn Hub",
    Subtitle        = "v1.0",
    LogoID          = "7251671408",
    LoadingEnabled  = true,
    LoadingTitle    = "Saturn Hub",
    LoadingSubtitle = "by coolio",
    KeySystem       = false
})

-- Optional Home tab
Window:CreateHomeTab({
    SupportedExecutors = {},
    DiscordInvite     = "TyevewM7Jc",
    Icon              = 1
})

-- Universal fallback UI
local function runUniversalFallback()
    local ut = Window:CreateTab({
        Name       = "Universal",
        Icon       = "view_in_ar",
        ImageSource= "Material",
        ShowTitle  = true
    })

    ut:CreateSection("Admin")
    ut:CreateButton({
        Name     = "Infinite Yield",
        Callback = function()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
                true
            ))()
        end
    })
    ut:CreateButton({
        Name     = "Nameless Admin",
        Callback = function()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua",
                true
            ))()
        end
    })
    ut:CreateButton({
        Name     = "AK Admin",
        Callback = function()
            loadstring(game:HttpGet("https://angelical.me/ak.lua", true))()
        end
    })

    ut:CreateDivider()
    ut:CreateSection("FE")
    ut:CreateButton({
        Name     = "Stalkie",
        Callback = function()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/0riginalWarrior/Stalkie/refs/heads/main/roblox.lua",
                true
            ))()
        end
    })

    ut:CreateDivider()
    ut:CreateSection("Script Hubs")
    ut:CreateButton({
        Name     = "Speed Hub X",
        Callback = function()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua",
                true
            ))()
        end
    })
    ut:CreateButton({
        Name     = "Forge Hub",
        Callback = function()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua",
                true
            ))()
        end
    })

    ut:CreateDivider()
    ut:CreateSection("Server Utilities")
    ut:CreateButton({ Name = "Rejoin",      Callback = rejoin })
    ut:CreateButton({ Name = "Serverhop",    Callback = serverhop })
    ut:CreateButton({ Name = "Small Server", Callback = smallServer })
end

-- Game‑specific tabs
local function runDetectedGame()
    local placeId = game.PlaceId
    local found   = false

    for category, games in pairs(supportedGameGroups) do
        local tab = Window:CreateTab({
            Name        = category,
            Icon        = "view_in_ar",
            ImageSource = "Material",
            ShowTitle   = true
        })

        local scriptDropdown
        tab:CreateDropdown({
            Name    = "Select Game",
            Options = (function()
                local opts = {}
                for _, g in ipairs(games) do
                    table.insert(opts, { Name = g.Name, Value = g })
                end
                return opts
            end)(),
            Callback = function(chosen)
                local ginfo = chosen.Value
                if scriptDropdown and scriptDropdown.Destroy then
                    scriptDropdown:Destroy()
                    scriptDropdown = nil
                end

                local scrOpts = {}
                for _, s in ipairs(ginfo.Scripts) do
                    if s.URL and #s.URL > 0 then
                        table.insert(scrOpts, { Name = s.Name, Value = s.URL })
                    end
                end

                if #scrOpts == 0 then
                    scriptDropdown = tab:CreateLabel("No scripts available.")
                else
                    scriptDropdown = tab:CreateDropdown({
                        Name    = "Select Script",
                        Options = scrOpts,
                        Callback = function(sel)
                            loadstring(game:HttpGet(sel.Value, true))()
                        end
                    })
                end
            end
        })

        for _, g in ipairs(games) do
            if g.ID == placeId then
                found = true
                break
            end
        end
    end

    if not found then
        runUniversalFallback()
    end
end

-- Kick everything off
task.defer(runDetectedGame)

-- **Required** per Luna docs: load saved configs/autoload tab state
Luna:LoadAutoloadConfig()
