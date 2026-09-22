-- language: Lua, file: ETX_v1_3.lua, target: Roblox Project Delta
-- ETX v1.3 — Aimbot + Wiki Bullet Drop + ESP + HP Bar + Skeleton + China Hat + Vehicle ESP + Preview (animation) + Mod Check + FullBright + Grass/Leaves Remover

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== UI ====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Project Delta | ETX v1.3",
    LoadingTitle = "Đang tải ETX...",
    LoadingSubtitle = "by ANON",
    ConfigurationSaving = { Enabled = true, FolderName = "ANON_PD", FileName = "ETX_config" },
    KeySystem = false,
})

-- ==================== STATE ====================
-- Aimbot
local AimbotMaster = false
local AimbotActive = false
local AimbotKeybind = "Y"
local AimbotMode = "Toggle"
local FOV = 150
local TargetPart = "Head"
local PredictionEnabled = true
local BulletSpeed = 715
local BulletGravity = 196.2
local Smoothness = 0.15
local MaxDistance = 5000
local CurrentBulletSpeed = nil
local CapturingKey = false
local CaptureConn = nil

-- NPC targeting
local TargetNPCEnabled = false

-- ESP
local ESPEnabled = false
local ESPTransparency = 0.5
local ESPColor = Color3.fromRGB(0, 255, 0)
local ESPObjects = {}

-- HP Bar
local HPBarEnabled = true
local HPBarWidth = 120
local HPColorHigh = Color3.fromRGB(0, 255, 0)
local HPColorMid  = Color3.fromRGB(255, 200, 0)
local HPColorLow  = Color3.fromRGB(255, 40, 40)

-- Skeleton
local SkeletonEnabled = true
local SkeletonColor = Color3.fromRGB(255, 255, 255)
local SkeletonThickness = 1
local SkeletonObjects = {}

-- China Hat
local ChinaHatEnabled = true
local ChinaHatColor = Color3.fromRGB(220, 30, 30)
local ChinaHatScale = 1
local ChinaHatObjects = {}

-- Vehicle / Aircraft ESP
local VehicleESPEnabled = true
local VehicleESPColor = Color3.fromRGB(0, 200, 255)
local VehicleESPTransparency = 0.5
local VehicleObjects = {}
local VEHICLE_KEYWORDS = {
    "mi24", "mi-24", "mi_24", "hind",
    "helicopter", "heli", "chopper",
    "uh60", "uh-60", "blackhawk",
    "ah64", "ah-64", "apache",
    "military", "vehicle", "aircraft", "jet", "plane",
}

-- Preview
local PreviewEnabled = true
local PreviewFrame = nil
local PreviewWorld = nil
local PreviewCam = nil
local PreviewTarget = nil
local PreviewPos = UDim2.new(0, 20, 1, -220)
local PreviewSize = UDim2.new(0, 200, 0, 200)

-- Invisible / Mod
local ModeratorAlertEnabled = true
local InvisibleAlertEnabled = true
local INVIS_THRESHOLD = 0.98
local FLAG_CONSECUTIVE_FRAMES = 1
local InvisCounter = {}
local Flagged = {}
local MOD_GROUP_IDS = {}
local MOD_KEYWORDS = {"moderator", "admin", "owner", "staff"}

-- FullBright
local FullBrightEnabled = false
local OriginalLighting = {}

-- Grass / Leaves Remover
local GrassRemoverEnabled = false
local LeavesRemoverEnabled = false
local HiddenObjects = {}   -- [object] = original properties

-- Targetline
local TargetLineEnabled = true
local TargetLine = Drawing and Drawing.new("Line") or nil
if TargetLine then
    TargetLine.Visible = false
    TargetLine.Color = Color3.fromRGB(255, 50, 50)
    TargetLine.Thickness = 1
    TargetLine.Transparency = 0.8
end

-- FOV Circle
local FOVCircle = Drawing and Drawing.new("Circle") or nil
if FOVCircle then
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 1
    FOVCircle.Transparency = 0.5
    FOVCircle.NumSides = 64
    FOVCircle.Radius = FOV
    FOVCircle.Filled = false
end

-- ==================== WIKI AMMO DATA ====================
-- Bảng muzzle velocity (m/s) tổng hợp từ Wiki Project Delta
local AMMO_VELOCITY = {
    -- Pistol / SMG
    ["9x18"] = 359,
    ["9x18 AP"] = 383,
    ["9x18 TFZ"] = 404,
    ["9x19"] = 465,
    ["9x19 AP"] = 500,
    [".45"] = 465,
    [".45 AP"] = 515,
    ["7.62x25"] = 460,
    ["7.62x25 AP"] = 484,

    -- Rifle
    ["7.62x39"] = 715,
    ["7.62x39 AP"] = 767,
    ["5.56x45"] = 940,
    ["5.56x45 AP"] = 990,
    ["5.45x39"] = 890,
    ["5.45x39 AP"] = 940,
    ["7.62x51"] = 850,
    ["7.62x51 AP"] = 900,
    ["7.62x54R"] = 885,
    ["7.62x54R AP"] = 935,

    -- Shotgun
    ["12ga Slug"] = 405,
    ["12ga Flechette"] = 340,
    ["12ga AP-20"] = 625,

    -- Special
    ["9x39"] = 450,
    ["9x39 AP"] = 490,
    [".300 BLK"] = 550,
    [".300 BLK AP"] = 600,
    ["85mm PG-7V"] = 200,
}

-- Ánh xạ tên súng → caliber (dựa trên wiki Project Delta)
local GUN_CALIBER_MAP = {
    -- Pistol
    ["makarov"] = "9x18", ["pm"] = "9x18",
    ["mp443"] = "9x19", ["glock"] = "9x19",
    ["m1911"] = ".45", ["colt"] = ".45",
    ["tt"] = "7.62x25", ["tokarev"] = "7.62x25",
    -- Rifle
    ["akmn"] = "7.62x39", ["akm"] = "7.62x39",
    ["ak74"] = "5.45x39", ["aks74"] = "5.45x39",
    ["m4a1"] = "5.56x45", ["m16"] = "5.56x45",
    ["adar"] = "5.56x45", ["falm"] = "7.62x51",
    ["fn fal"] = "7.62x51", ["svd"] = "7.62x54R",
    ["pkm"] = "7.62x54R", ["mosin"] = "7.62x54R",
    -- Shotgun
    ["saiga"] = "12ga", ["izh"] = "12ga",
    -- Special
    ["as val"] = "9x39", ["vss"] = "9x39",
    ["m700"] = "7.62x51", ["sr-25"] = "7.62x51",
}

-- ==================== HELPERS ====================
local function GetTargetPart(character, partName)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    if partName == "Head" then return character:FindFirstChild("Head")
    elseif partName == "Torso" then
        if hum.RigType == Enum.HumanoidRigType.R15 then
            return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        end
        return character:FindFirstChild("Torso")
    elseif partName == "HumanoidRootPart" then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return character:FindFirstChild("Head")
end

local function IsNPC(model)
    return Players:GetPlayerFromCharacter(model) == nil
end

