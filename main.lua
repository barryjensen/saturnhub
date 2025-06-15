--===== CONFIGURATION =====--
local CurrentVersion = "1.0.0"
local VersionURL     = "https://raw.githubusercontent.com/barryjensen/saturnhub/refs/heads/main/version.txt"

--===== SERVICES =====--
local TeleportService = game:GetService("TeleportService")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")
local StarterGui      = game:GetService("StarterGui")

--===== GAME/SCRIPT DATA =====--
local supportedGames = {
    {
        ID = 3823781113,
        Name = "Saber Simulator",
        Scripts = {
            { Name = "Revamp OP Gui", URL = "https://rawscripts.net/raw/Saber-Simulator-REVAMP-Op-Gui-41756" },
            { Name = "NS Hub",        URL = "https://rawscripts.net/raw/Saber-Simulator-SUMMER-SUMMER-EVENT-AUTO-FARM-AUTO-BUY-AUTO-BOSS-41970" }
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
    },
    {
        ID = 3623096087,
        Name = "Muscle Legends",
        Scripts = {
            { Name = "Speed Hub X",   URL = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" },
            { Name = "Enchanted Hub", URL = "https://raw.githubusercontent.com/iblameaabis/Enchanted/refs/heads/main/Enchanted%20Hub%20On%20Top" }
        }
    },
    {
        ID = 6403373529,
        Name = "Slap Battles",
        Scripts = {
            { Name = "Forge Hub", URL = "https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua" }
        }
    },
    {
        ID = 2753915549,
        Name = "Blox Fruits",
        Scripts = {
            { Name = "Redz Hub", URL = "https://raw.githubusercontent.com/newredz/BloxFruits/refs/heads/main/Source.luau" }
        }
    },
    {
        ID = 10449761463,
        Name = "The Strongest Battlegrounds",
        Scripts = {
            { Name = "Kukuri Client", URL = "https://raw.githubusercontent.com/Mikasuru/Arc/refs/heads/main/Arc.lua" }
        }
    }
}

--===== UTILITY FUNCTIONS =====--
-- Embedded console logger (writes to UI & Studio warn)
local function consoleLog(msg)
    warn("[SaturnHub] " .. msg)
    if _G.ConsoleScroll and _G.ConsoleLayout then
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size                = UDim2.new(1, 0, 0, 18)
        lbl.TextXAlignment      = Enum.TextXAlignment.Left
        lbl.Font               = Enum.Font.Code
        lbl.TextSize           = 16
        lbl.TextColor3         = Color3.new(1, 1, 1)
        lbl.Text               = msg
        lbl.Parent             = _G.ConsoleScroll
        _G.ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, _G.ConsoleLayout.AbsoluteContentSize.Y)
    end
end

local function notify(title, text, duration)
    consoleLog(("Notify: %s – %s"):format(title, text))
    StarterGui:SetCore("SendNotification", {
        Title    = title,
        Text     = text,
        Duration = duration or 5
    })
end

local function promptReload(title, text)
    consoleLog(("PromptReload: %s – %s"):format(title, text))
    StarterGui:SetCore("SendNotification", {
        Title    = title,
        Text     = text,
        Duration = 10,
        Button1  = "Reload",
        Button2  = "Later",
        Callback = function()
            consoleLog("User clicked Reload → teleporting to reload Hub.")
            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
        end
    })
end

local function rejoin()
    consoleLog("Rejoining current server.")
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end

local function serverhop()
    consoleLog("Starting serverhop loop.")
    local currentJobId = game.JobId
    while true do
        local ok, result = pcall(function()
            local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100")
                :format(game.PlaceId)
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if ok and result and type(result.data) == "table" then
            for _, srv in ipairs(result.data) do
                if srv.playing < srv.maxPlayers and srv.id ~= currentJobId then
                    consoleLog(("Teleporting to server %s (%d/%d)"):format(srv.id, srv.playing, srv.maxPlayers))
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, Players.LocalPlayer)
                    return
                end
            end
        else
            consoleLog("Error fetching server list.")
        end
        task.wait(1)
    end
end

local function smallServer()
    consoleLog("Looking for smallest server.")
    local ok, data = pcall(function()
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100")
            :format(game.PlaceId)
        return HttpService:JSONDecode(game:HttpGet(url)).data
    end)
    if ok and type(data) == "table" and #data > 0 then
        table.sort(data, function(a,b) return a.playing < b.playing end)
        consoleLog(("Teleporting to smallest server %s (%d/%d)"):format(data[1].id, data[1].playing, data[1].maxPlayers))
        TeleportService:TeleportToPlaceInstance(game.PlaceId, data[1].id, Players.LocalPlayer)
    else
        consoleLog("Failed to fetch smallest server.")
    end
end

--===== VERSION CHECKER =====--
local function checkForUpdates()
    local ok, res = pcall(function() return game:HttpGet(VersionURL) end)
    if ok and type(res) == "string" then
        local latest = res:match("%S+")
        if latest and latest ~= CurrentVersion then
            consoleLog("Update found: v" .. latest .. " (you have v" .. CurrentVersion .. ")")
            return true, latest
        end
    end
    consoleLog("No update available (v" .. CurrentVersion .. ").")
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
    KeySystem       = false
})

