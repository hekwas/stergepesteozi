local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local isActive, pulseMode, blinkMode = false, false, false
local power, pulseInterval = 400, 5
local targets = {}

-- ========== STEALTH BYPASS: AUTO-SCANNER & PAYLOAD ==========
local function ScanForRemotes()
    local found = {}
    local potential = {"Packages/Synchronizer/RequestData", "RF/ValentinesShopService/SearchUser", "RE/PlotService/CashCollected"}
    for _, path in pairs(potential) do
        local r = ReplicatedStorage:FindFirstChild(path, true)
        if r then table.insert(found, r) end
    end
    targets = found
end
task.spawn(function() while true do ScanForRemotes() task.wait(60) end end)

-- Generăm pachete mici (Bypass pentru Network Limit)
local function GetStealthPayload()
    return {
        ["ID"] = HttpService:GenerateGUID(false):sub(1,4),
        ["Val"] = math.random(1, 1000),
        ["T"] = tick()
    }
end

-- ========== UI DESIGN NEBULA STEALTH V70 ==========
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "Nebula_Stealth"

local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 360, 0, 560), UDim2.new(0.5, -180, 0.25, 0)
Main.BackgroundColor3, Main.BorderSizePixel = Color3.fromRGB(12, 12, 18), 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
local Glow = Instance.new("UIStroke", Main)
Glow.Color, Glow.Thickness = Color3.fromRGB(150, 0, 255), 2

-- Dragging System
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.Text = UDim2.new(1, 0, 0, 55), "  NEBULA STEALTH V70"
Title.TextColor3, Title.Font = Color3.fromRGB(180, 100, 255), Enum.Font.GothamBlack
Title.BackgroundTransparency, Title.TextSize, Title.TextXAlignment = 1, 18, Enum.TextXAlignment.Left

local Container = Instance.new("ScrollingFrame", Main)
Container.Size, Container.Position = UDim2.new(1, -20, 1, -70), UDim2.new(0, 10, 0, 60)
Container.BackgroundTransparency, Container.ScrollBarThickness, Container.CanvasSize = 1, 0, UDim2.new(0,0,0,600)
local UIList = Instance.new("UIListLayout", Container)
UIList.Padding, UIList.HorizontalAlignment = UDim.new(0, 12), Enum.HorizontalAlignment.Center

-- Helpers: UI Components
local function MakeSlider(text, min, max, def, callback)
    local Frame = Instance.new("Frame", Container)
    Frame.Size, Frame.BackgroundTransparency = UDim2.new(0.95, 0, 0, 50), 1
    local Label = Instance.new("TextLabel", Frame)
    Label.Size, Label.Text = UDim2.new(1, 0, 0, 20), text..": "..def
    Label.TextColor3, Label.Font, Label.BackgroundTransparency = Color3.new(0.8,0.8,0.8), Enum.Font.GothamBold, 1
    local Bar = Instance.new("Frame", Frame)
    Bar.Size, Bar.Position, Bar.BackgroundColor3 = UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 30), Color3.fromRGB(40,40,55)
    local Knob = Instance.new("TextButton", Bar)
    Knob.Size, Knob.Position, Knob.BackgroundColor3 = UDim2.new(0,16,0,16), UDim2.new((def-min)/(max-min),-8,0.5,-8), Color3.fromRGB(180,0,255)
    Knob.Text = "" Instance.new("UICorner", Knob)
    Knob.MouseButton1Down:Connect(function()
        local move; move = RunService.RenderStepped:Connect(function()
            local p = math.clamp((player:GetMouse().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Knob.Position = UDim2.new(p, -8, 0.5, -8)
            local val = math.floor(min + (p * (max - min)))
            Label.Text = text..": "..val callback(val)
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
    end)
end

local function MakeToggle(text, callback)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size, Btn.BackgroundColor3 = UDim2.new(0.95, 0, 0, 40), Color3.fromRGB(25, 25, 35)
    Btn.Text, Btn.TextColor3, Btn.Font = text..": OFF", Color3.new(0.6,0.6,0.6), Enum.Font.GothamBold
    Instance.new("UICorner", Btn)
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = text..": "..(state and "ON" or "OFF")
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(150,0,255) or Color3.fromRGB(25,25,35), TextColor3 = state and Color3.new(1,1,1) or Color3.new(0.6,0.6,0.6)}):Play()
        callback(state)
    end)
end

MakeSlider("POWER", 1, 2000, 400, function(v) power = v end)
MakeSlider("PULSE INTERVAL", 1, 30, 5, function(v) pulseInterval = v end)
MakeToggle("PULSE MODE", function(s) pulseMode = s end)
MakeToggle("BLINK (ON MOVE)", function(s) blinkMode = s end)

local Action = Instance.new("TextButton", Container)
Action.Size, Action.BackgroundColor3 = UDim2.new(0.95, 0, 0, 50), Color3.fromRGB(0, 160, 80)
Action.Text, Action.Font, Action.TextColor3 = "START STEALTH STORM", Enum.Font.GothamBlack, Color3.new(1,1,1)
Instance.new("UICorner", Action)

local Abort = Instance.new("TextButton", Container)
Abort.Size, Abort.BackgroundColor3 = UDim2.new(0.95, 0, 0, 40), Color3.fromRGB(160, 0, 40)
Abort.Text, Abort.Font, Abort.TextColor3 = "ABORT SYSTEM", Enum.Font.GothamBold, Color3.new(1,1,1)
Instance.new("UICorner", Abort)

-- ========== MOTOR STEALTH HYBRID ==========
Action.MouseButton1Click:Connect(function()
    if isActive then return end
    isActive = true
    Action.Text = "STORM ACTIVE (BYPASSING...)"
    
    task.spawn(function()
        while isActive do
            local isMoving = player.Character and player.Character.Humanoid.MoveDirection.Magnitude > 0
            local shouldFire = (not blinkMode) or (blinkMode and isMoving)

            if shouldFire then
                -- Folosim un power limitat pentru a evita kick-ul rapid
                local burstSize = math.clamp(power, 1, 1000)
                
                for i = 1, burstSize do
                    if not isActive then break end
                    for _, r in pairs(targets) do
                        task.defer(function()
                            pcall(function()
                                if r:IsA("RemoteEvent") then r:FireServer(GetStealthPayload())
                                elseif r:IsA("RemoteFunction") then r:InvokeServer(GetStealthPayload()) end
                            end)
                        end)
                    end
                    -- Sincronizare rețea: la fiecare 30 pachete lăsăm buffer-ul să respire
                    if i % 30 == 0 then RunService.Heartbeat:Wait() end
                end
            end
            -- Cooldown între rafale pentru a scădea sub radarul Anti-Spam
            task.wait(pulseMode and pulseInterval or 0.15)
        end
    end)
end)

Abort.MouseButton1Click:Connect(function()
    isActive = false
    Action.Text = "START STEALTH STORM"
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = hrp.CFrame end
end)