local function InputMatches(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name:upper() == AimbotKeybind
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then return AimbotKeybind == "MOUSEBUTTON1"
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then return AimbotKeybind == "MOUSEBUTTON2"
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then return AimbotKeybind == "MOUSEBUTTON3" end
    return false
end

-- ==================== WIKI-BASED GUN VELOCITY SCAN ====================
local function GetAmmoKey(caliber, ammoType)
    local cal = string.lower(caliber or ""):gsub("%s", "")
    local typ = string.lower(ammoType or "")

    if cal:find("9x18") then
        if typ:find("tfz") then return "9x18 TFZ"
        elseif typ:find("ap") or typ:find("armor") then return "9x18 AP"
        else return "9x18" end
    elseif cal:find("9x19") then
        if typ:find("ap") or typ:find("armor") then return "9x19 AP"
        else return "9x19" end
    elseif cal:find("45") then
        if typ:find("ap") or typ:find("armor") then return ".45 AP"
        else return ".45" end
    elseif cal:find("7.62x25") then
        if typ:find("ap") or typ:find("armor") then return "7.62x25 AP"
        else return "7.62x25" end
    elseif cal:find("7.62x39") then
        if typ:find("ap") or typ:find("armor") then return "7.62x39 AP"
        else return "7.62x39" end
    elseif cal:find("5.56x45") then
        if typ:find("ap") or typ:find("armor") then return "5.56x45 AP"
        else return "5.56x45" end
    elseif cal:find("5.45x39") then
        if typ:find("ap") or typ:find("armor") then return "5.45x39 AP"
        else return "5.45x39" end
    elseif cal:find("7.62x51") then
        if typ:find("ap") or typ:find("armor") then return "7.62x51 AP"
        else return "7.62x51" end
    elseif cal:find("7.62x54") then
        if typ:find("ap") or typ:find("armor") then return "7.62x54R AP"
        else return "7.62x54R" end
    elseif cal:find("12ga") or cal:find("12gauge") then
        if typ:find("slug") then return "12ga Slug"
        elseif typ:find("flechette") then return "12ga Flechette"
        elseif typ:find("ap") or typ:find("armor") then return "12ga AP-20"
        else return "12ga Slug" end
    elseif cal:find("9x39") then
        if typ:find("ap") or typ:find("armor") then return "9x39 AP"
        else return "9x39" end
    elseif cal:find("300") or cal:find("blk") then
        if typ:find("ap") or typ:find("armor") then return ".300 BLK AP"
        else return ".300 BLK" end
    elseif cal:find("85") then
        return "85mm PG-7V"
    end
    return nil
end

local function ScanGunVelocity()
    local character = LocalPlayer.Character
    if not character then return nil end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return nil end

    local caliber, ammoType = nil, nil

    -- Attributes
    for _, attr in ipairs(tool:GetAttributes()) do
        local lower = string.lower(attr)
        if lower:find("caliber") or lower:find("ammotype") or lower:find("ammo") then
            local val = tool:GetAttribute(attr)
            if type(val) == "string" then
                if lower:find("caliber") then caliber = val
                else ammoType = val end
            end
        end
    end

    -- Descendants (ValueBase + GUI Text)
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("ValueBase") then
            local lower = string.lower(d.Name)
            if lower:find("caliber") then caliber = tostring(d.Value)
            elseif lower:find("ammotype") or lower:find("ammo") then ammoType = tostring(d.Value) end
        elseif d:IsA("TextLabel") or d:IsA("TextButton") then
            local text = d.Text or ""
            local lower = string.lower(text)
            if lower:find("caliber") then
                local c = text:match("[:%s]+([%w%.]+)")
                if c then caliber = c end
            elseif lower:find("ammotype") or lower:find("ammo") then
                local a = text:match("[:%s]+([%w%.]+)")
                if a then ammoType = a end
            end
        end
    end

    -- Fallback: gun name → caliber
    if not caliber then
        local toolName = string.lower(tool.Name)
        for pattern, cal in pairs(GUN_CALIBER_MAP) do
            if toolName:find(pattern) then
                caliber = cal
                break
            end
        end
    end

    if not caliber then return nil end

    local key = GetAmmoKey(caliber, ammoType)
    if key and AMMO_VELOCITY[key] then
        return AMMO_VELOCITY[key]
    end
    return nil
end

local function UpdateBulletSpeed()
    local s = ScanGunVelocity()
    if s then
        CurrentBulletSpeed = s
        BulletSpeed = s
        return true
    end
    return false
end

local function CalculateBulletDrop(targetPos, speed, gravity)
    local myPos = Camera.CFrame.Position
    local dist = (targetPos - myPos).Magnitude
    if dist < 1 then return targetPos end
    local t = dist / speed
    local drop = 0.5 * gravity * t * t
    return targetPos + Vector3.new(0, drop, 0)
end

-- ==================== FULLBRIGHT ====================
local function SaveOriginalLighting()
    OriginalLighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        FogColor = Lighting.FogColor,
        ExposureCompensation = Lighting.ExposureCompensation,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
end

local function ApplyFullBright()
    SaveOriginalLighting()
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e6
    Lighting.FogStart = 1e6
    Lighting.FogColor = Color3.fromRGB(200, 200, 200)
    Lighting.ExposureCompensation = 0.5
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 1
end

local function RestoreLighting()
    if not OriginalLighting.Ambient then return end
    for k, v in pairs(OriginalLighting) do
        pcall(function() Lighting[k] = v end)
    end
end

-- ==================== GRASS / LEAVES REMOVER ====================
local GRASS_KEYWORDS = {"grass", "foliage", "bush", "shrub", "plant"}
local LEAVES_KEYWORDS = {"leaf", "leaves", "tree", "branch", "pine", "oak", "canopy"}

local function NameMatches(name, keywords)
    local lower = string.lower(name)
    for _, kw in ipairs(keywords) do
        if lower:find(kw, 1, true) then return true end
    end
    return false
end

local function HideObject(obj, tag)
    if HiddenObjects[obj] then return end
    local store = {}
    if obj:IsA("BasePart") then
        store.Transparency = obj.Transparency
        store.CanCollide = obj.CanCollide
        store.CanQuery = obj.CanQuery
        store.CanTouch = obj.CanTouch
        pcall(function() obj.Transparency = 1 end)
        pcall(function() obj.CanCollide = false end)
        pcall(function() obj.CanQuery = false end)
        pcall(function() obj.CanTouch = false end)
    elseif obj:IsA("Model") then
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("BasePart") then
                store[d] = { Transparency = d.Transparency, CanCollide = d.CanCollide }
                pcall(function() d.Transparency = 1 end)
                pcall(function() d.CanCollide = false end)
            end
        end
    end
    HiddenObjects[obj] = { store = store, tag = tag }
end

local function ShowObject(obj)
    local data = HiddenObjects[obj]
    if not data then return end
    if obj:IsA("BasePart") then
        pcall(function() obj.Transparency = data.store.Transparency end)
        pcall(function() obj.CanCollide = data.store.CanCollide end)
        pcall(function() obj.CanQuery = data.store.CanQuery end)
        pcall(function() obj.CanTouch = data.store.CanTouch end)
    elseif obj:IsA("Model") then
        for part, s in pairs(data.store) do
            if part and part.Parent then
                pcall(function() part.Transparency = s.Transparency end)
                pcall(function() part.CanCollide = s.CanCollide end)
            end
        end
    end
    HiddenObjects[obj] = nil
end

local function ScanWorldFor(tag, keywords)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            if NameMatches(obj.Name, keywords) then
                HideObject(obj, tag)
            end
        end
    end
end

local function RemoveAllGrass()
    ScanWorldFor("grass", GRASS_KEYWORDS)
end

local function RemoveAllLeaves()
    ScanWorldFor("leaves", LEAVES_KEYWORDS)
end

local function RestoreAllHidden()
    local list = {}
    for obj in pairs(HiddenObjects) do table.insert(list, obj) end
    for _, obj in ipairs(list) do ShowObject(obj) end
end

-- ==================== TARGET ACQUISITION ====================
local function GetClosestTarget()
    local closest, shortest = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local d = (root.Position - Camera.CFrame.Position).Magnitude
        if d > MaxDistance then continue end
        local sp, on = Camera:WorldToViewportPoint(root.Position)
        if not on then continue end
        local dm = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
        if dm < FOV and dm < shortest then shortest = dm; closest = char end
    end

    if TargetNPCEnabled then
        for _, npc in ipairs(Workspace:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and npc:FindFirstChild("Head") then
                if IsNPC(npc) then
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
                        if root then
                            local d = (root.Position - Camera.CFrame.Position).Magnitude
                            if d > MaxDistance then continue end
                            local sp, on = Camera:WorldToViewportPoint(root.Position)
                            if not on then continue end
                            local dm = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                            if dm < FOV and dm < shortest then shortest = dm; closest = npc end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function AimAt(target)
    if not target then return end
    local part = GetTargetPart(target, TargetPart)
    if not part then return end
    local targetPos = part.Position
    if PredictionEnabled then
        local spd = CurrentBulletSpeed or BulletSpeed
        targetPos = CalculateBulletDrop(targetPos, spd, BulletGravity)
    end
    local cur = Camera.CFrame
    local new = CFrame.new(cur.Position, targetPos)
    Camera.CFrame = cur:Lerp(new, Smoothness)
end

-- ==================== ESP ====================
local function CreateESP(character)
    if not character or ESPObjects[character] then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ETX_ESP"
    bb.Size = UDim2.new(0, 160, 0, 62)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local hpBg = Instance.new("Frame")
    hpBg.Name = "HPBg"
    hpBg.Size = UDim2.new(0, HPBarWidth, 0, 5)
    hpBg.Position = UDim2.new(0.5, -HPBarWidth/2, 0, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    hpBg.BorderSizePixel = 1
    hpBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    hpBg.Visible = HPBarEnabled
    hpBg.Parent = bb

    local hpFill = Instance.new("Frame")
    hpFill.Name = "HPFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = HPColorHigh
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0, 16)
    nl.Position = UDim2.new(0, 0, 0, 7)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = ESPColor
    nl.TextStrokeTransparency = 0.2
    nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nl.TextSize = 15
    nl.Font = Enum.Font.SourceSansBold
    nl.Text = "Unknown"
    nl.Parent = bb

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0, 14)
    dl.Position = UDim2.new(0, 0, 0, 24)
    dl.BackgroundTransparency = 1
    dl.TextColor3 = ESPColor
    dl.TextStrokeTransparency = 0.2
    dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    dl.TextSize = 13
    dl.Font = Enum.Font.SourceSansBold
    dl.Text = "[0m]"
    dl.Parent = bb

    local hpText = Instance.new("TextLabel")
    hpText.Name = "HPText"
    hpText.Size = UDim2.new(1, 0, 0, 13)
    hpText.Position = UDim2.new(0, 0, 0, 39)
    hpText.BackgroundTransparency = 1
    hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpText.TextStrokeTransparency = 0.3
    hpText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    hpText.TextSize = 12
    hpText.Font = Enum.Font.SourceSansBold
    hpText.Text = "100%"
    hpText.Visible = HPBarEnabled
    hpText.Parent = bb

    local hl = Instance.new("Highlight")
    hl.Name = "ETX_Highlight"
    hl.FillColor = ESPColor
    hl.FillTransparency = ESPTransparency
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.5
    hl.Adornee = character
    hl.Parent = character

    ESPObjects[character] = {
        Billboard = bb, NameLabel = nl, DistLabel = dl,
        HPBg = hpBg, HPFill = hpFill, HPText = hpText,
        Highlight = hl, Character = character
    }
end

local function RemoveESP(character)
    local d = ESPObjects[character]
    if d then
        if d.Billboard then d.Billboard:Destroy() end
        if d.Highlight then d.Highlight:Destroy() end
        ESPObjects[character] = nil
    end
end

local function UpdateESP()
    if not ESPEnabled then
        for c in pairs(ESPObjects) do RemoveESP(c) end
        ClearAllSkeletons()
        ClearAllHats()
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then CreateESP(plr.Character) end
    end
    for _, npc in ipairs(Workspace:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and npc:FindFirstChild("Head") then
            if IsNPC(npc) then CreateESP(npc) end
        end
    end

    for char, data in pairs(ESPObjects) do
        if not char or not char.Parent then RemoveESP(char); continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")

        if root and data.Billboard then
            local d = (root.Position - Camera.CFrame.Position).Magnitude
            if d > MaxDistance then
                data.Billboard.Enabled = false
                if data.Highlight then data.Highlight.Enabled = false end
            else
                data.Billboard.Enabled = true
                if data.Highlight then data.Highlight.Enabled = true end
                data.DistLabel.Text = "[" .. math.floor(d) .. "m]"
                local plr = Players:GetPlayerFromCharacter(char)
                data.NameLabel.Text = plr and plr.Name or (char.Name .. " (NPC)")

                if hum and data.HPFill then
                    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    data.HPFill.Size = UDim2.new(pct, 0, 1, 0)
                    data.HPText.Text = math.floor(pct * 100) .. "%"
                    if pct > 0.6 then
                        data.HPFill.BackgroundColor3 = HPColorHigh
                    elseif pct > 0.3 then
                        data.HPFill.BackgroundColor3 = HPColorMid
                    else
                        data.HPFill.BackgroundColor3 = HPColorLow
                    end
                    data.HPBg.Visible = HPBarEnabled
                    data.HPText.Visible = HPBarEnabled
                end
            end
        end
    end
end

-- ==================== VEHICLE ESP ====================
local function NameMatchesVehicle(name)
    local lower = string.lower(name)
    for _, kw in ipairs(VEHICLE_KEYWORDS) do
        if lower:find(kw, 1, true) then return true end
    end
    return false
end

local function IsVehicle(model)
    if not model or not model:IsA("Model") then return false end
    if model:FindFirstChildOfClass("Humanoid") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if NameMatchesVehicle(model.Name) then return true end
    local hasSeat = model:FindFirstChildWhichIsA("VehicleSeat") or model:FindFirstChildWhichIsA("Seat")
    if hasSeat then return true end
    return false
end

local function CreateVehicleESP(model)
    if VehicleObjects[model] then return end
    local anchor = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not anchor then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ETX_VehicleESP"
    bb.Size = UDim2.new(0, 180, 0, 40)
    bb.StudsOffset = Vector3.new(0, 6, 0)
    bb.AlwaysOnTop = true
    bb.Parent = anchor

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = VehicleESPColor
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextSize = 15
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Text = model.Name
    nameLabel.Parent = bb

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Position = UDim2.new(0, 0, 0, 18)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = VehicleESPColor
    distLabel.TextStrokeTransparency = 0.2
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.TextSize = 13
    distLabel.Font = Enum.Font.SourceSans
    distLabel.Text = "[0m]"
    distLabel.Parent = bb

    local hl = Instance.new("Highlight")
    hl.Name = "ETX_VehicleHighlight"
    hl.FillColor = VehicleESPColor
    hl.FillTransparency = VehicleESPTransparency
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.5
    hl.Adornee = model
    hl.Parent = model

    VehicleObjects[model] = {
        Billboard = bb, NameLabel = nameLabel,
        DistLabel = distLabel, Highlight = hl,
        Model = model, Anchor = anchor
    }
end

local function RemoveVehicleESP(model)
    local d = VehicleObjects[model]
    if d then
        if d.Billboard then d.Billboard:Destroy() end
        if d.Highlight then d.Highlight:Destroy() end
        VehicleObjects[model] = nil
    end
end

local function UpdateVehicleESP()
    if not VehicleESPEnabled or not ESPEnabled then
        for m in pairs(VehicleObjects) do RemoveVehicleESP(m) end
        return
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and IsVehicle(obj) then
            CreateVehicleESP(obj)
        end
    end

    for model, data in pairs(VehicleObjects) do
        if not model or not model.Parent then RemoveVehicleESP(model); continue end
        local anchor = model.PrimaryPart or data.Anchor
        if anchor and anchor.Parent and data.Billboard then
            local d = (anchor.Position - Camera.CFrame.Position).Magnitude
            if d > MaxDistance then
                data.Billboard.Enabled = false
                data.Highlight.Enabled = false
            else
                data.Billboard.Enabled = true
                data.Highlight.Enabled = true
                data.Billboard.Adornee = anchor
                data.DistLabel.Text = "[" .. math.floor(d) .. "m]"
                data.NameLabel.Text = model.Name
                data.NameLabel.TextColor3 = VehicleESPColor
                data.DistLabel.TextColor3 = VehicleESPColor
                data.Highlight.FillColor = VehicleESPColor
                data.Highlight.FillTransparency = VehicleESPTransparency
            end
        end
    end
end

-- ==================== SKELETON ====================
local SKELETON_R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local SKELETON_R6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local function GetBoneList(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum and hum.RigType == Enum.HumanoidRigType.R15 then return SKELETON_R15 end
    return SKELETON_R6
end

local function CreateSkeleton(character)
    if SkeletonObjects[character] then return end
    local bones = GetBoneList(character)
    local lines = {}
    for _ = 1, #bones do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = SkeletonColor
        line.Thickness = SkeletonThickness
        line.Transparency = 1
        table.insert(lines, line)
    end
    SkeletonObjects[character] = {Lines = lines, Bones = bones}
end

local function RemoveSkeleton(character)
    local data = SkeletonObjects[character]
    if data then
        for _, l in ipairs(data.Lines) do l:Remove() end
        SkeletonObjects[character] = nil
    end
end

local function UpdateSkeleton(character)
    local data = SkeletonObjects[character]
    if not data then return end
    if not character.Parent then RemoveSkeleton(character); return end
    for i, bone in ipairs(data.Bones) do
        local a = character:FindFirstChild(bone[1])
        local b = character:FindFirstChild(bone[2])
        local line = data.Lines[i]
        if a and b then
            local ap = a.Position + Vector3.new(0, (a.Size.Y/2 - 0.3) * (bone[1] == "Head" and -1 or 0), 0)
            local bp = b.Position + Vector3.new(0, (b.Size.Y/2 - 0.3), 0)
            local a2d, aOn = Camera:WorldToViewportPoint(ap)
            local b2d, bOn = Camera:WorldToViewportPoint(bp)
            if aOn and bOn then
                line.From = Vector2.new(a2d.X, a2d.Y)
                line.To = Vector2.new(b2d.X, b2d.Y)
                line.Color = SkeletonColor
                line.Thickness = SkeletonThickness
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

local function ClearAllSkeletons()
    for c in pairs(SkeletonObjects) do RemoveSkeleton(c) end
end

-- ==================== CHINA HAT ====================
local CONE_MESH_ID = "rbxassetid://1033714"

local function CreateChinaHat(character)
    if ChinaHatObjects[character] then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local hat = Instance.new("Part")
    hat.Name = "ETX_ChinaHat"
    hat.Shape = Enum.PartType.Cylinder
    hat.Size = Vector3.new(2, 2.4, 2.4) * ChinaHatScale
    hat.Anchored = true
    hat.CanCollide = false
    hat.CanQuery = false
    hat.CanTouch = false
    hat.Massless = true
    hat.CastShadow = false
    hat.Material = Enum.Material.SmoothPlastic
    hat.Color = ChinaHatColor
    hat.Transparency = 0.05

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = CONE_MESH_ID
    mesh.Scale = Vector3.new(ChinaHatScale, ChinaHatScale, ChinaHatScale)
    mesh.Parent = hat

    hat.Parent = Workspace
    ChinaHatObjects[character] = hat
end

local function UpdateChinaHat(character)
    local hat = ChinaHatObjects[character]
    if not hat then return end
    if not character.Parent then
        hat:Destroy(); ChinaHatObjects[character] = nil; return
    end
    local head = character:FindFirstChild("Head")
    if not head then hat.Transparency = 1; return end
    hat.Transparency = 0.05
    hat.Color = ChinaHatColor
    hat.CFrame = head.CFrame * CFrame.new(0, head.Size.Y/2 + (2.5 * ChinaHatScale), 0)
        * CFrame.Angles(0, 0, math.rad(90))
end

local function RemoveChinaHat(character)
    local hat = ChinaHatObjects[character]
    if hat then hat:Destroy(); ChinaHatObjects[character] = nil end
end

local function ClearAllHats()
    for c in pairs(ChinaHatObjects) do RemoveChinaHat(c) end
end

-- ==================== INVISIBLE / MOD CHECK ====================
local function PartIsVisible(p)
    if p.Transparency < INVIS_THRESHOLD then return true end
    local ltm = p.LocalTransparencyModifier
    if ltm and ltm < INVIS_THRESHOLD then return true end
    return false
end

local function IsFullyInvisible(character)
    if not character then return false end
    local hasAny = false
    for _, d in ipairs(character:GetDescendants()) do
        if d:IsA("BasePart") then
            hasAny = true
            if PartIsVisible(d) then return false end
        elseif d:IsA("Decal") or d:IsA("Texture") then
            if d.Transparency < INVIS_THRESHOLD then return false end
        elseif d:IsA("Accessory") then
            local handle = d:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") and PartIsVisible(handle) then return false end
        elseif d:IsA("Shirt") or d:IsA("Pants") then
            return false
        end
    end
    if not hasAny then return false end
    return true
end

local function EvaluateVisibility(character)
    if not InvisibleAlertEnabled or not character then return false end
    local plr = Players:GetPlayerFromCharacter(character)
    local name = plr and plr.Name or (character.Name .. " (NPC)")

    local invis = IsFullyInvisible(character)

    if invis then
        InvisCounter[name] = (InvisCounter[name] or 0) + 1
    else
        InvisCounter[name] = 0
        if Flagged[name] then
            Flagged[name] = nil
            local data = ESPObjects[character]
            if data and data.Highlight then
                data.Highlight.FillColor = ESPColor
                data.Highlight.FillTransparency = ESPTransparency
            end
        end
    end

    if InvisCounter[name] >= FLAG_CONSECUTIVE_FRAMES and not Flagged[name] then
        Flagged[name] = true
        Rayfield:Notify({
            Title = "⚠ MODERATOR DETECTED",
            Content = name .. " — model tàng hình",
            Duration = 10,
        })
        local data = ESPObjects[character]
        if data and data.Highlight then
            data.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
            data.Highlight.FillTransparency = 0.1
        end
    end
    return invis
end

local function CheckModerator(player)
    if not ModeratorAlertEnabled then return false end
    for _, gid in ipairs(MOD_GROUP_IDS) do
        local ok, rank = pcall(function() return player:GetRankInGroup(gid) end)
        if ok and rank and rank >= 200 then return true end
    end
    local lower = string.lower(player.Name)
    for _, kw in ipairs(MOD_KEYWORDS) do
        if lower:find(kw) then return true end
    end
    local dn = string.lower(player.DisplayName or "")
    for _, kw in ipairs(MOD_KEYWORDS) do
        if dn:find(kw) then return true end
    end
    return false
end

local function ScanForModerators(notify)
    local found = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and CheckModerator(plr) then table.insert(found, plr.Name) end
    end
    if notify and #found > 0 then
        Rayfield:Notify({Title = "⚠ MODERATOR", Content = table.concat(found, ", "), Duration = 8})
    end
    return found
end

Players.PlayerAdded:Connect(function(plr)
    task.wait(1)
    if CheckModerator(plr) then
        Rayfield:Notify({Title = "⚠ MODERATOR JOINED", Content = plr.Name, Duration = 8})
    end
end)

-- ==================== TARGET PREVIEW ====================
local function SafeClone(character)
    local states = {}
    local targets = {character}
    for _, d in ipairs(character:GetDescendants()) do
        if d:IsA("BasePart") or d:IsA("Model") or d:IsA("Accessory") or d:IsA("Decal") or d:IsA("Shirt") or d:IsA("Pants") then
            table.insert(targets, d)
        end
    end
    for _, d in ipairs(targets) do
        states[d] = d.Archivable
        pcall(function() d.Archivable = true end)
    end

    local ok, clone = pcall(function() return character:Clone() end)

    for d, s in pairs(states) do
        if d and d.Parent then pcall(function() d.Archivable = s end) end
    end

    if not ok or not clone then return nil end
    return clone
end

local function CreatePreviewFrame()
    if PreviewFrame then return end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ETX_PreviewGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Name = "PreviewFrame"
    frame.Size = PreviewSize
    frame.Position = PreviewPos
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = false
    frame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 0)
    stroke.Thickness = 1
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.TextSize = 13
    title.Font = Enum.Font.SourceSansBold
    title.Text = "No target"
    title.Parent = frame

    local vp = Instance.new("ViewportFrame")
    vp.Name = "Viewport"
    vp.Size = UDim2.new(1, -8, 1, -28)
    vp.Position = UDim2.new(0, 4, 0, 24)
    vp.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    vp.BackgroundTransparency = 0.5
    vp.Ambient = Color3.fromRGB(180, 180, 180)
    vp.LightColor = Color3.fromRGB(255, 255, 255)
    vp.Parent = frame

    local world = Instance.new("WorldModel")
    world.Parent = vp

    local cam = Instance.new("Camera")
    cam.FieldOfView = 30
    vp.CurrentCamera = cam

    PreviewFrame = frame
    PreviewWorld = world
    PreviewCam = cam

    local dragging = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

local function ClearPreview()
    if not PreviewWorld then return end
    for _, c in ipairs(PreviewWorld:GetChildren()) do
        if c:IsA("Model") then c:Destroy() end
    end
    PreviewTarget = nil
    if PreviewFrame then
        PreviewFrame.Title.Text = "No target"
        PreviewFrame.UIStroke.Color = Color3.fromRGB(0, 255, 0)
        PreviewFrame.Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end

local function SetPreviewTarget(character)
    if not PreviewWorld then return end
    if PreviewTarget == character then return end
    ClearPreview()
    if not character then return end

    local clone = SafeClone(character)
    if not clone then
        clone = Instance.new("Model")
        clone.Name = character.Name .. "_Preview"
        for _, d in ipairs(character:GetDescendants()) do
            if d:IsA("BasePart") then
                local ok, p = pcall(function() return d:Clone() end)
                if ok and p then
                    p.Anchored = false
                    p.CanCollide = false
                    p.CanQuery = false
                    p.CanTouch = false
                    p.Parent = clone
                end
            elseif d:IsA("Accessory") or d:IsA("Shirt") or d:IsA("Pants") then
                local ok, a = pcall(function() return d:Clone() end)
                if ok and a then a.Parent = clone end
            end
        end
        local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head") or character:FindFirstChildWhichIsA("BasePart")
        if root then
            clone.PrimaryPart = clone:FindFirstChild(root.Name) or clone:FindFirstChildWhichIsA("BasePart")
        end
    else
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("BasePart") then
                pcall(function() d.Anchored = false end)
            end
        end
    end

    clone.Parent = PreviewWorld

    -- Giữ Humanoid + Animator cho animation
    local cloneHum = clone:FindFirstChildOfClass("Humanoid")
    if cloneHum then
        if not cloneHum:FindFirstChildOfClass("Animator") then
            local anim = Instance.new("Animator")
            anim.Parent = cloneHum
        end
        cloneHum.PlatformStand = true
    end

    local ok, center = pcall(function() return clone:GetPivot().Position end)
    if not ok or not center then center = Vector3.new(0, 0, 0) end
    local ok2, size = pcall(function() return clone:GetExtentsSize() end)
    if not ok2 or not size then size = Vector3.new(4, 6, 4) end
    local distance = math.max(size.X, size.Y, size.Z) * 2.2
    PreviewCam.CFrame = CFrame.new(center + Vector3.new(0, size.Y * 0.2, distance), center)

    PreviewTarget = character

    local plr = Players:GetPlayerFromCharacter(character)
    local name = plr and plr.Name or (character.Name .. " (NPC)")
    if PreviewFrame then
        PreviewFrame.Title.Text = name
        PreviewFrame.UIStroke.Color = Color3.fromRGB(0, 255, 0)
        PreviewFrame.Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end

-- ==================== PREVIEW ANIMATION SYNC ====================
local function SyncPreviewAnimation()
    if not PreviewTarget or not PreviewTarget.Parent then return end
    if not PreviewWorld then return end

    local clone = nil
    for _, c in ipairs(PreviewWorld:GetChildren()) do
        if c:IsA("Model") then clone = c; break end
    end
    if not clone then return end

    -- Đồng bộ Motor6D transform
    for _, origMotor in ipairs(PreviewTarget:GetDescendants()) do
        if origMotor:IsA("Motor6D") then
            local parentName = origMotor.Parent and origMotor.Parent.Name
            if parentName then
                local cloneParent = clone:FindFirstChild(parentName, true)
                if cloneParent then
                    local cloneMotor = cloneParent:FindFirstChild(origMotor.Name)
                    if cloneMotor and cloneMotor:IsA("Motor6D") then
                        pcall(function()
                            cloneMotor.C0 = origMotor.C0
                            cloneMotor.C1 = origMotor.C1
                            cloneMotor.Transform = origMotor.Transform
                        end)
                    end
                end
            end
        end
    end

    -- Đồng bộ animation tracks
    local origHum = PreviewTarget:FindFirstChildOfClass("Humanoid")
    local cloneHum = clone:FindFirstChildOfClass("Humanoid")
    if origHum and cloneHum then
        local origAnimator = origHum:FindFirstChildOfClass("Animator")
        local cloneAnimator = cloneHum:FindFirstChildOfClass("Animator")
        if origAnimator and cloneAnimator then
            local origTracks = origAnimator:GetPlayingAnimationTracks()
            local cloneTracks = cloneAnimator:GetPlayingAnimationTracks()

            local needReload = (#origTracks ~= #cloneTracks)
            if not needReload then
                for i, t in ipairs(origTracks) do
                    if not cloneTracks[i] or cloneTracks[i].Animation.AnimationId ~= t.Animation.AnimationId then
                        needReload = true
                        break
                    end
                end
            end

            if needReload then
                for _, t in ipairs(cloneTracks) do
                    pcall(function() t:Stop() end)
                end
                for _, t in ipairs(origTracks) do
                    local ok, newTrack = pcall(function()
                        return cloneAnimator:LoadAnimation(t.Animation)
                    end)
                    if ok and newTrack then
                        pcall(function()
                            newTrack.Priority = t.Priority
                            newTrack:Play(t.TimePosition)
                            newTrack:AdjustSpeed(t.Speed)
                        end)
                    end
                end
            else
                for i, t in ipairs(origTracks) do
                    local ct = cloneTracks[i]
                    if ct then
                        pcall(function()
                            local delta = math.abs(ct.TimePosition - t.TimePosition)
                            if delta > 0.05 then
                                ct.TimePosition = t.TimePosition
                            end
                            ct:AdjustSpeed(t.Speed)
                        end)
                    end
                end
            end
        end
    end
end

-- ==================== RENDER LOOP ====================
RunService:BindToRenderStep("ETX_Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if FOVCircle then
        FOVCircle.Visible = AimbotMaster
        FOVCircle.Radius = FOV
        local vp = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
        FOVCircle.Color = AimbotActive and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
    end

    local target = nil
    if AimbotMaster and AimbotActive then
        target = GetClosestTarget()
        if target then AimAt(target) end
    end

    if TargetLine then
        if AimbotMaster and TargetLineEnabled then
            local lineTarget = target or GetClosestTarget()
            if lineTarget then
                local part = GetTargetPart(lineTarget, TargetPart)
                if part then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local vp = Camera.ViewportSize
                        TargetLine.From = Vector2.new(vp.X / 2, vp.Y / 2)
                        TargetLine.To = Vector2.new(sp.X, sp.Y)
                        TargetLine.Visible = true
                    else TargetLine.Visible = false end
                end
            else TargetLine.Visible = false end
        else TargetLine.Visible = false end
    end

    if PreviewEnabled and PreviewFrame then
        local previewTarget = nil
        if AimbotMaster and TargetLineEnabled then
            previewTarget = target or GetClosestTarget()
        end
        SetPreviewTarget(previewTarget)
    end
end)

RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateVehicleESP()
    SyncPreviewAnimation()

    -- Tàng hình / mod check
    if InvisibleAlertEnabled then
        for char in pairs(ESPObjects) do
            if char.Parent then EvaluateVisibility(char) end
        end
        if AimbotMaster and TargetLineEnabled then
            local t = GetClosestTarget()
            if t then EvaluateVisibility(t) end
        end
    end

    -- Preview border
    if PreviewFrame and PreviewTarget and PreviewTarget.Parent then
        local plr = Players:GetPlayerFromCharacter(PreviewTarget)
        local name = plr and plr.Name or (PreviewTarget.Name .. " (NPC)")
        local isFlagged = Flagged[name]
        PreviewFrame.UIStroke.Color = isFlagged and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        PreviewFrame.Title.TextColor3 = isFlagged and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 0)
    end

    -- Skeleton
    if SkeletonEnabled and ESPEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                CreateSkeleton(plr.Character)
                UpdateSkeleton(plr.Character)
            end
        end
        for _, npc in ipairs(Workspace:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and npc:FindFirstChild("Head") then
                if IsNPC(npc) then
                    CreateSkeleton(npc)
                    UpdateSkeleton(npc)
                end
            end
        end
        for c in pairs(SkeletonObjects) do
            if not c.Parent then RemoveSkeleton(c) end
        end
    else
        ClearAllSkeletons()
    end

    -- China Hat
    if ChinaHatEnabled and ESPEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                CreateChinaHat(plr.Character)
                UpdateChinaHat(plr.Character)
            end
        end
        for _, npc in ipairs(Workspace:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and npc:FindFirstChild("Head") then
                if IsNPC(npc) then
                    CreateChinaHat(npc)
                    UpdateChinaHat(npc)
                end
            end
        end
        for c in pairs(ChinaHatObjects) do
            if not c.Parent then RemoveChinaHat(c) end
        end
    else
        ClearAllHats()
    end
end)

-- ==================== KEYBIND CAPTURE ====================
local function StartKeyCapture()
    if CapturingKey then return end
    CapturingKey = true
    Rayfield:Notify({Title = "ETX", Content = "Nhấn phím hoặc chuột để gán...", Duration = 3})
    if CaptureConn then CaptureConn:Disconnect() end
    CaptureConn = UserInputService.InputBegan:Connect(function(input)
        if not CapturingKey then return end
        local key = nil
        if input.UserInputType == Enum.UserInputType.Keyboard then key = input.KeyCode.Name:upper()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then key = "MOUSEBUTTON1"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then key = "MOUSEBUTTON2"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then key = "MOUSEBUTTON3" end
        if key then
            AimbotKeybind = key
            CapturingKey = false
            CaptureConn:Disconnect()
            Rayfield:Notify({Title = "ETX", Content = "Đã gán: " .. key, Duration = 3})
        end
    end)
    task.delay(5, function()
        if CapturingKey then
            CapturingKey = false
            if CaptureConn then CaptureConn:Disconnect() end
            Rayfield:Notify({Title = "ETX", Content = "Hết giờ gán phím.", Duration = 2})
        end
    end)
end

-- ==================== UI ====================
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateSection("Aimbot")
CombatTab:CreateToggle({Name = "Bật Aimbot (Master)", CurrentValue = false, Flag = "AimbotMaster",
    Callback = function(v) AimbotMaster = v; if not v then AimbotActive = false end end})
CombatTab:CreateDropdown({Name = "Chế độ Keybind", Options = {"Toggle", "Hold", "Always"},
    CurrentOption = "Toggle", Flag = "AimbotMode",
    Callback = function(opt)
        AimbotMode = opt
        if opt == "Always" then AimbotActive = true else AimbotActive = false end
    end})
CombatTab:CreateButton({Name = "Gán phím Aimbot", Callback = function() StartKeyCapture() end})
CombatTab:CreateSlider({Name = "FOV", Range = {10, 500}, Increment = 10, Suffix = "px",
    CurrentValue = 150, Flag = "FOV", Callback = function(v) FOV = v end})
CombatTab:CreateDropdown({Name = "Target Part", Options = {"Head", "Torso", "HumanoidRootPart"},
    CurrentOption = "Head", Flag = "TargetPart", Callback = function(o) TargetPart = o end})
CombatTab:CreateSlider({Name = "Smoothness", Range = {0.01, 1}, Increment = 0.01, Suffix = "",
    CurrentValue = 0.15, Flag = "Smoothness", Callback = function(v) Smoothness = v end})
CombatTab:CreateToggle({Name = "Hiện Targetline", CurrentValue = true, Flag = "TargetLine",
    Callback = function(v) TargetLineEnabled = v end})
CombatTab:CreateToggle({Name = "Target NPC (tắt khi PvP)", CurrentValue = false, Flag = "TargetNPC",
    Callback = function(v) TargetNPCEnabled = v end})

-- Prediction
local PredTab = Window:CreateTab("Prediction", 4483362458)
PredTab:CreateSection("Bullet Drop (Wiki-based)")
PredTab:CreateToggle({Name = "Bật Bullet Drop", CurrentValue = true, Flag = "PredToggle",
    Callback = function(v) PredictionEnabled = v end})
PredTab:CreateSlider({Name = "Tốc độ đạn thủ công (m/s)", Range = {100, 2000}, Increment = 1, Suffix = "m/s",
    CurrentValue = 715, Flag = "BulletSpeed", Callback = function(v) BulletSpeed = v end})
PredTab:CreateButton({Name = "Quét tốc độ đạn từ súng (Wiki)",
    Callback = function()
        local ok = UpdateBulletSpeed()
        if ok then
            Rayfield:Notify({Title = "ETX", Content = "Wiki scan: " .. CurrentBulletSpeed .. " m/s", Duration = 3})
        else
            Rayfield:Notify({Title = "ETX", Content = "Không match wiki, nhập tay.", Duration = 3})
        end
    end})
PredTab:CreateSlider({Name = "Trọng lực (studs/s²)", Range = {50, 500}, Increment = 10, Suffix = "studs/s²",
    CurrentValue = 196.2, Flag = "BulletGravity", Callback = function(v) BulletGravity = v end})

-- ESP
local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateSection("Visuals")
ESPTab:CreateToggle({Name = "Bật ESP", CurrentValue = false, Flag = "ESPToggle",
    Callback = function(v) ESPEnabled = v end})
ESPTab:CreateSlider({Name = "Khoảng cách tối đa (m)", Range = {100, 30000}, Increment = 100, Suffix = "m",
    CurrentValue = 5000, Flag = "MaxDistance", Callback = function(v) MaxDistance = v end})
ESPTab:CreateSlider({Name = "Độ trong suốt", Range = {0, 1}, Increment = 0.05, Suffix = "",
    CurrentValue = 0.5, Flag = "ESPTransparency",
    Callback = function(v)
        ESPTransparency = v
        for _, d in pairs(ESPObjects) do
            if d.Highlight then d.Highlight.FillTransparency = v end
        end
    end})
ESPTab:CreateColorPicker({Name = "Màu ESP", Color = Color3.fromRGB(0, 255, 0), Flag = "ESPColor",
    Callback = function(c)
        ESPColor = c
        for _, d in pairs(ESPObjects) do
            if d.NameLabel then d.NameLabel.TextColor3 = c end
            if d.DistLabel then d.DistLabel.TextColor3 = c end
            if d.Highlight then d.Highlight.FillColor = c end
        end
    end})

ESPTab:CreateSection("Health Bar")
ESPTab:CreateToggle({Name = "Hiện Health Bar %", CurrentValue = true, Flag = "HPBarToggle",
    Callback = function(v)
        HPBarEnabled = v
        for _, d in pairs(ESPObjects) do
            if d.HPBg then d.HPBg.Visible = v end
            if d.HPText then d.HPText.Visible = v end
        end
    end})
ESPTab:CreateSlider({Name = "Chiều rộng Health Bar", Range = {60, 240}, Increment = 10, Suffix = "px",
    CurrentValue = 120, Flag = "HPBarWidth",
    Callback = function(v)
        HPBarWidth = v
        for _, d in pairs(ESPObjects) do
            if d.HPBg then
                d.HPBg.Size = UDim2.new(0, v, 0, 5)
                d.HPBg.Position = UDim2.new(0.5, -v/2, 0, 0)
            end
        end
    end})

ESPTab:CreateSection("Skeleton")
ESPTab:CreateToggle({Name = "Bật Skeleton", CurrentValue = true, Flag = "SkeletonToggle",
    Callback = function(v) SkeletonEnabled = v; if not v then ClearAllSkeletons() end end})
ESPTab:CreateSlider({Name = "Độ dày Skeleton", Range = {1, 4}, Increment = 1, Suffix = "px",
    CurrentValue = 1, Flag = "SkelThick", Callback = function(v) SkeletonThickness = v end})
ESPTab:CreateColorPicker({Name = "Màu Skeleton", Color = Color3.fromRGB(255, 255, 255), Flag = "SkelColor",
    Callback = function(c) SkeletonColor = c end})

ESPTab:CreateSection("China Hat")
ESPTab:CreateToggle({Name = "Bật China Hat", CurrentValue = true, Flag = "HatToggle",
    Callback = function(v) ChinaHatEnabled = v; if not v then ClearAllHats() end end})
ESPTab:CreateSlider({Name = "Scale Hat", Range = {0.5, 3}, Increment = 0.1, Suffix = "x",
    CurrentValue = 1, Flag = "HatScale",
    Callback = function(v)
        ChinaHatScale = v
        for _, hat in pairs(ChinaHatObjects) do
            hat.Size = Vector3.new(2, 2.4, 2.4) * v
            local m = hat:FindFirstChildOfClass("SpecialMesh")
            if m then m.Scale = Vector3.new(v, v, v) end
        end
    end})
ESPTab:CreateColorPicker({Name = "Màu China Hat", Color = Color3.fromRGB(220, 30, 30), Flag = "HatColor",
    Callback = function(c) ChinaHatColor = c end})

ESPTab:CreateSection("Vehicle / Aircraft")
ESPTab:CreateToggle({Name = "Bật ESP Vehicle (MI-24V, Heli)", CurrentValue = true, Flag = "VehicleESPToggle",
    Callback = function(v)
        VehicleESPEnabled = v
        if not v then
            for m in pairs(VehicleObjects) do RemoveVehicleESP(m) end
        end
    end})
ESPTab:CreateSlider({Name = "Độ trong suốt Vehicle", Range = {0, 1}, Increment = 0.05, Suffix = "",
    CurrentValue = 0.5, Flag = "VehicleTrans",
    Callback = function(v)
        VehicleESPTransparency = v
        for _, d in pairs(VehicleObjects) do
            if d.Highlight then d.Highlight.FillTransparency = v end
        end
    end})
ESPTab:CreateColorPicker({Name = "Màu Vehicle ESP", Color = Color3.fromRGB(0, 200, 255), Flag = "VehicleColor",
    Callback = function(c)
        VehicleESPColor = c
        for _, d in pairs(VehicleObjects) do
            if d.NameLabel then d.NameLabel.TextColor3 = c end
            if d.DistLabel then d.DistLabel.TextColor3 = c end
            if d.Highlight then d.Highlight.FillColor = c end
        end
    end})

-- Visuals / Map
local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateSection("Lighting")
VisualTab:CreateToggle({Name = "FullBright toàn map", CurrentValue = false, Flag = "FullBright",
    Callback = function(v)
        FullBrightEnabled = v
        if v then ApplyFullBright() else RestoreLighting() end
    end})
VisualTab:CreateButton({Name = "Reset Lighting",
    Callback = function()
        FullBrightEnabled = false
        RestoreLighting()
    end})

VisualTab:CreateSection("Map Cleanup")
VisualTab:CreateToggle({Name = "Xóa cỏ (Grass)", CurrentValue = false, Flag = "GrassRemove",
    Callback = function(v)
        GrassRemoverEnabled = v
        if v then RemoveAllGrass()
        else
            -- Gỡ cỏ đã ẩn
            local list = {}
            for obj, data in pairs(HiddenObjects) do
                if data.tag == "grass" then table.insert(list, obj) end
            end
            for _, obj in ipairs(list) do ShowObject(obj) end
        end
    end})
VisualTab:CreateToggle({Name = "Xóa lá cây (Leaves/Trees)", CurrentValue = false, Flag = "LeavesRemove",
    Callback = function(v)
        LeavesRemoverEnabled = v
        if v then RemoveAllLeaves()
        else
            local list = {}
            for obj, data in pairs(HiddenObjects) do
                if data.tag == "leaves" then table.insert(list, obj) end
            end
            for _, obj in ipairs(list) do ShowObject(obj) end
        end
    end})
VisualTab:CreateButton({Name = "Khôi phục toàn bộ map",
    Callback = function()
        RestoreAllHidden()
        GrassRemoverEnabled = false
        LeavesRemoverEnabled = false
        Rayfield:Notify({Title = "ETX", Content = "Đã khôi phục map.", Duration = 3})
    end})

-- Preview
local PrevTab = Window:CreateTab("Preview", 4483362458)
PrevTab:CreateSection("Target Preview")
PrevTab:CreateToggle({Name = "Bật Preview 3D mục tiêu", CurrentValue = true, Flag = "PreviewToggle",
    Callback = function(v)
        PreviewEnabled = v
        if PreviewFrame then PreviewFrame.Visible = v end
        if not v then ClearPreview() end
    end})
PrevTab:CreateButton({Name = "Reset vị trí Preview",
    Callback = function()
        if PreviewFrame then PreviewFrame.Position = UDim2.new(0, 20, 1, -220) end
    end})

-- Security
local SecTab = Window:CreateTab("Security", 4483362458)
SecTab:CreateSection("Moderator / Ghost")
SecTab:CreateToggle({Name = "Cảnh báo Moderator", CurrentValue = true, Flag = "ModAlert",
    Callback = function(v) ModeratorAlertEnabled = v end})
SecTab:CreateToggle({Name = "Cảnh báo mục tiêu tàng hình", CurrentValue = true, Flag = "InvisAlert",
    Callback = function(v)
        InvisibleAlertEnabled = v
        if not v then
            for k in pairs(InvisCounter) do InvisCounter[k] = nil end
            for k in pairs(Flagged) do Flagged[k] = nil end
            for _, d in pairs(ESPObjects) do
                if d.Highlight then
                    d.Highlight.FillColor = ESPColor
                    d.Highlight.FillTransparency = ESPTransparency
                end
            end
        end
    end})
SecTab:CreateSlider({Name = "Ngưỡng frame tàng hình", Range = {1, 60}, Increment = 1, Suffix = "f",
    CurrentValue = 1, Flag = "InvisFrames",
    Callback = function(v) FLAG_CONSECUTIVE_FRAMES = v end})
SecTab:CreateButton({Name = "Quét Moderator server",
    Callback = function()
        local found = ScanForModerators(true)
        if #found == 0 then
            Rayfield:Notify({Title = "ETX", Content = "Không có moderator.", Duration = 3})
        end
    end})

-- Settings
local SetTab = Window:CreateTab("Settings", 4483362458)
SetTab:CreateButton({Name = "Xóa tất cả visuals",
    Callback = function()
        for c in pairs(ESPObjects) do RemoveESP(c) end
        for m in pairs(VehicleObjects) do RemoveVehicleESP(m) end
        ClearAllSkeletons()
        ClearAllHats()
        Rayfield:Notify({Title = "ETX", Content = "Đã xóa toàn bộ visuals.", Duration = 3})
    end})
SetTab:CreateButton({Name = "Reset UI", Callback = function() Rayfield:Destroy() end})

-- ==================== INPUT HANDLER ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if CapturingKey then return end
    if gp and input.UserInputType == Enum.UserInputType.Keyboard then return end
    if InputMatches(input) then
        if AimbotMode == "Toggle" then AimbotActive = not AimbotActive
        elseif AimbotMode == "Hold" then AimbotActive = true end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if CapturingKey then return end
    if InputMatches(input) then
        if AimbotMode == "Hold" then AimbotActive = false end
    end
end)

-- ==================== GUN WATCH ====================
local function HookChar(char)
    task.wait(1)
    if UpdateBulletSpeed() then
        Rayfield:Notify({Title = "ETX | Wiki scan", Content = CurrentBulletSpeed .. " m/s", Duration = 2})
    end
    char.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then
            task.wait(0.3)
            if UpdateBulletSpeed() then
                Rayfield:Notify({Title = "ETX | Wiki scan", Content = CurrentBulletSpeed .. " m/s", Duration = 2})
            end
        end
    end)
    char.ChildRemoved:Connect(function(c)
        if c:IsA("Tool") then CurrentBulletSpeed = nil end
    end)
end
LocalPlayer.CharacterAdded:Connect(HookChar)
if LocalPlayer.Character then HookChar(LocalPlayer.Character) end

-- ==================== INIT ====================
CreatePreviewFrame()
task.spawn(function() task.wait(3); ScanForModerators(true) end)

Rayfield:Notify({
    Title = "ETX v1.3 loaded",
    Content = "Wiki bullet drop + Preview animation + FullBright + Map cleanup.",
    Duration = 6,
})

print("[ETX v1.3] Project Delta loaded.")