Window:CreateHomeTab({
    SupportedExecutors = {},
    DiscordInvite     = "TyevewM7Jc",
    Icon              = 1
})

--===== INITIAL UPDATE CHECK (deferred) =====--
task.defer(function()
    local available, latest = checkForUpdates()
    if available then
        promptReload(
            "Saturn Hub",
            "Update available! v" .. latest .. " (you have v" .. CurrentVersion .. ")"
        )
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

        -- Console UI inside Universal
        ut:CreateSection("Console")
        do
            local consoleFrame = Instance.new("Frame")
            consoleFrame.BackgroundTransparency = 1
            consoleFrame.Size     = UDim2.new(1, -20, 1, -60)
            consoleFrame.Position = UDim2.new(0, 10, 0, 40)
            consoleFrame.Parent   = ut.Container

            local scroll = Instance.new("ScrollingFrame")
            scroll.Name                   = "ConsoleScroll"
            scroll.BackgroundTransparency = 1
            scroll.Size                   = UDim2.new(1, 0, 1, 0)
            scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
            scroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
            scroll.Parent                 = consoleFrame

            local layout = Instance.new("UIListLayout")
            layout.Parent = scroll
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding   = UDim.new(0, 2)

            _G.ConsoleScroll = scroll
            _G.ConsoleLayout = layout
        end

        -- Admin section
        ut:CreateSection("Admin")
        ut:CreateButton({ Name = "Infinite Yield", Callback = function()
            consoleLog("Executing Infinite Yield")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))()
        end })
        ut:CreateButton({ Name = "Nameless Admin", Callback = function()
            consoleLog("Executing Nameless Admin")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua", true))()
        end })
        ut:CreateButton({ Name = "AK Admin", Callback = function()
            consoleLog("Executing AK Admin")
            loadstring(game:HttpGet("https://angelical.me/ak.lua", true))()
        end })

        ut:CreateDivider()
        ut:CreateSection("FE")
        ut:CreateButton({ Name = "Stalkie", Callback = function()
            consoleLog("Executing Stalkie")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/0riginalWarrior/Stalkie/refs/heads/main/roblox.lua", true))()
        end })

        ut:CreateDivider()
        ut:CreateSection("Script Hubs")
        ut:CreateButton({ Name = "Speed Hub X", Callback = function()
            consoleLog("Executing Speed Hub X")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
        end })
        ut:CreateButton({ Name = "Forge Hub", Callback = function()
            consoleLog("Executing Forge Hub")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua", true))()
        end })

        ut:CreateDivider()
        ut:CreateSection("Utilities")
        ut:CreateButton({ Name = "Rejoin",       Callback = rejoin })
        ut:CreateButton({ Name = "Serverhop",    Callback = serverhop })
        ut:CreateButton({ Name = "Small Server", Callback = smallServer })

        ut:CreateDivider()
        ut:CreateButton({
            Name = "Check for Updates",
            Callback = function()
                local available, latest = checkForUpdates()
                if available then
                    promptReload(
                        "Saturn Hub",
                        "Update available! v" .. latest .. " (you have v" .. CurrentVersion .. ")"
                    )
                else
                    notify("Saturn Hub", "You’re up to date (v" .. CurrentVersion .. ")", 5)
                end
            end
        })

        return
    end

    -- Scripts tab if game-specific
    local tab = Window:CreateTab({
        Name        = "Scripts",
        Icon        = "view_in_ar",
        ImageSource = "Material",
        ShowTitle   = true
    })

    tab:CreateSection(currentGame.Name)
    for _, info in ipairs(currentGame.Scripts) do
        tab:CreateButton({
            Name = info.Name,
            Callback = function()
                consoleLog("Loading script: " .. info.Name)
                local okFetch, res = pcall(function()
                    return game:HttpGet(info.URL, true)
                end)
                if not (okFetch and type(res) == "string") then
                    notify("Saturn Hub", "Failed to load " .. info.Name, 4)
                    return
                end

                local okLoad, fnOrErr = pcall(loadstring, res)
                if not (okLoad and type(fnOrErr) == "function") then
                    notify("Saturn Hub", "Compile error in " .. info.Name, 4)
                    return
                end

                local okRun, runErr = pcall(fnOrErr)
                if not okRun then
                    notify("Saturn Hub", "Runtime error in " .. info.Name, 4)
                end
            end
        })
    end

    tab:CreateDivider()
    tab:CreateSection("Utilities")
    tab:CreateButton({ Name = "Rejoin",       Callback = rejoin })
    tab:CreateButton({ Name = "Serverhop",    Callback = serverhop })
    tab:CreateButton({ Name = "Small Server", Callback = smallServer })

    tab:CreateDivider()
    tab:CreateButton({
        Name = "Check for Updates",
        Callback = function()
            local available, latest = checkForUpdates()
            if available then
                promptReload(
                    "Saturn Hub",
                    "Update available! v" .. latest .. " (you have v" .. CurrentVersion .. ")"
                )
            else
                notify("Saturn Hub", "You’re up to date (v" .. CurrentVersion .. ")", 5)
            end
        end
    })
end

task.defer(runDetectedGame)
