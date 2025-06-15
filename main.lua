--===== CONFIGURATION =====--
local CurrentVersion = "1.0.0"
local VersionURL     = "https://raw.githubusercontent.com/barryjensen/saturnhub/refs/heads/main/version.txt"

--===== SERVICES =====--
local TeleportService = game:GetService("TeleportService")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")

--===== GAME/SCRIPT DATA =====--
local supportedGames = {
    {
        ID = 3823781113,
        Name = "Saber Simulator",
        Scripts = {
            { Name = "Revamp OP Gui", URL = "https://rawscripts.net/raw/Saber-Simulator-REVAMP-Op-Gui-41756" },
            { Name = "NS Hub",        URL = "https://rawscripts.net/raw/Saber-Simulator-SUMMER-SUMMER-EVENT-AUTO-FARM-AUTO-BUY-AUTO-BOSS-41970" },
            { Name = "Trash Ass Hub", URL = "https://raw.githubusercontent.com/WheatDevelopment/roblox-scripts/main/SaberSim.lua" }
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

--===== UTILITY FUNCTIONS =====--
local function rejoin()
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end

local function serverhop()
    local currentJobId = game.JobId
    local maxAttempts  = 50
    local attempts     = 0

    while attempts < maxAttempts do
        attempts += 1
        local ok, result = pcall(function()
            local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100")
                :format(game.PlaceId)
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if ok and result and type(result.data) == "table" then
            for _, srv in ipairs(result.data) do
                if srv.playing < srv.maxPlayers and srv.id ~= currentJobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, Players.LocalPlayer)
                    return
                end
            end
        end
        task.wait(1)
    end

    warn("Saturn Hub: serverhop()—no non-full server found after " .. maxAttempts .. " attempts.")
end

local function smallServer()
    local ok, result = pcall(function()
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100")
            :format(game.PlaceId)
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)
    if ok and type(result) == "table" and #result > 0 then
        table.sort(result, function(a, b) return a.playing < b.playing end)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, result[1].id, Players.LocalPlayer)
    end
end

--===== VERSION CHECKER =====--
local function checkForUpdates()
    local ok, res = pcall(function()
        return game:HttpGet(VersionURL)
    end)
    if ok and type(res) == "string" then
        local latest = res:match("%S+")
        if latest and latest ~= CurrentVersion then
            return true, latest
        end
    end
    return false, nil
end

--===== LOAD LUNA UI =====--
local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua",
    true
))()

--===== CREATE MAIN WINDOW =====--
local Window = Luna:CreateWindow({
    Name            = "Saturn Hub",
    Subtitle        = "v" .. CurrentVersion,
    LogoID          = "7251671408",
    LoadingEnabled  = true,
    LoadingTitle    = "Saturn Hub",
    LoadingSubtitle = "by coolio",
    KeySystem       = false  -- supports all executors
})

Window:CreateHomeTab({
    SupportedExecutors = {},  -- allow any
    DiscordInvite     = "TyevewM7Jc",
    Icon              = 1
})

--===== INITIAL UPDATE CHECK =====--
task.defer(function()
    local available, latest = checkForUpdates()
    if available then
        warn(("Saturn Hub: update available! v%s (you have v%s)"):format(latest, CurrentVersion))
    end
end)

--===== BUILD TABS =====--
local function runDetectedGame()
    -- Detect game
    local currentGame
    for _, g in ipairs(supportedGames) do
        if g.ID == game.PlaceId then
            currentGame = g
            break
        end
    end

    if not currentGame then
        -- Universal fallback tab
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
        ut:CreateSection("Utilities")
        ut:CreateButton({ Name = "Rejoin",         Callback = rejoin })
        ut:CreateButton({ Name = "Serverhop",      Callback = serverhop })
        ut:CreateButton({ Name = "Small Server",   Callback = smallServer })

        -- Update-check button
        ut:CreateDivider()
        ut:CreateButton({
            Name = "Check for Updates",
            Callback = function()
                local available, latest = checkForUpdates()
                if available then
                    warn(("Saturn Hub: update available! v%s (you have v%s)"):format(latest, CurrentVersion))
                else
                    warn(("Saturn Hub: you’re up to date (v%s)"):format(CurrentVersion))
                end
            end
        })

        return
    end

    -- Scripts tab for the detected game
    local tab = Window:CreateTab({
        Name        = "Scripts",
        Icon        = "view_in_ar",
        ImageSource = "Material",
        ShowTitle   = true
    })

    tab:CreateSection(currentGame.Name)
    for _, info in ipairs(currentGame.Scripts) do
        local scriptName = info.Name
        local scriptURL  = info.URL

        tab:CreateButton({
            Name     = scriptName,
            Callback = function()
                local okFetch, res = pcall(function()
                    return game:HttpGet(scriptURL, true)
                end)
                if not (okFetch and type(res) == "string") then
                    warn(("Saturn Hub: HTTP error loading %q: %s"):format(scriptName, tostring(res)))
                    return
                end

                local okLoad, fnOrErr = pcall(loadstring, res)
                if not (okLoad and type(fnOrErr) == "function") then
                    warn(("Saturn Hub: compile error in %q: %s"):format(scriptName, tostring(fnOrErr)))
                    return
                end

                local okRun, runErr = pcall(fnOrErr)
                if not okRun then
                    warn(("Saturn Hub: runtime error in %q: %s"):format(scriptName, tostring(runErr)))
                end
            end
        })
    end

    tab:CreateDivider()
    tab:CreateSection("Utilities")
    tab:CreateButton({ Name = "Rejoin",       Callback = rejoin })
    tab:CreateButton({ Name = "Serverhop",    Callback = serverhop })
    tab:CreateButton({ Name = "Small Server", Callback = smallServer })

    -- Update-check button
    tab:CreateDivider()
    tab:CreateButton({
        Name = "Check for Updates",
        Callback = function()
            local available, latest = checkForUpdates()
            if available then
                warn(("Saturn Hub: update available! v%s (you have v%s)"):format(latest, CurrentVersion))
            else
                warn(("Saturn Hub: you’re up to date (v%s)"):format(CurrentVersion))
            end
        end
    })
end

task.defer(runDetectedGame)
