local TeleportService = game:GetService("TeleportService")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")
local StarterGui      = game:GetService("StarterGui")

-- Notification helper
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Notification",
            Text = text or "",
            Duration = duration or 5
        })
    end)
end

-- Game list
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

-- Teleport Utilities
local function rejoin()
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end

local function serverhop()
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
    local tried = {}
    while true do
        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url)).data
        end)
        if ok then
            for _, s in ipairs(result) do
                if s.playing < s.maxPlayers and not tried[s.id] then
                    tried[s.id] = true
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Players.LocalPlayer)
                    return
                end
            end
        end
        task.wait(1)
    end
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

-- Load Luna UI
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

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
    SupportedExecutors = {}, -- support all
    DiscordInvite = "TyevewM7Jc",
    Icon = 1
})

-- Universal Tab if no match
local function runUniversalFallback()
    local ut = Window:CreateTab({
        Name = "Universal",
        Icon = "view_in_ar",
        ImageSource = "Material",
        ShowTitle = true
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

    ut:CreateSection("FE")
    ut:CreateButton({ Name = "Stalkie", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0riginalWarrior/Stalkie/refs/heads/main/roblox.lua", true))()
    end })

    ut:CreateSection("Script Hubs")
    ut:CreateButton({ Name = "Speed Hub X", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
    end })
    ut:CreateButton({ Name = "Forge Hub", Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua", true))()
    end })

    ut:CreateSection("Server Utilities")
    ut:CreateButton({ Name = "Rejoin", Callback = rejoin })
    ut:CreateButton({ Name = "Serverhop", Callback = serverhop })
    ut:CreateButton({ Name = "Small Server", Callback = smallServer })
end

-- Detect game and show scripts
local function runDetectedGame()
    local placeId = game.PlaceId
    local match = nil

    for _, g in ipairs(supportedGames) do
        if g.ID == placeId then
            match = g
            break
        end
    end

    local tab = Window:CreateTab({
        Name = match and match.Name or "Scripts",
        Icon = "view_in_ar",
        ImageSource = "Material",
        ShowTitle = true
    })

    if match then
        local scriptOptions = {}
        for _, s in ipairs(match.Scripts) do
            if s.URL and #s.URL > 0 then
                table.insert(scriptOptions, {
                    Name = s.Name,
                    Value = s.URL
                })
            end
        end

        if #scriptOptions == 0 then
            tab:CreateLabel("No scripts available.")
        else
            tab:CreateDropdown({
                Name = "Select Script",
                Options = scriptOptions,
                Callback = function(sel)
                    local success, err = pcall(function()
                        loadstring(game:HttpGet(sel.Value, true))()
                        notify("Saturn Hub", "Loaded: " .. sel.Name)
                    end)
                    if not success then
                        notify("Error", "Failed to load script.")
                    end
                end
            })
        end

        tab:CreateDivider()
        tab:CreateSection("Server Tools")
        tab:CreateButton({ Name = "Rejoin", Callback = rejoin })
        tab:CreateButton({ Name = "Serverhop", Callback = serverhop })
        tab:CreateButton({ Name = "Small Server", Callback = smallServer })
    else
        runUniversalFallback()
    end
end

task.defer(runDetectedGame)
