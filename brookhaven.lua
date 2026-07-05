--[[
    Brookhaven RP Hub | Rayfield UI
    Speed / Fly / Noclip / Infinite Jump / Teleports / Invisible / Anti AFK
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
    Name = "Brookhaven Hub",
    LoadingTitle = "Brookhaven Hub",
    LoadingSubtitle = "Enjoy!",
    Theme = "Default",
    ConfigurationSaving = { Enabled = false }
})

local State = {
    WalkSpeed = 16,
    SpeedEnabled = false,
    Fly = false,
    FlySpeed = 60,
    Noclip = false,
    InfJump = false,
    Invisible = false,
}

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function getRoot() return getChar():FindFirstChild("HumanoidRootPart") end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end

-- ================= Speed =================
RunService.Heartbeat:Connect(function()
    if State.SpeedEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= State.WalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end
    end
end)

-- ================= Fly =================
local flyBV, flyBG
local flyConn

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local hum = getHum()
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end
    hum.PlatformStand = true

    flyBG = Instance.new("BodyGyro")
    flyBG.P = 9e4
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root

    flyBV = Instance.new("BodyVelocity")
    flyBV.Velocity = Vector3.zero
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Parent = root

    flyConn = RunService.RenderStepped:Connect(function()
        if not State.Fly then stopFly() return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end)
end

-- ================= Noclip =================
RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ================= Infinite Jump =================
UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ================= Invisible (local) =================
local savedTransparency = {}
local function setInvisible(on)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            if on then
                savedTransparency[part] = part.Transparency
                part.Transparency = 1
            elseif savedTransparency[part] ~= nil then
                part.Transparency = savedTransparency[part]
            end
        end
    end
    if not on then table.clear(savedTransparency) end
end

-- ================= Brookhaven Locations =================
local Locations = {
    ["Spawn"]        = Vector3.new(24, 13, -184),
    ["School"]       = Vector3.new(198, 20, -352),
    ["Hospital"]     = Vector3.new(324, 21, -71),
    ["Police Station"]= Vector3.new(-190, 18, -101),
    ["Grocery Store"]= Vector3.new(-247, 13, -287),
    ["Gas Station"]  = Vector3.new(-119, 13, -354),
    ["Church"]       = Vector3.new(120, 18, 128),
    ["Airport"]      = Vector3.new(105, 19, -650),
    ["Beach House"]  = Vector3.new(430, 13, -320),
}

local function teleportTo(pos)
    local root = getRoot()
    if root then root.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0)) end
end

-- ================= UI =================
local MovementTab = Window:CreateTab("Movement", 4483362458)

MovementTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(Value)
        State.SpeedEnabled = Value
        if not Value then
            local hum = getHum()
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value) State.WalkSpeed = Value end
})

MovementTab:CreateToggle({
    Name = "Fly (WASD + Space/Ctrl)",
    CurrentValue = false,
    Callback = function(Value)
        State.Fly = Value
        if Value then startFly() else stopFly() end
    end
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 5,
    CurrentValue = 60,
    Callback = function(Value) State.FlySpeed = Value end
})

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value) State.Noclip = Value end
})

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value) State.InfJump = Value end
})

local TPTab = Window:CreateTab("Teleports", 4483362458)

for name, pos in pairs(Locations) do
    TPTab:CreateButton({
        Name = "Teleport: " .. name,
        Callback = function() teleportTo(pos) end
    })
end

TPTab:CreateButton({
    Name = "Teleport to Player (nearest)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        local nearest, dist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local r = plr.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = (r.Position - root.Position).Magnitude
                    if d < dist then nearest, dist = r, d end
                end
            end
        end
        if nearest then root.CFrame = nearest.CFrame + Vector3.new(0, 3, 0) end
    end
})

local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateToggle({
    Name = "Invisible (Local)",
    CurrentValue = false,
    Callback = function(Value)
        State.Invisible = Value
        setInvisible(Value)
    end
})

MiscTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local hum = getHum()
        if hum then hum.Health = 0 end
    end
})

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Reapply on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if State.Fly then startFly() end
    if State.Invisible then setInvisible(true) end
end)

Rayfield:Notify({Title = "Brookhaven Hub", Content = "Loaded successfully!", Duration = 4})
